# Website - E-Commerce Platform

A PHP-based e-commerce website with user authentication, product management, shopping cart, and order processing functionality.

## Project Structure

```
website/
├── index.html                 # Landing page
├── index.php                  # Main PHP entry point
├── database.php              # Database configuration and helper functions
│
├── api/                      # Backend API endpoints
│   ├── auth.php             # User authentication (login/signup)
│   ├── cart.php             # Shopping cart management
│   ├── config.php           # API configuration
│   ├── database_setup.php   # Database initialization and schema
│   ├── orders.php           # Order processing
│   ├── products.php         # Product catalog management
│   └── test.php             # Testing utilities
│
├── assets/                  # Frontend assets
│   ├── css/
│   │   └── style.css       # Main stylesheet
│   └── js/
│       ├── api-php.js      # API communication layer
│       ├── auth-guard.js   # Authentication middleware
│       ├── auth.js         # Authentication logic
│       ├── cart.js         # Shopping cart functionality
│       ├── checkout.js     # Checkout process
│       ├── index-gate.js   # Main page routing/gating
│       ├── products.js     # Product display and filtering
│       └── script.js       # General utilities and initialization
│
├── pages/                   # HTML page templates
│   ├── about.html
│   ├── account.html
│   ├── checkout.html
│   ├── contact.html
│   ├── login.html
│   ├── products.html
│   └── signup.html
│
└── public/                  # Public assets
    └── img/
        └── site.webmanifest
```

## Features

- **User Authentication**: Login and signup functionality with secure password handling
- **Product Catalog**: Browse and search products
- **Shopping Cart**: Add/remove items, manage quantities
- **Checkout Process**: Complete purchase workflow
- **Order Management**: Track and manage customer orders
- **User Accounts**: Manage user profiles and account settings

## Technology Stack

- **Backend**: PHP
- **Frontend**: HTML, CSS, JavaScript
- **Server**: XAMPP (Apache + MySQL/MariaDB)
- **Database**: MySQL/MariaDB

## Setup Instructions

### Prerequisites
- XAMPP installed and running
- PHP 7.0 or higher
- MySQL/MariaDB database

### Installation

1. Place the project in your XAMPP `htdocs` directory:
   ```
   c:\xampp\htdocs\website
   ```

2. Initialize the database by running the database setup:
   - Access `api/database_setup.php` through your browser or command line
   - This will create necessary tables and schema

3. Configure database connection in `api/config.php` if needed

4. Access the website:
   ```
   http://localhost/website/
   ```

## API Endpoints

### Authentication
- `api/auth.php` - Handle user login and registration

### Products
- `api/products.php` - Retrieve and manage product catalog

### Cart
- `api/cart.php` - Manage shopping cart operations

### Orders
- `api/orders.php` - Process and track orders

## File Descriptions

### Core Files
- **index.php** - Main application entry point
- **database.php** - Database connection and utility functions

### API Files
- **api/config.php** - Application configuration and constants
- **api/database_setup.php** - Database schema and initialization
- **api/test.php** - Testing and debugging utilities

### Frontend Scripts
- **auth.js** - Handles user authentication flows
- **api-php.js** - API communication wrapper
- **cart.js** - Shopping cart management logic
- **checkout.js** - Checkout form and validation
- **products.js** - Product listing and filtering
- **auth-guard.js** - Route protection and authorization
- **script.js** - General utilities and initialization

## Development Notes

- Authentication state is likely managed via sessions or tokens
- API responses should be validated in frontend before processing
- Database queries should use prepared statements to prevent SQL injection
- Ensure HTTPS is enabled in production for security

## License

[Specify your license here]

## Support

For issues or questions, please contact the development team.
