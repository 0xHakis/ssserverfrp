#!/bin/bash

# 创建 FRP 配置文件
cat << EOF > /root/frpc-config.ini
[common]
server_addr = ${FRPC_SERVER}
server_port = ${FRPC_SERVER_PORT}
token = ${FRPC_TOKEN}

[test]
type = ${FRPC_TYPE}
local_ip = ${FRPC_LOCAL}
local_port = ${FRPC_LOCAL_PORT}
remote_port = ${FRPC_REMOTE_PORT}
EOF

# 启动 Shadowsocks server
/usr/local/bin/ssserver -s "${SSSERVER_ADDR}" -m "${SSSERVER_METHOD}" -k "${SSSERVER_PASSWD}" &

# 启动 FRP
/usr/local/bin/frpc -c /root/frpc-config.ini &

# 防止容器退出
wait

