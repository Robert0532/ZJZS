import request from '@/utils/request'

export const pageRole = (params) => request.get('/system/role/page', { params })
export const listRole = () => request.get('/system/role/all')
export const getRole = (id) => request.get(`/system/role/${id}`)
export const addRole = (data) => request.post('/system/role', data)
export const updateRole = (data) => request.put('/system/role', data)
export const delRole = (id) => request.delete(`/system/role/${id}`)
export const getRoleMenuIds = (id) => request.get(`/system/role/${id}/menuIds`)
export const saveRoleMenus = (id, menuIds) => request.put(`/system/role/${id}/menus`, menuIds)
export const getRoleDeptIds = (id) => request.get(`/system/role/${id}/deptIds`)
export const saveRoleDepts = (id, deptIds) => request.put(`/system/role/${id}/depts`, deptIds)
