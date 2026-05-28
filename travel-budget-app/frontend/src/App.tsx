import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './contexts/AuthContext'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'

// 未ログインの場合はログインページにリダイレクト
function PrivateRoute({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  return token ? <>{children}</> : <Navigate to="/login" />
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      {/* 旅行一覧ページは後で追加 */}
      <Route
        path="/trips"
        element={
          <PrivateRoute>
            <div className="p-8">旅行一覧（Coming Soon）</div>
          </PrivateRoute>
        }
      />
      {/* デフォルトはログインページへ */}
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  )
}