<template>
  <div class="nf">
    <div class="code">404</div>
    <div class="msg">页面不存在，或你没有该菜单的访问权限</div>
    <el-button type="primary" @click="$router.replace('/')">返回首页</el-button>
  </div>
</template>

<style scoped>
.nf {
  height: 60vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
}
.code {
  font-size: 64px;
  font-weight: 600;
  color: #d7dce4;
  line-height: 1;
}
.msg {
  color: #8b93a1;
  font-size: 13.5px;
}
</style>
