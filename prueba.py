#!/usr/bin/env python3
# transportador300_gui.py
# Simulador GUI de transportador digital 0-300° (entrada 8 bits)

import math
import tkinter as tk

MAX_COUNTS  = 255       # 8 bits
MAX_DEGREES = 300.0     # rango del transportador
DIAL_RADIUS = 140       # tamaño del dial en píxeles

# ──────────────────────────────────────────────────────────────────────────
def counts_to_degrees(counts: int) -> float:
    """Convierte la cuenta (0-255) a grados (0-300)."""
    counts = max(0, min(counts, MAX_COUNTS))
    return (counts / MAX_COUNTS) * MAX_DEGREES


class TransportadorGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Transportador digital 0-300°")
        self.resizable(False, False)
        self.configure(padx=20, pady=20)

        # Canvas para dibujar el dial
        size = DIAL_RADIUS * 2 + 10
        self.canvas = tk.Canvas(self, width=size, height=size, bg="white", highlightthickness=0)
        self.canvas.grid(row=0, column=0, columnspan=2)

        # Slider de 0-255
        self.scale = tk.Scale(self, from_=0, to=MAX_COUNTS, orient="horizontal",
                              length=size, command=self.on_scale, showvalue=False)
        self.scale.grid(row=1, column=0, columnspan=2, pady=(15, 0))

        # Etiquetas para mostrar la cuenta y el ángulo
        self.label_counts  = tk.Label(self, text="Cuenta: 0", font=("Helvetica", 12))
        self.label_degrees = tk.Label(self, text="Ángulo: 0.0°", font=("Helvetica", 12, "bold"))
        self.label_counts.grid(row=2, column=0, sticky="w", pady=(10, 0))
        self.label_degrees.grid(row=2, column=1, sticky="e", pady=(10, 0))

        # Pre-dibuja el dial estático
        self._draw_static_dial()
        # Aguja dinámica (inicializar con una línea; guardamos su id)
        self.needle_id = self.canvas.create_line(0, 0, 0, 0, width=4, fill="red", capstyle="round")
        self._update_needle(0)

    # ──────────────────────────────────────────────────────────────────
    def _draw_static_dial(self):
        """Dibuja los 300° del dial (arco y marcas cada 30°)."""
        cx, cy, r = self._center_radius()
        start_angle = -60          # 0° está en -60°, giramos 300° CCW hasta +240°
        extent = 300
        # Arco principal
        self.canvas.create_arc(cx - r, cy - r, cx + r, cy + r,
                               start=start_angle, extent=extent,
                               style="arc", width=3)
        # Marcas cada 30°
        for deg in range(0, 301, 30):
            self._draw_tick(deg, r, 10 if deg % 90 else 16, width=3 if deg % 90 == 0 else 2)

    def _draw_tick(self, deg, radius, length, width=2):
        """Dibuja una marca en el ángulo 'deg'."""
        cx, cy, r = self._center_radius()
        ang_rad = math.radians(deg - 60)  # convertir a coordenadas canvas (-60° de offset)
        x_outer = cx + r * math.cos(ang_rad)
        y_outer = cy - r * math.sin(ang_rad)
        x_inner = cx + (r - length) * math.cos(ang_rad)
        y_inner = cy - (r - length) * math.sin(ang_rad)
        self.canvas.create_line(x_outer, y_outer, x_inner, y_inner, width=width)

        # Rotula cada 90°
        if deg % 90 == 0 and deg != 0 and deg != 300:
            tx = cx + (r - 28) * math.cos(ang_rad)
            ty = cy - (r - 28) * math.sin(ang_rad)
            self.canvas.create_text(tx, ty, text=str(deg), font=("Helvetica", 10, "bold"))

    def _center_radius(self):
        """Devuelve (cx, cy, r) del dial."""
        cx = cy = DIAL_RADIUS + 5    # 5 px de margen
        return cx, cy, DIAL_RADIUS

    # ──────────────────────────────────────────────────────────────────
    def _update_needle(self, degrees):
        """Redibuja la aguja al nuevo ángulo."""
        cx, cy, r = self._center_radius()
        ang_rad = math.radians(degrees - 60)   # 0° sigue en -60°
        x_end = cx + (r - 20) * math.cos(ang_rad)
        y_end = cy - (r - 20) * math.sin(ang_rad)
        self.canvas.coords(self.needle_id, cx, cy, x_end, y_end)

    # ──────────────────────────────────────────────────────────────────
    def on_scale(self, value):
        """Manejador del slider."""
        counts = int(value)
        degrees = counts_to_degrees(counts)
        self.label_counts.config(text=f"Cuenta: {counts}")
        self.label_degrees.config(text=f"Ángulo: {degrees:0.1f}°")
        self._update_needle(degrees)


# ──────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    app = TransportadorGUI()
    app.mainloop()
