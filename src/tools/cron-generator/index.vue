<template>
  <div class="cron-generator">
    <!-- Tab 栏 -->
    <div class="tab-bar">
      <button
        v-for="(tab, i) in tabs"
        :key="tab.key"
        class="tab-btn"
        :class="{ active: activeTab === i }"
        @click="activeTab = i"
      >{{ tab.label }}</button>
    </div>

    <!-- Tab 内容 -->
    <div class="tab-content">
      <!-- 秒 -->
      <div v-show="activeTab === 0" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.second.type" value="every" />
          <span>每秒 <span class="hint">允许的通配符 [, - * /]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.second.type" value="range" />
          <span>周期从 <input type="number" class="num-input" v-model.number="fields.second.rangeStart" min="0" max="59" @focus="fields.second.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.second.rangeEnd" min="0" max="59" @focus="fields.second.type = 'range'" /> 秒</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.second.type" value="increment" />
          <span>从 <input type="number" class="num-input" v-model.number="fields.second.startFrom" min="0" max="59" @focus="fields.second.type = 'increment'" /> 秒开始，每 <input type="number" class="num-input" v-model.number="fields.second.increment" min="1" max="59" @focus="fields.second.type = 'increment'" /> 秒执行一次</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.second.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.second.type === 'specific'" class="checkbox-grid">
          <label v-for="n in 60" :key="n - 1" class="cb-item">
            <input type="checkbox" :value="n - 1" v-model="fields.second.specific" />
            <span>{{ String(n - 1).padStart(2, '0') }}</span>
          </label>
        </div>
      </div>

      <!-- 分钟 -->
      <div v-show="activeTab === 1" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.minute.type" value="every" />
          <span>每分钟 <span class="hint">允许的通配符 [, - * /]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.minute.type" value="range" />
          <span>周期从 <input type="number" class="num-input" v-model.number="fields.minute.rangeStart" min="0" max="59" @focus="fields.minute.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.minute.rangeEnd" min="0" max="59" @focus="fields.minute.type = 'range'" /> 分钟</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.minute.type" value="increment" />
          <span>从 <input type="number" class="num-input" v-model.number="fields.minute.startFrom" min="0" max="59" @focus="fields.minute.type = 'increment'" /> 分钟开始，每 <input type="number" class="num-input" v-model.number="fields.minute.increment" min="1" max="59" @focus="fields.minute.type = 'increment'" /> 分钟执行一次</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.minute.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.minute.type === 'specific'" class="checkbox-grid">
          <label v-for="n in 60" :key="n - 1" class="cb-item">
            <input type="checkbox" :value="n - 1" v-model="fields.minute.specific" />
            <span>{{ String(n - 1).padStart(2, '0') }}</span>
          </label>
        </div>
      </div>

      <!-- 小时 -->
      <div v-show="activeTab === 2" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.hour.type" value="every" />
          <span>每小时 <span class="hint">允许的通配符 [, - * /]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.hour.type" value="range" />
          <span>周期从 <input type="number" class="num-input" v-model.number="fields.hour.rangeStart" min="0" max="23" @focus="fields.hour.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.hour.rangeEnd" min="0" max="23" @focus="fields.hour.type = 'range'" /> 小时</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.hour.type" value="increment" />
          <span>从 <input type="number" class="num-input" v-model.number="fields.hour.startFrom" min="0" max="23" @focus="fields.hour.type = 'increment'" /> 小时开始，每 <input type="number" class="num-input" v-model.number="fields.hour.increment" min="1" max="23" @focus="fields.hour.type = 'increment'" /> 小时执行一次</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.hour.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.hour.type === 'specific'" class="checkbox-grid">
          <div class="cb-group-label">AM:</div>
          <div class="cb-group">
            <label v-for="n in 12" :key="n - 1" class="cb-item">
              <input type="checkbox" :value="n - 1" v-model="fields.hour.specific" />
              <span>{{ String(n - 1).padStart(2, '0') }}</span>
            </label>
          </div>
          <div class="cb-group-label">PM:</div>
          <div class="cb-group">
            <label v-for="n in 12" :key="n + 11" class="cb-item">
              <input type="checkbox" :value="n + 11" v-model="fields.hour.specific" />
              <span>{{ n + 11 }}</span>
            </label>
          </div>
        </div>
      </div>

      <!-- 日 -->
      <div v-show="activeTab === 3" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="every" />
          <span>每天 <span class="hint">允许的通配符 [, - * / L W]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="notSpecified" />
          <span>不指定</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="range" />
          <span>周期从 <input type="number" class="num-input" v-model.number="fields.day.rangeStart" min="1" max="31" @focus="fields.day.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.day.rangeEnd" min="1" max="31" @focus="fields.day.type = 'range'" /> 日</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="increment" />
          <span>从 <input type="number" class="num-input" v-model.number="fields.day.startFrom" min="1" max="31" @focus="fields.day.type = 'increment'" /> 日开始，每 <input type="number" class="num-input" v-model.number="fields.day.increment" min="1" max="31" @focus="fields.day.type = 'increment'" /> 天执行一次</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="nearestWeekday" />
          <span>每月 <input type="number" class="num-input" v-model.number="fields.day.nearestWeekday" min="1" max="31" @focus="fields.day.type = 'nearestWeekday'" /> 号最近的那个工作日</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="last" />
          <span>本月最后一天</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="lastWeekday" />
          <span>本月最后一个工作日</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.day.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.day.type === 'specific'" class="checkbox-grid">
          <label v-for="n in 31" :key="n" class="cb-item">
            <input type="checkbox" :value="n" v-model="fields.day.specific" />
            <span>{{ n }}</span>
          </label>
        </div>
      </div>

      <!-- 月 -->
      <div v-show="activeTab === 4" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.month.type" value="every" />
          <span>每月 <span class="hint">允许的通配符 [, - * /]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.month.type" value="range" />
          <span>周期从 <input type="number" class="num-input" v-model.number="fields.month.rangeStart" min="1" max="12" @focus="fields.month.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.month.rangeEnd" min="1" max="12" @focus="fields.month.type = 'range'" /> 月</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.month.type" value="increment" />
          <span>从 <input type="number" class="num-input" v-model.number="fields.month.startFrom" min="1" max="12" @focus="fields.month.type = 'increment'" /> 月开始，每 <input type="number" class="num-input" v-model.number="fields.month.increment" min="1" max="12" @focus="fields.month.type = 'increment'" /> 月执行一次</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.month.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.month.type === 'specific'" class="checkbox-grid">
          <label v-for="n in 12" :key="n" class="cb-item">
            <input type="checkbox" :value="n" v-model="fields.month.specific" />
            <span>{{ n }}月</span>
          </label>
        </div>
      </div>

      <!-- 周 -->
      <div v-show="activeTab === 5" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="every" />
          <span>每周 <span class="hint">允许的通配符 [, - * / L #]</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="notSpecified" />
          <span>不指定</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="range" />
          <span>周期 从星期 <input type="number" class="num-input" v-model.number="fields.week.rangeStart" min="1" max="7" @focus="fields.week.type = 'range'" /> - <input type="number" class="num-input" v-model.number="fields.week.rangeEnd" min="1" max="7" @focus="fields.week.type = 'range'" /></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="nthDay" />
          <span>第 <input type="number" class="num-input" v-model.number="fields.week.weekOfMonth" min="1" max="5" @focus="fields.week.type = 'nthDay'" /> 周 的星期 <input type="number" class="num-input" v-model.number="fields.week.dayOfWeek" min="1" max="7" @focus="fields.week.type = 'nthDay'" /></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="lastDay" />
          <span>本月最后一个星期 <input type="number" class="num-input" v-model.number="fields.week.lastDayOfWeek" min="1" max="7" @focus="fields.week.type = 'lastDay'" /></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.week.type" value="specific" />
          <span>指定</span>
        </label>
        <div v-if="fields.week.type === 'specific'" class="checkbox-grid">
          <label v-for="(name, i) in weekDays" :key="i" class="cb-item">
            <input type="checkbox" :value="i + 1" v-model="fields.week.specific" />
            <span>{{ name }}</span>
          </label>
        </div>
      </div>

      <!-- 年 -->
      <div v-show="activeTab === 6" class="field-options">
        <label class="radio-row">
          <input type="radio" v-model="fields.year.type" value="notSpecified" />
          <span>不指定 <span class="hint">允许的通配符 [, - * /] 非必填</span></span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.year.type" value="every" />
          <span>每年</span>
        </label>
        <label class="radio-row">
          <input type="radio" v-model="fields.year.type" value="range" />
          <span>周期从 <input type="number" class="num-input num-input-wide" v-model.number="fields.year.rangeStart" min="2024" max="2099" @focus="fields.year.type = 'range'" /> - <input type="number" class="num-input num-input-wide" v-model.number="fields.year.rangeEnd" min="2024" max="2099" @focus="fields.year.type = 'range'" /></span>
        </label>
      </div>

    </div>

    <!-- 表达式结果区 -->
    <div class="result-section">
      <div class="result-header">表达式</div>

      <!-- 各字段显示 -->
      <div class="field-display">
        <div class="field-cell" v-for="(tab, i) in tabs" :key="tab.key">
          <div class="field-cell-label">{{ tab.label }}</div>
          <div class="field-cell-value">{{ fieldValues[i] }}</div>
        </div>
      </div>

      <!-- Cron 表达式 -->
      <div class="expression-row">
        <div class="expression-label">Cron 表达式：</div>
        <input class="expression-input" v-model="manualExpression" @keyup.enter="reverseParse" />
        <button class="btn-primary" @click="copyExpression">{{ copyText }}</button>
        <button class="btn-accent" @click="reverseParse">反解析到UI</button>
      </div>

      <!-- 最近5次运行时间 -->
      <div class="next-runs">
        <div class="next-runs-label">最近 5 次运行时间：</div>
        <div v-if="nextRuns.length" class="run-list">
          <div v-for="(run, i) in nextRuns" :key="i" class="run-item">{{ run }}</div>
        </div>
        <div v-else class="run-item dim">暂无匹配的运行时间</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { Cron } from 'croner'

const tabs = [
  { key: 'second', label: '秒' },
  { key: 'minute', label: '分钟' },
  { key: 'hour', label: '小时' },
  { key: 'day', label: '日' },
  { key: 'month', label: '月' },
  { key: 'week', label: '周' },
  { key: 'year', label: '年' },
]

const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

const activeTab = ref(0)
const copyText = ref('复制')
const manualExpression = ref('')

const fields = reactive({
  second: { type: 'every', rangeStart: 1, rangeEnd: 2, startFrom: 0, increment: 1, specific: [] },
  minute: { type: 'every', rangeStart: 1, rangeEnd: 2, startFrom: 0, increment: 1, specific: [] },
  hour: { type: 'every', rangeStart: 0, rangeEnd: 2, startFrom: 0, increment: 1, specific: [] },
  day: { type: 'every', rangeStart: 1, rangeEnd: 2, startFrom: 1, increment: 1, nearestWeekday: 1, specific: [] },
  month: { type: 'every', rangeStart: 1, rangeEnd: 2, startFrom: 1, increment: 1, specific: [] },
  week: { type: 'notSpecified', rangeStart: 1, rangeEnd: 2, weekOfMonth: 1, dayOfWeek: 1, lastDayOfWeek: 1, specific: [] },
  year: { type: 'notSpecified', rangeStart: 2026, rangeEnd: 2027 },
})

function buildField(field, key) {
  const f = field
  switch (f.type) {
    case 'every': return '*'
    case 'notSpecified': return '?'
    case 'range': return `${f.rangeStart}-${f.rangeEnd}`
    case 'increment': return `${f.startFrom}/${f.increment}`
    case 'specific': {
      const sorted = [...f.specific].sort((a, b) => a - b)
      return sorted.length ? sorted.join(',') : '*'
    }
    case 'last': return 'L'
    case 'lastWeekday': return 'LW'
    case 'nearestWeekday': return `${f.nearestWeekday}W`
    case 'nthDay': return `${f.dayOfWeek}#${f.weekOfMonth}`
    case 'lastDay': return `${f.lastDayOfWeek}L`
    default: return '*'
  }
}

const fieldValues = computed(() => {
  const yearVal = fields.year.type === 'notSpecified' ? '' : buildField(fields.year, 'year')
  return [
    buildField(fields.second, 'second'),
    buildField(fields.minute, 'minute'),
    buildField(fields.hour, 'hour'),
    buildField(fields.day, 'day'),
    buildField(fields.month, 'month'),
    buildField(fields.week, 'week'),
    yearVal,
  ]
})

const cronExpression = computed(() => {
  const parts = fieldValues.value.slice(0, 6)
  const year = fieldValues.value[6]
  if (year) parts.push(year)
  return parts.join(' ')
})

// 同步到手动输入框
watch(cronExpression, (val) => {
  manualExpression.value = val
}, { immediate: true })

// 将 Quartz 风格表达式转为 croner 兼容格式
function quartzToCroner(quartzExpr) {
  const parts = quartzExpr.split(' ')
  const maxValues = [59, 59, 23, 31, 12, 7, 9999]
  const minValues = [0, 0, 0, 1, 1, 1, 1970]

  return parts.map((part, i) => {
    if (part === '?') return '*'
    // X/Y → */Y 或 X-max/Y
    if (/^\d+\/\d+$/.test(part)) {
      const [start, step] = part.split('/')
      if (Number(start) === minValues[i]) return `*/${step}`
      return `${start}-${maxValues[i]}/${step}`
    }
    // 周字段: XL → X#L
    if (i === 5 && /^\d+L$/.test(part)) {
      return part.slice(0, -1) + '#L'
    }
    return part
  }).join(' ')
}

// 计算最近5次运行时间
const nextRuns = computed(() => {
  try {
    const cronerExpr = quartzToCroner(cronExpression.value)
    const job = new Cron(cronerExpr, { alternativeWeekdays: true })
    return job.nextRuns(5).map(formatDate)
  } catch {
    return []
  }
})

function formatDate(d) {
  const pad = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function reverseParse() {
  const parts = manualExpression.value.trim().split(/\s+/)
  if (parts.length < 6 || parts.length > 7) return

  parseField(fields.second, parts[0], 0, 59)
  parseField(fields.minute, parts[1], 0, 59)
  parseField(fields.hour, parts[2], 0, 23)
  parseDayField(fields.day, parts[3])
  parseField(fields.month, parts[4], 1, 12)
  parseWeekField(fields.week, parts[5])

  if (parts.length === 7) {
    parseYearField(fields.year, parts[6])
  } else {
    fields.year.type = 'notSpecified'
  }
}

function parseField(field, value, min, max) {
  field.specific = []
  if (value === '*') { field.type = 'every'; return }
  if (value === '?') { field.type = 'notSpecified'; return }
  if (value.includes('/')) {
    const [start, inc] = value.split('/')
    field.type = 'increment'
    field.startFrom = Number(start) || 0
    field.increment = Number(inc) || 1
    return
  }
  if (value.includes('-') && !value.includes(',')) {
    const [s, e] = value.split('-')
    field.type = 'range'
    field.rangeStart = Number(s)
    field.rangeEnd = Number(e)
    return
  }
  if (value.includes(',') || !isNaN(value)) {
    field.type = 'specific'
    field.specific = value.split(',').map(Number)
    return
  }
  field.type = 'every'
}

function parseDayField(field, value) {
  field.specific = []
  if (value === '*') { field.type = 'every'; return }
  if (value === '?') { field.type = 'notSpecified'; return }
  if (value === 'L') { field.type = 'last'; return }
  if (value === 'LW') { field.type = 'lastWeekday'; return }
  if (value.endsWith('W')) { field.type = 'nearestWeekday'; field.nearestWeekday = Number(value.slice(0, -1)); return }
  parseField(field, value, 1, 31)
}

function parseWeekField(field, value) {
  field.specific = []
  if (value === '*') { field.type = 'every'; return }
  if (value === '?') { field.type = 'notSpecified'; return }
  if (value.includes('#')) {
    const [dow, wom] = value.split('#')
    field.type = 'nthDay'
    field.dayOfWeek = Number(dow)
    field.weekOfMonth = Number(wom)
    return
  }
  if (value.endsWith('L')) { field.type = 'lastDay'; field.lastDayOfWeek = Number(value.slice(0, -1)); return }
  parseField(field, value, 1, 7)
}

function parseYearField(field, value) {
  if (value === '*') { field.type = 'every'; return }
  if (value.includes('-') && !value.includes(',')) {
    const [s, e] = value.split('-')
    field.type = 'range'
    field.rangeStart = Number(s)
    field.rangeEnd = Number(e)
    return
  }
  field.type = 'every'
}

async function copyExpression() {
  try {
    await navigator.clipboard.writeText(cronExpression.value)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制' }, 1500)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = cronExpression.value
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    copyText.value = '已复制!'
    setTimeout(() => { copyText.value = '复制' }, 1500)
  }
}
</script>

<style scoped>
.cron-generator {
  display: flex;
  flex-direction: column;
  height: 100%;
  gap: 0;
}

/* Tab 栏 */
.tab-bar {
  display: flex;
  gap: 2px;
  border-bottom: 1px solid var(--color-border);
  margin-bottom: 0;
}

.tab-btn {
  padding: 10px 20px;
  background: transparent;
  color: var(--color-text-dim);
  border: 1px solid transparent;
  border-bottom: none;
  border-radius: 6px 6px 0 0;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.15s;
  margin-bottom: -1px;
}

.tab-btn:hover {
  color: var(--color-text);
  background: var(--color-surface-light);
}

.tab-btn.active {
  color: var(--color-accent);
  background: var(--color-surface);
  border-color: var(--color-border);
  border-bottom: 1px solid var(--color-surface);
}

/* Tab 内容 */
.tab-content {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-top: none;
  border-radius: 0 0 6px 6px;
  padding: 20px;
  min-height: 250px;
}

.field-options {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.radio-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--color-text);
  cursor: pointer;
}

.radio-row input[type="radio"] {
  accent-color: var(--color-accent);
  width: 16px;
  height: 16px;
  cursor: pointer;
}

.radio-row span {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.hint {
  color: var(--color-text-dim);
  font-size: 12px;
}

.num-input {
  width: 60px;
  padding: 4px 8px;
  background: var(--color-editor-bg);
  border: 1px solid var(--color-border);
  border-radius: 4px;
  color: var(--color-text);
  font-size: 13px;
  text-align: center;
  outline: none;
}

.num-input:focus {
  border-color: var(--color-accent);
}

.num-input-wide {
  width: 80px;
}

/* 复选框网格 */
.checkbox-grid {
  padding-left: 24px;
  padding-top: 4px;
}

.cb-group-label {
  color: var(--color-text-dim);
  font-size: 12px;
  font-weight: 600;
  margin: 8px 0 4px;
}

.cb-group-label:first-child {
  margin-top: 0;
}

.cb-group {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.cb-item {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  padding: 3px 6px;
  border-radius: 3px;
  font-size: 13px;
  color: var(--color-text-dim);
  cursor: pointer;
  transition: background 0.1s;
  min-width: 52px;
}

.cb-item:hover {
  background: var(--color-surface-light);
  color: var(--color-text);
}

.cb-item input[type="checkbox"] {
  accent-color: var(--color-accent);
  cursor: pointer;
}

/* 结果区 */
.result-section {
  margin-top: 20px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 16px 20px;
}

.result-header {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 14px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-border);
}

.field-display {
  display: flex;
  gap: 8px;
  margin-bottom: 14px;
}

.field-cell {
  flex: 1;
  text-align: center;
}

.field-cell-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--color-text-dim);
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.field-cell-value {
  padding: 6px 8px;
  background: var(--color-editor-bg);
  border: 1px solid var(--color-editor-border);
  border-radius: 4px;
  color: var(--color-accent);
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 13px;
  font-weight: 600;
  min-height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.expression-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 14px;
}

.expression-label {
  font-size: 13px;
  color: var(--color-text-dim);
  white-space: nowrap;
}

.expression-input {
  flex: 1;
  padding: 8px 12px;
  background: var(--color-editor-bg);
  border: 1px solid var(--color-editor-border);
  border-radius: 4px;
  color: var(--color-text);
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 14px;
  font-weight: 600;
  outline: none;
}

.expression-input:focus {
  border-color: var(--color-accent);
}

.btn-primary {
  background: var(--color-primary);
  color: #fff;
  white-space: nowrap;
}

.btn-primary:hover {
  background: var(--color-primary-hover);
}

.btn-accent {
  background: var(--color-accent);
  color: #0d1117;
  font-weight: 600;
  white-space: nowrap;
}

.btn-accent:hover {
  background: #00e6e6;
}

.next-runs {
  margin-top: 2px;
}

.next-runs-label {
  font-size: 13px;
  color: var(--color-text-dim);
  margin-bottom: 8px;
}

.run-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.run-item {
  font-family: "SF Mono", "Consolas", monospace;
  font-size: 13px;
  color: var(--color-text);
  padding: 4px 12px;
  background: var(--color-editor-bg);
  border-radius: 3px;
  display: inline-block;
}

.run-item.dim {
  color: var(--color-text-dim);
  background: none;
}
</style>
