#!/bin/bash

cd $HOME

# if a previous snapshots or actions list exists, delete it
rm -rf snapshot.json
rm -rf sample-snapshot.json
rm -rf backfill.actions
rm -rf no-accounts-txgen-latest.actions
rm -rf sample-txgen-latest.actions
rm -rf txgen-latest.actions

echo "snapshot-generator: installing tinman"

git clone https://github.com/steemit/tinman
virtualenv -p $(which python3) ~/ve/tinman
source ~/ve/tinman/bin/activate
cd tinman
pip install pipenv && pipenv install
pip install .

pip install awscli
export PATH=$PATH:$HOME/.local/bin

cd $HOME

timestamp=$(date +%s)

# FIXME - tinman does not yet support zero accounts because zero total_vests
# is not handled properly.  See: https://github.com/steemit/tinman/issues/180

# echo "snapshot-generator: generating a new no-accounts-txgen-latest.actions from no-accounts-snapshot (without backfill)"
# time tinman txgen -c $APP_ROOT/no-accounts-txgen.conf -o no-accounts-txgen-latest.actions
#
#echo "snapshot-generator: generated no-accounts-txgen-latest.actions: $(head -1 no-accounts-txgen-latest.actions)"
#
#echo "snapshot-generator: copying no-accounts-txgen-$timestamp.json to s3://$S3_BUCKET"
#time aws s3 cp no-accounts-txgen-latest.actions s3://$S3_BUCKET/no-accounts-txgen-$timestamp.actions
#echo "snapshot-generator: copying to no-accounts-txgen-latest.actions"
#time aws s3 cp s3://$S3_BUCKET/no-accounts-txgen-$timestamp.actions s3://$S3_BUCKET/no-accounts-txgen-latest.actions

echo "snapshot-generator: generating a new $APP_ROOT/snapshot.json file"
time tinman snapshot -s https://api.steemit.com -o $APP_ROOT/snapshot.json

echo "snapshot-generator: generating a new $APP_ROOT/sample-snapshot.json file"
time tinman sample -i $APP_ROOT/snapshot.json -o $APP_ROOT/sample-snapshot.json

echo "snapshot-generator: generating a new $APP_ROOT/txgen-latest.actions from snapshot (without backfill)"
time tinman txgen -c $APP_ROOT/txgen.conf -o $APP_ROOT/txgen-latest.actions

echo "snapshot-generator: generated $APP_ROOT/txgen-latest.actions: $(head -1 $APP_ROOT/txgen-latest.actions)"

echo "snapshot-generator: copying $APP_ROOT/txgen-$timestamp.json to s3://$S3_BUCKET"
time aws s3 cp $APP_ROOT/txgen-latest.actions s3://$S3_BUCKET/txgen-$timestamp.actions
echo "snapshot-generator: copying to $APP_ROOT/txgen-latest.actions"
time aws s3 cp s3://$S3_BUCKET/txgen-$timestamp.actions s3://$S3_BUCKET/txgen-latest.actions

echo "snapshot-generator: generating a new $APP_ROOT/sample-txgen-latest.actions from sample-snapshot (without backfill)"
time tinman txgen -c $APP_ROOT/sample-txgen.conf -o $APP_ROOT/sample-txgen-latest.actions

echo "snapshot-generator: generated $APP_ROOT/sample-txgen-latest.actions: $(head -1 $APP_ROOT/sample-txgen-latest.actions)"

echo "snapshot-generator: copying $APP_ROOT/sample-txgen-$timestamp.json to s3://$S3_BUCKET"
time aws s3 cp $APP_ROOT/sample-txgen-latest.actions s3://$S3_BUCKET/sample-txgen-$timestamp.actions
echo "snapshot-generator: copying to $APP_ROOT/sample-txgen-latest.actions"
time aws s3 cp s3://$S3_BUCKET/sample-txgen-$timestamp.actions s3://$S3_BUCKET/sample-txgen-latest.actions

echo "backfill-generator: generating a new $APP_ROOT/backfill.actions file with blocks from 30 days ago to present"
time tinman gatling -c $APP_ROOT/gatling.backfill.conf --from_blocks_ago 864000 --to_blocks_ago 0 -o - | \
  tinman prefixsub > $APP_ROOT/backfill.actions

echo "snapshot-generator: generating a new $APP_ROOT/txgen-backfill-latest.actions from snapshot (with backfill)"
time tinman txgen -c $APP_ROOT/txgen.backfill.conf -o $APP_ROOT/txgen-backfill-latest.actions

echo "snapshot-generator: generated $APP_ROOT/txgen-backfill-latest.actions: $(head -1 $APP_ROOT/txgen-backfill-latest.actions)"

echo "snapshot-generator: copying $APP_ROOT/txgen-backfill-$timestamp.json to s3://$S3_BUCKET"
time aws s3 cp $APP_ROOT/txgen-backfill-latest.actions s3://$S3_BUCKET/txgen-backfill-$timestamp.actions
echo "snapshot-generator: copying to $APP_ROOT/txgen-backfill-latest.actions"
time aws s3 cp s3://$S3_BUCKET/txgen-backfill-$timestamp.actions s3://$S3_BUCKET/txgen-backfill-latest.actions

echo "snapshot-generator: waiting 24 hours before running again"
sleep 86400
