# Gps_IA

Estudio comparativo de implementación de **GPS background tracking** (rastreo de ubicación en segundo plano, con la app minimizada o la pantalla bloqueada) entre **Flutter** e **Ionic**, evaluando además el impacto de herramientas de desarrollo asistido por IA: **GitHub Copilot (Codex)** y **Antigravity**.

```
Gps_IA/
├── flutter/      # Implementación nativa-bridge con flutter_background_service + geolocator
├── ionic/        # Implementación con Capacitor sobre WebView
└── README.md
```

---

## Tabla de contenidos

1. [Objetivo del estudio](#objetivo-del-estudio)
2. [Proyecto Flutter](#proyecto-flutter)
3. [Proyecto Ionic](#proyecto-ionic)
4. [Cómo ejecutar cada proyecto](#cómo-ejecutar-cada-proyecto)
5. [Metodología de pruebas](#metodología-de-pruebas)
6. [Comparativa Flutter vs Ionic](#comparativa-flutter-vs-ionic)
7. [Desarrollo asistido por IA: Codex vs Antigravity](#desarrollo-asistido-por-ia-codex-vs-antigravity)
8. [Conclusiones](#conclusiones)
9. [Autor](#autor)

---

## Objetivo del estudio

Determinar qué framework híbrido/multiplataforma ofrece un comportamiento más confiable y eficiente al mantener un servicio de geolocalización activo cuando la aplicación deja de estar en primer plano, y registrar cómo dos asistentes de IA (Codex vía GitHub Copilot, y Antigravity) aceleran o limitan la construcción de este tipo de infraestructura nativa (permisos, servicios de fondo, foreground services).

Ambas implementaciones cubren el mismo caso de uso funcional:

- Solicitar y validar permisos de ubicación (en uso y en segundo plano).
- Iniciar un servicio de fondo persistente.
- Escuchar el stream de posiciones (latitud, longitud, timestamp, precisión).
- Persistir el log de ubicaciones en almacenamiento local.
- Detener el servicio bajo demanda.

---

## Proyecto Flutter

**Ruta:** `/flutter`

### Stack

| Componente | Tecnología |
|---|---|
| Framework | Flutter / Dart |
| Servicio de fondo | `flutter_background_service` ^5.0.9 |
| Geolocalización | `geolocator` ^13.0.1 |
| Persistencia | `shared_preferences` ^2.3.3 |
| Notificaciones | `flutter_local_notifications` ^17.2.2 |

### Arquitectura

```
lib/
  services/
    location_service.dart    # Configuración e inicialización del servicio
    gps_handler.dart         # Lógica del stream GPS dentro del Isolate de fondo
  data/
    location_repository.dart # Persistencia del log (SharedPreferences)
  ui/
    home_screen.dart         # Controles de inicio/parada y visualización del log
  main.dart                  # Llama a initLocationService() antes de runApp()
```

El servicio corre en un **Isolate dedicado**, comunicado con la UI mediante el puerto nativo de `flutter_background_service`. En Android se ejecuta como **Foreground Service** con notificación persistente (obligatorio desde Android 8, con `foregroundServiceType="location"` explícito desde Android 14).

### Permisos clave

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`
- `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `UIBackgroundModes` → `location`, `fetch`, `processing`

---

## Proyecto Ionic

**Ruta:** `/ionic`

### Stack

| Componente | Tecnología |
|---|---|
| Framework | Ionic / Angular |
| Puente nativo | Capacitor |
| Geolocalización | `@capacitor/geolocation` + plugin de background geolocation |
| Persistencia | `@capacitor/preferences` / SQLite local |
| Notificaciones | `@capacitor/local-notifications` |

### Arquitectura

```
src/app/
  services/
    location.service.ts      # Wrapper sobre el plugin de geolocalización
    background-task.service.ts # Gestión del ciclo de vida del proceso de fondo
  pages/
    home/home.page.ts        # Controles de inicio/parada y visualización del log
android/
  app/src/main/AndroidManifest.xml
ios/
  App/App/Info.plist
```

A diferencia de Flutter, en Ionic el rastreo en segundo plano depende completamente del **plugin nativo de Capacitor** instalado (la WebView por sí sola no puede mantenerse activa en background). La persistencia del proceso recae en la capa nativa Android/iOS que el plugin expone hacia JavaScript.

### Permisos clave

Mismos permisos base que en Flutter (`ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE`, `UIBackgroundModes`), pero declarados y sincronizados a través de `capacitor.config.ts` y los proyectos nativos generados por `npx cap sync`.

---

## Cómo ejecutar cada proyecto

### Flutter

```bash
cd flutter
flutter pub get
flutter run            # dispositivo o emulador conectado
```

### Ionic

```bash
cd ionic
npm install
npx cap sync
npx cap run android    # o: npx cap run ios
```

> En ambos casos se recomienda probar primero en un **dispositivo físico**, ya que el comportamiento de los servicios de fondo en emuladores/simuladores no siempre refleja las restricciones reales de batería del fabricante.

---

## Metodología de pruebas

1. Otorgar permisos de ubicación "**Permitir siempre**" (no solo "mientras se usa la app").
2. Deshabilitar la optimización de batería para la app (crítico en Xiaomi/MIUI y Samsung/One UI).
3. Iniciar el rastreo y minimizar la aplicación (Home o gesto de back).
4. Simular o realizar movimiento real durante 5–10 minutos con la app en segundo plano y con la pantalla bloqueada.
5. Reabrir la app y verificar que el log de ubicaciones se haya seguido escribiendo durante todo el intervalo.
6. Repetir la prueba con el dispositivo estático para confirmar que el filtro de distancia evita registros redundantes.

Herramientas usadas: `adb logcat`, `adb shell geo fix`, Xcode → Features → Location (simulador), y caminatas con dispositivo físico para validación en campo.

---

## Comparativa Flutter vs Ionic

| Criterio | Flutter | Ionic (Capacitor) |
|---|---|---|
| Arquitectura de fondo | Isolate dedicado + Foreground Service nativo | Depende de plugin nativo sobre WebView |
| Consumo de batería | _Por completar con datos del estudio_ | _Por completar con datos del estudio_ |
| Complejidad de configuración nativa | Manifest/plist gestionados directamente en el proyecto Flutter | Configuración nativa generada/sincronizada vía Capacitor (`cap sync`), capa adicional de indirección |
| Persistencia del hilo de fondo | Buena; el Isolate sobrevive a la minimización si el Foreground Service está bien declarado | Depende fuertemente de la calidad y mantenimiento del plugin elegido |
| Latencia y precisión GPS | _Por completar con datos del estudio_ | _Por completar con datos del estudio_ |
| Compatibilidad por fabricante | Restricciones de Doze Mode y battery savers aplican igual | Mismas restricciones, pero con menos control de bajo nivel desde JS |
| Tamaño del bundle / app | Generalmente menor | Generalmente mayor (WebView + runtime) |
| Curva de mantenimiento del código | Tipado fuerte en Dart, errores de plugin detectados en compilación | Tipado en TypeScript, pero errores de plugin nativo suelen aparecer solo en runtime |

> Las filas marcadas como "_Por completar con datos del estudio_" deben llenarse con las métricas reales obtenidas en las pruebas de campo (mAh/hora, TTFF, entradas perdidas en background, etc.).

---

## Desarrollo asistido por IA: Codex vs Antigravity

| Aspecto | GitHub Copilot (Codex) | Antigravity |
|---|---|---|
| Fortaleza principal | Autocompletado de boilerplate nativo (Manifest, permisos) y refactors rápidos dentro del IDE | Generación de estructura de proyecto completa y mejor conocimiento actualizado del ecosistema Flutter/Dart |
| Calidad en configuración nativa | Buena, pero requiere verificación manual de versiones de Android/iOS objetivo | Más completa en Android; configuración iOS suele requerir revisión adicional |
| Conocimiento de restricciones por fabricante (MIUI, One UI) | No cubierto, requiere validación manual | No cubierto, requiere validación manual |
| Generación de tests | Limitada | Más sólida para pruebas unitarias del repositorio de datos |
| Integración en el flujo de trabajo | Alta (sugerencias en línea durante la escritura) | Más orientada a generación de bloques/proyectos completos a partir de un prompt |

**Conclusión analítica:** ambas herramientas reducen significativamente el tiempo dedicado a código repetitivo de infraestructura (permisos, boilerplate de servicios), pero ninguna reemplaza la validación manual de:

- Configuraciones nativas contra la documentación oficial de Android/iOS.
- Comportamiento real en dispositivos de fabricantes con gestión agresiva de batería.
- Pruebas de campo con movimiento real y pantalla bloqueada.

---

## Conclusiones

_(Completar al finalizar las pruebas de campo en ambos proyectos)_

- Framework con mejor persistencia de tracking en background: —
- Framework con menor consumo de batería: —
- Herramienta de IA que aportó mayor velocidad de desarrollo: —
- Principales limitaciones encontradas en cada stack: —

---

## Autor

**Andre (Anthon Chang Alvarez)**
Estudiante de Tecnología en Desarrollo de Software — Escuela Politécnica Nacional (EPN), Quito, Ecuador.
Proyecto desarrollado como parte de práctica/pasantía en [AtenIA](https://atenia.org).
