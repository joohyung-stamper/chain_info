#!/bin/bash

USER_NAME=$(whoami)
BINARY_INFO=$(echo "{ $($NODE_DAEMON version --long | grep -v 'go-version' | grep -e 'version' -e 'commit') }")

# config 경로
CONFIG_FILE="$DAEMON_HOME/config/config.toml"
APP_FILE="$DAEMON_HOME/config/app.toml"
CLIENT_FILE="$DAEMON_HOME/config/client.toml"

# minimum-gas-prices
GAS_PRICE=$(grep 'minimum-gas-prices = "' "$APP_FILE" | grep -v '^#' | sed 's/.*= "\([^"]*\)".*/\1/')

# port
RPC_PORT=$(grep -A 1 '# TCP or UNIX socket address for the RPC server to listen on' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
P2P_PORT=$(grep -A 1 '# Address to listen for incoming connections' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
LCD_PORT=$(grep -A 1 '# Address defines the API server to listen on' "$APP_FILE" | grep 'address = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
RPC_PORT=$(grep -A 1 '# TCP or UNIX socket address for the RPC server to listen on' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
GRPC_PORT=$(grep -A 1 '# Address defines the gRPC server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')
GRPCWEB_PORT=$(grep -A 1 '# Address defines the gRPC-web server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')
ROSETTA_PORT=$(grep -A 1 '# Address defines the Rosetta API server to listen on' "$APP_FILE" | grep 'address = "' | sed 's/.*"\(.*\):\(.*\)"/\2/')
PROMETHEUS_PORT=$(grep 'prometheus_listen_addr = "' "$CONFIG_FILE" | grep -v '^#' | sed 's/.*"\(.*\):\(.*\)"/\2/')
SIGNER_PORT=$(grep 'priv_validator_laddr = "' "$CONFIG_FILE" | grep -v '^#' | sed 's/.*"\(.*\):\(.*\)"/\2/')
ABCI_PORT=$(grep 'proxy_app = "tcp:' "$CONFIG_FILE" | grep -v '^#' | sed 's/.*:\([0-9]\+\)".*/\1/')
PPROF_PORT=$(grep 'pprof_laddr = "' "$CONFIG_FILE" | grep -v '^#' | sed 's/.*:\([0-9]\+\)".*/\1/')



# cpu, mem 사용량
total_cpu=0
total_mem=0
while read -r line; do
    cpu_usage=$(echo "$line" | awk '{print $3}')
    mem_kb=$(echo "$line" | awk '{print $6}')
    total_cpu=$(echo "$total_cpu + $cpu_usage" | bc)
    total_mem=$((total_mem + mem_kb))
done < <(ps aux | grep $USER_NAME)

total_cpu_percent=$(echo "scale=2; $total_cpu" | bc)
total_mem_mb=$(echo "scale=2; $total_mem / 1024" | bc)


# host address 확인
IPv4=$(curl -s ifconfig.me)

if [[ $IPv4 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    HOST_IP=$IPv4
else
    HOST_IP=$(ip addr show enp1s0f0 | grep -oP 'inet \K[\d.]+')
fi

CURRENT_STATUS=$($NODE_DAEMON status --node tcp://localhost:$RPC_PORT 2>&1 | jq '.')

echo "#####################################################################"
echo "USER_NAME :" $USER_NAME
echo "#####################################################################"
echo "DAEMON_NAME :" $DAEMON_NAME
echo "#####################################################################"
echo "BINARY_INFO:" $BINARY_INFO
echo "#####################################################################"
echo "CHAIN_ID :" $CHAIN_ID
echo "#####################################################################"
echo "GAS_PRICE :" $GAS_PRICE
echo "#####################################################################"
echo "HOST_IP :" $HOST_IP
echo "P2P :" $P2P_PORT
echo "LCD :" $LCD_PORT
echo "RPC :" $RPC_PORT
echo "GRPC :" $GRPC_PORT
echo "GRPCWEB :" $GRPCWEB_PORT
echo "ROSETTA :" $ROSETTA_PORT
echo "PROMETHEUS :" $PROMETHEUS_PORT
echo "SIGNER :" $SIGNER_PORT
echo "ABCI :" $ABCI_PORT
echo "PPROF :" $PPROF_PORT
echo "#####################################################################"
echo "CPU_USAGE: $total_cpu_percent %"
echo "MEMORY_USAGE: $total_mem_mb MB"
echo "DISK_USAGE: $(sudo du -sh $NODE_HOME)"
echo "#####################################################################"
echo "CURRENT_STATUS :" $CURRENT_STATUS
echo "#####################################################################"