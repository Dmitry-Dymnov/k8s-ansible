#!/bin/sh
echo "#######################_ANSIBLE_INVENTORY_#######################" >> ./ansible/inventory/inventory.yml
roles_array=$(cat actions.yaml | yq 'del( .[] | select(. == "") )' | yq '. | keys' | sed 's/^- *//g')
for role in $roles_array; do
check_all=$(cat actions.yaml | yq .$role | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
cat <<- xx >> ./ansible/inventory/inventory.yml
[$role]
$(yq K8S_INFRA/* | yq 'del(.cluster-vip)' | yq .[] -N | sed 's/^- *//g')
xx
else
k8s_clusters=$(cat actions.yaml | yq '.'$role' | keys' | sed 's/^- *//g')
cat <<- xx >> ./ansible/inventory/inventory.yml
[$role]
xx
for k8s_cluster in $k8s_clusters; do
check_all=$(cat actions.yaml | yq .$role.$k8s_cluster | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
all_hosts=$(cat K8S_INFRA/$k8s_cluster.yaml | yq 'del(.cluster-vip)' | yq .[] | sed 's/^- *//g')
cat <<- xx >> ./ansible/inventory/inventory.yml
$all_hosts
xx
else
k8s_cluster_components=$(cat actions.yaml | yq '.'$role.$k8s_cluster' | keys' | sed 's/^- *//g')
for k8s_cluster_component in $k8s_cluster_components; do
check_all=$(cat actions.yaml | yq .$role.$k8s_cluster.$k8s_cluster_component | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
all_hosts=$(cat K8S_INFRA/$k8s_cluster.yaml | yq 'del(.cluster-vip)' | yq .$k8s_cluster_component | sed 's/^- *//g')
cat <<- xx >> ./ansible/inventory/inventory.yml
$all_hosts
xx
else
hosts=$(cat actions.yaml | yq .$role.$k8s_cluster.$k8s_cluster_component | sed 's/^- *//g')
cat <<- xx >> ./ansible/inventory/inventory.yml
$hosts
xx
fi
done
fi
done
fi
done
echo "#################################################################" >> ./ansible/inventory/inventory.yml