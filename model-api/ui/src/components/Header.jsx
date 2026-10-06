import { useEffect, useRef, useState } from 'react';
import { getToken, setToken } from '../api.js';
import { SettingsIcon } from './icons.jsx';

function StatusPill({ health, healthError }) {
  const status = health ? 'ok' : healthError ? 'down' : 'checking';
  const label = health ? 'API online' : healthError ? 'API unreachable' : 'Checking\u2026';
  const dotClass = status === 'ok' ? 'bg-success' : status === 'down' ? 'bg-danger' : 'bg-muted';
  return (
    <div
      className="flex items-center gap-2 rounded-full border border-border bg-surface px-3 py-1 text-xs text-muted"
      title={healthError || label}
    >
      <span className={`h-2 w-2 rounded-full ${dotClass}`} />
      <span>{label}</span>
      {health?.default_partition && <span className="text-muted/70">&middot; {health.default_partition}</span>}
    </div>
  );
}

// Top bar: app title, a live health pill (polled by App.jsx), and a
// settings popover holding the optional API bearer token -- tucked away
// here (rather than always-visible, as it used to be) since auth is
// disabled by default on this deployment (see run.sh) and so is rarely
// touched. Token storage itself is unchanged (api.js's getToken/setToken,
// localStorage).
export default function Header({ health, healthError }) {
  const [open, setOpen] = useState(false);
  const [token, setTokenState] = useState(getToken());
  const popoverRef = useRef(null);

  useEffect(() => {
    if (!open) return undefined;
    function handleClickOutside(event) {
      if (popoverRef.current && !popoverRef.current.contains(event.target)) setOpen(false);
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open]);

  function handleTokenChange(event) {
    const value = event.target.value;
    setTokenState(value);
    setToken(value);
  }

  return (
    <header className="flex flex-wrap items-center justify-between gap-3 border-b border-border bg-surface px-5 py-3">
      <div className="flex items-center gap-3">
        <h1 className="text-base font-semibold text-text">model-api</h1>
        <StatusPill health={health} healthError={healthError} />
      </div>
      <div className="relative" ref={popoverRef}>
        <button
          type="button"
          onClick={() => setOpen((value) => !value)}
          className="rounded-md p-2 text-muted hover:bg-surface-2 hover:text-text"
          aria-label="Settings"
          aria-expanded={open}
        >
          <SettingsIcon className="h-4 w-4" />
        </button>
        {open && (
          <div className="absolute right-0 top-full z-20 mt-2 w-72 rounded-lg border border-border bg-surface p-4 shadow-lg">
            <label className="flex flex-col gap-1 text-xs text-muted">
              API token (optional)
              <input
                type="password"
                value={token}
                onChange={handleTokenChange}
                placeholder="leave blank if auth is disabled"
                autoComplete="off"
                className="rounded-md border border-border bg-bg px-2.5 py-1.5 text-sm text-text focus:outline-none focus:ring-2 focus:ring-accent/50"
              />
            </label>
          </div>
        )}
      </div>
    </header>
  );
}
