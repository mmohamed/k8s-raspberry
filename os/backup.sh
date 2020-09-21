#!/bin/bash -e

# Adapted from:
# https://github.com/colhom/coreos-docs/blob/cluster-dump-restore/kubernetes/cluster-dump-restore.md

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../bkp"
mkdir -p $ABSOLUTE_PATH

kubectl get --export -o=json ns | \
jq '.items[] |
    del(.status,
        .metadata.uid,
        .metadata.selfLink,
        .metadata.resourceVersion,
        .metadata.creationTimestamp,
        .metadata.generation
    )' > $ABSOLUTE_PATH/ns.json

echo "" > $ABSOLUTE_PATH/cluster-dump.json
for ns in $(jq -r '.metadata.name' < $ABSOLUTE_PATH/ns.json);do
    echo "Namespace: $ns"

    kubectl --namespace="${ns}" get --export -o=json svc,rc,secrets,ds,cm,deploy,hpa,pv,pvc,quota,limits,ns,storageclass | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .spec.clusterIP, # clusterIP is dynamically assigned
            .spec.claimRef,  # Throw this out so we can rebind
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .spec.template.spec.securityContext,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .spec?.ports[]?.nodePort? # Delete nodePort from service since this is dynamic
        ) |

        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then 
            .spec.persistentVolumeReclaimPolicy = "Retain" 
        else
            . 
        end' >> $ABSOLUTE_PATH/cluster-dump.json
done
