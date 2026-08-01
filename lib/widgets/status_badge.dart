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

  factory StatusBadge.briefStatus(String status) {
    switch (status) {
      case 'submitted':
        return const StatusBadge(label: 'Gönderildi', color: AppTheme.primary);
      case 'offer_sent':
        return const StatusBadge(label: 'Teklif Gönderildi', color: AppTheme.success);
      case 'draft':
      default:
        return const StatusBadge(label: 'Taslak', color: Colors.grey);
    }
  }

  factory StatusBadge.offerStatus(String status) {
    switch (status) {
      case 'accepted':
        return const StatusBadge(label: 'Kabul Edildi', color: AppTheme.success);
      case 'rejected':
        return const StatusBadge(label: 'Reddedildi', color: AppTheme.danger);
      case 'pending':
      default:
        return const StatusBadge(label: 'Bekliyor', color: AppTheme.warning);
    }
  }

  factory StatusBadge.reportStatus(String status) {
    switch (status) {
      case 'reviewed':
        return const StatusBadge(label: 'İncelendi', color: AppTheme.success);
      case 'dismissed':
        return const StatusBadge(label: 'Reddedildi', color: Colors.grey);
      case 'pending':
      default:
        return const StatusBadge(label: 'Bekliyor', color: AppTheme.warning);
    }
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
