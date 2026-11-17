import { useUserStore } from '@/store/user'

/**
 * v-perm="'system:user:add'"：无权限时直接移除元素。
 * 注意这只是前端体验优化，后端 @RequiresPerm 才是真正的权限边界。
 */
export default {
  mounted(el, binding) {
    const perm = binding.value
    if (!perm) return
    const store = useUserStore()
    if (!store.hasPerm(perm)) {
      el.parentNode && el.parentNode.removeChild(el)
    }
  }
}
