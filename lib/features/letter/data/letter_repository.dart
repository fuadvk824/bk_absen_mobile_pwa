import 'package:bk_absen/core/network/dio_client.dart';
import 'package:bk_absen/model/letter_model.dart';
import 'package:dio/dio.dart';

class LetterRepository {
  Future<List<LetterModel>> fetchLetters() async {
    try {
      final response = await DioClient.dio.get('/myletters');

      final data = response.data['data'] as List;

      return data
          .map((e) => LetterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed get letters');
    }
  }

  Future<String?> markAsRead(int letterId) async {
    try {
      final response = await DioClient.dio.post('/letters/$letterId/read');

      return response.data['pdf_url'] as String?;
    } on DioException catch (e) {

      throw Exception(
        e.response?.data['message'] ?? 'Gagal menandai surat sebagai dibaca',
      );
    }
  }
}