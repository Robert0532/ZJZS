<template>
  <div class="login-wrap">
    <div class="login-box">
      <div class="brand">
        <h1>硕果大数据测试服</h1>
        <p>统一身份认证与权限管理</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" size="large" @keyup.enter="submit">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="密码"
            show-password
            :prefix-icon="Lock"
          />
        </el-form-item>
        <el-button type="primary" class="submit" :loading="loading" @click="submit">登 录</el-button>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const formRef = ref()
const loading = ref(false)
const form = reactive({ username: 'admin', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const submit = async () => {
  await formRef.value.validate()
  loading.value = true
  try {
    await userStore.login(form)
    ElMessage.success('登录成功')
    const redirect = route.query.redirect ? decodeURIComponent(route.query.redirect) : '/'
    router.replace(redirect)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1f2530 0%, #2b3a55 100%);
}
.login-box {
  width: 400px;
  background: #fff;
  border-radius: 12px;
  padding: 34px 34px 26px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.22);
}
.brand h1 {
  margin: 0 0 6px;
  font-size: 21px;
  font-weight: 600;
}
.brand p {
  margin: 0 0 26px;
  font-size: 12.5px;
  color: #8b93a1;
}
.submit {
  width: 100%;
  margin-top: 4px;
}
</style>
