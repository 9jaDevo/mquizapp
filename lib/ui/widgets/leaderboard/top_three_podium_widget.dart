import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget for displaying top 3 users in a podium style
class TopThreePodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;
  final bool isEngagement; // true for engagement time, false for score
  final Color primaryColor;

  const TopThreePodiumWidget({
    super.key,
    required this.topThree,
    this.isEngagement = false,
    this.primaryColor = const Color(0xFF1E90FF),
  });

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure we have exactly 3 items (fill with empty if needed)
    final List<Map<String, dynamic>?> paddedTopThree = List.filled(3, null);
    for (int i = 0; i < topThree.length && i < 3; i++) {
      paddedTopThree[i] = topThree[i];
    }

    final first = paddedTopThree[0];
    final second = topThree.length > 1 ? paddedTopThree[1] : null;
    final third = topThree.length > 2 ? paddedTopThree[2] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (second != null)
            Expanded(
              child: _PodiumPosition(
                userData: second,
                rank: 2,
                height: 100,
                medalColor: Colors.grey[400]!,
                isEngagement: isEngagement,
                primaryColor: primaryColor,
              ),
            ),
          if (second == null) const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // First place
          if (first != null)
            Expanded(
              child: _PodiumPosition(
                userData: first,
                rank: 1,
                height: 130,
                medalColor: const Color(0xFFFFD700), // Gold
                isEngagement: isEngagement,
                primaryColor: primaryColor,
              ),
            ),
          if (first == null) const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // Third place
          if (third != null)
            Expanded(
              child: _PodiumPosition(
                userData: third,
                rank: 3,
                height: 80,
                medalColor: const Color(0xFFCD7F32), // Bronze
                isEngagement: isEngagement,
                primaryColor: primaryColor,
              ),
            ),
          if (third == null) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _PodiumPosition extends StatelessWidget {
  final Map<String, dynamic> userData;
  final int rank;
  final double height;
  final Color medalColor;
  final bool isEngagement;
  final Color primaryColor;

  const _PodiumPosition({
    required this.userData,
    required this.rank,
    required this.height,
    required this.medalColor,
    required this.isEngagement,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String name = userData['name']?.toString() ?? 'Unknown';
    final String profile = userData['profile']?.toString() ?? '';
    final String value = isEngagement
        ? _formatTime(userData['total_minutes']?.toString() ?? '0')
        : userData['score']?.toString() ?? '0';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal badge
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            Container(
              width: rank == 1 ? 70 : 60,
              height: rank == 1 ? 70 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: medalColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: profile,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Medal icon
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Name
        Text(
          name,
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 12,
            fontWeight: rank == 1 ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // Score/Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: rank == 1 ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withOpacity(0.6),
                medalColor.withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border(
              top: BorderSide(color: medalColor, width: 3),
              left: BorderSide(color: medalColor.withOpacity(0.5), width: 1),
              right: BorderSide(color: medalColor.withOpacity(0.5), width: 1),
            ),
          ),
          child: Center(
            child: Icon(
              isEngagement ? Icons.schedule : Icons.emoji_events,
              color: medalColor,
              size: rank == 1 ? 40 : 30,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(String minutes) {
    final double totalMinutes = double.tryParse(minutes) ?? 0.0;
    final int hours = (totalMinutes / 60).floor();
    final int mins = (totalMinutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }
}
