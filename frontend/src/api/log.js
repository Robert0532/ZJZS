import request from '@/utils/request'

export const pageLog = (params) => request.get('/system/log/page', { params })
export const cleanLog = () => request.delete('/system/log/clean')
