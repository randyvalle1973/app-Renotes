import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../models/note.dart';
import '../models/label.dart';
import '../data/sample_data.dart';

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final List<Project> proyectos = SampleData.crearProyectos();
  final List<Note> notas = SampleData.crearNotas();
  final List<Label> etiquetas = SampleData.crearEtiquetas();

  int _siguienteIdProyecto = 4;

  int contarNotas(int idProyecto) {
    return notas.where((nota) {
      return nota.idProyecto == idProyecto;
    }).length;
  }

  List<Note> obtenerNotasProyecto(int idProyecto) {
    return notas.where((nota) {
      return nota.idProyecto == idProyecto;
    }).toList();
  }

  List<Label> obtenerEtiquetasNota(Note nota) {
    return etiquetas.where((etiqueta) {
      return nota.idsEtiquetas.contains(etiqueta.id);
    }).toList();
  }

  List<Label> obtenerEtiquetasProyecto(int idProyecto) {
    final notasProyecto = obtenerNotasProyecto(idProyecto);

    final ids = <int>{};

    for (final nota in notasProyecto) {
      ids.addAll(nota.idsEtiquetas);
    }

    return etiquetas.where((etiqueta) {
      return ids.contains(etiqueta.id);
    }).toList();
  }

  void eliminarNota(int idNota) {
    notas.removeWhere((nota) => nota.id == idNota);
    notifyListeners();
  }

  void crearNota(
    int idProyecto,
    String titulo,
    String descripcion,
    List<int> idsEtiquetas,
  ) {
    final ahora = DateTime.now();

    final nuevoId = notas.isEmpty
        ? 1
        : notas
                  .map((nota) => nota.id)
                  .reduce(
                    (actual, siguiente) =>
                        actual > siguiente ? actual : siguiente,
                  ) +
              1;

    final nota = Note(
      id: nuevoId,
      idProyecto: idProyecto,
      titulo: titulo.trim(),
      descripcion: descripcion.trim(),
      fechaCreacion: ahora,
      fechaModificacion: ahora,
      idsEtiquetas: List<int>.from(idsEtiquetas),
    );

    notas.add(nota);

    final proyecto = proyectos.firstWhere(
      (proyecto) => proyecto.id == idProyecto,
    );
    proyecto.fechaModificacion = ahora;

    notifyListeners();
  }

  void editarNota(
    int idNota,
    String titulo,
    String descripcion,
    List<int> idsEtiquetas,
  ) {
    final nota = notas.firstWhere((nota) => nota.id == idNota);

    nota.titulo = titulo.trim();
    nota.descripcion = descripcion.trim();
    nota.idsEtiquetas = List<int>.from(idsEtiquetas);
    nota.fechaModificacion = DateTime.now();

    final proyecto = proyectos.firstWhere(
      (proyecto) => proyecto.id == nota.idProyecto,
    );
    proyecto.fechaModificacion = nota.fechaModificacion;

    notifyListeners();
  }

  String normalizarTexto(String texto) {
    const caracteres = 'áéíóúüñ';
    const reemplazos = 'aeiouun';

    String resultado = texto.trim().toLowerCase();

    for (int indice = 0; indice < caracteres.length; indice++) {
      resultado = resultado.replaceAll(caracteres[indice], reemplazos[indice]);
    }

    return resultado;
  }

  Label? buscarEtiqueta(String nombre) {
    final nombreNormalizado = normalizarTexto(nombre);

    for (final etiqueta in etiquetas) {
      if (normalizarTexto(etiqueta.nombre) == nombreNormalizado) {
        return etiqueta;
      }
    }

    return null;
  }

  Label crearEtiqueta(String nombre) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío');
    }

    final existente = buscarEtiqueta(nombreLimpio);

    if (existente != null) {
      return existente;
    }

    final nuevoId = etiquetas.isEmpty
        ? 1
        : etiquetas
                  .map((etiqueta) => etiqueta.id)
                  .reduce(
                    (actual, siguiente) =>
                        actual > siguiente ? actual : siguiente,
                  ) +
              1;

    final etiqueta = Label(
      id: nuevoId,
      nombre: nombreLimpio,
      color: Colors.deepPurple,
    );

    etiquetas.add(etiqueta);
    notifyListeners();

    return etiqueta;
  }

  int contarNotasEtiqueta(int idEtiqueta) {
    return notas.where((nota) {
      return nota.idsEtiquetas.contains(idEtiqueta);
    }).length;
  }

  bool renombrarEtiqueta(int idEtiqueta, String nuevoNombre) {
    final nombreLimpio = nuevoNombre.trim();

    if (nombreLimpio.isEmpty) {
      return false;
    }

    final existente = buscarEtiqueta(nombreLimpio);

    if (existente != null && existente.id != idEtiqueta) {
      return false;
    }

    final etiqueta = etiquetas.firstWhere(
      (etiqueta) => etiqueta.id == idEtiqueta,
    );

    etiqueta.nombre = nombreLimpio;
    notifyListeners();

    return true;
  }

  void eliminarEtiqueta(int idEtiqueta) {
    etiquetas.removeWhere((etiqueta) => etiqueta.id == idEtiqueta);

    for (final nota in notas) {
      nota.idsEtiquetas.remove(idEtiqueta);
    }

    notifyListeners();
  }

  List<Note> filtrarNotasPorEtiquetas(
    Set<int> idsSeleccionados, {
    required bool usarTodas,
  }) {
    if (idsSeleccionados.isEmpty) {
      return List<Note>.from(notas);
    }

    return notas.where((nota) {
      if (usarTodas) {
        return idsSeleccionados.every((id) => nota.idsEtiquetas.contains(id));
      }

      return idsSeleccionados.any((id) => nota.idsEtiquetas.contains(id));
    }).toList();
  }

  List<Note> buscarNotasGlobalmente({
    String texto = '',
    int? idProyecto,
    Set<int> idsEtiquetas = const {},
  }) {
    final busqueda = normalizarTexto(texto);

    return notas.where((nota) {
      final titulo = normalizarTexto(nota.titulo);
      final contenido = normalizarTexto(nota.descripcion);

      final coincideTexto =
          titulo.contains(busqueda) || contenido.contains(busqueda);

      final coincideProyecto =
          idProyecto == null || nota.idProyecto == idProyecto;

      final coincideEtiquetas =
          idsEtiquetas.isEmpty ||
          idsEtiquetas.every((id) => nota.idsEtiquetas.contains(id));

      return coincideTexto && coincideProyecto && coincideEtiquetas;
    }).toList();
  }

  Project? obtenerProyectoNota(Note nota) {
    for (final proyecto in proyectos) {
      if (proyecto.id == nota.idProyecto) {
        return proyecto;
      }
    }

    return null;
  }

  void crearProyecto(String nombre, String descripcion) {
    final ahora = DateTime.now();

    final proyecto = Project(
      id: _siguienteIdProyecto++,
      nombre: nombre.trim(),
      descripcion: descripcion.trim(),
      fechaCreacion: ahora,
      fechaModificacion: ahora,
    );

    proyectos.add(proyecto);
    notifyListeners();
  }

  void editarProyecto(int id, String nombre, String descripcion) {
    final proyecto = proyectos.firstWhere((proyecto) => proyecto.id == id);

    proyecto.nombre = nombre.trim();
    proyecto.descripcion = descripcion.trim();
    proyecto.fechaModificacion = DateTime.now();

    notifyListeners();
  }

  void eliminarProyecto(int id) {
    proyectos.removeWhere((proyecto) => proyecto.id == id);

    notas.removeWhere((nota) => nota.idProyecto == id);

    notifyListeners();
  }
}
