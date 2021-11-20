#!/bin/bash -e

FILENAME="dump-$(date '+%d%m%Y%H%M%S')"
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"$FILENAME
mkdir -p $ABSOLUTE_PATH

echo "Generate cluster dump started..."
kubectl get -o=json ns | \
jq '.items[] |
    del(.status,
        .metadata.uid,
        .metadata.selfLink,
        .metadata.resourceVersion,
        .metadata.creationTimestamp,
        .metadata.generation
    )' > $ABSOLUTE_PATH/namespaces.json
echo "Dump namespaces done."

echo "" > $ABSOLUTE_PATH/"cluster.json"
echo "Dump cluster objects started..."
kubectl get -o=json clusterrole,clusterrolebinding,podsecuritypolicies | \
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
        end' >> $ABSOLUTE_PATH/"cluster.json"

kubectl get apiservice -o json | \
    jq '.items[] | select(.spec.service!=null) |
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
        )' >> $ABSOLUTE_PATH/"cluster.json"
echo "Dump cluster objects done."

echo "Dump objects by namespace started..."
for ns in $(jq -r '.metadata.name' < $ABSOLUTE_PATH/namespaces.json);do
    echo "  Dumping namespace: $ns"
    echo "" > $ABSOLUTE_PATH/$ns".json"

    kubectl --namespace="${ns}" get -o=json serviceaccounts,services,replicationcontrollers,secrets,daemonsets,ingresses,configmaps,deployments,horizontalpodautoscalers,cronjob,persistentvolumes,persistentvolumeclaims,resourcequotas,limitranges,rolebinding,role,networkpolicy,mutatingwebhookconfiguration | \
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
        # dont forget to skip system role / configmap / ...
        # Set reclaim policy to retain so we can recover volumes
        if .kind == "PersistentVolume" then
            .spec.persistentVolumeReclaimPolicy = "Retain"
        else
            .
        end' >> $ABSOLUTE_PATH/$ns".json"
done
echo "Dump objects by namespace done."

echo "Generate compressed file $FILENAMe.tar.gz ..."
tar -czf $ABSOLUTE_PATH".tar.gz" --remove-files --absolute-names $ABSOLUTE_PATH
echo "Done."