import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState extends State<AdminSystemSettingsScreen> {
  // General Settings
  String _systemName = 'Interactive MultiDomain OSS';
  String _systemVersion = 'v2.3.1';
  String _timezone = 'UTC';
  String _language = 'English';
  bool _maintenanceMode = false;
  bool _debugMode = false;

  // Security Settings
  int _sessionTimeout = 30;
  bool _twoFactorAuth = true;
  bool _passwordExpiry = true;
  int _passwordExpiryDays = 90;
  int _maxLoginAttempts = 5;
  bool _ipWhitelist = false;

  // Notification Settings
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _slackIntegration = true;

  // Performance Settings
  int _maxConcurrentUsers = 1000;
  int _sessionCacheSize = 100;
  bool _enableCompression = true;
  String _logLevel = 'INFO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildGeneralSettings(),
            const SizedBox(height: 16),
            _buildSecuritySettings(),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            _buildPerformanceSettings(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Settings',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure system-wide settings and preferences',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFF3b82f6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'General Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'System Name',
            _systemName,
            (val) => _systemName = val,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'System Version',
            _systemVersion,
            (val) => _systemVersion = val,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Timezone',
            _timezone,
            ['UTC', 'EST', 'PST', 'GMT', 'CET'],
            (val) {
              setState(() => _timezone = val!);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Language',
            _language,
            ['English', 'Spanish', 'French', 'German', 'Chinese'],
            (val) {
              setState(() => _language = val!);
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Maintenance Mode',
            'Enable system maintenance mode',
            _maintenanceMode,
            (val) {
              setState(() => _maintenanceMode = val);
            },
          ),
          _buildSwitchTile('Debug Mode', 'Enable debug logging', _debugMode, (
            val,
          ) {
            setState(() => _debugMode = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFFef4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Security Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSliderTile(
            'Session Timeout',
            '$_sessionTimeout minutes',
            _sessionTimeout,
            10,
            120,
            (val) {
              setState(() => _sessionTimeout = val.round());
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Two-Factor Authentication',
            'Require 2FA for all users',
            _twoFactorAuth,
            (val) {
              setState(() => _twoFactorAuth = val);
            },
          ),
          _buildSwitchTile(
            'Password Expiry',
            'Force password change periodically',
            _passwordExpiry,
            (val) {
              setState(() => _passwordExpiry = val);
            },
          ),
          if (_passwordExpiry) ...[
            const SizedBox(height: 16),
            _buildSliderTile(
              'Password Expiry Days',
              '$_passwordExpiryDays days',
              _passwordExpiryDays,
              30,
              180,
              (val) {
                setState(() => _passwordExpiryDays = val.round());
              },
            ),
          ],
          const SizedBox(height: 16),
          _buildSliderTile(
            'Max Login Attempts',
            '$_maxLoginAttempts attempts',
            _maxLoginAttempts,
            3,
            10,
            (val) {
              setState(() => _maxLoginAttempts = val.round());
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'IP Whitelist',
            'Enable IP address restrictions',
            _ipWhitelist,
            (val) {
              setState(() => _ipWhitelist = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFF10b981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            'Email Notifications',
            'Send alerts via email',
            _emailNotifications,
            (val) {
              setState(() => _emailNotifications = val);
            },
          ),
          _buildSwitchTile(
            'SMS Notifications',
            'Send alerts via SMS',
            _smsNotifications,
            (val) {
              setState(() => _smsNotifications = val);
            },
          ),
          _buildSwitchTile(
            'Push Notifications',
            'Send browser push notifications',
            _pushNotifications,
            (val) {
              setState(() => _pushNotifications = val);
            },
          ),
          _buildSwitchTile(
            'Slack Integration',
            'Post alerts to Slack channels',
            _slackIntegration,
            (val) {
              setState(() => _slackIntegration = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b5cf6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.speed,
                  color: Color(0xFF8b5cf6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSliderTile(
            'Max Concurrent Users',
            '$_maxConcurrentUsers users',
            _maxConcurrentUsers,
            100,
            5000,
            (val) {
              setState(() => _maxConcurrentUsers = val.round());
            },
          ),
          const SizedBox(height: 16),
          _buildSliderTile(
            'Session Cache Size',
            '$_sessionCacheSize MB',
            _sessionCacheSize,
            50,
            500,
            (val) {
              setState(() => _sessionCacheSize = val.round());
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Enable Compression',
            'Compress HTTP responses',
            _enableCompression,
            (val) {
              setState(() => _enableCompression = val);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Log Level',
            _logLevel,
            ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
            (val) {
              setState(() => _logLevel = val!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          enabled: enabled,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161b22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF21262d)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF21262d)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3b82f6)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3b82f6),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    int currentValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3b82f6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3b82f6),
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: currentValue.toDouble(),
          min: min,
          max: max,
          activeColor: const Color(0xFF3b82f6),
          inactiveColor: const Color(0xFF21262d),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Save settings
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3b82f6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Reset to defaults
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF21262d)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset to Defaults',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
