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

    // Save tokens
    if (response['token'] != null) {
      await StorageService.setToken(response['token']);
    }
    if (response['refresh_token'] != null) {
      await StorageService.setRefreshToken(response['refresh_token']);
    }

    // Save user data
    final user = UserModel.fromJson(response['user']);
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

    // Save tokens
    if (response['token'] != null) {
      await StorageService.setToken(response['token']);
    }
    if (response['refresh_token'] != null) {
      await StorageService.setRefreshToken(response['refresh_token']);
    }

    // Save user data
    final user = UserModel.fromJson(response['user']);
    await StorageService.setUserData(user.toJson());
    await StorageService.setIsLoggedIn(true);

    return user;
  }

  Future<UserModel> googleSignIn({required String idToken}) async {
    final response = await _authProvider.googleSignIn(idToken: idToken);

    // Save tokens
    if (response['token'] != null) {
      await StorageService.setToken(response['token']);
    }
    if (response['refresh_token'] != null) {
      await StorageService.setRefreshToken(response['refresh_token']);
    }

    // Save user data
    final user = UserModel.fromJson(response['user']);
    await StorageService.setUserData(user.toJson());
    await StorageService.setIsLoggedIn(true);

    return user;
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
