# Gigantor

Simple tool to generate a snapshot daily for consumption of tinman testnets. The snapshot will live in an AWS S3 bucket.

Requirements: environment variable $S3_BUCKET must be set and an IAM Role that has access to this bucket must be applied to the instance running it.

usage:

```bash
docker run -d \
  --env S3_BUCKET="$S3_BUCKET" \
  --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  steemit/gigantor:latest
```

![gigantor](https://cdn.steemitimages.com/DQmRNw6tMqmCDMXc4BAHu3EZH2dmAQnQCrNMHeukeWJU5Nx/gigantor.jpg)
