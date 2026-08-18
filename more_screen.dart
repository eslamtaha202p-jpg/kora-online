import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/sports_repository.dart';

class MoreScreen extends StatelessWidget {
  final RepositorySnapshot snapshot;
  const MoreScreen({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('المزيد', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _item(Icons.star_outline_rounded, 'المفضلة', 'فرقك وبطولاتك ومبارياتك'),
          _item(Icons.notifications_active_outlined, 'التنبيهات', 'أهداف، بداية المباراة، التشكيل'),
          _item(Icons.auto_awesome_outlined, 'ملخص المباراة بالذكاء الاصطناعي', 'سيتم تفعيله بعد اكتمال Game Events'),
          _item(Icons.groups_3_outlined, 'دوري الصحاب', 'التوقعات والنقاط والترتيب'),
          _item(Icons.ios_share_rounded, 'Share Cards', 'كروت نتائج وتوقعات قابلة للمشاركة'),
          _item(Icons.settings_outlined, 'الإعدادات', 'اللغة والتوقيت والمظهر'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: snapshot.usedFallback ? const Color(0x22FF8A1F) : const Color(0x2220D980), borderRadius: BorderRadius.circular(14), border: Border.all(color: snapshot.usedFallback ? AppColors.accent : AppColors.success)),
            child: Row(children: [
              Icon(snapshot.usedFallback ? Icons.offline_bolt_outlined : Icons.cloud_done_outlined, color: snapshot.usedFallback ? AppColors.accent : AppColors.success),
              const SizedBox(width: 10),
              Expanded(child: Text(snapshot.usedFallback ? 'وضع التطوير: يتم استخدام Snapshot محلي عند تعذر المصدر الحي.' : 'المصدر الحي متصل.', style: const TextStyle(fontSize: 11, height: 1.5))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, String subtitle) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
    ),
  );
}
