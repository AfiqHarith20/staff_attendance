import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/admin_announcement_controller/admin_announcement_controller.dart';
import 'package:staff_attendance/apps/models/admin_announcement_model.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class AdminAnnouncementsScreen
    extends GetView<AdminAnnouncementController> {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2.5),
            );
          }
          if (controller.hasError.value) {
            return _ErrorRetry(
              isDark: isDark,
              onRetry: controller.fetchAnnouncements,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAnnouncements,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const AppPageHeader(title: 'Announcements'),
                const SizedBox(height: 12),
                if (controller.announcements.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        'No announcements yet.',
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.4),
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.announcements.map(
                    (a) => _AnnouncementCard(
                      item: a,
                      isDark: isDark,
                      onEdit: () => _openSheet(context, item: a),
                      onDelete: () => _confirmDelete(context, a),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New'),
      ),
    );
  }

  void _openSheet(BuildContext context, {AdminAnnouncementModel? item}) {
    if (item != null) {
      controller.populateForm(item);
    } else {
      controller.resetForm();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnnouncementFormSheet(
        isEdit: item != null,
        item: item,
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminAnnouncementModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: const Text('Delete Announcement'),
        content: Text('Delete "${item.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.delete(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminAnnouncementModel item;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.push_pin_rounded,
                            size: 14, color: AppColors.primary),
                      ),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.summary != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.summary!,
                    style: TextStyle(
                      color: text.withOpacity(0.55),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isPublished
                            ? const Color(0xFF16A34A).withOpacity(0.12)
                            : Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.isPublished ? 'Published' : 'Draft',
                        style: TextStyle(
                          color: item.isPublished
                              ? const Color(0xFF16A34A)
                              : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.category != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.category!.capitalizeFirst ?? item.category!,
                        style: TextStyle(
                            color: text.withOpacity(0.4), fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                color: text.withOpacity(0.4),
              ),
              IconButton(
                onPressed: onDelete,
                icon:
                    const Icon(Icons.delete_outline_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                color: Colors.red.withOpacity(0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementFormSheet extends GetView<AdminAnnouncementController> {
  const _AnnouncementFormSheet({required this.isEdit, this.item});

  final bool isEdit;
  final AdminAnnouncementModel? item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    InputDecoration fieldDecoration(String label) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: text.withOpacity(0.5), fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Announcement' : 'New Announcement',
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: Get.back,
                    child: Text('Cancel',
                        style: TextStyle(color: text.withOpacity(0.4))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.titleController,
                      decoration: fieldDecoration('Title *'),
                      style: TextStyle(color: text),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.summaryController,
                      decoration: fieldDecoration('Summary (optional)'),
                      style: TextStyle(color: text),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.bodyController,
                      decoration: fieldDecoration('Body *'),
                      style: TextStyle(color: text),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedCategory.value,
                          decoration: fieldDecoration('Category'),
                          dropdownColor: sheetBg,
                          style: TextStyle(color: text, fontSize: 14),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('None')),
                            ...AdminAnnouncementController.categories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                          c.capitalizeFirst ?? c),
                                    )),
                          ],
                          onChanged: (v) =>
                              controller.selectedCategory.value = v,
                        )),
                    const SizedBox(height: 12),
                    Obx(() => SwitchListTile(
                          value: controller.isPinned.value,
                          onChanged: (v) => controller.isPinned.value = v,
                          title: Text('Pin announcement',
                              style: TextStyle(color: text, fontSize: 14)),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        )),
                    Obx(() => SwitchListTile(
                          value: controller.publishNow.value,
                          onChanged: (v) =>
                              controller.publishNow.value = v,
                          title: Text('Publish immediately',
                              style: TextStyle(color: text, fontSize: 14)),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        )),
                    const SizedBox(height: 20),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () {
                                  if (isEdit && item != null) {
                                    controller.updateAnnouncement(item!);
                                  } else {
                                    controller.create();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : Text(
                                  isEdit ? 'Save Changes' : 'Publish',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load announcements',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
