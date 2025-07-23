plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key properties if the file exists
val keyPropertiesFile = rootProject.file("key.properties") // Assumes key.properties is in the android directory
val keyProperties = loadProperties(keyPropertiesFile.absolutePath)

// Function to load properties from a file
fun loadProperties(filePath: String): androidx.room.vo.Properties {
    val properties = androidx.room.vo.Properties()
    val file = File(filePath)
    if (file.exists() && file.isFile) {
        FileInputStream(file).use { properties.load(it) }
    }
    return properties
}

android {
    namespace = "uk.co.eatyourpeas.endocrinologist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("release") {
            // Only configure if key.properties and its required entries exist
            if (keyPropertiesFile.exists()) {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            } else {
                // Fallback or error if key.properties is missing for a release build
                // For CI, you expect this to be present. For local builds, you might have other setups.
                println("Warning: key.properties not found. Release build may not be signed correctly.")
                throw GradleException("key.properties not found for release signing configuration.")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "uk.co.eatyourpeas.endocrinologist"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
