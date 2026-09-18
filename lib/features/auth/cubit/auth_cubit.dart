import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await repository.login(email, password);
      emit(state.copyWith(isLoading: false, apiKey: response.apiKey));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await repository.register(email, password);
      emit(state.copyWith(isLoading: false, apiKey: response.apiKey));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}