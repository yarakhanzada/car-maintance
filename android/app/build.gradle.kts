plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.senior_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // التعديل الصحيح للغة Kotlin (KTS)
        isCoreLibraryDesugaringEnabled = true 
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // حل مشكلة الـ Deprecated
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.senior_project"
        
        // رفع الـ minSdk ضروري للـ Desugaring
        minSdk = flutter.minSdkVersion 
        
        multiDexEnabled = true
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // التعديل الصحيح لإضافة المكتبة في ملف KTS
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
