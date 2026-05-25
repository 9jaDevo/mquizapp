import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/core/network/api_config.dart';
import 'package:flutterquiz/core/network/base_repository.dart';
import 'package:flutterquiz/core/network/nestjs_api.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

final class CoinHistoryRemoteDataSource {
  const CoinHistoryRemoteDataSource();

  Future<({int total, List<Map<String, dynamic>> data})> getCoinHistory({
    required String limit,
    required String offset,
  }) async {
    if (ApiMigration.coins) {
      return runNestCall(() async {
        final lim = int.tryParse(limit) ?? 20;
        final off = int.tryParse(offset) ?? 0;
        final page = lim > 0 ? (off ~/ lim) + 1 : 1;
        final data = await NestJsApi.instance.getCoinHistory(page: page, limit: lim);
        return (total: data.length, data: data);
      });
    }
    try {
      final body = <String, String>{
        if (limit.isNotEmpty) limitKey: limit,
        if (offset.isNotEmpty) offsetKey: offset,
      };

      final response = await http.post(
        Uri.parse(getCoinHistoryUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      final total = int.parse(responseJson['total'] as String? ?? '0');
      final data = (responseJson['data'] as List).cast<Map<String, dynamic>>();

      return (total: total, data: data);
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }
}
