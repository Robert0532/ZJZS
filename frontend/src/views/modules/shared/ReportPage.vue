<template>
  <div class="page-card dept-page">
    <div class="dept-head">
      <div>
        <h2>{{ deptName }} · 数据填报</h2>
        <p>按周期录入本部门业务数据，提交后自动汇总至「数据驾驶舱」。</p>
      </div>
      <div class="dept-tags">
        <el-tag effect="plain" type="info">{{ deptName }}</el-tag>
        <el-tag effect="plain" type="warning">待接入</el-tag>
      </div>
    </div>

    <el-alert
      class="dept-alert"
      type="info"
      :closable="false"
      show-icon
      title="本页为功能占位，表单尚未接入"
      description="指标项与表结构确认后开放录入。数据按 dept_id 归集，部门管理员的数据权限为本部门（data_scope=3），只能看到自己部门的数据。"
    />

    <div class="dept-kpi">
      <div v-for="item in kpis" :key="item.label" class="dept-kpi-item">
        <div class="k">{{ item.label }}</div>
        <div class="v">{{ item.value }}</div>
      </div>
    </div>

    <el-card shadow="never" class="dept-card">
      <el-empty :image-size="88" description="填报表单尚未接入，指标项确认后开放录入" />
    </el-card>
  </div>
</template>

<script setup>
defineProps({
  deptName: { type: String, required: true },
  moduleKey: { type: String, required: true }
})

const kpis = [
  { label: '本期应报', value: '-' },
  { label: '已提交', value: '-' },
  { label: '待审核', value: '-' },
  { label: '退回修改', value: '-' }
]
</script>
