# ─────────────────────────────────────────────────────────────────────────────
# android/app/proguard-rules.pro  —  EatPlek Customer App
# ─────────────────────────────────────────────────────────────────────────────

# ── Flutter / Dart ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── PhonePe Payment SDK ───────────────────────────────────────────────────────
-keep class com.phonepe.** { *; }
-dontwarn com.phonepe.**

# ── OneSignal ─────────────────────────────────────────────────────────────────
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# ── flutter_local_notifications ───────────────────────────────────────────────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ── Cloudinary ────────────────────────────────────────────────────────────────
-keep class com.cloudinary.** { *; }
-dontwarn com.cloudinary.**

# ── OkHttp / Retrofit (used internally by some SDKs) ─────────────────────────
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# ── Keep model/data classes (prevents R8 from stripping JSON-mapped fields) ───
# Adjust package path to match your actual model package
-keep class com.eatplek.app.** { *; }

# ── General safety ────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ── Suppress common harmless warnings ────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
