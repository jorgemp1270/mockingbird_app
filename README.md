# Mockingbird App

Una aplicación de reproducción de música moderna con capacidades de chat de IA, construida con Flutter.

## Características

*   **Reproductor de Música**: Reproducción de archivos de audio locales con soporte para metadatos (título, artista, álbum).
*   **Chat con IA**: Interfaz de chat integrada impulsada por inteligencia artificial (para asistencia y recomendaciones).
*   **Gestión de Biblioteca**: Organiza y explora tu biblioteca de música.
*   **Personalización**: Tema dinámico basado en tu fondo de pantalla (Material You) y tipografía personalizada (Fredoka).
*   **Persistencia de Datos**: Guarda tus preferencias y estado de reproducción localmente.

## Tecnologías Utilizadas

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Lenguaje**: [Dart](https://dart.dev/)
*   **Paquetes Clave**:
    *   `audioplayers`: Para la reproducción de audio.
    *   `audiotags`: Para leer metadatos de archivos de audio.
    *   `provider`: Para la gestión del estado.
    *   `dynamic_color`: Para temas dinámicos de Material You.
    *   `flutter_markdown`: Para renderizar respuestas del chat.
    *   `http`: Para realizar peticiones a la API de IA.

## Configuración y Ejecución

### Requisitos Previos

*   Flutter SDK (versión 3.7.2 o superior)
*   Dart SDK
*   Dispositivo Android/Emulador o entorno de escritorio configurado.

### Pasos para Ejecutar

1.  **Clonar el repositorio** y navegar a la carpeta del proyecto.
2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```
3.  **Ejecutar la aplicación**:
    ```bash
    flutter run
    ```

## Estructura del Proyecto

*   `lib/main.dart`: Punto de entrada de la aplicación.
*   `lib/pages/`: Contiene las pantallas principales (Página de Biblioteca, Página de Chat IA, etc.).
*   `lib/services/`: Lógica de negocio y servicios (Servicio de Música, API, Cache).
*   `lib/models/`: Modelos de datos (ej. `Song`).
*   `lib/config/`: Configuraciones globales de la app.
