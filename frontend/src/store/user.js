import { defineStore } from 'pinia'
import { getInfo, login, logout } from '@/api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('rbac_token') || '',
    user: {},
    roles: [],
    perms: [],
    menus: []
  }),
  getters: {
    isLogin: (state) => !!state.token,
    isAdmin: (state) => state.user.admin === true,
    hasPerm: (state) => (perm) => {
      if (state.user.admin) return true
      return state.perms.includes('*:*:*') || state.perms.includes(perm)
    }
  },
  actions: {
    async login(form) {
      const res = await login(form)
      this.token = res.data.token
      localStorage.setItem('rbac_token', this.token)
      return res.data
    },
    async getInfo() {
      const res = await getInfo()
      this.user = res.data.user
      this.roles = res.data.roles
      this.perms = res.data.perms
      this.menus = res.data.menus
      return res.data
    },
    async logout() {
      try {
        await logout()
      } catch (e) {
        /* 忽略登出接口异常 */
      }
      this.reset()
    },
    reset() {
      this.token = ''
      this.user = {}
      this.roles = []
      this.perms = []
      this.menus = []
      localStorage.removeItem('rbac_token')
    }
  }
})
