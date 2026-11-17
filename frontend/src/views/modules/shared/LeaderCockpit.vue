<template>
  <div class="page-card dept-page">
    <div class="dept-head">
      <div>
        <h2>领导数据驾驶舱</h2>
        <p>全公司 16 个部门的数据填报与审核情况总览。</p>
      </div>
      <div class="dept-tags">
        <el-tag effect="plain" type="danger">全公司</el-tag>
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
      <template #header>
        <span style="font-size: 14px">部门填报进度</span>
      </template>
      <el-table :data="rows" size="small" border>
        <el-table-column prop="dept" label="部门" min-width="180" />
        <el-table-column prop="submitted" label="本期提交" width="120" align="center" />
        <el-table-column prop="status" label="审核状态" width="120" align="center" />
        <el-table-column prop="rate" label="数据完整度" width="120" align="center" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
const kpis = [
  { label: '接入部门', value: '16' },
  { label: '本期提交', value: '-' },
  { label: '待审核', value: '-' },
  { label: '平均完整度', value: '-' }
]

const depts = [
  '财务部', '商务法务部', '市场部', '采购管理部', '安全生产监督管理部',
  '技术质量部', '工程管理部', '人力资源部', '项目技术支撑中心', '科创与产品部',
  '党建工作部', '办公室', '设计院', '经理部与事业部', '项目部'
]

const rows = depts.map((dept) => ({
  dept,
  submitted: '-',
  status: '待接入',
  rate: '-'
}))
</script>
