#!/bin/bash
set -e

mkdir -p app/src/main/java/com/pet
mkdir -p app/src/main/assets
mkdir -p app/src/main/res/mipmap-xxhdpi

HTML=$(ls -1 *.html *.HTML *.htm 2>/dev/null | head -1)
echo "网页文件 = $HTML"
cp "$HTML" app/src/main/assets/index.html

cat > settings.gradle <<'EOF'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "PixelPet"
include ':app'
EOF

cat > build.gradle <<'EOF'
plugins { id 'com.android.application' version '8.1.4' apply false }
EOF

cat > app/build.gradle <<'EOF'
plugins { id 'com.android.application' }
android {
namespace 'com.pet'
compileSdk 34
defaultConfig {
applicationId "com.pet.pixelpet"
minSdk 21
targetSdk 34
versionCode 1
versionName "1.0"
}
buildTypes { release { minifyEnabled false } }
compileOptions {
sourceCompatibility JavaVersion.VERSION_17
targetCompatibility JavaVersion.VERSION_17
}
}
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
<uses-permission android:name="android.permission.VIBRATE" />
<application android:label="小桌宠" android:icon="@mipmap/ic_launcher" android:hardwareAccelerated="true" android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen">
<activity android:name=".MainActivity" android:exported="true" android:configChanges="orientation|screenSize|keyboardHidden|uiMode">
<intent-filter>
<action android:name="android.intent.action.MAIN" />
<category android:name="android.intent.category.LAUNCHER" />
</intent-filter>
</activity>
</application>
</manifest>
EOF

cat > app/src/main/java/com/pet/MainActivity.java <<'EOF'
package com.pet;
import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
public class MainActivity extends Activity {
private WebView web;
protected void onCreate(Bundle b) {
super.onCreate(b);
getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
getWindow().setStatusBarColor(0xFF17171B);
getWindow().setNavigationBarColor(0xFF17171B);
web = new WebView(this);
WebSettings s = web.getSettings();
s.setJavaScriptEnabled(true);
s.setDomStorageEnabled(true);
s.setDatabaseEnabled(true);
s.setAllowFileAccess(true);
s.setAllowContentAccess(true);
s.setUseWideViewPort(true);
s.setLoadWithOverviewMode(true);
web.setBackgroundColor(0xFF17171B);
web.setWebViewClient(new WebViewClient());
setContentView(web);
web.loadUrl("file:///android_asset/index.html");
immersive();
}
private void immersive() {
getWindow().getDecorView().setSystemUiVisibility(
View.SYSTEM_UI_FLAG_LAYOUT_STABLE
| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
| View.SYSTEM_UI_FLAG_FULLSCREEN
| View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
}
public void onWindowFocusChanged(boolean f) {
super.onWindowFocusChanged(f);
if (f) immersive();
}
}
EOF

cat > icon.py <<'EOF'
import zlib, struct, os, math
W = H = 144
U = 144.0 / 330.0
glow = lambda x, y: tuple(int(a + (b - a) * max(0.0, 1.0 - math.hypot(x - 72.0, y - 72.0) / 89.28)) for a, b in zip((23, 23, 27), (58, 34, 40)))
px = [[glow(x, y) for x in range(W)] for y in range(H)]
R = lambda x0, y0, x1, y1, c: [px[y].__setitem__(x, c) for y in range(int(round(y0)), int(round(y1))) for x in range(int(round(x0)), int(round(x1))) if 0 <= x < W and 0 <= y < H]
PS = 7.22 * U
POX = 49.5 * U
POY = 72.2 * U
P = lambda x, y, w, h, c: R(POX + x * PS, POY + y * PS, POX + (x + w) * PS, POY + (y + h) * PS, c)
HF = [(1, 0, 2, 1), (4, 0, 2, 1), (0, 1, 7, 1), (0, 2, 7, 1), (1, 3, 5, 1), (2, 4, 3, 1), (3, 5, 1, 1)]
WD = lambda hx, hy, hs, c: [R(hx + a * hs, hy + b * hs, hx + (a + w) * hs, hy + (b + h) * hs, c) for (a, b, w, h) in HF]
BODY = (229, 151, 124)
DARK = (224, 142, 115)
INK = (26, 26, 26)
WHITE = (252, 244, 240)
CHEEK = (255, 143, 168)
HRT = (255, 95, 166)
P(0, 10, 3, 4, DARK)
P(29, 10, 3, 4, DARK)
P(3, 5, 26, 14, BODY)
P(5, 19, 3, 3, BODY)
P(11, 19, 3, 3, BODY)
P(18, 19, 3, 3, BODY)
P(24, 19, 3, 3, BODY)
P(4.5, 11.5, 2.5, 1.5, CHEEK)
P(25, 11.5, 2.5, 1.5, CHEEK)
P(8, 11.7, 2, 1.0, INK)
P(22, 10, 2, 4, INK)
P(22, 10, 0.7, 1.1, WHITE)
WD(7.2, 20.7, 3.24, HRT)
WD(115.2, 11.7, 3.24, HRT)
raw = b''.join(b'\x00' + b''.join(bytes(p) for p in row) for row in px)
ck = lambda t, d: struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
data = b'\x89PNG\r\n\x1a\n' + ck(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0)) + ck(b'IDAT', zlib.compress(raw, 9)) + ck(b'IEND', b'')
os.makedirs('app/src/main/res/mipmap-xxhdpi', exist_ok=True)
open('app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 'wb').write(data)
print('icon ok')
EOF
python3 icon.py

if command -v gradle >/dev/null 2>&1; then
echo "使用系统 Gradle"
else
echo "下载 Gradle