import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFFDFB),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative circles
            if (!isDark) ...[
              // Top-right circle (mint green)
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8EEDC).withOpacity(0.44),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Bottom-left circle (peach)
              Positioned(
                left: -80,
                bottom: -20,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9A7).withOpacity(0.48),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
          // Pet Profile Card
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: const Text(
                      '🐾',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'O-Lulu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '體重：4.8 kg | 貓咪',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('編輯資料功能即將推出！')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Settings Options
          _buildSettingsGroup(
            context,
            '系統設定',
            [
              _buildSettingsTile(
                context,
                icon: Icons.pets_outlined,
                title: '寵物資料設定',
                subtitle: '編輯 O-Lulu 的基本資料與監測目標',
                onTap: () {
                  _showFeaturePlaceholder(context, '寵物資料設定');
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: '通知與警報管理',
                subtitle: '自訂脫水警報與每日進食提醒',
                onTap: () {
                  _showFeaturePlaceholder(context, '通知與警報管理');
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.share_outlined,
                title: '家庭成員共享',
                subtitle: '邀請其他家庭成員共同編輯聯絡簿',
                onTap: () {
                  _showFeaturePlaceholder(context, '家庭成員共享');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildSettingsGroup(
            context,
            '關於',
            [
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: '關於智慧觀測站',
                subtitle: '版本 v1.0.0 (已連接後端主機)',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '智慧成長觀測站',
                    applicationVersion: 'v1.0.0',
                    applicationIcon: const Text('🐾', style: TextStyle(fontSize: 32)),
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          '本系統提供寵物健康即時追蹤，包含體重監測、進食及飲水分析，並透過家庭聯絡簿串聯全家人的照護動態。',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ],
),
),
);
  }

  Widget _buildSettingsGroup(BuildContext context, String groupTitle, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            groupTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => tiles[index],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showFeaturePlaceholder(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「$featureName」功能即將推出，敬請期待！')),
    );
  }
}
