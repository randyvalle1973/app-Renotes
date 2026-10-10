import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/project.dart';
import '../state/app_state.dart';

class NoteEditorScreen extends StatefulWidget {
  final AppState estado;
  final Project proyecto;
  final Note? nota;

  const NoteEditorScreen({
    super.key,
    required this.estado,
    required this.proyecto,
    this.nota,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController controladorTitulo;
  late final TextEditingController controladorDescripcion;
  late final Set<int> etiquetasSeleccionadas;
  final formulario = GlobalKey<FormState>();
  bool guardado = false;

  @override
  void initState() {
    super.initState();

    controladorTitulo = TextEditingController(text: widget.nota?.titulo ?? '');

    controladorDescripcion = TextEditingController(
      text: widget.nota?.descripcion ?? '',
    );

    etiquetasSeleccionadas = {...?widget.nota?.idsEtiquetas};
  }

  @override
  void dispose() {
    controladorTitulo.dispose();
    controladorDescripcion.dispose();
    super.dispose();
  }

  bool hayCambios() {
    final tituloOriginal = widget.nota?.titulo ?? '';
    final descripcionOriginal = widget.nota?.descripcion ?? '';
    final etiquetasOriginales = widget.nota?.idsEtiquetas.toSet() ?? <int>{};

    return controladorTitulo.text != tituloOriginal ||
        controladorDescripcion.text != descripcionOriginal ||
        !etiquetasSeleccionadas.containsAll(etiquetasOriginales) ||
        !etiquetasOriginales.containsAll(etiquetasSeleccionadas);
  }

  Future<bool> confirmarSalida() async {
    if (guardado || !hayCambios()) {
      return true;
    }

    final salir = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text(
            'Tienes cambios que todavía no has guardado. '
            '¿Deseas descartarlos?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, false);
              },
              child: const Text('Seguir editando'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, true);
              },
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    return salir ?? false;
  }

  void agregarEtiqueta(String nombre) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return;
    }

    final etiqueta = widget.estado.crearEtiqueta(nombreLimpio);

    if (!mounted) return;

    setState(() {
      etiquetasSeleccionadas.add(etiqueta.id);
    });
  }

  void guardarNota() {
    if (!formulario.currentState!.validate()) {
      return;
    }

    if (widget.nota == null) {
      widget.estado.crearNota(
        widget.proyecto.id,
        controladorTitulo.text,
        controladorDescripcion.text,
        etiquetasSeleccionadas.toList(),
      );
    } else {
      widget.estado.editarNota(
        widget.nota!.id,
        controladorTitulo.text,
        controladorDescripcion.text,
        etiquetasSeleccionadas.toList(),
      );
    }
    setState(() {
      guardado = true;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.nota != null;
    return PopScope(
      canPop: guardado,
      onPopInvokedWithResult: (salio, resultado) async {
        if (salio) return;

        final permitirSalida = await confirmarSalida();

        if (permitirSalida && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(esEdicion ? 'Editar nota' : 'Nueva nota'),
          actions: [
            TextButton(onPressed: guardarNota, child: const Text('Guardar')),
          ],
        ),
        body: Form(
          key: formulario,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: controladorTitulo,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Escribe el título de la nota',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: controladorDescripcion,
                maxLines: null,
                minLines: 8,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  hintText: 'Escribe tu investigación...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Text('Etiquetas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),

              Autocomplete<String>(
                displayStringForOption: (opcion) => opcion,

                optionsBuilder: (TextEditingValue valor) {
                  final texto = widget.estado.normalizarTexto(valor.text);

                  if (texto.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  return widget.estado.etiquetas
                      .where((etiqueta) {
                        final nombreNormalizado = widget.estado.normalizarTexto(
                          etiqueta.nombre,
                        );

                        final yaSeleccionada = etiquetasSeleccionadas.contains(
                          etiqueta.id,
                        );

                        return nombreNormalizado.contains(texto) &&
                            !yaSeleccionada;
                      })
                      .map((etiqueta) => etiqueta.nombre);
                },

                onSelected: (String nombre) {
                  agregarEtiqueta(nombre);
                },

                fieldViewBuilder: (context, controlador, foco, enviar) {
                  void confirmarEtiqueta() {
                    final nombre = controlador.text.replaceAll(',', '').trim();

                    if (nombre.isEmpty) return;

                    agregarEtiqueta(nombre);
                    controlador.clear();
                  }

                  return TextField(
                    controller: controlador,
                    focusNode: foco,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Buscar o crear etiqueta',
                      prefixIcon: const Icon(Icons.sell_outlined),
                      suffixIcon: IconButton(
                        tooltip: 'Añadir etiqueta',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: confirmarEtiqueta,
                      ),
                    ),

                    onChanged: (texto) {
                      if (texto.contains(',')) {
                        final partes = texto.split(',');

                        for (int i = 0; i < partes.length - 1; i++) {
                          agregarEtiqueta(partes[i]);
                        }

                        controlador.value = TextEditingValue(
                          text: partes.last,
                          selection: TextSelection.collapsed(
                            offset: partes.last.length,
                          ),
                        );
                      }
                    },

                    onSubmitted: (texto) {
                      confirmarEtiqueta();
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.estado.etiquetas
                    .where((etiqueta) {
                      return etiquetasSeleccionadas.contains(etiqueta.id);
                    })
                    .map((etiqueta) {
                      return InputChip(
                        label: Text(etiqueta.nombre),
                        onDeleted: () {
                          setState(() {
                            etiquetasSeleccionadas.remove(etiqueta.id);
                          });
                        },
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
