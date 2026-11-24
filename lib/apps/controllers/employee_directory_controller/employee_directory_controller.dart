import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/models/employee_summary_model.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
import 'package:staff_attendance/widgets/app_toast.dart';

class EmployeeDirectoryController extends GetxController {
  final employees = <EmployeeSummaryModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final searchQuery = ''.obs;
  final selectedDept = Rxn<String>();

  final searchController = TextEditingController();
  Timer? _debounce;

  int _currentPage = 1;
  bool _hasMore = true;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees(reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // Department filtering is server-side (sent as query param); only apply
  // the search query locally for instant feedback between debounced requests.
  List<EmployeeSummaryModel> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return employees.toList();
    return employees.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          (e.employeeNo?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> fetchEmployees({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      employees.clear();
    }
    if (!_hasMore) return;

    try {
      if (_currentPage == 1) {
        isLoading(true);
        hasError(false);
      } else {
        isLoadingMore(true);
      }

      final params = <String, dynamic>{
        'page': _currentPage,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedDept.value != null) 'department': selectedDept.value,
      };

      final res = await ApiClient.instance.get(
        ApiList.adminEmployees,
        queryParameters: params,
      );

      final meta = res.data['meta'] as Map<String, dynamic>? ?? {};
      final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .map((e) => EmployeeSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      employees.addAll(list);
      _hasMore = _currentPage < lastPage;
      _currentPage++;
    } on DioException catch (e) {
      hasError(true);
      AppToast.failed('Failed', ApiClient.extractError(e, fallback: 'Could not load employees.'));
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void onSearch(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchEmployees(reset: true);
    });
  }

  void filterByDept(String? dept) {
    selectedDept.value = dept;
    fetchEmployees(reset: true);
  }
}
