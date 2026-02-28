part of 'app_bloc.dart';

class AppState extends Equatable {
  final List<Product> allProducts;
  final bool isLoadingProducts;
  final User? currentUser;
  final bool isLoadingUser;

  const AppState({
    this.allProducts = const [],
    this.isLoadingProducts = false,
    this.currentUser,
    this.isLoadingUser = false,
  });

  AppState copyWith({
    List<Product>? allProducts,
    bool? isLoadingProducts,
    User? currentUser,
    bool? isLoadingUser,
  }) {
    return AppState(
      allProducts: allProducts ?? this.allProducts,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      currentUser: currentUser ?? this.currentUser,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
    );
  }

  List<Product> get productsTab1 => allProducts;
  List<Product> get productsTab2 =>
      allProducts.where((p) => p.category == 'electronics').toList();
  List<Product> get productsTab3 =>
      allProducts.where((p) => p.category == 'jewelery').toList();

  @override
  List<Object?> get props => [
    allProducts,
    isLoadingProducts,
    currentUser,
    isLoadingUser,
  ];
}
