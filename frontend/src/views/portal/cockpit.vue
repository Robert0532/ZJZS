<template>
  <div class="portal">
    <header class="phead">
      <div class="brand">
        <el-icon class="back" @click="back"><ArrowLeft /></el-icon>
        <span class="name">硕果大数据测试服</span>
        <span class="sep">/</span>
        <span class="sub">数据驾驶舱</span>
      </div>
      <div class="right">
        <el-tag size="small" effect="plain" class="ghost-tag">{{ userStore.user.deptName || '未分配部门' }}</el-tag>
        <span class="uname">{{ userStore.user.nickname }}</span>
        <el-button link class="link-btn" @click="toAdmin">进入后台</el-button>
      </div>
    </header>

    <main class="pmain">
      <el-skeleton v-if="loading" :rows="6" animated />

      <template v-else-if="data">
        <div class="pchead">
          <div class="pc-title">
            <h1>{{ data.title }}</h1>
            <p>{{ data.deptName }} · {{ data.leader ? '全公司汇总视图' : '部门数据汇总视图' }}</p>
          </div>
          <div class="pc-tags">
            <el-tag size="small" effect="plain" type="info">数据范围：{{ data.scopeLabel }}</el-tag>
            <el-tag size="small" effect="plain" :type="data.accessible ? 'success' : 'danger'">
              {{ data.accessible ? '已授权' : '数据受限' }}
            </el-tag>
          </div>
        </div>

        <!-- 有权限：正常展示 -->
        <template v-if="data.accessible">
          <div class="kpis">
            <div class="kpi">
              <div class="k">{{ data.leader ? '部门数' : '本部门账号' }}</div>
              <div class="v">{{ data.leader ? data.visibleDeptCount : (data.userCount ?? '-') }}</div>
            </div>
            <div class="kpi">
              <div class="k">我可见的部门</div>
              <div class="v">{{ data.visibleDeptCount }}</div>
            </div>
            <div class="kpi">
              <div class="k">数据范围</div>
              <div class="v small">{{ data.scopeLabel }}</div>
            </div>
            <div class="kpi">
              <div class="k">指标项</div>
              <div class="v muted">—</div>
            </div>
          </div>

          <section class="panel">
            <div class="panel-head">
              我的可见范围
              <span class="panel-tip">按当前账号的数据权限计算，共 {{ data.visibleDeptCount }} 个部门</span>
            </div>
            <div class="tags">
              <el-tag v-for="d in data.visibleDepts" :key="d" size="small" effect="plain" type="info">{{ d }}</el-tag>
              <span v-if="!data.visibleDepts.length" class="tip">当前账号未匹配到任何部门</span>
            </div>
          </section>

          <section class="panel">
            <div class="panel-head">数据视图</div>
            <el-empty :image-size="96" description="业务指标接入后在此展示趋势与结构，当前已打通数据权限口径" />
          </section>
        </template>

        <!-- 无权限：说明原因 + 给出可去的地方 -->
        <section v-else class="deny">
          <el-icon class="deny-icon"><Lock /></el-icon>
          <h3>无权限查看该驾驶舱</h3>
          <p>{{ data.message }}</p>
          <div class="deny-actions">
            <el-button type="primary" @click="back">返回驾驶舱大厅</el-button>
            <el-button v-for="p in peers" :key="p.key" @click="go(p.key)">{{ p.title }}</el-button>
          </div>
        </section>
      </template>
    </main>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Lock } from '@element-plus/icons-vue'
import { getPortalCockpit } from '@/api/portal'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const data = ref(null)

// 只列出当前驾驶舱以外的、且有权限的舱，最多 3 个，避免越权页变成菜单墙
const peers = computed(() =>
  (data.value?.peers || []).filter((p) => p.key !== data.value?.key).slice(0, 3)
)

const load = async (key) => {
  loading.value = true
  data.value = null
  try {
    const res = await getPortalCockpit(key)
    data.value = res.data
  } finally {
    loading.value = false
  }
}

const back = () => router.push('/portal')
const go = (key) => router.push(`/portal/cockpit/${key}`)
const toAdmin = () => router.push('/dashboard')

watch(
  () => route.params.key,
  (key) => {
    if (key) load(key)
  },
  { immediate: true }
)
</script>

<style scoped>
.portal {
  min-height: 100vh;
  background: #f2f5fa;
}
.phead {
  height: 56px;
  background: #1f2530;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  position: sticky;
  top: 0;
  z-index: 20;
}
.brand {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
}
.back {
  cursor: pointer;
  font-size: 17px;
  color: #c6cbd4;
  margin-right: 2px;
}
.back:hover {
  color: #fff;
}
.name {
  font-weight: 500;
}
.sep {
  color: rgba(255, 255, 255, 0.32);
}
.sub {
  color: #c6cbd4;
}
.right {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 13px;
}
.ghost-tag {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.22);
  color: #dfe5ef;
}
.uname {
  color: #dfe5ef;
}
.link-btn {
  color: #9fb6dd;
}
.link-btn:hover {
  color: #fff;
}
.pmain {
  max-width: 1180px;
  margin: 0 auto;
  padding: 20px 24px 34px;
}
.pchead {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}
.pc-title h1 {
  margin: 0 0 5px;
  font-size: 21px;
  font-weight: 600;
}
.pc-title p {
  margin: 0;
  font-size: 12.5px;
  color: #7b8394;
}
.pc-tags {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
  padding-top: 4px;
}
.kpis {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 14px;
}
.kpi {
  background: #fff;
  border: 1px solid #e6eaf2;
  border-radius: 10px;
  padding: 14px 16px;
}
.kpi .k {
  font-size: 12px;
  color: #8b93a1;
  margin-bottom: 6px;
}
.kpi .v {
  font-size: 22px;
  font-weight: 600;
  line-height: 1.2;
}
.kpi .v.small {
  font-size: 15px;
  font-weight: 500;
  padding-top: 4px;
}
.kpi .v.muted {
  color: #b6bdc9;
}
.panel {
  background: #fff;
  border: 1px solid #e6eaf2;
  border-radius: 10px;
  padding: 16px 18px 18px;
  margin-bottom: 14px;
}
.panel-head {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 12px;
  display: flex;
  align-items: baseline;
  gap: 10px;
}
.panel-tip {
  font-size: 12px;
  font-weight: 400;
  color: #8b93a1;
}
.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.tip {
  font-size: 12.5px;
  color: #8b93a1;
}
.deny {
  background: #fff;
  border: 1px solid #e6eaf2;
  border-radius: 10px;
  padding: 44px 24px 40px;
  text-align: center;
}
.deny-icon {
  font-size: 40px;
  color: #d0d6e0;
}
.deny h3 {
  margin: 14px 0 8px;
  font-size: 17px;
  font-weight: 600;
}
.deny p {
  margin: 0 auto 22px;
  max-width: 560px;
  color: #6b7383;
  font-size: 13px;
  line-height: 1.7;
}
.deny-actions {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 10px;
}
@media (max-width: 980px) {
  .kpis {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
