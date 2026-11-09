import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { AuthProvider } from './shared/auth/AuthProvider'
import { AppShell } from './shared/ui/AppShell'
import { ProtectedRoute } from './shared/ui/ProtectedRoute'
import { FarmSettingsPage } from './features/auth/pages/FarmSettingsPage'
import { HomePage } from './features/auth/pages/HomePage'
import { ProfilePage } from './features/auth/pages/ProfilePage'
import { SignInPage } from './features/auth/pages/SignInPage'
import { SignUpPage } from './features/auth/pages/SignUpPage'
import { CowCreatePage } from './features/cows/pages/CowCreatePage'
import { CowDetailPage } from './features/cows/pages/CowDetailPage'
import { CowsListPage } from './features/cows/pages/CowsListPage'
import { PoultryCreatePage } from './features/poultry/pages/PoultryCreatePage'
import { PoultryDetailPage } from './features/poultry/pages/PoultryDetailPage'
import { PoultryListPage } from './features/poultry/pages/PoultryListPage'

const queryClient = new QueryClient()

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/signin" element={<SignInPage />} />
            <Route path="/signup" element={<SignUpPage />} />
            <Route element={<ProtectedRoute />}>
              <Route element={<AppShell />}>
                <Route path="/" element={<HomePage />} />
                <Route path="/cows" element={<CowsListPage />} />
                <Route path="/cows/new" element={<CowCreatePage />} />
                <Route path="/cows/:cowId" element={<CowDetailPage />} />
                <Route path="/poultry" element={<PoultryListPage />} />
                <Route path="/poultry/new" element={<PoultryCreatePage />} />
                <Route path="/poultry/:groupId" element={<PoultryDetailPage />} />
                <Route path="/profile" element={<ProfilePage />} />
                <Route path="/settings" element={<FarmSettingsPage />} />
              </Route>
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  )
}
