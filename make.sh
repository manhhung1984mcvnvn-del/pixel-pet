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
    <application
        android:label="小桌宠"
        android:icon="@mipmap/ic_launcher"
        android:hardwareAccelerated="true"
        android:theme="@android:style/Theme.Black.NoTitleBar.Fullscreen">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden|uiMode">
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

    @Override
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
        s.setMediaPlaybackRequiresUserGesture(false);
        if (Build.VERSION.SDK_INT >= 21) {
            s.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        }
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

    @Override
    public void onWindowFocusChanged(boolean f) {
        super.onWindowFocusChanged(f);
        if (f) immersive();
    }
}
EOF

ICON() { if command -v magick >/dev/null 2>&1; then magick "$@"; else convert "$@"; fi; }
ICON -size 144x144 xc:'#17171b' -draw "
fill #e5977c rectangle 16,34 128,112
fill #e08e73 rectangle 6,64 16,86
fill #e08e73 rectangle 128,64 138,86
fill #e5977c rectangle 22,112 34,128
fill #e5977c rectangle 44,112 56,128
fill #e5977c rectangle 66,112 78,128
fill #e5977c rectangle 88,112 100,128
fill #ff8fa8 rectangle 22,70 42,80
fill #ff8fa8 rectangle 102,70 122,80
fill #1a1a1a rectangle 84,56 96,84
fill #1a1a1a rectangle 48,68 72,76
fill #fcf4f0 rectangle 86,58 90,64
fill #ff5fa6 rectangle 62,14 70,22
fill #ff5fa6 rectangle 74,14 82,22
fill #ff5fa6 rectangle 56,20 88,32
fill #ff5fa6 rectangle 60,32 84,40
fill #ff5fa6 rectangle 66,40 78,48
" app/src/main/res/mipmap-xxhdpi/ic_launcher.png

echo "图标 ok"
gradle assembleDebug --no-daemon