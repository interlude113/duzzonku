import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import api from '../lib/axios'

export default function RegisterPage() {
  const { login } = useAuth()
  const navigate = useNavigate()

  // フォームの入力値を管理
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    try {
      // 会員登録APIにリクエスト
      const res = await api.post('/register', { name, email, password })
      // tokenとuserをContextに保存
      login(res.data.token, res.data.user)
      // 登録成功後、旅行一覧ページへ遷移
      navigate('/trips')
    } catch {
      setError('登録に失敗しました。入力内容を確認してください')
    }
  }

  return (
    <div className="min-h-screen bg-slate-900 flex items-center justify-center">
      <div className="bg-slate-800 border border-slate-700 p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 className="text-2xl font-bold text-center mb-6 text-sky-400">
          旅行予算メモ
        </h1>
        <h2 className="text-xl font-semibold text-center mb-6 text-slate-200">新規登録</h2>

        {/* エラーメッセージ */}
        {error && (
          <div className="bg-red-900 text-red-300 p-3 rounded mb-4 text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-1">
              名前
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-1">
              メールアドレス
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-1">
              パスワード（8文字以上）
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-sky-500 text-white py-2 rounded-md hover:bg-sky-600 transition font-semibold"
          >
            登録する
          </button>
        </form>

        <p className="text-center text-sm text-slate-500 mt-4">
          すでにアカウントをお持ちの方は{' '}
          <Link to="/login" className="text-sky-400 hover:underline">
            ログイン
          </Link>
        </p>
      </div>
    </div>
  )
}