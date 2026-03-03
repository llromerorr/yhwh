import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yhwh/controllers/BiblePageController.dart';

class HihglighterCreate extends StatelessWidget {
  const HihglighterCreate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hemos sacado el color 0x0 de la lista, ya que ahora 
    // "Eliminar" es un botón con icono propio y no un color falso.
    final List<int> highlightColors = [
      0xff8ab4f8,
      0xfff28b82,
      0xfffdd663,
      0xff81c995,
      0xffff8bcb,
      0xffd7aefb,
      0xff78d9ec
    ];

    return GetBuilder<BiblePageController>(
      init: BiblePageController(),
      builder: (biblePageController) {
        return Row(
          children: [
            // --- 1. SECCIÓN DE ACCIONES (Fijas a la izquierda) ---
            
            // Botón: Eliminar Resaltado
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              iconSize: 26,
              tooltip: 'Eliminar resaltado',
              color: Theme.of(context).indicatorColor,
              onPressed: () {
                biblePageController.removeFromHighlighter();
              },
            ),
            
            // Botón: Copiar
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              iconSize: 24,
              tooltip: 'Copiar versículos',
              color: Theme.of(context).indicatorColor,
              onPressed: () {
                biblePageController.copyVersesToClipboard();
              },
            ),

            // Línea divisoria sutil
            Container(
              height: 28,
              width: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: Theme.of(context).indicatorColor.withValues(alpha: 0.2),
            ),
            
            // --- 2. SECCIÓN DE COLORES (Deslizable a la derecha) ---
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: highlightColors.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  Color color = Color(highlightColors[index]);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Center(
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          biblePageController.addToHighlighter(color);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            // Borde sutil para que el círculo resalte 
                            // independientemente de si el fondo es blanco o negro
                            border: Border.all(
                              color: Theme.of(context).indicatorColor.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}