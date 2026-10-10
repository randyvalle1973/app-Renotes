import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/label.dart';

class NoteCard extends StatelessWidget {
  final Note nota;
  final List<Label> etiquetas;
  final VoidCallback alAbrir;
  final VoidCallback alEliminar;

  const NoteCard({
    super.key,
    required this.nota,
    required this.etiquetas,
    required this.alAbrir,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nota.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar nota',
                    onPressed: alEliminar,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                nota.descripcion.isEmpty ? 'Sin descripción' : nota.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colores.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: etiquetas.map((etiqueta) {
                  return Chip(
                    label: Text(
                      etiqueta.nombre,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: etiqueta.color.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text(
                'Modificada: '
                '${nota.fechaModificacion.day}/'
                '${nota.fechaModificacion.month}/'
                '${nota.fechaModificacion.year}',
                style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
