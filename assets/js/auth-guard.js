// Authentication Guard - Redirects to account page (login/signup) if not authenticated
// Add this script to any page that requires login
// NOTE: Do NOT add this to account.html, login.html, or signup.html

(function() {
    'use strict';
    
    // Only enforce auth on explicitly protected pages (e.g. checkout)
    const currentPath = window.location.pathname.toLowerCase();
    const protectedPaths = [
        'checkout.html',
        '/checkout',
        '/pages/checkout.html'
    ];

    // Skip if current page is not in protectedPaths
    const isProtected = protectedPaths.some(p => currentPath.includes(p));
    if (!isProtected) {
        return; // allow browsing freely
    }
    
    function redirectToAccount() {
        const isInPages = window.location.pathname.includes('/pages/');
        const accountPath = isInPages ? 'account.html' : 'pages/account.html';
        window.location.href = accountPath;
    }
    
    function checkAuthAndRedirect() {
        // Check if auth.js has loaded
        if (typeof isUserLoggedIn === 'function') {
            // Auth functions are available, check login status
            if (!isUserLoggedIn()) {
                // User not logged in - redirect to account page
                redirectToAccount();
                return;
            }
            // User is logged in - page will show normally
        } else {
            // Auth.js not loaded yet, wait a bit and try again
            setTimeout(checkAuthAndRedirect, 50);
        }
    }
    
    // Quick check via localStorage first (fast path)
    try {
        const authData = localStorage.getItem('compumart_auth');
        if (!authData) {
            redirectToAccount();
            return;
        }
        const auth = JSON.parse(authData);
        if (!auth || !auth.isLoggedIn || !auth.user) {
            redirectToAccount();
            return;
        }
    } catch (e) {
        // Continue with function check
    }
    
    // Start checking
    checkAuthAndRedirect();
    
    // Fallback check after page loads
    window.addEventListener('load', function() {
        if (typeof isUserLoggedIn === 'function' && !isUserLoggedIn()) {
            redirectToAccount();
        }
    });
    
    // Listen for storage changes (in case user logs out in another tab/window)
    window.addEventListener('storage', (e) => {
        if (e.key === 'compumart_auth') {
            if (typeof isUserLoggedIn === 'function' && !isUserLoggedIn()) {
                const isInPages = window.location.pathname.includes('/pages/');
                const accountPath = isInPages ? 'account.html' : 'pages/account.html';
                window.location.replace(accountPath);
            }
        }
    });
})();

