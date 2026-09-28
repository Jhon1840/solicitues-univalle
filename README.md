# CAMPUS CONNECT - App móvil (Flutter)

Aplicación móvil del **Desarrollador B**. Consume la API REST hecha en **Laravel 12 + PostgreSQL**.

## 1. Puesta en marcha

Requisitos: Flutter 3.22 o superior (Dart 3.3+).

```bash
# 1) Genera las carpetas de plataforma (android/ ios/) sin tocar lib/ ni pubspec.yaml
flutter create --org bo.campusconnect --project-name campus_connect .

# 2) Dependencias
flutter pub get

# 3) Ejecutar (emulador Android: 10.0.2.2 = localhost de tu PC)
flutter run

# Celular real: usa la IP de tu PC en la red
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Si `flutter create .` te sobrescribe algo, crea un proyecto nuevo y copia dentro
`lib/`, `test/`, `integration_test/`, `pubspec.yaml` y `analysis_options.yaml`.

### Configuración de plataforma

**Android** (`android/app/build.gradle` o `build.gradle.kts`):
`minSdk = 23` (requerido por `flutter_secure_storage`).

**Android** (`android/app/src/main/AndroidManifest.xml`), dentro de `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
y en `<application ...>` solo para desarrollo con http:
```xml
android:usesCleartextTraffic="true"
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Para tomar fotos de evidencia de tu solicitud.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Para adjuntar fotos de evidencia a tu solicitud.</string>
```

## 2. Arquitectura

```
UI (screens/widgets) -> Provider (estado) -> Repository -> ApiClient (Dio) -> API Laravel
```

| Carpeta | Contenido |
|---|---|
| `lib/core` | ApiClient (token + 401), ApiException, TokenStorage seguro, validadores, router protegido, tema |
| `lib/models` | Usuario, Solicitud, Evidencia, Comentario, HistorialItem, Catalogos, Pagina |
| `lib/repositories` | Acceso a la API (auth, solicitudes, comentarios) |
| `lib/providers` | Estado con `provider` (AuthProvider, SolicitudProvider, ComentarioProvider) |
| `lib/screens` | Login, lista, formulario crear/editar, detalle (+ widgets) |

## 3. Historias de usuario cubiertas

| HU | Dónde |
|---|---|
| HU-01 Login | `login_screen.dart`, `AuthProvider.login` |
| HU-02 Logout | `lista_solicitudes_screen.dart` (icono de salida) |
| HU-05 Crear solicitud | `solicitud_form_screen.dart` |
| HU-06 Evidencia | `evidencia_picker.dart` + `ImageRules` |
| HU-07 Duplicados | `_dialogoDuplicados` en el formulario |
| HU-08 Editar | mismo formulario con `solicitud` (solo si es Pendiente) |
| HU-09 Eliminar | `detalle_solicitud_screen.dart` (con confirmación) |
| HU-10 Mis solicitudes | `lista_solicitudes_screen.dart` (filtros, refresco, paginación) |
| HU-11 Detalle e historial | `detalle_solicitud_screen.dart` + `timeline.dart` |
| HU-12 Comentarios | `comentarios_section.dart` |
| HU-13 Notificaciones | No incluida (prioridad baja): se puede añadir con `firebase_messaging` o polling |

## 4. Contrato de API que espera la app

Base: `/api`. Token `Bearer` (Sanctum) en todas salvo `/login`. Las respuestas de recurso van
envueltas en `{ "data": ... }` (como los API Resources de Laravel).

| Método | Endpoint | Respuesta esperada |
|---|---|---|
| POST | `/login` | `{ "token": "...", "user": { id, name, email, rol } }` (body: `email`, `password`, `device_name`) |
| POST | `/logout` | 204/200 |
| GET | `/me` | `{ data: usuario }` |
| GET | `/catalogos` | `{ data: { tipos: [{id,nombre}], prioridades: [...], estados: [...] } }` |
| GET | `/solicitudes?page=&estado_id=&tipo_id=` | `{ data: [solicitud], meta: { current_page, last_page } }` |
| POST | `/solicitudes` | body: `tipo_id, prioridad_id, titulo, descripcion, ubicacion` -> `{ data: solicitud }` |
| GET | `/solicitudes/{id}` | `{ data: solicitud }` |
| PUT | `/solicitudes/{id}` | mismo body -> `{ data: solicitud }` (403 si no está Pendiente) |
| DELETE | `/solicitudes/{id}` | 204/200 (403 si no está Pendiente) |
| POST | `/solicitudes/{id}/evidencias` | multipart, campo `imagen` (jpg/png, máx 5 MB) |
| GET | `/solicitudes/similares?tipo_id=&ubicacion=` | `{ data: [solicitud] }` |
| GET | `/solicitudes/{id}/historial` | `{ data: [{ id, estado, descripcion, autor, created_at }] }` |
| GET | `/solicitudes/{id}/comentarios` | `{ data: [{ id, contenido, autor, created_at }] }` |
| POST | `/solicitudes/{id}/comentarios` | body: `contenido` -> `{ data: comentario }` |

Forma de una solicitud:
```json
{
  "id": 7, "codigo": "SOL-00007", "titulo": "...", "descripcion": "...", "ubicacion": "...",
  "tipo": {"id": 1, "nombre": "Mantenimiento"},
  "prioridad": {"id": 2, "nombre": "Alta"},
  "estado": {"id": 1, "nombre": "Pendiente"},
  "responsable": {"id": 5, "name": "Carlos"} ,
  "evidencias": [{"id": 1, "url": "http://.../storage/evidencias/a.jpg"}],
  "created_at": "2026-09-28T10:30:00Z"
}
```
Notas para el backend: `php artisan storage:link` para que las URLs de las fotos funcionen,
`url` de evidencia absoluta, errores de validación con código 422 y `{ errors: { campo: [msg] } }`.
La app lee tipo/prioridad/estado como objeto o como texto simple.

## 5. Pruebas

```bash
flutter analyze
flutter test                      # unitarias + widget (no necesitan servidor)
flutter test integration_test/app_flow_test.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api \
  --dart-define=TEST_EMAIL=estudiante@test.com \
  --dart-define=TEST_PASSWORD=password      # requiere la API y un dispositivo/emulador
```

| ID | Archivo | Qué valida |
|---|---|---|
| U1 | `test/validators_test.dart` | Validadores de formularios y reglas de imagen |
| U2 | `test/solicitud_test.dart` | `fromJson`, `esEditable`, `permiteComentarios` |
| U3 | `test/api_exception_test.dart` | Traducción de 401, 403, 404, 422 y sin conexión |
| W1 | `test/login_screen_test.dart` | Login vacío no llama a la API; login válido autentica |
| W2 | `test/solicitud_form_test.dart` | Crear incompleto no envía y muestra validaciones |
| W3 | `test/detalle_solicitud_test.dart` | Editar/Eliminar solo visibles en estado Pendiente |
| W4 | `test/router_test.dart` | Sin sesión redirige al Login |
| I1-I4 | `integration_test/app_flow_test.dart` | Login, crear con evidencia, editar/eliminar, comentar (Móvil-API-BD) |

Guarda capturas de la consola de `flutter test` y de la ejecución de integración como evidencia.

## 6. Git

Ramas por historia (`feature/movil-login`, `feature/movil-crear-solicitud`, ...) hacia `develop`,
con el CI en verde (compila + `flutter test`) antes de fusionar.

Ejemplo de workflow (`.github/workflows/movil.yml`):
```yaml
name: movil-ci
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
```
