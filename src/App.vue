<template>
  <div class="app-layout">
    <Sidebar />
    <div class="main-wrapper">
      <header class="top-header">
        <div class="header-title">{{ currentToolName }}</div>
      </header>
      <main class="main-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import Sidebar from './components/Sidebar.vue'

const route = useRoute()

const toolNames = {
  '/tools/json-formatter': 'JSON 格式化 / 压缩',
  '/tools/markdown-renderer': 'Markdown 渲染',
}

const currentToolName = computed(() => {
  return toolNames[route.path] || 'Chiyou'
})
</script>

<style scoped>
.app-layout {
  display: flex;
  height: 100%;
}

.main-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.top-header {
  background: var(--color-header);
  padding: 0 24px;
  height: 48px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid var(--color-border);
}

.header-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text);
  letter-spacing: 0.3px;
}

.main-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}
</style>
