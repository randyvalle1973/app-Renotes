import 'package:flutter/material.dart';

import '../models/note.dart';
import '../state/app_state.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final void Function(int) abrirEtiquetas;
  final AppState estado;

  const SearchScreen({
    super.key,
    required this.estado,
    required this.abrirEtiquetas,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controladorBusqueda = TextEditingController();

  int? idProyectoSeleccionado;
  final Set<int> etiquetasSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    widget.estado.addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) {
      setState(() {
        if (idProyectoSeleccionado != null &&
            !widget.estado.proyectos.any(
              (proyecto) => proyecto.id == idProyectoSeleccionado,
            )) {
          idProyectoSeleccionado = null;
        }

        etiquetasSeleccionadas.removeWhere(
          (id) => !widget.estado.etiquetas.any((etiqueta) => etiqueta.id == id),
        );
      });
    }
  }

  @override
  void dispose() {
    widget.estado.removeListener(_actualizar);
    controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notasFiltradas = widget.estado.buscarNotasGlobalmente(
      texto: controladorBusqueda.text,
      idProyecto: idProyectoSeleccionado,
      idsEtiquetas: etiquetasSeleccionadas,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar notas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Encuentra tus investigaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: controladorBusqueda,
            decoration: InputDecoration(
              hintText: 'Buscar por título o contenido',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close),
                onPressed: () {
                  controladorBusqueda.clear();
                  setState(() {});
                },
              ),
            ),
            onChanged: (valor) {
              setState(() {});
            },
          ),

          const SizedBox(height: 20),

          Text('Proyecto', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            initialValue: idProyectoSeleccionado ?? -1,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.folder_outlined),
            ),
            hint: const Text('Todos los proyectos'),
            items: [
              const DropdownMenuItem<int>(
                value: -1,
                child: Text('Todos los proyectos'),
              ),
              ...widget.estado.proyectos.map((proyecto) {
                return DropdownMenuItem<int>(
                  value: proyecto.id,
                  child: Text(proyecto.nombre),
                );
              }),
            ],
            onChanged: (valor) {
              setState(() {
                idProyectoSeleccionado = valor == -1 ? null : valor;
              });
            },
          ),

          const SizedBox(height: 20),

          Text('Etiquetas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.estado.etiquetas.map((etiqueta) {
              final seleccionada = etiquetasSeleccionadas.contains(etiqueta.id);

              return FilterChip(
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
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          Text(
            'Resultados (${notasFiltradas.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),

          if (notasFiltradas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No se encontraron notas')),
            ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notasFiltradas.length,
            separatorBuilder: (context, indice) => const SizedBox(height: 12),
            itemBuilder: (context, indice) {
              final nota = notasFiltradas[indice];
              final proyecto = widget.estado.obtenerProyectoNota(nota);

              if (proyecto == null) {
                return const SizedBox.shrink();
              }

              return NoteCard(
                nota: nota,
                etiquetas: widget.estado.obtenerEtiquetasNota(nota),
                alAbrir: () {
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
                alEliminar: () {
                  mostrarConfirmacionEliminar(nota);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void mostrarConfirmacionEliminar(Note nota) {
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
}
