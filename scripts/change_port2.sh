#!/bin/bash

# 포트 변경 함수
change_port() {
    local current_port=$1
    local new_port_prompt=$2
    local config_file=$3

    echo "현재 포트: $current_port"
    echo "새 포트를 입력하세요 ($new_port_prompt):"
    read new_port

    # 포트 교체 혹은 기존값 유지
    if [ -n "$new_port" ]; then
        sed -i "s/$current_port/$new_port/" "$config_file"
        echo "변경된 포트: $new_port"
    else
        echo "포트 변경 없음. 기존 값 유지: $current_port"
    fi
}

echo "########################################"
echo "현재 설정:"
echo "CURRENT_DAEMON_NAME : $DAEMON_NAME"
echo "CURRENT_CHAIN_ID : $CHAIN_ID"
echo "CURRENT_DAEMON_HOME : $DAEMON_HOME"

# config 파일 경로
CONFIG_FILE="$DAEMON_HOME/config/config.toml"
APP_FILE="$DAEMON_HOME/config/app.toml"
CLIENT_FILE="$DAEMON_HOME/config/client.toml"

# 포트 
P2P_PORT=$(grep -A 1 '# Address to listen for incoming connections' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
LCD_PORT=$(grep -A 1 '# Address defines the API server to listen on' "$APP_FILE" | grep 'address = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
RPC_PORT=$(grep -A 1 '# TCP or UNIX socket address for the RPC server to listen on' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
RPC_PORT2=$(grep 'node = "tcp://localhost' "$CLIENT_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')
GRPC_PORT=$(grep -A 1 '# Address defines the gRPC server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')
GRPCWEB_PORT=$(grep -A 1 '# Address defines the gRPC-web server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')
ROSETTA_PORT=$(grep -A 1 '# Address defines the Rosetta API server to listen on' "$APP_FILE" | grep 'address = "' | sed 's/.*"\(.*\):\(.*\)"/\2/')
PROMETHEUS_PORT=$(grep 'prometheus_listen_addr = "' "$CONFIG_FILE" | sed 's/.*"\(.*\):\(.*\)"/\2/')
SIGNER_PORT=$(grep 'priv_validator_laddr = "' "$CONFIG_FILE" | sed 's/.*"\(.*\):\(.*\)"/\2/')
ABCI_PORT=$(grep 'proxy_app = "tcp:' "$CONFIG_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')
PPROF_PORT=$(grep 'pprof_laddr = "' "$CONFIG_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')

echo "########################################"
echo "사용 중인 포트 :"
echo "P2P: $P2P_PORT"
echo "LCD: $LCD_PORT"
echo "RPC: $RPC_PORT"
echo "GRPC: $GRPC_PORT"
echo "GRPCWEB: $GRPCWEB_PORT"
echo "ROSETTA: $ROSETTA_PORT"
echo "PROMETHEUS: $PROMETHEUS_PORT"
echo "SIGNER: $SIGNER_PORT"
echo "ABCI: $ABCI_PORT"
echo "PPROF: $PPROF_PORT"
echo "########################################"

echo "########################################"
echo "포트 수정을 시작하시겠습니까? (y/yes)"
read answer

if [ "$answer" == "y" ] || [ "$answer" == "yes" ]; then
    cp "${NODE_HOME}/config/config.toml" "${NODE_HOME}/config/config.toml.oldport"
    cp "${NODE_HOME}/config/app.toml" "${NODE_HOME}/config/app.toml.oldport"
    cp "${NODE_HOME}/config/client.toml" "${NODE_HOME}/config/client.toml.oldport"

    # 함수 호출
    change_port "$P2P_PORT" "끝자리 00" "$CONFIG_FILE"
    change_port "$LCD_PORT" "끝자리 01" "$APP_FILE"
    change_port "$RPC_PORT" "끝자리 02" "$CONFIG_FILE"
    change_port "$GRPC_PORT" "끝자리 03" "$APP_FILE"
    change_port "$GRPCWEB_PORT" "끝자리 04" "$APP_FILE"
    change_port "$ROSETTA_PORT" "끝자리 07" "$APP_FILE"
    change_port "$PROMETHEUS_PORT" "끝자리 08" "$CONFIG_FILE"

    if [ -n "$SIGNER_PORT" ]; then
        change_port "$SIGNER_PORT" "끝자리 09" "$CONFIG_FILE"
    fi

    change_port "$ABCI_PORT" "끝자리 10" "$CONFIG_FILE"
    change_port "$PPROF_PORT" "끝자리 11" "$CONFIG_FILE"

    echo "########################################"
    echo
    echo "포트 수정이 완료되었습니다."
    echo "########################################"
else
    echo "포트 수정이 취소되었습니다."
fi
