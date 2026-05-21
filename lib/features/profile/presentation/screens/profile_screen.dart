// lib/features/profile/presentation/screens/profile_screen.dart
// User profile screen showing avatar, display name, watchlist/watched stats,
// extended viewing stats, and settings (language, password, logout, delete account).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:movie_watchlist/features/profile/presentation/providers/profile_providers.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/l10n/app_localizations.dart';
import 'package:movie_watchlist/core/localization/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

// ─── Avatar color provider (persisted locally) ───────────────────────────────

const _kAvatarColorKey = 'profile_avatar_color';

/// Persists the user's chosen avatar background colour in [SharedPreferences].
final _avatarColorProvider = StateNotifierProvider<_AvatarColorNotifier, Color>(
  (ref) {
    return _AvatarColorNotifier();
  },
);

/// Manages the avatar colour state and persists it to [SharedPreferences].
class _AvatarColorNotifier extends StateNotifier<Color> {
  _AvatarColorNotifier() : super(AppColors.primary) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_kAvatarColorKey);
    if (value != null) state = Color(value);
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAvatarColorKey, color.toARGB32());
  }
}

// ─── Preset avatar colors ─────────────────────────────────────────────────────

const _avatarColors = [
  Color(0xFFE50914), // red (primary)
  Color(0xFF1565C0), // blue
  Color(0xFF2E7D32), // green
  Color(0xFF6A1B9A), // purple
  Color(0xFFE65100), // orange
  Color(0xFF00838F), // teal
  Color(0xFFC62828), // dark red
  Color(0xFF4527A0), // deep purple
  Color(0xFF00695C), // dark teal
  Color(0xFF558B2F), // olive
];

// ─── Screen ───────────────────────────────────────────────────────────────────

/// User profile screen.
///
/// Shows the user's avatar (with colour picker), display name (editable),
/// email, watchlist/watched counts, extended stats (total watch time, favourite
/// genre), and a settings section (language, change password, about, logout,
/// delete account).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authState = ref.watch(authStateChangesProvider);
    final watchlistAsync = ref.watch(watchlistStreamProvider);
    final watchedAsync = ref.watch(watchedStreamProvider);
    final avatarColor = ref.watch(_avatarColorProvider);
    final l10n = AppLocalizations.of(context)!;

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final watchlistCount = watchlistAsync.valueOrNull?.length ?? 0;
        final watchedCount = watchedAsync.valueOrNull?.length ?? 0;
        final displayName = user.displayName;
        final initials = _initials(displayName, user.email);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(l10n.profile),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Avatar ──
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () => _showAvatarColorPicker(avatarColor),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: avatarColor,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAvatarColorPicker(avatarColor),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.color_lens,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Display name ──
                GestureDetector(
                  onTap: () => _showEditNameDialog(displayName),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName?.isNotEmpty == true
                            ? displayName!
                            : 'Add your name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: displayName?.isNotEmpty == true
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── Email ──
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Stats ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: l10n.watchlist,
                          value: watchlistCount.toString(),
                          icon: Icons.bookmark,
                          onTap: () => context.push('/watchlist'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: l10n.watched,
                          value: watchedCount.toString(),
                          icon: Icons.visibility,
                          onTap: () => context.push('/watched'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Extended Stats ──
                _ExtendedStatsCard(watchedAsync: watchedAsync),

                const SizedBox(height: 28),

                // ── Settings ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.language,
                        title: ref.watch(localeProvider).languageCode == 'en'
                            ? '${l10n.language} (Eng)'
                            : '${l10n.language} (አማርኛ)',
                        onTap: () => _showLanguageDialog(),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () => context.push('/change-password'),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () => context.push('/about'),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _SettingsTile(
                        icon: Icons.logout,
                        title: l10n.logout,
                        textColor: AppColors.error,
                        onTap: () => _showLogoutDialog(),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _SettingsTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Delete Account',
                        textColor: AppColors.error,
                        onTap: () =>
                            _showDeleteAccountDialog(user.uid, user.email),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Derives initials from [displayName] (first letters of first two words)
  /// or falls back to the first letter of [email].
  String _initials(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  void _showAvatarColorPicker(Color current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Choose avatar color',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _avatarColors.map((color) {
            final isSelected = color.toARGB32() == current.toARGB32();
            return GestureDetector(
              onTap: () {
                ref.read(_avatarColorProvider.notifier).setColor(color);
                Navigator.of(ctx).pop();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(String? current) {
    final controller = TextEditingController(text: current ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Display name',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(authRepositoryProvider)
                    .updateDisplayName(name.isEmpty ? null : name);
                ref.invalidate(authStateChangesProvider);
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.logout,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.logoutConfirmation,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authRepositoryProvider).signOut();
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(String uid, String? email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'This will permanently delete your account and all data. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (email != null && email.isNotEmpty) {
                _showReauthForDeleteDialog(uid, email);
              } else {
                _deleteAccount(uid);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showReauthForDeleteDialog(String uid, String email) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirm Identity',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to confirm account deletion.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccount(
                uid,
                email: email,
                password: passwordController.text,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(
    String uid, {
    String? email,
    String? password,
  }) async {
    final result = await ref.read(deleteAccountUseCaseProvider)(
      DeleteAccountParams(uid: uid, email: email, password: password),
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go('/login');
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.selectLanguage,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.english,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(
                l10n.amharic,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              trailing: currentLocale.languageCode == 'am'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('am'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

/// A tappable stat card showing an icon, numeric value, and label.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A settings list tile with an icon, title, and optional custom text colour.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ─── Extended stats card ──────────────────────────────────────────────────────

/// Computes and displays total watch time and favourite genre from the
/// watched history. Hidden when the watched list is empty.
class _ExtendedStatsCard extends ConsumerWidget {
  final AsyncValue<List<WatchlistItem>> watchedAsync;

  const _ExtendedStatsCard({required this.watchedAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreAsync = ref.watch(genreMapProvider);

    return watchedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        // Total watch time
        int totalMinutes = 0;
        final genreFrequency = <int, int>{};

        for (final item in items) {
          final runtime = (item.data['runtime'] as num?)?.toInt() ?? 0;
          totalMinutes += runtime;

          final genreIds =
              (item.data['genre_ids'] as List?)
                  ?.map((e) => e as int)
                  .toList() ??
              [];
          for (final id in genreIds) {
            genreFrequency[id] = (genreFrequency[id] ?? 0) + 1;
          }
        }

        final hours = totalMinutes ~/ 60;
        final mins = totalMinutes % 60;
        final watchTimeStr = totalMinutes > 0 ? '${hours}h ${mins}m' : '—';

        // Favorite genre
        String favoriteGenre = '—';
        if (genreFrequency.isNotEmpty) {
          final topId = genreFrequency.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          favoriteGenre = genreAsync.valueOrNull?[topId] ?? '—';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stats',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _StatsRow(
                  icon: Icons.access_time,
                  label: 'Total watch time',
                  value: watchTimeStr,
                ),
                const SizedBox(height: 8),
                _StatsRow(
                  icon: Icons.favorite_outline,
                  label: 'Favorite genre',
                  value: favoriteGenre,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatsRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
