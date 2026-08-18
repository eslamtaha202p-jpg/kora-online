import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/sports_repository.dart';
import 'competitions_screen.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'more_screen.dart';
import 'teams_screen.dart';

class AppShell extends StatefulWidget {
  final SportsRepository repository;

  const AppShell({super.key, required this.repository});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  RepositorySnapshot? snapshot;
  Object? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.repository.loadDashboard();
      if (!mounted) return;
      setState(() { snapshot = data; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e; loading = false; });
    }
  }

  @override
  void dispose() {
    widget.repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = snapshot;
    final screens = data == null
        ? const <Widget>[]
        : [
            HomeScreen(snapshot: data, onRefresh: _reload),
            MatchesScreen(matches: data.currentMatches),
            CompetitionsScreen(competitions: data.competitions, scorers: data.scorers),
            TeamsScreen(teams: data.teams, players: data.players),
            MoreScreen(snapshot: data),
          ];

    return Scaffold(
      body: loading && data == null
          ? const _LoadingView()
          : error != null && data == null
              ? _ErrorView(error: error!, onRetry: _reload)
              : IndexedStack(index: index, children: screens),
      bottomNavigationBar: data == null ? null : NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), selectedIcon: Icon(Icons.sports_soccer), label: 'المباريات'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'البطولات'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'الفرق'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'المزيد'),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.danger),
        const SizedBox(height: 12),
        const Text('تعذر تحميل البيانات', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 6),
        Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ]),
    ),
  );
}
