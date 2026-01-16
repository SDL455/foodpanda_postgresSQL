import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/storage_service.dart';

class AuthRepository {
  final AuthProvider _authProvider = AuthProvider();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _authProvider.login(
      email: email,
      password: password,
    );

    // Response format: { success: true, data: { token, user }, message }
    final data = response['data'] ?? response;

    // Save tokens
    if (data['token'] != null) {
      await StorageService.setToken(data['token']);
    }
    if (data['refresh_token'] != null) {
      await StorageService.setRefreshToken(data['refresh_token']);
    }

    // Save user data
    final user = UserModel.fromJson(data['user']);
    await StorageService.setUserData(user.toJson());
    await StorageService.setIsLoggedIn(true);

    return user;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _authProvider.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    // Response format: { success: true, data: { token, user }, message }
    final data = response['data'] ?? response;

    // Save tokens
    if (data['token'] != null) {
      await StorageService.setToken(data['token']);
    }
    if (data['refresh_token'] != null) {
      await StorageService.setRefreshToken(data['refresh_token']);
    }

    // Save user data
    final user = UserModel.fromJson(data['user']);
    await StorageService.setUserData(user.toJson());
    await StorageService.setIsLoggedIn(true);

    return user;
  }

  Future<UserModel> googleSignIn({required String idToken}) async {
    final response = await _authProvider.googleSignIn(idToken: idToken);

    // Response format: { success: true, data: { token, user/customer }, message }
    final data = response['data'] ?? response;

    // Save tokens
    if (data['token'] != null) {
      await StorageService.setToken(data['token']);
    }
    if (data['refresh_token'] != null) {
      await StorageService.setRefreshToken(data['refresh_token']);
    }

    // Save user data (can be 'user' or 'customer')
    final userData = data['user'] ?? data['customer'];
    final user = UserModel.fromJson(userData);
    await StorageService.setUserData(user.toJson());
    await StorageService.setIsLoggedIn(true);

    return user;
  }

  // Rider Login
  Future<void> riderLogin({
    required String email,
    required String password,
  }) async {
    final response = await _authProvider.riderLogin(
      email: email,
      password: password,
    );

    // Response format: { success: true, data: { token, rider }, message }
    final data = response['data'] ?? response;

    // Save tokens
    if (data['token'] != null) {
      await StorageService.setToken(data['token']);
    }

    // Save rider data
    if (data['rider'] != null) {
      await StorageService.setUserData(data['rider']);
    }
    await StorageService.setIsLoggedIn(true);
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } finally {
      await StorageService.clearAuthData();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    await _authProvider.forgotPassword(email: email);
  }

  bool get isLoggedIn => StorageService.isLoggedIn;

  UserModel? get currentUser {
    final userData = StorageService.userData;
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
