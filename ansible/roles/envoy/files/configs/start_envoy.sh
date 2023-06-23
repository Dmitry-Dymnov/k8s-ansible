#!/bin/bash
#ulimit -n 102400
exec /usr/bin/envoy -c /etc/envoy/envoy.yaml --restart-epoch $RESTART_EPOCH --drain-time-s 3 --parent-shutdown-time-s 600 -l error