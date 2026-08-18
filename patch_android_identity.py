from pathlib import Path

APP_ID = "com.koraonline.matches"
APP_LABEL = "كورة اونلاين - مباريات اليوم"

manifest = Path("android/app/src/main/AndroidManifest.xml")
if manifest.exists():
    text = manifest.read_text(encoding="utf-8")
    import re
    text = re.sub(r'android:label="[^"]*"', f'android:label="{APP_LABEL}"', text, count=1)
    manifest.write_text(text, encoding="utf-8")

for name in ("android/app/build.gradle.kts", "android/app/build.gradle"):
    path = Path(name)
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8")
    import re
    text = re.sub(r'(applicationId\s*[= ]\s*["\'])([^"\']+)(["\'])', rf'\g<1>{APP_ID}\g<3>', text)
    text = re.sub(r'(namespace\s*[= ]\s*["\'])([^"\']+)(["\'])', rf'\g<1>{APP_ID}\g<3>', text)
    path.write_text(text, encoding="utf-8")
