import 'package:flutter/material.dart';
import '../design_tokens.dart';

/// Cabeçalho tipográfico das seções, independente dos cartões de conteúdo.
class SectionHero extends StatelessWidget {
  const SectionHero({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.splashEnd,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: escuro ? Colors.white : AppColors.ink,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: escuro ? Colors.white70 : AppColors.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: escuro ? AppColors.nightCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: escuro ? AppColors.nightCard : AppColors.line,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),
        ],
      ),
    );
  }
}
