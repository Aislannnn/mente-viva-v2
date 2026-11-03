part of '../presentation.dart';

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool escuro;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.escuro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = escuro ? AppColors.nightSurface : Colors.white;
    final textColor = escuro ? Colors.white : Colors.black87;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 86,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: escuro ? AppColors.nightCard : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
