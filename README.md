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

## Docker 部署

```bash
docker build -t chiyou .
docker run -d -p 80:80 --name chiyou --restart unless-stopped chiyou
```
