import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Electronics', 'Jewelery'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild sliver list when tab changes
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 300) {
      // Swipe Right, go to previous tab
      if (_tabController.index > 0) {
        _tabController.animateTo(_tabController.index - 1);
        setState(() {});
      }
    } else if (details.primaryVelocity! < -300) {
      // Swipe Left, go to next tab
      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AppBloc>().add(FetchInitialData());
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: GestureDetector(
          // Handles horizontal swipe across the *entire* scrollable area
          // without interfering with vertical scroll
          onHorizontalDragEnd: _handleHorizontalSwipe,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              _buildStickyTabBar(context),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: false,
      backgroundColor: Colors.deepOrange,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.deepOrange,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        // Login/Profile action
                        context.read<AppBloc>().add(LoginAndFetchProfile());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging in...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'MEGA DEALS\nUp to 80% Off!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyTabBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 3,
          isScrollable: false,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (index) {
            setState(() {});
          },
        ),
        MediaQuery.of(context).padding.top,
      ),
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.isLoadingProducts && state.allProducts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        List<Product> activeProducts;
        switch (_tabController.index) {
          case 0:
            activeProducts = state.productsTab1;
            break;
          case 1:
            activeProducts = state.productsTab2;
            break;
          case 2:
            activeProducts = state.productsTab3;
            break;
          default:
            activeProducts = state.productsTab1;
        }

        if (activeProducts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No products found.')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = activeProducts[index];
              return _buildProductCard(product);
            }, childCount: activeProducts.length),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(product.image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final double statusBarHeight;

  _StickyTabBarDelegate(this.tabBar, this.statusBarHeight);

  @override
  double get minExtent => tabBar.preferredSize.height + statusBarHeight;

  @override
  double get maxExtent => tabBar.preferredSize.height + statusBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: statusBarHeight),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        statusBarHeight != oldDelegate.statusBarHeight;
  }
}
