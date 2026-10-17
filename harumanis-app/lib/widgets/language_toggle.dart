import 'package:flutter/material.dart';
import '../services/locale_service.dart';

/// Compact BM | EN switch for the login screen (dark background).
/// Plain TextStyle (font comes from the app theme) so it runs in widget tests
/// without google_fonts trying to load fonts.
class LanguageToggle extends StatelessWidget {
  final LocaleController? controller;
  const LanguageToggle({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller ?? LocaleController.instance;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(c, 'ms', 'BM'),
          const Text('|', style: TextStyle(color: Colors.white38, fontSize: 13)),
          _option(c, 'en', 'EN'),
        ],
      ),
    );
  }

  Widget _option(LocaleController c, String code, String label) {
    final selected = c.code == code;
    return TextButton(
      onPressed: () => c.setLocale(code),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? Colors.white : Colors.white60,
        ),
      ),
    );
  }
}
