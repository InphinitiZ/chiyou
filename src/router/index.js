import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/tools/json-formatter',
  },
  {
    path: '/tools/json-formatter',
    component: () => import('../tools/json-formatter/index.vue'),
  },
  {
    path: '/tools/markdown-renderer',
    component: () => import('../tools/markdown-renderer/index.vue'),
  },
  {
    path: '/tools/cron-generator',
    component: () => import('../tools/cron-generator/index.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
