plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ✅ Required for Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.devopify.infogram" // ✅ Match with your Firebase google-services.json
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Match Firebase plugin requirement

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.devopify.infogram" // ✅ Update this to match your Firebase config
        minSdk = 23 // ✅ Firebase Auth now requires minSdkVersion 23+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
