#!/bin/bash
# update gcloud sdk tool
gcloud components update -q
INSTANCE_GROUP_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/instance_group_name)
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | sed 's:.*/::')
INSTANCES=($(gcloud --format='value(instance)' compute instance-groups list-instances $INSTANCE_GROUP_NAME --zone=$ZONE))
args="CONSUL_SERVERS=-bootstrap-expect=${#INSTANCES[@]} "
for x in "${INSTANCES[@]}"; do args+="-retry-join=$x "; done
#args+="-retry-join=${servers[0]}"
echo $args
