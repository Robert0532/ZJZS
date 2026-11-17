import request from '@/utils/request'

export const pageUser = (params) => request.get('/system/user/page', { params })
export const getUser = (id) => request.get(`/system/user/${id}`)
export const addUser = (data) => request.post('/system/user', data)
export const updateUser = (data) => request.put('/system/user', data)
export const delUser = (id) => request.delete(`/system/user/${id}`)
export const resetUserPwd = (id, password) =>
  request.put(`/system/user/${id}/password`, null, { params: { password } })
export const changeUserStatus = (id, status) =>
  request.put(`/system/user/${id}/status`, null, { params: { status } })
export const exportUser = (params) =>
  request.get('/system/user/export', { params, responseType: 'blob' })
