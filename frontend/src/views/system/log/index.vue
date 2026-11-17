<template>
  <div class="page-card">
    <div class="search-bar">
      <el-input v-model="query.title" placeholder="模块名称" clearable style="width: 170px" @keyup.enter="load" />
      <el-input v-model="query.operName" placeholder="操作人" clearable style="width: 150px" @keyup.enter="load" />
      <el-select v-model="query.status" placeholder="状态" clearable style="width: 120px">
        <el-option label="成功" value="0" />
        <el-option label="失败" value="1" />
      </el-select>
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="reset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button v-perm="'system:log:remove'" type="danger" plain @click="onClean">清空日志</el-button>
      <span class="tip">由 AOP 自动记录，包含入参、返回、耗时、IP；写日志失败不影响业务</span>
    </div>

    <el-table v-loading="loading" :data="rows" border size="small">
      <el-table-column prop="id" label="ID" width="70" align="center" />
      <el-table-column prop="title" label="模块" width="150" />
      <el-table-column prop="businessType" label="类型" width="90" align="center" />
      <el-table-column prop="operName" label="操作人" width="100" />
      <el-table-column prop="deptName" label="部门" width="130" />
      <el-table-column prop="requestMethod" label="方法" width="80" align="center" />
      <el-table-column prop="operIp" label="IP" width="130" />
      <el-table-column label="耗时" width="90" align="center">
        <template #default="{ row }">{{ row.costTime }} ms</template>
      </el-table-column>
      <el-table-column label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-tag size="small" :type="row.status === '0' ? 'success' : 'danger'">
            {{ row.status === '0' ? '成功' : '失败' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="operTime" label="操作时间" width="165" />
      <el-table-column label="详情" width="80" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="showDetail(row)">查看</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pager">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @size-change="load"
        @current-change="load"
      />
    </div>

    <el-drawer v-model="detail.visible" title="日志详情" size="520px">
      <div class="kv"><span>接口</span><b>{{ detail.row.method }}</b></div>
      <div class="kv"><span>URL</span><b>{{ detail.row.operUrl }}</b></div>
      <div class="kv"><span>错误信息</span><b>{{ detail.row.errorMsg || '无' }}</b></div>
      <h4>请求参数</h4>
      <pre>{{ pretty(detail.row.operParam) }}</pre>
      <h4>返回结果</h4>
      <pre>{{ pretty(detail.row.jsonResult) }}</pre>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { pageLog, cleanLog } from '@/api/log'

const loading = ref(false)
const rows = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, title: '', operName: '', status: '' })
const detail = reactive({ visible: false, row: {} })

const load = async () => {
  loading.value = true
  try {
    const res = await pageLog(query)
    rows.value = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

const reset = () => {
  query.title = ''
  query.operName = ''
  query.status = ''
  query.pageNum = 1
  load()
}

const showDetail = (row) => {
  detail.row = row
  detail.visible = true
}

const pretty = (text) => {
  if (!text) return '无'
  try {
    return JSON.stringify(JSON.parse(text), null, 2)
  } catch (e) {
    return text
  }
}

const onClean = async () => {
  await ElMessageBox.confirm('将清空全部操作日志，确认？', '提示', { type: 'warning' })
  await cleanLog()
  ElMessage.success('已清空')
  load()
}

onMounted(load)
</script>

<style scoped>
.kv {
  display: flex;
  gap: 10px;
  font-size: 13px;
  padding: 6px 0;
  border-bottom: 1px dashed #eef0f4;
}
.kv span {
  width: 70px;
  color: #8b93a1;
  flex: none;
}
.kv b {
  font-weight: 400;
  word-break: break-all;
}
h4 {
  font-size: 13px;
  margin: 16px 0 6px;
}
pre {
  background: #f7f9fc;
  border: 1px solid #eef0f4;
  border-radius: 6px;
  padding: 10px;
  font-size: 12px;
  line-height: 1.6;
  max-height: 240px;
  overflow: auto;
  white-space: pre-wrap;
  word-break: break-all;
  margin: 0;
}
</style>
