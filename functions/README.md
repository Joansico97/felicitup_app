# Felicitup App - Cloud Functions

Este directorio contiene las Firebase Cloud Functions para el backend de Felicitup. 
Se ha aplicado una refactorización basada en principios de **Ingeniería de Software y Patrones de Razonamiento Defensivo**, específicamente:

## Principios Defensivos Aplicados

1. **Idempotencia Activa (Zero-Trust):**
   - **Video Processing (`video.ts`):** Las funciones `normalizeSingleVideo` y `processVideoMerge` abortan su ejecución si los registros indican que el video ya está en estado `processing` o `completed`.
   - **Felicitups (`felicitups.ts`):** Las funciones de envío manual y finalización retornan temprano si la felicitup ya está en estado `Finished`.
   - **Cumpleaños (`users.ts`):** Las notificaciones programadas generan un ID determinista (`ID-Año`) para garantizar que múltiples ejecuciones en el mismo día no envíen la alerta por duplicado.

2. **Self-Healing (Autocuración) e Higiene del Estado:**
   - **Notificaciones (`notifications.ts`):** Al detectar que un token FCM es inválido o ha expirado, el sistema lo elimina automáticamente de la base de datos (limpiando `fcmToken`), previniendo fallos futuros.
   - **Usuarios (`users.ts`):** Al deshabilitar la cuenta de un usuario (`disableCurrentUser`), no solo se revoca en Auth, sino que se limpian explícitamente los campos de sesión (tokens, chats activos).

3. **Validación Exhaustiva de Contratos:**
   - Las funciones que requieren autenticación verifican rigurosamente `request.auth` y validan el formato y tipado de los argumentos pasados en `request.data`.

## Estructura

- `src/felicitups.ts`: Lógica de programación y finalización de felicitups.
- `src/notifications.ts`: Enrutamiento y envío de push notifications FCM.
- `src/users.ts`: Utilidades y cron-jobs relacionados a usuarios.
- `src/video.ts`: Funciones intensivas de procesamiento de video mediante FFmpeg.
- `src/smoke_test.ts`: Script rápido de validación del manejo de errores.

## Testing

Para ejecutar el test integral (Smoke Tests y Validaciones) con Jest:
```bash
npm run test:smoke
```
