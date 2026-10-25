![Priorix](docs/readme_icon.png)

# Priorix

**Decide qué importa primero.**

Matriz de Eisenhower con alertas locales que entienden el tiempo que te queda.

![Versión](https://img.shields.io/badge/versión-1.0.1-D8B677?style=for-the-badge&labelColor=12141B) ![Flutter](https://img.shields.io/badge/Flutter-3.47-D8B677?style=for-the-badge&logo=flutter&logoColor=D8B677&labelColor=12141B) ![Dart](https://img.shields.io/badge/Dart-3.13-D8B677?style=for-the-badge&logo=dart&logoColor=D8B677&labelColor=12141B)

![iOS](https://img.shields.io/badge/iOS-15+-F4F1EA?style=flat-square&logo=apple&logoColor=F4F1EA&labelColor=08090E&color=1A1D26) ![Android](https://img.shields.io/badge/Android-✓-F4F1EA?style=flat-square&logo=android&logoColor=F4F1EA&labelColor=08090E&color=1A1D26) ![macOS](https://img.shields.io/badge/macOS-10.15+-F4F1EA?style=flat-square&logo=apple&logoColor=F4F1EA&labelColor=08090E&color=1A1D26) ![Offline](https://img.shields.io/badge/100%25-local-F4F1EA?style=flat-square&labelColor=08090E&color=1A1D26)

---

## ✦ Qué es Priorix

Priorix clasifica cada tarea según dos preguntas, **¿es urgente?** y **¿es importante?**, y la coloca en uno de los cuatro cuadrantes de la matriz de Eisenhower. Después te avisa **según el porcentaje de tiempo que queda** hasta la fecha límite, no a una hora fija.

Todo vive en tu dispositivo: sin cuentas, sin servidores y sin rastreo.

## ✦ Características

| | |
|---|---|
| ◆ **Matriz de Eisenhower** | Cuatro cuadrantes con color, icono y una guía de qué hacer en cada uno. |
| ◆ **Alertas por tiempo restante** | Avisos cuando queda el 50 %, el 20 % o el porcentaje que elijas del plazo, más un aviso al vencer. |
| ◆ **Recordatorios exactos** | Un aviso puntual en el momento que tú indiques, con o sin fecha límite. |
| ◆ **Sonidos propios** | Seis sonidos de alerta con vista previa y prueba de notificación real. |
| ◆ **Tres vistas** | Inicio, Matriz y Agenda. Tú eliges con cuál abre la app. |
| ◆ **Categorías** | Personalizables, con 12 iconos y 10 colores. |
| ◆ **Siete temas** | Cuatro oscuros y tres claros, con transición animada entre ellos. |
| ◆ **Copias de seguridad** | Exporta e importa tareas, categorías y ajustes en JSON. |
| ◆ **Privado por diseño** | Almacenamiento local con Hive y notificaciones programadas en el dispositivo. |

## ✦ La matriz

| Código | Cuadrante | Criterio | Color | Qué hacer |
|:--:|---|---|:--:|---|
| `Q1` | **Hacer ya** | Urgente e importante | ![](https://img.shields.io/badge/%20-EB6A52-EB6A52?style=flat-square) | Hazlo hoy. Es lo que más impacto tiene ahora mismo. |
| `Q2` | **Planificar** | Importante, no urgente | ![](https://img.shields.io/badge/%20-3FAE8A-3FAE8A?style=flat-square) | Reserva un bloque en tu agenda y protégelo. |
| `Q3` | **Delegar** | Urgente, no importante | ![](https://img.shields.io/badge/%20-7C8CF0-7C8CF0?style=flat-square) | Encuentra a alguien que pueda resolverlo y haz seguimiento. |
| `Q4` | **Eliminar** | Ni urgente ni importante | ![](https://img.shields.io/badge/%20-8E8A96-8E8A96?style=flat-square) | Suéltalo. Menos ruido, más foco. |

## ✦ Alertas que entienden el tiempo

Los porcentajes se calculan sobre la ventana que va **desde que creas la tarea hasta su fecha límite**.

> Una tarea creada el **lunes a las 09:00** que vence el **miércoles a las 09:00**, con umbral del **50 %**, avisa el **martes a las 09:00**.

| Preset | Umbrales |
|---|---|
| **Esencial** *(por defecto)* | 50 % · 20 % |
| **Intenso** | 75 % · 50 % · 25 % · 10 % |
| **Con margen** | 90 % · 75 % · 50 % |
| **Última hora** | 10 % · 5 % |

Cada tarea admite hasta **8 umbrales**, además del aviso al vencer y un recordatorio exacto. La lógica está en [`DeadlineAlertPlanner`](lib/features/tasks/domain/services/deadline_alert_planner.dart) y tiene tests propios.

#### Detalles técnicos de las notificaciones

- **Límite de iOS:** iOS guarda como máximo 64 notificaciones pendientes por app. Priorix programa como mucho **60** y prioriza las más próximas.
- **IDs deterministas:** se calculan con un hash FNV-1a del id de la tarea y el número de slot, así que se pueden cancelar incluso después de reiniciar la app.
- **Reprogramación al arrancar:** al abrir la app se vuelven a planificar todas las alertas, lo que cubre migraciones e importaciones de copias.
- **Un canal de Android por sonido:** Android fija el sonido de un canal cuando lo crea. Cada sonido tiene su canal (`priorix_deadlines_<sonido>`) y los canales que no se usan se eliminan.
- **Icono monocromo:** el icono de la barra de estado (`ic_stat_priorix`) se genera a partir de la marca.

## ✦ Sonidos

| Sonido | Archivo | Duración |
|---|---|:--:|
| Destello *(por defecto)* | `priorix_destello.wav` | 1,1 s |
| Logro | `priorix_logro.wav` | 1,1 s |
| Pulso | `priorix_pulso.wav` | 1,8 s |
| Cristal | `priorix_cristal.wav` | 2,5 s |
| Eco | `priorix_eco.wav` | 2,5 s |
| Mensaje | `priorix_mensaje.wav` | 4,4 s |
| Predeterminado del sistema | — | El tono configurado en el dispositivo |

Todos los sonidos son **WAV PCM de 16 bits, mono, a 44,1 kHz y de menos de 30 s**, el único formato que aceptan a la vez Android e iOS. Cada archivo está en tres sitios:

```
assets/sounds/                      → vista previa dentro de la app (audioplayers)
android/app/src/main/res/raw/       → notificaciones de Android (se conservan con keep.xml)
ios/Runner/  ·  macos/Runner/       → notificaciones de iOS y macOS (Copy Bundle Resources)
```

---

## ✦ Sistema de diseño

La interfaz se construye sobre **Material 3**, con un `ThemeExtension` propio (`PriorixPalette`) que define superficies, texto y acento para cada tema. Los colores de marca no cambian entre temas.

### Temas

| Tema | Modo | Fondo | Superficie | Superficie alta | Acento |
|---|---|:--:|:--:|:--:|:--:|
| **Obsidiana** *(predeterminado)* | Oscuro | ![](https://img.shields.io/badge/%20-08090E-08090E?style=flat-square) `#08090E` | ![](https://img.shields.io/badge/%20-12141B-12141B?style=flat-square) `#12141B` | ![](https://img.shields.io/badge/%20-1A1D26-1A1D26?style=flat-square) `#1A1D26` | ![](https://img.shields.io/badge/%20-D8B677-D8B677?style=flat-square) `#D8B677` |
| **Grafito** | Oscuro | ![](https://img.shields.io/badge/%20-0B0B0C-0B0B0C?style=flat-square) `#0B0B0C` | ![](https://img.shields.io/badge/%20-161618-161618?style=flat-square) `#161618` | ![](https://img.shields.io/badge/%20-202023-202023?style=flat-square) `#202023` | ![](https://img.shields.io/badge/%20-DADAE0-DADAE0?style=flat-square) `#DADAE0` |
| **Jade** | Oscuro | ![](https://img.shields.io/badge/%20-070B0A-070B0A?style=flat-square) `#070B0A` | ![](https://img.shields.io/badge/%20-111715-111715?style=flat-square) `#111715` | ![](https://img.shields.io/badge/%20-19211E-19211E?style=flat-square) `#19211E` | ![](https://img.shields.io/badge/%20-6FD3A9-6FD3A9?style=flat-square) `#6FD3A9` |
| **Amatista** | Oscuro | ![](https://img.shields.io/badge/%20-0A0910-0A0910?style=flat-square) `#0A0910` | ![](https://img.shields.io/badge/%20-14121C-14121C?style=flat-square) `#14121C` | ![](https://img.shields.io/badge/%20-1D1A28-1D1A28?style=flat-square) `#1D1A28` | ![](https://img.shields.io/badge/%20-B9A4F7-B9A4F7?style=flat-square) `#B9A4F7` |
| **Champagne** | Claro | ![](https://img.shields.io/badge/%20-F7F4EE-F7F4EE?style=flat-square) `#F7F4EE` | ![](https://img.shields.io/badge/%20-FFFFFF-FFFFFF?style=flat-square) `#FFFFFF` | ![](https://img.shields.io/badge/%20-EFEAE1-EFEAE1?style=flat-square) `#EFEAE1` | ![](https://img.shields.io/badge/%20-9C7631-9C7631?style=flat-square) `#9C7631` |
| **Porcelana** | Claro | ![](https://img.shields.io/badge/%20-F5F6F8-F5F6F8?style=flat-square) `#F5F6F8` | ![](https://img.shields.io/badge/%20-FFFFFF-FFFFFF?style=flat-square) `#FFFFFF` | ![](https://img.shields.io/badge/%20-ECEEF2-ECEEF2?style=flat-square) `#ECEEF2` | ![](https://img.shields.io/badge/%20-3F51C9-3F51C9?style=flat-square) `#3F51C9` |
| **Menta** | Claro | ![](https://img.shields.io/badge/%20-F2F7F5-F2F7F5?style=flat-square) `#F2F7F5` | ![](https://img.shields.io/badge/%20-FFFFFF-FFFFFF?style=flat-square) `#FFFFFF` | ![](https://img.shields.io/badge/%20-E5EFEB-E5EFEB?style=flat-square) `#E5EFEB` | ![](https://img.shields.io/badge/%20-1F8A70-1F8A70?style=flat-square) `#1F8A70` |

### Tokens de la paleta

Se usan con `context.palette.<token>` ([`app_palette.dart`](lib/app/theme/app_palette.dart)).

| Token | Uso | Oscuro | Claro |
|---|---|---|---|
| `background` | Lienzo de la app | según el tema | según el tema |
| `surface` | Tarjetas, sheets, diálogos | según el tema | `#FFFFFF` |
| `surfaceHigh` | Inputs, chips, fondo de iconos | según el tema | según el tema |
| `hairline` | Divisores y bordes | `#FFFFFF` al 8 % | `#000000` al 8 % |
| `textPrimary` | Títulos y texto principal | `#F4F1EA` | `#17151A` |
| `textSecondary` | Cuerpo y subtítulos | `#A09DA8` | `#67636D` |
| `textTertiary` | Etiquetas, pistas, metadatos | `#67646F` | `#A39FA8` |
| `accent` | Acción principal y selección | según el tema | según el tema |
| `onAccent` | Contenido sobre el acento | según el tema | `#FFFFFF` |
| `glow` | Halo radial del fondo | acento al 12 % | acento al 10 % |

### Colores de marca

Son independientes del tema ([`app_colors.dart`](lib/app/theme/app_colors.dart)).

| | Token | Hex | Uso |
|:--:|---|---|---|
| ![](https://img.shields.io/badge/%20-D8B677-D8B677?style=flat-square) | `gold` | `#D8B677` | Color de marca y de las notificaciones de Android |
| ![](https://img.shields.io/badge/%20-EB6A52-EB6A52?style=flat-square) | `ember` | `#EB6A52` | Q1 · Hacer ya |
| ![](https://img.shields.io/badge/%20-3FAE8A-3FAE8A?style=flat-square) | `jade` | `#3FAE8A` | Q2 · Planificar |
| ![](https://img.shields.io/badge/%20-7C8CF0-7C8CF0?style=flat-square) | `iris` | `#7C8CF0` | Q3 · Delegar |
| ![](https://img.shields.io/badge/%20-8E8A96-8E8A96?style=flat-square) | `stone` | `#8E8A96` | Q4 · Eliminar |
| ![](https://img.shields.io/badge/%20-F07FA8-F07FA8?style=flat-square) | `rose` | `#F07FA8` | Categorías |
| ![](https://img.shields.io/badge/%20-F2A93B-F2A93B?style=flat-square) | `amber` | `#F2A93B` | Categorías |
| ![](https://img.shields.io/badge/%20-4FB3E8-4FB3E8?style=flat-square) | `sky` | `#4FB3E8` | Categorías |
| ![](https://img.shields.io/badge/%20-A98BF2-A98BF2?style=flat-square) | `violet` | `#A98BF2` | Categorías |
| ![](https://img.shields.io/badge/%20-E5484D-E5484D?style=flat-square) | `danger` | `#E5484D` | Tareas vencidas, errores y acciones destructivas |
| ![](https://img.shields.io/badge/%20-3DBE8B-3DBE8B?style=flat-square) | `success` | `#3DBE8B` | Tareas completadas y categoría Salud |

### Tipografía

Se usa la fuente del sistema (SF Pro en Apple y Roboto en Android) con una escala propia: tracking negativo en los titulares y etiquetas pequeñas en mayúsculas con tracking abierto.

| Estilo | Tamaño | Peso | Tracking | Interlineado |
|---|:--:|:--:|:--:|:--:|
| `displayLarge` | 56 | 300 | −2.0 | 1.00 |
| `displayMedium` | 40 | 600 | −1.4 | 1.05 |
| `displaySmall` | 32 | 600 | −1.0 | 1.10 |
| `headlineMedium` | 30 | 600 | −0.9 | 1.12 |
| `headlineSmall` | 26 | 600 | −0.6 | 1.18 |
| `titleLarge` | 20 | 600 | −0.4 | 1.25 |
| `titleMedium` | 16 | 600 | −0.2 | 1.30 |
| `titleSmall` | 14 | 600 | −0.1 | 1.30 |
| `bodyLarge` | 16 | 400 | 0 | 1.45 |
| `bodyMedium` | 14 | 400 | 0 | 1.45 |
| `bodySmall` | 12.5 | 400 | 0 | 1.40 |
| `labelLarge` | 14 | 600 | +0.1 | — |
| `labelMedium` | 12 | 600 | +0.2 | — |
| `labelSmall` | 11 | 600 | +1.4 | — |

### Forma

| Elemento | Radio |
|---|:--:|
| Bottom sheets, diálogos, selectores de fecha y hora | `28` |
| Tarjetas (`SurfaceCard`) | `24` |
| Campos de texto | `18` |
| Snackbars y filas de lista | `16` |
| Icono dentro de cada fila | `11` |
| Chips de categoría | píldora |

Las transiciones de página usan `FadeForwards` en Android y el estilo Cupertino en iOS y macOS.

---

## ✦ Arquitectura

Arquitectura limpia organizada por funcionalidad, con el estado gestionado por **Cubit** (`flutter_bloc`).

```
lib/
├── app/                    # Shell, splash y tema (AppTheme, PriorixPalette, AppColors)
├── core/
│   ├── extensions/         # Formato de fechas
│   └── widgets/            # SurfaceCard, PButton, PageFrame, PriorixMark…
└── features/
    ├── tasks/
    │   ├── domain/         # Entidades, repositorio, casos de uso, DeadlineAlertPlanner
    │   ├── data/           # Modelo y datasource de Hive, implementación del repositorio
    │   └── presentation/   # TaskCubit, páginas y widgets
    ├── categories/         # Categorías personalizables + CategoryCubit
    └── settings/           # AppSettings, NotificationService, BackupService, SettingsCubit
```

## ✦ Tecnología

| Paquete | Versión | Para qué |
|---|:--:|---|
| [Flutter](https://flutter.dev) | 3.47 | Framework de interfaz |
| [Dart](https://dart.dev) | 3.13 | Lenguaje |
| `flutter_bloc` | 9.1.1 | Estado con Cubit |
| `equatable` | 2.0.8 | Igualdad por valor |
| `hive` · `hive_flutter` | 2.2.3 · 1.1.0 | Almacenamiento local |
| `flutter_local_notifications` | 19.5.0 | Alertas programadas |
| `timezone` · `flutter_timezone` | 0.10.1 · 4.1.1 | Programación según la zona horaria |
| `audioplayers` | 6.8.1 | Vista previa de los sonidos |
| `file_picker` · `path_provider` | 10.3.10 · 2.1.5 | Copias de seguridad |
| `intl` · `flutter_localizations` | 0.20.3 | Fechas y textos en español |
| `uuid` | 4.5.3 | Identificadores |
| `flutter_launcher_icons` · `flutter_native_splash` | 0.14.4 · 2.4.8 | Icono y pantalla de carga |

## ✦ Primeros pasos

```bash
flutter pub get
flutter run
```

| Plataforma | Mínimo | Identificador |
|---|---|---|
| iOS | 15.0 | `com.pablo.priorix` |
| Android | `minSdk` por defecto de Flutter | `com.pablo.priorix` |
| macOS | 10.15 | `com.pablo.priorix` |

> Cuando se añaden recursos nativos (sonidos, iconos) o plugins nuevos, hay que volver a compilar la app; un *hot restart* no basta. Los datos se conservan al reinstalar la app encima de la versión anterior.

### Tests

```bash
flutter test
```

Incluyen el planificador de alertas, un *smoke test* de todas las pantallas en tema claro y oscuro, y las comparaciones *golden* de los recursos de marca.

### Recursos de marca

Los PNG de marca se generan a partir de [`priorix_mark.dart`](lib/core/widgets/priorix_mark.dart):

```bash
flutter test test/brand_assets_test.dart --update-goldens
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

**PRIORIX** · Decide qué importa primero.
