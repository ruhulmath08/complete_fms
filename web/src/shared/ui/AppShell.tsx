import { useEffect, useRef, useState } from "react";
import { Link, NavLink, Outlet } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { getProfile } from "../../features/auth/api/authApi";
import { useProfileImageUrl } from "../../features/auth/hooks/useProfileImageUrl";
import { useAuth } from "../auth/useAuth";

const SIDEBAR_KEY = "fms.shell.sidebarOpen";

const NAV_ITEMS = [
  { to: "/cows", label: "Cows" },
  { to: "/poultry", label: "Poultry" },
  { to: "/crops", label: "Crops" },
  { to: "/inventory", label: "Inventory" },
  { to: "/ledger", label: "Income & expenses" },
  { to: "/profile", label: "Profile" },
  { to: "/settings", label: "Farm settings" },
] as const;

function readSidebarOpen(): boolean {
  try {
    const raw = localStorage.getItem(SIDEBAR_KEY);
    if (raw === null) return true;
    return raw === "true";
  } catch {
    return true;
  }
}

function MenuOpenIcon() {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <path
        fill="currentColor"
        d="M3 6h18v2H3V6zm0 5h18v2H3v-2zm0 5h18v2H3v-2z"
      />
    </svg>
  );
}

function MenuCloseIcon() {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <path
        fill="currentColor"
        d="M18.3 5.71 12 12.01 5.7 5.7 4.29 7.11 10.59 13.4 4.29 19.7 5.7 21.11 12 14.82l6.3 6.29 1.41-1.41-6.29-6.3 6.29-6.29z"
      />
    </svg>
  );
}

function ProfileMenuIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
      <path
        fill="currentColor"
        d="M12 12a4.5 4.5 0 1 0-4.5-4.5A4.5 4.5 0 0 0 12 12Zm0 2.25c-3.75 0-6.75 1.91-6.75 4.25V20h13.5v-1.5c0-2.34-3-4.25-6.75-4.25Z"
      />
    </svg>
  );
}

function LogoutMenuIcon() {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
      <path
        fill="currentColor"
        d="M10 17v-3H3v-4h7V7l5 5-5 5Zm9-12h-7v2h7v14h-7v2h7a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2Z"
      />
    </svg>
  );
}

export function AppShell() {
  const { signOut } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(readSidebarOpen);
  const [notificationsOpen, setNotificationsOpen] = useState(false);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const profileMenuRef = useRef<HTMLDivElement>(null);
  const menuToggleRef = useRef<HTMLButtonElement>(null);
  const notificationsButtonRef = useRef<HTMLButtonElement>(null);
  const profileButtonRef = useRef<HTMLButtonElement>(null);

  const { data: profile } = useQuery({
    queryKey: ["me"],
    queryFn: getProfile,
  });
  const profileImageUrl = useProfileImageUrl(profile?.updated_at);
  const initials = (profile?.full_name ?? "Owner")
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");

  useEffect(() => {
    try {
      localStorage.setItem(SIDEBAR_KEY, String(sidebarOpen));
    } catch {
      // ignore storage failures
    }
  }, [sidebarOpen]);

  useEffect(() => {
    if (!profileMenuOpen) return;
    function onPointerDown(event: MouseEvent) {
      if (!profileMenuRef.current?.contains(event.target as Node)) {
        setProfileMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", onPointerDown);
    return () => document.removeEventListener("mousedown", onPointerDown);
  }, [profileMenuOpen]);

  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.key !== "Escape") return;
      if (profileMenuOpen) {
        setProfileMenuOpen(false);
        profileButtonRef.current?.focus();
        return;
      }
      if (notificationsOpen) {
        setNotificationsOpen(false);
        notificationsButtonRef.current?.focus();
        return;
      }
      if (sidebarOpen) {
        setSidebarOpen(false);
        menuToggleRef.current?.focus();
      }
    }
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, [profileMenuOpen, notificationsOpen, sidebarOpen]);

  const avatar = profileImageUrl ? (
    <img src={profileImageUrl} alt="" className="app-topbar__avatar" />
  ) : (
    <span className="app-topbar__avatar app-topbar__avatar--fallback">
      {initials || "O"}
    </span>
  );

  return (
    <div className={`app-shell${sidebarOpen ? "" : " app-shell--collapsed"}`}>
      <a href="#main-content" className="skip-link">
        Skip to main content
      </a>

      <header className="app-topbar">
        <div className="app-topbar__brand">
          <Link to="/" className="app-topbar__brand-link">
            Farm Manager
          </Link>
          <button
            ref={menuToggleRef}
            type="button"
            className="app-topbar__icon-btn app-topbar__toggle"
            aria-label={sidebarOpen ? "Hide menu" : "Show menu"}
            aria-expanded={sidebarOpen}
            aria-controls="app-sidebar"
            onClick={() => setSidebarOpen((open) => !open)}
          >
            {sidebarOpen ? <MenuCloseIcon /> : <MenuOpenIcon />}
          </button>
        </div>

        <div className="app-topbar__actions">
          <div className="app-topbar__notify-wrap">
            <button
              ref={notificationsButtonRef}
              type="button"
              className="app-topbar__icon-btn"
              aria-label="Notifications"
              aria-expanded={notificationsOpen}
              onClick={() => {
                setNotificationsOpen((open) => !open);
                setProfileMenuOpen(false);
              }}
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

          <div className="app-topbar__profile-wrap" ref={profileMenuRef}>
            <button
              ref={profileButtonRef}
              type="button"
              className="app-topbar__profile"
              aria-label="Open profile menu"
              aria-expanded={profileMenuOpen}
              aria-haspopup="menu"
              onClick={() => {
                setProfileMenuOpen((open) => !open);
                setNotificationsOpen(false);
              }}
            >
              {avatar}
            </button>
            {profileMenuOpen ? (
              <div className="app-topbar__profile-menu" role="menu">
                <div className="app-topbar__profile-menu-head">
                  {avatar}
                  <div className="app-topbar__profile-menu-meta">
                    <strong>{profile?.full_name ?? "Owner"}</strong>
                    <span className="muted">{profile?.email ?? ""}</span>
                  </div>
                </div>
                <Link
                  to="/profile"
                  role="menuitem"
                  className="app-topbar__profile-menu-item"
                  onClick={() => setProfileMenuOpen(false)}
                >
                  <ProfileMenuIcon />
                  Profile
                </Link>
                <button
                  type="button"
                  role="menuitem"
                  className="app-topbar__profile-menu-item"
                  onClick={() => {
                    setProfileMenuOpen(false);
                    void signOut();
                  }}
                >
                  <LogoutMenuIcon />
                  Logout
                </button>
              </div>
            ) : null}
          </div>
        </div>
      </header>

      <div className="app-shell__body">
        {sidebarOpen ? (
          <button
            type="button"
            className="app-shell__scrim"
            aria-label="Close menu"
            onClick={() => setSidebarOpen(false)}
          />
        ) : null}

        <aside
          id="app-sidebar"
          className="app-sidebar"
          aria-label="Main menu"
          hidden={!sidebarOpen}
        >
          <nav className="app-sidebar__nav">
            {NAV_ITEMS.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `app-sidebar__link${isActive ? " app-sidebar__link--active" : ""}`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        </aside>

        <div className="app-shell__main">
          <main id="main-content" className="app-content" tabIndex={-1}>
            <Outlet />
          </main>

          <footer className="app-footer">
            <span>Farm Manager</span>
            <span className="muted">Single-farm record keeping</span>
          </footer>
        </div>
      </div>
    </div>
  );
}
