# Chiyou

个人工具集合网站。

## 已有工具

- **JSON 格式化 / 压缩** — 支持 JSON 与 JSON5 互转，语法高亮输出
- **Markdown 渲染** — 实时预览，代码块语法高亮 + 行号 + 语言切换 + 一键复制
- **Cron 表达式生成器** — 可视化生成 Cron 表达式，支持 L/W/# 等 Quartz 扩展语法，反解析，最近运行时间预览

## 技术栈

- Vue 3 + Vite
- highlight.js（语法高亮）
- marked + marked-highlight（Markdown 渲染）
- croner（Cron 表达式解析）
- Docker + Nginx（部署）

## 本地开发

```bash
npm install
npm run dev
```

## 一键部署（推荐）

在 VPS 上执行：

```bash
wget -O deploy.sh https://raw.githubusercontent.com/InphinitiZ/chiyou/main/deploy.sh && bash deploy.sh
```

脚本会自动完成：检测系统环境、安装 Git/Docker、交互式配置（端口/域名/HTTPS）、拉代码、构建部署。支持 Ubuntu/Debian、CentOS/RHEL/Fedora、Alpine。再次执行即可更新部署。

## 手动 Docker 部署

```bash
docker build -t chiyou .
docker run -d -p 80:80 --name chiyou --restart unless-stopped chiyou
```
