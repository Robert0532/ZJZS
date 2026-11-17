<template>
  <svg class="pthumb" viewBox="0 0 240 110" preserveAspectRatio="none" aria-hidden="true">
    <defs>
      <linearGradient :id="gid" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stop-color="#4a86ff" stop-opacity="0.26" />
        <stop offset="100%" stop-color="#4a86ff" stop-opacity="0.02" />
      </linearGradient>
    </defs>
    <g stroke="#e1e8f4" stroke-width="1">
      <line v-for="y in [28, 54, 80]" :key="y" x1="12" :y1="y" x2="228" :y2="y" />
    </g>
    <polygon :points="area" :fill="`url(#${gid})`" />
    <polyline :points="line" fill="none" stroke="#4a86ff" stroke-width="2" stroke-linejoin="round" />
    <g fill="#b9cdf0">
      <rect v-for="(b, i) in bars" :key="i" :x="b.x" :y="b.y" :width="b.w" :height="b.h" rx="2" />
    </g>
  </svg>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  seed: { type: Number, default: 0 }
})

const gid = computed(() => `pthumb-grad-${props.seed}`)

// 固定种子的伪随机，保证同一次构建里每张缩略图形状稳定、刷新不跳动
const rnd = (i) => {
  const x = Math.sin((props.seed + 1) * 12.9898 + i * 78.233) * 43758.5453
  return x - Math.floor(x)
}

const points = computed(() =>
  Array.from({ length: 13 }, (_, i) => {
    const x = 12 + i * 18
    const y = 84 - Math.round(18 + rnd(i) * 50)
    return [Math.round(x), y]
  })
)

const line = computed(() => points.value.map((p) => p.join(',')).join(' '))
const area = computed(() => `12,98 ${line.value} 228,98`)

const bars = computed(() =>
  Array.from({ length: 5 }, (_, i) => {
    const h = Math.round(8 + rnd(i + 20) * 16)
    return { x: 26 + i * 44, y: 100 - h, w: 7, h }
  })
)
</script>

<style scoped>
.pthumb {
  display: block;
  width: 100%;
  height: 100%;
}
</style>
