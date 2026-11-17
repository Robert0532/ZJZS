<template>
  <div class="portal">
    <header class="phead">
      <div class="brand">
        <span class="dot"></span>
        <span class="name">硕果大数据测试服</span>
        <span class="sep">/</span>
        <span class="sub">数据驾驶舱</span>
      </div>
      <div class="right">
        <el-tag size="small" effect="plain" class="ghost-tag">{{ userStore.user.deptName || '未分配部门' }}</el-tag>
        <span class="uname">{{ userStore.user.nickname }}</span>
        <el-button link class="link-btn" @click="toAdmin">进入后台</el-button>
        <el-button link class="link-btn" @click="onLogout">退出</el-button>
      </div>
    </header>

    <main class="pmain">
      <div class="pmain-head">
        <div>
          <h1>数据驾驶舱</h1>
          <p>共 {{ cards.length }} 个驾驶舱，点击卡片进入查看</p>
        </div>
        <el-tag v-if="scopeLabel" size="small" effect="plain" type="info">我的数据范围：{{ scopeLabel }}</el-tag>
      </div>

      <el-skeleton v-if="loading" :rows="6" animated />

      <template v-else>
        <!-- 领导舱：全公司汇总，单独特一条通栏 -->
        <section
          v-if="leader"
          class="leader"
          :class="{ limited: !leader.accessible }"
          @click="open(leader)"
        >
          <div class="leader-main">
            <div class="leader-tag">全公司</div>
            <h2>{{ leader.title }}</h2>
            <p>{{ leader.subtitle }}</p>
            <div class="leader-meta">
              <el-tag v-if="!leader.accessible" size="small" effect="dark" type="info">数据受限</el-tag>
              <span v-else class="leader-go">进入驾驶舱 <el-icon><ArrowRight /></el-icon></span>
            </div>
          </div>
          <div class="leader-thumb">
            <PortalThumb :seed="0" />
          </div>
        </section>

        <!-- 15 个部门：5 列 × 3 行 -->
        <div class="grid">
          <article
            v-for="(c, i) in depts"
            :key="c.key"
            class="card"
            :class="{ limited: !c.accessible }"
            :title="c.accessible ? c.title : c.restrictedHint"
            @click="open(c)"
          >
            <div class="thumb">
              <PortalThumb :seed="i + 1" />
              <span v-if="!c.accessible" class="lock">受限</span>
            </div>
            <div class="cap">
              <div class="cap-name">{{ c.deptName }}</div>
              <div class="cap-sub">数据驾驶舱</div>
            </div>
          </article>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowRight } from '@element-plus/icons-vue'
import { getPortalOverview } from '@/api/portal'
import { useUserStore } from '@/store/user'
import { resetRouter } from '@/router'
import PortalThumb from './components/PortalThumb.vue'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const cards = ref([])
const scopeLabel = ref('')

const leader = computed(() => cards.value.find((c) => c.leader))
const depts = computed(() => cards.value.filter((c) => !c.leader))

const open = (card) => {
  router.push(`/portal/cockpit/${card.key}`)
}

const toAdmin = () => router.push('/dashboard')

const onLogout = async () => {
  await ElMessageBox.confirm('确认退出登录？', '提示', { type: 'warning' })
  await userStore.logout()
  resetRouter()
  ElMessage.success('已退出')
  window.location.href = '/login'
}

onMounted(async () => {
  try {
    const res = await getPortalOverview()
    cards.value = res.data?.cards || []
    scopeLabel.value = res.data?.scopeLabel || ''
  } finally {
    loading.value = false
  }
})
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
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4a86ff;
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
  max-width: 1560px;
  margin: 0 auto;
  padding: 20px 24px 34px;
}
.pmain-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}
.pmain-head h1 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
}
.pmain-head p {
  margin: 0;
  font-size: 12.5px;
  color: #7b8394;
}

/* ---- 领导舱通栏 ---- */
.leader {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 20px 26px;
  border-radius: 12px;
  background: linear-gradient(118deg, #1f2530 0%, #2b3a55 58%, #31507f 100%);
  color: #fff;
  cursor: pointer;
  overflow: hidden;
  position: relative;
  transition: box-shadow 0.2s, transform 0.2s;
}
.leader:hover {
  transform: translateY(-1px);
  box-shadow: 0 12px 28px rgba(31, 37, 48, 0.22);
}
.leader-main {
  flex: 1;
  min-width: 0;
}
.leader-tag {
  display: inline-block;
  font-size: 11.5px;
  padding: 2px 8px;
  border-radius: 10px;
  background: rgba(122, 166, 255, 0.18);
  color: #a9c4ff;
  margin-bottom: 8px;
}
.leader-main h2 {
  margin: 0 0 6px;
  font-size: 21px;
  font-weight: 600;
  letter-spacing: 0.5px;
}
.leader-main p {
  margin: 0;
  font-size: 12.5px;
  color: rgba(255, 255, 255, 0.66);
}
.leader-meta {
  margin-top: 14px;
  font-size: 13px;
}
.leader-go {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #9fc0ff;
}
.leader-thumb {
  width: 300px;
  height: 96px;
  flex: 0 0 auto;
  opacity: 0.9;
}
.leader.limited .leader-thumb {
  opacity: 0.35;
}

/* ---- 部门宫格 ---- */
.grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 14px;
  margin-top: 16px;
}
.card {
  background: #fff;
  border: 1px solid #e6eaf2;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  transition: transform 0.18s, box-shadow 0.18s, border-color 0.18s;
}
.card:hover {
  transform: translateY(-2px);
  border-color: #c9d6ef;
  box-shadow: 0 10px 24px rgba(31, 37, 48, 0.1);
}
.thumb {
  height: 104px;
  background: linear-gradient(180deg, #f8fafd, #eef3fb);
  border-bottom: 1px solid #eef1f6;
  position: relative;
}
.card.limited .thumb {
  filter: grayscale(0.35);
  opacity: 0.78;
}
.lock {
  position: absolute;
  top: 8px;
  right: 8px;
  font-size: 11px;
  line-height: 1;
  padding: 4px 7px;
  border-radius: 9px;
  background: rgba(31, 37, 48, 0.62);
  color: #fff;
}
.cap {
  padding: 10px 12px 12px;
  text-align: center;
}
.cap-name {
  font-size: 13px;
  font-weight: 500;
  color: #1a1d21;
  line-height: 1.35;
  min-height: 18px;
}
.cap-sub {
  margin-top: 3px;
  font-size: 11.5px;
  color: #8b93a1;
}

@media (max-width: 1400px) {
  .grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}
@media (max-width: 1080px) {
  .grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
  .leader-thumb {
    width: 220px;
  }
}
@media (max-width: 760px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
  .leader-thumb {
    display: none;
  }
  .pmain {
    padding: 16px;
  }
}
</style>
