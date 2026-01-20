import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/category_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/utils/storage_service.dart';

class HomeController extends GetxController {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  // Search controller
  final searchController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<RestaurantModel> popularRestaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> nearbyRestaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> searchResults = <RestaurantModel>[].obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString currentAddress = 'ກຳລັງຊອກຫາທີ່ຢູ່...'.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();

  @override
  void onInit() {
    super.onInit();
    _initLocation();
    _loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentPosition.value = position;

      // Load saved address or use default
      final savedAddress = StorageService.selectedAddress;
      if (savedAddress != null) {
        currentAddress.value = savedAddress['address'] ?? 'ທີ່ຢູ່ບໍ່ລະບຸ';
      }
    } catch (e) {
      LoggerService.error('Location error', e);
      currentAddress.value = 'ບໍ່ສາມາດຊອກຫາທີ່ຢູ່ໄດ້';
    }
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;

      // Load popular stores
      final popularData = await _restaurantRepository.getPopularStores(
        limit: 10,
      );
      popularRestaurants.value = popularData;

      // Load nearby stores
      if (currentPosition.value != null) {
        final nearbyData = await _restaurantRepository.getNearbyStores(
          latitude: currentPosition.value!.latitude,
          longitude: currentPosition.value!.longitude,
          limit: 20,
        );
        nearbyRestaurants.value = nearbyData;
      } else {
        // If no location, just load all stores
        final result = await _restaurantRepository.getStores(limit: 20);
        nearbyRestaurants.value = result.stores;
      }
    } catch (e) {
      LoggerService.error('Load data error', e);
      Helpers.showSnackbar(
        title: 'ເກີດຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  void selectCategory(String categoryId) {
    if (selectedCategoryId.value == categoryId) {
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = categoryId;
    }
    // Filter or reload based on category
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      searchQuery.value = query;
      final result = await _restaurantRepository.searchStores(query: query);
      searchResults.value = result.stores;
    } catch (e) {
      LoggerService.error('Search error', e);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }
}
