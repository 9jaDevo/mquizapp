# Modern UI Screens Implementation Guide - Coding Agent Instructions

## 📋 Overview

This guide provides detailed specifications for implementing modern glassmorphism-based UI screens for the mQuiz Flutter application. The new designs extend the glassmorphism design system that has been successfully implemented on login, signup, dashboard, and home screens.

**Status**: Ready for implementation  
**Date**: February 2026  
**Target Pages**: Coin History, Wallet (Redemption), Transaction History, Payment Methods, Account Details, Referral

---

## 🎨 Design System Reference

### Core Design Pattern: Glassmorphism Effect

All screens use the **Liquid Glass Effect** with the following specifications:

#### Glass Container Pattern (Dart)
```dart
// Standard glass effect used across all cards and containers
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: // content here
    ),
  ),
)
```

### Color Palette

| Element              | Light Mode        | Dark Mode         | Usage                             |
| -------------------- | ----------------- | ----------------- | --------------------------------- |
| **Primary Gradient** | #4A75E8 → #60A5FA | #4A75E8 → #60A5FA | Streak, icons, primary actions    |
| **Teal Gradient**    | #14B8A6 → #06B6D4 | #14B8A6 → #06B6D4 | Featured items, secondary actions |
| **Glass Base**       | White @ 0.9       | White @ 0.08      | Container backgrounds             |
| **Glass Border**     | White @ 0.3       | White @ 0.15      | Container borders                 |
| **Text Primary**     | #1A1A1A           | White @ 0.95      | Main text                         |
| **Text Secondary**   | #666666           | White @ 0.7       | Secondary text                    |
| **Accent Shadow**    | #4A75E8 @ 0.3     | Black @ 0.2       | Blue-tinted shadows               |

### Typography

**Font Family**: Google Fonts Nunito (already imported in project)

| Size    | Weight        | Usage                        |
| ------- | ------------- | ---------------------------- |
| 11px    | 400 (Regular) | Small labels, captions       |
| 12px    | 400 (Regular) | Descriptions, secondary text |
| 13px    | 400 (Regular) | Body text                    |
| 15-16px | 700 (Bold)    | Important values, labels     |
| 18px    | 700 (Bold)    | Section titles               |
| 20-24px | 700 (Bold)    | Page titles                  |

### Import Requirements

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

---

## 📱 UI Screens to Implement

### 1. **Coin History Page**

**File Location**: `lib/ui/screens/wallet/coin_history_screen.dart`

**Design Reference**: `/docs/UI_Design/Coin History.jpg`

#### Layout Structure
```
┌─────────────────────────────────────┐
│ ← Coin History                      │ (Header with back button)
├─────────────────────────────────────┤
│ 💰 Total Balance: 5,420             │ (Glass card - centered)
├─────────────────────────────────────┤
│ Filters: [Today] [Week] [Month] [All] │ (Chip selection)
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ +50 Coins                       │ │
│ │ Daily Challenge Completed  12:45│ │ (List item - glass)
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ -100 Coins                      │ │
│ │ Quiz Exam Entry Fee        11:30│ │ (List item - glass)
│ └─────────────────────────────────┘ │
│ ... (more transactions)              │
└─────────────────────────────────────┘
```

#### Components & Specifications

**1.1 Page Header**
- Title: "Coin History" with back button
- Typography: 20px bold, color: theme text primary
- Padding: 16px horizontal, 12px vertical

**1.2 Balance Card** (Glass Effect)
- Center-aligned glass container with rounded corners (16px)
- Large coin emoji (40px)
- Title: "Total Balance" (12px, secondary)
- Balance: "5,420" (28px bold, primary)
- Background: Standard glass with accent blue gradient
- Padding: 20px all sides
- Margin: 16px bottom

**1.3 Filter Chips**
- Row of filter options: [Today] [Week] [Month] [All]
- Active chip: Blue gradient background with white text
- Inactive chip: Light glass background
- Typography: 13px medium
- Horizontal scroll if needed
- Margin: 16px

**1.4 Transaction List Items** (Glass Cards)
- Glass container with 16px border radius
- Structure:
  - Left: Emoji/Icon (24px) indicating transaction type
  - Center: Amount (16px bold) on top, Description (12px secondary) below
  - Right: Timestamp (11px tertiary)
- Padding: 16px
- Margin: 8px vertical
- Colors:
  - Add (+): Green/Teal gradient emoji
  - Remove (-): Orange/Red gradient emoji
- Swipe-to-delete functionality (optional)

#### Code Template

```dart
class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  String selectedFilter = 'all'; // today, week, month, all
  List<CoinTransaction> transactions = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: Text('Coin History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Balance Card - Glass Effect
            _buildBalanceCard(context, isDark),
            // 2. Filter Chips
            _buildFilterChips(context, isDark),
            // 3. Transaction List
            _buildTransactionList(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    // Implement glass card with balance display
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    // Implement filter chips
  }

  Widget _buildTransactionList(BuildContext context, bool isDark) {
    // Implement transaction list with glass cards
  }
}
```

---

### 2. **Wallet Page - Redemption Section**

**File Location**: `lib/ui/screens/wallet/wallet_redeem_screen.dart`

**Design Reference**: `/docs/UI_Design/Request Payment.jpg`

#### Layout Structure
```
┌─────────────────────────────────────┐
│ Redeem Your Coins                   │ (Title)
├─────────────────────────────────────┤
│ Available Balance: 5,420 💰          │ (Glass card - info)
├─────────────────────────────────────┤
│ Minimum Redemption: 1,000 Coins     │ (Requirement info)
│ You'll Get: $50.00 USD              │ (Exchange rate)
├─────────────────────────────────────┤
│ Enter Amount to Redeem:             │
│ ┌─────────────────────────────────┐ │
│ │ [    1000    ] Coins            │ │ (Input field + slider)
│ └─────────────────────────────────┘ │
│ ╔═════════════════════════════════╗ │
│ ║ ━━━━━━━━━━━━━━━╭───┬───╮━━━━━━ ║ │ (Slider)
│ ╚═════════════════════════════════╝ │
│ Receive: $50.00 USD (Real-time)    │ (Converted amount)
├─────────────────────────────────────┤
│ ┌──────────────────────────────────┐│
│ │ Continue to Payment Setup        ││ (Blue gradient button)
│ └──────────────────────────────────┘│
└─────────────────────────────────────┘
```

#### Components & Specifications

**2.1 Header Section**
- Title: "Redeem Your Coins" (20px bold)
- Subtitle: "Convert your coins to real money" (13px secondary)

**2.2 Info Cards** (Glass Effect)
- Card 1: Available Balance display
  - Label: "Available Balance" (12px secondary)
  - Value: "5,420 💰" (24px bold primary)
  - Icon: Coin emoji (32px)
- Card 2: Redemption Terms
  - Minimum: "1,000 Coins" (12px, left)
  - Exchange: "You'll Get $50.00 USD" (13px bold, left)

**2.3 Input Section** (Glass Background)
- Label: "Enter Amount to Redeem" (13px bold)
- Input Field: 
  - Glass effect container with rounded corners (12px)
  - Placeholder: "Enter amount in coins"
  - Suffix icon: "Coins" label
  - Size: 48px height
- Amount Slider:
  - Min: 1000, Max: available balance
  - Shows coin increments
- Real-time conversion display:
  - "Receive: $50.00 USD" (14px bold, accent color)

**2.4 Action Button**
- Text: "Continue to Payment Setup"
- Style: Blue gradient background
- Full width with 16px margins
- Height: 56px
- Border radius: 12px
- Font: 16px bold white

#### Code Template

```dart
class WalletRedeemScreen extends StatefulWidget {
  const WalletRedeemScreen({super.key});

  @override
  State<WalletRedeemScreen> createState() => _WalletRedeemScreenState();
}

class _WalletRedeemScreenState extends State<WalletRedeemScreen> {
  late TextEditingController _amountController;
  int selectedAmount = 1000;
  int availableBalance = 5420;
  int minimumRedeem = 1000;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1000');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final convertedAmount = (selectedAmount / 20).toStringAsFixed(2); // Example conversion rate

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              SizedBox(height: 20),
              // Info Cards
              _buildBalanceCard(context, isDark),
              SizedBox(height: 12),
              _buildRedemptionTerms(context, isDark),
              SizedBox(height: 24),
              // Input Section
              _buildInputSection(context, isDark, convertedAmount),
              SizedBox(height: 32),
              // Action Button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods...
}
```

---

### 3. **Transaction History Tab**

**File Location**: `lib/features/wallet/screens/wallet_screen.dart` (Extend existing)

**Design Reference**: `/docs/UI_Design/Payment Transaction History.jpg`

#### Layout Structure
```
┌─────────────────────────────────────┐
│ [Redemption] [Transactions] [Settings]│ (Tab bar)
├─────────────────────────────────────┤
│ Filter: [Pending] [Completed] [Failed]│ (Quick filter)
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Request #5240                   │ │
│ │ 2,500 Coins → $125.00 USD      │ │
│ │ Status: Pending  Feb 3, 2:45 PM │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Request #5239                   │ │
│ │ 1,000 Coins → $50.00 USD       │ │
│ │ Status: ✅ Completed  Feb 2     │ │
│ └─────────────────────────────────┘ │
│ ... (more transactions)              │
└─────────────────────────────────────┘
```

#### Components & Specifications

**3.1 Tab Bar**
- Options: [Redemption] [Transactions] [Settings]
- Active tab: Underlined with blue gradient
- Inactive tab: Light gray text
- Full width tabs
- Height: 48px

**3.2 Status Filter Chips**
- [Pending] [Completed] [Failed] [All]
- Style: Same as coin history filter
- Margin: 12px bottom

**3.3 Transaction Cards** (Glass Effect)
- Structure:
  ```
  Request #5240
  2,500 Coins → $125.00 USD
  Status: Pending  |  Feb 3, 2:45 PM
  ```
- Left indicator: Status color badge
  - Pending: Orange (#F59E0B)
  - Completed: Green (#10B981)
  - Failed: Red (#EF4444)
- Padding: 16px
- Full width with 8px vertical margin
- Glass effect with border

**3.4 Empty State** (if no transactions)
- Center icon: Transaction icon (48px, secondary color)
- Title: "No Transactions Yet" (16px bold)
- Subtitle: "Start by redeeming your coins" (13px secondary)

#### Code Template

```dart
class TransactionHistoryTab extends StatefulWidget {
  const TransactionHistoryTab({super.key});

  @override
  State<TransactionHistoryTab> createState() => _TransactionHistoryTabState();
}

class _TransactionHistoryTabState extends State<TransactionHistoryTab> {
  String selectedFilter = 'all';
  List<PaymentRequest> transactions = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Filter chips
        _buildFilterChips(context, isDark),
        // Transaction list
        Expanded(
          child: _buildTransactionList(context, isDark),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    // Implement filter chips
  }

  Widget _buildTransactionList(BuildContext context, bool isDark) {
    // Implement transaction list with glass cards
  }
}
```

---

### 4. **Payment Method Selection**

**File Location**: `lib/ui/screens/wallet/payment_method_selection_screen.dart`

**Design Reference**: `/docs/UI_Design/Payment Request Selection.jpg`

#### Layout Structure
```
┌─────────────────────────────────────┐
│ Select Payment Method               │ (Title)
├─────────────────────────────────────┤
│ Recommended for Fast Processing:    │ (Section header)
├─────────────────────────────────────┤
│ ◎ Bank Transfer (2-3 days)          │ (Radio option - glass)
│   • Low fees, Secure                │
├─────────────────────────────────────┤
│ Other Payment Methods:              │ (Section header)
├─────────────────────────────────────┤
│ ○ PayPal (Instant)                  │ (Radio option - glass)
│   • Fast, but higher fees           │
│ ○ Google Play Credit                │ (Radio option - glass)
│   • Instant, for app purchases      │
│ ○ Cryptocurrency (Bitcoin)          │ (Radio option - glass)
│   • Decentralized, no KYC needed    │
├─────────────────────────────────────┤
│ ┌──────────────────────────────────┐│
│ │ Continue with Bank Transfer     ││ (Action button - enabled)
│ └──────────────────────────────────┘│
│ Fees: $5.00 (Estimated)             │ (Fee info - right aligned)
└─────────────────────────────────────┘
```

#### Components & Specifications

**4.1 Header**
- Title: "Select Payment Method" (20px bold)
- Subtitle: "Choose how you want to receive your earnings" (13px secondary)

**4.2 Method Sections** (Glass Effect)
Each method is a glass card with:
- **Radio Button** (left, 24px)
- **Method Name** (16px bold primary)
- **Processing Time** (12px secondary, right side)
- **Description** (12px secondary gray, bullet points)
- Full width, 12px border radius
- Padding: 16px
- Margin: 8px vertical

**4.3 Section Headers**
- "Recommended for Fast Processing:" (13px bold)
- "Other Payment Methods:" (13px bold)
- Color: Secondary text
- Margin: 16px top, 8px bottom

**4.4 Fee Information**
- Position: Bottom right
- Text: "Fees: $5.00 (Estimated)" (12px secondary)
- Color: Orange/warning color
- Update in real-time based on selection

**4.5 Action Button**
- Text: "Continue with [Method Name]" (updates based on selection)
- Style: Blue gradient
- Enabled when method selected
- Height: 56px
- Margin: 16px
- Border radius: 12px

#### Code Template

```dart
class PaymentMethodSelectionScreen extends StatefulWidget {
  final int redemptionAmount;

  const PaymentMethodSelectionScreen({
    required this.redemptionAmount,
    super.key,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState extends State<PaymentMethodSelectionScreen> {
  String? selectedMethod; // 'bank', 'paypal', 'google_play', 'crypto'
  
  final paymentMethods = [
    PaymentMethod(
      id: 'bank',
      name: 'Bank Transfer',
      processingTime: '2-3 days',
      description: 'Low fees, Secure',
      fee: 0.0,
      isRecommended: true,
    ),
    // ... more methods
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(title: Text('Select Payment Method')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommended section
              _buildMethodSection(context, isDark, true),
              SizedBox(height: 20),
              // Other methods section
              _buildMethodSection(context, isDark, false),
              SizedBox(height: 32),
              // Fee info
              _buildFeeInfo(context, isDark),
              SizedBox(height: 16),
              // Action button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods...
}
```

---

### 5. **Account Details Dialog/Popup**

**File Location**: `lib/ui/screens/wallet/account_details_dialog.dart`

**Design Reference**: `/docs/UI_Design/Payment Account Details.jpg`

#### Layout Structure
```
╔═════════════════════════════════════╗
║ Account Details                  ✕  ║ (Modal header)
╠═════════════════════════════════════╣
║ Bank Account Information:           ║ (Section title)
║ ┌─────────────────────────────────┐ ║
║ │ Account Name: John Doe          │ ║ (Glass input field)
║ └─────────────────────────────────┘ ║
║ ┌─────────────────────────────────┐ ║
║ │ Account Number: ****5678        │ ║ (Masked - readonly)
║ └─────────────────────────────────┘ ║
║ ┌─────────────────────────────────┐ ║
║ │ Bank Name: National Bank USA    │ ║
║ └─────────────────────────────────┘ ║
║ ┌─────────────────────────────────┐ ║
║ │ SWIFT Code: NABAUS33           │ ║
║ └─────────────────────────────────┘ ║
║                                     ║
║ ┌──────────────────────────────────┐║
║ │ ✓ Verify Account                ││ (Action button)
║ └──────────────────────────────────┘║
║ ┌──────────────────────────────────┐║
║ │ Edit Account Details            ││ (Secondary button)
║ └──────────────────────────────────┘║
╚═════════════════════════════════════╝
```

#### Components & Specifications

**5.1 Modal Structure**
- Width: ~85% of screen (min 300px, max 400px)
- Border radius: 20px
- Glass background with standard effect
- Header with close button (X icon)

**5.2 Input Fields** (Glass Effect)
- Label above: 12px, secondary color
- Input container: 
  - Height: 48px
  - Glass effect with border
  - Padding: 12px horizontal
  - Border radius: 12px
  - Font: 14px, color: primary text
- Types:
  - Account Name: Editable text input
  - Account Number: Masked display (readonly)
  - Bank Name: Dropdown selector
  - SWIFT Code: Editable text input

**5.3 Verification Info** (Optional)
- Color: Green (#10B981)
- Icon: Checkmark (16px)
- Text: "Account verified on Feb 3, 2026" (11px)

**5.4 Action Buttons**
- Primary: "Verify Account" (Blue gradient, full width)
- Secondary: "Edit Account Details" (Light glass outline)
- Height: 48px each
- Margin: 8px between buttons
- Border radius: 12px

**5.5 Footer Info** (Optional)
- "Your account details are encrypted and secure" (11px, tertiary)
- Centered, light color

#### Code Template

```dart
class AccountDetailsDialog extends StatefulWidget {
  final PayoutMethod accountDetails;
  final VoidCallback? onVerify;
  final VoidCallback? onEdit;

  const AccountDetailsDialog({
    required this.accountDetails,
    this.onVerify,
    this.onEdit,
    super.key,
  });

  @override
  State<AccountDetailsDialog> createState() => _AccountDetailsDialogState();
}

class _AccountDetailsDialogState extends State<AccountDetailsDialog> {
  late TextEditingController _accountNameController;
  late TextEditingController _swiftCodeController;

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(
      text: widget.accountDetails.accountHolderName,
    );
    _swiftCodeController = TextEditingController(
      text: widget.accountDetails.swiftCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Apply glass effect
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context),
              SizedBox(height: 20),
              // Input fields
              _buildInputFields(context, isDark),
              SizedBox(height: 24),
              // Action buttons
              _buildActionButtons(context),
              SizedBox(height: 12),
              // Footer
              _buildFooterInfo(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods...
}
```

---

### 6. **Referral Page**

**File Location**: `lib/ui/screens/referral/referral_page.dart`

**Design Reference**: `/docs/UI_Design/Referral.jpg`

#### Layout Structure
```
┌─────────────────────────────────────┐
│ 🎁 Referral Program                 │ (Header with icon)
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Earn 100 Coins per referral!   │ │ (Benefit card - glass)
│ │ Your Unique Code: ABC123XYZ     │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌──────────────────────────────────┐│
│ │ [Copy Code] [Share]             ││ (Action buttons)
│ └──────────────────────────────────┘│
├─────────────────────────────────────┤
│ Referred Friends: 12                │ (Stat card - glass)
│ Total Coins Earned: 1,200 💰        │
├─────────────────────────────────────┤
│ Recent Referrals:                   │ (Section title)
│ ┌─────────────────────────────────┐ │
│ │ John Doe          +100 💰       │ │ (Referral item - glass)
│ │ Joined Feb 1, 2026              │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Jane Smith        +100 💰       │ │
│ │ Joined Jan 28, 2026             │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### Components & Specifications

**6.1 Header Section**
- Icon: Gift emoji or icon (40px)
- Title: "Referral Program" (24px bold)
- Subtitle: "Share the love and earn rewards" (13px secondary)
- Center-aligned, with top padding

**6.2 Benefit Card** (Glass Effect - Accent Intensity)
- Background: Blue gradient (#4A75E8 → #60A5FA)
- Icon: Gift or star (32px, white)
- Title: "Earn 100 Coins per referral!" (16px bold white)
- Code: "Your Unique Code:" (12px white secondary)
- Code Display: "ABC123XYZ" (18px bold white, mono font, highlighted background)
- Padding: 20px
- Margin: 16px
- Border radius: 16px

**6.3 Action Buttons** (below benefit card)
- Copy Code Button:
  - Text: "[Copy Code]"
  - Style: Light glass outline
  - Width: 48% with gap
  - Height: 48px
- Share Button:
  - Text: "[Share]"
  - Style: Blue gradient background
  - Width: 48% with gap
  - Height: 48px
- Row layout, centered

**6.4 Statistics Card** (Glass Effect)
- Two-column layout:
  - Left: "Referred Friends: 12" (18px bold)
  - Right: "Total Coins Earned: 1,200 💰" (18px bold)
- Icons: Friend icon (24px) and coin icon (24px)
- Padding: 16px
- Full width, margin: 16px

**6.5 Recent Referrals Section**
- Section Title: "Recent Referrals" (16px bold)
- List of referral items (Glass Effect):
  - Name: "John Doe" (15px bold primary)
  - Coins Earned: "+100 💰" (14px bold, green/teal)
  - Join Date: "Joined Feb 1, 2026" (12px secondary)
  - Layout: Name (left) | Coins (right) | Date below name
  - Padding: 16px
  - Margin: 8px vertical
  - Border radius: 12px

**6.6 Empty State** (if no referrals)
- Icon: Friends icon (48px, secondary)
- Title: "No Referrals Yet" (16px bold)
- Subtitle: "Share your code to earn coins" (13px secondary)
- Center-aligned

#### Code Template

```dart
class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String referralCode = 'ABC123XYZ';
  int totalReferrals = 12;
  int totalCoinsEarned = 1200;
  List<Referral> recentReferrals = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            SizedBox(height: 16),
            // Benefit Card
            _buildBenefitCard(context, isDark),
            SizedBox(height: 16),
            // Action Buttons
            _buildActionButtons(context),
            SizedBox(height: 24),
            // Statistics Card
            _buildStatisticsCard(context, isDark),
            SizedBox(height: 24),
            // Recent Referrals
            _buildRecentReferrals(context, isDark),
          ],
        ),
      ),
    );
  }

  // Widget methods...
}
```

---

## 🔧 Implementation Guidelines

### 1. **Glass Effect Implementation**

All glass containers must use this pattern for consistency:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(borderRadiusValue),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(borderRadiusValue),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.3),
          width: 1.5,
        ),
      ),
      // content
    ),
  ),
)
```

### 2. **Dark Mode Support**

Every widget must check brightness:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Then use conditional colors:
Color textColor = isDark ? Colors.white : Color(0xFF1A1A1A);
```

### 3. **Typography Consistency**

Always use Google Fonts Nunito:

```dart
Text(
  'Your text',
  style: GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
)
```

### 4. **Spacing Conventions**

- **Vertical gaps**: 8px (small), 12px (medium), 16px (large), 24px (section), 32px (major)
- **Horizontal padding**: 16px standard, 12px for compact layouts
- **Card margins**: 8px vertical, 16px horizontal

### 5. **Border Radius Consistency**

- **Small components** (buttons, chips): 12px
- **Cards/containers**: 16px
- **Modals/dialogs**: 20px
- **Large sections**: 24px

### 6. **Touch Target Sizing**

- Minimum touch targets: 48x48dp (Material Design requirement)
- Buttons: 56px height minimum
- Icon buttons: 48x48px

### 7. **Shadow Usage**

For colored elements (gradients):
```dart
boxShadow: [
  BoxShadow(
    color: primaryColor.withValues(alpha: 0.3),
    blurRadius: 12,
    offset: const Offset(0, 6),
  ),
]
```

For neutral elements:
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  ),
]
```

### 8. **State Management**

All screens should use BLoC/Cubit pattern:

```dart
BlocBuilder<SomeCubit, SomeState>(
  builder: (context, state) {
    if (state is SomeLoadingState) {
      return Center(child: CircularProgressIndicator());
    }
    if (state is SomeSuccessState) {
      return _buildContent(context, state.data);
    }
    if (state is SomeErrorState) {
      return _buildErrorWidget(context, state.error);
    }
    return SizedBox.shrink();
  },
)
```

### 9. **Animation & Transitions**

Use Flutter's built-in animations:

```dart
// For list items
AnimatedList(
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return ScaleTransition(
      scale: animation,
      child: _buildItem(items[index]),
    );
  },
)

// For simple transitions
GestureDetector(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => NextScreen(),
    ));
  },
  child: child,
)
```

### 10. **Error Handling & Empty States**

Every list must have error and empty states:

```dart
if (items.isEmpty) {
  return _buildEmptyState(context);
}

if (error != null) {
  return _buildErrorState(context, error);
}

return ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => _buildItem(items[index]),
);
```

---

## 📂 File Organization

Create files in these locations:

```
lib/
├── ui/
│   ├── screens/
│   │   └── wallet/
│   │       ├── coin_history_screen.dart          (NEW)
│   │       ├── wallet_redeem_screen.dart         (NEW)
│   │       ├── payment_method_selection_screen.dart  (NEW)
│   │       └── account_details_dialog.dart       (NEW)
│   │
│   └── screens/
│       └── referral/
│           └── referral_page.dart                (NEW)
│
├── features/
│   └── wallet/
│       └── screens/
│           └── wallet_screen.dart                (EXTEND - add TransactionHistoryTab)
│
└── models/
    └── (Create data models if needed)
        ├── coin_transaction.dart
        ├── referral.dart
        └── payment_method.dart
```

---

## 🎯 Implementation Checklist

For each screen, ensure:

- [ ] Glass effect applied to all cards/containers
- [ ] Dark mode support (brightness check)
- [ ] Proper typography (Google Fonts Nunito)
- [ ] Correct color palette usage
- [ ] Touch target sizes (48x48dp minimum)
- [ ] Error and empty states
- [ ] BLoC/Cubit integration
- [ ] Proper spacing and padding
- [ ] Responsive design (mobile-first)
- [ ] Semantic accessibility labels
- [ ] Remove unused imports
- [ ] Format with `dart format`
- [ ] No compilation warnings/errors

---

## 🚀 Dependencies

Verify these are in `pubspec.yaml`:

```yaml
flutter:
  sdk: flutter
  
google_fonts: ^latest
flutter_bloc: ^latest
dio: ^latest (for API calls)
hive: ^latest (for local caching)
intl: ^latest (for date formatting)
```

---

## 📝 Code Style Standards

- **Naming**: camelCase for variables, PascalCase for classes
- **Comments**: Use `///` for public documentation
- **Line length**: Max 100 characters
- **Imports**: Organized (dart, flutter, packages, relative)
- **Constants**: Use `const` where possible for performance

Example:
```dart
/// Displays a glass-morphism card with transaction details
class TransactionCard extends StatelessWidget {
  /// The transaction data to display
  final PaymentRequest transaction;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;

  const TransactionCard({
    required this.transaction,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

---

## 🧪 Testing Checklist

After implementation:

1. **Visual Testing**
   - [ ] Light mode appearance
   - [ ] Dark mode appearance
   - [ ] Tablet/Desktop responsiveness
   - [ ] Glass effect clarity

2. **Functional Testing**
   - [ ] Navigation between screens
   - [ ] Input validation
   - [ ] Loading states
   - [ ] Error handling
   - [ ] Empty states

3. **Accessibility Testing**
   - [ ] Screen reader compatibility
   - [ ] Touch target sizes
   - [ ] Color contrast ratios
   - [ ] Semantic labels

4. **Performance Testing**
   - [ ] Smooth animations (60fps)
   - [ ] No jank during scrolling
   - [ ] Quick load times
   - [ ] Memory usage

---

## 🎨 Reference Resources

**Design Files Location**: `/docs/UI_Design/`

**Color Reference**: 
- Primary Blue: #4A75E8 → #60A5FA
- Teal: #14B8A6 → #06B6D4
- Success Green: #10B981
- Warning Orange: #F59E0B
- Error Red: #EF4444

**Typography Reference**:
- Font: Google Fonts Nunito
- Family: Work Sans, Inter (fallbacks)

**Existing Implementation Examples**:
- [Dashboard Glassmorphism Complete](file:///c%3A/xampp/htdocs/mquizapp/DASHBOARD_GLASSMORPHISM_UPDATE_COMPLETE.md)
- [Glassmorphism Redesign Complete](file:///c%3A/xampp/htdocs/mquizapp/GLASSMORPHISM_REDESIGN_COMPLETE.md)
- [Monetization Widgets](file:///c%3A/xampp/htdocs/mquizapp/lib/features/wallet/widgets/monetization_widgets.dart)

---

## 📞 Support & Clarifications

For implementation questions:

1. Refer to existing glassmorphism implementations
2. Check the design files in `/docs/UI_Design/`
3. Review the color palette and typography specs
4. Follow the code templates provided above
5. Maintain consistency with existing screens

---

**Status**: ✅ Ready for Coding Agent  
**Last Updated**: February 3, 2026  
**Target Completion**: February 10, 2026  

---

## Notes for Coding Agent

- **Priority**: High - These are monetization-critical screens
- **Scope**: 6 screens + extensions to existing wallet screen
- **Estimated LOC**: ~2500-3500 lines of production code
- **Design System**: Already established - ensure strict consistency
- **Testing**: Critical for financial screens - thorough validation required
- **Dark Mode**: Non-negotiable - test thoroughly in both themes
