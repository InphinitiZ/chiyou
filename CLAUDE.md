# Chiyou 项目指南

## 项目概述

Chiyou 是一个个人工具集合网站，目标是把常用的在线工具自己实现一份。非盈利，纯兴趣项目。

## 用户背景

- Java 后端开发工程师，前端几乎零基础
- 前端代码主要由 Claude Code 生成，给方案时优先选简单、直观的方式
- 后端如果需要会用 Java（Spring Boot）

## 技术选型

- **前端**：Vue 3 + Vite，选 Vue 是因为模板语法对前端新手更友好
- **路由**：vue-router
- **语法高亮**：highlight.js（仅按需引入语言，不引入全量包）
- **Cron 解析**：croner（支持秒、年、L/W/# 等 Quartz 扩展语法）
- **部署**：VPS + Docker（多阶段构建：Node 编译 + Nginx 托管静态文件）+ 一键部署脚本 `deploy.sh`

## 设计风格

- 暗色主题，参考 json-generator.com 的整体风格
- 配色：深蓝黑背景，蓝色主色调，青色点缀色
- 代码编辑器风格的文本框（暗底亮字、monospace 字体）
- 左侧侧边栏导航 + 顶部标题栏 + 主内容区

## 项目结构

```
src/
├── main.js                        # 入口
├── App.vue                        # 根布局：侧边栏 + 顶部栏 + 内容区
├── router/index.js                # 路由配置
├── styles/global.css              # 全局样式和 CSS 变量
├── components/Sidebar.vue         # 侧边栏导航
└── tools/                         # 每个工具一个子目录
    ├── json-formatter/index.vue   # JSON 格式化工具
    ├── markdown-renderer/index.vue # Markdown 渲染工具
    └── cron-generator/index.vue   # Cron 表达式生成器
```

## 添加新工具（3 步）

1. 新建 `src/tools/<tool-name>/index.vue`
2. 在 `src/router/index.js` 加一条路由
3. 在 `src/components/Sidebar.vue` 的 tools 数组加一项
4. 在 `src/App.vue` 的 toolNames 对象加一条映射（顶部标题栏显示用）

## 已完成的工具

### JSON 格式化 / 压缩
- 输入支持 JSON 和 JSON5
- 三个核心操作：格式化 JSON、压缩 JSON、转 JSON5
- 输出始终使用语法高亮渲染（JSON 用 json 语言，JSON5 用 javascript 语言）
- 可选缩进：2 空格 / 4 空格 / Tab
- 输出框悬停显示复制按钮

### Markdown 渲染
- 左右双栏：左边 Markdown 输入，右边实时预览
- 中间有折叠按钮，可隐藏编辑区全屏预览
- 代码块功能丰富：语法高亮、行号、语言切换下拉（带搜索）、一键复制
- 使用 marked + marked-highlight + highlight.js（common 包）
- 代码块语言选择器是自定义下拉（非原生 select），支持搜索过滤
- 工具栏：清空、加载示例、复制 HTML

### Cron 表达式生成器
- 7 个 Tab：秒、分钟、小时、日、月、周、年（年可选，默认不指定）
- 每个 Tab 提供多种选择：每X、周期范围、递增、指定值等
- 日字段额外支持：L（最后一天）、LW（最后工作日）、W（最近工作日）
- 周字段额外支持：#（第N个星期X）、XL（最后一个星期X）
- 底部结果区：各字段值展示、可编辑表达式输入框、复制、反解析到UI、最近5次运行时间
- 使用 croner 库计算运行时间，内部通过 quartzToCroner() 函数将 Quartz 风格表达式转为 croner 兼容格式
- 使用 alternativeWeekdays: true 使周字段编号与 Quartz 一致（1=SUN...7=SAT）

## 部署

- `deploy.sh` 是一键部署脚本，在 VPS 上直接 `bash deploy.sh` 即可
- 自动检测系统（Ubuntu/Debian/CentOS/RHEL/Fedora/Alpine），安装 Git 和 Docker
- 交互式配置端口、域名、HTTPS（Let's Encrypt 自动申请或手动证书）
- 配置保存在 `/opt/chiyou/deploy/.deploy-config`，再次执行自动加载上次配置
- 动态生成 nginx.conf 挂载到容器内，项目自带的 `nginx.conf` 仅作为 Docker 构建时的默认配置

## 注意事项

- 不要引入复杂的前端框架或状态管理（目前不需要 Pinia/Vuex）
- 不要引入 CSS 框架，当前用纯 CSS + CSS 变量
- 保持依赖精简，每加一个依赖要有明确理由
- UI 文字用中文
