import request from '@/utils/request'

export const getPortalOverview = () => request.get('/portal/overview')
export const getPortalCockpit = (key) => request.get(`/portal/cockpit/${key}`)
