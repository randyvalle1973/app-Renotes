import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/note.dart';
import '../models/label.dart';

class SampleData {
  static String generarDescripcionLarga(
    String tema,
    String introduccion,
    String aplicaciones,
    String conclusiones,
  ) {
    return '''
$introduccion

OBJETIVO DE LA INVESTIGACIÓN

El propósito de esta investigación sobre $tema es comprender
sus fundamentos, estudiar sus principales características
y analizar la importancia que tiene dentro de su área.
Se busca identificar los conceptos más relevantes y
establecer relaciones entre la teoría y la práctica.

DESARROLLO Y APLICACIONES

$aplicaciones

Durante el estudio de $tema se deben considerar los
diferentes métodos utilizados, las herramientas disponibles
y los resultados obtenidos. También es importante
comparar distintas alternativas, identificar sus ventajas
y reconocer las limitaciones que puedan presentarse.

CONCLUSIONES

$conclusiones

Finalmente, esta investigación permite organizar los
conocimientos adquiridos, documentar los resultados
y establecer nuevas líneas de estudio para continuar
profundizando en el tema.
''';
  }

  static List<Project> crearProyectos() {
    return [
      Project(
        id: 1,
        nombre: 'Inteligencia Artificial',
        descripcion: 'Investigación sobre modelos y sistemas de IA',
        fechaCreacion: DateTime(2026, 9, 10),
        fechaModificacion: DateTime(2026, 10, 7),
      ),
      Project(
        id: 2,
        nombre: 'Ciencias Naturales',
        descripcion: 'Estudios, experimentos y observaciones',
        fechaCreacion: DateTime(2026, 9, 15),
        fechaModificacion: DateTime(2026, 10, 6),
      ),
      Project(
        id: 3,
        nombre: 'Desarrollo Móvil',
        descripcion: 'Aprendizaje de Flutter y aplicaciones Android',
        fechaCreacion: DateTime(2026, 9, 20),
        fechaModificacion: DateTime(2026, 10, 8),
      ),
    ];
  }

  static List<Label> crearEtiquetas() {
    return [
      Label(id: 1, nombre: 'Importante', color: Colors.red),
      Label(id: 2, nombre: 'Investigación', color: Colors.blue),
      Label(id: 3, nombre: 'Pendiente', color: Colors.orange),
      Label(id: 4, nombre: 'Flutter', color: Colors.purple),
      Label(id: 5, nombre: 'Experimentos', color: Colors.green),
      Label(id: 6, nombre: 'Referencias', color: Colors.teal),
      Label(id: 7, nombre: 'Ideas', color: Colors.indigo),
      Label(id: 8, nombre: 'Revisión', color: Colors.amber),
      Label(id: 9, nombre: 'Archivado', color: Colors.blueGrey),
    ];
  }

  static List<Note> crearNotas() {
    final ahora = DateTime(2026, 10, 8);

    return [
      Note(
        id: 1,
        idProyecto: 1,
        titulo: 'Introducción a la inteligencia artificial',
        descripcion: generarDescripcionLarga(
          'la inteligencia artificial',
          'La inteligencia artificial es una disciplina de la informática '
              'que busca desarrollar sistemas capaces de realizar tareas '
              'que normalmente requieren inteligencia humana, como el '
              'reconocimiento de patrones, el aprendizaje y la toma de decisiones.',
          'Entre sus aplicaciones se encuentran los asistentes virtuales, '
              'los sistemas de recomendación, el procesamiento del lenguaje '
              'natural y el análisis automatizado de grandes cantidades de datos.',
          'La inteligencia artificial ofrece numerosas oportunidades, '
              'pero también plantea desafíos relacionados con la privacidad, '
              'la transparencia de los algoritmos y el uso responsable de la tecnología.',
        ),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [1, 2],
      ),
      Note(
        id: 2,
        idProyecto: 1,
        titulo: 'Aprendizaje automático',
        descripcion: generarDescripcionLarga(
          'el aprendizaje automático',
          'El aprendizaje automático permite que los programas '
              'informáticos identifiquen patrones a partir de datos '
              'y mejoren sus predicciones sin recibir instrucciones '
              'específicas para cada situación.',
          'Sus aplicaciones incluyen la detección de fraudes, '
              'la clasificación de imágenes, la predicción de resultados '
              'y el análisis de información para apoyar decisiones.',
          'La calidad de los datos y la elección del modelo '
              'son factores fundamentales para obtener resultados '
              'confiables y evitar errores durante el entrenamiento.',
        ),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [2, 7],
      ),
      Note(
        id: 3,
        idProyecto: 1,
        titulo: 'Redes neuronales',
        descripcion:
            'Arquitecturas de redes neuronales y su '
            'utilización en el reconocimiento de patrones.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [1, 2],
      ),
      Note(
        id: 4,
        idProyecto: 1,
        titulo: 'Ética en la inteligencia artificial',
        descripcion: 'Estudio de los principios éticos relacionados con el desarrollo y uso de la inteligencia artificial, incluyendo la privacidad, la transparencia, los sesgos algorítmicos y la responsabilidad en la toma de decisiones automatizadas.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [3, 6],
      ),
      Note(
        id: 5,
        idProyecto: 1,
        titulo: 'Aplicaciones futuras de la IA',
        descripcion:
            'Ideas sobre posibles avances y nuevas '
            'aplicaciones de la inteligencia artificial.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [7],
      ),
      Note(
        id: 6,
        idProyecto: 2,
        titulo: 'Método científico',
        descripcion: generarDescripcionLarga(
          'el método científico',
          'El método científico es un procedimiento organizado '
              'que permite investigar fenómenos mediante la observación, '
              'la formulación de preguntas, la elaboración de hipótesis '
              'y la realización de experimentos.',
          'Se utiliza en investigaciones de biología, química '
              'y física para comprobar explicaciones, recopilar datos '
              'y obtener resultados que puedan analizarse y reproducirse.',
          'La aplicación rigurosa del método científico ayuda '
              'a reducir errores, distinguir evidencias de opiniones '
              'y construir conocimientos fundamentados.',
        ),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [2, 5],
      ),
      Note(
        id: 7,
        idProyecto: 2,
        titulo: 'Ecosistemas naturales',
        descripcion: generarDescripcionLarga(
          'los ecosistemas',
          'Los ecosistemas están formados por organismos vivos '
              'y elementos físicos que interactúan constantemente '
              'en un entorno determinado. Estas relaciones permiten '
              'el intercambio de energía y el reciclaje de nutrientes.',
          'El estudio de los ecosistemas permite comprender '
              'las cadenas alimentarias, la biodiversidad, '
              'el equilibrio ecológico y los efectos de la actividad '
              'humana sobre los recursos naturales.',
          'La conservación de los ecosistemas resulta esencial '
              'para proteger las especies, mantener los recursos '
              'naturales y reducir los impactos de la contaminación.',
        ),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [2, 6],
      ),
      Note(
        id: 8,
        idProyecto: 2,
        titulo: 'Cambio climático',
        descripcion:
            'Causas y consecuencias del calentamiento '
            'global y posibles medidas de mitigación.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [1, 2],
      ),
      Note(
        id: 9,
        idProyecto: 2,
        titulo: 'Experimentos de laboratorio',
        descripcion: 'Análisis de los procedimientos utilizados en experimentos científicos, desde la formulación de hipótesis hasta la recopilación de datos y evaluación de resultados, siguiendo las normas de seguridad y el método científico.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [5, 8],
      ),
      Note(
        id: 10,
        idProyecto: 2,
        titulo: 'Conservación ambiental',
        descripcion:
            'Estrategias para proteger la biodiversidad '
            'y utilizar los recursos naturales responsablemente.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [3, 7],
      ),
      Note(
        id: 11,
        idProyecto: 3,
        titulo: 'Introducción a Flutter',
        descripcion: generarDescripcionLarga(
          'Flutter y el desarrollo móvil',
          'Flutter es un framework de desarrollo de interfaces '
              'que permite construir aplicaciones multiplataforma '
              'utilizando el lenguaje de programación Dart. '
              'Su arquitectura se basa en widgets reutilizables.',
          'Flutter permite desarrollar interfaces adaptables, '
              'gestionar la navegación entre pantallas, crear '
              'formularios interactivos y organizar aplicaciones '
              'mediante componentes y estructuras reutilizables.',
          'Comprender los widgets, el manejo del estado '
              'y la organización del código resulta fundamental '
              'para construir aplicaciones mantenibles y escalables.',
        ),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [4, 2],
      ),
      Note(
        id: 12,
        idProyecto: 3,
        titulo: 'Widgets y estados',
        descripcion: 'Introducción al uso de widgets en Flutter y a la gestión de estados para desarrollar interfaces dinámicas e interactivas, comprendiendo las diferencias entre StatelessWidget y StatefulWidget y cómo actualizar la interfaz mediante setState()',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [4, 1],
      ),
      Note(
        id: 13,
        idProyecto: 3,
        titulo: 'Navegación entre pantallas',
        descripcion:
            'Uso de Navigator.push, Navigator.pop '
            'y rutas en aplicaciones Flutter.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [4, 6],
      ),
      Note(
        id: 14,
        idProyecto: 3,
        titulo: 'Colecciones en Dart',
        descripcion:
            'Utilización de List, Set, Map y operaciones '
            'como where, map y contains.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [4, 8],
      ),
      Note(
        id: 15,
        idProyecto: 3,
        titulo: 'Ideas para aplicaciones móviles',
        descripcion:
            'Propuestas de proyectos prácticos para '
            'continuar desarrollando habilidades en Flutter.',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        idsEtiquetas: [],
      ),
    ];
  }
}
