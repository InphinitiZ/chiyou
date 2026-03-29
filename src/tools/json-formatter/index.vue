<template>
  <div class="json-formatter">
    <div class="toolbar">
      <div class="toolbar-group">
        <button class="btn-primary" @click="formatJson">格式化 JSON</button>
        <button class="btn-primary" @click="compressJson">压缩 JSON</button>
        <button class="btn-secondary" @click="toJson5">转 JSON5</button>
        <div class="divider"></div>
        <button class="btn-ghost" @click="clearAll">清空</button>
      </div>
      <div class="toolbar-group">
        <label class="indent-label">
          缩进
          <select v-model="indentOption">
            <option value="2">2 空格</option>
            <option value="4">4 空格</option>
            <option value="tab">Tab</option>
          </select>
        </label>
      </div>
    </div>

    <div class="editor-area">
      <div class="editor-pane">
        <div class="pane-header">
          <span class="pane-label">输入</span>
          <span class="pane-hint">支持 JSON / JSON5</span>
        </div>
        <textarea
          v-model="inputText"
          placeholder="在此粘贴 JSON 或 JSON5..."
          spellcheck="false"
        ></textarea>
      </div>
      <div class="editor-pane">
        <div class="pane-header">
          <span class="pane-label">结果</span>
          <span v-if="outputText" class="pane-hint">{{ outputLines }} 行</span>
        </div>
        <div class="output-wrapper">
          <button v-if="outputText" class="copy-btn" @click="copyResult">{{ copyText }}</button>
          <pre v-if="outputText" class="output-pre"><code v-html="highlightedOutput"></code></pre>
          <div v-else class="output-placeholder">格式化或压缩后的结果...</div>
        </div>
      </div>
    </div>

    <transition name="fade">
      <div v-if="errorMsg" class="error-bar">
        <span class="error-icon">!</span>
        {{ errorMsg }}
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import JSON5 from 'json5'
import hljs from 'highlight.js/lib/core'
import json from 'highlight.js/lib/languages/json'
import javascript from 'highlight.js/lib/languages/javascript'
import 'highlight.js/styles/atom-one-dark.css'

hljs.registerLanguage('json', json)
hljs.registerLanguage('javascript', javascript)

const inputText = ref('')
const outputText = ref('')
const outputLang = ref('json')
const errorMsg = ref('')
const indentOption = ref('2')
const copyText = ref('复制结果')

const outputLines = computed(() => {
  if (!outputText.value) return 0
  return outputText.value.split('\n').length
})

const highlightedOutput = computed(() => {
  if (!outputText.value) return ''
  return hljs.highlight(outputText.value, { language: outputLang.value }).value
})

function getIndent() {
  if (indentOption.value === 'tab') return '\t'
  return Number(indentOption.value)
}

function formatJson() {
  if (!inputText.value.trim()) {
    errorMsg.value = '请输入内容'
    return
  }
  try {
    const parsed = JSON5.parse(inputText.value)
    outputText.value = JSON.stringify(parsed, null, getIndent())
    outputLang.value = 'json'
    errorMsg.value = ''
  } catch (e) {
    errorMsg.value = '解析失败：' + e.message
  }
}

function compressJson() {
  if (!inputText.value.trim()) {
    errorMsg.value = '请输入内容'
    return
  }
  try {
    const parsed = JSON5.parse(inputText.value)
    outputText.value = JSON.stringify(parsed)
    outputLang.value = 'json'
    errorMsg.value = ''
  } catch (e) {
    errorMsg.value = '解析失败：' + e.message
  }
}

function toJson5() {
  if (!inputText.value.trim()) {
    errorMsg.value = '请输入内容'
    return
  }
  try {
    const parsed = JSON5.parse(inputText.value)
    outputText.value = JSON5.stringify(parsed, null, getIndent())
    outputLang.value = 'javascript'
    errorMsg.value = ''
  } catch (e) {
    errorMsg.value = '解析失败：' + e.message
  }
}

async function copyResult() {
  if (!outputText.value) return
  try {
    await navigator.clipboard.writeText(outputText.value)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制结果' }, 1500)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = outputText.value
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制结果' }, 1500)
  }
}

function clearAll() {
  inputText.value = ''
  outputText.value = ''
  errorMsg.value = ''
}
</script>

<style scoped>
.json-formatter {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.toolbar-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.divider {
  width: 1px;
  height: 20px;
  background: var(--color-border);
  margin: 0 4px;
}

.btn-primary {
  background: var(--color-primary);
  color: #fff;
}

.btn-primary:hover {
  background: var(--color-primary-hover);
  box-shadow: 0 0 12px rgba(59, 130, 246, 0.3);
}

.btn-accent {
  background: var(--color-accent);
  color: #0d1117;
  font-weight: 600;
}

.btn-accent:hover {
  background: #00e6e6;
  box-shadow: 0 0 12px rgba(0, 210, 211, 0.3);
}

.btn-secondary {
  background: var(--color-surface-light);
  color: var(--color-accent);
  border: 1px solid var(--color-accent);
}

.btn-secondary:hover {
  background: rgba(0, 210, 211, 0.1);
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

.indent-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--color-text-dim);
}

.editor-area {
  display: flex;
  gap: 12px;
  flex: 1;
  min-height: 0;
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
}

.output-wrapper {
  flex: 1;
  min-height: 300px;
  border: 1px solid var(--color-editor-border);
  border-radius: 0 0 4px 4px;
  background: var(--color-editor-bg);
  overflow: auto;
  position: relative;
}

.copy-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  padding: 4px 12px;
  font-size: 12px;
  background: var(--color-surface-light);
  color: var(--color-text-dim);
  border: 1px solid var(--color-border);
  border-radius: 4px;
  opacity: 0;
  transition: opacity 0.2s;
  z-index: 1;
}

.output-wrapper:hover .copy-btn {
  opacity: 1;
}

.copy-btn:hover {
  color: var(--color-text);
  border-color: var(--color-text-dim);
  background: var(--color-surface);
}

.output-pre {
  margin: 0;
  padding: 14px;
  font-family: "SF Mono", "Cascadia Code", "Fira Code", "Consolas", monospace;
  font-size: 13px;
  line-height: 1.6;
  background: transparent;
  white-space: pre;
  word-wrap: normal;
}

.output-pre :deep(.hljs) {
  background: transparent;
  padding: 0;
}

.output-placeholder {
  padding: 14px;
  color: #484f58;
  font-family: "SF Mono", "Cascadia Code", "Fira Code", "Consolas", monospace;
  font-size: 13px;
}

.error-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  padding: 10px 14px;
  background: rgba(255, 107, 107, 0.1);
  border: 1px solid rgba(255, 107, 107, 0.3);
  border-radius: 4px;
  color: var(--color-error);
  font-size: 13px;
}

.error-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--color-error);
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  flex-shrink: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
