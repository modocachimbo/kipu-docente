import 'package:flutter/material.dart';

import '../theme.dart';

class Proximamente extends StatelessWidget {
  final String titulo;
  final String descripcion;

  const Proximamente(this.titulo, this.descripcion, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: KipuColores.moradoClaro,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.construction,
                    size: 40, color: KipuColores.morado),
              ),
              const SizedBox(height: 18),
              const Text('En construcción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: KipuColores.gris)),
            ],
          ),
        ),
      ),
    );
  }
}
