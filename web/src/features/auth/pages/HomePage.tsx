import { Link } from 'react-router-dom'

export function HomePage() {
  return (
    <div className="panel" style={{ margin: '0 auto' }}>
      <h1>Welcome</h1>
      <p className="lede">Manage cows, profile, and farm settings from the web app.</p>
      <div className="form-stack">
        <Link className="btn btn-primary" to="/cows" style={{ textAlign: 'center' }}>
          Manage cows
        </Link>
        <Link className="btn btn-ghost" to="/profile" style={{ textAlign: 'center' }}>
          Go to profile
        </Link>
        <Link className="btn btn-ghost" to="/settings" style={{ textAlign: 'center' }}>
          Farm settings
        </Link>
      </div>
    </div>
  )
}
