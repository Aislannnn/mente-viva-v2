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
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCardWide extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool escuro;
  final VoidCallback onTap;

  const _QuickCardWide({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: escuro ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
