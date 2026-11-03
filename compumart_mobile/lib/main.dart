import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'screens/home_screen.dart';
import 'screens/warehouse_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const CompuMartApp());
}

class CompuMartApp extends StatefulWidget {
  const CompuMartApp({super.key});

  @override
  State<CompuMartApp> createState() => _CompuMartAppState();
}

class _CompuMartAppState extends State<CompuMartApp> {
  bool _isDark = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDark = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompuMart',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F172A),
          secondary: Color(0xFF0F766E),
          surface: Colors.white,
        ),
        fontFamily: 'SF-Pro',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111318),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF0F766E),
          surface: Color(0xFF1E212A),
        ),
        fontFamily: 'SF-Pro',
        useMaterial3: true,
      ),
      home: MainNavigationShell(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const MainNavigationShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final List<CartItem> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _incrementCartItem(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementCartItem(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
    });
  }

  void _removeCartItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final totalItemsCount = _cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final screens = [
      HomeScreen(
        onAddToCart: _addToCart,
        onNavigateToWarehouse: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        isDark: isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      WarehouseScreen(
        onAddToCart: _addToCart,
        isDark: isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      CartScreen(
        cartItems: _cartItems,
        onIncrement: _incrementCartItem,
        onDecrement: _decrementCartItem,
        onRemove: _removeCartItem,
        onClearCart: _clearCart,
      ),
      SettingsScreen(
        isDark: isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
    ];

    // 1. SCAFFOLD WIDGET
    // Properties: body, bottomNavigationBar, backgroundColor
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // APPLE-STYLE ICON-ONLY FLOATING CLAY DOCK
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(160),
                        offset: const Offset(4, 8),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: const Color(0xFF2D3240).withAlpha(100),
                        offset: const Offset(-2, -2),
                        blurRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFFB4BAC8).withAlpha(110),
                        offset: const Offset(4, 8),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(255),
                        offset: const Offset(-4, -4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconNavItem(
                  index: 0,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  isDark: isDark,
                ),
                _buildIconNavItem(
                  index: 1,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  isDark: isDark,
                ),
                _buildIconNavItem(
                  index: 2,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  isDark: isDark,
                  badgeCount: totalItemsCount,
                ),
                _buildIconNavItem(
                  index: 3,
                  icon: Icons.tune_rounded,
                  activeIcon: Icons.tune_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ICON-ONLY NAVIGATION ITEM (NO TEXT LABELS)
  Widget _buildIconNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isDark,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark ? Colors.black.withAlpha(80) : const Color(0xFFCBD5E1).withAlpha(80),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected
                    ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -7,
                  top: -7,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
