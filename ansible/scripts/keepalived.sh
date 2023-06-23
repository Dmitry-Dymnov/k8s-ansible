#!/bin/sh
config_path="ansible/roles/keepalived/vars"
check_keepalived=$(cat actions.yaml | yq .keepalived | sed 's/^- *//g')
all_k8s_clusters=$(ls -1 K8S_INFRA | sed 's/\(.*\)\..*/\1/')
function keepalived_vars() {
vip=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .cluster-vip | sed 's/^- *//g')
keepalived_list=$(for srv in $srv_list; do
                echo "  - $srv"
                done)
cat <<- xx > $config_path/$srv
vip:
  - $vip
vr_id:
  - $vr_id
keepalived_list:
$keepalived_list
xx
}
if [ "$check_keepalived" != "" ]; then
if [ "$check_keepalived" == "all" ]; then
for k8s_cluster in $all_k8s_clusters; do
vr_id=$(($RANDOM % 100 + 150))
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for srv in $srv_list; do
keepalived_vars
done
done
else
k8s_clusters=$(cat actions.yaml | yq '.keepalived | keys' | sed 's/^- *//g')
for k8s_cluster in $k8s_clusters; do
vr_id=$(($RANDOM % 100 + 150))
check_all=$(cat actions.yaml | yq .keepalived.$k8s_cluster.[] | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for srv in $srv_list; do
keepalived_vars
done
else
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | yq .[] -N | sed 's/^- *//g')
for srv in $check_all; do
keepalived_vars
done
fi
done
fi
fi