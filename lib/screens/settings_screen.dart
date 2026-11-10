import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ai_insights_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _obscureApiKey = true;
  bool _isTestingKey = false;
  String? _testResultText;
  bool? _testResultSuccess;

  static const _accentColors = [
    _AccentOption('Flame', Color(0xFFFF5722)),
    _AccentOption('Rose', Color(0xFFE53935)),
    _AccentOption('Ocean', Color(0xFF1E88E5)),
    _AccentOption('Forest', Color(0xFF43A047)),
    _AccentOption('Sunset', Color(0xFFFB8C00)),
    _AccentOption('Violet', Color(0xFF8E24AA)),
    _AccentOption('Teal', Color(0xFF00897B)),
    _AccentOption('Indigo', Color(0xFF3949AB)),
    _AccentOption('Amber', Color(0xFFFFB300)),
  ];

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: ref.read(settingsProvider).groqApiKey,
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Appearance ──────────────────────────────
          _SectionCard(
            children: [
              _SectionTitle(icon: Icons.palette_outlined, title: 'Appearance'),
              const SizedBox(height: 20),

              // Theme Mode
              Text(
                'THEME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _ThemeSelector(
                current: settings.themeMode,
                onChanged: (mode) {
                  HapticFeedback.selectionClick();
                  notifier.updateThemeMode(mode);
                },
                colorScheme: cs,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // Accent Color
              Text(
                'ACCENT COLOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _AccentColorPicker(
                colors: _accentColors,
                selected: settings.seedColor,
                onChanged: (color) {
                  HapticFeedback.selectionClick();
                  notifier.updateSeedColor(color);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Units ───────────────────────────────────
          _SectionCard(
            children: [
              _SectionTitle(icon: Icons.straighten_outlined, title: 'Units'),
              const SizedBox(height: 20),
              Text(
                'WEIGHT UNIT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _UnitSelector(
                current: settings.weightUnit,
                onChanged: (unit) {
                  HapticFeedback.selectionClick();
                  notifier.updateWeightUnit(unit);
                },
                colorScheme: cs,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── AI Coach ────────────────────────────────
          _SectionCard(
            children: [
              _SectionTitle(icon: Icons.auto_awesome_outlined, title: 'AI Coach'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Get your free API key at console.groq.com',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                obscureText: _obscureApiKey,
                style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'gsk_...',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.key_outlined, size: 20, color: cs.onSurfaceVariant),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureApiKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle_outline, size: 20, color: cs.primary),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          final cleanedKey = _apiKeyController.text.trim();
                          notifier.updateGroqApiKey(cleanedKey);
                          ref.read(aiCoachProvider.notifier).refreshInsight();
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('API Key saved & AI Coach refreshed!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  notifier.updateGroqApiKey(value.trim());
                  if (_testResultText != null) {
                    setState(() {
                      _testResultText = null;
                      _testResultSuccess = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isTestingKey
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            final key = _apiKeyController.text.trim();
                            if (key.isEmpty) {
                              setState(() {
                                _testResultSuccess = false;
                                _testResultText = 'Please enter an API key first';
                              });
                              return;
                            }
                            setState(() {
                              _isTestingKey = true;
                              _testResultText = null;
                            });
                            // Save it first
                            notifier.updateGroqApiKey(key);
                            final result = await AiCoachNotifier.testConnection(key);
                            if (mounted) {
                              setState(() {
                                _isTestingKey = false;
                                _testResultSuccess = result['success'] == true;
                                _testResultText = result['success'] == true
                                    ? 'Connected to Groq successfully (${result['model']})!'
                                    : '${result['error']}';
                              });
                              if (result['success'] == true) {
                                ref.read(aiCoachProvider.notifier).refreshInsight();
                              }
                            }
                          },
                    icon: _isTestingKey
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check_rounded, size: 16),
                    label: Text(_isTestingKey ? 'Testing...' : 'Test Connection'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ],
              ),
              if (_testResultText != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _testResultSuccess == true
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _testResultSuccess == true
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testResultSuccess == true ? Icons.check_circle : Icons.error_outline,
                        color: _testResultSuccess == true ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testResultText!,
                          style: TextStyle(
                            color: _testResultSuccess == true ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ── Account ─────────────────────────────────
          Consumer(builder: (context, ref, _) {
            final authState = ref.watch(authStateProvider);
            final userEmail = authState.value?.email ?? 'Unknown User';

            return _SectionCard(
              children: [
                _SectionTitle(icon: Icons.person_outline_rounded, title: 'Account'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.person, color: cs.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userEmail,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Signed in',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(authControllerProvider).signOut();
                    },
                    icon: Icon(Icons.logout_rounded, size: 18, color: cs.error),
                    label: Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w600, color: cs.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // ── App Info ────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'AV Fitness',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.8.5',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section Card — groups related settings in a rounded card
// ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF121212)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF262626)
              : const Color(0xFFE5E5E5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section Title with icon
// ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Custom Theme Selector (replaces SegmentedButton)
// ─────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ThemeSelector({
    required this.current,
    required this.onChanged,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeChip(
          icon: Icons.brightness_auto_rounded,
          label: 'Auto',
          isSelected: current == ThemeMode.system,
          onTap: () => onChanged(ThemeMode.system),
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _ThemeChip(
          icon: Icons.light_mode_rounded,
          label: 'Light',
          isSelected: current == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _ThemeChip(
          icon: Icons.dark_mode_rounded,
          label: 'Dark',
          isSelected: current == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : (isDark ? const Color(0xFF262626) : Colors.transparent),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Accent Color Picker
// ─────────────────────────────────────────────────────────

class _AccentOption {
  final String name;
  final Color color;
  const _AccentOption(this.name, this.color);
}

class _AccentColorPicker extends StatelessWidget {
  final List<_AccentOption> colors;
  final Color selected;
  final ValueChanged<Color> onChanged;

  const _AccentColorPicker({
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((option) {
        final isSelected = selected == option.color;
        return GestureDetector(
          onTap: () => onChanged(option.color),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: option.color.withValues(alpha: 0.45),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Custom Unit Selector (replaces SegmentedButton)
// ─────────────────────────────────────────────────────────

class _UnitSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  final ColorScheme colorScheme;
  final bool isDark;

  const _UnitSelector({
    required this.current,
    required this.onChanged,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UnitChip(
          label: 'Kilograms',
          subtitle: 'kg',
          isSelected: current == 'kg',
          onTap: () => onChanged('kg'),
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _UnitChip(
          label: 'Pounds',
          subtitle: 'lbs',
          isSelected: current == 'lbs',
          onTap: () => onChanged('lbs'),
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDark;

  const _UnitChip({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : (isDark ? const Color(0xFF262626) : Colors.transparent),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
