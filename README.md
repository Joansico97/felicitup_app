# Felicitup App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase)
![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript)
![Node.js](https://img.shields.io/badge/Node.js-22-339933?logo=nodedotjs)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20BLoC-blue)

**Felicitup** es una aplicación multiplataforma (iOS, Android y Web) diseñada para crear, organizar y enviar felicitaciones en video grupales y colaborativas ("Felicitups") acompañadas de botes económicos compartidos para cualquier ocasión especial (cumpleaños, bodas, despedidas, etc.).

---

## 🚀 Tecnologías Principales

### Frontend (Flutter)
- **Framework**: Flutter 3.x (Soporte responsivo Móvil y Web).
- **Gestión de Estado**: BLoC (`flutter_bloc`) con **Single State Class** de banderas atómicas e inmutabilidad con `freezed`.
- **Inyección de Dependencias**: `get_it` / `injectable`.
- **Manejo de Errores**: Tipo funcional `Either<ApiException, T>` (`either_dart`).
- **Navegación**: `go_router` con guards de autenticación y redirección responsiva.
- **Internacionalización**: `l10n` nativo (`intl_utils`, `S.of(context)` en Español e Inglés).
- **Persistencia Local de Preferencias**: `HydratedBloc` (tema y lenguaje).

### Backend & Cloud Infrastructure (Firebase + Node 22)
- **Base de Datos**: Cloud Firestore.
- **Autenticación**: Firebase Auth (Email/Password, Google, Apple).
- **Almacenamiento**: Cloud Storage (videos normalizados, miniaturas y marcas de agua).
- **Notificaciones Push**: Firebase Cloud Messaging (FCM).
- **Serverless Backend (`functions/`)**:
  - **Runtime**: TypeScript en Node 22 (`strict: true`, Firebase Functions v2).
  - **Procesamiento de Video**: FFmpeg (`fluent-ffmpeg`) para normalización, unión de videos grupales (`VideoMergeJobs`) y marcas de agua.
  - **Programación de Tareas**: Google Cloud Tasks (`send-felicitup`) y Cron Jobs (`onSchedule`).

---

## 📂 Estructura del Proyecto

El código sigue una arquitectura limpia orientada a características (**Feature-driven Clean Architecture**):

```
felicitup_app/
├── docs/specs/                    # Especificaciones técnicas del proyecto
│   ├── APP_SPEC.md                # Especificación de la capa de App y Bootstrap
│   ├── BLOC_SPEC.md               # Estándar de BLoC y Single State Class
│   ├── DATA_SPEC.md               # Modelos, Repositorios y ApiException
│   ├── DATABASE_SPEC.md           # Colecciones de Firestore y Esquemas
│   ├── FUNCTIONS_SPEC.md          # Cloud Functions en TypeScript
│   └── SPEC_GUIDE.md              # Guía de observancia de specs
│
├── functions/                     # Backend de Cloud Functions (TypeScript)
│   ├── src/
│   │   ├── index.ts               # Manifiesto principal (maxInstances: 10)
│   │   ├── felicitups.ts          # Tareas y flujo de Felicitups
│   │   ├── notifications.ts        # Notificaciones FCM individuales y masivas
│   │   ├── video.ts               # Normalización, concatenación y watermark con FFmpeg
│   │   ├── users.ts               # Cron de cumpleaños, signed URLs y DNS email check
│   │   └── system.ts              # Diagnósticos y log de errores
│   └── package.json
│
├── lib/
│   ├── app/                       # Bootstrap global (FelicitupApp, AppBloc, AppObserver)
│   ├── components/                # Componentes UI reutilizables del Design System
│   ├── core/                      # Configuración, rutas, tema, utilidades y constantes
│   ├── data/                      # Capa de Datos (Modelos Freezed, Repositorios y Firebase Resources)
│   └── features/                  # Módulos de Características (24 características)
│       └── <feature>/
│           ├── bloc/              # BLoC, Eventos (Sealed) y Estado de la feature
│           └── views/
│               ├── mobile/        # Vista específica Móvil
│               ├── web/           # Vista específica Web
│               ├── <feature>_page.dart # LayoutBuilder wrapper (breakpoint 1024px)
│               └── views.dart
│
├── test/                          # Suite de pruebas unitarias (59/59 pasando)
├── Makefile                       # Comandos automatizados de desarrollo
├── pubspec.yaml                   # Dependencias de Flutter
└── firebase.json                  # Configuración de Firebase y Emuladores
```

---

## 🗄️ Colecciones de Base de Datos (Cloud Firestore)

La base de datos se estructura en 9 colecciones principales:

1. **`Users`**: Perfiles de usuario, lista de amigos, alertas de cumpleaños, token FCM y configuración.
2. **`Felicitups`**: Eventos de felicitación (fecha, creador, invitados, dueños, estado del bote y video final).
3. **`UsersInvitedInformation`**: Registros de pago y confirmación de asistencia por usuario invitado.
4. **`Chats`**: Mensajes de chat grupal asociados a cada Felicitup.
5. **`SingleChats`**: Conversaciones directas 1 a 1 entre amigos.
6. **`GeneralData`**: Configuración global, términos de servicio y políticas de privacidad.
7. **`ReportedVideosCollection`**: Moderación de contenido y reportes de video.
8. **`VideoMergeJobs`**: Cola de procesamiento asíncrono para unión de videos por Cloud Functions.
9. **`DeleteAccountRequests`**: Solicitudes de eliminación de cuenta.

---

## 🛠️ Comandos de Desarrollo

El proyecto incluye un `Makefile` para agilizar los comandos de desarrollo habituales:

### Comandos de Flutter

```bash
# Obtener dependencias de Flutter
flutter pub get

# Ejecutar el generador de código (Freezed, JsonSerializable)
make build_runner
# o directamente:
dart run build_runner build --delete-conflicting-outputs

# Generar clases de localización (l10n)
dart run intl_utils:generate

# Ejecutar pruebas unitarias (100% éxito)
make test
# o directamente:
flutter test

# Ejecutar análisis estático (0 errores)
make analyze
# o directamente:
flutter analyze
```

### Comandos de Cloud Functions

```bash
# Compilar el código TypeScript de Cloud Functions
cd functions && npm run build

# Desplegar las Cloud Functions a producción
make deploy_functions
# o directamente:
firebase deploy --only functions
```

---

## 🧪 Calidad de Código y Verificación

- **Static Analysis**: 0 warnings / 0 errores (`flutter analyze` limpio).
- **Unit Tests**: 59 pruebas unitarias en `test/features/` cubriendo los BLoCs principales al 100%.
- **Spec Compliance**: Estrictamente guiado por la documentación en `docs/specs/`.
