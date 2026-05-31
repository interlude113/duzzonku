import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api from '../lib/axios'

// 支出データの型定義
interface Expense {
  id: number
  amount: number
  category: string
  memo: string | null
  created_at: string
}

// 旅行データの型定義
interface Trip {
  id: number
  name: string
  budget: number
  start_date: string
  end_date: string
}

// カテゴリの選択肢
const CATEGORIES = ['食費', '交通', '宿泊', '観光', '買い物', 'その他']

export default function ExpensePage() {
  const { id } = useParams()
  const navigate = useNavigate()

  const [trip, setTrip] = useState<Trip | null>(null)
  const [expenses, setExpenses] = useState<Expense[]>([])
  const [total, setTotal] = useState(0)
  const [balance, setBalance] = useState(0)
  const [showForm, setShowForm] = useState(false)
  const [amount, setAmount] = useState('')
  const [category, setCategory] = useState('食費')
  const [memo, setMemo] = useState('')
  const [error, setError] = useState('')

  const fetchExpenses = async () => {
    const res = await api.get(`/trips/${id}/expenses`)
    setExpenses(res.data.expenses)
    setTotal(res.data.total)
    setBalance(res.data.balance)
  }

  // ページ読み込み時に旅行情報と支出一覧を取得
  useEffect(() => {
    const fetchTrip = async () => {
      const res = await api.get('/trips')
      const found = res.data.find((t: Trip) => t.id === Number(id))
      setTrip(found)
    }
    fetchTrip()
    fetchExpenses()
  }, [id])

  // 支出を新規登録
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    try {
      await api.post(`/trips/${id}/expenses`, {
        amount: Number(amount),
        category,
        memo: memo || null,
      })
      // フォームをリセット
      setAmount('')
      setCategory('食費')
      setMemo('')
      setShowForm(false)
      fetchExpenses()
    } catch {
      setError('登録に失敗しました')
    }
  }

  // 支出を削除
  const handleDelete = async (expenseId: number) => {
    if (!confirm('本当に削除しますか？')) return
    await api.delete(`/trips/${id}/expenses/${expenseId}`)
    fetchExpenses()
  }

  return (
    <div className="min-h-screen bg-slate-900">
      {/* ヘッダー */}
      <header className="bg-slate-800 border-b border-slate-700">
        <div className="max-w-2xl mx-auto px-4 py-4 flex justify-between items-center">
          <button
            onClick={() => navigate('/trips')}
            className="text-sky-400 hover:underline text-sm transition"
          >
            ← 旅行一覧に戻る
          </button>
          <h1 className="text-xl font-bold text-sky-400">
            {trip?.name}
          </h1>
          <div className="w-16" />
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 py-6">
        {/* 予算サマリー */}
        <div className="bg-slate-800 border border-slate-700 p-5 rounded-lg mb-4">
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p className="text-sm text-slate-500">予算</p>
              <p className="text-lg font-bold text-slate-200">
                ¥{trip?.budget.toLocaleString()}
              </p>
            </div>
            <div>
              <p className="text-sm text-slate-500">合計支出</p>
              <p className="text-lg font-bold text-red-400">
                ¥{total.toLocaleString()}
              </p>
            </div>
            <div>
              <p className="text-sm text-slate-500">残高</p>
              <p className={`text-lg font-bold ${balance >= 0 ? 'text-green-400' : 'text-red-400'}`}>
                ¥{balance.toLocaleString()}
              </p>
            </div>
          </div>
        </div>

        {/* 支出追加ボタン */}
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold text-slate-200">支出一覧</h2>
          <button
            onClick={() => setShowForm(!showForm)}
            className="bg-sky-500 text-white px-4 py-2 rounded-md hover:bg-sky-600 transition text-sm font-semibold"
          >
            ＋ 支出を追加
          </button>
        </div>

        {/* 支出登録フォーム */}
        {showForm && (
          <div className="bg-slate-800 border border-slate-700 p-6 rounded-lg mb-4">
            <h3 className="font-semibold mb-4 text-slate-200">支出を登録</h3>
            {error && (
              <div className="bg-red-900 text-red-300 p-3 rounded mb-4 text-sm">
                {error}
              </div>
            )}
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-1">
                  金額（円）
                </label>
                <input
                  type="number"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-1">
                  カテゴリ
                </label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                >
                  {CATEGORIES.map((cat) => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-1">
                  メモ（任意）
                </label>
                <input
                  type="text"
                  value={memo}
                  onChange={(e) => setMemo(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-600 rounded-md px-3 py-2 text-slate-200 focus:outline-none focus:ring-2 focus:ring-sky-500"
                />
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

        {/* 支出一覧 */}
        {expenses.length === 0 ? (
          <div className="bg-slate-800 border border-slate-700 p-8 rounded-lg text-center text-slate-500">
            支出がまだ登録されていません
          </div>
        ) : (
          <div className="space-y-3">
            {expenses.map((expense) => (
              <div key={expense.id} className="bg-slate-800 border border-slate-700 p-4 rounded-lg">
                <div className="flex justify-between items-center">
                  <div>
                    <span className="inline-block bg-sky-900 text-sky-300 text-xs px-2 py-1 rounded mr-2">
                      {expense.category}
                    </span>
                    <span className="font-semibold text-slate-200">
                      ¥{expense.amount.toLocaleString()}
                    </span>
                    {expense.memo && (
                      <p className="text-sm text-slate-500 mt-1">{expense.memo}</p>
                    )}
                  </div>
                  <button
                    onClick={() => handleDelete(expense.id)}
                    className="text-red-500 hover:text-red-400 text-base transition"
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