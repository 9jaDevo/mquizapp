import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/open_rooms_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/battle_painters.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({
    super.key,
    required this.quizType,
    required this.onJoinSuccess,
  });

  final QuizTypes quizType;

  /// Called after a successful join so the parent can show [inviteToRoomBottomSheet].
  final VoidCallback onJoinSuccess;

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  bool _isJoining = false;

  double get scrWidth => context.width;
  bool get _isGroupBattle => widget.quizType == QuizTypes.groupPlay;
  int get _maxSlots => _isGroupBattle ? 4 : 2;

  // Active filter / sort state (mirrors what's in OpenRoomsCubit but kept
  // here so the filter chips rebuild without reading the whole state).
  int? _feeFilter;
  String _sortBy = 'latest';

  static const _feeOptions = [50, 100, 500, 1000];

  // ── Colours ----------------------------------------------------------------
  static const _darkBlue = Color(0xFF0A0E2E);
  static const _midBlue = Color(0xFF1A3A8F);
  static const _accentBlue = Color(0xFF2563EB);
  static const _bgGrey = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset battle room cubits — mirrors the reset done in showJoinRoomBottomSheet().
      context.read<MultiUserBattleRoomCubit>().reset();
      context.read<BattleRoomCubit>().updateState(
        const BattleRoomInitial(),
        cancelSubscription: true,
      );
      // Load open rooms list.
      context.read<OpenRoomsCubit>().loadRooms(isGroupBattle: _isGroupBattle);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  // ── Join by code (typed or tapped from card) -------------------------------

  void _triggerJoin(String code) {
    if (code.trim().isEmpty) {
      context.showSnack(context.tr(enterRoomCodeMsg) ?? 'Enter a room code');
      return;
    }
    FocusScope.of(context).unfocus();

    final user = context.read<UserDetailsCubit>().getUserProfile();
    final currentCoin = user.coins ?? '0';
    final name = user.name ?? '';
    final profileUrl = user.profileUrl ?? '';
    final uid = user.userId ?? '';

    if (_isGroupBattle) {
      context.read<MultiUserBattleRoomCubit>().joinRoom(
        currentCoin: currentCoin,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        roomCode: code.trim(),
      );
    } else {
      context.read<BattleRoomCubit>().joinRoom(
        currentCoin: currentCoin,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        roomCode: code.trim(),
      );
    }
  }

  // ── Error / coin dialog (mirrors the logic in create_or_join_screen) -------

  void _showErrorDialog(String errorCode) {
    // Detect insufficient-coins situations (same logic as the bottom sheet).
    final isCoinError =
        errorCode == errorCodeNotEnoughCoins ||
        errorCode.contains('coin') ||
        errorCode.contains('Coin');

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.tr('errorLbl') ?? 'Error'),
        content: Text(
          context.tr(convertErrorCodeToLanguageKey(errorCode)) ?? errorCode,
        ),
        actions: [
          TextButton(
            child: Text(
              context.tr(isCoinError ? 'addCoinsLbl' : 'closeLbl') ?? 'Close',
              style: const TextStyle(color: _accentBlue),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── Filter helpers ---------------------------------------------------------

  void _onFeeChipTap(int? fee) {
    setState(() => _feeFilter = fee);
    context.read<OpenRoomsCubit>().applyFilter(feeFilter: fee, sortBy: _sortBy);
  }

  void _onSortToggle(String newSort) {
    setState(() => _sortBy = newSort);
    context.read<OpenRoomsCubit>().applyFilter(
      feeFilter: _feeFilter,
      sortBy: newSort,
    );
  }

  // ── Glass helper -----------------------------------------------------------

  Widget _glass({
    required Widget child,
    double radius = 14,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
    Color fill = const Color(0x1AFFFFFF),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _bgGrey,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiBlocListener(
        listeners: [
          // -- Group battle join outcome --
          BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
            listener: (ctx, state) {
              if (state is MultiUserBattleRoomSuccess) {
                setState(() => _isJoining = false);
                Navigator.of(context).pop();
                widget.onJoinSuccess();
              } else if (state is MultiUserBattleRoomFailure) {
                setState(() => _isJoining = false);
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                } else {
                  _showErrorDialog(state.errorMessageCode);
                }
              } else if (state is MultiUserBattleRoomInProgress) {
                setState(() => _isJoining = true);
              }
            },
          ),
          // -- 1v1 join outcome --
          BlocListener<BattleRoomCubit, BattleRoomState>(
            listener: (ctx, state) {
              if (state is BattleRoomUserFound) {
                setState(() => _isJoining = false);
                Navigator.of(context).pop();
                widget.onJoinSuccess();
              } else if (state is BattleRoomFailure) {
                setState(() => _isJoining = false);
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                } else {
                  _showErrorDialog(state.errorMessageCode);
                }
              } else if (state is BattleRoomJoining) {
                setState(() => _isJoining = true);
              }
            },
          ),
        ],
        child: PopScope(
          canPop: !_isJoining,
          child: Scaffold(
            backgroundColor: _bgGrey,
            body: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header -----------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darkBlue, _midBlue],
        ),
      ),
      child: Stack(
        children: [
          // Radial rays background
          Positioned.fill(
            child: CustomPaint(
              painter: const BattleRadialRaysPainter(centerYFraction: 0.5),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                scrWidth * UiUtils.hzMarginPct,
                12,
                scrWidth * UiUtils.hzMarginPct,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: back | logo | title
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: _isJoining ? null : Navigator.of(context).pop,
                        child: _glass(
                          radius: 50,
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // App logo
                      _glass(
                        radius: 50,
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          Assets.appLogo,
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          context.tr('joinRoom') ?? 'Join Room',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Code input row
                  _buildCodeInputRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputRow() {
    return Row(
      children: [
        // Wide code input
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _codeController,
              focusNode: _codeFocus,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText:
                    context.tr('enterRoomCodeHint') ??
                    'Enter Room Code (e.g. WZ4821)',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                isDense: true,
              ),
              onSubmitted: _triggerJoin,
              enabled: !_isJoining,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Join button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isJoining
                ? null
                : () => _triggerJoin(_codeController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _accentBlue.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
            ),
            child: _isJoining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.tr('join') ?? 'Join',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Body -------------------------------------------------------------------

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        _buildFilterRow(),
        const SizedBox(height: 4),
        Expanded(child: _buildRoomList()),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        scrWidth * UiUtils.hzMarginPct,
        16,
        scrWidth * UiUtils.hzMarginPct,
        0,
      ),
      child: Row(
        children: [
          Text(
            context.tr('activeRoomsLbl') ?? 'Active Rooms',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.read<OpenRoomsCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              context.tr('refreshLbl') ?? 'Refresh',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: _accentBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: scrWidth * UiUtils.hzMarginPct,
          vertical: 4,
        ),
        children: [
          // All chip
          _filterChip(
            label: context.tr('allLbl') ?? 'All',
            selected: _feeFilter == null,
            onTap: () => _onFeeChipTap(null),
          ),
          const SizedBox(width: 8),
          // Fee chips
          ..._feeOptions.map(
            (fee) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _filterChip(
                label: '$fee coins',
                selected: _feeFilter == fee,
                onTap: () => _onFeeChipTap(fee),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Sort toggle
          _sortChip(
            label: '↕ ${_sortBy == 'fewest' ? 'Fewest Players' : 'Latest'}',
            onTap: () =>
                _onSortToggle(_sortBy == 'latest' ? 'fewest' : 'latest'),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? _accentBlue : const Color(0xFFCBD5E1),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _accentBlue.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _sortChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    return BlocBuilder<OpenRoomsCubit, OpenRoomsState>(
      builder: (context, state) {
        if (state is OpenRoomsLoading || state is OpenRoomsInitial) {
          return _buildShimmerList();
        }
        if (state is OpenRoomsError) {
          return _buildErrorState(state.message);
        }
        if (state is OpenRoomsLoaded) {
          if (state.filtered.isEmpty) return _buildEmptyState();
          return RefreshIndicator(
            color: _accentBlue,
            onRefresh: () => context.read<OpenRoomsCubit>().refresh(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                scrWidth * UiUtils.hzMarginPct,
                8,
                scrWidth * UiUtils.hzMarginPct,
                24,
              ),
              itemCount: state.filtered.length,
              itemBuilder: (_, index) => _RoomCard(
                room: state.filtered[index],
                maxSlots: _maxSlots,
                isJoining: _isJoining,
                onJoin: (code) {
                  _codeController.text = code;
                  _triggerJoin(code);
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Shimmer / empty / error ------------------------------------------------

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        scrWidth * UiUtils.hzMarginPct,
        8,
        scrWidth * UiUtils.hzMarginPct,
        24,
      ),
      itemCount: 5,
      itemBuilder: (_, __) => _shimmerCard(),
    );
  }

  Widget _shimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 100, height: 14),
                const SizedBox(height: 6),
                _shimmerBox(width: 140, height: 11),
                const SizedBox(height: 6),
                _shimmerBox(width: 80, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shimmerBox(width: 36, height: 20, radius: 10),
              const SizedBox(height: 8),
              _shimmerBox(width: 60, height: 28, radius: 14),
            ],
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            context.tr('noActiveRoomsLbl') ?? 'No active rooms found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('createRoomToStartLbl') ??
                'Create a room to start playing!',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(convertErrorCodeToLanguageKey(message)) ?? message,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<OpenRoomsCubit>().loadRooms(
              isGroupBattle: _isGroupBattle,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.tr('retryLbl') ?? 'Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Room Card
// =============================================================================

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.maxSlots,
    required this.isJoining,
    required this.onJoin,
  });

  final BattleRoom room;
  final int maxSlots;
  final bool isJoining;
  final void Function(String code) onJoin;

  int get _filled {
    var c = 0;
    if (room.user1?.uid.isNotEmpty == true) c++;
    if (room.user2?.uid.isNotEmpty == true) c++;
    if (room.user3?.uid.isNotEmpty == true) c++;
    if (room.user4?.uid.isNotEmpty == true) c++;
    return c;
  }

  bool get _isFull => _filled >= maxSlots;

  Color get _capacityColor {
    if (_isFull) return const Color(0xFFEF4444);
    if (_filled >= maxSlots / 2) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hostName = room.user1?.name ?? '';
    final category = room.categoryName ?? '';
    final fee = room.entryFee ?? 0;
    final code = room.roomCode ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor(hostName),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                hostName.isNotEmpty ? hostName[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Centre info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Room code
                  Text(
                    code,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Host
                  Text(
                    'Host: $hostName',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Category + coins
                  Row(
                    children: [
                      if (category.isNotEmpty) ...[
                        const Icon(
                          Icons.category_outlined,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            category,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Text('🪙', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        '$fee coins',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Right side: capacity + join ────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Capacity pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _capacityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: _capacityColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '$_filled/$maxSlots',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _capacityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Join button
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: (_isFull || isJoining || code.isEmpty)
                        ? null
                        : () => onJoin(code),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      _isFull
                          ? (context.tr('fullLbl') ?? 'Full')
                          : (context.tr('join') ?? 'Join'),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
