import 'dart:io';

import 'package:flutter/foundation.dart';

class LoggerService {
  // Archivo de log privado
  static final File _logFile = File('${Directory.systemTemp.path}\\gym_admin_log_process.txt');

  /// Inicializa el archivo de log
  static void init() {
    if (kDebugMode) {
      print("📁 Archivo de log en: ${_logFile.path}");
    }
    write("--- Aplicación Iniciada ---");
  }

  /// Método global para escribir logs
  static void write(String message) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      _logFile.writeAsStringSync(
        '[$timestamp] $message\n', 
        mode: FileMode.append,
      );
      
      // También lo imprimimos en consola si estamos en desarrollo
      if (kDebugMode) {
        debugPrint('LOG: $message');
      }
    } catch (e) {
      debugPrint("Error escribiendo en el log: $e");
    }
  }

  /// Método para capturar errores de Flutter
  static void logFlutterError(FlutterErrorDetails details) {
    write('FlutterError: ${details.exceptionAsString()}');
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  }
}