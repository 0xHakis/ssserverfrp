# 使用Rust的Alpine镜像作为Shadowsocks Rust的构建基础
FROM rust:1.67.1-alpine3.17 AS shadowsocks-builder

# 设置目标架构为x86_64
ARG RUST_TARGET="x86_64-unknown-linux-musl"
ARG MUSL="x86_64-linux-musl"

# 安装必要的构建工具
RUN set -x \
    && apk add --no-cache build-base

# 设置工作目录
WORKDIR /root/shadowsocks-rust

# 添加Shadowsocks Rust源码
COPY shadowsocks-rust/ /root/shadowsocks-rust/

# 构建Shadowsocks Rust
RUN wget -qO- "https://musl.cc/$MUSL-cross.tgz" | tar -xzC /root/ \
    && PATH="/root/$MUSL-cross/bin:$PATH" \
    && CC=/root/$MUSL-cross/bin/$MUSL-gcc \
    && echo "CC=$CC" \
    && rustup override set stable \
    && rustup target add "$RUST_TARGET" \
    && RUSTFLAGS="-C linker=$CC" CC=$CC cargo build --target "$RUST_TARGET" --release \
    && mv target/$RUST_TARGET/release/ssserver /usr/local/bin/

# 使用Golang的Alpine镜像作为FRP的构建基础
FROM golang:1.21 AS frpc-builder

# 设置工作目录
WORKDIR /root/frp

# 确保整个frp文件夹都被复制
COPY frp/ /root/frp/

# 构建FRP
RUN cd /root/frp \
    && make frpc \
    && mv bin/frpc /usr/local/bin/

# 最终镜像
FROM alpine:3.17

# 安装运行时依赖
RUN apk add --no-cache bash

# 从shadowsocks-builder阶段复制ssserver
COPY --from=shadowsocks-builder /usr/local/bin/ssserver /usr/local/bin/

# 从frpc-builder阶段复制frpc
COPY --from=frpc-builder /usr/local/bin/frpc /usr/local/bin/

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 设置容器入口点
ENTRYPOINT ["/start.sh"]

