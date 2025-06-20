# Informe de Hallazgos - Gitleaks
_Generado el Thu Jun 19 14:36:06 -05 2025_  

## 🔐 Secreto detectado: gcp-api-key
- **Archivo:** `android/app/src/main/AndroidManifest.xml`
- **Línea:** 31
- **Commit:** `10499abfb86ec18eb2c69a5678db9ffe7dc010b0`
- **Descripción:** Uncovered a GCP API key, which could lead to unauthorized access to Google Cloud services and data breaches.
- **Valor detectado:** `***************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-04-25T01:11:26Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/10499abfb86ec18eb2c69a5678db9ffe7dc010b0/android/app/src/main/AndroidManifest.xml#L31](https://github.com/Joansico97/felicitup_app/blob/10499abfb86ec18eb2c69a5678db9ffe7dc010b0/android/app/src/main/AndroidManifest.xml#L31)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: gcp-api-key
- **Archivo:** `android/app/src/main/AndroidManifest.xml`
- **Línea:** 36
- **Commit:** `10499abfb86ec18eb2c69a5678db9ffe7dc010b0`
- **Descripción:** Uncovered a GCP API key, which could lead to unauthorized access to Google Cloud services and data breaches.
- **Valor detectado:** `***************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-04-25T01:11:26Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/10499abfb86ec18eb2c69a5678db9ffe7dc010b0/android/app/src/main/AndroidManifest.xml#L36](https://github.com/Joansico97/felicitup_app/blob/10499abfb86ec18eb2c69a5678db9ffe7dc010b0/android/app/src/main/AndroidManifest.xml#L36)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1634
- **Commit:** `1c54bbb58ecc863351223e32c8c54b3c659f6e13`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-04-24T15:32:30Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/1c54bbb58ecc863351223e32c8c54b3c659f6e13/ios/Podfile.lock#L1634](https://github.com/Joansico97/felicitup_app/blob/1c54bbb58ecc863351223e32c8c54b3c659f6e13/ios/Podfile.lock#L1634)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/features/auth/register/bloc/register_bloc.dart`
- **Línea:** 147
- **Commit:** `1c54bbb58ecc863351223e32c8c54b3c659f6e13`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-04-24T15:32:30Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/1c54bbb58ecc863351223e32c8c54b3c659f6e13/lib/features/auth/register/bloc/register_bloc.dart#L147](https://github.com/Joansico97/felicitup_app/blob/1c54bbb58ecc863351223e32c8c54b3c659f6e13/lib/features/auth/register/bloc/register_bloc.dart#L147)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1634
- **Commit:** `9ce8f01ff4bb6e7503104b57d96841344a6c2880`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-04-10T20:00:58Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/9ce8f01ff4bb6e7503104b57d96841344a6c2880/ios/Podfile.lock#L1634](https://github.com/Joansico97/felicitup_app/blob/9ce8f01ff4bb6e7503104b57d96841344a6c2880/ios/Podfile.lock#L1634)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1629
- **Commit:** `55d6ba076c19f5a56bfcd9168e3e89e8de04135f`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-28T19:26:23Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/55d6ba076c19f5a56bfcd9168e3e89e8de04135f/ios/Podfile.lock#L1629](https://github.com/Joansico97/felicitup_app/blob/55d6ba076c19f5a56bfcd9168e3e89e8de04135f/ios/Podfile.lock#L1629)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/features/auth/register/bloc/register_bloc.dart`
- **Línea:** 99
- **Commit:** `d77046f7d7df6cbf5053c21da569a5a1b4982f81`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-21T21:58:28Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/d77046f7d7df6cbf5053c21da569a5a1b4982f81/lib/features/auth/register/bloc/register_bloc.dart#L99](https://github.com/Joansico97/felicitup_app/blob/d77046f7d7df6cbf5053c21da569a5a1b4982f81/lib/features/auth/register/bloc/register_bloc.dart#L99)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/features/auth/register/bloc/register_bloc.dart`
- **Línea:** 101
- **Commit:** `d77046f7d7df6cbf5053c21da569a5a1b4982f81`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-21T21:58:28Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/d77046f7d7df6cbf5053c21da569a5a1b4982f81/lib/features/auth/register/bloc/register_bloc.dart#L101](https://github.com/Joansico97/felicitup_app/blob/d77046f7d7df6cbf5053c21da569a5a1b4982f81/lib/features/auth/register/bloc/register_bloc.dart#L101)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/helpers/list_avatares.dart`
- **Línea:** 2
- **Commit:** `9f119c3752189951427f946867ad8eb54a2a9166`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-19T21:35:44Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L2](https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L2)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/helpers/list_avatares.dart`
- **Línea:** 3
- **Commit:** `9f119c3752189951427f946867ad8eb54a2a9166`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-19T21:35:44Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L3](https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L3)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/helpers/list_avatares.dart`
- **Línea:** 4
- **Commit:** `9f119c3752189951427f946867ad8eb54a2a9166`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-19T21:35:44Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L4](https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L4)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `lib/helpers/list_avatares.dart`
- **Línea:** 5
- **Commit:** `9f119c3752189951427f946867ad8eb54a2a9166`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-19T21:35:44Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L5](https://github.com/Joansico97/felicitup_app/blob/9f119c3752189951427f946867ad8eb54a2a9166/lib/helpers/list_avatares.dart#L5)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1604
- **Commit:** `ecd74dd8f40c9aac03ac7ab0d172a60f0533a211`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-18T11:42:15Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1604](https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1604)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1611
- **Commit:** `ecd74dd8f40c9aac03ac7ab0d172a60f0533a211`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-18T11:42:15Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1611](https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1611)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1618
- **Commit:** `ecd74dd8f40c9aac03ac7ab0d172a60f0533a211`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-18T11:42:15Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1618](https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1618)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1619
- **Commit:** `ecd74dd8f40c9aac03ac7ab0d172a60f0533a211`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-18T11:42:15Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1619](https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1619)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

## 🔐 Secreto detectado: generic-api-key
- **Archivo:** `ios/Podfile.lock`
- **Línea:** 1642
- **Commit:** `ecd74dd8f40c9aac03ac7ab0d172a60f0533a211`
- **Descripción:** Detected a Generic API Key, potentially exposing access to various services and sensitive operations.
- **Valor detectado:** `****************************************`
- **Autor:** Jorge Antonio Silva Cortés
- **Fecha:** 2025-03-18T11:42:15Z
- **Enlace al código:** [https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1642](https://github.com/Joansico97/felicitup_app/blob/ecd74dd8f40c9aac03ac7ab0d172a60f0533a211/ios/Podfile.lock#L1642)

### 🛠️ Recomendaciones
- Revocar o restringir la clave inmediatamente si sigue activa.
- Eliminarla del código fuente y del historial (Git).
- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults).
- Añadir el archivo a `.gitignore` si aplica.

---

