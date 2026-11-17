<template>
  <div class="page-card dept-page">
    <div class="dept-head">
      <div>
        <h2>{{ deptName }} · 数据驾驶舱</h2>
        <p>汇总本部门填报数据的趋势与结构，供部门负责人查看。</p>
      </div>
      <div class="dept-tags">
        <el-tag effect="plain" type="info">{{ deptName }}</el-tag>
        <el-tag effect="plain" type="warning">待接入</el-tag>
      </div>
    </div>

    <div class="dept-kpi">
      <div v-for="item in kpis" :key="item.label" class="dept-kpi-item">
        <div class="k">{{ item.label }}</div>
        <div class="v">{{ item.value }}</div>
      </div>
    </div>

    <el-card shadow="never" class="dept-card">
      <el-empty :image-size="88" description="数据接入后展示趋势图与指标结构" />
    </el-card>
  </div>
</template>

<script setup>
defineProps({
  deptName: { type: String, required: true },
  moduleKey: { type: String, required: true }
})

const kpis = [
  { label: '本期填报', value: '-' },
  { label: '审核通过', value: '-' },
  { label: '指标项', value: '-' },
  { label: '数据完整度', value: '-' }
]
</script>
