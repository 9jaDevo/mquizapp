import 'package:flutter/material.dart';

/// Widget for toggling between Score and Engagement metrics
class MetricToggleWidget extends StatelessWidget {
  final int selectedMetricIndex; // 0 for Score, 1 for Engagement
  final void Function(int) onMetricChanged;
  final Color activeColor;
  final Color inactiveColor;

  const MetricToggleWidget({
    super.key,
    required this.selectedMetricIndex,
    required this.onMetricChanged,
    this.activeColor = const Color(0xFF1E90FF),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: inactiveColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _MetricTab(
                label: 'Top Scorers',
                icon: Icons.emoji_events,
                isSelected: selectedMetricIndex == 0,
                onTap: () => onMetricChanged(0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
            Expanded(
              child: _MetricTab(
                label: 'Most Active',
                icon: Icons.schedule,
                isSelected: selectedMetricIndex == 1,
                onTap: () => onMetricChanged(1),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _MetricTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
