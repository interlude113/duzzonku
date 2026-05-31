import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import api from '../lib/axios'

// 旅行データの型定義
interface Trip {
  id: number
  name: string
  budget: number
  start_date: string
  end_date: string
  total: number
  balance: number
}

export default function TripsPage() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const [trips, setTrips] = useState<Trip[]>([])
  const [name, setName] = useState('')
  const [budget, setBudget] = useState('')
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [error, setError] = useState('')

  const fetchTrips = async () => {
    const res = await api.get('/trips')
    setTrips(res.data)
  }

  // ページ読み込み時に旅行一覧を取得
  useEffect(() => {
    fetchTrips()
  }, [])

  // 旅行を新規登録
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    try {
      await api.post('/trips', {
        name,
        budget: Number(budget),
        start_date: startDate,
        end_date: endDate,
      })
      // フォームをリセット
      setName('')
      setBudget('')
      setStartDate('')
      setEndDate('')
      setShowForm(false)
      fetchTrips()
    } catch {
      setError('登録に失敗しました')
    }
  }

  // 旅行を削除
  const handleDelete = async (id: number) => {
    if (!confirm('本当に削除しますか？')) return
    await api.delete(`/trips/${id}`)
    fetchTrips()
  }

  // ログアウト
  const handleLogout = async () => {
    await api.post('/logout')
    logout()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-slate-900">
      {/* ヘッダー */}
      <header className="bg-slate-800 border-b border-slate-700">
        <div className="max-w-2xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-xl font-bold text-sky-400">旅行予算メモ</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-slate-400">{user?.name}</span>
            <button
              onClick={handleLogout}
              className="text-sm text-slate-500 hover:text-slate-300 transition"
            >
              ログアウト
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 py-6">
        {/* 旅行追加ボタン */}
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold text-slate-200">旅行一覧</h2>
          <button
            onClick={() => setShowForm(!showForm)}
            className="bg-sky-500 text-white px-4 py-2 rounded-md hover:bg-sky-600 transition text-sm font-semibold"
          >
            ＋ 旅行を追加
          </button>
        </div>

        {/* 旅行登録フォーム */}
        {showForm && (
          <div className="bg-slate-800 border border-slate-700 p-6 rounded-lg mb-4">
            <h3 className="font-semibold mb-4 text-slate-200">新しい旅行を登録</h3>
            {error && (
              <div className="bg-red-900 text-red-300 p-3 rounded mb-4 text-sm">
                {error}
              </div>
            )}
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-1">
                  旅行名
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
                  予算（円）
                </label>
                <input
                  type="number"
                  value={budget}
                  onChange={(e) => setBudget(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                  required
                />
              </div>
              <div className="flex gap-3">
                <div className="flex-1">
                  <label className="block text-sm font-medium text-slate-400 mb-1">
                    開始日
                  </label>
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                    required
                  />
                </div>
                <div className="flex-1">
                  <label className="block text-sm font-medium text-slate-400 mb-1">
                    終了日
                  </label>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                    required
                  />
                </div>
              </div>
              <div className="flex gap-3">
                <button
                  type="submit"
                  className="flex-1 bg-sky-500 text-white py-2 rounded-md hover:bg-sky-600 transition font-semibold"
                >
                  登録する
                </button>
                <button
                  type="button"
                  onClick={() => setShowForm(false)}
                  className="flex-1 bg-slate-700 text-slate-300 py-2 rounded-md hover:bg-slate-600 transition"
                >
                  キャンセル
                </button>
              </div>
            </form>
          </div>
        )}

        {/* 旅行一覧 */}
        {trips.length === 0 ? (
          <div className="bg-slate-800 border border-slate-700 p-8 rounded-lg text-center text-slate-500">
            旅行がまだ登録されていません
          </div>
        ) : (
          <div className="space-y-3">
            {trips.map((trip) => (
              <div
                key={trip.id}
                className="bg-slate-800 border border-slate-700 p-5 rounded-lg"
              >
                <div className="flex justify-between items-center">
                    <div
                    className="flex-1 cursor-pointer"
                    onClick={() => navigate(`/trips/${trip.id}`)}
                    >
                    <h3 className="font-semibold text-lg text-slate-200">{trip.name}</h3>
                    <p className="text-sm text-slate-500 mt-1">
                      {trip.start_date} 〜 {trip.end_date}
                    </p>
                    <div className="flex gap-4 mt-2">
                        <p className="text-sm font-medium text-sky-400">
                            予算: ¥{trip.budget.toLocaleString()}
                        </p>
                        <p className="text-sm font-medium text-red-400">
                            支出: ¥{trip.total.toLocaleString()}
                        </p>
                        <p className={`text-sm font-medium ${trip.balance >= 0 ? 'text-green-400' : 'text-red-400'}`}>
                            残高: ¥{trip.balance.toLocaleString()}
                        </p>
                    </div>
                  </div>
                  <button
                    onClick={() => handleDelete(trip.id)}
                    className="text-red-500 hover:text-red-400 text-xl ml-4 transition"
                  >
                    削除
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}