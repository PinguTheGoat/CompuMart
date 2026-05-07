// PHP API Service for CompuMart (XAMPP)
// This file handles all API calls to the PHP backend

// Auto-detect API base URL based on current location
function getAPIBaseURL() {
    const path = window.location.pathname;
    if (path.includes('/pages/')) {
        return '../api';
    } else if (path.includes('/Website/')) {
        return 'api';
    } else {
        return '/Website/api';
    }
}

const API_BASE_URL = getAPIBaseURL();

// ==================== PRODUCTS API ====================

/**
 * Fetch all products from the database
 * @param {string} category - Optional category filter
 * @returns {Promise<Array>} Array of products
 */
async function fetchProducts(category = null) {
    try {
        let url = `${API_BASE_URL}/products.php`;
        if (category) {
            url += `?category=${encodeURIComponent(category)}`;
        }
        
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const products = await response.json();
        return products;
    } catch (error) {
        console.error('Error fetching products:', error);
        // Fallback to local products if API fails
        return getLocalProducts();
    }
}

/**
 * Fetch a single product by ID
 * @param {number} productId - Product ID
 * @returns {Promise<Object>} Product object
 */
async function fetchProduct(productId) {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php?id=${productId}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Error fetching product:', error);
        return null;
    }
}

// ==================== CART API ====================

/**
 * Get current user ID (stored in localStorage)
 * In production, this would come from PHP session
 */
function getUserId() {
    let userId = localStorage.getItem('compumart_user_id');
    if (!userId) {
        userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        localStorage.setItem('compumart_user_id', userId);
    }
    return userId;
}

/**
 * Add product to cart
 * @param {number} productId - Product ID
 * @param {number} quantity - Quantity to add
 * @returns {Promise<boolean>} Success status
 */
async function addToCartAPI(productId, quantity = 1) {
    try {
        const userId = getUserId();
        
        const response = await fetch(`${API_BASE_URL}/cart.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userId: userId,
                productId: productId,
                quantity: quantity
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        return result.success || false;
    } catch (error) {
        console.error('Error adding to cart:', error);
        return false;
    }
}

/**
 * Fetch user's cart from database
 * @returns {Promise<Array>} Array of cart items
 */
async function fetchCart() {
    try {
        const userId = getUserId();
        const response = await fetch(`${API_BASE_URL}/cart.php?userId=${encodeURIComponent(userId)}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Error fetching cart:', error);
        return [];
    }
}

/**
 * Update cart item quantity
 * @param {number} productId - Product ID
 * @param {number} quantity - New quantity
 * @returns {Promise<boolean>} Success status
 */
async function updateCartQuantity(productId, quantity) {
    try {
        const userId = getUserId();
        
        const response = await fetch(`${API_BASE_URL}/cart.php`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userId: userId,
                productId: productId,
                quantity: quantity
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        return result.success || false;
    } catch (error) {
        console.error('Error updating cart:', error);
        return false;
    }
}

/**
 * Remove item from cart
 * @param {number} productId - Product ID
 * @returns {Promise<boolean>} Success status
 */
async function removeFromCartAPI(productId) {
    try {
        const userId = getUserId();
        
        const response = await fetch(`${API_BASE_URL}/cart.php`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userId: userId,
                productId: productId
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        return result.success || false;
    } catch (error) {
        console.error('Error removing from cart:', error);
        return false;
    }
}

/**
 * Get cart item count
 * @returns {Promise<number>} Number of items in cart
 */
async function getCartCount() {
    try {
        const userId = getUserId();
        const response = await fetch(`${API_BASE_URL}/cart.php?userId=${encodeURIComponent(userId)}&action=count`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        return result.count || 0;
    } catch (error) {
        console.error('Error fetching cart count:', error);
        return 0;
    }
}

// ==================== FALLBACK: LOCAL PRODUCTS ====================

/**
 * Get local products as fallback when API is unavailable
 * Note: This relies on products.js being loaded before this file
 */
function getLocalProducts() {
    // Check if products array exists from products.js
    if (typeof products !== 'undefined' && Array.isArray(products)) {
        return Promise.resolve(products);
    }
    // Return empty array if products.js hasn't loaded yet
    return Promise.resolve([]);
}

// ==================== CONFIGURATION ====================

/**
 * Check if PHP API is available
 * @returns {Promise<boolean>} True if API is available
 */
async function checkAPIAvailability() {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php`);
        return response.ok;
    } catch (error) {
        return false;
    }
}

// Note: Functions are available globally for use across the application

