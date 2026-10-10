class Project {
  final int id;
  String nombre;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;

  Project({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });
}
