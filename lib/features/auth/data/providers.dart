import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'auth_notifier.dart';
import 'user.dart';

// final loginRepoProvider = NotifierProvider<LoginNotifier, LoginState>(
//   LoginNotifier.new,
// );

// class LoginNotifier extends Notifier<LoginState> {
//   @override
//   LoginState build() {
//     return LoginState();
//   }

// class LoginState {
//   final List<User> data;
//   final bool isLoading;
//   final Object? error;
//   final String? errorMessage;

//   LoginState({
//     List<User>? data,
//     this.isLoading = false,
//     this.error,
//     this.errorMessage,
//   }) : data = data ?? [];

//   LoginState copyWith({
//     List<User>? data,
//     User? currentUser,
//     bool? isLoading,
//     Object? error,
//     String? errorMessage,
//   }) {
//     return LoginState(
//       data: data ?? this.data,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       errorMessage: errorMessage,
//     );
//   }
// }

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../shared/utils/api_endpointen.dart';
// import '../../../shared/utils/http_client.dart';
// import 'user.dart';
// import 'auth_notifier.dart';

final loginRepoProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => LoginState();

  Future<bool> sendOtp({required String mobile}) async {
    state = state.copyWith(isLoading: true, error: null, errorMessage: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, tempMobile: mobile);
      print("OTP sent (dummy): 1234");
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
        errorMessage: "Failed to send OTP",
      );
      return false;
    }
  }

  //   Future<bool> verifyOtp({required String otp}) async {
  //     state = state.copyWith(isLoading: true, error: null, errorMessage: null);
  //     try {
  //       print("working");
  //       await Future.delayed(const Duration(seconds: 1));
  //       if (otp != "1234") {
  //         state = state.copyWith(isLoading: false, errorMessage: "Invalid OTP");
  //         return false;
  //       }
  //       final user = User(
  //         userid: 1,
  //         userName: state.tempMobile ?? "unknown",
  //         displayName: "Demo User",
  //         designation: "User",
  //         token: "dummy_token_123",
  //       );
  //       ref.read(authProvider.notifier).login(user);
  //       print("User logged in with mobile: ${state.tempMobile}");
  //       state = state.copyWith(isLoading: false);
  //       return true;
  //     } catch (e) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: e,
  //         errorMessage: "OTP verification failed",
  //       );
  //       return false;
  //     }
  //   }
  // }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, errorMessage: null);
    try {
      await Future.delayed(Duration(seconds: 1));

      final postData = {"username": username, "password": password};
      final dio = ref.read(httpClientProvider);

      var response = await dio.post(ApiEndPoint.login, data: postData);
      //print(response.data);
      if (response.statusCode == HttpStatus.ok) {
        //print(response.data);
        final sucess = response.data["success"];

        state = state.copyWith(isLoading: false);

        if (sucess) {
          print("Login successful entered if else block ${response.data}");
          response.data["username"] = username;
          final user = User.fromJson(response.data);
          //print("Login token : ${user}");

          ref.read(authProvider.notifier).login(user);
          print("User Name : ${user.userName}");
          print("token : ${user.token}");
        }
        return sucess;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.data["msg"],
        );
        return false;
      }
    } catch (e, stack) {
      print("LOGIN ERROR: $e");
      print("STACK TRACE: $stack");

      state = state.copyWith(
        isLoading: false,
        error: e,
        errorMessage: 'Login failed. Please try again.',
      );
      return false;
    }
  }
}

class LoginState {
  final List<User> data;
  final bool isLoading;
  final Object? error;
  final String? errorMessage;
  final String? tempMobile;

  LoginState({
    List<User>? data,
    this.isLoading = false,
    this.error,
    this.errorMessage,
    this.tempMobile,
  }) : data = data ?? [];

  LoginState copyWith({
    List<User>? data,
    bool? isLoading,
    Object? error,
    String? errorMessage,
    String? tempMobile,
  }) {
    return LoginState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      errorMessage: errorMessage,
      tempMobile: tempMobile ?? this.tempMobile,
    );
  }
}
