# 📋 Admin Navigation Menu - Add to Sidebar

## Location
File: `admin_backend/application/views/header.php`

## Where to Add
Find the sidebar menu section (usually around line 100-200, look for other menu items with `<li class="dropdown">`)

## Code to Add

```html
<!-- Referral System Menu (Anti-Farming Protection) -->
<li class="dropdown">
    <a href="#" class="nav-link has-dropdown">
        <i class="fas fa-users-cog"></i> <span>Referral System</span>
    </a>
    <ul class="dropdown-menu">
        <li>
            <a class="nav-link" href="<?= base_url('referral-dashboard') ?>">
                <i class="fas fa-chart-line"></i> Dashboard
            </a>
        </li>
        <li>
            <a class="nav-link" href="<?= base_url('referral-activity') ?>">
                <i class="fas fa-list-alt"></i> Activity Log
            </a>
        </li>
        <li>
            <a class="nav-link" href="<?= base_url('referral-fraud-review') ?>">
                <i class="fas fa-exclamation-triangle"></i> Fraud Review
                <?php
                // Show badge if there are pending fraud cases
                $pending_fraud = $this->db->query("
                    SELECT COUNT(*) as count 
                    FROM tbl_referral_fraud_checks 
                    WHERE resolved = 0 AND severity IN ('high', 'critical')
                ")->row();
                if ($pending_fraud && $pending_fraud->count > 0):
                ?>
                    <span class="badge badge-danger"><?= $pending_fraud->count ?></span>
                <?php endif; ?>
            </a>
        </li>
        <li>
            <a class="nav-link" href="<?= base_url('referral-settings') ?>">
                <i class="fas fa-cog"></i> Settings
            </a>
        </li>
    </ul>
</li>
```

## Alternative: Simple Single Menu Item (if you prefer)

```html
<!-- Referral System - Single Link -->
<li>
    <a class="nav-link" href="<?= base_url('referral-dashboard') ?>">
        <i class="fas fa-users-cog"></i> <span>Referral System</span>
    </a>
</li>
```

## Where to Place It
**Recommended position:** After "Users" or "System Settings" menu items

## Icons Used
- `fa-users-cog` - Main menu icon (settings + users)
- `fa-chart-line` - Dashboard
- `fa-list-alt` - Activity log
- `fa-exclamation-triangle` - Fraud review (with warning badge)
- `fa-cog` - Settings

## Badge Notification
The fraud review menu item includes a red badge showing count of high/critical priority fraud cases requiring manual review.

## Screenshot Preview
```
├─ 📊 Dashboard
├─ 👥 Users
├─ ⚙️ System Settings
├─ 👥⚙️ Referral System          ← Add here
│  ├─ 📈 Dashboard
│  ├─ 📋 Activity Log
│  ├─ ⚠️ Fraud Review (🔴 3)
│  └─ ⚙️ Settings
└─ 🚪 Logout
```

## Testing After Adding
1. Save header.php
2. Clear browser cache
3. Refresh admin panel
4. Look for "Referral System" in sidebar
5. Click to verify all 4 links work

## Troubleshooting
- **Menu not showing:** Check for PHP syntax errors in header.php
- **Links not working:** Verify routes.php was updated correctly
- **Badge not showing:** Check database connection in header.php context
