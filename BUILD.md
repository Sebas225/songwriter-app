# Cómo generar builds de Songwriter

Esta guía explica, paso a paso y sin asumir conocimientos previos, cómo preparar el proyecto y generar instaladores para Android (APK), Windows y macOS.

## 1) Requisitos previos
- Una instalación de **Flutter 3.19 o superior**.
- Acceso a internet para que Flutter descargue dependencias la primera vez.
- El sistema operativo apropiado para cada build:
  - **Android APK:** Windows, macOS o Linux con Android SDK instalado (Flutter lo instala al correr `flutter doctor` si falta).
  - **Windows:** Windows 10/11 con Visual Studio (Desktop development with C++).
  - **macOS:** Mac con Xcode instalado (necesario para compilar apps de Apple).

## 2) Preparar el proyecto (una sola vez)
1. Abre una terminal y ubícate en la carpeta del proyecto.
2. Si faltan las carpetas de plataformas, créalas con Flutter:
   ```bash
   flutter create . --platforms android,windows,macos
   ```
3. Descarga las dependencias del proyecto:
   ```bash
   flutter pub get
   ```
4. Coloca tu imagen de icono (PNG cuadrado, idealmente 1024x1024) en `assets/app_icon.png`.
   - El archivo está ignorado en Git para evitar binarios en el repositorio, así que cada persona debe guardarlo localmente.
5. Asegura que el nombre mostrado de la app sea **Songwriter**:
   - Android: abre `android/app/src/main/res/values/strings.xml` y define `<string name="app_name">Songwriter</string>`.
   - macOS: en `macos/Runner/Configs/AppInfo.xcconfig` revisa que `PRODUCT_NAME = Songwriter`.
   - Windows: en `windows/runner/Runner.rc` busca `FileDescription` y `ProductName` y cambia sus valores a `Songwriter`.
6. Genera los iconos para todas las plataformas usando la imagen base guardada en `assets/app_icon.png`:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

> Tip: Si Flutter muestra advertencias en `flutter doctor`, síguelas hasta que todo aparezca en verde.

## 3) Versionado
- El número de versión se encuentra en `pubspec.yaml` (`version: 1.0.0+1`).
- Cambia la parte antes del `+` para versiones visibles por usuarios (1.0.1, 1.1.0, etc.) y la parte después del `+` para el número interno de compilación.

## 4) Generar builds
### Android (APK para instalar manualmente)
1. Conecta un dispositivo o solo genera el archivo.
2. Ejecuta:
   ```bash
   flutter build apk --release --target-platform android-arm64
   ```
3. El APK final quedará en `build/app/outputs/flutter-apk/app-release.apk`.

### Windows (app de escritorio)
1. Habilita desktop si aún no lo hiciste:
   ```bash
   flutter config --enable-windows-desktop
   ```
2. Ejecuta el build:
   ```bash
   flutter build windows --release
   ```
3. El ejecutable aparecerá en `build/windows/runner/Release/` (archivo `songwriter.exe`).

### macOS (app de escritorio)
1. Habilita desktop en macOS si es la primera vez:
   ```bash
   flutter config --enable-macos-desktop
   ```
2. Compila la app:
   ```bash
   flutter build macos --release
   ```
3. El paquete listo para abrir estará en `build/macos/Build/Products/Release/Songwriter.app`.

## 5) Qué hacer si algo falla
- Corre `flutter doctor` y sigue las instrucciones específicas de cada plataforma.
- Si los iconos no se actualizan, vuelve a ejecutar `flutter pub run flutter_launcher_icons` después de los cambios.
- Para limpiar builds previos, puedes usar `flutter clean` y luego repetir los pasos de compilación.
