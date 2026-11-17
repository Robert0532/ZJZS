import axios from 'axios'
import { ElMessage } from 'element-plus'

const service = axios.create({
  baseURL: '/api',
  timeout: 20000
})

service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('rbac_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

service.interceptors.response.use(
  (response) => {
    const res = response.data
    if (response.config.responseType === 'blob') {
      return res
    }
    if (res.code !== 200) {
      ElMessage({ message: res.msg || '请求失败', type: 'error' })
      return Promise.reject(new Error(res.msg || 'error'))
    }
    return res
  },
  (error) => {
    const status = error.response?.status
    const msg = error.response?.data?.msg
    if (status === 401) {
      localStorage.removeItem('rbac_token')
      ElMessage({ message: msg || '登录已失效', type: 'warning' })
      setTimeout(() => {
        window.location.href = '/login'
      }, 600)
    } else if (status === 403) {
      ElMessage({ message: msg || '没有操作权限', type: 'error' })
    } else {
      ElMessage({ message: msg || error.message || '网络异常', type: 'error' })
    }
    return Promise.reject(error)
  }
)

export default service
