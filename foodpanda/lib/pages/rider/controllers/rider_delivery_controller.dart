import 'package:get/get.dart';

enum DeliveryStatus { pending, accepted, pickedUp, delivering, delivered }

class DeliveryItem {
  final String id;
  final String orderNo;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double customerLat;
  final double customerLng;
  final String storeName;
  final String storeAddress;
  final double storeLat;
  final double storeLng;
  final int totalAmount;
  final int deliveryFee;
  final DeliveryStatus status;
  final DateTime createdAt;
  final double? distance;
  final int? estimatedTime;

  DeliveryItem({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLat,
    required this.customerLng,
    required this.storeName,
    required this.storeAddress,
    required this.storeLat,
    required this.storeLng,
    required this.totalAmount,
    required this.deliveryFee,
    required this.status,
    required this.createdAt,
    this.distance,
    this.estimatedTime,
  });
}

class RiderDeliveryController extends GetxController {
  final RxList<DeliveryItem> availableDeliveries = <DeliveryItem>[].obs;
  final RxList<DeliveryItem> activeDeliveries = <DeliveryItem>[].obs;
  final RxList<DeliveryItem> completedDeliveries = <DeliveryItem>[].obs;
  final Rxn<DeliveryItem> currentDelivery = Rxn<DeliveryItem>();

  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveries();
  }

  Future<void> loadDeliveries() async {
    isLoading.value = true;
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      availableDeliveries.value = [
        DeliveryItem(
          id: '1',
          orderNo: 'FP001234',
          customerName: 'ທ້າວ ສົມສັກ',
          customerPhone: '020 9999 8888',
          customerAddress: 'ບ້ານ ໂພນສະຫວ່າງ, ນະຄອນຫຼວງວຽງຈັນ',
          customerLat: 17.9757,
          customerLng: 102.6331,
          storeName: 'ຮ້ານອາຫານລາວ',
          storeAddress: 'ບ້ານ ໂພນໄຊ',
          storeLat: 17.9657,
          storeLng: 102.6231,
          totalAmount: 85000,
          deliveryFee: 15000,
          status: DeliveryStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          distance: 2.5,
          estimatedTime: 15,
        ),
        DeliveryItem(
          id: '2',
          orderNo: 'FP001235',
          customerName: 'ນາງ ມະນີ',
          customerPhone: '020 8888 7777',
          customerAddress: 'ບ້ານ ສີສະເກດ, ນະຄອນຫຼວງວຽງຈັນ',
          customerLat: 17.9857,
          customerLng: 102.6431,
          storeName: 'KFC',
          storeAddress: 'ບ້ານ ທົ່ງຂັນຄຳ',
          storeLat: 17.9557,
          storeLng: 102.6131,
          totalAmount: 120000,
          deliveryFee: 20000,
          status: DeliveryStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          distance: 3.8,
          estimatedTime: 20,
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptDelivery(DeliveryItem delivery) async {
    isLoading.value = true;
    try {
      // TODO: Call API
      await Future.delayed(const Duration(milliseconds: 500));

      availableDeliveries.remove(delivery);
      final accepted = DeliveryItem(
        id: delivery.id,
        orderNo: delivery.orderNo,
        customerName: delivery.customerName,
        customerPhone: delivery.customerPhone,
        customerAddress: delivery.customerAddress,
        customerLat: delivery.customerLat,
        customerLng: delivery.customerLng,
        storeName: delivery.storeName,
        storeAddress: delivery.storeAddress,
        storeLat: delivery.storeLat,
        storeLng: delivery.storeLng,
        totalAmount: delivery.totalAmount,
        deliveryFee: delivery.deliveryFee,
        status: DeliveryStatus.accepted,
        createdAt: delivery.createdAt,
        distance: delivery.distance,
        estimatedTime: delivery.estimatedTime,
      );
      activeDeliveries.add(accepted);
      currentDelivery.value = accepted;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeliveryStatus(DeliveryStatus newStatus) async {
    if (currentDelivery.value == null) return;

    isLoading.value = true;
    try {
      // TODO: Call API
      await Future.delayed(const Duration(milliseconds: 500));

      final delivery = currentDelivery.value!;
      final updated = DeliveryItem(
        id: delivery.id,
        orderNo: delivery.orderNo,
        customerName: delivery.customerName,
        customerPhone: delivery.customerPhone,
        customerAddress: delivery.customerAddress,
        customerLat: delivery.customerLat,
        customerLng: delivery.customerLng,
        storeName: delivery.storeName,
        storeAddress: delivery.storeAddress,
        storeLat: delivery.storeLat,
        storeLng: delivery.storeLng,
        totalAmount: delivery.totalAmount,
        deliveryFee: delivery.deliveryFee,
        status: newStatus,
        createdAt: delivery.createdAt,
        distance: delivery.distance,
        estimatedTime: delivery.estimatedTime,
      );

      if (newStatus == DeliveryStatus.delivered) {
        activeDeliveries.removeWhere((d) => d.id == delivery.id);
        completedDeliveries.insert(0, updated);
        currentDelivery.value = null;
      } else {
        final index = activeDeliveries.indexWhere((d) => d.id == delivery.id);
        if (index != -1) {
          activeDeliveries[index] = updated;
        }
        currentDelivery.value = updated;
      }
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'ລໍຖ້າຮັບ';
      case DeliveryStatus.accepted:
        return 'ຮັບແລ້ວ';
      case DeliveryStatus.pickedUp:
        return 'ຮັບອາຫານແລ້ວ';
      case DeliveryStatus.delivering:
        return 'ກຳລັງສົ່ງ';
      case DeliveryStatus.delivered:
        return 'ສົ່ງສຳເລັດ';
    }
  }
}
