import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/pages/homepage.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_intro_page.dart';
import 'package:consulting_fe/provider/auth_provider.dart';
import 'package:consulting_fe/provider/profile_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum _SignInMethod { none, google, apple }

class _LoginPageState extends State<LoginPage> {
  _SignInMethod _activeMethod = _SignInMethod.none;
  bool _manualExchange = false;
  String? _errorMessage;

  bool get _loading => _activeMethod != _SignInMethod.none;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (_manualExchange) return;
      if (data.event == AuthChangeEvent.signedIn &&
          data.session != null &&
          mounted) {
        _exchangeAndNavigate(data.session!.accessToken);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _activeMethod = _SignInMethod.google;
      _errorMessage = null;
    });

    try {
      // google_sign_in v7: singleton + authenticate() shows native account picker
      final googleUser = await GoogleSignIn.instance.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw 'No ID token received from Google.';

      // signInWithIdToken triggers onAuthStateChange → _exchangeAndNavigate
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      // User cancelled — reset without showing an error
      if (e.code == GoogleSignInExceptionCode.canceled) {
        if (mounted) setState(() => _activeMethod = _SignInMethod.none);
        return;
      }
      rethrow;
    } catch (e) {
      if (mounted) {
        setState(() {
          _activeMethod = _SignInMethod.none;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _activeMethod = _SignInMethod.apple;
      _errorMessage = null;
    });

    try {
      final rawNonce = Supabase.instance.client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) throw 'No ID token received from Apple.';

      // Prevent the auth listener from auto-navigating — we need to
      // save the user's name first (Apple only provides it on first sign-in).
      _manualExchange = true;

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (credential.givenName != null || credential.familyName != null) {
        final nameParts = <String>[
          if (credential.givenName != null) credential.givenName!,
          if (credential.familyName != null) credential.familyName!,
        ];
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': nameParts.join(' '),
              'given_name': credential.givenName,
              'family_name': credential.familyName,
            },
          ),
        );
      }

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && mounted) {
        _exchangeAndNavigate(session.accessToken);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      _manualExchange = false;
      if (e.code == AuthorizationErrorCode.canceled) {
        if (mounted) setState(() => _activeMethod = _SignInMethod.none);
        return;
      }
      if (mounted) {
        setState(() {
          _activeMethod = _SignInMethod.none;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      _manualExchange = false;
      if (mounted) {
        setState(() {
          _activeMethod = _SignInMethod.none;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _exchangeAndNavigate(String supabaseToken) async {
    final auth = context.read<AuthProvider>();
    auth.setLoggedIn(true);

    await context.read<ProfileProvider>().load();
    if (!mounted) return;

    final hasName = context.read<ProfileProvider>().hasName;
    final onboardingDone = hasName;

    final initialData = onboardingDone
        ? null
        : OnboardingData(name: context.read<ProfileProvider>().name);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => onboardingDone
            ? const HomePage()
            : OnboardingIntroPage(data: initialData),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildIcon(),
              const SizedBox(height: 28),
              _buildTexts(),
              const Spacer(flex: 3),

              // if (_errorMessage != null) ...[
              //   _buildError(),
              //   const SizedBox(height: 16),
              // ],
              _buildLoginHeader(),
              const SizedBox(height: 8),
              if (Platform.isIOS) ...[
                _buildAppleSignInButton(),
                const SizedBox(height: 10),
              ],
              _buildGoogleSignInButton(),
              const SizedBox(height: 16),
              _buildFooter(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.mainPoint.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset('assets/login/light_icon.png', width: 88, height: 88),
    );
  }

  Widget _buildTexts() {
    return const Column(
      children: [
        SizedBox(height: 12),
        Text(
          'NEVER GUESS Your Wake Up Time Again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Your Alarm clock, powered by traffic',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppleSignInButton() {
    final isAppleActive = _activeMethod == _SignInMethod.apple;
    final dimmed = _loading && !isAppleActive;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14),
        color: AppColors.textPrimary,
        onPressed: _loading ? null : _handleAppleSignIn,
        child: AnimatedOpacity(
          opacity: dimmed ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apple,
                size: 22,
                color: isAppleActive
                    ? AppColors.background.withValues(alpha: 0.4)
                    : AppColors.background,
              ),
              const SizedBox(width: 8),
              Text(
                isAppleActive ? 'Signing in…' : 'Continue with Apple',
                style: TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isAppleActive
                      ? AppColors.background.withValues(alpha: 0.4)
                      : AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    final isGoogleActive = _activeMethod == _SignInMethod.google;
    final dimmed = _loading && !isGoogleActive;
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: PlatformLoginButton(
          text: isGoogleActive ? 'Signing in…' : 'Continue with Google',
          icon: _GoogleLogoWidget(size: 20, dimmed: isGoogleActive),
          onPressed: _loading ? null : _handleGoogleSignIn,
          height: 55,
          isProminentGlass: true,
          enabled: !_loading,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 13,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'By continuing, you agree to the Terms of Service and Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppFonts.normal,
        fontSize: 12,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        height: 1.5,
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Text(
      'Learns your commute to improve your wake-up timing.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppFonts.normal,
        fontSize: 12,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        height: 1.5,
      ),
    );
  }
}

// ── Google "G" logo per brand guidelines ──────────────────────────────────────
// Uses the official four-color Google palette.
class _GoogleLogoWidget extends StatelessWidget {
  const _GoogleLogoWidget({this.size = 20, this.dimmed = false});

  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: Image.asset(
        'assets/login/google.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
