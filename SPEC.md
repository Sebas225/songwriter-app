Listo. Aquí tienes un **SPEC.md completo** (copias y pegas en tu repo) + un **roadmap de tareas** para dárselas a Codex una por una. Está pensado para Flutter, multiplataforma, con MVP claro y luego V2/V3.

---

# SPEC.md — Songwriter (App de letras y acordes)

## 0. Resumen

**Songwriter** es una app multiplataforma (iOS, Android, Windows, macOS, Web opcional) para escribir canciones con acordes por partes (Intro, Verso, Coro, etc.), reconocer acordes libremente escritos, detectar/sugerir tono, transponer canciones automáticamente, mostrar grados armónicos según el tono, y manejar CRUD completo de canciones.

**Usuarios objetivo:** compositores / músicos que quieren un editor rápido tipo Ultimate Guitar, con transposición instantánea.

---

## 1. Plataformas y stack

### 1.1 Plataforma

* Mobile: iOS, Android
* Desktop: Windows, macOS
* (Opcional futuro) Web

### 1.2 Stack técnico

* Framework UI: **Flutter**
* Lenguaje: Dart
* Estado: **Riverpod** (o BLoC si lo prefieres, pero MVP con Riverpod)
* Navegación: `go_router`
* BD local: **SQLite con Drift** (preferido) o `sqflite`
* Testing: `flutter_test` + tests unitarios para motor musical
* Arquitectura: “feature-first” con capas `domain / data / ui`

---

## 2. Entidades (modelo de datos)

### 2.1 Song

Representa una canción completa.

Campos:

* `id: String (uuid)`
* `title: String`
* `artist: String?`
* `originalKey: KeySignature?` (tono original, opcional hasta que se defina)
* `currentKey: KeySignature?` (tono actual si se ha transpuesto)
* `tempoBpm: int?`
* `createdAt: DateTime`
* `updatedAt: DateTime`
* `sections: List<Section>`

### 2.2 Section

Parte de la canción (Intro, Verso 1, Coro, Puente…)

Campos:

* `id: String (uuid)`
* `songId: String`
* `name: String`
* `order: int` (posición)
* `lines: List<Line>`

### 2.3 Line

Una línea de letra con acordes inline.

Campos:

* `id: String (uuid)`
* `sectionId: String`
* `order: int`
* `rawText: String`
  Texto original con acordes tipo:

  * `"Hoy me siento [G]bien y todo [D/F#]fluyó"`
* `tokens: List<ChordToken>` (derivado)

### 2.4 ChordToken (derivado, no persiste directamente)

Un acorde encontrado en una línea.

Campos:

* `chord: Chord`
* `startIndex: int` (posición en rawText)
* `endIndex: int`

---

## 3. Editor de acordes (formato)

### 3.1 Formato principal

El usuario escribe acordes entre corchetes:

Ejemplo:

```
[Am]Hoy te vi
y [F]no pude hablar
[C]todo cambió [G]de repente
```

Reglas:

* Todo lo que esté dentro de `[` y `]` es un acorde.
* Puede haber múltiples acordes por línea.
* Los corchetes **no se muestran** en modo vista; solo en edición.

### 3.2 Render

Modo vista:

* Acordes se muestran en negrita sobre la sílaba donde aparecen.
* Si es difícil alinear en MVP, mostrar acorde inline en color distinto (aceptable para MVP).

---

## 4. Motor musical

### 4.1 Parser de acordes

Debe reconocer:

**Raíz:**

* Notas: A B C D E F G
* Accidentales: `#` (sostenido), `b` (bemol)
* Equivalencias:

  * A# == Bb
  * C# == Db
  * D# == Eb
  * F# == Gb
  * G# == Ab

**Calidad/acorde base:**

* mayor (default): `C`
* menor: `Cm`, `Cmin`, `C-`
* aumentado: `Caug`, `C+`
* disminuido: `Cdim`, `C°`
* suspendido: `Csus2`, `Csus4`
* power chord: `C5`

**Extensiones y añadidos:**

* `6`, `7`, `9`, `11`, `13`
* `maj7`, `maj9`
* `add9`, `add11`
* alteraciones: `#5`, `b5`, `#9`, `b9`, `#11`, `b13`
* combinaciones: `Am7(b5)`, `G7(#9)`, `Cmaj7(add9)`

**Slash chords / bajo:**

* `D/F#`, `C/E`, `G/B`

**Salida del parser (Chord):**

```dart
class Chord {
  Note root;        // e.g. C, F#, Bb
  Quality quality;  // major, minor, dim, aug, sus2, sus4, power...
  List<Extension> extensions; // 7, maj7, add9, b5, #9...
  Note? bass;       // para slash chords
}
```

**Función requerida:**

* `Chord parseChord(String input)`
* `List<ChordToken> extractChords(String rawLine)`

Debe incluir **tests unitarios** con al menos 40 acordes válidos y 10 inválidos.

---

### 4.2 Detección / sugerencia de tono

Dos modos:

**Manual (MVP):**

* usuario selecciona tono mayor/menor en UI.

**Inferido (V2):**

* `KeySignature inferKeyFromChords(List<Chord> chords)`

Algoritmo sugerido:

1. Generar 24 tonalidades (12 mayores + 12 menores).
2. Para cada tonalidad, construir acordes diatónicos esperados.
3. Puntuar:

   * +2 si acorde es diatónico exacto
   * +1 si es acorde prestado común (bVII, IV menor, V/vi)
   * 0 si no encaja
4. Devolver la tonalidad con mayor puntaje.

Mostrar en UI:

* “Tono sugerido: G mayor (confianza alta/media/baja)”
* botón “Aplicar”.

---

### 4.3 Transposición

**Requisito:**

* Si cambia el tono de la canción, **todos los acordes transponen** y se re-renderizan respetando calidad, extensiones y slash bass.

Funciones:

* `Note transposeNote(Note n, int semitones)`
* `Chord transposeChord(Chord c, int semitones)`
* `Song transposeSong(Song s, KeySignature newKey)`

Reglas:

* Mantener preferencia de notación (si el usuario está en Bb, preferir bemoles).
* Ej.:
  `D/F#` +2 semitonos => `E/G#`

Debe tener tests:

* transposición de acordes simples
* con alteraciones
* slash chords
* cadenas completas de canción.

---

### 4.4 Grados del tono (números romanos)

Para `KeySignature key`:

* construir escala diatónica
* mapear acordes diatónicos a grado:

  * mayor: I, ii, iii, IV, V, vi, vii°
  * menor natural/harmónica (simplificar a menor natural en MVP)

Función:

* `RomanDegree getDegree(Chord chord, KeySignature key)`

Salida en UI:

* al lado del acorde:
  `D  (V)`
  `Am (ii)`
* si no es diatónico:
  mostrar `*` o “ND” (no diatónico) en MVP.

---

## 5. UI / Pantallas

### 5.1 Home — lista de canciones

* AppBar con título “Songwriter”
* Lista con:

  * título
  * artista (si existe)
  * tono actual
* Acciones:

  * `+` crear canción
  * swipe / menú para borrar
  * search bar

### 5.2 Create / Edit Song

* Form:

  * título (requerido)
  * artista (opcional)
  * tono original (selector opcional)
* Botón guardar.

### 5.3 Song Detail

Muestra:

* título/ artista / tono actual
* botón “Transponer”
* botón “Detectar tono”
* lista de secciones ordenadas

Acciones:

* agregar sección
* reordenar secciones (drag & drop V2)
* borrar sección

### 5.4 Section Editor

* Campo nombre sección
* Lista de líneas editable
* Cada línea:

  * TextField multiline con rawText
  * previsualización inline debajo (modo vista)
* Botones:

  * agregar línea
  * borrar línea

### 5.5 Transpose Modal

* selector de nuevo tono (12 mayores + 12 menores)
* preview “antes / después”
* botón aplicar.

---

## 6. Persistencia

### 6.1 Repositorios

* `SongRepository`
* `SectionRepository`
* `LineRepository`

Operaciones:

* create / get / update / delete
* list songs
* reorder sections/lines

### 6.2 BD local

* Drift con tablas:

  * songs
  * sections
  * lines

Relaciones:

* songs 1—N sections
* sections 1—N lines

---

## 7. No-funcionales

* App inicia en < 2s en desktop normal.
* No requiere internet.
* UI simple tipo notas.
* Autosave al editar líneas (debounce 500ms).
* Sincronización cloud es futura.

---

## 8. Roadmap

### MVP (entregable 1)

1. Proyecto Flutter + arquitectura + dependencias.
2. CRUD Songs/Sections/Lines con SQLite.
3. Editor `[Chord]texto` con preview simple.
4. Parser robusto + tests.
5. Selección manual de tono.
6. Transposición completa + tests.
7. Visualización básica de grados diatónicos.

### V2

8. Detección automática de tono (inferir).
9. Render bonito con acordes arriba alineados.
10. Reordenar secciones/lines.

### V3

11. Exportar PDF / compartir.
12. Sync cloud.

---

## 9. Casos de prueba (input/output)

### 9.1 Parser válido

* `"C"` => root C, major
* `"Cm"` => C minor
* `"Bbmaj7"` => Bb major, maj7
* `"F#dim7"` => F# dim, 7
* `"D/F#"` => root D, bass F#
* `"Am7(b5)"` => A minor, 7, b5
* `"G7(#9)"` => G major, 7, #9

### 9.2 Transposición

* `C` +2 => `D`
* `Bb` +2 => `C`
* `F#m7` -1 => `Fm7`
* `D/F#` +2 => `E/G#`

---

## 10. Definiciones

### 10.1 Note

Enum con:
`C, C#, Db, D, D#, Eb, E, F, F#, Gb, G, G#, Ab, A, A#, Bb, B`

### 10.2 KeySignature

```dart
class KeySignature {
  Note tonic;
  bool isMinor;
}
```

---

# FIN SPEC.md

---

## Roadmap de tareas para Codex (copia y pega 1 por 1)

> **Tip**: crea el repo, pega SPEC.md en la raíz, y luego lanza estas tareas.

### Tarea 1 — Base Flutter

**Prompt para Codex:**

> Inicia un proyecto Flutter llamado Songwriter siguiendo SPEC.md.
> Configura: riverpod, go_router, drift (sqlite) y estructura feature-first con domain/data/ui.
> Crea app mínima con Home vacía y tests de smoke.

---

### Tarea 2 — BD y repositorios

> Implementa tablas drift: songs, sections, lines con relaciones 1-N según SPEC.md.
> Crea DAOs y repositorios (SongRepository, SectionRepository, LineRepository) con CRUD completo y streams para UI reactiva.
> Incluye tests de repositorios con base en memoria.

---

### Tarea 3 — UI CRUD básica

> Construye pantallas UI:
>
> * Home lista canciones con buscar/crear/borrar.
> * Create/Edit Song form.
> * Song Detail mostrando secciones.
> * Section Editor con líneas editables rawText.
>   Respeta navegación con go_router y estado con riverpod.

---

### Tarea 4 — Parser de acordes

> Implementa parseChord y extractChords según SPEC.md.
> Soporta raíces con #/b, calidades, extensiones, alteraciones y slash chords.
> Agrega mínimo 40 tests válidos y 10 inválidos.

---

### Tarea 5 — Preview de acordes en editor

> En Section Editor, agrega un preview visual debajo de cada línea:
>
> * muestra los acordes detectados en negrita inline sin corchetes.
> * marca acordes inválidos en rojo y muestra tooltip simple.
>   No cambies el rawText del usuario aún.

---

### Tarea 6 — Transposición

> Implementa transposeNote, transposeChord y transposeSong.
> Agrega modal “Transponer” en Song Detail para elegir nuevo tono y aplicar.
> Al aplicar, re-renderiza todos los acordes en preview y en modo vista.
> Incluye tests completos.

---

### Tarea 7 — Grados romanos

> Implementa cálculo de escala diatónica y getDegree.
> Muestra el grado romano al lado de cada acorde en preview.
> Si no es diatónico, muestra “ND”.

---

### Tarea 8 (V2) — Detección automática de tono

> Implementa inferKeyFromChords con scoring diatónico según SPEC.md.
> En Song Detail añade botón “Detectar tono” que sugiera y permita aplicar.

---
