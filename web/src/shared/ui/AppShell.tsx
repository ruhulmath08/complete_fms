import { Link, NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../auth/useAuth'

export function AppShell() {
  const { signOut } = useAuth()

  return (
    <div className="app-shell">
      <header className="app-header">
        <Link to="/" className="brand">
          Farm Manager
        </Link>
        <nav className="nav-links">
          <NavLink to="/cows">Cows</NavLink>
          <NavLink to="/poultry">Poultry</NavLink>
          <NavLink to="/profile">Profile</NavLink>
          <NavLink to="/settings">Farm settings</NavLink>
          <button type="button" className="btn btn-ghost" onClick={() => void signOut()}>
            Sign out
          </button>
        </nav>
      </header>
      <Outlet />
    </div>
  )
}
