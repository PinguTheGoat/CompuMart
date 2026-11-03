import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/clay_container.dart';
import '../widgets/theme_swipe_button.dart';
import 'product_detail_screen.dart';

class WarehouseScreen extends StatefulWidget {
  final Function(Product) onAddToCart;
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const WarehouseScreen({
    super.key,
    required this.onAddToCart,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'CPU',
    'GPU',
    'RAM',
    'SSD',
    'Case',
    'Motherboard',
    'Power Supply',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;

    final products = ProductService.getProducts(
      category: selectedCategory,
      searchQuery: searchQuery,
    );

    // 1. SCAFFOLD WIDGET
    // Properties: appBar, body, backgroundColor
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      // 2. APPBAR WIDGET
      // Properties: title, backgroundColor, elevation, centerTitle, actions
      appBar: AppBar(
        title: Text(
          'Warehouse',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.6,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Center(
              child: ThemeSwipeButton(
                isDark: isDark,
                onToggle: widget.onToggleTheme,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        // 3. COLUMN WIDGET
        // Properties: crossAxisAlignment, mainAxisAlignment, children
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH BOX WITH CLAY EMBOSSING
            // 4. CONTAINER WIDGET
            ClayContainer(
              borderRadius: 20,
              surfaceColor: cardBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: searchController,
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
                style: TextStyle(color: textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search processors, graphics, memory...',
                  hintStyle: TextStyle(color: mutedColor, fontSize: 13),
                  // 5. ICONS WIDGET
                  prefixIcon: Icon(Icons.search_rounded, color: mutedColor, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 16, color: mutedColor),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // HORIZONTAL CATEGORY PILLS
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A))
                            : cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A)).withAlpha(60),
                                  offset: const Offset(1, 3),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        // 6. TEXT WIDGET
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                : mutedColor,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // STATUS & COUNT ROW
            // 7. ROW WIDGET
            // Properties: mainAxisAlignment, crossAxisAlignment, children
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedCategory Hardware (${products.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withAlpha(isDark ? 50 : 25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Direct Inventory',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // PRODUCT CLAY GRID
            products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 44, color: mutedColor),
                          const SizedBox(height: 10),
                          Text(
                            'No hardware components match your search.',
                            style: TextStyle(color: mutedColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.64,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductClayCard(context, product, isDark, cardBg, textColor, mutedColor);
                    },
                  ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildProductClayCard(
    BuildContext context,
    Product product,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color mutedColor,
  ) {
    return ClayContainer(
      borderRadius: 22,
      surfaceColor: cardBg,
      padding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              onAddToCart: () => widget.onAddToCart(product),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              // 8. IMAGE WIDGET
              // Properties: image, fit, width, height
              child: Center(
                child: Image.asset(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      // 9. PLACEHOLDER WIDGET
                      // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                      Placeholder(
                    fallbackHeight: 80,
                    fallbackWidth: 80,
                    color: mutedColor,
                    strokeWidth: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            product.category.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 3),

          Text(
            product.name,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Price & Add Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.5,
                ),
              ),
              // 10. ELEVATEDBUTTON WIDGET
              // Properties: onPressed, style, child
              SizedBox(
                width: 32,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.name} to cart'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: isDark ? const Color(0xFF1E212A) : const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
