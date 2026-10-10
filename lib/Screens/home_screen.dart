import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import 'project_notes_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback cambiarTema;
  final bool esOscuro;
  final AppState estado;
  final void Function(int) abrirEtiquetas;

  const HomeScreen({
    super.key,
    required this.cambiarTema,
    required this.esOscuro,
    required this.estado,
    required this.abrirEtiquetas,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  void didUpdateWidget(covariant HomeScreen anterior) {
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

  void _mostrarFormulario({Project? proyecto}) {
    final controladorNombre = TextEditingController(
      text: proyecto?.nombre ?? '',
    );

    final controladorDescripcion = TextEditingController(
      text: proyecto?.descripcion ?? '',
    );

    final formulario = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: Text(proyecto == null ? 'Nuevo proyecto' : 'Editar proyecto'),
          content: Form(
            key: formulario,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controladorNombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del proyecto',
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controladorDescripcion,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                ],
              ),
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
                if (!formulario.currentState!.validate()) {
                  return;
                }

                if (proyecto == null) {
                  widget.estado.crearProyecto(
                    controladorNombre.text,
                    controladorDescripcion.text,
                  );
                } else {
                  widget.estado.editarProyecto(
                    proyecto.id,
                    controladorNombre.text,
                    controladorDescripcion.text,
                  );
                }

                Navigator.pop(contextoDialogo);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      controladorNombre.dispose();
      controladorDescripcion.dispose();
    });
  }

  void _confirmarEliminar(Project proyecto) {
    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Eliminar proyecto'),
          content: Text(
            '¿Seguro que deseas eliminar "${proyecto.nombre}"? '
            'También se eliminarán todas sus notas.',
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
                widget.estado.eliminarProyecto(proyecto.id);
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
    final proyectos = widget.estado.proyectos;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mis proyectos',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('Organiza tus investigaciones'),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: widget.cambiarTema,
                    icon: Icon(
                      widget.esOscuro
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tus investigaciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('${proyectos.length} proyectos'),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: proyectos.isEmpty
                    ? const Center(child: Text('Todavía no tienes proyectos'))
                    : ListView.builder(
                        itemCount: proyectos.length,
                        itemBuilder: (context, indice) {
                          final proyecto = proyectos[indice];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProjectCard(
                              proyecto: proyecto,
                              cantidadNotas: widget.estado.contarNotas(
                                proyecto.id,
                              ),
                              alAbrir: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectNotesScreen(
                                      proyecto: proyecto,
                                      estado: widget.estado,
                                      abrirEtiquetas: widget.abrirEtiquetas,
                                    ),
                                  ),
                                );
                              },
                              alEditar: () {
                                _mostrarFormulario(proyecto: proyecto);
                              },
                              alEliminar: () {
                                _confirmarEliminar(proyecto);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }
}
