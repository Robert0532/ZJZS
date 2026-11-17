import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/layout/index.vue'
import { useUserStore } from '@/store/user'
import { joinPath } from '@/utils/path'

const modules = import.meta.glob('../views/**/*.vue')

const loadView = (component) => {
  if (!component) return () => import('@/views/error/404.vue')
  const key = `../views/${component}.vue`
  return modules[key] || (() => import('@/views/error/404.vue'))
}

export const constantRoutes = [
  { path: '/login', component: () => import('@/views/login/index.vue'), meta: { public: true } },
  // 前台驾驶舱：独立于后台 Layout，不带侧边栏
  {
    path: '/portal',
    name: 'Portal',
    component: () => import('@/views/portal/index.vue'),
    meta: { title: '数据驾驶舱' }
  },
  {
    path: '/portal/cockpit/:key',
    name: 'PortalCockpit',
    component: () => import('@/views/portal/cockpit.vue'),
    meta: { title: '数据驾驶舱' }
  },
  {
    path: '/',
    name: 'Layout',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '首页' }
      }
    ]
  }
]

/** 把后端菜单（M 目录 / C 菜单）摊平成 Layout 的子路由 */
export function buildRoutes(menus, parentPath = '') {
  const routes = []
  for (const menu of menus || []) {
    const path = menu.path || ''
    const fullPath = path.startsWith('/') ? path : `${parentPath}/${path}`.replace(/\/+/g, '/')
    if (menu.menuType === 'C') {
      routes.push({
        path: fullPath.replace(/^\//, ''),
        name: `menu-${menu.id}`,
        component: loadView(menu.component),
        meta: { title: menu.menuName, perms: menu.perms, icon: menu.icon }
      })
    } else if (menu.children && menu.children.length) {
      routes.push(...buildRoutes(menu.children, fullPath))
    }
  }
  return routes
}

const router = createRouter({
  history: createWebHistory(),
  routes: constantRoutes
})

let dynamicAdded = false

router.beforeEach(async (to, from, next) => {
  const store = useUserStore()
  if (to.meta.public) {
    return next()
  }
  if (!store.token) {
    return next(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
  }
  if (store.user && store.user.userId) {
    return next()
  }
  try {
    const data = await store.getInfo()
    if (!dynamicAdded) {
      buildRoutes(data.menus).forEach((route) => router.addRoute('Layout', route))
      router.addRoute({
        path: '/:pathMatch(.*)*',
        component: () => import('@/views/error/404.vue'),
        meta: { public: true }
      })
      dynamicAdded = true
    }
    return next({ ...to, replace: true })
  } catch (e) {
    store.reset()
    dynamicAdded = false
    return next('/login')
  }
})

export function resetRouter() {
  dynamicAdded = false
}

export default router
