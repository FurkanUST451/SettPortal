import 'package:flutter/material.dart';

import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.projectStatus(String status) {
    switch (status) {
      case 'active':
        return StatusBadge(label: 'Devam Ediyor', color: AppTheme.primary);
      case 'completed':
        return StatusBadge(label: 'Tamamlandı', color: AppTheme.success);
      case 'cancelled':
        return StatusBadge(label: 'İptal Edildi', color: AppTheme.danger);
      case 'pending':
      default:
        return const StatusBadge(label: 'Bekliyor', color: AppTheme.warning);
    }
  }

  factory StatusBadge.role(String role) {
    return StatusBadge(
      label: role == 'freelancer' ? 'Freelancer' : 'Client',
      color: role == 'freelancer' ? const Color(0xFF6C3483) : AppTheme.primary,
    );
  }

  factory StatusBadge.banned(bool banned) {
    return banned
        ? const StatusBadge(label: 'Yasaklı', color: AppTheme.danger)
        : const StatusBadge(label: 'Aktif', color: AppTheme.success);
  }

  factory StatusBadge.flagged(bool flagged) {
    return flagged
        ? const StatusBadge(label: 'Flagli', color: AppTheme.danger)
        : const StatusBadge(label: 'Normal', color: AppTheme.success);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
