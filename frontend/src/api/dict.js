import request from '@/utils/request'

export const pageDictType = (params) => request.get('/system/dict/type/page', { params })
export const addDictType = (data) => request.post('/system/dict/type', data)
export const updateDictType = (data) => request.put('/system/dict/type', data)
export const delDictType = (id) => request.delete(`/system/dict/type/${id}`)

export const listDictData = (dictType) => request.get(`/system/dict/data/${dictType}`)
export const addDictData = (data) => request.post('/system/dict/data', data)
export const updateDictData = (data) => request.put('/system/dict/data', data)
export const delDictData = (id) => request.delete(`/system/dict/data/${id}`)
