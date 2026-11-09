import { Link } from 'react-router-dom'

export function HomePage() {
  return (
    <div className="panel" style={{ margin: '0 auto' }}>
      <h1>Welcome</h1>
      <p className="lede">
        Manage cows, poultry, crops, inventory, profile, and farm settings from the
        web app.
      </p>
      <div className="form-stack">
        <Link className="btn btn-primary" to="/cows" style={{ textAlign: 'center' }}>
          Manage cows
        </Link>
        <Link className="btn btn-primary" to="/poultry" style={{ textAlign: 'center' }}>
          Manage poultry
        </Link>
        <Link className="btn btn-primary" to="/crops" style={{ textAlign: 'center' }}>
          Manage crops
        </Link>
        <Link className="btn btn-primary" to="/inventory" style={{ textAlign: 'center' }}>
          Manage inventory
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
