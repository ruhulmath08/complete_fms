import { useEffect, useState } from 'react'
import { Link, NavLink, Outlet } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { getProfile } from '../../features/auth/api/authApi'
import { useProfileImageUrl } from '../../features/auth/hooks/useProfileImageUrl'
import { useAuth } from '../auth/useAuth'

const SIDEBAR_KEY = 'fms.shell.sidebarOpen'

const NAV_ITEMS = [
  { to: '/cows', label: 'Cows' },
  { to: '/poultry', label: 'Poultry' },
  { to: '/crops', label: 'Crops' },
  { to: '/inventory', label: 'Inventory' },
  { to: '/ledger', label: 'Income & expenses' },
  { to: '/profile', label: 'Profile' },
  { to: '/settings', label: 'Farm settings' },
] as const

function readSidebarOpen(): boolean {
  try {
    const raw = localStorage.getItem(SIDEBAR_KEY)
    if (raw === null) return true
    return raw === 'true'
  } catch {
    return true
  }
}

export function AppShell() {
  const { signOut } = useAuth()
  const [sidebarOpen, setSidebarOpen] = useState(readSidebarOpen)
  const [notificationsOpen, setNotificationsOpen] = useState(false)

  const { data: profile } = useQuery({
    queryKey: ['me'],
    queryFn: getProfile,
  })
  const profileImageUrl = useProfileImageUrl(profile?.updated_at)
  const initials = (profile?.full_name ?? 'Owner')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? '')
    .join('')

  useEffect(() => {
    try {
      localStorage.setItem(SIDEBAR_KEY, String(sidebarOpen))
    } catch {
      // ignore storage failures
    }
  }, [sidebarOpen])

  return (
    <div className={`app-shell${sidebarOpen ? '' : ' app-shell--collapsed'}`}>
      <aside
        id="app-sidebar"
        className="app-sidebar"
        aria-label="Main menu"
        hidden={!sidebarOpen}
      >
        <div className="app-sidebar__brand">
          <Link to="/" className="app-sidebar__brand-link">
            Farm Manager
          </Link>
        </div>
        <nav className="app-sidebar__nav">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `app-sidebar__link${isActive ? ' app-sidebar__link--active' : ''}`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="app-sidebar__footer">
          <button
            type="button"
            className="btn btn-ghost app-sidebar__signout"
            onClick={() => void signOut()}
          >
            Sign out
          </button>
        </div>
      </aside>

      <div className="app-shell__main">
        <header className="app-topbar">
          <button
            type="button"
            className="btn btn-ghost app-topbar__toggle"
            aria-expanded={sidebarOpen}
            aria-controls="app-sidebar"
            onClick={() => setSidebarOpen((open) => !open)}
          >
            {sidebarOpen ? 'Hide menu' : 'Show menu'}
          </button>

          <div className="app-topbar__actions">
            <div className="app-topbar__notify-wrap">
              <button
                type="button"
                className="app-topbar__icon-btn"
                aria-label="Notifications"
                aria-expanded={notificationsOpen}
                onClick={() => setNotificationsOpen((open) => !open)}
              >
                <svg
                  className="app-topbar__bell"
                  viewBox="0 0 24 24"
                  width="20"
                  height="20"
                  aria-hidden="true"
                >
                  <path
                    fill="currentColor"
                    d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22Zm8-6V11a8 8 0 1 0-16 0v5l-2 2v1h20v-1l-2-2Zm-2 1H6v-6a6 6 0 1 1 12 0v6Z"
                  />
                </svg>
              </button>
              {notificationsOpen ? (
                <div className="app-topbar__notify-panel" role="status">
                  No notifications yet.
                </div>
              ) : null}
            </div>

            <Link to="/profile" className="app-topbar__profile" aria-label="Open profile">
              {profileImageUrl ? (
                <img
                  src={profileImageUrl}
                  alt=""
                  className="app-topbar__avatar"
                />
              ) : (
                <span className="app-topbar__avatar app-topbar__avatar--fallback">
                  {initials || 'O'}
                </span>
              )}
            </Link>
          </div>
        </header>

        <main className="app-content">
          <Outlet />
        </main>

        <footer className="app-footer">
          <span>Farm Manager</span>
          <span className="muted">Single-farm record keeping</span>
        </footer>
      </div>
    </div>
  )
}
