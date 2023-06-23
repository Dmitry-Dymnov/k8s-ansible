#!/bin/sh
config_path="ansible/roles/haproxy/files"
check_haproxy=$(cat actions.yaml | yq .haproxy | sed 's/^- *//g')
all_k8s_clusters=$(ls -1 K8S_INFRA | sed 's/\(.*\)\..*/\1/')
counter=0
function haproxy_vars() {
master_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .k8s-masters | sed 's/^- *//g')
worker_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .k8s-workers | sed 's/^- *//g')
k8s_api_list=$(for master in $master_list; do
                counter=$(expr $counter + 1)
                echo "    server k8s-api-$counter $master:6443 check"
                done)
k8s_ingress_http=$(for worker in $worker_list; do
                counter=$(expr $counter + 1)
                echo "    server k8s-ingress-$counter $worker:80 check send-proxy"
                done)
k8s_ingress_https=$(for worker in $worker_list; do
                counter=$(expr $counter + 1)
                echo "    server k8s-ingress-$counter $worker:443 check send-proxy"
                done)
eval "printf \"$(cat $config_path/haproxy.cfg)\"" > $config_path/$lb
}
if [ "$check_haproxy" != "" ]; then
if [ "$check_haproxy" == "all" ]; then
for k8s_cluster in $all_k8s_clusters; do
lb_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for lb in $lb_list; do
haproxy_vars
done
done
else
k8s_clusters=$(cat actions.yaml | yq '.haproxy | keys' | sed 's/^- *//g')
for k8s_cluster in $k8s_clusters; do
check_all=$(cat actions.yaml | yq .haproxy.$k8s_cluster.[] | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
lb_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for lb in $lb_list; do
haproxy_vars
done
else
for lb in $check_all; do
haproxy_vars
done
fi
done
fi
fi