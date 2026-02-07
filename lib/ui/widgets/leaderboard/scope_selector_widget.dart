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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
      ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : inactiveColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
