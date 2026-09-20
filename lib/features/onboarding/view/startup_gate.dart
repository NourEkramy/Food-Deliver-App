import 'package:flutter/material.dart';

import '../../../core/storage/local_store.dart';
import '../../auth/view/auth_gate.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

/// Decides what the app opens on: onboarding, or the app itself.
///
/// Sits above [AuthGate] rather than inside it, because the two questions are
/// independent — whether this person has seen the introduction has nothing to
/// do with whether they are signed in.
class StartupGate extends StatefulWidget {
  final LocalStore store;

  const StartupGate({super.key, this.store = const LocalStore()});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool? _needsOnboarding;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final seen = await widget.store.readFlag(LocalStore.keyOnboardingSeen);
    if (mounted) setState(() => _needsOnboarding = !seen);
  }

  Future<void> _finish() async {
    await widget.store.writeFlag(LocalStore.keyOnboardingSeen, value: true);
    if (mounted) setState(() => _needsOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_needsOnboarding) {
      null => const SplashScreen(),
      true => OnboardingScreen(onDone: _finish),
      false => const AuthGate(),
    };
  }
}
