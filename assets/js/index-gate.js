// Auth Gate for Index Page - Redirects to account page (login/signup) if not authenticated
// This runs immediately to prevent page flash

// Index gate removed: allow public browsing of the homepage.
// Previously this script redirected unauthenticated visitors to the account page,
// which prevented browsing. We intentionally make this script a no-op so users
// can explore the site. Authentication is enforced only on protected pages
// (see assets/js/auth-guard.js).

/* No-op index gate */
(() => {})();

