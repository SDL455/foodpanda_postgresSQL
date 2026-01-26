import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger_service.dart';

class AddressController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isGettingLocation = false.obs;
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  // Form controllers
  final labelController = TextEditingController();
  final addressController = TextEditingController();
  final detailController = TextEditingController();

  // Selected address for editing
  final Rxn<AddressModel> selectedAddress = Rxn<AddressModel>();
  final RxBool isDefault = false.obs;

  // Predefined labels
  final List<String> predefinedLabels = ['ເຮືອນ', 'ບ່ອນເຮັດວຽກ', 'ອື່ນໆ'];
  final RxString selectedLabel = 'ເຮືອນ'.obs;

  // Coordinates
  final RxDouble latitude = 17.9757.obs;
  final RxDouble longitude = 102.6331.obs;
  final RxBool hasValidLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  @override
  void onClose() {
    labelController.dispose();
    addressController.dispose();
    detailController.dispose();
    super.onClose();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final data = await _repository.getAddresses();
      addresses.value = data;
    } catch (e) {
      LoggerService.error('Failed to load addresses', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດໂຫຼດທີ່ຢູ່ໄດ້',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAddresses() async {
    await loadAddresses();
  }

  void prepareForAdd() {
    selectedAddress.value = null;
    labelController.clear();
    addressController.clear();
    detailController.clear();
    selectedLabel.value = 'ເຮືອນ';
    isDefault.value = addresses.isEmpty;
    // Reset location
    latitude.value = 17.9757;
    longitude.value = 102.6331;
    hasValidLocation.value = false;
  }

  void prepareForEdit(AddressModel address) {
    selectedAddress.value = address;
    labelController.text = address.label;
    addressController.text = address.address;
    detailController.text = address.detail ?? '';
    selectedLabel.value = predefinedLabels.contains(address.label)
        ? address.label
        : 'ອື່ນໆ';
    isDefault.value = address.isDefault;
    latitude.value = address.latitude;
    longitude.value = address.longitude;
    hasValidLocation.value = true;
  }

  /// ກວດສອບ ແລະ ຂໍ permission ສຳລັບ location
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາເປີດ GPS ໃນອຸປະກອນຂອງທ່ານ',
        isError: true,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Helpers.showSnackbar(
          title: 'ຂໍ້ຜິດພາດ',
          message: 'ກະລຸນາອະນຸຍາດໃຫ້ເຂົ້າເຖິງ location',
          isError: true,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'Location ຖືກປະຕິເສດຖາວອນ. ກະລຸນາເປີດໃນ Settings',
        isError: true,
      );
      return false;
    }

    return true;
  }

  /// ດຶງ location ປັດຈຸບັນຈາກ GPS
  Future<void> getCurrentLocation() async {
    try {
      // ກວດສອບ permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      isGettingLocation.value = true;

      // ດຶງ location ປັດຈຸບັນ
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      hasValidLocation.value = true;

      // ແປງ coordinates ເປັນທີ່ຢູ່
      await _reverseGeocode(position.latitude, position.longitude);

      Helpers.showSnackbar(
        title: 'ສຳເລັດ',
        message: 'ດຶງຕຳແໜ່ງປັດຈຸບັນແລ້ວ',
      );
    } catch (e) {
      LoggerService.error('Failed to get current location', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດດຶງຕຳແໜ່ງໄດ້. ກະລຸນາລອງໃໝ່',
        isError: true,
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  /// ແປງ coordinates ເປັນທີ່ຢູ່ (Reverse Geocoding)
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // ສ້າງທີ່ຢູ່ຈາກຂໍ້ມູນ
        final parts = <String>[];
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          parts.add(place.administrativeArea!);
        }

        if (parts.isNotEmpty) {
          addressController.text = parts.join(', ');
        }
      }
    } catch (e) {
      LoggerService.error('Failed to reverse geocode', e);
      // ບໍ່ສະແດງ error ເພາະ address ສາມາດໃສ່ເອງໄດ້
    }
  }

  Future<void> saveAddress() async {
    // Validation
    final label = selectedLabel.value == 'ອື່ນໆ'
        ? labelController.text.trim()
        : selectedLabel.value;

    if (label.isEmpty) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາເລືອກປະເພດທີ່ຢູ່',
        isError: true,
      );
      return;
    }

    if (addressController.text.trim().isEmpty) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາໃສ່ທີ່ຢູ່',
        isError: true,
      );
      return;
    }

    // ກວດສອບວ່າມີ location ຫຼືບໍ່
    if (!hasValidLocation.value) {
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ກະລຸນາດຶງຕຳແໜ່ງປັດຈຸບັນກ່ອນ',
        isError: true,
      );
      return;
    }

    try {
      isSaving.value = true;

      if (selectedAddress.value != null) {
        // Update existing address
        await _repository.updateAddress(
          id: selectedAddress.value!.id,
          label: label,
          address: addressController.text.trim(),
          detail: detailController.text.trim().isNotEmpty
              ? detailController.text.trim()
              : null,
          latitude: latitude.value,
          longitude: longitude.value,
          isDefault: isDefault.value,
        );
        Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ອັບເດດທີ່ຢູ່ແລ້ວ');
      } else {
        // Add new address
        await _repository.addAddress(
          label: label,
          address: addressController.text.trim(),
          detail: detailController.text.trim().isNotEmpty
              ? detailController.text.trim()
              : null,
          latitude: latitude.value,
          longitude: longitude.value,
          isDefault: isDefault.value,
        );
        Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ເພີ່ມທີ່ຢູ່ແລ້ວ');
      }

      Get.back();
      await loadAddresses();
    } catch (e) {
      LoggerService.error('Failed to save address', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    final confirm = await Helpers.showConfirmDialog(
      title: 'ລຶບທີ່ຢູ່',
      message: 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບທີ່ຢູ່ນີ້?',
    );

    if (!confirm) return;

    try {
      Helpers.showLoading(message: 'ກຳລັງລຶບ...');
      await _repository.deleteAddress(id);
      Helpers.hideLoading();
      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ລຶບທີ່ຢູ່ແລ້ວ');
      await loadAddresses();
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Failed to delete address', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດລຶບທີ່ຢູ່ໄດ້',
        isError: true,
      );
    }
  }

  Future<void> setAsDefault(String id) async {
    try {
      Helpers.showLoading(message: 'ກຳລັງຕັ້ງຄ່າ...');
      await _repository.setDefaultAddress(id);
      Helpers.hideLoading();
      Helpers.showSnackbar(title: 'ສຳເລັດ', message: 'ຕັ້ງເປັນທີ່ຢູ່ຫຼັກແລ້ວ');
      await loadAddresses();
    } catch (e) {
      Helpers.hideLoading();
      LoggerService.error('Failed to set default address', e);
      Helpers.showSnackbar(
        title: 'ຂໍ້ຜິດພາດ',
        message: 'ບໍ່ສາມາດຕັ້ງເປັນທີ່ຢູ່ຫຼັກໄດ້',
        isError: true,
      );
    }
  }
}
