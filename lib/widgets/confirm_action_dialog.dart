import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows a confirmation dialog before a destructive action; if [requireReason]
/// is true, an admin must type a short reason (recorded in the audit log by
/// the Cloud Function that performs the action). Returns the reason string on
/// confirm, or null if cancelled.
Future<String?> showConfirmActionDialog({
  required String title,
  required String message,
  bool requireReason = false,
  String confirmLabel = 'Onayla',
  Color? confirmColor,
}) async {
  final reasonController = TextEditingController();
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (requireReason) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Gerekçe',
                  hintText: 'Bu işlemin nedenini kısaca yazın',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: confirmColor != null
              ? FilledButton.styleFrom(backgroundColor: confirmColor)
              : null,
          onPressed: () => Get.back(result: true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (result != true) return null;
  return requireReason ? reasonController.text.trim() : '';
}
