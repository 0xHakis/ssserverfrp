#!/bin/bash

# 定义端口变量
LOCAL_PORT=8848

# 生成随机的8位字符串
random_string=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')
tcp_name="tcp_$random_string"
udp_name="udp_$random_string"

# 创建 FRP 配置文件 (TOML 格式)
cat << EOF > /root/frpc-config.toml
[common]
server_addr = "${FRPC_SERVER}"
server_port = ${FRPC_SERVER_PORT}
token = "${FRPC_TOKEN}"

[${tcp_name}]
type = "tcp"
local_ip = "127.0.0.1"
local_port = ${LOCAL_PORT}
remote_port = ${FRPC_REMOTE_PORT}

[${udp_name}]
type = "udp"
local_ip = "127.0.0.1"
local_port = ${LOCAL_PORT}
remote_port = ${FRPC_REMOTE_PORT}
EOF

# 启动 Shadowsocks server
/usr/local/bin/ssserver -s "[::]:${LOCAL_PORT}" -m "${SSSERVER_METHOD}" -k "${SSSERVER_PASSWD}" &

# 启动 FRP
/usr/local/bin/frpc -c /root/frpc-config.toml &

# 防止容器退出
wait


