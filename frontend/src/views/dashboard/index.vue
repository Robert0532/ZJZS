<template>
  <div class="page-card">
    <h2 class="title">欢迎，{{ userStore.user.nickname }}</h2>
    <p class="sub">硕果大数据测试服 · 后台管理骨架，已接真实 MySQL，系统管理模块开箱可用。</p>

    <el-row :gutter="14" class="cards">
      <el-col :span="6">
        <div class="stat">
          <div class="k">当前部门</div>
          <div class="v">{{ userStore.user.deptName || '-' }}</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat">
          <div class="k">角色</div>
          <div class="v">{{ userStore.roles.join(' / ') || '-' }}</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat">
          <div class="k">权限标识数</div>
          <div class="v">{{ userStore.perms.length }}</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat">
          <div class="k">可见菜单</div>
          <div class="v">{{ menuCount }}</div>
        </div>
      </el-col>
    </el-row>

    <h3 class="h3">已实现能力</h3>
    <ul class="list">
      <li>JWT 登录鉴权 + 拦截器，每次请求实时装配权限（停用/改权限立即生效）</li>
      <li>菜单表驱动的动态路由与侧边栏，按钮级权限指令 v-perm</li>
      <li>用户 / 角色 / 菜单 / 部门 / 字典 / 操作日志 六个系统模块</li>
      <li>角色分配菜单权限 + 五种行级数据权限（全部 / 自定义 / 本部门 / 本部门及以下 / 仅本人）</li>
      <li>AOP 操作日志：参数、返回、耗时、IP、异常全记录</li>
      <li>部门树 ancestors 维护与子树重算，供数据权限按层级过滤</li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

const menuCount = computed(() => {
  let n = 0
  const walk = (list) => {
    for (const m of list || []) {
      if (m.menuType === 'C') n += 1
      if (m.children) walk(m.children)
    }
  }
  walk(userStore.menus)
  return n
})
</script>

<style scoped>
.title {
  margin: 0 0 6px;
  font-size: 19px;
  font-weight: 600;
}
.sub {
  margin: 0 0 20px;
  color: #6b7383;
  font-size: 13px;
}
.cards {
  margin-bottom: 8px;
}
.stat {
  background: #f7f9fc;
  border: 1px solid #e8ebf0;
  border-radius: 8px;
  padding: 14px 16px;
}
.stat .k {
  font-size: 12px;
  color: #8b93a1;
  margin-bottom: 6px;
}
.stat .v {
  font-size: 15px;
  font-weight: 500;
}
.h3 {
  font-size: 14px;
  margin: 24px 0 10px;
}
.list {
  margin: 0;
  padding-left: 20px;
  color: #3d434d;
  font-size: 13px;
  line-height: 1.9;
}
</style>
