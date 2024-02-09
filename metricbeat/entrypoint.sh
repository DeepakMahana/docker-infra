#!/usr/bin/env bash

wait_single_host() {
  local host=$1
  local port=$2
  local timeout=120  # Timeout in seconds
  local interval=1  # Check interval in seconds
  local endtime=$((SECONDS + timeout))
  
  echo "==> Checking host ${host}:${port}"
  
  while [ $SECONDS -lt $endtime ]; do
    if nc -z "$host" "$port"; then
      echo "   --> Connection to ${host}:${port} successful"
      return 0  # Success status
    else
      echo "   --> Waiting for ${host}:${port} to be available"
      sleep "$interval"
    fi
  done
  
  echo "   --> Timeout reached while waiting for ${host}:${port} to be available"
  return 1  # Failure status
}

wait_all_hosts() {
  if [ ! -z "$WAIT_FOR_HOSTS" ]; then
    IFS=" " read -ra host_ports <<< "$WAIT_FOR_HOSTS"
    for host_port in "${host_ports[@]}"; do
      IFS=":" read -r host port <<< "$host_port"
      wait_single_host "$host" "$port"
    done
  else
    echo "IMPORTANT: Waiting for nothing because no \$WAIT_FOR_HOSTS environment variable is defined."
  fi
}

wait_all_hosts

# Wait for Elasticsearch cluster to reach YELLOW status
while ! curl -s -X GET "${HOST_ELASTICSEARCH}/_cluster/health?wait_for_status=yellow&timeout=60s" | grep -q '"status":"yellow"'; do
  echo "==> Waiting for cluster YELLOW status" && sleep 1
done

echo ""
echo "Cluster is YELLOW. Fine! (But you could maybe try to have it GREEN ;))"
echo ""

# Execute docker-entrypoint script
bash -c "/usr/local/bin/docker-entrypoint $*"
