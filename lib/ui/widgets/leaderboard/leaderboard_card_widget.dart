import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget for displaying a single leaderboard entry in card format
class LeaderboardCardWidget extends StatelessWidget {
  final String rank;
  final String name;
  final String profile;
  final String value; // Score or time
  final bool isCurrentUser;
  final bool isEngagement; // true for engagement time, false for score
  final String? countryCode;
  final Color primaryColor;

  const LeaderboardCardWidget({
    super.key,
    required this.rank,
    required this.name,
    required this.profile,
    required this.value,
    this.isCurrentUser = false,
    this.isEngagement = false,
    this.countryCode,
    this.primaryColor = const Color(0xFF1E90FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? primaryColor.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? primaryColor : Colors.grey[300]!,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isCurrentUser ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrentUser ? primaryColor : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: profile,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? 'You' : name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isCurrentUser ? primaryColor : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (countryCode != null && countryCode!.isNotEmpty)
                  Text(
                    _getCountryFlag(countryCode!) + ' ' + countryCode!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Score/Time value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? primaryColor
                  : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEngagement ? Icons.schedule : Icons.star,
                  size: 16,
                  color: isCurrentUser ? Colors.white : primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryFlag(String countryCode) {
    // Convert country code to flag emoji
    // ISO 3166-1 alpha-2 code to emoji
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
