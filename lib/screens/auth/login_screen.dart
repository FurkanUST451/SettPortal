import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _controller = Get.put(AuthController());

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sidebarBg,
      body: Center(
        child: Card(
          margin: EdgeInsets.zero,
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(32),
            child: Obx(() {
              final mfaPending = _controller.auth.mfaResolver.value != null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    mfaPending ? 'Doğrulama Kodu' : 'SET Admin Panel',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mfaPending
                        ? 'Authenticator uygulamandaki 6 haneli kodu gir.'
                        : 'Sadece yetkili yönetici hesapları giriş yapabilir.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  if (!mfaPending) ...[
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                    ),
                  ] else ...[
                    TextField(
                      controller: _codeCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, letterSpacing: 6),
                      maxLength: 6,
                      decoration: const InputDecoration(counterText: ''),
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                  Obx(() {
                    final error = _controller.errorText.value;
                    if (error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Obx(
                    () => FilledButton(
                      onPressed: _controller.loading.value ? null : _submit,
                      child: _controller.loading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(mfaPending ? 'Doğrula' : 'Giriş Yap'),
                    ),
                  ),
                  if (mfaPending) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _controller.cancelMfa();
                        _codeCtrl.clear();
                      },
                      child: const Text('Geri Dön'),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_controller.auth.mfaResolver.value != null) {
      _controller.submitMfaCode(_codeCtrl.text);
    } else {
      _controller.submit(_emailCtrl.text, _passwordCtrl.text);
    }
  }
}
