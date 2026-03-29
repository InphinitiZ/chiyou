#!/bin/bash
set -e

# ============================================================
# Chiyou 一键部署脚本
# 用法: bash deploy.sh
# 支持: Ubuntu/Debian, CentOS/RHEL/Fedora, Alpine
# ============================================================

REPO_URL="https://github.com/InphinitiZ/chiyou.git"
INSTALL_DIR="/opt/chiyou"
DEPLOY_DIR="${INSTALL_DIR}/deploy"
CONFIG_FILE="${DEPLOY_DIR}/.deploy-config"

# --- 颜色输出 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step()  { echo -e "\n${CYAN}==>${NC} $1"; }

# --- 检查 root 权限 ---
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "请以 root 用户运行此脚本，或使用 sudo bash deploy.sh"
    fi
}

# --- 检测操作系统 ---
detect_os() {
    step "检测系统环境"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID}"
        OS_NAME="${PRETTY_NAME}"
    else
        error "无法识别操作系统（缺少 /etc/os-release）"
    fi

    case "${OS_ID}" in
        ubuntu|debian|linuxmint)
            PKG_MANAGER="apt"
            ;;
        centos|rhel|fedora|rocky|almalinux)
            if command -v dnf &>/dev/null; then
                PKG_MANAGER="dnf"
            else
                PKG_MANAGER="yum"
            fi
            ;;
        alpine)
            PKG_MANAGER="apk"
            ;;
        *)
            error "不支持的操作系统: ${OS_NAME} (${OS_ID})"
            ;;
    esac

    ARCH=$(uname -m)
    info "系统: ${OS_NAME}"
    info "架构: ${ARCH}"
    info "包管理器: ${PKG_MANAGER}"
}

# --- 安装软件包 ---
pkg_install() {
    case "${PKG_MANAGER}" in
        apt)
            apt-get update -qq
            apt-get install -y -qq "$@"
            ;;
        yum)
            yum install -y -q "$@"
            ;;
        dnf)
            dnf install -y -q "$@"
            ;;
        apk)
            apk add --quiet "$@"
            ;;
    esac
}

# --- 安装 Git ---
install_git() {
    if command -v git &>/dev/null; then
        info "Git 已安装: $(git --version)"
        return
    fi
    step "安装 Git"
    pkg_install git
    info "Git 安装完成: $(git --version)"
}

# --- 安装 Docker ---
install_docker() {
    if command -v docker &>/dev/null; then
        info "Docker 已安装: $(docker --version)"
        ensure_docker_running
        return
    fi

    step "安装 Docker"

    case "${PKG_MANAGER}" in
        apt)
            # 安装前置依赖
            pkg_install ca-certificates curl gnupg
            # 添加 Docker 官方 GPG key
            install -m 0755 -d /etc/apt/keyrings
            if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
                curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                chmod a+r /etc/apt/keyrings/docker.gpg
            fi
            # 添加 Docker 源
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" > /etc/apt/sources.list.d/docker.list
            apt-get update -qq
            apt-get install -y -qq docker-ce docker-ce-cli containerd.io
            ;;
        yum|dnf)
            pkg_install yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || true
            ${PKG_MANAGER} install -y docker-ce docker-ce-cli containerd.io
            ;;
        apk)
            apk add docker
            ;;
    esac

    ensure_docker_running
    info "Docker 安装完成: $(docker --version)"
}

ensure_docker_running() {
    # systemd 系统
    if command -v systemctl &>/dev/null; then
        systemctl start docker 2>/dev/null || true
        systemctl enable docker 2>/dev/null || true
    # OpenRC (Alpine)
    elif command -v rc-service &>/dev/null; then
        rc-service docker start 2>/dev/null || true
        rc-update add docker default 2>/dev/null || true
    fi

    # 验证 Docker 正在运行
    if ! docker info &>/dev/null; then
        error "Docker 未能正常启动，请手动检查"
    fi
}

# --- 读取上次配置（如有） ---
load_config() {
    HTTP_PORT="80"
    DOMAIN=""
    ENABLE_HTTPS="n"
    HTTPS_MODE=""
    CERT_PATH=""
    KEY_PATH=""

    if [ -f "${CONFIG_FILE}" ]; then
        source "${CONFIG_FILE}"
        info "已加载上次部署配置"
    fi
}

# --- 交互式询问配置 ---
ask_config() {
    step "部署配置"
    echo ""

    # 端口
    read -p "$(echo -e "${CYAN}HTTP 端口${NC} [${HTTP_PORT}]: ")" input
    HTTP_PORT="${input:-${HTTP_PORT}}"

    # 域名
    read -p "$(echo -e "${CYAN}域名${NC}（直接回车则用 IP 访问）[${DOMAIN}]: ")" input
    DOMAIN="${input:-${DOMAIN}}"

    # HTTPS
    ENABLE_HTTPS="n"
    HTTPS_MODE=""
    CERT_PATH=""
    KEY_PATH=""

    if [ -n "${DOMAIN}" ]; then
        read -p "$(echo -e "${CYAN}启用 HTTPS?${NC} (y/n) [n]: ")" input
        ENABLE_HTTPS="${input:-n}"

        if [ "${ENABLE_HTTPS}" = "y" ] || [ "${ENABLE_HTTPS}" = "Y" ]; then
            ENABLE_HTTPS="y"
            echo ""
            echo "  1) Let's Encrypt 自动申请（免费）"
            echo "  2) 手动提供证书文件"
            read -p "$(echo -e "${CYAN}HTTPS 方式${NC} [1]: ")" input
            HTTPS_MODE="${input:-1}"

            if [ "${HTTPS_MODE}" = "2" ]; then
                read -p "$(echo -e "${CYAN}证书文件路径${NC} (fullchain.pem): ")" CERT_PATH
                read -p "$(echo -e "${CYAN}私钥文件路径${NC} (privkey.pem): ")" KEY_PATH
                [ ! -f "${CERT_PATH}" ] && error "证书文件不存在: ${CERT_PATH}"
                [ ! -f "${KEY_PATH}" ] && error "私钥文件不存在: ${KEY_PATH}"
            fi
        fi
    fi

    echo ""
    info "配置确认:"
    info "  端口: ${HTTP_PORT}"
    info "  域名: ${DOMAIN:-（IP 访问）}"
    info "  HTTPS: ${ENABLE_HTTPS}"
    [ "${ENABLE_HTTPS}" = "y" ] && info "  HTTPS 方式: ${HTTPS_MODE}"
    echo ""
}

# --- 保存配置 ---
save_config() {
    mkdir -p "${DEPLOY_DIR}"
    cat > "${CONFIG_FILE}" <<EOF
HTTP_PORT="${HTTP_PORT}"
DOMAIN="${DOMAIN}"
ENABLE_HTTPS="${ENABLE_HTTPS}"
HTTPS_MODE="${HTTPS_MODE}"
CERT_PATH="${CERT_PATH}"
KEY_PATH="${KEY_PATH}"
EOF
}

# --- 克隆或更新代码 ---
fetch_code() {
    if [ -d "${INSTALL_DIR}/.git" ]; then
        step "更新代码"
        cd "${INSTALL_DIR}"
        git pull
    else
        step "克隆代码"
        # 如果目录存在但不是 git 仓库（比如只有 deploy 目录），先备份 deploy
        if [ -d "${INSTALL_DIR}" ]; then
            if [ -d "${DEPLOY_DIR}" ]; then
                cp -r "${DEPLOY_DIR}" /tmp/chiyou-deploy-backup
            fi
            rm -rf "${INSTALL_DIR}"
        fi
        git clone "${REPO_URL}" "${INSTALL_DIR}"
        # 恢复 deploy 目录
        if [ -d /tmp/chiyou-deploy-backup ]; then
            mv /tmp/chiyou-deploy-backup "${DEPLOY_DIR}"
        fi
    fi
    info "代码就绪: ${INSTALL_DIR}"
}

# --- 生成 nginx 配置 ---
generate_nginx_conf() {
    step "生成 Nginx 配置"
    mkdir -p "${DEPLOY_DIR}"

    local server_name="${DOMAIN:-_}"

    if [ "${ENABLE_HTTPS}" = "y" ]; then
        cat > "${DEPLOY_DIR}/nginx.conf" <<NGINX
server {
    listen 80;
    server_name ${server_name};

    location /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name ${server_name};

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
NGINX
    else
        cat > "${DEPLOY_DIR}/nginx.conf" <<NGINX
server {
    listen 80;
    server_name ${server_name};
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
NGINX
    fi

    info "Nginx 配置已生成"
}

# --- 准备 SSL 证书 ---
setup_ssl() {
    if [ "${ENABLE_HTTPS}" != "y" ]; then
        return
    fi

    mkdir -p "${DEPLOY_DIR}/ssl"

    if [ "${HTTPS_MODE}" = "2" ]; then
        # 手动证书
        step "复制 SSL 证书"
        cp "${CERT_PATH}" "${DEPLOY_DIR}/ssl/fullchain.pem"
        cp "${KEY_PATH}" "${DEPLOY_DIR}/ssl/privkey.pem"
        info "证书已复制到 ${DEPLOY_DIR}/ssl/"
    else
        # Let's Encrypt
        step "申请 Let's Encrypt 证书"

        # 安装 certbot
        if ! command -v certbot &>/dev/null; then
            info "安装 certbot..."
            case "${PKG_MANAGER}" in
                apt)  pkg_install certbot ;;
                yum|dnf) pkg_install certbot ;;
                apk)  pkg_install certbot ;;
            esac
        fi

        # 需要先以 HTTP 模式启动容器，以通过域名验证
        # 创建 webroot 目录
        mkdir -p "${INSTALL_DIR}/certbot-webroot/.well-known"

        # 先临时启动 HTTP 容器
        info "临时启动 HTTP 服务用于域名验证..."
        build_image
        docker rm -f chiyou 2>/dev/null || true
        docker run -d --name chiyou --restart no \
            -p 80:80 \
            -v "${DEPLOY_DIR}/nginx.conf:/etc/nginx/conf.d/default.conf" \
            -v "${INSTALL_DIR}/certbot-webroot:/usr/share/nginx/html/.well-known/acme-challenge" \
            chiyou

        # 申请证书
        certbot certonly --webroot \
            -w "${INSTALL_DIR}/certbot-webroot" \
            -d "${DOMAIN}" \
            --non-interactive \
            --agree-tos \
            --register-unsafely-without-email \
            || error "证书申请失败，请检查域名 DNS 是否已解析到本机 IP"

        # 停止临时容器
        docker rm -f chiyou 2>/dev/null || true

        # 复制证书
        cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" "${DEPLOY_DIR}/ssl/fullchain.pem"
        cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" "${DEPLOY_DIR}/ssl/privkey.pem"

        # 设置自动续期
        setup_certbot_renewal

        info "Let's Encrypt 证书申请成功"
    fi
}

# --- 设置 certbot 自动续期 ---
setup_certbot_renewal() {
    local cron_cmd="0 3 1,15 * * certbot renew --quiet && cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ${DEPLOY_DIR}/ssl/fullchain.pem && cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem ${DEPLOY_DIR}/ssl/privkey.pem && docker restart chiyou"

    # 避免重复添加
    ( crontab -l 2>/dev/null | grep -v "certbot renew.*chiyou"; echo "${cron_cmd}" ) | crontab -
    info "已添加 certbot 自动续期定时任务（每月 1 号和 15 号凌晨 3 点）"
}

# --- 构建 Docker 镜像 ---
build_image() {
    step "构建 Docker 镜像"
    docker build -t chiyou "${INSTALL_DIR}"
    info "镜像构建完成"
}

# --- 启动容器 ---
start_container() {
    step "启动容器"

    # 停止旧容器
    docker rm -f chiyou 2>/dev/null || true

    # 构建 docker run 参数
    local docker_args=(
        -d
        --name chiyou
        --restart unless-stopped
        -p "${HTTP_PORT}:80"
        -v "${DEPLOY_DIR}/nginx.conf:/etc/nginx/conf.d/default.conf"
    )

    if [ "${ENABLE_HTTPS}" = "y" ]; then
        docker_args+=(-p "443:443")
        docker_args+=(-v "${DEPLOY_DIR}/ssl:/etc/nginx/ssl:ro")
    fi

    docker run "${docker_args[@]}" chiyou

    # 等待容器启动
    sleep 2
    if docker ps --filter name=chiyou --format '{{.Status}}' | grep -q "Up"; then
        info "容器启动成功"
    else
        error "容器启动失败，查看日志: docker logs chiyou"
    fi
}

# --- 打印结果 ---
print_result() {
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "${ip}" ] && ip="<服务器IP>"

    local url
    if [ "${ENABLE_HTTPS}" = "y" ]; then
        url="https://${DOMAIN}"
    elif [ -n "${DOMAIN}" ]; then
        if [ "${HTTP_PORT}" = "80" ]; then
            url="http://${DOMAIN}"
        else
            url="http://${DOMAIN}:${HTTP_PORT}"
        fi
    else
        if [ "${HTTP_PORT}" = "80" ]; then
            url="http://${ip}"
        else
            url="http://${ip}:${HTTP_PORT}"
        fi
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Chiyou 部署完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "  访问地址: ${CYAN}${url}${NC}"
    echo ""
    echo -e "  常用命令:"
    echo -e "    查看日志:   ${YELLOW}docker logs -f chiyou${NC}"
    echo -e "    重启服务:   ${YELLOW}docker restart chiyou${NC}"
    echo -e "    停止服务:   ${YELLOW}docker stop chiyou${NC}"
    echo -e "    更新部署:   ${YELLOW}bash ${INSTALL_DIR}/deploy.sh${NC}"
    echo ""
}

# ============================================================
# 主流程
# ============================================================
main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      Chiyou 一键部署脚本            ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
    echo ""

    check_root
    detect_os
    install_git
    install_docker
    load_config
    ask_config
    save_config
    fetch_code
    generate_nginx_conf

    # HTTPS: 申请证书前先用 HTTP 配置做域名验证，申请完再切回 HTTPS 配置
    if [ "${ENABLE_HTTPS}" = "y" ]; then
        # 先生成 HTTP 配置用于 certbot webroot 验证
        local server_name="${DOMAIN:-_}"
        cat > "${DEPLOY_DIR}/nginx.conf" <<NGINX
server {
    listen 80;
    server_name ${server_name};
    root /usr/share/nginx/html;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX
        setup_ssl
        # 重新生成完整的 HTTPS 配置
        generate_nginx_conf
    fi

    build_image
    start_container
    print_result
}

main
