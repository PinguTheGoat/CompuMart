// Shopping Cart Management
let cart = [];

// Helper function to resolve image paths
function getCartImagePath(path) {
    // Check if we're in the pages folder
    if (window.location.pathname.includes('/pages/')) {
        // If path doesn't already start with ../
        if (!path.startsWith('../')) {
            return '../' + path;
        }
        return path;
    }
    // Remove ../ if we're at root
    return path.replace(/^\.\.\//, '');
}

// Load cart from localStorage on page load
document.addEventListener('DOMContentLoaded', () => {
    loadCart();
    updateCartUI();
    setupCartEvents();
});

function setupCartEvents() {
    const cartIcon = document.getElementById('cartIcon');
    const cartSidebar = document.getElementById('cartSidebar');
    const cartClose = document.getElementById('cartClose');
    const cartOverlay = document.getElementById('cartOverlay');
    const checkoutBtn = document.getElementById('checkoutBtn');
    
    if (cartIcon) {
        cartIcon.addEventListener('click', () => {
            openCart();
        });
    }
    
    // Also make the cart count clickable
    const cartCount = document.getElementById('cartCount');
    if (cartCount) {
        cartCount.addEventListener('click', () => {
            openCart();
        });
    }
    
    if (cartClose) {
        cartClose.addEventListener('click', closeCart);
    }
    
    if (cartOverlay) {
        cartOverlay.addEventListener('click', closeCart);
    }
    
    if (checkoutBtn) {
        checkoutBtn.addEventListener('click', () => {
            if (cart.length === 0) return;

            // If auth is available, require login before checkout
            if (typeof isUserLoggedIn === 'function' && typeof getAccountPagePath === 'function' && !isUserLoggedIn()) {
                const goToAccount = confirm('You need an account to checkout. Go to the Account page to log in or register?');
                if (goToAccount) {
                    window.location.href = getAccountPagePath();
                }
                return;
            }

            // Send user to dedicated checkout page
            if (typeof getCheckoutPagePath === 'function') {
                window.location.href = getCheckoutPagePath();
            } else {
                // Fallback: simple message
                alert('Proceeding to checkout...');
            }
        });
    }
}

function openCart() {
    const cartSidebar = document.getElementById('cartSidebar');
    const cartOverlay = document.getElementById('cartOverlay');
    
    if (cartSidebar) {
        cartSidebar.classList.add('active');
    }
    
    if (cartOverlay) {
        cartOverlay.classList.add('active');
    }
    
    document.body.style.overflow = 'hidden';
}

function closeCart() {
    const cartSidebar = document.getElementById('cartSidebar');
    const cartOverlay = document.getElementById('cartOverlay');
    
    if (cartSidebar) {
        cartSidebar.classList.remove('active');
    }
    
    if (cartOverlay) {
        cartOverlay.classList.remove('active');
    }
    
    document.body.style.overflow = '';
}

function addToCart(product, quantity = 1) {
    try {
        console.debug('[cart] addToCart called', { id: product && product.id, quantity });
    } catch (e) {}
    const existingItem = cart.find(item => item.id === product.id);
    
    if (existingItem) {
        existingItem.quantity += quantity;
    } else {
        cart.push({
            id: product.id,
            name: product.name,
            price: product.price,
            image: product.image,
            quantity: quantity
        });
    }
    
    saveCart();
    updateCartUI();
    
    // Show notification
    showCartNotification(`Added ${quantity}x ${product.name} to cart!`);
}

function removeFromCart(productId) {
    cart = cart.filter(item => item.id !== productId);
    saveCart();
    updateCartUI();
}

function updateQuantity(productId, newQuantity) {
    const item = cart.find(item => item.id === productId);
    
    if (item) {
        if (newQuantity <= 0) {
            removeFromCart(productId);
        } else {
            item.quantity = newQuantity;
            saveCart();
            updateCartUI();
        }
    }
}

function clearCart() {
    cart = [];
    saveCart();
    updateCartUI();
    closeCart();
}

function getCartTotal() {
    return cart.reduce((total, item) => total + (item.price * item.quantity), 0);
}

function getCartItemCount() {
    if (!Array.isArray(cart)) return 0;
    return cart.reduce((count, item) => count + (Number(item.quantity) || 0), 0);
}

function updateCartUI() {
    updateCartCount();
    updateCartItems();
    updateCartTotal();
}

function updateCartCount() {
    const cartCount = document.getElementById('cartCount');
    if (cartCount) {
        const count = getCartItemCount();
        try { console.debug('[cart] updateCartCount computed', { count, cart }); } catch (e) {}
        cartCount.textContent = count > 0 ? count : '';
        cartCount.style.display = count > 0 ? 'flex' : 'none';
    }
}

function updateCartItems() {
    const cartItems = document.getElementById('cartItems');
    const cartEmpty = document.getElementById('cartEmpty');
    const cartFooter = document.getElementById('cartFooter');
    
    if (!cartItems) return;
    
    if (cart.length === 0) {
        if (cartEmpty) cartEmpty.style.display = 'block';
        if (cartFooter) cartFooter.style.display = 'none';
        cartItems.innerHTML = '';
        cartItems.appendChild(cartEmpty);
        return;
    }
    
    if (cartEmpty) cartEmpty.style.display = 'none';
    if (cartFooter) cartFooter.style.display = 'block';
    
    cartItems.innerHTML = '';
    
    cart.forEach(item => {
        const cartItem = document.createElement('div');
        cartItem.className = 'cart-item';
        cartItem.innerHTML = `
            <div class="cart-item-image">
                <img src="${getCartImagePath(item.image)}" alt="${item.name}">
            </div>
            <div class="cart-item-info">
                <h4>${item.name}</h4>
                <p class="cart-item-price">$${item.price.toFixed(2)}</p>
                <div class="cart-item-controls">
                    <button class="quantity-btn minus" data-product-id="${item.id}">-</button>
                    <span class="quantity-value">${item.quantity}</span>
                    <button class="quantity-btn plus" data-product-id="${item.id}">+</button>
                </div>
            </div>
            <div class="cart-item-total">
                <p>$${(item.price * item.quantity).toFixed(2)}</p>
                <button class="remove-item-btn" data-product-id="${item.id}">&times;</button>
            </div>
        `;
        
        // Add event listeners
        const minusBtn = cartItem.querySelector('.minus');
        const plusBtn = cartItem.querySelector('.plus');
        const removeBtn = cartItem.querySelector('.remove-item-btn');
        
        minusBtn.addEventListener('click', () => {
            updateQuantity(item.id, item.quantity - 1);
        });
        
        plusBtn.addEventListener('click', () => {
            updateQuantity(item.id, item.quantity + 1);
        });
        
        removeBtn.addEventListener('click', () => {
            removeFromCart(item.id);
        });
        
        cartItems.appendChild(cartItem);
    });
}

function updateCartTotal() {
    const cartTotal = document.getElementById('cartTotal');
    if (cartTotal) {
        cartTotal.textContent = `$${getCartTotal().toFixed(2)}`;
    }
}

function saveCart() {
    localStorage.setItem('compumart_cart', JSON.stringify(cart));
}

function loadCart() {
    const savedCart = localStorage.getItem('compumart_cart');
    if (savedCart) {
        try {
            const parsed = JSON.parse(savedCart);
            // Validate structure: expect an array of items with numeric quantity
            if (Array.isArray(parsed)) {
                const isValid = parsed.every(it => it && (typeof it.id === 'number' || typeof it.id === 'string') && ('quantity' in it) && !Number.isNaN(Number(it.quantity)));
                if (isValid) {
                    cart = parsed.map(it => ({
                        id: it.id,
                        name: it.name || '',
                        price: Number(it.price) || 0,
                        image: it.image || '',
                        quantity: Number(it.quantity) || 0
                    }));
                    try { console.debug('[cart] loaded and normalized cart', cart); } catch (e) {}
                } else {
                    // Corrupt or unexpected data — reset to empty and persist
                    cart = [];
                    saveCart();
                }
            } else {
                cart = [];
                saveCart();
            }
        } catch (e) {
            cart = [];
            saveCart();
        }
    } else {
        cart = [];
    }
    try { console.debug('[cart] loadCart finished, cart length', cart.length); } catch (e) {}
}

function showCartNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'cart-notification';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    // Show notification
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Hide and remove notification
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 2000);
}

