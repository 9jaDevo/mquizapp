/// Aggregated stats for the battle landing screen.
final class BattleStats {
  const BattleStats({
    required this.activeRooms,
    required this.playersOnline,
    required this.totalBattles,
  });

  /// Number of rooms currently waiting for players (readyToPlay == false).
  final int activeRooms;

  /// Number of user slots occupied in open rooms.
  final int playersOnline;

  /// Cumulative number of battles ever created (incremented atomically).
  final int totalBattles;

  static const zero = BattleStats(
    activeRooms: 0,
    playersOnline: 0,
    totalBattles: 0,
  );
}
