import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'ການເຊື່ອມຕໍ່ໝົດເວລາ';
        break;
      case DioExceptionType.sendTimeout:
        message = 'ການສົ່ງຂໍ້ມູນໝົດເວລາ';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'ການຮັບຂໍ້ມູນໝົດເວລາ';
        break;
      case DioExceptionType.badCertificate:
        message = 'ໃບຢັ້ງຢືນບໍ່ຖືກຕ້ອງ';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'ຄຳຂໍຖືກຍົກເລີກ';
        break;
      case DioExceptionType.connectionError:
        message = 'ບໍ່ສາມາດເຊື່ອມຕໍ່ກັບເຊີບເວີໄດ້';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'ເກີດຂໍ້ຜິດພາດທີ່ບໍ່ຮູ້ຈັກ';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return 'ເກີດຂໍ້ຜິດພາດ';

    switch (response.statusCode) {
      case 400:
        return response.data?['message'] ?? 'ຄຳຂໍບໍ່ຖືກຕ້ອງ';
      case 401:
        return 'ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່';
      case 403:
        return 'ທ່ານບໍ່ມີສິດເຂົ້າເຖິງ';
      case 404:
        return 'ບໍ່ພົບຂໍ້ມູນ';
      case 409:
        return response.data?['message'] ?? 'ຂໍ້ມູນຊ້ຳກັນ';
      case 422:
        return response.data?['message'] ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ';
      case 500:
        return 'ເກີດຂໍ້ຜິດພາດຈາກເຊີບເວີ';
      case 502:
        return 'ເຊີບເວີບໍ່ພ້ອມໃຫ້ບໍລິການ';
      case 503:
        return 'ບໍລິການບໍ່ພ້ອມໃຊ້ງານຊົ່ວຄາວ';
      default:
        return 'ເກີດຂໍ້ຜິດພາດ (${response.statusCode})';
    }
  }

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'ບໍ່ມີການເຊື່ອມຕໍ່ອິນເຕີເນັດ']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'ກະລຸນາເຂົ້າສູ່ລະບົບໃໝ່']);

  @override
  String toString() => message;
}
