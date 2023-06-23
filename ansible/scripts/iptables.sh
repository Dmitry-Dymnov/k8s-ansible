#!/bin/sh
config_path="ansible/roles/iptables/vars"
check_iptables=$(cat actions.yaml | yq .iptables | sed 's/^- *//g')
all_k8s_clusters=$(ls -1 K8S_INFRA | sed 's/\(.*\)\..*/\1/')
function iptables_vars() {
iptables_list=$(for srv in $srv_list; do
                echo "  - $srv"
                done)
cat <<- xx > $config_path/$srv
iptables_list:
$iptables_list
xx
}
if [ "$check_iptables" != "" ]; then
if [ "$check_iptables" == "all" ]; then
for k8s_cluster in $all_k8s_clusters; do
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq 'del(.cluster-vip)' | yq .[] -N | sed 's/^- *//g')
for srv in $srv_list; do
iptables_vars
done
done
else
k8s_clusters=$(cat actions.yaml | yq '.iptables | keys' | sed 's/^- *//g')
for k8s_cluster in $k8s_clusters; do
check_all=$(cat actions.yaml | yq .iptables.$k8s_cluster.[] | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq 'del(.cluster-vip)' | yq .[] -N | sed 's/^- *//g')
for srv in $srv_list; do
iptables_vars
done
else
srv_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq 'del(.cluster-vip)' | yq .[] -N | sed 's/^- *//g')
for srv in $check_all; do
iptables_vars
done
fi
done
fi
fi