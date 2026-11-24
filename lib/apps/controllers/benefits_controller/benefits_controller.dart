import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/apps/models/benefit_model.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class BenefitsController extends GetxController {
  final benefits = <BenefitModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final selectedCategory = 'All'.obs;

  List<String> get categories {
    final values = benefits.map((b) => b.category).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<BenefitModel> get filtered {
    if (selectedCategory.value == 'All') return benefits;
    return benefits
        .where((b) => b.category == selectedCategory.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBenefits();
  }

  Future<void> fetchBenefits() async {
    try {
      isLoading(true);
      hasError(false);
      final response = await ApiClient.instance.get(ApiList.benefits);
      final data =
          response.data['data'] as Map<String, dynamic>? ?? {};

      final leaveList = (data['leave'] as List? ?? const [])
          .map((e) => BenefitModel.fromLeaveJson(e as Map<String, dynamic>))
          .toList();

      final insuranceList = (data['insurance'] as List? ?? const [])
          .map((e) =>
              BenefitModel.fromInsuranceJson(e as Map<String, dynamic>))
          .toList();

      benefits.assignAll([...leaveList, ...insuranceList]);
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed(
        'Failed to load',
        ApiClient.extractError(e, fallback: 'Could not fetch benefits.'),
      );
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void setCategory(String category) => selectedCategory(category);
}
