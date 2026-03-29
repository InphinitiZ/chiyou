<template>
  <aside class="sidebar">
    <div class="sidebar-brand">
      <span class="brand-icon">&#9876;</span>
      <span class="brand-text">Chiyou</span>
    </div>
    <div class="sidebar-section-label">工具</div>
    <nav>
      <router-link
        v-for="tool in tools"
        :key="tool.path"
        :to="tool.path"
        class="sidebar-item"
      >
        <span class="sidebar-icon">{{ tool.icon }}</span>
        <span>{{ tool.name }}</span>
      </router-link>
    </nav>
  </aside>
</template>

<script setup>
const tools = [
  { name: 'JSON 格式化', path: '/tools/json-formatter', icon: '{ }' },
  { name: 'Markdown 渲染', path: '/tools/markdown-renderer', icon: 'M' },
]
</script>

<style scoped>
.sidebar {
  width: 200px;
  min-width: 200px;
  background: var(--color-sidebar);
  display: flex;
  flex-direction: column;
  height: 100%;
  border-right: 1px solid var(--color-border);
}

.sidebar-brand {
  padding: 16px 16px 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px solid var(--color-border);
}

.brand-icon {
  font-size: 20px;
  color: var(--color-accent);
}

.brand-text {
  font-size: 18px;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: 1px;
}

.sidebar-section-label {
  padding: 16px 16px 8px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--color-text-dim);
  letter-spacing: 1.5px;
}

nav {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 0 8px;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 12px;
  border-radius: 4px;
  color: var(--color-sidebar-text);
  text-decoration: none;
  font-size: 13px;
  transition: all 0.15s;
}

.sidebar-item:hover {
  background: var(--color-sidebar-hover);
  color: var(--color-text);
}

.sidebar-item.router-link-active {
  background: var(--color-sidebar-active);
  color: #ffffff;
  font-weight: 500;
}

.sidebar-icon {
  font-size: 12px;
  width: 22px;
  text-align: center;
  font-weight: 700;
  font-family: "SF Mono", "Consolas", monospace;
}
</style>
