import 'package:flutter/material.dart';

/// Widget for selecting time period: Week, Month, or All Time
class TimeFilterWidget extends StatelessWidget {
  final String selectedPeriod; // 'week', 'month', or 'alltime'
  final Function(String) onPeriodChanged;
  final Color activeColor;
  final Color inactiveColor;

  const TimeFilterWidget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.activeColor = const Color(0xFF1E90FF),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TimeChip(
              label: 'Week',
              isSelected: selectedPeriod == 'week',
              onTap: () => onPeriodChanged('week'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(width: 8),
            _TimeChip(
              label: 'Month',
              isSelected: selectedPeriod == 'month',
              onTap: () => onPeriodChanged('month'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(width: 8),
            _TimeChip(
              label: 'All Time',
              isSelected: selectedPeriod == 'alltime',
              onTap: () => onPeriodChanged('alltime'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : inactiveColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
