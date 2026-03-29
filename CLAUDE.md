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
- **部署**：VPS + Docker（多阶段构建：Node 编译 + Nginx 托管静态文件）

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
    └── json-formatter/index.vue   # JSON 格式化工具
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

## 注意事项

- 不要引入复杂的前端框架或状态管理（目前不需要 Pinia/Vuex）
- 不要引入 CSS 框架，当前用纯 CSS + CSS 变量
- 保持依赖精简，每加一个依赖要有明确理由
- UI 文字用中文
