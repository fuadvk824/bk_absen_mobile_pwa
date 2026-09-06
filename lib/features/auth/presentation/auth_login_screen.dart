import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();

  bool isObscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    return null;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final errorMessage = await ref
        .read(authProvider.notifier)
        .login(email.text.trim(), password.text);

    if (!mounted) return;

    if (errorMessage != null) {
      ToastHelper.error(context, title: 'Login gagal', message: errorMessage);
      return;
    }

    ToastHelper.success(
      context,
      title: 'Login berhasil',
      message: 'Selamat datang kembali',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: AppColors.dark.withValues(alpha: .05),
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bisa Absen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                     Text(
                      'Login ke akun absen kamu',
                      style: TextStyle(color: AppColors.tertiary),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: email,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: password,
                      validator: validatePassword,
                      obscureText: isObscure,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          submit();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          tooltip: isObscure
                              ? 'Tampilkan password'
                              : 'Sembunyikan password',
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ?  SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.light,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
