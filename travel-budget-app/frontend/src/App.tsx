import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './contexts/AuthContext'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import TripsPage from './pages/TripsPage'
import ExpensePage from './pages/ExpensePage'

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
      <Route
        path="/trips"
        element={
          <PrivateRoute>
            <TripsPage />
          </PrivateRoute>
        }
      />
      <Route
        path="/trips/:id"
        element={
          <PrivateRoute>
            <ExpensePage />
          </PrivateRoute>
        }
      />
      {/* デフォルトはログインページへ */}
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  )
}