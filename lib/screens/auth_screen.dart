import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────── Авторизация: Вход / Регистрация ─────────────────────
//
// Первый экран при первом открытии приложения. После успешного входа
// пользователь попадает в онбординг, начиная с выбора режима
// («Сколько людей будет пользоваться приложением?»).
//
// Аккаунты хранятся локально в JSON: повторная регистрация с тем же
// email/телефоном запрещена, вход проверяет пароль.

final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
final RegExp _phoneCharsRe = RegExp(r'^\+?[\d\s\-\(\)]{7,20}$');

bool _looksLikeEmail(String value) => _emailRe.hasMatch(value.trim());

bool _looksLikePhone(String value) {
  final clean = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
  return _phoneCharsRe.hasMatch(value.trim()) &&
      RegExp(r'^\+?\d{7,15}$').hasMatch(clean);
}

/// Проверка поля «Email или номер телефона» в реальном времени.
String? contactError(String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  if (_looksLikeEmail(v) || _looksLikePhone(v)) return null;
  return 'Проверьте правильность email или номера телефона';
}

String? passwordError(String value) {
  if (value.isEmpty) return null;
  if (value.length < 6) return 'Пароль должен быть не короче 6 символов';
  return null;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool registerMode = false;

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return StatusBarStyle(
      darkIcons: Theme.of(context).brightness != Brightness.dark,
      child: Scaffold(
        backgroundColor: pal.bg,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: registerMode
                ? _RegisterForm(
                    key: const ValueKey('register'),
                    onSwitch: () => setState(() => registerMode = false),
                  )
                : _LoginForm(
                    key: const ValueKey('login'),
                    onSwitch: () => setState(() => registerMode = true),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Экран «Вход» ───────────────────────────

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _LoginForm({super.key, required this.onSwitch});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;
  bool loading = false;
  String? formError;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get formValid =>
      (loginController.text.trim().isNotEmpty &&
          contactError(loginController.text) == null) &&
      passwordController.text.length >= 6;

  Future<void> _signInEmail() async {
    setState(() {
      loading = true;
      formError = null;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final error = AppScope.of(context).signInWithPassword(
      loginController.text,
      passwordController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        loading = false;
        formError = error;
      });
    }
  }

  void _signInAsGuest() {
    AppScope.of(context).signInAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final contactErr = contactError(loginController.text);
    final passErr = passwordError(passwordController.text);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthLogo(),
          const SizedBox(height: 20),
          Text(
            'С возвращением',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: pal.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Войдите, чтобы продолжить вести свой бюджет',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, height: 1.4, color: pal.sub),
          ),
          const SizedBox(height: 26),
          _AuthField(
            controller: loginController,
            hint: 'Email или номер телефона',
            errorText: contactErr,
            onChanged: (_) => setState(() => formError = null),
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: passwordController,
            hint: 'Пароль',
            obscure: obscure,
            errorText: passErr,
            hintBelow: passErr == null && passwordController.text.isEmpty
                ? 'Минимум 6 символов'
                : null,
            onChanged: (_) => setState(() => formError = null),
            suffix: IconButton(
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 20,
                color: pal.sub,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Восстановление пароля появится в следующей версии 🌱'),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Забыли пароль?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
          ),
          if (formError != null) ...[
            const SizedBox(height: 12),
            Text(
              formError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: pal.pinkText,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SubmitButton(
            label: 'Войти',
            enabled: formValid && !loading,
            loading: loading,
            onTap: _signInEmail,
          ),
          const _OrDivider(),
          Center(
            child: GestureDetector(
              onTap: _signInAsGuest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Продолжить как гость',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: pal.sub,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _AuthSwitchText(
            prefix: 'Нет аккаунта? ',
            link: 'Зарегистрироваться',
            onTap: widget.onSwitch,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Экран «Регистрация» ───────────────────────

class _RegisterForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _RegisterForm({super.key, required this.onSwitch});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscure = true;
  bool agreed = false;
  bool loading = false;
  String? formError;

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? get nameErr {
    final name = nameController.text.trim();
    if (name.isEmpty || name.length >= 2) return null;
    return 'Введите имя';
  }

  String? get confirmErr {
    final confirm = confirmController.text;
    if (confirm.isEmpty) return null;
    if (confirm != passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  bool get formValid =>
      nameController.text.trim().length >= 2 &&
      contactController.text.trim().isNotEmpty &&
      contactError(contactController.text) == null &&
      passwordController.text.length >= 6 &&
      confirmController.text == passwordController.text &&
      agreed;

  Future<void> _signUpEmail() async {
    setState(() {
      loading = true;
      formError = null;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final error = AppScope.of(context).registerAccount(
      name: nameController.text,
      contact: contactController.text,
      password: passwordController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        loading = false;
        formError = error;
      });
    }
  }

  void _openDocument(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('«$title» откроются в следующей версии 📄')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    final contactErr = contactError(contactController.text);
    final passErr = passwordError(passwordController.text);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthLogo(),
          const SizedBox(height: 20),
          Text(
            'Создать аккаунт',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: pal.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Это займёт меньше минуты',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, height: 1.4, color: pal.sub),
          ),
          const SizedBox(height: 26),
          _AuthField(
            controller: nameController,
            hint: 'Имя',
            errorText: nameErr,
            onChanged: (_) => setState(() => formError = null),
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: contactController,
            hint: 'Email или номер телефона',
            errorText: contactErr,
            onChanged: (_) => setState(() => formError = null),
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: passwordController,
            hint: 'Пароль',
            obscure: obscure,
            errorText: passErr,
            hintBelow: passErr == null && passwordController.text.isEmpty
                ? 'Минимум 6 символов'
                : null,
            onChanged: (_) => setState(() => formError = null),
            suffix: IconButton(
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 20,
                color: pal.sub,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: confirmController,
            hint: 'Повторите пароль',
            obscure: obscure,
            errorText: confirmErr,
            onChanged: (_) => setState(() => formError = null),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                key: const ValueKey('terms-checkbox'),
                onTap: () => setState(() => agreed = !agreed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: agreed ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: agreed
                        ? null
                        : Border.all(color: pal.sageBorder, width: 2),
                  ),
                  child: agreed
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: pal.sub,
                    ),
                    children: [
                      const TextSpan(text: 'Я согласен с '),
                      TextSpan(
                        text: 'условиями использования',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _linkRecognizer(
                            () => _openDocument('Условия использования')),
                      ),
                      const TextSpan(text: ' и '),
                      TextSpan(
                        text: 'политикой конфиденциальности',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _linkRecognizer(
                            () => _openDocument('Политика конфиденциальности')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (formError != null) ...[
            const SizedBox(height: 14),
            Text(
              formError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: pal.pinkText,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SubmitButton(
            label: 'Зарегистрироваться',
            enabled: formValid && !loading,
            loading: loading,
            onTap: _signUpEmail,
          ),
          const SizedBox(height: 18),
          _AuthSwitchText(
            prefix: 'Уже есть аккаунт? ',
            link: 'Войти',
            onTap: widget.onSwitch,
          ),
        ],
      ),
    );
  }
}

GestureRecognizer _linkRecognizer(VoidCallback onTap) =>
    (TapGestureRecognizer()..onTap = onTap);

// ─────────────────────── Общие элементы ───────────────────────

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Center(
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: pal.sage,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text('🌿', style: TextStyle(fontSize: 26))),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final String? errorText;
  final String? hintBelow;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.obscure = false,
    this.suffix,
    this.errorText,
    this.hintBelow,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          style: TextStyle(fontSize: 15.5, color: pal.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15, color: pal.sub),
            filled: true,
            fillColor: pal.cardAlt,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: errorText != null
                  ? BorderSide(color: pal.pinkText.withValues(alpha: 0.55))
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: errorText != null
                    ? pal.pinkText.withValues(alpha: 0.7)
                    : AppColors.green.withValues(alpha: 0.5),
              ),
            ),
            suffixIcon: suffix,
          ),
        ),
        if (errorText != null || hintBelow != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText ?? hintBelow!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    errorText != null ? FontWeight.w600 : FontWeight.w400,
                color: errorText != null ? pal.pinkText : pal.sub,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: pal.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'или',
              style: TextStyle(fontSize: 12.5, color: pal.sub),
            ),
          ),
          Expanded(child: Container(height: 1, color: pal.divider)),
        ],
      ),
    );
  }
}

/// Основная кнопка: приглушённая, пока форма некорректна,
/// со спиннером при отправке.
class _SubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return GestureDetector(
      onTap: enabled && !loading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.green : pal.sage,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : pal.sub,
                ),
              ),
      ),
    );
  }
}

class _AuthSwitchText extends StatelessWidget {
  final String prefix;
  final String link;
  final VoidCallback onTap;

  const _AuthSwitchText({
    required this.prefix,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = palOf(context);
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: prefix,
                  style: TextStyle(fontSize: 13.5, color: pal.sub),
                ),
                TextSpan(
                  text: link,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
