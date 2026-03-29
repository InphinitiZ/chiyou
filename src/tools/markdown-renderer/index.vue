<template>
  <div class="markdown-renderer">
    <div class="toolbar">
      <div class="toolbar-group">
        <button class="btn-ghost" @click="clearAll">清空</button>
        <button class="btn-ghost" @click="loadExample">加载示例</button>
        <button class="btn-ghost" @click="copyHtml">{{ copyText }}</button>
      </div>
    </div>

    <div class="editor-area">
      <div v-show="!editorCollapsed" class="editor-pane">
        <div class="pane-header">
          <span class="pane-label">Markdown</span>
          <span class="pane-hint">{{ lineCount }} 行</span>
        </div>
        <textarea
          v-model="inputText"
          placeholder="在此输入 Markdown..."
          spellcheck="false"
        ></textarea>
      </div>
      <button class="collapse-btn" @click="editorCollapsed = !editorCollapsed" :title="editorCollapsed ? '展开编辑区' : '收起编辑区'">
        <span class="collapse-arrow" :class="{ collapsed: editorCollapsed }">&#9664;</span>
      </button>
      <div class="editor-pane">
        <div class="pane-header">
          <span class="pane-label">预览</span>
        </div>
        <div class="preview-wrapper" ref="previewRef" v-html="renderedHtml" @click="onPreviewClick"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { marked } from 'marked'
import { markedHighlight } from 'marked-highlight'
import hljs from 'highlight.js/lib/common'
import 'highlight.js/styles/atom-one-dark.css'

marked.use(
  markedHighlight({
    langPrefix: 'hljs language-',
    highlight(code, lang) {
      if (lang && hljs.getLanguage(lang)) {
        return hljs.highlight(code, { language: lang }).value
      }
      return hljs.highlightAuto(code).value
    },
  })
)

marked.setOptions({
  breaks: true,
  gfm: true,
})

const inputText = ref('')
const copyText = ref('复制 HTML')
const previewRef = ref(null)
const editorCollapsed = ref(false)

const languages = hljs.listLanguages().sort()
const langOptionsHtml = languages.map(l => `<div class="lang-option" data-lang="${l}">${l}</div>`).join('')

const lineCount = computed(() => {
  if (!inputText.value) return 0
  return inputText.value.split('\n').length
})

let codeBlockCounter = 0

const renderedHtml = computed(() => {
  if (!inputText.value.trim()) return ''
  codeBlockCounter = 0
  const html = marked(inputText.value)
  return html.replace(/<pre><code class="(.*?)">([\s\S]*?)<\/code><\/pre>/g, (_, cls, code) => {
    const langMatch = cls.match(/language-(\w+)/)
    const lang = langMatch ? langMatch[1] : 'plaintext'
    const blockId = codeBlockCounter++
    const lines = code.replace(/\n$/, '').split('\n')
    const wrapped = lines.map(line => `<span class="code-line">${line}</span>`).join('\n')
    return `<div class="code-block-wrapper" data-block-id="${blockId}">` +
      `<div class="code-block-header">` +
        `<div class="header-right">` +
          `<div class="lang-picker">` +
            `<button class="lang-picker-btn" data-block-id="${blockId}">${lang} <span class="arrow">&#9662;</span></button>` +
            `<div class="lang-dropdown" data-block-id="${blockId}">` +
              `<input class="lang-search" placeholder="搜索语言..." />` +
              `<div class="lang-list">${langOptionsHtml}</div>` +
            `</div>` +
          `</div>` +
          `<span class="header-divider"></span>` +
          `<button class="code-copy-btn" data-block-id="${blockId}" title="复制代码">` +
            `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>` +
          `</button>` +
        `</div>` +
      `</div>` +
      `<pre class="has-line-numbers" data-block-id="${blockId}"><code class="${cls}">${wrapped}</code></pre>` +
    `</div>`
  })
})

function rehighlight(pre, newLang) {
  const codeEl = pre.querySelector('code')
  const raw = codeEl.textContent
  const highlighted = (newLang && hljs.getLanguage(newLang))
    ? hljs.highlight(raw, { language: newLang }).value
    : hljs.highlightAuto(raw).value
  const lines = highlighted.replace(/\n$/, '').split('\n')
  codeEl.innerHTML = lines.map(line => `<span class="code-line">${line}</span>`).join('\n')
  codeEl.className = `hljs language-${newLang}`
}

function closeAllDropdowns() {
  if (!previewRef.value) return
  previewRef.value.querySelectorAll('.lang-dropdown.open').forEach(d => {
    d.classList.remove('open')
  })
}

function onPreviewClick(e) {
  // 复制按钮
  const copyBtn = e.target.closest('.code-copy-btn')
  if (copyBtn) {
    const blockId = copyBtn.dataset.blockId
    const pre = previewRef.value.querySelector(`pre[data-block-id="${blockId}"]`)
    if (pre) {
      const text = pre.querySelector('code').textContent
      navigator.clipboard.writeText(text).then(() => {
        copyBtn.textContent = '已复制!'
        setTimeout(() => { copyBtn.textContent = '复制' }, 1500)
      }).catch(() => {
        const ta = document.createElement('textarea')
        ta.value = text
        document.body.appendChild(ta)
        ta.select()
        document.execCommand('copy')
        document.body.removeChild(ta)
        copyBtn.textContent = '已复制!'
        setTimeout(() => { copyBtn.textContent = '复制' }, 1500)
      })
    }
    return
  }

  // 语言选择器按钮
  const pickerBtn = e.target.closest('.lang-picker-btn')
  if (pickerBtn) {
    const blockId = pickerBtn.dataset.blockId
    const dropdown = previewRef.value.querySelector(`.lang-dropdown[data-block-id="${blockId}"]`)
    const isOpen = dropdown.classList.contains('open')
    closeAllDropdowns()
    if (!isOpen) {
      dropdown.classList.add('open')
      const input = dropdown.querySelector('.lang-search')
      input.value = ''
      input.focus()
      // 重置过滤
      dropdown.querySelectorAll('.lang-option').forEach(o => { o.style.display = '' })
    }
    e.stopPropagation()
    return
  }

  // 搜索框 - 阻止冒泡关闭
  if (e.target.closest('.lang-search')) {
    e.stopPropagation()
    return
  }

  // 语言选项点击
  const langOption = e.target.closest('.lang-option')
  if (langOption) {
    const newLang = langOption.dataset.lang
    const dropdown = langOption.closest('.lang-dropdown')
    const blockId = dropdown.dataset.blockId
    const pre = previewRef.value.querySelector(`pre[data-block-id="${blockId}"]`)
    const btn = previewRef.value.querySelector(`.lang-picker-btn[data-block-id="${blockId}"]`)
    if (pre) {
      rehighlight(pre, newLang)
      btn.textContent = newLang
    }
    dropdown.classList.remove('open')
    return
  }

  // 点击其他区域关闭下拉
  closeAllDropdowns()
}

function onSearchInput(e) {
  if (!e.target.classList.contains('lang-search')) return
  const keyword = e.target.value.toLowerCase()
  const list = e.target.closest('.lang-dropdown').querySelector('.lang-list')
  list.querySelectorAll('.lang-option').forEach(o => {
    o.style.display = o.dataset.lang.includes(keyword) ? '' : 'none'
  })
}

// 全局点击关闭下拉
function onDocClick() { closeAllDropdowns() }

onMounted(() => {
  document.addEventListener('click', onDocClick)
  if (previewRef.value) {
    previewRef.value.addEventListener('input', onSearchInput)
  }
})

onUnmounted(() => {
  document.removeEventListener('click', onDocClick)
})

function clearAll() {
  inputText.value = ''
}

function loadExample() {
  inputText.value = `# 标题

## 二级标题

这是一段正文，支持 **加粗**、*斜体*、~~删除线~~ 和 \`行内代码\`。

### 列表

- 项目一
- 项目二
  - 子项目
- 项目三

### 有序列表

1. 第一步
2. 第二步
3. 第三步

### 代码块

\`\`\`javascript
function hello() {
  console.log('Hello, Chiyou!')
}
\`\`\`

### 表格

| 名称 | 类型 | 说明 |
|------|------|------|
| id | number | 唯一标识 |
| name | string | 用户名 |

### 引用

> 千里之行，始于足下。

### 链接与图片

[GitHub](https://github.com)

---

分隔线以上是全部示例。`
}

async function copyHtml() {
  if (!renderedHtml.value) return
  try {
    await navigator.clipboard.writeText(renderedHtml.value)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制 HTML' }, 1500)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = renderedHtml.value
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制 HTML' }, 1500)
  }
}
</script>

<style scoped>
.markdown-renderer {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.toolbar-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-ghost {
  background: transparent;
  color: var(--color-text-dim);
  border: 1px solid var(--color-border);
}

.btn-ghost:hover {
  color: var(--color-text);
  border-color: var(--color-text-dim);
  background: var(--color-surface-light);
}

.editor-area {
  display: flex;
  gap: 0;
  flex: 1;
  min-height: 0;
}

.collapse-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  min-width: 20px;
  background: var(--color-surface);
  border: 1px solid var(--color-editor-border);
  border-radius: 0;
  color: var(--color-text-dim);
  cursor: pointer;
  padding: 0;
  transition: all 0.15s;
  margin: 0 2px;
}

.collapse-btn:hover {
  background: var(--color-surface-light);
  color: var(--color-text);
}

.collapse-arrow {
  font-size: 10px;
  transition: transform 0.2s;
}

.collapse-arrow.collapsed {
  transform: rotate(180deg);
}

.editor-pane {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.pane-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  background: var(--color-surface);
  border: 1px solid var(--color-editor-border);
  border-bottom: none;
  border-radius: 4px 4px 0 0;
}

.pane-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-text);
  text-transform: uppercase;
  letter-spacing: 0.8px;
}

.pane-hint {
  font-size: 11px;
  color: var(--color-text-dim);
}

textarea {
  flex: 1;
  width: 100%;
  min-height: 300px;
  border-radius: 0 0 4px 4px;
  resize: none;
}

.preview-wrapper {
  flex: 1;
  min-height: 300px;
  border: 1px solid var(--color-editor-border);
  border-radius: 0 0 4px 4px;
  background: var(--color-editor-bg);
  padding: 20px 24px;
  overflow-y: auto;
  color: #c9d1d9;
  line-height: 1.7;
}

/* Markdown 渲染样式 */
.preview-wrapper :deep(h1) {
  font-size: 28px;
  font-weight: 700;
  margin: 0 0 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text);
}

.preview-wrapper :deep(h2) {
  font-size: 22px;
  font-weight: 600;
  margin: 24px 0 12px;
  padding-bottom: 6px;
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text);
}

.preview-wrapper :deep(h3) {
  font-size: 18px;
  font-weight: 600;
  margin: 20px 0 10px;
  color: var(--color-text);
}

.preview-wrapper :deep(h4),
.preview-wrapper :deep(h5),
.preview-wrapper :deep(h6) {
  font-size: 15px;
  font-weight: 600;
  margin: 16px 0 8px;
  color: var(--color-text);
}

.preview-wrapper :deep(p) {
  margin: 0 0 12px;
}

.preview-wrapper :deep(a) {
  color: var(--color-primary);
  text-decoration: none;
}

.preview-wrapper :deep(a:hover) {
  text-decoration: underline;
}

.preview-wrapper :deep(strong) {
  color: var(--color-text);
  font-weight: 600;
}

.preview-wrapper :deep(code) {
  background: rgba(110, 118, 129, 0.2);
  padding: 2px 6px;
  border-radius: 3px;
  font-family: "SF Mono", "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  color: #f0883e;
}

/* 代码块 */
.preview-wrapper :deep(.code-block-wrapper) {
  margin: 0 0 12px;
  border-radius: 8px;
  overflow: visible;
  position: relative;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.preview-wrapper :deep(.code-block-header) {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 8px 12px;
  background: #282c34;
  border-radius: 8px 8px 0 0;
  border-bottom: 1px solid #3a3f47;
}

.preview-wrapper :deep(.header-right) {
  display: flex;
  align-items: center;
  gap: 4px;
}

.preview-wrapper :deep(.header-divider) {
  width: 1px;
  height: 18px;
  background: #3a3f47;
  margin: 0 4px;
}

.preview-wrapper :deep(.code-copy-btn) {
  background: transparent;
  color: #636a76;
  border: none;
  border-radius: 4px;
  padding: 4px 6px;
  cursor: pointer;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-wrapper :deep(.code-copy-btn:hover) {
  color: #e2e8f0;
  background: rgba(255, 255, 255, 0.08);
}

/* 语言选择器 */
.preview-wrapper :deep(.lang-picker) {
  position: relative;
}

.preview-wrapper :deep(.lang-picker-btn) {
  background: transparent;
  color: #a0a8b6;
  border: none;
  padding: 4px 8px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  gap: 4px;
}

.preview-wrapper :deep(.lang-picker-btn:hover) {
  color: #e2e8f0;
  background: rgba(255, 255, 255, 0.08);
}

.preview-wrapper :deep(.lang-picker-btn .arrow) {
  font-size: 10px;
  color: #636a76;
}

.preview-wrapper :deep(.lang-dropdown) {
  display: none;
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 4px;
  width: 200px;
  background: #292d33;
  border: 1px solid #3a3f47;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
  z-index: 100;
  overflow: hidden;
}

.preview-wrapper :deep(.lang-dropdown.open) {
  display: block;
}

.preview-wrapper :deep(.lang-search) {
  width: 100%;
  padding: 10px 12px;
  background: #1e2228;
  border: none;
  border-bottom: 1px solid #3a3f47;
  color: #e2e8f0;
  font-size: 13px;
  outline: none;
  font-family: inherit;
}

.preview-wrapper :deep(.lang-search::placeholder) {
  color: #636a76;
}

.preview-wrapper :deep(.lang-list) {
  max-height: 220px;
  overflow-y: auto;
}

.preview-wrapper :deep(.lang-option) {
  padding: 7px 12px;
  font-size: 13px;
  color: #a0a8b6;
  cursor: pointer;
  transition: background 0.1s;
}

.preview-wrapper :deep(.lang-option:hover) {
  background: #363b44;
  color: #e2e8f0;
}

.preview-wrapper :deep(pre) {
  background: #1e2228;
  padding: 16px 14px;
  margin: 0;
  overflow-x: auto;
  border-radius: 0 0 8px 8px;
}

.preview-wrapper :deep(pre code) {
  background: none;
  padding: 0;
  color: #c9d1d9;
  font-size: 13px;
}

.preview-wrapper :deep(pre.has-line-numbers) {
  counter-reset: line;
  padding-left: 0;
}

.preview-wrapper :deep(pre.has-line-numbers code) {
  display: block;
}

.preview-wrapper :deep(.code-line) {
  display: inline-block;
  width: 100%;
  padding-left: 50px;
  position: relative;
}

.preview-wrapper :deep(.code-line::before) {
  counter-increment: line;
  content: counter(line);
  position: absolute;
  left: 0;
  width: 36px;
  text-align: right;
  color: #484f58;
  font-size: 12px;
  user-select: none;
  border-right: 1px solid var(--color-border);
  padding-right: 8px;
  margin-right: 12px;
}

.preview-wrapper :deep(blockquote) {
  margin: 0 0 12px;
  padding: 4px 16px;
  border-left: 3px solid var(--color-primary);
  color: var(--color-text-dim);
}

.preview-wrapper :deep(ul),
.preview-wrapper :deep(ol) {
  margin: 0 0 12px;
  padding-left: 24px;
}

.preview-wrapper :deep(li) {
  margin-bottom: 4px;
}

.preview-wrapper :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 0 0 12px;
}

.preview-wrapper :deep(th),
.preview-wrapper :deep(td) {
  border: 1px solid var(--color-border);
  padding: 8px 12px;
  text-align: left;
}

.preview-wrapper :deep(th) {
  background: var(--color-surface);
  font-weight: 600;
  color: var(--color-text);
}

.preview-wrapper :deep(hr) {
  border: none;
  border-top: 1px solid var(--color-border);
  margin: 20px 0;
}

.preview-wrapper :deep(del) {
  color: var(--color-text-dim);
}

.preview-wrapper :deep(img) {
  max-width: 100%;
  border-radius: 4px;
}
</style>
