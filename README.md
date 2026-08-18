# كورة اونلاين - مباريات اليوم — Flutter MVP v0.2.0

تطبيق نتائج ومباريات عربي RTL بهوية **كورة اونلاين**، مبني بطبقة Data قابلة للاستبدال.

## الهوية الثابتة
- اسم البراند داخل التطبيق: كورة اونلاين
- اسم Google Play: كورة اونلاين - مباريات اليوم
- Package ID: `com.koraonline.matches`
- Version: `0.2.0+2`

## الموجود حاليًا
- الرئيسية
- مباريات اليوم
- المباراة الأبرز
- البطولات
- الهدافون
- الفرق
- اللاعبون
- تفاصيل المباراة الأساسية
- RTL + Dark UI
- Repository/Data layer منفصلة
- Live source + local JSON fallback أثناء التطوير

## البيانات المربوطة حاليًا
- `/web/games/current/`
- `/web/games/featured/`
- `/web/stats/`
- `/web/competitions/top/`
- `/web/competitors/top/`
- `/web/athletes/top/`

## Cloud build بدون Android Studio
المشروع يحتوي Workflow في:
`.github/workflows/build-preview-aab.yml`

الـWorkflow يولّد Android platform تلقائيًا بالحزمة `com.koraonline.matches` ثم يبني AAB Preview في GitHub Actions.

> ملاحظة: قبل أول رفع Production على Google Play سنثبت Upload Key دائم ونحوّل Workflow إلى Release-signed AAB. لا تعتمد على Preview signing للنشر النهائي.
