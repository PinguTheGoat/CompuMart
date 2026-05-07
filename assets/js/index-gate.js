// Auth Gate for Index Page - Redirects to account page (login/signup) if not authenticated
// This runs immediately to prevent page flash

(function() {
    'use strict';
    
    let redirectAttempted = false;
    
    function redirectToAccount() {
        if (redirectAttempted) return;
        redirectAttempted = true;
        window.location.href = 'pages/account.html';
    }
    
    // Quick check: if we can immediately determine user is not logged in, redirect right away
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
        // Error reading localStorage - proceed with function check
    }
    
    // Wait for auth.js to load and check
    function checkAuth() {
        if (redirectAttempted) return;
        
        if (typeof isUserLoggedIn === 'function') {
            if (!isUserLoggedIn()) {
                redirectToAccount();
            }
            // If logged in, do nothing - page will show normally
        } else {
            // Auth.js not loaded yet, try again
            setTimeout(checkAuth, 50);
        }
    }
    
    // Start checking
    checkAuth();
    
    // Fallback check after page loads
    window.addEventListener('load', function() {
        if (redirectAttempted) return;
        if (typeof isUserLoggedIn === 'function' && !isUserLoggedIn()) {
            redirectToAccount();
        }
    });
    
    // Listen for storage changes
    window.addEventListener('storage', (e) => {
        if (e.key === 'compumart_auth' && typeof isUserLoggedIn === 'function' && !isUserLoggedIn()) {
            redirectToAccount();
        }
    });
})();

