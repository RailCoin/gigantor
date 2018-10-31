#!/bin/bash

cd $HOME

# if a previous snapshot or actions list exists, delete it
rm -rf snapshot.json
rm -rf backfill.actions
rm -rf txgen-latest.actions

echo "snapshot-generator: installing tinman"

git clone https://github.com/steemit/tinman
virtualenv -p $(which python3) ~/ve/tinman
source ~/ve/tinman/bin/activate
cd tinman
pip install pipenv && pipenv install
pip install .

cd $HOME

timestamp=$(date +%s)

echo "snapshot-generator: generating a new snapshot.json file"
time tinman snapshot -s https://api.steemit.com -o snapshot.json

echo "snapshot-generator: generating a new txgen-latest.actions from snapshot (without backfill)"
time tinman txgen -c txgen.conf -o txgen-latest.actions

echo "snapshot-generator: generated txgen-latest.actions: $(head -1 txgen-latest.actions)"

echo "snapshot-generator: copying txgen-$timestamp.json to s3://$S3_BUCKET"
time aws s3 cp txgen-latest.actions s3://$S3_BUCKET/txgen-$timestamp.actions
echo "snapshot-generator: copying to txgen-latest.actions"
time aws s3 cp s3://$S3_BUCKET/txgen-$timestamp.actions s3://$S3_BUCKET/txgen-latest.actions

echo "backfill-generator: generating a new backfill.actions file with blocks from 30 days ago to present"
time tinman gatling -c gatling.backfill.conf --from_blocks_ago 864000 --to_blocks_ago 0 -o - | \
  tinman prefixsub > backfill.actions

echo "snapshot-generator: generating a new txgen-backfill-latest.actions from snapshot (with backfill)"
time tinman txgen -c txgen.backfill.conf -o txgen-backfill-latest.actions

echo "snapshot-generator: generated txgen-backfill-latest.actions: $(head -1 txgen-backfill-latest.actions)"

echo "snapshot-generator: copying txgen-backfill-$timestamp.json to s3://$S3_BUCKET"
time aws s3 cp txgen-backfill-latest.actions s3://$S3_BUCKET/txgen-backfill-$timestamp.actions
echo "snapshot-generator: copying to txgen-backfill-latest.actions"
time aws s3 cp s3://$S3_BUCKET/txgen-backfill-$timestamp.actions s3://$S3_BUCKET/txgen-backfill-latest.actions

echo "snapshot-generator: waiting 24 hours before running again"
sleep 86400
