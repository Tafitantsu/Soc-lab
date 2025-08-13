#!/bin/sh
set -e

# Wait for MinIO to be available
until mc alias set myminio http://localhost:9002 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD; do
    echo "MinIO not ready yet, retrying in 5 seconds..."
    sleep 5
done

echo "MinIO is up and ready."

# Create the bucket if it doesn't exist
if mc ls myminio | grep -q "${MINIO_BUCKET_NAME}"; then
  echo "Bucket '${MINIO_BUCKET_NAME}' already exists."
else
  echo "Creating bucket '${MINIO_BUCKET_NAME}'..."
  mc mb myminio/${MINIO_BUCKET_NAME}
  echo "Bucket '${MINIO_BUCKET_NAME}' created successfully."
fi

# Set bucket policy to allow public read (optional, useful for some scenarios)
# mc policy set public myminio/${MINIO_BUCKET_NAME}
# echo "Bucket policy set to public."

exit 0
