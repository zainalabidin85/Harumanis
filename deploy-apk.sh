#!/bin/bash
set -e

# Usage: ./deploy-apk.sh ai|beli
# Builds the release APK and uploads it to Cloudflare R2 under a stable
# filename (no version suffix), matching the iot project's deploy-apk.sh.
#
# Requires R2 credentials scoped to the "mlharum" bucket, set as env vars:
#   export R2_ACCESS_KEY_ID=...
#   export R2_SECRET_ACCESS_KEY=...

APP="$1"
case "$APP" in
  ai)
    APP_DIR="mlharum-app"
    APK_NAME="Ai-Harumanis.apk"
    ;;
  beli)
    APP_DIR="harumanis-app"
    APK_NAME="BeliHarumanis.apk"
    ;;
  *)
    echo "Usage: $0 ai|beli"
    exit 1
    ;;
esac

R2_BUCKET="mlharum"
R2_ENDPOINT="https://ca3601ca077ec7930f01046f7e5d3001.r2.cloudflarestorage.com"
R2_PUBLIC_URL="https://pub-09d17b214a8449658a27e1cbecccb5ab.r2.dev"
: "${R2_ACCESS_KEY_ID:?Set R2_ACCESS_KEY_ID (R2 token scoped to the mlharum bucket)}"
: "${R2_SECRET_ACCESS_KEY:?Set R2_SECRET_ACCESS_KEY (R2 token scoped to the mlharum bucket)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_LOCAL="$SCRIPT_DIR/$APP_DIR/build/app/outputs/flutter-apk/app-release.apk"

echo "==> Building $APP_DIR release APK..."
cd "$SCRIPT_DIR/$APP_DIR"
flutter build apk --release

echo "==> Uploading $APK_NAME to Cloudflare R2 (bucket: $R2_BUCKET)..."
python3 - "$APK_LOCAL" "$APK_NAME" <<EOF
import boto3, sys
from botocore.config import Config

apk_path, apk_name = sys.argv[1], sys.argv[2]
s3 = boto3.client(
    's3',
    endpoint_url='$R2_ENDPOINT',
    aws_access_key_id='$R2_ACCESS_KEY_ID',
    aws_secret_access_key='$R2_SECRET_ACCESS_KEY',
    config=Config(signature_version='s3v4'),
    region_name='auto'
)
with open(apk_path, 'rb') as f:
    s3.upload_fileobj(f, '$R2_BUCKET', apk_name,
        ExtraArgs={'ContentType': 'application/vnd.android.package-archive'})
print('R2 upload complete.')
EOF

echo ""
echo "✓ APK deployed to R2."
echo "  Download URL: $R2_PUBLIC_URL/$APK_NAME"
