// Helper function to resolve image paths
function getImagePath(path) {
    // Check if we're in the pages folder
    if (window.location.pathname.includes('/pages/')) {
        return '../' + path;
    }
    return path;
}

// Products data (base catalog)
const products = [
    {
        id: 1,
        name: "AMD Ryzen 7 5700X3D Processor",
        price: 138.20,
        image: "public/img/category-1.png",
        category: "cpu",
        description: "High-performance processor with 3D V-Cache technology for exceptional gaming performance."
    },
    {
        id: 2,
        name: "Palit RTX 5090 GameRock OC 32GB",
        price: 5300.00,
        image: "public/img/category-2.png",
        category: "gpu",
        description: "Top-of-the-line graphics card with 32GB VRAM, perfect for 4K gaming and professional work."
    },
    {
        id: 3,
        name: "Corsair Dominator Titanium DDR5 96GB",
        price: 320.00,
        image: "public/img/category-3.png",
        category: "ram",
        description: "Premium DDR5 memory kit with 96GB capacity and titanium heat spreaders."
    },
    {
        id: 4,
        name: "SAMSUNG 980 M.2 PCIe NVMe 1TB SSD",
        price: 215.00,
        image: "public/img/category-4.png",
        category: "ssd",
        description: "Fast NVMe SSD with 1TB storage capacity for lightning-fast boot times and file transfers."
    },
    {
        id: 5,
        name: "Lian Li Edge Series-1000W Full Modular Power",
        price: 279.00,
        image: "public/img/category-5.png",
        category: "powersupply",
        description: "80 Plus Gold certified fully modular power supply with 1000W capacity."
    },
    {
        id: 6,
        name: "GIGABYTE AORUS GeForce RTX 5080 Master ICE 16G Graphics Card",
        price: 1790.00,
        image: "public/img/category-6.png",
        category: "gpu",
        description: "Premium RTX 5080 graphics card with 16GB VRAM and advanced cooling solution."
    },
    {
        id: 7,
        name: "Hyte Y70 Touch Infinite Dual Chamber ATX PC Case",
        price: 501.00,
        image: "public/img/category-7.png",
        category: "case",
        description: "Premium PC case with touch screen display and dual chamber design for optimal airflow."
    },
    {
        id: 8,
        name: "ASUS ROG Astral GeForce RTX5090 Dhahab OC Edition Graphic card",
        price: 5500.00,
        image: "public/img/product-1.png",
        category: "gpu",
        description: "Ultimate flagship graphics card with premium design and extreme overclocking capabilities."
    },
    {
        id: 9,
        name: "Asus Rog Crosshair X870e Extreme Motherboard",
        price: 939.00,
        image: "public/img/product-2.png",
        category: "motherboard",
        description: "High-end motherboard with advanced features for extreme performance and overclocking."
    },
    {
        id: 10,
        name: "AMD Ryzen 9 9950X3D Processor",
        price: 533.00,
        image: "public/img/product-3.png",
        category: "cpu",
        description: "Flagship processor with 3D V-Cache for unparalleled gaming and productivity performance."
    },
    {
        id: 11,
        name: "Benq Zowie Xl2586x+ 24 Full Hd Tn Led 600hz Gaming Monitor",
        price: 1300.00,
        image: "public/img/product-4.png",
        category: "monitor",
        description: "Ultra-high refresh rate gaming monitor with 600Hz for competitive gaming."
    }
];

// Helper function to fetch with timeout
function fetchWithTimeout(url, timeout = 5000) {
    return Promise.race([
        fetch(url),
        new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Fetch timeout')), timeout)
        )
    ]);
}

// Combine base products with database products and custom products
async function getAllProducts() {
    // Try to fetch from database API first
    try {
        // Use the global API_BASE_URL from api-php.js if available
        let apiPath;
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            apiPath = API_BASE_URL + '/products.php';
        } else {
            const inPages = window.location.pathname.includes('/pages/');
            apiPath = inPages ? '../api/products.php' : 'api/products.php';
        }
        
        console.debug('[products.js] Fetching from API:', apiPath);
        
        const response = await fetchWithTimeout(apiPath, 5000);
        console.debug('[products.js] API response status:', response.status);
        
        if (!response.ok) {
            console.warn('[products.js] API returned non-ok status:', response.status, response.statusText);
            throw new Error(`HTTP ${response.status}`);
        }
        
        const dbProducts = await response.json();
        console.debug('[products.js] Successfully fetched', dbProducts.length, 'products from API');
        
        if (!Array.isArray(dbProducts) || dbProducts.length === 0) {
            console.warn('[products.js] API returned empty or non-array response');
            throw new Error('Invalid API response');
        }
        
        // Merge with local products (avoid duplicates)
        const dbProductIds = new Set(dbProducts.map(p => {
            // Convert to number for comparison since DB might return strings
            const id = typeof p.id === 'string' ? parseInt(p.id) : p.id;
            return id > 0 ? id : null;
        }).filter(id => id !== null));
        
        const localProducts = products.filter(p => !dbProductIds.has(p.id));
        
        console.debug('[products.js] Combined', dbProducts.length, 'DB products +', localProducts.length, 'local hardcoded products');
        return [...dbProducts, ...localProducts];
        
    } catch (error) {
        console.error('[products.js] Error fetching products from database:', error.message);
    }
    
    // Fallback: return local products + custom products from localStorage
    console.log('[products.js] Using fallback: local products + custom products');
    try {
        if (typeof loadCustomProducts === 'function') {
            const custom = loadCustomProducts();
            if (Array.isArray(custom) && custom.length > 0) {
                console.debug('[products.js] Adding', custom.length, 'custom products from localStorage');
                return products.concat(custom);
            }
        }
    } catch (e) {
        console.warn('[products.js] Error loading custom products:', e.message);
    }
    
    console.debug('[products.js] Returning', products.length, 'local products');
    return products;
}

// Initialize products on page load
document.addEventListener('DOMContentLoaded', async () => {
    const urlParams = new URLSearchParams(window.location.search);
    const category = urlParams.get('category');
    
    // Load products from database
    await displayProducts(category);
    
    // Add scroll to top functionality
    const scrollToTopBtn = document.getElementById('scrollToTop');
    if (scrollToTopBtn) {
        window.addEventListener('scroll', () => {
            scrollToTopBtn.classList.toggle('show', window.scrollY > 300);
        });
        
        scrollToTopBtn.addEventListener('click', () => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }
});

async function displayProducts(category = null) {
    const productsGrid = document.getElementById('productsGrid');
    if (!productsGrid) {
        console.error('[products.js] productsGrid element not found');
        return;
    }
    
    productsGrid.innerHTML = '<p>Loading products...</p>';
    
    try {
        const allProducts = await getAllProducts();
        console.debug('[products.js] Displaying', allProducts.length, 'total products' + (category ? ' (category: ' + category + ')' : ''));
        
        let filteredProducts = category ? allProducts.filter(p => p.category === category) : allProducts;
        console.debug('[products.js] After filtering:', filteredProducts.length, 'products');
        
        productsGrid.innerHTML = '';
        
        if (filteredProducts.length === 0) {
            productsGrid.innerHTML = '<p>No products found' + (category ? ' in category: ' + category : '') + '.</p>';
            return;
        }
        
        filteredProducts.forEach(product => {
            const productCard = createProductCard(product);
            productsGrid.appendChild(productCard);
        });
        
        console.log('[products.js] Successfully rendered', filteredProducts.length, 'product cards');
    } catch (error) {
        console.error('[products.js] Error displaying products:', error);
        productsGrid.innerHTML = '<p>Error loading products. Please try refreshing the page.</p>';
    }
}

function createProductCard(product) {
    try {
        const card = document.createElement('div');
        card.className = 'product-card';
        
        // Ensure price is a number
        const price = typeof product.price === 'string' ? parseFloat(product.price) : product.price;
        
        card.innerHTML = `
            <div class="product-image-wrapper">
                <img src="${getImagePath(product.image)}" alt="${product.name}" class="product-image">
                <div class="product-overlay">
                    <button class="view-product-btn" data-product-id="${product.id}">View Details</button>
                </div>
            </div>
            <div class="product-info">
                <h4>${product.name}</h4>
                <p class="product-price">$${price.toFixed(2)}</p>
                <button class="add-to-cart-btn" data-product-id="${product.id}">Add to Cart</button>
            </div>
        `;
        
        // Add click event for product details
        const viewBtn = card.querySelector('.view-product-btn');
        if (viewBtn) {
            viewBtn.addEventListener('click', () => showProductModal(product));
        }
        
        // Add click event for add to cart
        const addToCartBtn = card.querySelector('.add-to-cart-btn');
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', () => {
                // Add directly to cart with quantity 1, or show modal for quantity selection
                if (typeof addToCart === 'function') {
                    addToCart(product, 1);
                } else {
                    showProductModal(product);
                }
            });
        }
        
        return card;
    } catch (error) {
        console.error('[products.js] Error creating product card for:', product, error);
        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `<p>Error loading product: ${product.name || 'Unknown'}</p>`;
        return card;
    }
}

function showProductModal(product) {
    const modal = document.getElementById('productModal');
    const modalBody = document.getElementById('modalBody');
    
    if (!modal || !modalBody) return;
    
    try {
        // Ensure price is a number
        const price = typeof product.price === 'string' ? parseFloat(product.price) : product.price;
        
        modalBody.innerHTML = `
            <div class="modal-product-image">
                <img src="${getImagePath(product.image)}" alt="${product.name}">
            </div>
            <div class="modal-product-info">
                <h2>${product.name}</h2>
                <p class="modal-price">$${price.toFixed(2)}</p>
                <p class="modal-description">${product.description}</p>
                <div class="modal-quantity">
                    <label for="modalQuantity">Quantity:</label>
                    <input type="number" id="modalQuantity" min="1" value="1">
                </div>
                <button class="modal-add-cart-btn" data-product-id="${product.id}">Add to Cart</button>
            </div>
        `;
        
        modal.style.display = 'flex';
        
        // Add to cart from modal
        const addBtn = modalBody.querySelector('.modal-add-cart-btn');
        if (addBtn) {
            addBtn.addEventListener('click', () => {
                const quantity = parseInt(document.getElementById('modalQuantity').value) || 1;
                if (typeof addToCart === 'function') {
                    addToCart(product, quantity);
                }
                closeProductModal();
            });
        }
    } catch (error) {
        console.error('[products.js] Error showing product modal:', error);
        modalBody.innerHTML = '<p>Error loading product details. Please try again.</p>';
    }
}

function closeProductModal() {
    const modal = document.getElementById('productModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Close modal when clicking outside
document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('productModal');
    const modalClose = document.getElementById('modalClose');
    
    if (modalClose) {
        modalClose.addEventListener('click', closeProductModal);
    }
    
    if (modal) {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeProductModal();
            }
        });
    }
});

// Function to get product by ID
async function getProductById(id) {
    // Try database first
    try {
        let apiPath;
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            apiPath = API_BASE_URL + '/products.php';
        } else {
            const inPages = window.location.pathname.includes('/pages/');
            apiPath = inPages ? '../api/products.php' : 'api/products.php';
        }
        
        console.debug('[products.js] Fetching product', id, 'from API:', apiPath);
        
        const response = await fetch(`${apiPath}?id=${id}`);
        if (response.ok) {
            const product = await response.json();
            if (product && product.id) {
                console.debug('[products.js] Found product from API:', product.name);
                return product;
            }
        }
    } catch (error) {
        console.warn('[products.js] Error fetching product from database:', error.message);
    }
    
    // Fallback to local products
    const allProducts = await getAllProducts();
    const found = allProducts.find(p => p.id === id);
    if (found) {
        console.debug('[products.js] Found product from local products:', found.name);
    } else {
        console.warn('[products.js] Product', id, 'not found');
    }
    return found;
}

