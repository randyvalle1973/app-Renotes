import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/note.dart';
import '../state/app_state.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';

class ProjectNotesScreen extends StatefulWidget {
  final Project proyecto;
  final AppState estado;
  final void Function(int) abrirEtiquetas;

  const ProjectNotesScreen({
    super.key,
    required this.proyecto,
    required this.estado,
    required this.abrirEtiquetas,
  });

  @override
  State<ProjectNotesScreen> createState() => _ProjectNotesScreenState();
}

class _ProjectNotesScreenState extends State<ProjectNotesScreen> {
  String busqueda = '';
  final Set<int> etiquetasSeleccionadas = {};

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
  void didUpdateWidget(covariant ProjectNotesScreen anterior) {
    super.didUpdateWidget(anterior);

    if (anterior.estado != widget.estado) {
      anterior.estado.removeListener(_actualizar);
      widget.estado.addListener(_actualizar);
    }
  }

  @override
  void dispose() {
    widget.estado.removeListener(_actualizar);
    super.dispose();
  }

  List<Note> obtenerNotasFiltradas() {
    final notasProyecto = widget.estado.obtenerNotasProyecto(
      widget.proyecto.id,
    );

    return notasProyecto.where((nota) {
      final texto = busqueda.toLowerCase().trim();

      final coincideBusqueda =
          nota.titulo.toLowerCase().contains(texto) ||
          nota.descripcion.toLowerCase().contains(texto);

      final coincideEtiquetas =
          etiquetasSeleccionadas.isEmpty ||
          etiquetasSeleccionadas.every((id) => nota.idsEtiquetas.contains(id));

      return coincideBusqueda && coincideEtiquetas;
    }).toList();
  }

  void confirmarEliminar(Note nota) {
    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: Text('¿Seguro que deseas eliminar "${nota.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                widget.estado.eliminarNota(nota.id);
                Navigator.pop(contextoDialogo);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notas = obtenerNotasFiltradas();

    final etiquetas = widget.estado.obtenerEtiquetasProyecto(
      widget.proyecto.id,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.proyecto.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.estado.contarNotas(widget.proyecto.id)} notas',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por título o contenido',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) {
                setState(() {
                  busqueda = valor;
                });
              },
            ),

            const SizedBox(height: 16),

            if (etiquetas.isNotEmpty)
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: etiquetas.map((etiqueta) {
                    final seleccionada = etiquetasSeleccionadas.contains(
                      etiqueta.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(etiqueta.nombre),
                        selected: seleccionada,
                        onSelected: (valor) {
                          setState(() {
                            if (valor) {
                              etiquetasSeleccionadas.add(etiqueta.id);
                            } else {
                              etiquetasSeleccionadas.remove(etiqueta.id);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: notas.isEmpty
                  ? const Center(child: Text('No hay notas que mostrar'))
                  : ListView.builder(
                      itemCount: notas.length,
                      itemBuilder: (context, indice) {
                        final nota = notas[indice];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NoteCard(
                            nota: nota,
                            etiquetas: widget.estado.obtenerEtiquetasNota(nota),
                            alAbrir: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteDetailScreen(
                                    nota: nota,
                                    proyecto: widget.proyecto,
                                    estado: widget.estado,
                                    abrirEtiquetas: widget.abrirEtiquetas,
                                  ),
                                ),
                              );
                            },
                            alEliminar: () {
                              confirmarEliminar(nota);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(
                estado: widget.estado,
                proyecto: widget.proyecto,
              ),
            ),
          );
        },

        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
    );
  }
}
