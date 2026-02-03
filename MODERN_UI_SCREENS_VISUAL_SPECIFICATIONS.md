# Modern UI Screens - Visual Design Specifications

## 📊 Design Overview

This document provides detailed visual specifications for the 6 modern UI screens being implemented for the mQuiz Flutter application. All designs follow the glassmorphism design system with the "Liquid Glass Effect."

---

## 1️⃣ Coin History Screen

### Screen Purpose
Display user's coin earning and spending history with filterable transactions.

### Design Elements

#### Color Scheme
| Element                 | Color           | Alpha                    | Usage              |
| ----------------------- | --------------- | ------------------------ | ------------------ |
| Glass Background        | White           | 0.9 (light), 0.08 (dark) | Container base     |
| Glass Border            | White           | 0.3 (light), 0.15 (dark) | Container outline  |
| Header Text             | #1A1A1A / White | 1.0                      | Primary text       |
| Secondary Text          | #666666 / White | 0.7                      | Helper text        |
| Balance Card Background | Blue Gradient   | -                        | #4A75E8 → #60A5FA  |
| Add Transaction (+)     | Teal/Green      | -                        | Success indication |
| Remove Transaction (-)  | Orange/Red      | -                        | Loss indication    |

#### Layout Breakdown

```
┌─ Top Navigation (60px)
│  ├─ Back Button (48x48)
│  └─ Title "Coin History" (20px bold)
├─ Balance Card (120px height)
│  ├─ Emoji Icon (40px)
│  ├─ "Total Balance" Label (12px)
│  └─ Amount "5,420" (28px bold)
├─ Filter Chips Row (60px)
│  ├─ [Today] [Week] [Month] [All]
│  └─ Active: Blue gradient, Inactive: Light glass
├─ Transaction List (Scrollable)
│  ├─ Item Height: 80px
│  ├─ Padding: 16px horizontal, 8px vertical
│  ├─ Structure:
│  │  ├─ Emoji (24px, left)
│  │  ├─ Amount (16px bold) + Description (12px)
│  │  └─ Time (11px, right-aligned)
│  └─ Glass effect with 1px border
└─ Empty State (if no transactions)
   ├─ Icon (48px)
   ├─ Title (16px bold)
   └─ Subtitle (13px secondary)
```

#### Spacing Reference
- Status bar height: 24px (iOS), 0px (Android - handled by system)
- App bar height: 56px
- Balance card: 120px (with 16px vertical padding = effective 88px content)
- Filter chips row: 60px total (48px chips + 12px padding)
- Transaction item gap: 8px
- Bottom safe area: 16px (iOS safe area handled by app)

#### Typography Details

| Element            | Font   | Size | Weight | Color           |
| ------------------ | ------ | ---- | ------ | --------------- |
| Page Title         | Nunito | 20px | 700    | Primary         |
| Balance Label      | Nunito | 12px | 400    | White/Secondary |
| Balance Amount     | Nunito | 28px | 700    | White           |
| Filter Chip        | Nunito | 13px | 600    | Primary/White   |
| Transaction Amount | Nunito | 16px | 700    | Primary         |
| Transaction Desc   | Nunito | 12px | 400    | Secondary       |
| Time               | Nunito | 11px | 400    | Tertiary        |

#### Interactive Elements

**Filter Chips**
- Default: Light glass container, secondary text
- Pressed: Scale animation (0.95)
- Selected: Blue gradient background, white text
- Transition: 200ms ease

**Transaction Item**
- Tap feedback: Slightly scale down (0.98)
- Press: Opacity change (0.8)
- Long press: Show context menu (delete, duplicate, etc.)
- Swipe left: Delete action

#### Responsive Considerations
- **Mobile (< 600px)**: 
  - Filter chips: Horizontal scroll if > 3 visible
  - Transaction items: Full width minus 16px padding
  - Font sizes: Decrease by 1-2px if space constrained
  
- **Tablet (600px - 900px)**:
  - Transaction items: 2-column grid
  - Balance card: Wider (80% max width)
  
- **Desktop (> 900px)**:
  - 3-column grid for transactions
  - Sidebar with date range picker

---

## 2️⃣ Wallet Redemption Screen

### Screen Purpose
Allow users to redeem their coins for real currency with amount selection and rate preview.

### Design Elements

#### Color Scheme
| Element          | Color                 | Usage               |
| ---------------- | --------------------- | ------------------- |
| Primary Gradient | #4A75E8 → #60A5FA     | Buttons, highlights |
| Success Green    | #10B981               | Conversion display  |
| Warning Orange   | #F59E0B               | Fee alerts          |
| Text Primary     | #1A1A1A / White       | Headers             |
| Text Secondary   | #666666 / White @ 0.7 | Descriptions        |

#### Layout Breakdown

```
┌─ Header Section (100px)
│  ├─ Title "Redeem Your Coins" (20px bold)
│  └─ Subtitle "Convert your coins to real money" (13px)
│
├─ Available Balance Card (120px, Glass effect)
│  ├─ Icon: Coin emoji (32px)
│  ├─ Label: "Available Balance" (12px)
│  ├─ Value: "5,420 💰" (24px bold)
│  └─ Padding: 20px
│
├─ Redemption Terms Card (100px, Glass effect)
│  ├─ Row 1: "Minimum: 1,000 Coins" (12px)
│  └─ Row 2: "You'll Get: $50.00 USD" (13px bold)
│
├─ Input Section (180px)
│  ├─ Label: "Enter Amount to Redeem" (13px bold)
│  ├─ Input Field (48px height, glass)
│  │  ├─ Value: "1000"
│  │  ├─ Suffix: "Coins"
│  │  └─ Placeholder: "Enter amount in coins"
│  ├─ Slider (48px height with visual track)
│  │  ├─ Min: 1,000
│  │  ├─ Max: Available balance
│  │  ├─ Track color: Light blue
│  │  └─ Thumb: Blue gradient
│  └─ Conversion: "Receive: $50.00 USD" (14px bold, success green)
│
├─ Spacing Buffer (16px)
│
└─ Action Button Section (56px + 12px safe area)
   └─ "Continue to Payment Setup" (Full width, blue gradient)
```

#### Input Field Design
- **Type**: TextFormField with custom decoration
- **Height**: 48px
- **Padding**: 12px horizontal, 8px vertical
- **Border**: Glass style (1px white @ 0.3)
- **Border radius**: 12px
- **Background**: Glass effect (white @ 0.9 light, white @ 0.08 dark)
- **Cursor color**: Blue (#4A75E8)
- **Text color**: Primary
- **Placeholder color**: Secondary @ 0.5

#### Slider Implementation
- **Type**: CupertinoSlider or Material Slider
- **Height**: 48px (with labels)
- **Track height**: 8px
- **Thumb radius**: 12px
- **Min value**: 1000
- **Max value**: availableBalance
- **Divisions**: (availableBalance - 1000) ~/ 100 (for granular steps)
- **Colors**:
  - Inactive track: Light blue (#DBEAFE)
  - Active track: Blue gradient start (#4A75E8)
  - Thumb: Blue gradient (#4A75E8)

#### Spacing Details
- Card gaps: 12px
- Vertical sections: 24px
- Bottom to button: 32px
- Input to slider: 12px
- Slider to conversion: 16px

#### Typography Details

| Element     | Font   | Size | Weight |
| ----------- | ------ | ---- | ------ |
| Page Title  | Nunito | 20px | 700    |
| Subtitle    | Nunito | 13px | 400    |
| Card Label  | Nunito | 12px | 400    |
| Card Value  | Nunito | 24px | 700    |
| Input Label | Nunito | 13px | 700    |
| Input Text  | Nunito | 14px | 400    |
| Conversion  | Nunito | 14px | 700    |
| Button      | Nunito | 16px | 700    |

#### Interactive Behavior

**Input Field**
- Focus: Border color changes to blue, slight glow effect
- Input validation: Real-time check against min/max
- Error state: Border color changes to red, error message below
- Success: Green checkmark appears if valid amount

**Slider**
- Continuous update of conversion display
- Haptic feedback on value changes (iOS)
- Visual "snap" to round numbers (every 100 coins)

**Conversion Display**
- Real-time calculation as user types or slides
- Formula: (coinsEntered / 20) * exchangeRate
- Color change: Green when valid, Orange when approaching limit
- Animation: Fade in/out when value changes

---

## 3️⃣ Transaction History Tab

### Screen Purpose
Display all past redemption requests with status and filtering.

### Design Elements

#### Color Scheme
| Status     | Color            | Icon        |
| ---------- | ---------------- | ----------- |
| Pending    | #F59E0B (Orange) | ⏳ Clock     |
| Completed  | #10B981 (Green)  | ✅ Checkmark |
| Failed     | #EF4444 (Red)    | ❌ X         |
| Processing | #8B5CF6 (Purple) | ⚙️ Gear      |

#### Tab Bar Design
```
┌─────────────────────────────────────┐
│ [Redemption] [Transactions] [Settings] │
│  ═══════════════════════════════════  │ (Blue underline for active)
└─────────────────────────────────────┘
```

- **Height**: 48px
- **Tab items**: Equal width distribution
- **Active indicator**: 3px blue line at bottom
- **Indicator animation**: 300ms curve
- **Font**: Nunito 14px, weight 600
- **Active color**: Blue (#4A75E8)
- **Inactive color**: Secondary (#666666)

#### Transaction Card Layout

```
┌─ Status Badge (left, 8px)
│  ├─ Color: Status dependent (Orange/Green/Red)
│  └─ Size: 4px wide, card height tall
│
├─ Content Area (flex)
│  ├─ Row 1: "Request #5240" (14px bold) + Status "Pending" (12px orange)
│  │         Date on right "Feb 3, 2:45 PM" (11px secondary)
│  │
│  ├─ Row 2: "2,500 Coins" (bold) → "$125.00 USD" (secondary)
│  │         Exchange rate display
│  │
│  └─ Row 3: Progress bar (optional)
│         Shows processing progress if pending
│
└─ Right Arrow (for detail view)
```

- **Card Height**: 100px
- **Padding**: 16px
- **Border radius**: 12px
- **Glass effect**: Standard
- **Status badge width**: 4px
- **Content gap**: 8px between rows

#### Filter Chips
- **Position**: Above transaction list
- **Chips**: [All] [Pending] [Completed] [Failed]
- **Default**: "All" selected
- **Style**: Same as coin history filters

#### Empty State Design
```
┌──────────────────────────┐
│                          │
│     📋 Icon (48px)       │
│                          │
│ "No Transactions Yet"    │ (16px bold)
│ "Start by redeeming..."  │ (13px secondary)
│                          │
│ [Start Redeeming]        │ (Primary button)
│                          │
└──────────────────────────┘
```

#### Spacing Reference
- Filter row height: 60px
- Transaction card gap: 8px
- Card padding: 16px
- Status badge: 4px wide, full height

#### Typography Details

| Element      | Size | Weight |
| ------------ | ---- | ------ |
| Tab Label    | 14px | 600    |
| Request ID   | 14px | 700    |
| Status Label | 12px | 600    |
| Coin Amount  | 14px | 700    |
| USD Amount   | 12px | 400    |
| Date/Time    | 11px | 400    |

---

## 4️⃣ Payment Method Selection Screen

### Screen Purpose
Allow users to select their preferred payment method for redemption.

### Design Elements

#### Color Scheme
| Element            | Color            | Usage                    |
| ------------------ | ---------------- | ------------------------ |
| Recommended Badge  | Green (#10B981)  | "Recommended" indicator  |
| Processing Normal  | Blue (#4A75E8)   | Standard processing time |
| Processing Instant | Green (#10B981)  | Fast processing          |
| Processing Slow    | Orange (#F59E0B) | Slow processing          |

#### Section Layout

```
┌─ Header (80px)
│  ├─ Title: "Select Payment Method" (20px bold)
│  └─ Subtitle: "Choose how you want to receive..." (13px)
│
├─ "Recommended" Section Header (32px)
│  ├─ Text: "Recommended for Fast Processing:" (13px bold)
│  └─ Left border accent (3px blue)
│
├─ Method Cards (Recommended) (100px each)
│  ├─ Radio Button (left, 24px)
│  ├─ Content
│  │  ├─ Method Name: "Bank Transfer" (16px bold)
│  │  ├─ Time Badge: "(2-3 days)" (12px secondary)
│  │  └─ Description: "• Low fees, Secure" (12px secondary)
│  └─ Glass effect, full width
│
├─ "Other Methods" Section Header (32px)
│  └─ Same style as above
│
├─ Method Cards (Other) (100px each)
│  └─ Same as recommended
│
├─ Spacing Buffer (24px)
│
├─ Fee Information (40px)
│  ├─ "Fees: $5.00 (Estimated)" (12px secondary, right-aligned)
│  └─ Color: Warning orange
│
└─ Action Button (56px)
   └─ "Continue with [Method Name]" (Full width, blue gradient)
```

#### Method Card Design

**Selected State**:
- Radio button: Filled (blue)
- Border: 2px blue
- Background: Light blue overlay (0.05 alpha)
- Shadow: Blue tinted

**Unselected State**:
- Radio button: Empty circle
- Border: Standard glass
- Background: Standard glass
- Shadow: Neutral

**Disabled State**:
- Opacity: 0.5
- Cursor: Not allowed
- No interaction

#### Radio Button
- **Size**: 24px diameter
- **Selected**: Blue circle fill (#4A75E8)
- **Unselected**: Circle outline (2px border)
- **Animation**: Snap (100ms)

#### Typography Details

| Element         | Size | Weight |
| --------------- | ---- | ------ |
| Section Header  | 13px | 700    |
| Method Name     | 16px | 700    |
| Processing Time | 12px | 400    |
| Description     | 12px | 400    |
| Fee Info        | 12px | 400    |
| Button          | 16px | 700    |

#### Spacing Details
- Header bottom: 20px
- Section header top: 16px
- Section header bottom: 8px
- Card gap: 8px
- Card padding: 16px
- Fee info top: 24px
- Button top: 16px

---

## 5️⃣ Account Details Dialog

### Screen Purpose
Display and edit user's bank account or payment information.

### Design Elements

#### Dialog Structure

```
╔═══════════════════════════════════╗ (20px border radius)
║ Account Details              ✕    ║ (Header bar, 56px)
╠═══════════════════════════════════╣
║                                   ║
║ Bank Account Information:         ║ (Section title, 13px bold)
║                                   ║
║ ┌─────────────────────────────────┐║ (Input field)
║ │ Account Name                    ││
║ │ [John Doe                     ]││ (Editable, 48px)
║ └─────────────────────────────────┘║
║                                   ║
║ ┌─────────────────────────────────┐║ (Input field)
║ │ Account Number                  ││
║ │ [••••••••5678              ]  ││ (Readonly, masked)
║ └─────────────────────────────────┘║
║                                   ║
║ ┌─────────────────────────────────┐║ (Dropdown)
║ │ Bank Name                       ││
║ │ [National Bank USA          ▼]││ (Selector, 48px)
║ └─────────────────────────────────┘║
║                                   ║
║ ┌─────────────────────────────────┐║ (Input field)
║ │ SWIFT Code                      ││
║ │ [NABAUS33                     ]││ (Editable, 48px)
║ └─────────────────────────────────┘║
║                                   ║
║ ✓ Account verified on Feb 3   (11px) ║ (Success indicator)
║                                   ║
║ ┌──────────────────────────────────┐║ (Primary button)
║ │ Verify Account                 ││ (56px height)
║ └──────────────────────────────────┘║
║                                   ║
║ ┌──────────────────────────────────┐║ (Secondary button)
║ │ Edit Account Details           ││ (48px height)
║ └──────────────────────────────────┘║
║                                   ║
║ Your details are encrypted & secure║ (Footer, 11px)
║                                   ║
╚═══════════════════════════════════╝
```

#### Dialog Sizing
- **Width**: 85% of screen (min 300px, max 400px)
- **Max height**: 90% of screen
- **Scrollable**: If content exceeds max height
- **Background**: Glass effect with darker overlay (0.3 alpha)

#### Input Field Design
**Standard Glass Input Field**
- **Height**: 48px
- **Padding**: 12px horizontal, 8px vertical
- **Border**: Glass style (1px white @ 0.3)
- **Border radius**: 12px
- **Label**: Above field, 12px secondary
- **Label gap**: 4px

**Field States**
- **Default**: Glass background, placeholder text
- **Focus**: Blue border glow, cursor visible
- **Error**: Red border, error message below
- **Readonly**: Disabled state (opacity 0.6), no cursor

**Masked Input (Account Number)**
- Display: "••••••••5678"
- Tooltip on hover: "This field is protected"
- Copy button (optional): Copies unmasked to clipboard with toast

#### Dropdown (Bank Selector)
- **Height**: 48px
- **Glass effect**: Standard
- **Icon**: Chevron down (right side)
- **Behavior**: Opens modal list or native picker
- **List items**: 48px height each

#### Verification Badge
- **Layout**: Icon + Text
- **Icon**: Green checkmark (16px)
- **Text**: "Account verified on Feb 3, 2026" (11px)
- **Color**: Success green (#10B981)
- **Position**: Below last input
- **Margin**: 12px top

#### Buttons

**Primary Button (Verify Account)**
- **Height**: 56px
- **Width**: Full width of dialog - padding
- **Background**: Blue gradient (#4A75E8 → #60A5FA)
- **Text**: White, 16px bold
- **Border radius**: 12px
- **Disabled**: Opacity 0.5, no interaction

**Secondary Button (Edit Account Details)**
- **Height**: 48px
- **Width**: Full width
- **Background**: Light glass (white @ 0.2)
- **Text**: Blue (#4A75E8), 14px bold
- **Border**: 1px blue
- **Border radius**: 12px
- **Gap between buttons**: 8px

#### Footer Info
- **Text**: "Your account details are encrypted and secure" (11px)
- **Color**: Tertiary gray
- **Alignment**: Center
- **Position**: Bottom of dialog

#### Spacing Details
- **Header padding**: 16px
- **Content padding**: 20px all sides
- **Section gap**: 16px
- **Input gap**: 12px
- **Button gap**: 8px
- **Footer margin**: 12px top

---

## 6️⃣ Referral Page

### Screen Purpose
Promote referral program and display referral statistics and list.

### Design Elements

#### Color Scheme
| Element         | Color             | Usage            |
| --------------- | ----------------- | ---------------- |
| Accent Gradient | #4A75E8 → #60A5FA | Benefit card     |
| Text on Accent  | White             | Text on gradient |
| Success Green   | #10B981           | Earned coins     |
| Stat Numbers    | Bold Primary      | Statistics       |

#### Page Layout

```
┌─ Status Bar (Safe area top)
│
├─ Header Section (100px)
│  ├─ Icon: Gift/Star (40px)
│  ├─ Title: "Referral Program" (24px bold)
│  └─ Subtitle: "Share the love and earn rewards" (13px secondary)
│
├─ Benefit Card - Blue Gradient (120px, Glass overlay)
│  ├─ Icon: Gift (32px, white)
│  ├─ Title: "Earn 100 Coins per referral!" (16px bold white)
│  ├─ Code Label: "Your Unique Code:" (12px white secondary)
│  ├─ Code Display:
│  │  ├─ Value: "ABC123XYZ" (18px bold white, mono font)
│  │  ├─ Background: Darker glass or highlight box
│  │  └─ Copy feedback: Haptic + Toast
│  └─ Padding: 20px, Border radius: 16px
│
├─ Action Buttons Row (60px)
│  ├─ Copy Code Button (48% width)
│  │  ├─ Icon: Copy icon (16px)
│  │  ├─ Text: "Copy Code" (14px)
│  │  ├─ Background: Light glass outline
│  │  └─ Height: 48px
│  │
│  ├─ Spacer (4%)
│  │
│  └─ Share Button (48% width)
│     ├─ Icon: Share icon (16px)
│     ├─ Text: "Share" (14px)
│     ├─ Background: Blue gradient
│     ├─ Text Color: White
│     └─ Height: 48px
│
├─ Statistics Card (100px, Glass effect)
│  ├─ Left Side
│  │  ├─ Icon: Friends (24px, blue)
│  │  ├─ Label: "Referred Friends" (11px secondary)
│  │  └─ Value: "12" (20px bold)
│  │
│  ├─ Divider: Vertical line (height 60px, center)
│  │
│  └─ Right Side
│     ├─ Icon: Coins (24px, teal)
│     ├─ Label: "Total Coins Earned" (11px secondary)
│     └─ Value: "1,200 💰" (20px bold)
│
├─ Spacing Buffer (24px)
│
├─ Recent Referrals Section Header (40px)
│  ├─ Title: "Recent Referrals" (16px bold)
│  ├─ Subtitle: "Last 10 referrals" (12px secondary)
│  └─ Optional: Sort button
│
├─ Referral List (Scrollable)
│  ├─ Item Height: 80px
│  ├─ Padding: 16px
│  ├─ Glass effect
│  │
│  ├─ Content Layout:
│  │  ├─ Top Row:
│  │  │  ├─ Name: "John Doe" (15px bold, left)
│  │  │  └─ Coins: "+100 💰" (14px bold teal, right)
│  │  │
│  │  └─ Bottom Row:
│  │     └─ Join Date: "Joined Feb 1, 2026" (12px secondary)
│  │
│  └─ Item Gap: 8px
│
├─ Empty State (if no referrals)
│  ├─ Icon: Friends icon (48px, secondary)
│  ├─ Title: "No Referrals Yet" (16px bold)
│  └─ Subtitle: "Share your code to earn coins" (13px secondary)
│
└─ Safe Area Bottom (16px)
```

#### Benefit Card Details

**Background**: Linear gradient
- From: #4A75E8 (top-left)
- To: #60A5FA (bottom-right)
- Shadow: Blue (#4A75E8) @ 0.3 alpha

**Code Display Container** (within benefit card)
- **Background**: Darker glass overlay (white @ 0.15)
- **Border**: 1px white @ 0.3
- **Padding**: 12px
- **Border radius**: 8px
- **Font**: Mono font (Courier New or similar)
- **Letter spacing**: 2px (for readability)

**Copy Button Feedback**:
- **Visual**: Text changes to "Copied!" for 2 seconds
- **Haptic**: Light haptic feedback (iOS)
- **Toast**: Brief toast notification "Code copied to clipboard"

#### Action Buttons

**Copy Code Button**
- **Type**: Outlined
- **Border**: 1px white @ 0.3
- **Background**: Light glass (white @ 0.1)
- **Text**: Primary color
- **Icon**: Copy icon (16px)
- **Hover**: Slight scale up (1.02)

**Share Button**
- **Type**: Filled gradient
- **Background**: Blue gradient (#4A75E8 → #60A5FA)
- **Text**: White
- **Icon**: Share icon (16px)
- **Native Share Sheet**: Uses platform native sharing

#### Statistics Card

**Layout**: Two-column with vertical divider

**Left Column (Friends)**
- **Icon**: Friends/user group icon (24px, color: #4A75E8)
- **Label**: "Referred Friends" (11px, secondary)
- **Value**: Large number (20px bold)

**Divider**
- **Type**: Vertical line
- **Color**: White @ 0.2
- **Height**: ~60px (centered)
- **Width**: 1px

**Right Column (Coins)**
- **Icon**: Coins icon (24px, color: #14B8A6)
- **Label**: "Total Coins Earned" (11px, secondary)
- **Value**: Large number + emoji (20px bold)

#### Referral Item Card

```
┌─────────────────────────────┐
│ John Doe          +100 💰   │ (Names on left, coins on right)
│ Joined Feb 1, 2026          │ (Date below name)
└─────────────────────────────┘
```

**Design Details**:
- **Name color**: Primary text
- **Coins color**: Success green/teal (#10B981 or #14B8A6)
- **Date color**: Secondary gray
- **Padding**: 16px
- **Border radius**: 12px
- **Glass effect**: Standard

#### Typography Details

| Element       | Font    | Size | Weight |
| ------------- | ------- | ---- | ------ |
| Page Title    | Nunito  | 24px | 700    |
| Page Subtitle | Nunito  | 13px | 400    |
| Benefit Title | Nunito  | 16px | 700    |
| Referral Code | Courier | 18px | 700    |
| Stat Value    | Nunito  | 20px | 700    |
| Stat Label    | Nunito  | 11px | 400    |
| Referral Name | Nunito  | 15px | 700    |
| Referral Date | Nunito  | 12px | 400    |

#### Spacing Reference

| Element        | Top  | Bottom | Left | Right |
| -------------- | ---- | ------ | ---- | ----- |
| Header         | 16px | 16px   | 16px | 16px  |
| Benefit Card   | 12px | 20px   | 16px | 16px  |
| Action Buttons | 12px | 20px   | 16px | 16px  |
| Stats Card     | 12px | 20px   | 16px | 16px  |
| Section Header | 16px | 8px    | 16px | 16px  |
| Referral Items | 0px  | 0px    | 0px  | 0px   |
| Item Gap       | -    | 8px    | -    | -     |

---

## 🎨 General Design Standards

### Glass Effect Application

All glass containers follow this pattern:

**Light Mode**:
- Background: white @ 0.9 alpha
- Border: white @ 0.3 alpha (1.5px)
- Blur: 12px (σ)

**Dark Mode**:
- Background: white @ 0.08 alpha
- Border: white @ 0.15 alpha (1.5px)
- Blur: 12px (σ)

### Shadow Standards

**For Gradient Elements** (blue/teal cards):
```
Blur radius: 12px
Offset: (0, 6)
Alpha: 0.3
Color: Gradient start color
Example: Color(0xFF4A75E8).withValues(alpha: 0.3)
```

**For Neutral Elements**:
```
Blur radius: 8px
Offset: (0, 4)
Alpha: 0.1
Color: Colors.black
```

### Border Radius Standards

| Component          | Radius |
| ------------------ | ------ |
| Small inputs/chips | 12px   |
| Standard cards     | 16px   |
| Modals/dialogs     | 20px   |
| Large sections     | 24px   |

### Animation Standards

| Action           | Duration | Easing      | Type          |
| ---------------- | -------- | ----------- | ------------- |
| Tap feedback     | 100ms    | ease-out    | Scale to 0.98 |
| Slide transition | 300ms    | ease-in-out | Custom        |
| Fade in          | 200ms    | ease-in     | Opacity 0→1   |
| Chip selection   | 200ms    | ease-out    | Color change  |
| Dialog open      | 250ms    | ease-out    | Scale + fade  |

---

## 📋 Implementation Checklist

For each screen, verify:

- [ ] All glass containers use standard pattern
- [ ] Colors match palette specification
- [ ] Typography uses Nunito font
- [ ] Spacing follows guidelines
- [ ] Dark mode colors applied
- [ ] Interactive elements have proper feedback
- [ ] Border radius values correct
- [ ] Shadows use correct blur and offset
- [ ] Touch targets minimum 48x48px
- [ ] Images/icons are optimized
- [ ] Loading states designed
- [ ] Error states designed
- [ ] Empty states included
- [ ] Responsive breakpoints tested

---

**Last Updated**: February 3, 2026  
**Design System**: Glassmorphism + Liquid Glass Effect  
**Target Platform**: Flutter (iOS & Android)  
**Figma File**: /docs/UI_Design/ (reference folder)
