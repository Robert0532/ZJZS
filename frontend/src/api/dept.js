import request from '@/utils/request'

export const treeDept = (params) => request.get('/system/dept/tree', { params })
export const deptOptions = () => request.get('/system/dept/options')
export const addDept = (data) => request.post('/system/dept', data)
export const updateDept = (data) => request.put('/system/dept', data)
export const delDept = (id) => request.delete(`/system/dept/${id}`)
