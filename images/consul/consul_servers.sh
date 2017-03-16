#!/bin/bash
# update gcloud sdk tool
RETRY_COUNT=0
until [ `gcloud components update -q` ] || [ "$RETRY_COUNT" -gt 12 ]; do
    /usr/bin/systemd-cat -t "consul_servers" /usr/bin/echo "Could not update gcloud components"
    sleep 5
    ((RETRY_COUNT++))
done
INSTANCE_GROUP_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/created-by | sed 's:.*/::')
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | sed 's:.*/::')
INSTANCES=($(gcloud --format='value(instance)' compute instance-groups list-instances $INSTANCE_GROUP_NAME --zone=$ZONE))
args="CONSUL_SERVERS=-bootstrap-expect=${#INSTANCES[@]} "
for x in "${INSTANCES[@]}"; do args+="-retry-join=$x "; done
#args+="-retry-join=${servers[0]}"
echo $args
