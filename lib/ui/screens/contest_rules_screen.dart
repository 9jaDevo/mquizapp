import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContestRulesScreen extends StatelessWidget {
  const ContestRulesScreen({super.key});

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const ContestRulesScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contest Rules'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Official Contest Rules',
              '''
1. ELIGIBILITY
• Open to users aged 13 and above
• Must have a registered account to participate
• One entry per user per contest period

2. HOW TO ENTER
• Navigate to the Contest section from the home screen
• Select an active contest
• Complete the quiz within the specified time limit
• Submit your answers before the contest deadline

3. PRIZES & REWARDS
• Virtual coins awarded based on contest ranking
• Top performers receive bonus coins
• Coins can be used within the app to:
  - Unlock premium quiz categories
  - Purchase hints and lifelines
  - Access special features
• Coins have NO CASH VALUE
• Coins are NON-TRANSFERABLE
• Coins CANNOT be redeemed for real money or real-world items

4. WINNER DETERMINATION
• Winners are determined by:
  - Quiz accuracy (number of correct answers)
  - Time to completion
  - Total score
• Contest leaderboard is updated in real-time
• Final rankings are determined when contest ends
• Top 3 users in each contest receive bonus rewards

5. PRIZE NOTIFICATION & DISTRIBUTION
• Coins are credited automatically when contest ends
• Winners can view results in the Contest Leaderboard
• All prizes are virtual and used only within the app

6. GENERAL CONDITIONS
• Contest results are final
• We reserve the right to disqualify participants for:
  - Cheating or answer manipulation
  - Using multiple accounts
  - Violating our Terms of Service
  - Any form of unfair play
• Contests may be cancelled if insufficient participants
• Contest schedules are subject to change
• We reserve the right to modify contest rules with notice

7. DATA & PRIVACY
• Your quiz performance data is used only for contest ranking
• Personal information is handled per our Privacy Policy
• You may request data deletion at any time

8. DISPUTES
• All disputes will be resolved at our sole discretion
• Decisions regarding contest results are final

9. CONTACT
• Questions: support@mquiz.uk
• Disputes: admin@mquiz.uk
• Technical issues: Report via app settings
              ''',
            ),
            const SizedBox(height: 24),
            _buildImportantNotice(context),
            const SizedBox(height: 24),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade700, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'IMPORTANT NOTICE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Apple Inc. is not a sponsor of, and is not involved in any way with, '
            'this contest or sweepstakes.\n\n'
            'This contest is operated solely by mQuiz and is subject to these '
            'official rules.\n\n'
            'All prizes are virtual coins and are used '
            'exclusively within the mQuiz application.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.red.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version: 2.3.8',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
