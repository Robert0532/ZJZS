<template>
  <el-container class="layout">
    <el-aside :width="asideWidth + 'px'" class="aside">
      <div class="logo">
        <span class="dot"></span>
        <span class="logo-text">硕果大数据测试服</span>
      </div>
      <el-scrollbar>
        <el-menu :default-active="activeMenu" router unique-opened class="menu">
          <template v-for="m in userStore.menus" :key="m.id">
            <el-sub-menu v-if="m.menuType === 'M' && m.children && m.children.length" :index="m.path">
              <template #title>
                <el-icon><component :is="m.icon || 'Menu'" /></el-icon>
                <span class="mi-text" :title="m.menuName">{{ m.menuName }}</span>
              </template>
              <el-menu-item
                v-for="c in m.children"
                :key="c.id"
                :index="joinPath(m.path, c.path)"
              >
                <span class="mi-text" :title="c.menuName">{{ c.menuName }}</span>
              </el-menu-item>
            </el-sub-menu>
            <el-menu-item v-else-if="m.menuType === 'C'" :index="joinPath('', m.path)">
              <el-icon><component :is="m.icon || 'Menu'" /></el-icon>
              <span class="mi-text" :title="m.menuName">{{ m.menuName }}</span>
            </el-menu-item>
          </template>
        </el-menu>
      </el-scrollbar>
    </el-aside>

    <!-- 拖拽条：左右拖动调整侧边栏宽度，双击恢复默认 -->
    <div
      class="resizer"
      :class="{ 'is-dragging': dragging }"
      title="拖动调整菜单宽度，双击恢复默认"
      @mousedown.prevent="startResize"
      @dblclick="resetWidth"
    >
      <span class="resizer-bar"></span>
    </div>

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
                <el-dropdown-item command="portal" divided>进入前台驾驶舱</el-dropdown-item>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
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
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { joinPath } from '@/utils/path'
import { resetRouter } from '@/router'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

/* ---------------- 侧边栏宽度拖拽 ---------------- */
const DEFAULT_WIDTH = 220
const MIN_WIDTH = 180
const MAX_WIDTH = 560
const MAIN_MIN_WIDTH = 520
const WIDTH_KEY = 'rbac_aside_width'

// 上限既受固定值约束，也保证右侧内容区至少留出 MAIN_MIN_WIDTH
const maxWidth = () => {
  const byViewport = window.innerWidth - MAIN_MIN_WIDTH
  return Math.max(DEFAULT_WIDTH, Math.min(MAX_WIDTH, byViewport))
}
const clamp = (n) => Math.min(maxWidth(), Math.max(MIN_WIDTH, n))

const loadWidth = () => {
  const saved = Number(localStorage.getItem(WIDTH_KEY))
  if (!Number.isFinite(saved) || saved <= 0) return DEFAULT_WIDTH
  // 读取时只按固定区间收敛，避免窄窗口打开就被压到最小值
  return Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, saved))
}

const asideWidth = ref(loadWidth())
const dragging = ref(false)

let startX = 0
let startWidth = 0

const onMove = (e) => {
  asideWidth.value = Math.round(clamp(startWidth + (e.clientX - startX)))
}

const stopResize = () => {
  if (!dragging.value) return
  dragging.value = false
  document.removeEventListener('mousemove', onMove)
  document.removeEventListener('mouseup', stopResize)
  window.removeEventListener('blur', stopResize)
  document.body.classList.remove('aside-resizing')
  localStorage.setItem(WIDTH_KEY, String(asideWidth.value))
}

const startResize = (e) => {
  dragging.value = true
  startX = e.clientX
  startWidth = asideWidth.value
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', stopResize)
  window.addEventListener('blur', stopResize)
  document.body.classList.add('aside-resizing')
}

const resetWidth = () => {
  asideWidth.value = DEFAULT_WIDTH
  localStorage.setItem(WIDTH_KEY, String(DEFAULT_WIDTH))
}

// 窗口变窄时把超限的宽度收回来，避免挤爆内容区
const onWindowResize = () => {
  const next = clamp(asideWidth.value)
  if (next !== asideWidth.value) asideWidth.value = next
}

window.addEventListener('resize', onWindowResize)
onMounted(onWindowResize)

onBeforeUnmount(() => {
  stopResize()
  window.removeEventListener('resize', onWindowResize)
})
/* ------------------------------------------------ */

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => route.meta?.title || '首页')

const onCommand = async (cmd) => {
  if (cmd === 'portal') {
    router.push('/portal')
    return
  }
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
  overflow: hidden;
}
/* ---- 拖拽条 ---- */
.resizer {
  flex: 0 0 6px;
  margin: 0 -3px;
  position: relative;
  z-index: 10;
  cursor: col-resize;
  background: transparent;
  transition: background 0.15s;
}
.resizer:hover,
.resizer.is-dragging {
  background: rgba(74, 134, 255, 0.18);
}
.resizer-bar {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 50%;
  width: 2px;
  transform: translateX(-50%);
  background: transparent;
  transition: background 0.15s, width 0.15s;
}
.resizer:hover .resizer-bar {
  background: #4a86ff;
}
.resizer.is-dragging .resizer-bar {
  width: 3px;
  background: #4a86ff;
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
  flex: 0 0 auto;
}
.logo-text {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4a86ff;
  display: inline-block;
  flex: 0 0 auto;
}
.menu {
  border-right: none;
  background: transparent;
}
/* 长菜单名：窄时省略号 + 悬停看全称，拖宽后完整显示 */
.mi-text {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.menu :deep(.el-menu-item),
.menu :deep(.el-sub-menu__title) {
  color: #c6cbd4;
  overflow: hidden;
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
