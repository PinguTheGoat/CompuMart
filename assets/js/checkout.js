// Checkout page logic

document.addEventListener('DOMContentLoaded', () => {
    // If auth.js is loaded, enforce login
    if (typeof requireLoginForPage === 'function') {
        requireLoginForPage();
    }

    const orderItemsEl = document.getElementById('orderItems');
    const orderTotalEl = document.getElementById('orderTotal');
    const placeOrderBtn = document.getElementById('placeOrderBtn');
    const checkoutForm = document.getElementById('checkoutForm');
    const receiptSection = document.getElementById('receiptSection');
    const receiptMessage = document.getElementById('receiptMessage');
    const receiptDetails = document.getElementById('receiptDetails');

    // Use existing cart.js helpers if available
    if (typeof loadCart === 'function') {
        loadCart();
    }

    let items = typeof cart !== 'undefined' ? cart : [];

    function renderSummary() {
        if (!orderItemsEl) return;

        if (!items || items.length === 0) {
            orderItemsEl.innerHTML = '<p>Your cart is empty.</p>';
            if (placeOrderBtn) {
                placeOrderBtn.disabled = true;
            }
            return;
        }

        orderItemsEl.innerHTML = '';
        let total = 0;

        items.forEach(item => {
            const lineTotal = item.price * item.quantity;
            total += lineTotal;

            const row = document.createElement('div');
            row.className = 'order-item-row';
            row.innerHTML = `
                <span>${item.name} (x${item.quantity})</span>
                <span>$${lineTotal.toFixed(2)}</span>
            `;
            orderItemsEl.appendChild(row);
        });

        if (orderTotalEl) {
            orderTotalEl.textContent = `$${total.toFixed(2)}`;
        }

        if (placeOrderBtn) {
            placeOrderBtn.disabled = false;
        }
    }

    renderSummary();

    if (placeOrderBtn && checkoutForm && receiptSection && receiptMessage && receiptDetails) {
        placeOrderBtn.addEventListener('click', async (e) => {
            e.preventDefault();

            if (!items || items.length === 0) {
                alert('Your cart is empty.');
                return;
            }

            if (!checkoutForm.reportValidity()) {
                return;
            }

            // Get current user ID
            let userId = 'guest';
            if (typeof getCurrentUser === 'function') {
                const user = getCurrentUser();
                if (user) {
                    userId = user.id.toString();
                }
            }

            const formData = new FormData(checkoutForm);
            const fullName = formData.get('fullName');
            const phone = formData.get('phoneNumber');
            const email = formData.get('email');
            const address = formData.get('deliveryAddress');

            // Calculate total
            let total = 0;
            items.forEach(item => {
                total += item.price * item.quantity;
            });

            // Prepare order data
            const orderData = {
                user_id: userId,
                items: items.map(item => ({
                    product_id: item.id,
                    quantity: item.quantity,
                    price: item.price
                })),
                total: total,
                customer_name: fullName,
                customer_phone: phone,
                customer_email: email || '',
                delivery_address: address
            };

            // Disable button during submission
            placeOrderBtn.disabled = true;
            placeOrderBtn.textContent = 'Processing...';

            // Auto-detect API path
            const apiPath = window.location.pathname.includes('/pages/') 
                ? '../api/orders.php' 
                : (window.location.pathname.includes('/Website/') ? 'api/orders.php' : '/Website/api/orders.php');
            
            // Debug logs removed for production - API path and order data
            
            try {
                const response = await fetch(apiPath, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(orderData)
                });

                if (!response.ok) {
                    const errorText = await response.text();
                    console.error('API Error Response:', response.status, errorText);
                    throw new Error(`HTTP ${response.status}: ${errorText}`);
                }

                const result = await response.json();

                if (result.success) {
                    const orderId = result.order_id || 'CM-' + Date.now();
                    receiptMessage.textContent = `Thank you, ${fullName}! Your order (#${orderId}) has been created and saved to the database.`;

                    const detailsHtml = `
                        <h3>Customer Details</h3>
                        <p><strong>Name:</strong> ${fullName}</p>
                        <p><strong>Phone:</strong> ${phone}</p>
                        ${email ? `<p><strong>Email:</strong> ${email}</p>` : ''}
                        <p><strong>Delivery Address:</strong> ${address}</p>
                        <h3>Items</h3>
                        ${orderItemsEl.innerHTML}
                        <h3>Total Paid</h3>
                        <p>${orderTotalEl.textContent}</p>
                    `;
                    receiptDetails.innerHTML = detailsHtml;
                    receiptSection.style.display = 'block';

                    // Clear cart using existing helper if possible
                    if (typeof clearCart === 'function') {
                        clearCart();
                    }

                    items = [];
                    renderSummary();
                } else {
                    alert('Failed to save order: ' + (result.message || 'Unknown error'));
                    placeOrderBtn.disabled = false;
                    placeOrderBtn.textContent = 'Place Order';
                }
            } catch (error) {
                console.error('Error saving order:', error);
                alert('Failed to save order to database. Please check if XAMPP is running and the API is accessible.\n\nError: ' + error.message);
                placeOrderBtn.disabled = false;
                placeOrderBtn.textContent = 'Place Order';
            }
        });
    }
});


