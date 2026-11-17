<template>
  <div class="page-card">
    <div class="search-bar">
      <el-input v-model="keyword" placeholder="菜单名称" clearable style="width: 200px" @keyup.enter="load" />
      <el-button type="primary" @click="load">查询</el-button>
      <el-button @click="expandAll">展开/收起</el-button>
    </div>

    <div class="toolbar">
      <el-button v-perm="'system:menu:add'" type="primary" @click="openAdd(0)">新增顶级菜单</el-button>
      <span class="tip">菜单驱动前端路由：component 必须与 views 下的文件路径一致，perms 必须与后端 @RequiresPerm 一致</span>
    </div>

    <el-table
      v-loading="loading"
      :data="rows"
      row-key="id"
      border
      :default-expand-all="expanded"
      :tree-props="{ children: 'children' }"
    >
      <el-table-column prop="menuName" label="菜单名称" min-width="180" />
      <el-table-column label="类型" width="90" align="center">
        <template #default="{ row }">
          <el-tag size="small" :type="typeTag(row.menuType)">{{ typeText(row.menuType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="path" label="路由地址" width="140" />
      <el-table-column prop="component" label="组件路径" min-width="170" />
      <el-table-column prop="perms" label="权限标识" min-width="190" />
      <el-table-column prop="orderNum" label="排序" width="70" align="center" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'system:menu:add'" link type="primary" @click="openAdd(row.id)">新增下级</el-button>
          <el-button v-perm="'system:menu:edit'" link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button v-perm="'system:menu:remove'" link type="danger" @click="onDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑菜单' : '新增菜单'" width="600px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="上级菜单">
          <el-tree-select
            v-model="form.parentId"
            :data="parentOptions"
            :props="{ label: 'menuName', children: 'children' }"
            node-key="id"
            check-strictly
            :render-after-expand="false"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="菜单类型" prop="menuType">
          <el-radio-group v-model="form.menuType">
            <el-radio value="M">目录</el-radio>
            <el-radio value="C">菜单</el-radio>
            <el-radio value="F">按钮</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="菜单名称" prop="menuName">
          <el-input v-model="form.menuName" />
        </el-form-item>
        <el-form-item v-if="form.menuType !== 'F'" label="路由地址">
          <el-input v-model="form.path" placeholder="目录用 /system，菜单用 user" />
        </el-form-item>
        <el-form-item v-if="form.menuType === 'C'" label="组件路径">
          <el-input v-model="form.component" placeholder="system/user/index" />
        </el-form-item>
        <el-form-item v-if="form.menuType !== 'M'" label="权限标识">
          <el-input v-model="form.perms" placeholder="system:user:list" />
        </el-form-item>
        <el-form-item v-if="form.menuType !== 'F'" label="图标">
          <el-input v-model="form.icon" placeholder="Element Plus 图标名，如 User" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="0" />
        </el-form-item>
        <el-form-item v-if="form.menuType !== 'F'" label="显示状态">
          <el-radio-group v-model="form.visible">
            <el-radio value="0">显示</el-radio>
            <el-radio value="1">隐藏</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="菜单状态">
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
import { treeMenu, addMenu, updateMenu, delMenu } from '@/api/menu'

const loading = ref(false)
const saving = ref(false)
const rows = ref([])
const keyword = ref('')
const expanded = ref(false)
const formRef = ref()

const dialog = reactive({ visible: false, isEdit: false })
const emptyForm = () => ({
  id: null, parentId: 0, menuName: '', menuType: 'C', path: '', component: '',
  perms: '', icon: '', orderNum: 0, visible: '0', status: '0'
})
const form = reactive(emptyForm())
const rules = {
  menuName: [{ required: true, message: '请输入菜单名称', trigger: 'blur' }],
  menuType: [{ required: true, message: '请选择类型', trigger: 'change' }]
}

const typeText = (t) => ({ M: '目录', C: '菜单', F: '按钮' }[t] || t)
const typeTag = (t) => ({ M: 'warning', C: 'primary', F: 'info' }[t] || 'info')

const parentOptions = computed(() => [
  { id: 0, menuName: '顶级菜单', children: rows.value }
])

const load = async () => {
  loading.value = true
  try {
    const res = await treeMenu({ keyword: keyword.value })
    rows.value = res.data
  } finally {
    loading.value = false
  }
}

const expandAll = () => {
  expanded.value = !expanded.value
  load()
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
    if (dialog.isEdit) {
      await updateMenu(payload)
    } else {
      await addMenu(payload)
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } finally {
    saving.value = false
  }
}

const onDelete = async (row) => {
  await ElMessageBox.confirm(`确认删除「${row.menuName}」？`, '提示', { type: 'warning' })
  await delMenu(row.id)
  ElMessage.success('已删除')
  load()
}

onMounted(load)
</script>
