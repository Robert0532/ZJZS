<template>
  <div class="page-card">
    <div class="search-bar">
      <el-input v-model="query.username" placeholder="用户名 / 昵称" clearable style="width: 180px" @keyup.enter="load" />
      <el-tree-select
        v-model="query.deptId"
        :data="deptTree"
        :props="{ label: 'deptName', children: 'children' }"
        node-key="id"
        check-strictly
        clearable
        placeholder="所属部门"
        style="width: 190px"
      />
      <el-select v-model="query.status" placeholder="状态" clearable style="width: 120px">
        <el-option label="正常" value="0" />
        <el-option label="停用" value="1" />
      </el-select>
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="reset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button v-perm="'system:user:add'" type="primary" @click="openAdd">新增用户</el-button>
      <el-button v-perm="'system:user:export'" @click="onExport">导出 CSV</el-button>
      <span class="tip">共 {{ total }} 条 · 列表已按当前用户的数据权限过滤</span>
    </div>

    <el-table v-loading="loading" :data="rows" border size="default">
      <el-table-column prop="id" label="ID" width="70" align="center" />
      <el-table-column prop="username" label="用户名" width="130" />
      <el-table-column prop="nickname" label="昵称" min-width="140" />
      <el-table-column prop="deptName" label="部门" width="150" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column label="状态" width="100" align="center">
        <template #default="{ row }">
          <el-switch
            :model-value="row.status === '0'"
            :disabled="row.isAdmin === '1'"
            @change="(v) => toggleStatus(row, v)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="165" />
      <el-table-column label="操作" width="230" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'system:user:edit'" link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button v-perm="'system:user:resetPwd'" link type="warning" @click="onResetPwd(row)">重置密码</el-button>
          <el-button v-perm="'system:user:remove'" link type="danger" @click="onDelete(row)">删除</el-button>
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

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑用户' : '新增用户'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" :disabled="dialog.isEdit && form.isAdmin === '1'" />
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" />
        </el-form-item>
        <el-form-item v-if="!dialog.isEdit" label="初始密码">
          <el-input v-model="form.password" placeholder="留空则默认 123456" />
        </el-form-item>
        <el-form-item label="所属部门" prop="deptId">
          <el-tree-select
            v-model="form.deptId"
            :data="deptTree"
            :props="{ label: 'deptName', children: 'children' }"
            node-key="id"
            check-strictly
            :render-after-expand="false"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="form.sex">
            <el-radio value="1">男</el-radio>
            <el-radio value="2">女</el-radio>
            <el-radio value="0">未知</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.roleIds" multiple style="width: 100%" placeholder="可分配多个角色">
            <el-option v-for="r in roles" :key="r.id" :label="r.roleName" :value="r.id" />
          </el-select>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageUser, getUser, addUser, updateUser, delUser, resetUserPwd, changeUserStatus, exportUser
} from '@/api/user'
import { deptOptions } from '@/api/dept'
import { listRole } from '@/api/role'

const loading = ref(false)
const saving = ref(false)
const rows = ref([])
const total = ref(0)
const deptTree = ref([])
const roles = ref([])
const formRef = ref()

const query = reactive({ pageNum: 1, pageSize: 10, username: '', status: '', deptId: null })
const dialog = reactive({ visible: false, isEdit: false })
const emptyForm = () => ({
  id: null, username: '', nickname: '', password: '', deptId: null,
  phone: '', email: '', sex: '1', status: '0', roleIds: [], isAdmin: '0'
})
const form = reactive(emptyForm())
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  deptId: [{ required: true, message: '请选择部门', trigger: 'change' }]
}

const load = async () => {
  loading.value = true
  try {
    const res = await pageUser(query)
    rows.value = res.data.records
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

const reset = () => {
  query.username = ''
  query.status = ''
  query.deptId = null
  query.pageNum = 1
  load()
}

const assign = (target, source) => {
  Object.keys(target).forEach((k) => { target[k] = source[k] })
}

const openAdd = () => {
  assign(form, emptyForm())
  dialog.isEdit = false
  dialog.visible = true
}

const openEdit = async (row) => {
  const res = await getUser(row.id)
  assign(form, { ...emptyForm(), ...res.data, password: '' })
  dialog.isEdit = true
  dialog.visible = true
}

const onSubmit = async () => {
  await formRef.value.validate()
  saving.value = true
  try {
    if (dialog.isEdit) {
      await updateUser(form)
    } else {
      await addUser(form)
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } finally {
    saving.value = false
  }
}

const onDelete = async (row) => {
  await ElMessageBox.confirm(`确认删除用户「${row.nickname}」？`, '提示', { type: 'warning' })
  await delUser(row.id)
  ElMessage.success('已删除')
  load()
}

const onResetPwd = async (row) => {
  const { value } = await ElMessageBox.prompt('请输入新密码（不少于 6 位）', '重置密码', {
    inputValue: '123456',
    inputPattern: /^.{6,}$/,
    inputErrorMessage: '密码不少于 6 位'
  })
  await resetUserPwd(row.id, value)
  ElMessage.success('密码已重置')
}

const toggleStatus = async (row, checked) => {
  const status = checked ? '0' : '1'
  await changeUserStatus(row.id, status)
  row.status = status
  ElMessage.success('状态已更新')
}

const onExport = async () => {
  const blob = await exportUser({ username: query.username, status: query.status })
  const url = window.URL.createObjectURL(new Blob([blob]))
  const link = document.createElement('a')
  link.href = url
  link.download = 'users.csv'
  link.click()
  window.URL.revokeObjectURL(url)
}

onMounted(async () => {
  const [deptRes, roleRes] = await Promise.all([deptOptions(), listRole()])
  deptTree.value = deptRes.data
  roles.value = roleRes.data
  load()
})
</script>
