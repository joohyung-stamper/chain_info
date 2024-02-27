#!/bin/bash

echo "########################################"
echo "CURRENT_DAEMON_NAME :" $DAEMON_NAME
echo "CURRENT_CHAIN_ID :" $CHAIN_ID
echo "CURRENT_DAEMON_HOME :" $DAEMON_HOME

# config 경로
CONFIG_FILE="$DAEMON_HOME/config/config.toml"
APP_FILE="$DAEMON_HOME/config/app.toml"
CLIENT_FILE="$DAEMON_HOME/config/client.toml"

# 기본값 26656
P2P_PORT=$(grep -A 1 '# Address to listen for incoming connections' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')

# 기본값 1317
LCD_PORT=$(grep -A 1 '# Address defines the API server to listen on' "$APP_FILE" | grep 'address = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')

# 기본값 26657
RPC_PORT=$(grep -A 1 '# TCP or UNIX socket address for the RPC server to listen on' "$CONFIG_FILE" | grep 'laddr = "tcp:' | sed 's/.*:\([0-9]\+\)".*/\1/')
RPC_PORT2=$(grep 'node = "tcp://localhost' "$CLIENT_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')

# 기본값 9090
GRPC_PORT=$(grep -A 1 '# Address defines the gRPC server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')

# 기본값 9091
GRPCWEB_PORT=$(grep -A 1 '# Address defines the gRPC-web server address to bind to' "$APP_FILE" | grep 'address = "\(localhost:\|0.0.0.0:\)' | sed 's/.*"\(.*\):\(.*\)"/\2/')

# 기본값 8080
ROSETTA_PORT=$(grep -A 1 '# Address defines the Rosetta API server to listen on' "$APP_FILE" | grep 'address = "' | sed 's/.*"\(.*\):\(.*\)"/\2/')

# 기본값 26660
PROMETHEUS_PORT=$(grep 'prometheus_listen_addr = "' "$CONFIG_FILE" | sed 's/.*"\(.*\):\(.*\)"/\2/')

# 기본값 X
SIGNER_PORT=$(grep 'priv_validator_laddr = "' "$CONFIG_FILE" | sed 's/.*"\(.*\):\(.*\)"/\2/')

# 기본값 26658
ABCI_PORT=$(grep 'proxy_app = "tcp:' "$CONFIG_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')

# 기본값 6060
PPROF_PORT=$(grep 'pprof_laddr = "' "$CONFIG_FILE" | sed 's/.*:\([0-9]\+\)".*/\1/')


echo "########################################"
echo "CURRENTLY_USED_PORT :"
echo "P2P" : $P2P_PORT
echo "LCD" : $LCD_PORT
echo "RPC" : $RPC_PORT
echo "GRPC" : $GRPC_PORT
echo "GRPCWEB" : $GRPCWEB_PORT
echo "ROSETTA" : $ROSETTA_PORT
echo "PROMETHEUS" : $PROMETHEUS_PORT
echo "SIGNER" : $SIGNER_PORT
echo "ABCI" : $ABCI_PORT
echo "PPROF" : $PPROF_PORT

echo "########################################"
echo "포트 수정을 시작하시겠습니까? (y/yes)"
read answer

if [ "$answer" == "y" ] || [ "$answer" == "yes" ]; then
    
    cp "${NODE_HOME}/config/config.toml" "${NODE_HOME}/config/config.toml.oldport"
    cp "${NODE_HOME}/config/app.toml" "${NODE_HOME}/config/app.toml.oldport"
    cp "${NODE_HOME}/config/client.toml" "${NODE_HOME}/config/client.toml.oldport"

    # P2P_PORT 수정
    echo "현재 P2P 포트: $P2P_PORT"
    echo "새 P2P 포트를 입력하세요 (끝자리 00):"
    read NEW_P2P_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_P2P_PORT" ]; then
        sed -i "s/$P2P_PORT/$NEW_P2P_PORT/" "$CONFIG_FILE"
        echo "CHANGED_P2P_PORT: $NEW_P2P_PORT"
    else
        echo "P2P_PORT 변경 없음. 기존값 유지: $P2P_PORT"
    fi

    echo "########################################"
    
    # LCD_PORT 수정
    echo "현재 LCD 포트: $LCD_PORT"
    echo "새 LCD 포트를 입력하세요 (끝자리 01):"
    read NEW_LCD_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_LCD_PORT" ]; then
    sed -i "s/"$LCD_PORT"/"$NEW_LCD_PORT"/" "$APP_FILE"
    echo "CHANGED_P2P_PORT: $NEW_LCD_PORT"
    else
        echo "P2P_PORT 변경 없음. 기존 값 유지: $LCD_PORT"
    fi

    echo "########################################"
    
    # RPC_PORT 수정
    echo "현재 RPC 포트: $RPC_PORT"
    echo "새 RPC 포트를 입력하세요 (끝자리 02):"
    read NEW_RPC_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_RPC_PORT" ]; then
    sed -i "s/"$RPC_PORT"/"$NEW_RPC_PORT"/" "$CONFIG_FILE"
    sed -i "s/"$RPC_PORT2"/"$NEW_RPC_PORT"/" "$CLIENT_FILE"
    echo "CHANGED_RPC_PORT: $NEW_RPC_PORT"
    else
        echo "RPC_PORT 변경 없음. 기존값 유지: $RPC_PORT"
    fi

    echo "########################################"
    
    # GRPC_PORT 수정
    echo "현재 GRPC 포트: $GRPC_PORT"
    echo "새 GRPC 포트를 입력하세요 (끝자리 03):"
    read NEW_GRPC_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_GRPC_PORT" ]; then
    sed -i "s/"$GRPC_PORT"/"$NEW_GRPC_PORT"/" "$APP_FILE"
    echo "CHANGED_GRPC_PORT: $NEW_GRPC_PORT"
    else
        echo "GRPC_PORT 변경 없음. 기존 값 유지: $GRPC_PORT"
    fi

    echo "########################################"
    
    # GRPCWEB_PORT 수정
    echo "현재 GRPCWEB 포트: $GRPCWEB_PORT"
    echo "새 GRPCWEB 포트를 입력하세요 (끝자리 04):"
    read NEW_GRPCWEB_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_GRPCWEB_PORT" ]; then
    sed -i "s/"$GRPCWEB_PORT"/"$NEW_GRPCWEB_PORT"/" "$APP_FILE"
    echo "CHANGED_GRPCWEB_PORT: $NEW_GRPCWEB_PORT"
    else
        echo "GRPCWEB_PORT 변경 없음. 기존값 유지: $GRPCWEB_PORT"
    fi

    echo "########################################"
    
    # ROSETTA_PORT 수정
    echo "현재 ROSETTA 포트: $ROSETTA_PORT"
    echo "새 ROSETTA 포트를 입력하세요 (끝자리 07):"
    read NEW_ROSETTA_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_ROSETTA_PORT" ]; then
    sed -i "s/"$ROSETTA_PORT"/"$NEW_ROSETTA_PORT"/" "$APP_FILE"
    echo "CHANGED_ROSETTA_PORT: $NEW_ROSETTA_PORT"
    else
        echo "ROSETTA_PORT 변경 없음. 기존값 유지: $ROSETTA_PORT"
    fi

    echo "########################################"
   
    # PROMETHEUS_PORT 수정
    echo "현재 PROMETHEUS 포트: $PROMETHEUS_PORT"
    echo "새 PROMETHEUS 포트를 입력하세요 (끝자리 08):"
    read NEW_PROMETHEUS_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_PROMETHEUS_PORT" ]; then
    sed -i "s/"$PROMETHEUS_PORT"/"$NEW_PROMETHEUS_PORT"/" "$CONFIG_FILE"
    echo "CHANGED_PROMETHEUS_PORT: $NEW_PROMETHEUS_PORT"
    else
        echo "PROMETHEUS_PORT 변경 없음. 기존값 유지: $PROMETHEUS_PORT"
    fi

    echo "########################################"

    if [ -n "$SIGNER_PORT" ]; then
    echo "현재 SIGNER 포트: $SIGNER_PORT"
    echo "새 SIGNER 포트를 입력하세요 (끝자리 09):"
    read NEW_SIGNER_PORT

        if [ -n "$NEW_SIGNER_PORT" ]; then
        sed -i "s/"$SIGNER_PORT"/"$NEW_SIGNER_PORT"/" "$CONFIG_FILE"
        echo "CHANGED_SIGNER_PORT: $NEW_SIGNER_PORT"
        else
            echo "SIGNER_PORT 변경 없음. 기존값 유지: $SIGNER_PORT"
        fi  
    fi

    # ABCI_PORT 수정
    echo "현재 ABCI 포트: $ABCI_PORT"
    echo "새 ABCI 포트를 입력하세요 (끝자리 10):"
    read NEW_ABCI_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_ABCI_PORT" ]; then
    sed -i "s/"$ABCI_PORT"/"$NEW_ABCI_PORT"/" "$CONFIG_FILE"
    echo "CHANGED_RPC_PORT: $NEW_ABCI_PORT"
    else
        echo "ABCI_PORT 변경 없음. 기존값 유지: $ABCI_PORT"
    fi

    echo "########################################"

    # PPROF_PORT 수정
    echo "현재 PPROF 포트: $PPROF_PORT"
    echo "새 PPROF 포트를 입력하세요 (끝자리 11):"
    read NEW_PPROF_PORT

    # 입력된 포트로 교체 또는 기존값 유지
    if [ -n "$NEW_PPROF_PORT" ]; then
    sed -i "s/"$PPROF_PORT"/"$NEW_PPROF_PORT"/" "$CONFIG_FILE"
    echo "CHANGED_RPC_PORT: $NEW_PPROF_PORT"
    else
        echo "PPROF_PORT 변경 없음. 기존값 유지: $PPROF_PORT"
    fi

    echo "########################################"
    echo
    echo "포트 수정이 완료되었습니다."
    echo "########################################"
    echo "CHANGED_PORT :"
    echo "P2P" : $NEW_P2P_PORT
    echo "LCD" : $NEW_LCD_PORT
    echo "RPC" : $NEW_RPC_PORT
    echo "GRPC" : $NEW_GRPC_PORT
    echo "GRPCWEB" : $NEW_GRPCWEB_PORT
    echo "ROSETTA" : $NEW_ROSETTA_PORT
    echo "PROMETHEUS" : $NEW_PROMETHEUS_PORT
    echo "ABCI" : $NEW_ABCI_PORT
    echo "PPROF" : $NEW_PPROF_PORT
    echo "########################################"
else
    echo "포트 수정이 취소되었습니다."
fi