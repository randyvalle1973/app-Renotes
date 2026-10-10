import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/project.dart';
import '../state/app_state.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note nota;
  final Project proyecto;
  final AppState estado;
  final void Function(int)? abrirEtiquetas;

  const NoteDetailScreen({
    super.key,
    required this.nota,
    required this.proyecto,
    required this.estado,
    required this.abrirEtiquetas,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.estado.addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.estado.removeListener(_actualizar);
    super.dispose();
  }

  String formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: Text(
            '¿Seguro que deseas eliminar "${widget.nota.titulo}"? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      widget.estado.eliminarNota(widget.nota.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nota = widget.nota;
    final etiquetas = widget.estado.obtenerEtiquetasNota(nota);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de nota'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(
                    estado: widget.estado,
                    proyecto: widget.proyecto,
                    nota: nota,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Eliminar nota',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: confirmarEliminar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nota.titulo,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('Proyecto: ${widget.proyecto.nombre}'),
            const SizedBox(height: 6),
            Text('Creada: ${formatearFecha(nota.fechaCreacion)}'),
            Text('Modificada: ${formatearFecha(nota.fechaModificacion)}'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: etiquetas.map((etiqueta) {
                return ActionChip(
                  label: Text(etiqueta.nombre),
                  backgroundColor: etiqueta.color.withValues(alpha: 0.12),
                  side: BorderSide.none,
                  onPressed: () {
                    debugPrint('ETIQUETA PULSADA: ${etiqueta.nombre}');

                    if (widget.abrirEtiquetas == null) {
                      debugPrint('ERROR: abrirEtiquetas es null');
                      return;
                    }

                    widget.abrirEtiquetas!(etiqueta.id);

                    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SelectableText(
              nota.descripcion.isEmpty
                  ? 'Esta nota no tiene contenido.'
                  : nota.descripcion,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
