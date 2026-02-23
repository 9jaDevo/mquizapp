import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/quiz/cubits/set_coin_score_cubit.dart';
import 'package:flutterquiz/features/quiz/models/user_battle_room_details.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

// ── Args ─────────────────────────────────────────────────────────────────────

final class BattleRoomResultArgs extends RouteArgs {
  BattleRoomResultArgs({
    required this.battleRoom,
    required this.currentUserId,
    required this.entryFee,
    required this.quizType,
    required this.matchId,
    this.playWithBot = false,
  });

  /// Snapshot of the battle room at quiz end.
  final BattleRoom battleRoom;
  final String currentUserId;
  final int entryFee;

  /// Backend quiz-type code: '1.3' for random battle, '1.4' for 1v1.
  final String quizType;
  final String? matchId;
  final bool playWithBot;
}

// ── Screen ───────────────────────────────────────────────────────────────────

class BattleRoomResultScreen extends StatefulWidget {
  const BattleRoomResultScreen({required this.args, super.key});

  final BattleRoomResultArgs args;

  @override
  State<BattleRoomResultScreen> createState() => _BattleRoomResultScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<BattleRoomResultArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SetCoinScoreCubit(),
        child: BattleRoomResultScreen(args: args),
      ),
    );
  }
}

class _BattleRoomResultScreenState extends State<BattleRoomResultScreen> {
  BattleRoom get _room => widget.args.battleRoom;
  String get _currentUserId => widget.args.currentUserId;

  @override
  void initState() {
    super.initState();
    _updateResult();
  }

  Future<void> _updateResult() async {
    await context.read<SetCoinScoreCubit>().setCoinScore(
      quizType: widget.args.quizType,
      playedQuestions: {
        'user1_id': _room.user1!.uid,
        'user2_id': _room.user2!.uid,
        'user1_data': _room.user1!.answers,
        'user2_data': _room.user2!.answers,
      },
      playWithBot: widget.args.playWithBot,
      matchId: widget.args.matchId,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  bool _isVictory(SetCoinScoreSuccess state) {
    if (state.winnerUserId == null || state.winnerUserId == '0') return false;
    return state.winnerUserId == _currentUserId;
  }

  int _correctForUser(SetCoinScoreSuccess state, String uid) =>
      state.userRanks
          .where((r) => r.userId == uid)
          .firstOrNull
          ?.correctAnswers ??
      (_room.userById(uid)?.correctAnswers ?? 0);

  int _currentCorrect(SetCoinScoreSuccess state) =>
      _correctForUser(state, _currentUserId);

  /// Returns the coin change for the current user.
  /// Falls back to entry-fee math if the API field is 0.
  int _computeEarnedCoins(SetCoinScoreSuccess state) {
    if (state.earnCoin != 0) return state.earnCoin;
    final fee = widget.args.entryFee;
    if (fee == 0) return 0;
    final victory = _isVictory(state);
    final isDraw = state.winnerUserId == null || state.winnerUserId == '0';
    if (isDraw) return 0;
    // 1v1: winner earns one opponent's fee
    if (victory) return fee;
    return -fee;
  }

  Future<void> _shareScore(SetCoinScoreSuccess state) async {
    final correct = _currentCorrect(state);
    final total = state.totalQuestions;
    final pts = _room.userById(_currentUserId)?.points ?? 0;
    final emoji = _isVictory(state) ? '🏆' : '🎮';
    await Share.share(
      '$emoji I scored $pts pts ($correct/$total correct) in 1v1 Battle!\n'
      'Can you beat me? 🔥',
      subject: 'My Battle Result',
    );
  }

  // ── Shared decoration ────────────────────────────────────────────────────

  BoxDecoration _card({double radius = 20}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.pushNamedAndRemoveUntil(
        Routes.home,
        predicate: (_) => false,
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF1E293B),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          context.tr('oneVsOneBattleLbl') ?? '1 vs 1 BATTLE',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('battleResultLbl') ?? 'Battle Result',
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(SetCoinScoreSuccess state) {
    final victory = _isVictory(state);
    final isDraw = state.winnerUserId == null || state.winnerUserId == '0';
    final earnedCoins = _computeEarnedCoins(state);
    final coins = earnedCoins.abs();
    final coinPositive = earnedCoins >= 0;

    final Color iconBg = victory
        ? const Color(0xFFDCFCE7)
        : isDraw
        ? const Color(0xFFFEF9C3)
        : const Color(0xFFFEE2E2);
    final Color iconColor = victory
        ? const Color(0xFF10B981)
        : isDraw
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    final Color titleColor = victory
        ? const Color(0xFF0EA5E9)
        : isDraw
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    final Color pillBg = coinPositive
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final Color pillText = coinPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final IconData icon = victory
        ? Icons.emoji_events_rounded
        : isDraw
        ? Icons.handshake_outlined
        : Icons.heart_broken_rounded;

    final String title = victory
        ? context.tr('victoryLbl') ?? 'Victory!'
        : isDraw
        ? context.tr('drawLbl') ?? 'Draw!'
        : context.tr('defeatLbl') ?? 'Defeat';

    final String subtitle = victory
        ? context.tr('victorySubtitleLbl') ?? "Great job — you're the champion!"
        : isDraw
        ? context.tr('drawSubtitleLbl') ?? "It's a tie — well played!"
        : context.tr('defeatSubtitleLbl') ??
              "Keep practicing — you'll win next time";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QImage(imageUrl: Assets.coin, height: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${coinPositive ? '+' : '-'}$coins '
                        '${context.tr('coinsLbl') ?? 'Coins'} '
                        '${coinPositive ? context.tr('wonLbl') ?? 'Won' : context.tr('lostLbl') ?? 'Lost'}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: pillText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVSCard(SetCoinScoreSuccess state) {
    // Rank-based left/right assignment — works for draws and bot matches.
    final rank1Id = state.userRanks.isNotEmpty
        ? state.userRanks.first.userId
        : _currentUserId;
    final rank2Id = state.userRanks.length > 1
        ? state.userRanks[1].userId
        : null;

    final leftUser = _room.userById(rank1Id);
    final rightUser = rank2Id != null ? _room.userById(rank2Id) : null;

    final leftCorrect = _correctForUser(state, rank1Id);
    final rightCorrect = _correctForUser(state, rank2Id ?? '');

    // Map BattleUserData by userId for speed bonus display.
    BattleUserData? _dataForUser(String uid) {
      if (state.user1Id == uid) return state.user1Data;
      if (state.user2Id == uid) return state.user2Data;
      return null;
    }

    final isDraw = state.winnerUserId == null || state.winnerUserId == '0';
    final leftIsWinner = !isDraw;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: _card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildPlayerColumn(
              user: leftUser,
              correct: leftCorrect,
              total: state.totalQuestions,
              isWinner: leftIsWinner,
              battleData: _dataForUser(rank1Id),
            ),
          ),
          SizedBox(
            width: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 1, height: 60, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                _buildVSBadge(),
                const SizedBox(height: 8),
                Container(width: 1, height: 60, color: const Color(0xFFE2E8F0)),
              ],
            ),
          ),
          Expanded(
            child: _buildPlayerColumn(
              user: rightUser,
              correct: rightCorrect,
              total: state.totalQuestions,
              isWinner: false,
              battleData: rank2Id != null ? _dataForUser(rank2Id) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVSBadge() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFF1E293B),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFEF4444), width: 2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Center(
      child: Text(
        'VS',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );

  Widget _buildPlayerColumn({
    required UserBattleRoomDetails? user,
    required int correct,
    required int total,
    required bool isWinner,
    BattleUserData? battleData,
  }) {
    if (user == null) return const SizedBox.shrink();

    final pts = user.points;
    final pillBg = isWinner ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0);
    final pillText = isWinner ? Colors.white : const Color(0xFF64748B);
    final isMe = user.uid == _currentUserId;
    final speedBonus = battleData != null
        ? battleData.quickestBonus + battleData.secondQuickestBonus
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWinner)
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFBBF24),
            size: 22,
          )
        else
          const SizedBox(height: 22),
        const SizedBox(height: 4),
        ClipOval(
          child: QImage.circular(
            imageUrl: user.profileUrl,
            width: 58,
            height: 58,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name.isEmpty
              ? '—'
              : isMe
              ? '${user.name} (${context.tr('youLbl') ?? 'You'})'
              : user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isMe ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$pts ${context.tr('ptsLbl') ?? 'pts'}',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: pillText,
            ),
          ),
        ),
        if (speedBonus > 0) ...[
          const SizedBox(height: 4),
          Text(
            '+$speedBonus ${context.tr('speedBonus') ?? 'Speed Bonus'}',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF59E0B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          '$correct/$total ${context.tr('correctLbl') ?? 'correct'}',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatTiles(SetCoinScoreSuccess state) {
    final total = state.totalQuestions;
    final correct = _currentCorrect(state);
    final accuracy = total > 0 ? (correct * 100 ~/ total) : state.percentage;

    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            icon: Icons.quiz_outlined,
            value: '$total',
            label: context.tr('questionsLbl') ?? 'Questions',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            icon: Icons.check_circle_outline_rounded,
            value: '$accuracy%',
            label: context.tr('accuracyLbl') ?? 'Accuracy',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            icon: Icons.fact_check_outlined,
            value: '$correct/$total',
            label: context.tr('correctLbl') ?? 'Correct',
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: _card(radius: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SetCoinScoreSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _shareScore(state),
          icon: const Icon(Icons.share_rounded, size: 18),
          label: Text(
            context.tr('shareScoreLbl') ?? 'Share Your Score',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3B82F6),
            side: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.pushNamedAndRemoveUntil(
            Routes.home,
            predicate: (_) => false,
          ),
          icon: const Icon(Icons.home_rounded, size: 18),
          label: Text(
            context.tr('homeBtn') ?? 'Back to Home',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(SetCoinScoreSuccess state) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildBackButton(),
          ),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 22),
          _buildResultCard(state),
          const SizedBox(height: 16),
          _buildVSCard(state),
          const SizedBox(height: 16),
          _buildStatTiles(state),
          const SizedBox(height: 16),
          _buildActionButtons(state),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: BlocConsumer<SetCoinScoreCubit, SetCoinScoreState>(
        listener: (context, state) {
          if (state is SetCoinScoreSuccess) {
            // Delete the battle room when scoring is complete.
            context.read<BattleRoomCubit>().deleteBattleRoom();
          }
        },
        builder: (context, state) {
          if (state is SetCoinScoreSuccess) {
            return _buildResultContent(state);
          }

          if (state is SetCoinScoreFailure) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBackButton(),
                    ),
                  ),
                  Expanded(
                    child: ErrorContainer(
                      showBackButton: false,
                      errorMessageColor: const Color(0xFF1E293B),
                      errorMessage: convertErrorCodeToLanguageKey(state.error),
                      onTapRetry: _updateResult,
                      showErrorImage: true,
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressContainer());
        },
      ),
    );
  }
}
