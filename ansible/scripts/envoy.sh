#!/bin/sh
config_path="ansible/roles/envoy/files"
check_envoy=$(cat actions.yaml | yq .envoy | sed 's/^- *//g')
all_k8s_clusters=$(ls -1 K8S_INFRA | sed 's/\(.*\)\..*/\1/')
function envoy_vars() {
master_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .k8s-masters | sed 's/^- *//g')
worker_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .k8s-workers | sed 's/^- *//g')
k8s_api_list=$(for master in $master_list; do
                echo "        - endpoint:"
				echo "            address:"
				echo "              socket_address: { address: $master, port_value: 6443, protocol: TCP }"
				echo "            health_check_config: { port_value: 6443 }"
                done)
k8s_ingress_http=$(for worker in $worker_list; do
                echo "        - endpoint:"
				echo "            address:"
				echo "              socket_address: { address: $worker, port_value: 80, protocol: TCP }"
				echo "            health_check_config: { port_value: 80 }"
                done)
k8s_ingress_https=$(for worker in $worker_list; do
                echo "        - endpoint:"
				echo "            address:"
				echo "              socket_address: { address: $worker, port_value: 443, protocol: TCP }"
				echo "            health_check_config: { port_value: 443 }"
                done)
eval "printf \"$(cat $config_path/envoy.yaml)\"" > $config_path/$lb
}
if [ "$check_envoy" != "" ]; then
if [ "$check_envoy" == "all" ]; then
for k8s_cluster in $all_k8s_clusters; do
lb_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for lb in $lb_list; do
envoy_vars
done
done
else
k8s_clusters=$(cat actions.yaml | yq '.envoy | keys' | sed 's/^- *//g')
for k8s_cluster in $k8s_clusters; do
check_all=$(cat actions.yaml | yq .envoy.$k8s_cluster.[] | sed 's/^- *//g')
if [ "$check_all" == "all" ]; then
lb_list=$(cat K8S_INFRA/$k8s_cluster.yaml | yq .load-balancers | sed 's/^- *//g')
for lb in $lb_list; do
envoy_vars
done
else
for lb in $check_all; do
envoy_vars
done
fi
done
fi
fi