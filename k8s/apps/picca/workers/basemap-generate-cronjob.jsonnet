local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
local sourcePvc = import 'basemap-source-pvc.jsonnet';

local releaseTag = 'v0.0.45';

local downloaderScript = |||
  set -eu

  BASE_URL="https://planet.openstreetmap.org/pbf"
  OCEAN_URL="https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip"
  TMP_DIR="/source/.download-tmp"
  mkdir -p "$TMP_DIR"

  curl_dl() {
    curl --fail --location --proto '=https' --proto-redir '=https' \
      --silent --show-error \
      --retry 10 --retry-delay 10 --retry-all-errors \
      --connect-timeout 30 --speed-limit 1024 --speed-time 120 \
      "$@"
  }

  curl_dl -o "$TMP_DIR/planet-pbf-rss.xml" "$BASE_URL/planet-pbf-rss.xml"
  SNAPSHOT=$(grep -o 'planet-[0-9]\{6\}\.osm\.pbf' "$TMP_DIR/planet-pbf-rss.xml" | head -n1)
  if [ -z "$SNAPSHOT" ]; then
    echo "failed to resolve latest planet snapshot filename from RSS feed" >&2
    exit 1
  fi
  SNAPSHOT_DATE=$(printf '%s' "$SNAPSHOT" | sed -n 's/^planet-\([0-9]\{6\}\)\.osm\.pbf$/\1/p')

  curl_dl -o "$TMP_DIR/${SNAPSHOT}.md5" "$BASE_URL/${SNAPSHOT}.md5"
  EXPECTED_MD5=$(awk '{print $1}' "$TMP_DIR/${SNAPSHOT}.md5")

  FINAL="/source/$SNAPSHOT"
  PART="/source/${SNAPSHOT}.part"

  NEED_DOWNLOAD=1
  if [ -f "$FINAL" ]; then
    ACTUAL_MD5=$(md5sum "$FINAL" | awk '{print $1}')
    if [ "$ACTUAL_MD5" = "$EXPECTED_MD5" ]; then
      NEED_DOWNLOAD=0
    fi
  fi

  if [ "$NEED_DOWNLOAD" = "1" ]; then
    ATTEMPT=1
    while [ "$ATTEMPT" -le 2 ]; do
      if [ -f "$PART" ]; then
        echo "resuming $PART from offset $(wc -c < "$PART")"
      fi
      curl_dl --continue-at - --output "$PART" "$BASE_URL/$SNAPSHOT"
      ACTUAL_MD5=$(md5sum "$PART" | awk '{print $1}')
      if [ "$ACTUAL_MD5" = "$EXPECTED_MD5" ]; then
        mv "$PART" "$FINAL"
        break
      fi
      echo "checksum mismatch for $SNAPSHOT (attempt $ATTEMPT): expected $EXPECTED_MD5, got $ACTUAL_MD5" >&2
      rm -f "$PART"
      ATTEMPT=$((ATTEMPT + 1))
    done
    if [ ! -f "$FINAL" ]; then
      echo "checksum mismatch: full redownload required for $SNAPSHOT" >&2
      exit 1
    fi
  fi

  ln -sfn "$SNAPSHOT" /source/planet.osm.pbf

  find /source -maxdepth 1 -type f -name '*.part' ! -name "$(basename "$PART")" -delete

  OCEAN_FINAL="/source/water-polygons-split-3857.zip"
  OCEAN_PART="/source/water-polygons-split-3857.zip.part"
  if [ -f "$OCEAN_PART" ]; then
    echo "resuming $OCEAN_PART from offset $(wc -c < "$OCEAN_PART")"
  fi
  curl_dl --continue-at - --output "$OCEAN_PART" "$OCEAN_URL"
  mv "$OCEAN_PART" "$OCEAN_FINAL"

  rm -rf "$TMP_DIR"

  mkdir -p /work-metadata
  printf '%s' "$SNAPSHOT_DATE" > /work-metadata/source-snapshot
  printf '%s-%s' "$SNAPSHOT_DATE" "$RELEASE_TAG" > /work-metadata/dataset-version
|||;

local plantilerScript = |||
  set -eu
  DATASET_VERSION=$(cat /work-metadata/dataset-version)
  exec java -cp @/app/jib-classpath-file com.onthegomap.planetiler.Main generate-custom \
    --schema=/schema/schema.yml \
    --dataset_version="$DATASET_VERSION" \
    --output=/scratch/basemap.pmtiles \
    --tmpdir=/scratch/tmp \
    --threads=6 \
    --nodemap_type=sparsearray \
    --nodemap_storage=mmap
|||;

local fontsExtractScript = |||
  set -eu
  mkdir -p /scratch/fonts
  tar xzf /fonts-image/fonts.tar.gz -C /scratch/fonts
|||;

local publishScript = |||
  set -eu
  DATASET_VERSION=$(cat /work-metadata/dataset-version)
  SOURCE_SNAPSHOT=$(cat /work-metadata/source-snapshot)

  rclone copyto /scratch/basemap.pmtiles "seaweedfs:picca/basemap-versions/${DATASET_VERSION}.pmtiles" \
    --s3-no-check-bucket \
    --header-upload "Cache-Control: public, max-age=31536000, immutable"

  rclone copyto /scratch/basemap.pmtiles seaweedfs:picca/basemap/basemap.pmtiles \
    --s3-no-check-bucket \
    --header-upload "Cache-Control: public, max-age=300"

  GENERATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  cat > /scratch/latest.json <<EOF
  {"version":"$DATASET_VERSION","sourceSnapshot":"$SOURCE_SNAPSHOT","pmtiles":"/basemap-versions/${DATASET_VERSION}.pmtiles","generatedAt":"$GENERATED_AT"}
  EOF

  rclone copyto /scratch/latest.json seaweedfs:picca/basemap/latest.json \
    --s3-no-check-bucket \
    --header-upload "Cache-Control: no-cache"

  rclone copy /scratch/fonts seaweedfs:picca/fonts \
    --s3-no-check-bucket \
    --header-upload "Cache-Control: public, max-age=86400, must-revalidate"

  {
    find /source -maxdepth 1 -type f -name 'planet-*.osm.pbf' ! -name "planet-${SOURCE_SNAPSHOT}.osm.pbf" -delete
    find /source -maxdepth 1 -type f -name '*.part' -delete
    rm -rf /source/.download-tmp
  } || true
|||;

{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-basemap-generate',
    namespace: app.namespace,
    labels: labels(app.name + '-basemap-generate'),
  },
  spec: {
    schedule: '0 3 1 * *',  // 毎月1日 03:00
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 300,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      spec: {
        activeDeadlineSeconds: 48 * 60 * 60,
        backoffLimit: 1,
        ttlSecondsAfterFinished: 3 * 24 * 60 * 60,
        template: {
          metadata: {
            labels: labels(app.name + '-basemap-generate'),
          },
          spec: {
            serviceAccountName: (import '../sa.jsonnet').metadata.name,
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            restartPolicy: 'Never',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
              fsGroup: 65532,
              fsGroupChangePolicy: 'OnRootMismatch',
            },
            initContainers: [
              (import '../../../components/container.libsonnet') {
                name: 'source-download',
                image: 'docker.io/curlimages/curl:8.21.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [downloaderScript],
                env: [
                  { name: 'RELEASE_TAG', value: releaseTag },
                ],
                resources: {
                  requests: { cpu: '250m', memory: '64Mi' },
                  limits: { memory: '256Mi' },
                },
                volumeMounts: [
                  { name: 'source', mountPath: '/source' },
                  { name: 'work-metadata', mountPath: '/work-metadata' },
                ],
              },
              (import '../../../components/container.libsonnet') {
                name: 'fonts-extract',
                image: 'docker.io/curlimages/curl:8.21.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [fontsExtractScript],
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { memory: '512Mi' },
                },
                volumeMounts: [
                  { name: 'fonts', mountPath: '/fonts-image', readOnly: true },
                  { name: 'scratch', mountPath: '/scratch' },
                ],
              },
              (import '../../../components/container.libsonnet') {
                name: 'planetiler',
                image: 'ghcr.io/onthegomap/planetiler:0.10.2',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [plantilerScript],
                env: [
                  { name: 'JAVA_TOOL_OPTIONS', value: '-Xmx16g' },
                ],
                resources: {
                  requests: { cpu: '4', memory: '24Gi' },
                  limits: { memory: '32Gi' },
                },
                volumeMounts: [
                  { name: 'source', mountPath: '/source', readOnly: true },
                  { name: 'schema', mountPath: '/schema', readOnly: true },
                  { name: 'scratch', mountPath: '/scratch' },
                  { name: 'work-metadata', mountPath: '/work-metadata', readOnly: true },
                ],
              },
            ],
            containers: [
              (import '../../../components/container.libsonnet') {
                name: 'rclone',
                image: 'ghcr.io/rclone/rclone:1.75.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [publishScript],
                env: commonEnv + s3Irsa.env + [
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_TYPE',
                    value: 's3',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_PROVIDER',
                    value: 'Other',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_ENV_AUTH',
                    value: 'true',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_ENDPOINT',
                    value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_REGION',
                    value: 'us-east-1',
                  },
                  {
                    name: 'OTEL_SERVICE_NAME',
                    value: 'picca-basemap-generate',
                  },
                ],
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { memory: '768Mi' },
                },
                volumeMounts: [
                  { name: 'scratch', mountPath: '/scratch' },
                  { name: 'work-metadata', mountPath: '/work-metadata', readOnly: true },
                  { name: 'source', mountPath: '/source' },
                ] + s3Irsa.volumeMounts,
              },
            ],
            volumes: [
              {
                name: 'source',
                persistentVolumeClaim: { claimName: sourcePvc.metadata.name },
              },
              {
                name: 'scratch',
                ephemeral: {
                  volumeClaimTemplate: {
                    spec: {
                      storageClassName: 'local-path',
                      accessModes: ['ReadWriteOnce'],
                      resources: { requests: { storage: '450Gi' } },
                    },
                  },
                },
              },
              {
                name: 'work-metadata',
                emptyDir: {},
              },
              {
                name: 'schema',
                image: { reference: 'ghcr.io/walnuts1018/picca/basemap-schema:' + releaseTag },
              },
              {
                name: 'fonts',
                image: { reference: 'ghcr.io/walnuts1018/picca/basemap-fonts:' + releaseTag },
              },
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
