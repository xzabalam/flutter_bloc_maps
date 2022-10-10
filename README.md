# Flutter - Google Maps - MapBox
Se debe crear los siguientes archivos en las siguientes rutas,

> android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_maps_app">

    <!-- INTERNET -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- GPS -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

   <application
        android:label="flutter_maps_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />

       <!-- GoogleMaps API Key -->
       <meta-data android:name="com.google.android.geo.API_KEY"
           android:value="${GOOGLE_API_KEY}"/>
    </application>
</manifest>
```

> ios/Runner/AppDelegate.m

```swift
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"${IOS_API_KEY}"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

> ios/Runner/AppDelegate.swift
```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("${IOS_API_KEY}")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```



# API Keys Security Checklist
Para generar el archivo env.g.dart se debe seguir los siguientes pasos:

1. En la ruta del proyecto se debe crear un archivo de propiedades, en este archivo se almacenará los API KEYS en texto plano.

>.env

```properties
# ACCESS_TOKEN
MAP_BOX_ACCESS_TOKEN=${API_KEY_DE_MAPBOX}
# URL_ACCESS
URL_MAP_BOX_API=https://api.mapbox.com/directions/v5/mapbox
SEARCH_MAP_BOX_API=https://api.mapbox.com/geocoding/v5/mapbox.places
```

2. Añadir .env al archivo .gitignore
3. Instalar el paquete ENVied 
```shell
$ flutter pub add envied
$ flutter pub add --dev envied_generator
$ flutter pub add --dev build_runner
```

4. Crear un archivo llamado env.dart y definir la clase con uno o más campos para cada línea del archivo .env, se debe usar la propiedad obfuscate: true para las API KEY.  El archivo puede quedar de la siguiente manera:

```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAP_BOX_ACCESS_TOKEN', obfuscate: true)
  static final mapBoxApiKey = _Env.mapBoxApiKey;

  @EnviedField(varName: 'URL_MAP_BOX_API')
  static const urlMapBoxApi = _Env.urlMapBoxApi;

  @EnviedField(varName: 'SEARCH_MAP_BOX_API')
  static const searchMapBoxApi = _Env.searchMapBoxApi;
}

```

6. Para generar el archivo env.g.dart se debe ejecutar en una consola el siguiente comando desde la raiz del proyecto:

```shell
$ flutter pub run build_runner build --delete-conflicting-outputs
```

6. Añadir env.g.dart a .gitignore
7. Para utilizar estas propiedades creadas se lo puede hacer de la siguiente manera:
```dart
import 'package:flutter_maps_app/config/env/env.dart';

final urlSearchMapBoxApi = Env.urlMapBoxApi;
final url = '${Env.urlMapBoxApi}?access_token=${Env.mapBoxApiKey}';
```

# Referencias

https://www.udemy.com/course/flutter-avanzado-fernando-herrera/

Para asegurar las apis de google, mapbox, se usa
https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/

Para convertir json a DTO se usa
https://app.quicktype.io/

Para seleccionar el estilo del mapa 
https://snazzymaps.com/

Api de MapBox
https://docs.mapbox.com/playground/directions/

https://github.com/bizz84/movie_app_state_management_flutter

https://medium.com/flutter-community/how-to-setup-dart-define-for-keys-and-secrets-on-android-and-ios-in-flutter-apps-4f28a10c4b6c

Security, AppStoreKey
https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/

Markers 
https://medium.com/flutter-community/ad-custom-marker-images-for-your-google-maps-in-flutter-68ce627107fc

Widget to image
https://medium.com/flutter-community/export-your-widget-to-image-with-flutter-dc7ecfa6bafb

https://stackoverflow.com/questions/60203604/how-to-get-get-png-from-custompainter-in-flutter/60206381#60206381
