import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../../../core/token_storage.dart';
import '../../../shared/utils/token_storage.dart';
//import '../data/login_repository.dart';
import 'user.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {

  @override
  AuthState build() {
    //state = AuthState(status: AuthStatus.loading);
    loadToken();
    return AuthState(status: AuthStatus.loading, user: null);
  }

  // Expose a stream of auth changes for go_router to listen to
  final StreamController<void> _authChanges = StreamController.broadcast();
  Stream<void> get authChanges => _authChanges.stream;

  Future<void> loadToken() async {
    final user = await TokenStorage.getUser();
    if (user != null) {
      final userMap = Map<String, dynamic>.from(user);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: User.fromJson(userMap),
      );
      _authChanges.add(null);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated, user: null);
    }
  }


  Future<void> login(User user) async {
    await TokenStorage.saveUser(user.toJson());
    state = AuthState(status: AuthStatus.authenticated, user: user);
    _authChanges.add(null);
  }

  Future<void> logout() async {
    await TokenStorage.clearUser();
    state = AuthState(status: AuthStatus.unauthenticated, user: null);
    _authChanges.add(null);
  }

  void updateCartCount(int count) {
  if (state.user == null) return;

  state = state.copyWith(
    user: state.user!.copyWith(cartCount: count),
  );
}

}

class AuthState {
  //final bool isAuthenticated;
  final AuthStatus status;
  User? user;

  AuthState({required this.status, this.user});

  AuthState copyWith({AuthStatus? status, User? user}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user);
}
