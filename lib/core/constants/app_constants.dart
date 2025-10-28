/// Clase que contiene las constantes de configuración de la aplicación
class AppConstants {
  // ============================================
  // CONFIGURACIÓN DE CATEGORÍAS
  // ============================================

  /// Lista de IDs de categorías permitidas para mostrar en la aplicación
  ///
  /// Solo los artículos de estas categorías se mostrarán en el feed.
  /// Para ocultar una categoría, coméntala o elimínala de esta lista.
  ///
  /// Ejemplo de uso:
  /// - Para mostrar: incluye el ID en la lista
  /// - Para ocultar: comenta la línea con //
  static const List<int> allowedCategoryIds = [
    89, // Actualidad
    36, // Eventos
    93, // LANZAMIENTOS
    // 7,   // Internacional (comentado = no se mostrará)
    // 220, // Policiales (comentado = no se mostrará)
  ];

  // ============================================
  // NOMBRES DE CATEGORÍAS
  // ============================================

  /// Mapeo de IDs de categorías a sus nombres legibles
  ///
  /// Útil para mostrar nombres de categorías en la interfaz de usuario
  /// sin necesidad de consultar la API cada vez.
  ///
  /// Formato: {id: 'Nombre de la categoría'}
  static const Map<int, String> categoryNames = {
    89: 'Actualidad',
    87: 'Apunte pastoral',
    92: 'DEVOCIONAL',
    88: 'Devocional',
    41: 'Modulo El Post',
    36: 'Eventos',
    61: 'Galeria',
    37: 'Hablemos',
    47: 'J. Echeverry',
    93: 'LANZAMIENTOS',
  };
}
