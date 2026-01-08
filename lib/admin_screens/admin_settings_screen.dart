import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // To do: Replace all below values with API-backed settings later

  // Approval flow
  int approvalTimeoutDays = 7;
  int autoEscalationDays = 3;
  bool allowParallelApproval = true;
  bool requireRejectionComment = true;
  bool allowWithdrawals = false;

  // Notifications
  bool emailNotifications = true;
  bool inAppNotifications = true;
  bool dailyDigest = false;
  bool reminderNotifications = true;
  double reminderHours = 24;

  // Security
  int sessionTimeout = 30;
  int passwordExpiry = 90;
  bool twoFactorAuth = false;
  bool auditLogging = true;

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(context),
          const SizedBox(height: 24),

          _approvalFlowCard(),
          const SizedBox(height: 24),

          _notificationCard(),
          const SizedBox(height: 24),

          _securityCard(),
          const SizedBox(height: 120), // space for sticky footer
        ],
      ),
    );
  }

  // ---------------- PAGE HEADER ----------------

  Widget _pageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Settings',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Advanced configuration and workflow controls',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppTheme.textLight),
        ),
      ],
    );
  }

  // ---------------- CARDS ----------------

  Widget _approvalFlowCard() {
    return _settingsCard(
      icon: Icons.low_priority,
      iconColor: AppTheme.primary,
      title: 'Default Approval Flow Settings',
      subtitle: 'Configure default workflow behaviors',
      child: Column(
        children: [
          _numberField(
            label: 'Default Approval Timeout',
            suffix: 'days',
            value: approvalTimeoutDays,
            onChanged: (v) => approvalTimeoutDays = v,
          ),
          _numberField(
            label: 'Auto-escalation after',
            suffix: 'days',
            value: autoEscalationDays,
            onChanged: (v) => autoEscalationDays = v,
          ),
          const Divider(),
          _switchTile(
            'Allow parallel approvals',
            'Enable multiple approvers at the same level',
            allowParallelApproval,
            (v) => setState(() => allowParallelApproval = v),
          ),
          _switchTile(
            'Require comments on rejection',
            'Force approvers to provide a reason',
            requireRejectionComment,
            (v) => setState(() => requireRejectionComment = v),
          ),
          _switchTile(
            'Enable request withdrawals',
            'Allow requestors to cancel pending requests',
            allowWithdrawals,
            (v) => setState(() => allowWithdrawals = v),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard() {
    return _settingsCard(
      icon: Icons.notifications_active,
      iconColor: Colors.purple,
      title: 'Notification Settings',
      subtitle: 'Configure how users receive notifications',
      child: Column(
        children: [
          _switchTile(
            'Email notifications',
            'Send email alerts for new requests',
            emailNotifications,
            (v) => setState(() => emailNotifications = v),
          ),
          _switchTile(
            'In-app notifications',
            'Show notifications within the app',
            inAppNotifications,
            (v) => setState(() => inAppNotifications = v),
          ),
          _switchTile(
            'Daily digest emails',
            'Daily summary of pending approvals',
            dailyDigest,
            (v) => setState(() => dailyDigest = v),
          ),
          const Divider(),
          _switchTile(
            'Reminder notifications',
            'Remind approvers of pending requests',
            reminderNotifications,
            (v) => setState(() => reminderNotifications = v),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder frequency: ${reminderHours.round()} hours',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Slider(
                min: 1,
                max: 72,
                divisions: 71,
                value: reminderHours,
                onChanged: (v) =>
                    setState(() => reminderHours = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityCard() {
    return _settingsCard(
      icon: Icons.lock,
      iconColor: AppTheme.error,
      title: 'Security Settings',
      subtitle: 'Manage security and access settings',
      child: Column(
        children: [
          _numberField(
            label: 'Session timeout',
            suffix: 'minutes',
            value: sessionTimeout,
            onChanged: (v) => sessionTimeout = v,
          ),
          _numberField(
            label: 'Password expiry',
            suffix: 'days',
            value: passwordExpiry,
            onChanged: (v) => passwordExpiry = v,
          ),
          const Divider(),
          _switchTile(
            'Two-factor authentication',
            'Require 2FA for all users',
            twoFactorAuth,
            (v) => setState(() => twoFactorAuth = v),
          ),
          _switchTile(
            'Audit logging',
            'Track all system activities',
            auditLogging,
            (v) => setState(() => auditLogging = v),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _settingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.all(24),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8), // bottom reduced

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _numberField({
    required String label,
    required String suffix,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value.toString()),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: AppTheme.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) {
          final parsed = int.tryParse(v);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }
}
