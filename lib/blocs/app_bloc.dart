import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/api_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final ApiService apiService;

  AppBloc(this.apiService) : super(const AppState()) {
    on<FetchInitialData>(_onFetchInitialData);
    on<LoginAndFetchProfile>(_onLoginAndFetchProfile);
  }

  Future<void> _onFetchInitialData(
    FetchInitialData event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoadingProducts: true));
    try {
      final products = await apiService.fetchProducts();
      emit(state.copyWith(isLoadingProducts: false, allProducts: products));
    } catch (e) {
      emit(state.copyWith(isLoadingProducts: false));
    }
  }

  Future<void> _onLoginAndFetchProfile(
    LoginAndFetchProfile event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoadingUser: true));
    try {
      await apiService.login('johnd', 'm38rmF\$');
      final user = await apiService.fetchUserProfile(1);
      emit(state.copyWith(isLoadingUser: false, currentUser: user));
    } catch (e) {
      emit(state.copyWith(isLoadingUser: false));
    }
  }
}
