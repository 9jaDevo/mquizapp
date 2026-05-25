import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/progress/models/progress_stage_model.dart';

class ProgressRepository {
  ProgressRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<ProgressStage>> fetchStages() async {
    final list = await _api.getProgressStages();
    return list.map(ProgressStage.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchMyProgress() {
    return _api.getMyProgress();
  }
}
