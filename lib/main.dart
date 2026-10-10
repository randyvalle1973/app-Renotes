import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'Screens/home_screen.dart';
import 'Screens/label_screen.dart';
import 'Screens/search_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  ThemeMode themeMode = ThemeMode.light;
  final AppState estado = AppState();

  void cambiarTema() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    estado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReNotes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: MainScreen(
        cambiarTema: cambiarTema,
        esOscuro: themeMode == ThemeMode.dark,
        estado: estado,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback cambiarTema;
  final bool esOscuro;
  final AppState estado;

  const MainScreen({
    super.key,
    required this.cambiarTema,
    required this.esOscuro,
    required this.estado,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int indiceActual = 0;
  int? idEtiquetaPendiente;
  int numeroNavegacionEtiqueta = 0;

  void abrirEtiquetas(int idEtiqueta) {
    setState(() {
      idEtiquetaPendiente = idEtiqueta;
      numeroNavegacionEtiqueta++;
      indiceActual = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: indiceActual,
        children: [
          HomeScreen(
            cambiarTema: widget.cambiarTema,
            esOscuro: widget.esOscuro,
            estado: widget.estado,
            abrirEtiquetas: abrirEtiquetas,
          ),
          LabelScreen(
            estado: widget.estado,
            abrirEtiquetas: abrirEtiquetas,
            idEtiquetaInicial: idEtiquetaPendiente,
            numeroNavegacion: numeroNavegacionEtiqueta,
          ),
          SearchScreen(estado: widget.estado, abrirEtiquetas: abrirEtiquetas),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceActual,
        onTap: (index) {
          setState(() {
            indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell_outlined),
            activeIcon: Icon(Icons.sell_rounded),
            label: 'Etiquetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}
