<template>
  <div class="page-card">
    <div class="search-bar">
      <el-input v-model="query.roleName" placeholder="角色名称 / 权限字符" clearable style="width: 220px" @keyup.enter="load" />
      <el-select v-model="query.status" placeholder="状态" clearable style="width: 120px">
        <el-option label="正常" value="0" />
        <el-option label="停用" value="1" />
      </el-select>
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="reset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button v-perm="'system:role:add'" type="primary" @click="openAdd">新增角色</el-button>
      <span class="tip">数据权限决定该角色能看到哪些部门的数据</span>
    </div>

    <el-table v-loading="loading" :data="rows" border>
      <el-table-column prop="id" label="ID" width="70" align="center" />
      <el-table-column prop="roleName" label="角色名称" min-width="140" />
      <el-table-column prop="roleKey" label="权限字符" width="150" />
      <el-table-column label="数据权限" width="150">
        <template #default="{ row }">
          <el-tag size="small" :type="scopeType(row.dataScope)">{{ scopeText(row.dataScope) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="备注" min-width="180" />
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'system:role:edit'" link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button v-perm="'system:role:edit'" link type="success" @click="openPerm(row)">分配权限</el-button>
          <el-button v-perm="'system:role:remove'" link type="danger" :disabled="row.id === 1" @click="onDelete(row)">删除</el-button>
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

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑角色' : '新增角色'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="form.roleName" />
        </el-form-item>
        <el-form-item label="权限字符" prop="roleKey">
          <el-input v-model="form.roleKey" placeholder="如 dev_lead" />
        </el-form-item>
        <el-form-item label="数据权限" prop="dataScope">
          <el-select v-model="form.dataScope" style="width: 100%">
            <el-option v-for="s in scopeOptions" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.dataScope === '2'" label="自定义部门">
          <el-tree
            ref="deptTreeRef"
            :data="deptTree"
            :props="{ label: 'deptName', children: 'children' }"
            node-key="id"
            show-checkbox
            check-strictly
            style="max-height: 200px; overflow: auto; width: 100%"
          />
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
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSubmit">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="permDialog.visible" title="分配菜单权限" width="520px">
      <div class="tip" style="margin-bottom: 10px">
        勾选后该角色才能看到对应菜单，按钮权限也在这里授予。
      </div>
      <el-tree
        ref="menuTreeRef"
        :data="menuTree"
        :props="{ label: 'menuName', children: 'children' }"
        node-key="id"
        show-checkbox
        default-expand-all
        style="max-height: 420px; overflow: auto"
      />
      <template #footer>
        <el-button @click="permDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="savePerm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageRole, getRole, addRole, updateRole, delRole,
  getRoleMenuIds, saveRoleMenus, getRoleDeptIds, saveRoleDepts
} from '@/api/role'
import { treeMenu } from '@/api/menu'
import { deptOptions } from '@/api/dept'

const loading = ref(false)
const saving = ref(false)
const rows = ref([])
const total = ref(0)
const menuTree = ref([])
const deptTree = ref([])
const formRef = ref()
const menuTreeRef = ref()
const deptTreeRef = ref()

const query = reactive({ pageNum: 1, pageSize: 10, roleName: '', status: '' })
const dialog = reactive({ visible: false, isEdit: false })
const permDialog = reactive({ visible: false, roleId: null })

const emptyForm = () => ({
  id: null, roleName: '', roleKey: '', dataScope: '1',
  orderNum: 0, status: '0', remark: ''
})
const form = reactive(emptyForm())
const rules = {
  roleName: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  roleKey: [{ required: true, message: '请输入权限字符', trigger: 'blur' }]
}

const scopeOptions = [
  { value: '1', label: '全部数据' },
  { value: '2', label: '自定义部门数据' },
  { value: '3', label: '本部门数据' },
  { value: '4', label: '本部门及以下数据' },
  { value: '5', label: '仅本人数据' }
]
const scopeText = (v) => scopeOptions.find((s) => s.value === v)?.label || '-'
const scopeType = (v) => ({ 1: 'danger', 2: 'warning', 3: 'primary', 4: 'success', 5: 'info' }[v] || 'info')

const load = async () => {
  loading.value = true
  try {
    const res = await pageRole(query)
    rows.value = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

const reset = () => {
  query.roleName = ''
  query.status = ''
  query.pageNum = 1
  load()
}

const openAdd = () => {
  Object.assign(form, emptyForm())
  dialog.isEdit = false
  dialog.visible = true
}

const openEdit = async (row) => {
  const res = await getRole(row.id)
  Object.assign(form, emptyForm(), res.data)
  dialog.isEdit = true
  dialog.visible = true
  if (res.data.dataScope === '2') {
    const deptRes = await getRoleDeptIds(row.id)
    await nextTick()
    deptTreeRef.value?.setCheckedKeys(deptRes.data || [])
  }
}

const onSubmit = async () => {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = { ...form }
    if (payload.dataScope === '2' && deptTreeRef.value) {
      payload.deptIds = deptTreeRef.value.getCheckedKeys()
    } else {
      payload.deptIds = []
    }
    delete payload.menuIds
    if (dialog.isEdit) {
      await updateRole(payload)
    } else {
      await addRole(payload)
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } finally {
    saving.value = false
  }
}

const openPerm = async (row) => {
  if (row.id === 1) {
    ElMessage.info('超级管理员默认拥有全部权限，无需配置')
    return
  }
  permDialog.roleId = row.id
  permDialog.visible = true
  const res = await getRoleMenuIds(row.id)
  await nextTick()
  menuTreeRef.value?.setCheckedKeys(res.data || [])
}

const savePerm = async () => {
  saving.value = true
  try {
    const checked = menuTreeRef.value.getCheckedKeys()
    const half = menuTreeRef.value.getHalfCheckedKeys()
    await saveRoleMenus(permDialog.roleId, [...checked, ...half])
    ElMessage.success('权限已保存，重新登录后该角色生效')
    permDialog.visible = false
  } finally {
    saving.value = false
  }
}

const onDelete = async (row) => {
  await ElMessageBox.confirm(`确认删除角色「${row.roleName}」？`, '提示', { type: 'warning' })
  await delRole(row.id)
  ElMessage.success('已删除')
  load()
}

onMounted(async () => {
  const [menuRes, deptRes] = await Promise.all([treeMenu(), deptOptions()])
  menuTree.value = menuRes.data
  deptTree.value = deptRes.data
  load()
})
</script>
