import 'package:flutter/material.dart';

import '../models/label.dart';
import '../models/note.dart';
import '../state/app_state.dart';
import 'note_detail_screen.dart';

class LabelScreen extends StatefulWidget {
  final AppState estado;
  final void Function(int) abrirEtiquetas;
  final int? idEtiquetaInicial;
  final int numeroNavegacion;

  const LabelScreen({
    super.key,
    required this.estado,
    required this.abrirEtiquetas,
    required this.idEtiquetaInicial,
    required this.numeroNavegacion,
  });

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final Set<int> etiquetasSeleccionadas = {};
  bool usarTodas = true;

  @override
  void initState() {
    super.initState();

    widget.estado.addListener(_actualizar);

    final id = widget.idEtiquetaInicial;

    if (id != null) {
      etiquetasSeleccionadas.add(id);
    }
  }

  @override
  void didUpdateWidget(covariant LabelScreen anterior) {
    super.didUpdateWidget(anterior);

    if (widget.numeroNavegacion != anterior.numeroNavegacion &&
        widget.idEtiquetaInicial != null) {
      etiquetasSeleccionadas
        ..clear()
        ..add(widget.idEtiquetaInicial!);
    }
  }

  void _actualizar() {
    if (mounted) {
      setState(() {
        etiquetasSeleccionadas.removeWhere(
          (id) => !widget.estado.etiquetas.any((etiqueta) => etiqueta.id == id),
        );
      });
    }
  }

  @override
  void dispose() {
    widget.estado.removeListener(_actualizar);
    super.dispose();
  }

  void mostrarFormulario({Label? etiqueta}) {
    final controlador = TextEditingController(text: etiqueta?.nombre ?? '');

    String? error;

    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (contexto, actualizarDialogo) {
            return AlertDialog(
              title: Text(
                etiqueta == null ? 'Nueva etiqueta' : 'Editar etiqueta',
              ),
              content: TextField(
                controller: controlador,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  errorText: error,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(contextoDialogo);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombre = controlador.text.trim();

                    if (nombre.isEmpty) {
                      actualizarDialogo(() {
                        error = 'Escribe un nombre';
                      });
                      return;
                    }

                    if (etiqueta == null) {
                      final existente = widget.estado.buscarEtiqueta(nombre);

                      if (existente != null) {
                        actualizarDialogo(() {
                          error = 'Esta etiqueta ya existe';
                        });
                        return;
                      }

                      widget.estado.crearEtiqueta(nombre);
                    } else {
                      final correcto = widget.estado.renombrarEtiqueta(
                        etiqueta.id,
                        nombre,
                      );

                      if (!correcto) {
                        actualizarDialogo(() {
                          error = 'Nombre duplicado o inválido';
                        });
                        return;
                      }
                    }

                    Navigator.pop(contextoDialogo);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(controlador.dispose);
  }

  void confirmarEliminar(Label etiqueta) {
    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Eliminar etiqueta'),
          content: Text(
            '¿Eliminar "${etiqueta.nombre}"? '
            'Se quitará de todas las notas, '
            'pero las notas se conservarán.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                widget.estado.eliminarEtiqueta(etiqueta.id);
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
    final notasFiltradas = widget.estado.filtrarNotasPorEtiquetas(
      etiquetasSeleccionadas,
      usarTodas: usarTodas,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiquetas'),
        actions: [
          IconButton(
            tooltip: 'Nueva etiqueta',
            onPressed: () => mostrarFormulario(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Gestiona tus etiquetas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona etiquetas para filtrar notas '
            'de todos tus proyectos.',
          ),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.estado.etiquetas.length,
            itemBuilder: (context, indice) {
              final etiqueta = widget.estado.etiquetas[indice];
              final seleccionada = etiquetasSeleccionadas.contains(etiqueta.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: seleccionada,
                  onChanged: (valor) {
                    setState(() {
                      if (valor == true) {
                        etiquetasSeleccionadas.add(etiqueta.id);
                      } else {
                        etiquetasSeleccionadas.remove(etiqueta.id);
                      }
                    });
                  },
                  secondary: PopupMenuButton<String>(
                    tooltip: 'Opciones de etiqueta',
                    icon: Icon(Icons.sell_rounded, color: etiqueta.color),
                    onSelected: (opcion) {
                      if (opcion == 'editar') {
                        mostrarFormulario(etiqueta: etiqueta);
                      } else if (opcion == 'eliminar') {
                        confirmarEliminar(etiqueta);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                  title: Text(etiqueta.nombre),
                  subtitle: Text(
                    '${widget.estado.contarNotasEtiqueta(etiqueta.id)} notas',
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text('Modo de filtro:'),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('AND'),
                selected: usarTodas,
                onSelected: (_) {
                  setState(() {
                    usarTodas = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('OR'),
                selected: !usarTodas,
                onSelected: (_) {
                  setState(() {
                    usarTodas = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Notas encontradas (${notasFiltradas.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          if (notasFiltradas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No se encontraron notas')),
            ),

          ...notasFiltradas.map((nota) {
            final proyecto = widget.estado.obtenerProyectoNota(nota);

            if (proyecto == null) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(nota.titulo),
                subtitle: Text(
                  nota.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(
                        nota: nota,
                        proyecto: proyecto,
                        estado: widget.estado,
                        abrirEtiquetas: widget.abrirEtiquetas,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        tooltip: 'Nueva etiqueta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
