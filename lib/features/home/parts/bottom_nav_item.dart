part of '../presentation.dart';

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Color selectedColor;
  final Color iconColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.selectedColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? selectedColor : iconColor,
                size: 23,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? selectedColor : iconColor,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
