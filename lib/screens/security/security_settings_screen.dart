import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/security_controller.dart';
import '../../core/theme.dart';
import '../../models/admin_info.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SecurityController());

    return AdminScaffold(
      title: 'Güvenlik Ayarları',
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İki Adımlı Doğrulama (2FA)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Google Authenticator, Authy gibi bir uygulamayla hesabına '
                          'ikinci bir doğrulama katmanı ekle. Şifren ele geçirilse bile '
                          'bu kod olmadan kimse giriş yapamaz.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        if (c.pendingSecret.value == null &&
                            c.errorText.value != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              c.errorText.value!,
                              style: const TextStyle(
                                color: AppTheme.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (c.pendingSecret.value != null)
                          _buildEnrollmentStep(c)
                        else if (c.enrolled.value)
                          _buildEnrolledState(c)
                        else
                          _buildNotEnrolledState(c),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAdminsCard(c),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAdminsCard(SecurityController c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Mevcut Adminler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Yenile',
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: c.adminsLoading.value ? null : c.loadAdmins,
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Yeni bir admin eklemek için Kullanıcılar ekranından ilgili '
              'kişiyi bul ve detay sayfasından "Admin Yetkisi Ver" butonuna bas.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (c.adminsError.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  c.adminsError.value!,
                  style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                ),
              ),
            if (c.adminsLoading.value)
              const Center(child: CircularProgressIndicator())
            else if (c.admins.isEmpty)
              const Text('Hiç admin bulunamadı.')
            else
              Column(
                children: c.admins.map((a) {
                  final isSelf = a.uid == c.currentUid;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: Text(a.email ?? a.uid),
                    subtitle: isSelf
                        ? const Text(
                            'Sen',
                            style: TextStyle(color: AppTheme.primary),
                          )
                        : (a.disabled
                              ? const Text(
                                  'Hesap devre dışı',
                                  style: TextStyle(color: AppTheme.danger),
                                )
                              : null),
                    trailing: isSelf
                        ? null
                        : IconButton(
                            tooltip: 'Yetkiyi Kaldır',
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppTheme.danger,
                            ),
                            onPressed: () => _onRevokePressed(c, a),
                          ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRevokePressed(SecurityController c, AdminInfo admin) async {
    final confirmed = await showConfirmActionDialog(
      title: 'Admin Yetkisini Kaldır',
      message:
          '${admin.email ?? admin.uid} artık panele giriş yapamayacak. Emin misin?',
      confirmLabel: 'Kaldır',
      confirmColor: AppTheme.danger,
    );
    if (confirmed != null) await c.revokeAdmin(admin.uid);
  }

  Widget _buildNotEnrolledState(SecurityController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '2FA kurulu değil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: c.busy.value ? null : c.startEnrollment,
          icon: c.busy.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.qr_code),
          label: const Text('2FA Kurulumunu Başlat'),
        ),
      ],
    );
  }

  Widget _buildEnrollmentStep(SecurityController c) {
    final qrUrl = c.qrUrl.value;
    final secret = c.pendingSecret.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Authenticator uygulamanla aşağıdaki QR kodu tara (veya kodu elle gir).',
        ),
        const SizedBox(height: 16),
        if (qrUrl != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(data: qrUrl, size: 200),
            ),
          ),
        if (secret != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Elle giriş için anahtar:',
            style: TextStyle(color: Colors.black54),
          ),
          SelectableText(
            secret.secretKey,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          ),
        ],
        const SizedBox(height: 20),
        const Text('2. Uygulamanın gösterdiği 6 haneli kodu gir:'),
        const SizedBox(height: 8),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '123456',
            counterText: '',
          ),
        ),
        Obx(() {
          final error = c.errorText.value;
          if (error == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              error,
              style: const TextStyle(color: AppTheme.danger, fontSize: 13),
            ),
          );
        }),
        Row(
          children: [
            FilledButton(
              onPressed: c.busy.value
                  ? null
                  : () {
                      c.confirmEnrollment(_codeCtrl.text);
                      _codeCtrl.clear();
                    },
              child: const Text('Onayla'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: c.cancelEnrollment,
              child: const Text('Vazgeç'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnrolledState(SecurityController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.verified_user, color: AppTheme.success, size: 20),
            SizedBox(width: 8),
            Text('2FA aktif', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: c.busy.value ? null : () => _onDisablePressed(c),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('2FA\'yı Kaldır'),
        ),
      ],
    );
  }

  Future<void> _onDisablePressed(SecurityController c) async {
    final confirmed = await showConfirmActionDialog(
      title: '2FA Kaldır',
      message:
          'Bu hesap için ikinci doğrulama katmanı kaldırılacak, sadece şifreyle giriş '
          'yapılabilir hale gelecek. Emin misin?',
      confirmLabel: 'Kaldır',
      confirmColor: AppTheme.danger,
    );
    if (confirmed != null) await c.disable();
  }
}
