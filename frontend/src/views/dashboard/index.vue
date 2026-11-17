<template>
  <div class="page-card">
    <h2 class="title">欢迎，{{ userStore.user.nickname }}</h2>
    <p class="sub">硕果大数据测试服，已接真实 MySQL，系统管理模块开箱可用。</p>

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
  margin-bottom: 0;
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
</style>
