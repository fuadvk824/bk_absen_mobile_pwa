import 'dart:typed_data';
import 'package:bk_absen/model/leave_category_model.dart';
import 'package:dio/dio.dart';
import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/leave_model.dart';

class LeaveRepository {
  Future<LeaveResponse> fetchLeaves() async {
    try {
      final res = await DioClient.dio.get('/leaves');

      return LeaveResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal mengambil data leave",
      );
    }
  }

  Future<List<LeaveCategoryModel>> fetchCategories() async {
    try {
      final res = await DioClient.dio.get('/leave-categories');
      final data = res.data['data'] as List;

      return data.map((e) => LeaveCategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal ambil kategori");
    }
  }

  Future<String> submitLeave({
    required int leaveCategoryId,
    required String startDate,
    required String endDate,
    required String reason,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "leave_categories_id": leaveCategoryId,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,

        if (fileBytes != null)
          "file": MultipartFile.fromBytes(
            fileBytes,
            filename: fileName ?? "upload.jpg",
          ),
      });

      final res = await DioClient.dio.post('/leaves', data: formData);
      return res.data['message'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal submit leave");
    }
  }
}
