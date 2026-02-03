import '../api/api_client.dart';
import '../api/patient_api.dart';
import 'models.dart';

class TreatmentPlansRepository {
  final PatientApi api;

  TreatmentPlansRepository(this.api);

  Future<List<PlanSummary>> listPlans(int userId) async {
    final json = await api.listPlanos(userId);

    Object? v = json['planos'] ?? json['data'] ?? json['items'];
    if (v is Map) {
      final m = v.cast<String, dynamic>();
      v = m['planos'] ?? m['items'] ?? m['data'];
    }

    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => PlanSummary.fromJson(e.cast<String, dynamic>()))
          .where((p) => p.idTratamento != 0)
          .toList(growable: false);
    }

    // Fallback: scan first-level values for a list.
    for (final value in json.values) {
      if (value is List) {
        final out = value
            .whereType<Map>()
            .map((e) => PlanSummary.fromJson(e.cast<String, dynamic>()))
            .where((p) => p.idTratamento != 0)
            .toList(growable: false);
        if (out.isNotEmpty) return out;
      }
    }

    return const <PlanSummary>[];
  }

  Future<PlanDetail> getPlanDetail(int userId, int planId) async {
    final json = await api.getPlano(userId, planId);
    return PlanDetail.fromJson(json);
  }

  Future<ApiBinaryResponse> downloadPlanPdf(int userId, int planId) {
    return api.downloadPlanoPdf(userId, planId);
  }
}
