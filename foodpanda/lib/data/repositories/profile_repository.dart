import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class ProfileRepository {
  final ApiClient _apiClient = ApiClient();

  // Upload avatar image
  Future<String> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final response = await _apiClient.uploadFile(
      ApiConstants.upload,
      filePath: imageFile.path,
      fileName: fileName,
    );

    if (response.data['success'] == true && response.data['files'] != null) {
      final files = response.data['files'] as List;
      if (files.isNotEmpty) {
        return files.first['url'] as String;
      }
    }
    throw Exception('Failed to upload image');
  }

  // Get current user profile
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    if (response.data['success'] == true && response.data['data'] != null) {
      return UserModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to get profile');
  }

  // Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.updateProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
      },
    );

    if (response.data['success'] == true) {
      if (response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      }
      // Return updated user from profile endpoint if not in response
      return await getProfile();
    }
    throw Exception(response.data['message'] ?? 'Failed to update profile');
  }

  // Get user addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get(ApiConstants.addresses);
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => AddressModel.fromJson(e)).toList();
    }
    return [];
  }

  // Add new address
  Future<AddressModel> addAddress({
    required String label,
    required String address,
    String? detail,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.addresses,
      data: {
        'label': label,
        'address': address,
        'detail': detail,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      },
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return AddressModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to add address');
  }

  // Update address
  Future<AddressModel> updateAddress({
    required String id,
    String? label,
    String? address,
    String? detail,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    final response = await _apiClient.patch(
      '${ApiConstants.addresses}/$id',
      data: {
        if (label != null) 'label': label,
        if (address != null) 'address': address,
        if (detail != null) 'detail': detail,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (isDefault != null) 'is_default': isDefault,
      },
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return AddressModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update address');
  }

  // Delete address
  Future<void> deleteAddress(String id) async {
    final response = await _apiClient.delete('${ApiConstants.addresses}/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete address');
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String id) async {
    final response = await _apiClient.patch(
      '${ApiConstants.addresses}/$id/default',
      data: {'is_default': true},
    );
    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Failed to set default address',
      );
    }
  }

  // Get favorites
  Future<List<dynamic>> getFavorites() async {
    final response = await _apiClient.get(ApiConstants.favorites);
    if (response.data['success'] == true && response.data['data'] != null) {
      return response.data['data'];
    }
    return [];
  }

  // Add to favorites
  Future<void> addToFavorites(String storeId) async {
    final response = await _apiClient.post(
      ApiConstants.favorites,
      data: {'store_id': storeId},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to add to favorites');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String storeId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.favorites}/$storeId',
    );
    if (response.data['success'] != true) {
      throw Exception(
        response.data['message'] ?? 'Failed to remove from favorites',
      );
    }
  }

  // Get notifications
  Future<List<dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      '${ApiConstants.notifications}?page=$page&limit=$limit',
    );
    if (response.data['success'] == true && response.data['data'] != null) {
      return response.data['data'];
    }
    return [];
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    final response = await _apiClient.get(ApiConstants.notificationUnreadCount);
    if (response.data['success'] == true) {
      return response.data['data']?['count'] ?? 0;
    }
    return 0;
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    await _apiClient.patch('${ApiConstants.markNotificationRead}$id/read');
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await _apiClient.post(ApiConstants.markAllNotificationsRead);
  }
}
