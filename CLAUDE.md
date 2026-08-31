# Waypoint iOS

App iOS de Waypoint (SwiftUI, arquitectura modular con paquetes SPM locales en `Packages/`).

Toda la UI debe construirse con el paquete `Packages/DesignSystem`: colores `Color.wp*`, tipografías `Font.fredoka(...)`/`Font.nunito(...)` y escala `Font.wp*`, botones `.buttonStyle(.waypointPrimary/.waypointSecondary/.waypointTertiary)`, tarjetas `.waypointCard()`, `WaypointTag`, `WaveShape` y `Bubble`. No usar colores o fuentes fuera del sistema.

## Branding (fuente: `../waypoint_branding/Waypoint Branding.dc.html`)

Toda UI que se cree o modifique debe seguir estas reglas de marca. La identidad es la ballena de Waypoint: amigable, redonda y optimista, con contorno navy grueso — todos los elementos heredan ese estilo.

### Paleta (solo estos colores, ninguno fuera de esta familia)

| Nombre | Hex | Uso |
|---|---|---|
| Deep Navy | `#1E2B85` | Contornos y texto |
| Ocean Blue | `#2B8CFF` | Color primario (acciones, acentos) |
| Whale Blue | `#45AEF5` | Cuerpo de la ballena, estados hover/secundarios |
| Splash Sky | `#8ED8F8` | Detalles y rellenos suaves |
| Foam | `#F4FBFF` | Fondos claros |

Colores de apoyo vistos en la guía: `#DCEBFA` (bordes suaves), `#4A57A0` (texto secundario), `#7B86C2` (texto terciario), `#CFE9FF` (texto claro sobre azul), `#EAF5FF` (fondo de tags).

Ratio de uso aproximado: Foam 35% · Ocean Blue 30% · Whale Blue 15% · Splash Sky 10% · Deep Navy 10%.

### Tipografía

- **Titulares: Fredoka** (pesos 500–700). Siempre en navy o blanco. Nunca en tiradas largas de mayúsculas.
- **Cuerpo: Nunito** (400 para párrafos, 700–800 para labels y botones). Mínimo 14 pt en pantalla.
- Escala: H1 48/56 · H2 32/40 · Body 16/26 · Label 13 (uppercase, letter-spacing amplio, Ocean Blue).
- Ambas van incluidas como TTF variables en `Packages/DesignSystem` y se registran automáticamente al usar `Font.fredoka(...)` / `Font.nunito(...)` (o llamando a `WaypointFont.register()`).

### Elementos gráficos y UI

- Contornos navy gruesos (equivalente a 2–3 pt) y esquinas muy redondeadas en tarjetas y controles; botones y tags en forma de píldora (radio completo).
- Los botones se sienten "dibujados": borde navy de 3 pt + sombra dura inferior navy (offset y ~4, sin blur) que se hunde al pulsar.
  - Primario: fondo Ocean Blue, texto blanco. Secundario: fondo blanco, texto navy. Terciario: fondo Splash Sky, texto navy.
- Tarjetas: fondo blanco, borde `#DCEBFA` de 2 pt, radio ~20, sombra suave `rgba(30,43,133,0.12)`.
- Motivos: olas (curvas suaves) y burbujas — las burbujas siempre con contorno navy.

### Logo

- Vive siempre dentro de su campo azul, recortado como círculo o cuadrado redondeado, con borde navy (o Splash Sky/blanco sobre fondos oscuros).
- Espacio libre alrededor: al menos la mitad de su diámetro.
- No estirar, rotar ni recolorear la ballena; no quitar el contorno navy; no ponerlo sobre fondos que compitan con su azul.

### Tono

Calmado, amigable y optimista; metáforas de océano (olas, flow, splash). Ej.: "Find your flow, one wave at a time".
