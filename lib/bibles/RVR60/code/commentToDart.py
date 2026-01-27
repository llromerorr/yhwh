import json
import os
import sys

# --- CONFIGURACIÓN ---
ARCHIVO_COMMENTARIES = 'commentaries.json'
ARCHIVO_BOOKS = 'books.json'
ARCHIVO_SALIDA = 'comentarios_biblicos.txt'

# Mapa Maestro: Nombre del Libro -> ID Real (1-66)
MAPA_LIBROS = {
    # Antiguo Testamento
    "Génesis": 1, "Éxodo": 2, "Levítico": 3, "Números": 4, "Deuteronomio": 5,
    "Josué": 6, "Jueces": 7, "Rut": 8, "1 Samuel": 9, "2 Samuel": 10,
    "1 Reyes": 11, "2 Reyes": 12, "1 Crónicas": 13, "2 Crónicas": 14,
    "Esdras": 15, "Nehemías": 16, "Ester": 17, "Job": 18, "Salmos": 19,
    "Proverbios": 20, "Eclesiastés": 21, "Cantares": 22, "Isaías": 23,
    "Jeremías": 24, "Lamentaciones": 25, "Ezequiel": 26, "Daniel": 27,
    "Oseas": 28, "Joel": 29, "Amós": 30, "Abdías": 31, "Jonás": 32,
    "Miqueas": 33, "Nahum": 34, "Nahúm": 34, "Habacuc": 35, "Sofonías": 36, 
    "Haggeo": 37, "Hageo": 37, "Zacarías": 38, "Malaquías": 39,
    
    # Nuevo Testamento (con variantes S. / San)
    "Mateo": 40, "S.Mateo": 40, "S. Mateo": 40, "San Mateo": 40,
    "Marcos": 41, "S.Marcos": 41, "S. Marcos": 41, "San Marcos": 41,
    "Lucas": 42, "S.Lucas": 42, "S. Lucas": 42, "San Lucas": 42,
    "Juan": 43, "S.Juan": 43, "S. Juan": 43, "San Juan": 43,
    
    "Hechos": 44, "Hechos de los Apóstoles": 44,
    "Romanos": 45, "1 Corintios": 46, "2 Corintios": 47, "Gálatas": 48,
    "Efesios": 49, "Filipenses": 50, "Colosenses": 51,
    "1 Tesalonicenses": 52, "2 Tesalonicenses": 53,
    "1 Timoteo": 54, "2 Timoteo": 55, "Tito": 56, "Filemón": 57,
    "Hebreos": 58, "Santiago": 59,
    "1 Pedro": 60, "2 Pedro": 61,
    "1 Juan": 62, "2 Juan": 63, "3 Juan": 64,
    "Judas": 65, "Apocalipsis": 66
}

def obtener_id_real(id_interno, db_libros):
    """
    Traduce el ID interno del JSON (ej: 10) al ID bíblico estándar (ej: 1)
    usando books.json como puente.
    """
    nombre = db_libros.get(id_interno)
    if not nombre: return None
    return MAPA_LIBROS.get(nombre.strip())

def main():
    print("--- Iniciando Procesamiento de Comentarios ---")

    # 1. Cargar la referencia de Libros (books.json)
    # Esto es necesario para saber qué libro es el número "10" o "490"
    try:
        with open(ARCHIVO_BOOKS, 'r', encoding='utf-8') as f:
            datos_books = json.load(f)
        # Creamos mapa: ID Interno -> Nombre Libro
        mapa_interno_nombre = {b['book_number']: b['long_name'] for b in datos_books}
        print(f"Referencia de libros cargada ({len(mapa_interno_nombre)} libros).")
    except FileNotFoundError:
        print(f"Error CRÍTICO: No encuentro '{ARCHIVO_BOOKS}'. Lo necesito para identificar los libros.")
        return

    # 2. Cargar los Comentarios (commentaries.json)
    try:
        with open(ARCHIVO_COMMENTARIES, 'r', encoding='utf-8') as f:
            datos_comentarios = json.load(f)
    except FileNotFoundError:
        print(f"Error: No encuentro '{ARCHIVO_COMMENTARIES}'")
        return

    lista_final = []
    total_items = len(datos_comentarios)
    print(f"Procesando {total_items} comentarios...")

    # 3. Procesar datos
    for i, item in enumerate(datos_comentarios):
        
        # Barra de progreso visual
        if i % 100 == 0 or i == total_items - 1:
            progreso = (i / total_items) * 100
            sys.stdout.write(f"\rProgreso: [{('=' * int(progreso // 2)).ljust(50)}] {progreso:.1f}%")
            sys.stdout.flush()

        # Extraer datos originales
        id_interno = item.get('book_number')
        capitulo = item.get('chapter_number_from')
        versiculo = item.get('verse_number_from')
        marcador = item.get('marker')
        texto = item.get('text', '')

        # Validar datos mínimos
        if id_interno is None or capitulo is None or versiculo is None:
            continue

        # Obtener el ID Real (1-66)
        id_real = obtener_id_real(id_interno, mapa_interno_nombre)
        
        if not id_real:
            # Si no se encuentra el libro, lo saltamos (o podrías imprimir un error)
            continue

        # Limpiar texto: Si el texto contiene comillas simples ', las escapamos para que no rompa el formato Python
        # Ejemplo: <a href='link'> -> <a href=\'link\'>
        texto_seguro = texto.replace("'", "\\'")

        # Guardar tupla para ordenar: (Libro, Capitulo, Versiculo, Marcador, Texto)
        lista_final.append((id_real, capitulo, versiculo, marcador, texto_seguro))

    print("\n\nOrdenando comentarios cronológicamente...")
    # Python ordena tuplas elemento por elemento (Libro -> Cap -> Vers -> Marcador)
    lista_final.sort()

    # 4. Escribir Archivo Final
    print(f"Escribiendo resultado en '{ARCHIVO_SALIDA}'...")
    
    with open(ARCHIVO_SALIDA, 'w', encoding='utf-8') as f_out:
        for item in lista_final:
            libro, cap, ver, marca, txt = item
            
            # FORMATO SOLICITADO:
            # 'book:chapter:verse:marker' : 'text'
            
            clave = f"{libro}:{cap}:{ver}:{marca}"
            linea = f"'{clave}' : '{txt}',\n"
            
            f_out.write(linea)

    print("--- ¡Listo! Archivo generado con éxito ---")

if __name__ == '__main__':
    main()