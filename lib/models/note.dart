class Note {
  final int id;
  final int idProyecto;
  String titulo;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;
  List<int> idsEtiquetas;

  Note({
    required this.id,
    required this.idProyecto,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
    required this.idsEtiquetas,
  });
}
