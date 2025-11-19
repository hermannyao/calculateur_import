// fichier: lib/main.dart

import 'package:calculateur_import/screens/calcul_prix_revient.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CalculateurApp());
}

class CalculateurApp extends StatelessWidget {
  const CalculateurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de Prix de Revient',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: CalculPrixRevient(),
      debugShowCheckedModeBanner: false,
    );
  }
}