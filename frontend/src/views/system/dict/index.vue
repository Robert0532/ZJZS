<template>
  <div class="page-card">
    <el-row :gutter="14">
      <el-col :span="10">
        <div class="panel">
          <div class="panel-head">
            <span>字典类型</span>
            <el-button v-perm="'system:dict:add'" size="small" type="primary" @click="openTypeAdd">新增</el-button>
          </div>
          <el-input v-model="keyword" placeholder="字典名称 / 类型" clearable size="small" style="margin-bottom: 10px" @keyup.enter="loadTypes" />
          <el-table
            v-loading="typeLoading"
            :data="types"
            size="small"
            border
            highlight-current-row
            @current-change="onSelectType"
          >
            <el-table-column prop="dictName" label="名称" min-width="110" />
            <el-table-column prop="dictType" label="类型" min-width="140" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button v-perm="'system:dict:edit'" link type="primary" @click.stop="openTypeEdit(row)">改</el-button>
                <el-button v-perm="'system:dict:remove'" link type="danger" @click.stop="onTypeDelete(row)">删</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-col>

      <el-col :span="14">
        <div class="panel">
          <div class="panel-head">
            <span>字典数据 {{ currentType ? '· ' + currentType.dictName : '' }}</span>
            <el-button
              v-perm="'system:dict:add'"
              size="small"
              type="primary"
              :disabled="!currentType"
              @click="openDataAdd"
            >
              新增
            </el-button>
          </div>
          <el-empty v-if="!currentType" description="请先在左侧选择一个字典类型" :image-size="80" />
          <el-table v-else :data="datas" size="small" border>
            <el-table-column prop="dictLabel" label="标签" min-width="110" />
            <el-table-column prop="dictValue" label="键值" width="100" />
            <el-table-column prop="orderNum" label="排序" width="70" align="center" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button v-perm="'system:dict:edit'" link type="primary" @click="openDataEdit(row)">改</el-button>
                <el-button v-perm="'system:dict:remove'" link type="danger" @click="onDataDelete(row)">删</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-col>
    </el-row>

    <el-dialog v-model="typeDialog.visible" :title="typeDialog.isEdit ? '编辑字典类型' : '新增字典类型'" width="460px">
      <el-form ref="typeFormRef" :model="typeForm" :rules="typeRules" label-width="90px">
        <el-form-item label="字典名称" prop="dictName">
          <el-input v-model="typeForm.dictName" />
        </el-form-item>
        <el-form-item label="字典类型" prop="dictType">
          <el-input v-model="typeForm.dictType" placeholder="如 sys_user_sex" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="typeForm.remark" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onTypeSubmit">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="dataDialog.visible" :title="dataDialog.isEdit ? '编辑字典数据' : '新增字典数据'" width="460px">
      <el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="90px">
        <el-form-item label="字典标签" prop="dictLabel">
          <el-input v-model="dataForm.dictLabel" />
        </el-form-item>
        <el-form-item label="字典键值" prop="dictValue">
          <el-input v-model="dataForm.dictValue" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="dataForm.orderNum" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dataDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onDataSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageDictType, addDictType, updateDictType, delDictType,
  listDictData, addDictData, updateDictData, delDictData
} from '@/api/dict'

const keyword = ref('')
const types = ref([])
const datas = ref([])
const currentType = ref(null)
const typeLoading = ref(false)
const saving = ref(false)
const typeFormRef = ref()
const dataFormRef = ref()

const typeDialog = reactive({ visible: false, isEdit: false })
const dataDialog = reactive({ visible: false, isEdit: false })

const typeForm = reactive({ id: null, dictName: '', dictType: '', remark: '' })
const typeRules = {
  dictName: [{ required: true, message: '请输入字典名称', trigger: 'blur' }],
  dictType: [{ required: true, message: '请输入字典类型', trigger: 'blur' }]
}

const dataForm = reactive({ id: null, dictType: '', dictLabel: '', dictValue: '', orderNum: 0 })
const dataRules = {
  dictLabel: [{ required: true, message: '请输入标签', trigger: 'blur' }],
  dictValue: [{ required: true, message: '请输入键值', trigger: 'blur' }]
}

const loadTypes = async () => {
  typeLoading.value = true
  try {
    const res = await pageDictType({ pageNum: 1, pageSize: 100, keyword: keyword.value })
    types.value = res.data.records
  } finally {
    typeLoading.value = false
  }
}

const onSelectType = async (row) => {
  currentType.value = row
  if (!row) return
  const res = await listDictData(row.dictType)
  datas.value = res.data
}

const openTypeAdd = () => {
  Object.assign(typeForm, { id: null, dictName: '', dictType: '', remark: '' })
  typeDialog.isEdit = false
  typeDialog.visible = true
}

const openTypeEdit = (row) => {
  Object.assign(typeForm, row)
  typeDialog.isEdit = true
  typeDialog.visible = true
}

const onTypeSubmit = async () => {
  await typeFormRef.value.validate()
  saving.value = true
  try {
    if (typeDialog.isEdit) {
      await updateDictType(typeForm)
    } else {
      await addDictType(typeForm)
    }
    ElMessage.success('保存成功')
    typeDialog.visible = false
    loadTypes()
  } finally {
    saving.value = false
  }
}

const onTypeDelete = async (row) => {
  await ElMessageBox.confirm(`删除字典「${row.dictName}」会同时删除其数据项，确认？`, '提示', { type: 'warning' })
  await delDictType(row.id)
  ElMessage.success('已删除')
  if (currentType.value?.id === row.id) {
    currentType.value = null
    datas.value = []
  }
  loadTypes()
}

const openDataAdd = () => {
  Object.assign(dataForm, { id: null, dictType: currentType.value.dictType, dictLabel: '', dictValue: '', orderNum: 0 })
  dataDialog.isEdit = false
  dataDialog.visible = true
}

const openDataEdit = (row) => {
  Object.assign(dataForm, row)
  dataDialog.isEdit = true
  dataDialog.visible = true
}

const onDataSubmit = async () => {
  await dataFormRef.value.validate()
  saving.value = true
  try {
    if (dataDialog.isEdit) {
      await updateDictData(dataForm)
    } else {
      await addDictData(dataForm)
    }
    ElMessage.success('保存成功')
    dataDialog.visible = false
    onSelectType(currentType.value)
  } finally {
    saving.value = false
  }
}

const onDataDelete = async (row) => {
  await ElMessageBox.confirm(`确认删除「${row.dictLabel}」？`, '提示', { type: 'warning' })
  await delDictData(row.id)
  ElMessage.success('已删除')
  onSelectType(currentType.value)
}

onMounted(loadTypes)
</script>

<style scoped>
.panel {
  border: 1px solid #e8ebf0;
  border-radius: 8px;
  padding: 12px 14px 14px;
  min-height: 420px;
}
.panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13.5px;
  font-weight: 500;
  margin-bottom: 10px;
}
</style>
