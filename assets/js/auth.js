// Simple front-end auth and role management for CompuMart
// NOTE: This is purely client-side (for demo use only).

const AUTH_STORAGE_KEY = 'compumart_auth';

// Clear old localStorage custom products key (we now use database only)
if (localStorage.getItem('compumart_custom_products')) {
    console.log('[AUTH] Clearing old localStorage custom products - using database only now');
    localStorage.removeItem('compumart_custom_products');
}

function getAuthState() {
    try {
        const raw = localStorage.getItem(AUTH_STORAGE_KEY);
        return raw ? JSON.parse(raw) : { isLoggedIn: false, user: null };
    } catch (e) {
        return { isLoggedIn: false, user: null };
    }
}

function saveAuthState(state) {
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(state));
}

function isUserLoggedIn() {
    const auth = getAuthState();
    return !!auth.isLoggedIn && !!auth.user;
}

function getCurrentUser() {
    const auth = getAuthState();
    return auth.user || null;
}

function logoutUser() {
    saveAuthState({ isLoggedIn: false, user: null });
    // Clear any client-side cart when logging out to avoid leaking cart between users
    try {
        localStorage.removeItem('compumart_cart');
        if (typeof clearCart === 'function') clearCart();
    } catch (e) {}
}

async function registerUser({ name, email, password }) {
    // Resolve API path: prefer global API_BASE_URL from `api-php.js` when available
    let apiPath;
    
    if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
        apiPath = API_BASE_URL + '/auth.php';
    } else {
        const pathname = window.location.pathname;
        if (pathname.includes('/pages/')) {
            apiPath = '../api/auth.php';
        } else if (pathname.includes('/Website/')) {
            apiPath = 'api/auth.php';
        } else {
            apiPath = '/Website/api/auth.php';
        }
    }
    
    try {
        console.debug('[auth] register fetch URL:', apiPath);
        const response = await fetch(apiPath, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'register',
                name: name,
                email: email,
                password: password
            })
        });
        if (!response.ok) {
            let errorText = '';
            try { errorText = await response.text(); } catch (e) { errorText = response.statusText || String(e); }
            console.error('API Error Response:', response.status, errorText);
            return { success: false, message: errorText || `HTTP ${response.status}` };
        }

        let result;
        try {
            result = await response.json();
        } catch (e) {
            const txt = await response.text().catch(() => '');
            console.error('Invalid JSON response from register:', e, txt);
            return { success: false, message: 'Invalid server response' };
        }

        if (result && result.success) {
            // Save auth state to localStorage for session management
            saveAuthState({
                isLoggedIn: true,
                user: result.user
            });
            // Clear any existing client-side cart when a (new) user logs in
            try {
                localStorage.removeItem('compumart_cart');
                if (typeof clearCart === 'function') clearCart();
            } catch (e) {}
            return { success: true, user: result.user };
        } else {
            return { success: false, message: result.message || 'Registration failed.' };
        }
    } catch (error) {
        console.error('API registration error:', error);
        alert('Failed to connect to server. Please check if XAMPP is running and the API is accessible.\n\nError: ' + error.message);
        return { success: false, message: 'Failed to connect to server: ' + error.message };
    }
}

async function loginUser({ email, password }) {
    // Resolve API path: prefer global API_BASE_URL from `api-php.js` when available
    let apiPath;
    
    if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
        apiPath = API_BASE_URL + '/auth.php';
    } else {
        const pathname = window.location.pathname;
        if (pathname.includes('/pages/')) {
            apiPath = '../api/auth.php';
        } else if (pathname.includes('/Website/')) {
            apiPath = 'api/auth.php';
        } else {
            apiPath = '/Website/api/auth.php';
        }
    }
    
    try {
        console.debug('[auth] login fetch URL:', apiPath);
        const response = await fetch(apiPath, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'login',
                email: email,
                password: password
            })
        });
        if (!response.ok) {
            let errorText = '';
            try { errorText = await response.text(); } catch (e) { errorText = response.statusText || String(e); }
            console.error('API Error Response:', response.status, errorText);
            return { success: false, message: errorText || `HTTP ${response.status}` };
        }

        let result;
        try {
            result = await response.json();
        } catch (e) {
            const txt = await response.text().catch(() => '');
            console.error('Invalid JSON response from login:', e, txt);
            return { success: false, message: 'Invalid server response' };
        }

        if (result && result.success) {
            // Save auth state to localStorage for session management
            saveAuthState({
                isLoggedIn: true,
                user: result.user
            });
            // Clear any existing client-side cart when a (new) user logs in
            try {
                localStorage.removeItem('compumart_cart');
                if (typeof clearCart === 'function') clearCart();
            } catch (e) {}
            return { success: true, user: result.user };
        } else {
            return { success: false, message: result.message || 'Login failed.' };
        }
    } catch (error) {
        console.error('API login error:', error);
        alert('Failed to connect to server. Please check if XAMPP is running and the API is accessible.\n\nError: ' + error.message);
        return { success: false, message: 'Failed to connect to server: ' + error.message };
    }
}

function isCurrentUserAdmin() {
    const user = getCurrentUser();
    return !!user && user.role === 'admin';
}

// Helper to build correct path to account page (from root or /pages/)
function getAccountPagePath() {
    const inPages = window.location.pathname.includes('/pages/');
    return inPages ? 'account.html' : 'pages/account.html';
}

// Helper to build correct path to checkout page
function getCheckoutPagePath() {
    const inPages = window.location.pathname.includes('/pages/');
    return inPages ? 'checkout.html' : 'pages/checkout.html';
}

// Enforce auth on protected pages (like checkout)
function requireLoginForPage() {
    if (!isUserLoggedIn()) {
        const accountPath = getAccountPagePath();
        window.location.href = accountPath + '?redirect=' + encodeURIComponent(window.location.pathname);
    }
}

// Account page wiring
document.addEventListener('DOMContentLoaded', async () => {
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const logoutBtn = document.getElementById('logoutBtn');
    const navLogout = document.getElementById('navLogout');
    const accountStatus = document.getElementById('accountStatus');
    const accountUserName = document.getElementById('accountUserName');
    const accountTitle = document.getElementById('accountTitle');
    const accountActions = document.getElementById('accountActions');
    const authFormsSection = document.getElementById('authFormsSection');
    const adminPanel = document.getElementById('adminPanel');
    const adminProductsList = document.getElementById('adminProductsList');

    const isLoggedIn = isUserLoggedIn();

    // Show/hide login/signup forms based on auth status
    if (authFormsSection) {
        authFormsSection.style.display = isLoggedIn ? 'none' : 'block';
    }

    // Show/hide navbar logout link on all pages
    if (navLogout) {
        navLogout.style.display = isLoggedIn ? 'inline-block' : 'none';
    }

    // Update basic account UI (if present)
    if (accountStatus && accountUserName) {
        if (isLoggedIn) {
            const user = getCurrentUser();
            if (accountTitle) accountTitle.textContent = 'My Account';
            accountStatus.textContent = 'Logged in as';
            accountUserName.textContent = user.name + (user.role === 'admin' ? ' (Admin)' : '');
            if (accountActions) {
                accountActions.innerHTML = '';
                if (logoutBtn) logoutBtn.style.display = 'inline-block';
            }
        } else {
            if (accountTitle) accountTitle.textContent = 'Login or Sign Up';
            accountStatus.textContent = 'Please login or create an account to continue.';
            accountUserName.textContent = '';
            if (accountActions) {
                accountActions.innerHTML = '<p>Choose an option below to get started.</p>';
            }
            if (logoutBtn) logoutBtn.style.display = 'none';
        }
    }

    if (adminPanel) {
        adminPanel.style.display = isCurrentUserAdmin() ? 'block' : 'none';
    }

    // Render admin products list if present and user is admin
    if (adminProductsList && isCurrentUserAdmin()) {
        await renderAdminProductsList(adminProductsList);
    }

    // Handle logout button click
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            logoutUser();
            // Redirect to index page to show login gate
            const isInPages = window.location.pathname.includes('/pages/');
            const indexPath = isInPages ? '../index.html' : 'index.html';
            window.location.href = indexPath;
        });
    }

    // Handle navbar logout link click (works on all pages)
    if (navLogout) {
        navLogout.addEventListener('click', (e) => {
            e.preventDefault();
            logoutUser();
            // Redirect to index page
            const isInPages = window.location.pathname.includes('/pages/');
            const indexPath = isInPages ? '../index.html' : 'index.html';
            window.location.href = indexPath;
        });
    }

    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = loginForm.querySelector('input[name="loginEmail"]').value.trim();
            const password = loginForm.querySelector('input[name="loginPassword"]').value.trim();

            if (!email || !password) return;

            const result = await loginUser({ email, password });
            if (!result.success) {
                alert(result.message);
                return;
            }

            const params = new URLSearchParams(window.location.search);
            const redirect = params.get('redirect');
            if (redirect) {
                window.location.href = redirect;
            } else {
                // Redirect to index.html after successful login
                const isInPages = window.location.pathname.includes('/pages/');
                const indexPath = isInPages ? '../index.html' : 'index.html';
                window.location.href = indexPath;
            }
        });
    }

    if (registerForm) {
        registerForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const name = registerForm.querySelector('input[name="registerName"]').value.trim();
            const email = registerForm.querySelector('input[name="registerEmail"]').value.trim();
            const password = registerForm.querySelector('input[name="registerPassword"]').value.trim();

            if (!name || !email || !password) return;

            const result = await registerUser({ name, email, password });
            if (!result.success) {
                alert(result.message);
                return;
            }

            alert('Account created! You are now logged in.');
            // Redirect to index.html after successful signup
            const isInPages = window.location.pathname.includes('/pages/');
            const indexPath = isInPages ? '../index.html' : 'index.html';
            window.location.href = indexPath;
        });
    }

    // Admin product creation wiring
    const adminProductForm = document.getElementById('adminProductForm');
    if (adminProductForm) {
        let isSubmittingProduct = false;
        adminProductForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            // Prevent double submission
            if (isSubmittingProduct) {
                alert('Please wait, product is being saved...');
                return;
            }
            
            if (!isCurrentUserAdmin()) {
                alert('Only admins can add products.');
                return;
            }

            const name = adminProductForm.querySelector('input[name="productName"]').value.trim();
            const priceValue = adminProductForm.querySelector('input[name="productPrice"]').value.trim();
            const image = adminProductForm.querySelector('input[name="productImage"]').value.trim();
            const category = adminProductForm.querySelector('select[name="productCategory"]').value;
            const description = adminProductForm.querySelector('textarea[name="productDescription"]').value.trim();

            if (!name || !priceValue || !category) {
                alert('Please fill in at least name, price, and category.');
                return;
            }

            const price = parseFloat(priceValue);
            if (Number.isNaN(price) || price <= 0) {
                alert('Please enter a valid price.');
                return;
            }

            // Try to save to database via API first
            const apiPath = window.location.pathname.includes('/pages/') 
                ? '../api/products.php' 
                : (window.location.pathname.includes('/Website/') ? 'api/products.php' : '/Website/api/products.php');
            
            isSubmittingProduct = true;
            console.log('[AUTH] Adding product via API:', { name, price, category, apiPath });
            try {
                const response = await fetch(apiPath, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        name: name,
                        price: price,
                        image: image || 'public/img/product-1.png',
                        category: category,
                        description: description || 'Custom product added by admin.',
                        stock: 0
                    })
                });

                console.log('[AUTH] API response status:', response.status, response.statusText);
                
                const result = await response.json();
                console.log('[AUTH] API response body:', result);
                
                if (!response.ok) {
                    throw new Error(`API returned ${response.status}: ${result.error || result.message || 'Unknown error'}`);
                }
                
                if (result.success || result.id) {
                    console.log('[AUTH] SUCCESS - Product saved to database with ID:', result.id);
                    adminProductForm.reset();
                    alert('Product added! ID: ' + result.id);
                    
                    if (adminProductsList) {
                        console.log('[AUTH] Updating admin products list...');
                        await renderAdminProductsList(adminProductsList);
                    }
                    
                    // Refresh product display
                    if (typeof displayProducts === 'function') {
                        console.log('[AUTH] Refreshing main products display...');
                        displayProducts();
                    }
                } else {
                    throw new Error(result.error || 'Failed to save product - no ID returned');
                }
            } catch (error) {
                console.error('[AUTH] API save FAILED:', error);
                alert('Error saving product to database: ' + error.message);
            } finally {
                isSubmittingProduct = false;
            }
        });
    }
});

// Custom products helpers (shared with products.js)
const CUSTOM_PRODUCTS_KEY = 'compumart_custom_products';

function loadCustomProducts() {
    try {
        const raw = localStorage.getItem(CUSTOM_PRODUCTS_KEY);
        return raw ? JSON.parse(raw) : [];
    } catch (e) {
        return [];
    }
}

function saveCustomProducts(products) {
    localStorage.setItem(CUSTOM_PRODUCTS_KEY, JSON.stringify(products));
}

// Render list of custom products for admin with delete buttons
async function renderAdminProductsList(container) {
    try {
        // Fetch all products from database
        let apiPath = '../api/products.php';
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            apiPath = API_BASE_URL + '/products.php';
        } else if (window.location.pathname.includes('/pages/')) {
            apiPath = '../api/products.php';
        } else {
            apiPath = 'api/products.php';
        }
        
        console.log('[AUTH] renderAdminProductsList: Fetching from', apiPath);
        const response = await fetch(apiPath);
        
        if (!response.ok) {
            throw new Error(`API returned ${response.status}: ${response.statusText}`);
        }
        
        const allProducts = await response.json();
        console.log('[AUTH] renderAdminProductsList: Fetched', allProducts.length, 'total products');
        
        if (!Array.isArray(allProducts)) {
            throw new Error('API did not return an array');
        }
        
        // Filter to only show custom products (ID > 11)
        const customProducts = allProducts.filter(p => {
            const id = typeof p.id === 'string' ? parseInt(p.id) : p.id;
            return id > 11;
        });
        
        console.log('[AUTH] renderAdminProductsList: Found', customProducts.length, 'custom products (ID > 11)');

        if (!customProducts.length) {
            container.innerHTML = '<p style="font-size: 14px; color: #777;">No custom products yet.</p>';
            return;
        }

        const listHtml = customProducts.map(p => `
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                <div>
                    <strong>${p.name}</strong>
                    <span style="font-size:12px; color:#777;"> - $${parseFloat(p.price).toFixed(2)} (${p.category}) [ID: ${p.id}]</span>
                </div>
                <button class="btn" data-delete-product-id="${p.id}" style="padding:4px 10px; font-size:12px; background:#e74c3c; color:#fff;">Delete</button>
            </div>
        `).join('');

        container.innerHTML = `<h3 style="margin-bottom:10px;">Custom Products</h3>${listHtml}`;

        container.querySelectorAll('[data-delete-product-id]').forEach(btn => {
            btn.addEventListener('click', async () => {
                const id = Number(btn.getAttribute('data-delete-product-id'));
                console.log('[AUTH] Delete button clicked for product ID:', id);
                
                // Determine API path
                let apiPath = '../api/products.php';
                if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
                    apiPath = API_BASE_URL + '/products.php';
                }
                
                try {
                    // Call API to delete from database
                    console.log('[AUTH] Attempting DELETE to API:', apiPath, 'for ID:', id);
                    const response = await fetch(apiPath, {
                        method: 'DELETE',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ id: id })
                    });
                    
                    console.log('[AUTH] DELETE response status:', response.status);
                    if (!response.ok) {
                        const errorData = await response.json();
                        console.error('[AUTH] API delete error:', response.status, errorData);
                    } else {
                        const result = await response.json();
                        console.log('[AUTH] DELETE successful:', result);
                    }
                    
                    alert('Product deleted successfully.');
                    
                    // Refresh admin list
                    renderAdminProductsList(container);
                    
                    // Refresh main products display
                    console.log('[AUTH] Calling displayProducts() to refresh main grid');
                    if (typeof displayProducts === 'function') {
                        displayProducts();
                    }
                } catch (error) {
                    console.error('[AUTH] Delete product error:', error);
                    alert('Error deleting product: ' + error.message);
                }
            });
        });
    } catch (error) {
        console.error('[AUTH] Error loading custom products:', error);
        container.innerHTML = '<p style="font-size: 14px; color: #c0392b;">Error loading custom products</p>';
    }
}


