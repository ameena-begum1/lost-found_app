buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15") // Google Services Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.20") 
        classpath("com.android.tools.build:gradle:8.0.2") 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Corrected Kotlin DSL syntax for the clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}