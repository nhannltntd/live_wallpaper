# Keep Conscrypt classes for OkHttp
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep OkHttp Platform classes
-keep class okhttp3.internal.platform.** { *; }
-dontwarn okhttp3.internal.platform.** 