<template>
  <el-container class="layout">
    <el-aside width="220px" class="aside">
      <div class="logo">
        <span class="dot"></span>
        <span>硕果大数据测试服</span>
      </div>
      <el-scrollbar>
        <el-menu :default-active="activeMenu" router unique-opened class="menu">
          <template v-for="m in userStore.menus" :key="m.id">
            <el-sub-menu v-if="m.menuType === 'M' && m.children && m.children.length" :index="m.path">
              <template #title>
                <el-icon><component :is="m.icon || 'Menu'" /></el-icon>
                <span>{{ m.menuName }}</span>
              </template>
              <el-menu-item
                v-for="c in m.children"
                :key="c.id"
                :index="joinPath(m.path, c.path)"
              >
                {{ c.menuName }}
              </el-menu-item>
            </el-sub-menu>
            <el-menu-item v-else-if="m.menuType === 'C'" :index="joinPath('', m.path)">
              <el-icon><component :is="m.icon || 'Menu'" /></el-icon>
              <span>{{ m.menuName }}</span>
            </el-menu-item>
          </template>
        </el-menu>
      </el-scrollbar>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div class="crumb">{{ currentTitle }}</div>
        <div class="right">
          <el-tag size="small" type="info" effect="plain">{{ userStore.user.deptName || '未分配部门' }}</el-tag>
          <el-tag size="small" :type="userStore.isAdmin ? 'danger' : 'success'" effect="plain">
            {{ userStore.isAdmin ? '超级管理员' : (userStore.roles[0] || '无角色') }}
          </el-tag>
          <el-dropdown @command="onCommand">
            <span class="user">
              <el-icon><UserFilled /></el-icon>
              {{ userStore.user.nickname }}
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">当前账号：{{ userStore.user.username }}</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main class="main">
        <router-view v-slot="{ Component }">
          <keep-alive :max="6">
            <component :is="Component" :key="route.fullPath" />
          </keep-alive>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { joinPath } from '@/utils/path'
import { resetRouter } from '@/router'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => route.meta?.title || '首页')

const onCommand = async (cmd) => {
  if (cmd === 'logout') {
    await ElMessageBox.confirm('确认退出登录？', '提示', { type: 'warning' })
    await userStore.logout()
    resetRouter()
    ElMessage.success('已退出')
    // 硬跳转：清掉已注册的动态路由，避免换账号后残留上一个人的菜单
    window.location.href = '/login'
  }
}
</script>

<style scoped>
.layout {
  height: 100vh;
}
.aside {
  background: #1f2530;
  display: flex;
  flex-direction: column;
}
.logo {
  height: 56px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 18px;
  color: #fff;
  font-size: 15px;
  font-weight: 500;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4a86ff;
  display: inline-block;
}
.menu {
  border-right: none;
  background: transparent;
}
.menu :deep(.el-menu-item),
.menu :deep(.el-sub-menu__title) {
  color: #c6cbd4;
}
.menu :deep(.el-menu-item:hover),
.menu :deep(.el-sub-menu__title:hover) {
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
}
.menu :deep(.el-menu-item.is-active) {
  background: rgba(74, 134, 255, 0.16);
  color: #7aa6ff;
}
.menu :deep(.el-sub-menu .el-menu) {
  background: transparent;
}
.header {
  height: 56px;
  background: #fff;
  border-bottom: 1px solid #e8ebf0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}
.crumb {
  font-size: 15px;
  font-weight: 500;
}
.right {
  display: flex;
  align-items: center;
  gap: 10px;
}
.user {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  font-size: 13.5px;
  color: #2c313a;
}
.main {
  padding: 16px;
  background: #f5f7fa;
  overflow-y: auto;
}
</style>
