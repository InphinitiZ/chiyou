# Chiyou

个人工具集合网站。

## 已有工具

- **JSON 格式化 / 压缩** — 支持 JSON 与 JSON5 互转，语法高亮输出

## 技术栈

- Vue 3 + Vite
- highlight.js（语法高亮）
- Docker + Nginx（部署）

## 本地开发

```bash
npm install
npm run dev
```

## Docker 部署

```bash
docker build -t chiyou .
docker run -d -p 80:80 --name chiyou --restart unless-stopped chiyou
```
