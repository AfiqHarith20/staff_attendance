import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/controllers/document_upload_controller/document_upload_controller.dart';
import 'package:staff_attendance/apps/models/document_model.dart';
import 'package:staff_attendance/widgets/form_widget.dart';

class DocumentUploadScreen extends GetView<DocumentUploadController> {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            appBar(isDark: isDark, title: 'Upload Document'),
            const SizedBox(height: 12),
            _UploadHero(isDark: isDark),
            const SizedBox(height: 16),
            formSectionCard(
              isDark: isDark,
              child: _TypeSelector(isDark: isDark),
            ),
            const SizedBox(height: 16),
            formSectionCard(
              isDark: isDark,
              child: _SelectedFileCard(isDark: isDark),
            ),
            const SizedBox(height: 16),
            formSectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionLabel(label: 'Note', isDark: isDark),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller.noteController,
                    minLines: 4,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a short note for HR or your manager',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF185FA5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            noteCard(
              isDark: isDark,
              lines: const [
                'Upload clear MCs, receipts, or supporting files for faster review.',
                'Accepted formats should stay readable and under the allowed file size.',
                'Add a short note if the file needs context for HR or your manager.',
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final error = controller.uploadError.value;
              if (error.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isUploading.value
                  ? null
                  : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: controller.isUploading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Upload document',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadHero extends GetView<DocumentUploadController> {
  final bool isDark;
  const _UploadHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF123F6B), Color(0xFF0F172A)]
              : const [Color(0xFF185FA5), Color(0xFF4DA3E8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF185FA5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Upload MCs, leave proofs, or supporting files in one place.',
                  style: TextStyle(
                    color: Color(0xFFE8FFF0),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends GetView<DocumentUploadController> {
  final bool isDark;
  const _TypeSelector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(label: 'Document type', isDark: isDark),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DocumentType.values.map((type) {
              final active = controller.selectedType.value == type;
              return GestureDetector(
                onTap: () => controller.selectedType(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF185FA5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF185FA5)
                          : isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    controller.typeLabel(type),
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SelectedFileCard extends GetView<DocumentUploadController> {
  final bool isDark;
  const _SelectedFileCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.selectedFile.value;
      final hasFile = file != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label: 'Selected file', isDark: isDark),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile
                  ? const Color(
                      0xFF16A34A,
                    ).withValues(alpha: isDark ? 0.14 : 0.10)
                  : isDark
                  ? const Color(0xFF0F2742)
                  : const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasFile
                    ? const Color(0xFF16A34A).withValues(alpha: 0.28)
                    : const Color(0xFF185FA5).withValues(alpha: 0.28),
                width: 1.4,
              ),
            ),
            child: hasFile
                ? Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF16A34A,
                          ).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.fileSize(file),
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFBFDBFE)
                                    : const Color(0xFF4B5563),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: controller.pickFile,
                        child: const Text('Replace'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF185FA5,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          size: 28,
                          color: Color(0xFF185FA5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No file selected yet',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PDF, JPG, or PNG up to 5 MB.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: controller.pickFile,
                        icon: const Icon(Icons.attach_file_rounded, size: 18),
                        label: const Text('Choose file'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF185FA5),
                          side: const BorderSide(color: Color(0xFF185FA5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );
    });
  }
}
