import request from '@/utils/request'

export const treeMenu = (params) => request.get('/system/menu/tree', { params })
export const listMenu = (params) => request.get('/system/menu/list', { params })
export const addMenu = (data) => request.post('/system/menu', data)
export const updateMenu = (data) => request.put('/system/menu', data)
export const delMenu = (id) => request.delete(`/system/menu/${id}`)
