import json
import os

def procesar_biblia_json():
    archivo_versiculos = 'verses.json'
    archivo_libros = 'books.json'
    archivo_salida = 'biblia_desde_json.txt'

    # 1. MAPA DE NOMBRES A ID CORRECTO (1-66)
    # Actualizado con "Nahúm" y otras variantes con tildes por seguridad
    mapa_nombres_a_id_real = {
        # Antiguo Testamento
        "Génesis": 1, "Éxodo": 2, "Levítico": 3, "Números": 4, "Deuteronomio": 5,
        "Josué": 6, "Jueces": 7, "Rut": 8, "1 Samuel": 9, "2 Samuel": 10,
        "1 Reyes": 11, "2 Reyes": 12, "1 Crónicas": 13, "2 Crónicas": 14,
        "Esdras": 15, "Nehemías": 16, "Ester": 17, "Job": 18, "Salmos": 19,
        "Proverbios": 20, "Eclesiastés": 21, "Cantares": 22, "Isaías": 23,
        "Jeremías": 24, "Lamentaciones": 25, "Ezequiel": 26, "Daniel": 27,
        "Oseas": 28, "Joel": 29, "Amós": 30, "Abdías": 31, "Jonás": 32,
        
        "Miqueas": 33, 
        "Nahum": 34, "Nahúm": 34, # <-- AQUÍ ESTABA EL ERROR (Agregada la variante con tilde)
        "Habacuc": 35, 
        "Sofonías": 36, 
        "Haggeo": 37, "Hageo": 37, 
        "Zacarías": 38, "Malaquías": 39,
        
        # Nuevo Testamento (Variantes con S. y San)
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

    print("--- Iniciando conversión JSON ---")

    # 2. CARGAR LIBROS
    try:
        with open(archivo_libros, 'r', encoding='utf-8') as f:
            datos_libros = json.load(f)
        
        id_interno_a_nombre = {}
        for b in datos_libros:
            id_interno_a_nombre[b['book_number']] = b['long_name']
            
        print(f"Libros cargados en memoria: {len(id_interno_a_nombre)}")

    except FileNotFoundError:
        print(f"Error: No se encontró {archivo_libros}")
        return

    # 3. CARGAR VERSÍCULOS Y PROCESAR
    try:
        with open(archivo_versiculos, 'r', encoding='utf-8') as f:
            datos_versiculos = json.load(f)

        lista_final = []
        errores_libros = set()

        for v in datos_versiculos:
            id_interno = v['book_number']
            capitulo = v['chapter']
            versiculo = v['verse']
            texto = v['text']

            # Paso A: Obtener nombre del libro
            nombre_libro = id_interno_a_nombre.get(id_interno)

            if not nombre_libro:
                if id_interno not in errores_libros:
                    print(f"Advertencia: ID interno {id_interno} no existe en books.json")
                    errores_libros.add(id_interno)
                continue

            # Paso B: Limpieza y Mapeo
            nombre_limpio = nombre_libro.strip()
            id_real = mapa_nombres_a_id_real.get(nombre_limpio)

            if not id_real:
                if nombre_limpio not in errores_libros:
                    print(f"Advertencia CRÍTICA: El libro '{nombre_limpio}' no está en el mapa. Agrégalo al código.")
                    errores_libros.add(nombre_limpio)
                continue

            lista_final.append((id_real, capitulo, versiculo, texto))

        print(f"Versículos procesados correctamente: {len(lista_final)}")

    except FileNotFoundError:
        print(f"Error: No se encontró {archivo_versiculos}")
        return

    # 4. ORDENAR
    print("Ordenando datos...")
    lista_final.sort()

    # 5. ESCRIBIR ARCHIVO FINAL
    print(f"Escribiendo en '{archivo_salida}'...")
    with open(archivo_salida, 'w', encoding='utf-8') as f_out:
        for item in lista_final:
            libro, cap, ver, txt = item
            # Formato solicitado: '1:1:1': 'Texto ', (sin borrar caracteres especiales)
            linea = f"'{libro}:{cap}:{ver}': '{txt} ',\n"
            f_out.write(linea)

    print("--- ¡Proceso terminado con éxito! ---")

if __name__ == '__main__':
    procesar_biblia_json()