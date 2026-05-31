import axios from 'axios'

const api = axios.create({
  // Laravel APIのベースURL
  baseURL: 'http://localhost:8000/api',
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