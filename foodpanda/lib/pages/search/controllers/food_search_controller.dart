import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger_service.dart';
import '../../../data/models/food_model.dart';
import '../../../data/repositories/restaurant_repository.dart';

class FoodSearchController extends GetxController {
  final RestaurantRepository _repository = RestaurantRepository();

  final TextEditingController textController = TextEditingController();

  final RxString query = ''.obs;
  final RxList<FoodModel> results = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;

  late final Worker _debouncer;

  @override
  void onInit() {
    super.onInit();

    final initialQuery = (Get.arguments is String) ? (Get.arguments as String) : '';
    if (initialQuery.trim().isNotEmpty) {
      textController.text = initialQuery;
      query.value = initialQuery;
    }

    _debouncer = debounce<String>(
      query,
      (value) => _performSearch(value),
      time: const Duration(milliseconds: 350),
    );
  }

  @override
  void onClose() {
    _debouncer.dispose();
    textController.dispose();
    super.onClose();
  }

  void setQuery(String value) {
    query.value = value;
  }

  void clear() {
    textController.clear();
    query.value = '';
    results.clear();
  }

  Future<void> refresh() async {
    await _performSearch(query.value);
  }

  Future<void> _performSearch(String value) async {
    final q = value.trim();
    if (q.isEmpty) {
      results.clear();
      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.getFoods(search: q, limit: 30);
      results.value = response.foods;
    } catch (e) {
      LoggerService.error('Food search error', e);
      // Intentionally silent here; UI already handles empty state gracefully.
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

