import axios from 'axios'

const api = axios.create({
  // 本番環境のLaravel APIのURL
  baseURL: 'https://duzzonku-production.up.railway.app/api',
})

// リクエストのたびにlocalStorageからトークンを取得してヘッダーに付与
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default api