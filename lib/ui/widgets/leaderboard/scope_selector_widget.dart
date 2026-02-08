import 'package:flutter/material.dart';

/// Widget for selecting scope filter: World, Country, or Region
class ScopeSelectorWidget extends StatelessWidget {
  final String selectedScope; // 'world', 'country', or 'region'
  final void Function(String) onScopeChanged;
  final Color activeColor;
  final Color inactiveColor;

  const ScopeSelectorWidget({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
    this.activeColor = const Color(0xFF1E90FF),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScopeButton(
            label: 'World',
            icon: Icons.public,
            isSelected: selectedScope == 'world',
            onTap: () => onScopeChanged('world'),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScopeButton(
            label: 'Country',
            icon: Icons.flag,
            isSelected: selectedScope == 'country',
            onTap: () => onScopeChanged('country'),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScopeButton(
            label: 'Region',
            icon: Icons.map,
            isSelected: selectedScope == 'region',
            onTap: () => onScopeChanged('region'),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      ],
    );
  }
}

class _ScopeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _ScopeButton({
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
