<template>
  <div class="page-card">
    <div class="search-bar">
      <el-input v-model="keyword" placeholder="部门名称" clearable style="width: 200px" @keyup.enter="load" />
      <el-button type="primary" @click="load">查询</el-button>
    </div>

    <div class="toolbar">
      <el-button v-perm="'system:dept:add'" type="primary" @click="openAdd(0)">新增顶级部门</el-button>
      <span class="tip">ancestors 字段维护完整层级链（如 0,1,5,），“本部门及以下”数据权限依赖它</span>
    </div>

    <el-table v-loading="loading" :data="rows" row-key="id" border :tree-props="{ children: 'children' }">
      <el-table-column prop="deptName" label="部门名称" min-width="200" />
      <el-table-column prop="leader" label="负责人" width="120" />
      <el-table-column prop="phone" label="联系电话" width="150" />
      <el-table-column prop="ancestors" label="层级链" width="130" />
      <el-table-column prop="orderNum" label="排序" width="80" align="center" />
      <el-table-column label="状态" width="90" align="center">
        <template #default="{ row }">
          <el-tag size="small" :type="row.status === '0' ? 'success' : 'info'">
            {{ row.status === '0' ? '正常' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'system:dept:add'" link type="primary" @click="openAdd(row.id)">新增下级</el-button>
          <el-button v-perm="'system:dept:edit'" link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button v-perm="'system:dept:remove'" link type="danger" @click="onDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑部门' : '新增部门'" width="500px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="上级部门">
          <el-tree-select
            v-model="form.parentId"
            :data="parentOptions"
            :props="{ label: 'deptName', children: 'children' }"
            node-key="id"
            check-strictly
            :render-after-expand="false"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="部门名称" prop="deptName">
          <el-input v-model="form.deptName" />
        </el-form-item>
        <el-form-item label="负责人">
          <el-input v-model="form.leader" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { treeDept, addDept, updateDept, delDept } from '@/api/dept'

const loading = ref(false)
const saving = ref(false)
const rows = ref([])
const keyword = ref('')
const formRef = ref()

const dialog = reactive({ visible: false, isEdit: false })
const emptyForm = () => ({
  id: null, parentId: 0, deptName: '', leader: '', phone: '', orderNum: 0, status: '0'
})
const form = reactive(emptyForm())
const rules = { deptName: [{ required: true, message: '请输入部门名称', trigger: 'blur' }] }

const parentOptions = computed(() => [{ id: 0, deptName: '顶级部门', children: rows.value }])

const load = async () => {
  loading.value = true
  try {
    const res = await treeDept({ keyword: keyword.value })
    rows.value = res.data
  } finally {
    loading.value = false
  }
}

const openAdd = (parentId) => {
  Object.assign(form, emptyForm(), { parentId })
  dialog.isEdit = false
  dialog.visible = true
}

const openEdit = (row) => {
  Object.assign(form, emptyForm(), JSON.parse(JSON.stringify(row)), { children: undefined })
  dialog.isEdit = true
  dialog.visible = true
}

const onSubmit = async () => {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = { ...form }
    delete payload.children
    delete payload.ancestors
    if (dialog.isEdit) {
      await updateDept(payload)
    } else {
      await addDept(payload)
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } finally {
    saving.value = false
  }
}

const onDelete = async (row) => {
  await ElMessageBox.confirm(`确认删除部门「${row.deptName}」？`, '提示', { type: 'warning' })
  await delDept(row.id)
  ElMessage.success('已删除')
  load()
}

onMounted(load)
</script>
