Map<String, int> bookToInt =
{
  "Génesis": 1,
  "Éxodo": 2,
  "Levítico": 3,
  "Números": 4,
  "Deuteronomio": 5,
  "Josué": 6,
  "Jueces": 7,
  "Rut": 8,
  "1 Samuel": 9,
  "2 Samuel": 10,
  "1 Reyes": 11,
  "2 Reyes": 12,
  "1 Crónicas": 13,
  "2 Crónicas": 14,
  "Esdras": 15,
  "Nehemías": 16,
  "Ester": 17,
  "Job": 18,
  "Salmos": 19,
  "Proverbios": 20,
  "Eclesiastés": 21,
  "Cantares": 22,
  "Isaías": 23,
  "Jeremías": 24,
  "Lamentaciones": 25,
  "Ezequiel": 26,
  "Daniel": 27,
  "Oseas": 28,
  "Joel": 29,
  "Amós": 30,
  "Abdías": 31,
  "Jonás": 32,
  "Miqueas": 33,
  "Nahum": 34,
  "Habacuc": 35,
  "Sofonías": 36,
  "Haggeo": 37,
  "Zacarías": 38,
  "Malaquías": 39,
  "Mateo": 40,
  "Marcos": 41,
  "Lucas": 42,
  "Juan": 43,
  "Hechos": 44,
  "Romanos": 45,
  "1 Corintios": 46,
  "2 Corintios": 47,
  "Gálatas": 48,
  "Efesios": 49,
  "Filipenses": 50,
  "Colosenses": 51,
  "1 Tesalonicenses": 52,
  "2 Tesalonicenses": 53,
  "1 Timoteo": 54,
  "2 Timoteo": 55,
  "Tito": 56,
  "Filemón": 57,
  "Hebreos": 58,
  "Santiago": 59,
  "1 Pedro": 60,
  "2 Pedro": 61,
  "1 Juan": 62,
  "2 Juan": 63,
  "3 Juan": 64,
  "Judas": 65,
  "Apocalipsis" : 66
};

Map<int, String> intToBook =
{
  1: "Génesis",
  2: "Éxodo",
  3: "Levítico",
  4: "Números",
  5: "Deuteronomio",
  6: "Josué",
  7: "Jueces",
  8: "Rut",
  9: "1 Samuel",
  10: "2 Samuel",
  11: "1 Reyes",
  12: "2 Reyes",
  13: "1 Crónicas",
  14: "2 Crónicas",
  15: "Esdras",
  16: "Nehemías",
  17: "Ester",
  18: "Job",
  19: "Salmos",
  20: "Proverbios",
  21: "Eclesiastés",
  22: "Cantares",
  23: "Isaías",
  24: "Jeremías",
  25: "Lamentaciones",
  26: "Ezequiel",
  27: "Daniel",
  28: "Oseas",
  29: "Joel",
  30: "Amós",
  31: "Abdías",
  32: "Jonás",
  33: "Miqueas",
  34: "Nahum",
  35: "Habacuc",
  36: "Sofonías",
  37: "Haggeo",
  38: "Zacarías",
  39: "Malaquías",
  40: "Mateo",
  41: "Marcos",
  42: "Lucas",
  43: "Juan",
  44: "Hechos",
  45: "Romanos",
  46: "1 Corintios",
  47: "2 Corintios",
  48: "Gálatas",
  49: "Efesios",
  50: "Filipenses",
  51: "Colosenses",
  52: "1 Tesalonicenses",
  53: "2 Tesalonicenses",
  54: "1 Timoteo",
  55: "2 Timoteo",
  56: "Tito",
  57: "Filemón",
  58: "Hebreos",
  59: "Santiago",
  60: "1 Pedro",
  61: "2 Pedro",
  62: "1 Juan",
  63: "2 Juan",
  64: "3 Juan",
  65: "Judas",
  66: "Apocalipsis"
};

Map<int, String> intToAbreviatura =
{
  1: "Gn.",
  2: "Ex.",
  3: "Lv.",
  4: "Nm.",
  5: "Dt.",
  6: "Jos.",
  7: "Jue.",
  8: "Rt.",
  9: "1 S.",
  10: "2 S.",
  11: "1 R.",
  12: "2 R.",
  13: "1 Cr.",
  14: "2 Cr.",
  15: "Esd.",
  16: "Neh.",
  17: "Est.",
  18: "Job.",
  19: "Sal.",
  20: "Pr.",
  21: "Ec.",
  22: "Cnt.",
  23: "Is.",
  24: "Jer.",
  25: "Lm.",
  26: "Ez.",
  27: "Dn.",
  28: "Os.",
  29: "Jl.",
  30: "Am.",
  31: "Abd.",
  32: "Jon.",
  33: "Mi.",
  34: "Nah.",
  35: "Hab.",
  36: "Sof.",
  37: "Hag.",
  38: "Zac.",
  39: "Mal.",
  40: "Mt.",
  41: "Mr.",
  42: "Lc.",
  43: "Jn.",
  44: "Hch.",
  45: "Ro.",
  46: "1 Co.",
  47: "2 Co.",
  48: "Gá.",
  49: "Ef.",
  50: "Fil.",
  51: "Col.",
  52: "1 Ts.",
  53: "2 Ts.",
  54: "1 Ti.",
  55: "2 Ti.",
  56: "Tit.",
  57: "Flm.",
  58: "He.",
  59: "Stg.",
  60: "1 P.",
  61: "2 P.",
  62: "1 Jn.",
  63: "2 Jn.",
  64: "3 Jn.",
  65: "Jud.",
  66: "Ap."
};

List namesAndChapters = const [
  ["Génesis", 50],
  ["Éxodo", 40],
  ["Levítico", 27],
  ["Números", 36],
  ["Deuteronomio", 34],
  ["Josué", 24],
  ["Jueces", 21],
  ["Rut", 4],
  ["1 Samuel", 31],
  ["2 Samuel", 24],
  ["1 Reyes", 22],
  ["2 Reyes", 25],
  ["1 Crónicas", 29],
  ["2 Crónicas", 36],
  ["Esdras", 10],
  ["Nehemías", 13],
  ["Ester", 10],
  ["Job", 42],
  ["Salmos", 150],
  ["Proverbios", 31],
  ["Eclesiastés", 12],
  ["Cantares", 8],
  ["Isaías", 66],
  ["Jeremías", 52],
  ["Lamentaciones", 5],
  ["Ezequiel", 48],
  ["Daniel", 12],
  ["Oseas", 14],
  ["Joel", 3],
  ["Amós", 9],
  ["Abdías", 1],
  ["Jonás", 4],
  ["Miqueas", 7],
  ["Nahum", 3],
  ["Habacuc", 3],
  ["Sofonías", 3],
  ["Haggeo", 2],
  ["Zacarías", 14],
  ["Malaquías", 4],
  ["Mateo", 28],
  ["Marcos", 16],
  ["Lucas", 24],
  ["Juan", 21],
  ["Hechos", 28],
  ["Romanos", 16],
  ["1 Corintios", 16],
  ["2 Corintios", 13],
  ["Gálatas", 6],
  ["Efesios", 6],
  ["Filipenses", 4],
  ["Colosenses", 4],
  ["1 Tesalonicenses", 5],
  ["2 Tesalonicenses", 3],
  ["1 Timoteo", 6],
  ["2 Timoteo", 4],
  ["Tito", 3],
  ["Filemón", 1],
  ["Hebreos", 13],
  ["Santiago", 5],
  ["1 Pedro", 5],
  ["2 Pedro", 3],
  ["1 Juan", 5],
  ["2 Juan", 1],
  ["3 Juan", 1],
  ["Judas", 1],
  ["Apocalipsis", 22]
];

Map<int, String> weekNumberToString =
{
  1: "Lunes",
  2: "Martes",
  3: "Miércoles",
  4: "Jueves",
  5: "Viernes",
  6: "Sábado",
  7: "Domingo"
};

Map<int, String> monthDayToString =
{
  1: "Enero",
  2: "Febrero",
  3: "Marzo",
  4: "Abril",
  5: "Mayo",
  6: "Junio",
  7: "Julio",
  8 : "Agosto",
  9: "Septiembre",
  10: "Octubre",
  11: "Noviembre",
  12: "Diciembre",
};

Map<String, String> versionToName =
{
  'RVR60' : "Reina Valera Revisada 1960",
  'V1602P' : "Valera 1602 Purificada",
  'RVC' : "Reina Valera Contemporánea",
};

Map<int, int> linkIdToBook = {
  10: 1,   // Génesis
  20: 2,   // Éxodo
  30: 3,   // Levítico
  40: 4,   // Números
  50: 5,   // Deuteronomio
  60: 6,   // Josué
  70: 7,   // Jueces
  80: 8,   // Rut
  90: 9,   // 1 Samuel
  100: 10, // 2 Samuel
  110: 11, // 1 Reyes
  120: 12, // 2 Reyes
  130: 13, // 1 Crónicas
  140: 14, // 2 Crónicas
  150: 15, // Esdras
  160: 16, // Nehemías
  190: 17, // Ester
  220: 18, // Job
  230: 19, // Salmos
  240: 20, // Proverbios
  250: 21, // Eclesiastés
  260: 22, // Cantares
  290: 23, // Isaías
  300: 24, // Jeremías
  310: 25, // Lamentaciones
  330: 26, // Ezequiel
  340: 27, // Daniel
  350: 28, // Oseas
  360: 29, // Joel
  370: 30, // Amós
  380: 31, // Abdías
  390: 32, // Jonás
  400: 33, // Miqueas
  410: 34, // Nahum
  420: 35, // Habacuc
  430: 36, // Sofonías
  440: 37, // Hageo
  450: 38, // Zacarías
  460: 39, // Malaquías
  470: 40, // Mateo
  480: 41, // Marcos
  490: 42, // Lucas
  500: 43, // Juan
  510: 44, // Hechos
  520: 45, // Romanos
  530: 46, // 1 Corintios
  540: 47, // 2 Corintios
  550: 48, // Gálatas
  560: 49, // Efesios
  570: 50, // Filipenses
  580: 51, // Colosenses
  590: 52, // 1 Tesalonicenses
  600: 53, // 2 Tesalonicenses
  610: 54, // 1 Timoteo
  620: 55, // 2 Timoteo
  630: 56, // Tito
  640: 57, // Filemón
  650: 58, // Hebreos
  660: 59, // Santiago
  670: 60, // 1 Pedro
  680: 61, // 2 Pedro
  690: 62, // 1 Juan
  700: 63, // 2 Juan
  710: 64, // 3 Juan
  720: 65, // Judas
  730: 66  // Apocalipsis
};