export function joinPath(parentPath, path) {
  if (!path) return parentPath || '/'
  if (path.startsWith('/')) return path
  return `${parentPath}/${path}`.replace(/\/+/g, '/')
}
