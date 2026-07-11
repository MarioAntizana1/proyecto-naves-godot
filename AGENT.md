# AGENT.md - Guía para Agentes de IA en este Proyecto

## 🎯 Propósito del Proyecto
Space shooter vertical (Defensa Cóndor) en Godot 3.x / GDScript. Proyecto final de curso.

## 🏗 Arquitectura Clave

### Escenas y Flujo
```
main/Control.tscn (Menú) 
  → stage/Stage.tscn (Nivel 1) 
    → stage/Stage2.tscn (Nivel 2) 
      → stage/Stage3.tscn (Nivel 3) 
        → completed/DefenseCompleted.tscn (Victoria)
```
- Game Over recarga escena actual o vuelve al menú
- `Globals.current_stage` (autoload) trackea progresión 1→2→3

### Autoloads (Singletons)
| Nombre | Ruta | Uso |
|--------|------|-----|
| `Utils` | `res://libs/utils.gd` | `Utils.view_size`, `Utils.choice_list(array)` |
| `Globals` | `res://completed/Globals.gd` | `Globals.current_stage`, `Globals.score`, `Globals.reset_game()` |

### Herencia Enemigos
```
Enemy.gd (base: armor=4, shoot timer, collision handling)
  ├─ EnemyBlue.gd (movimiento sinusoidal horizontal + vertical)
  └─ EnemyRed.gd (caída vertical rápida velocidad aleatoria 250-1000)
```
- Spawner: `SpawnerEnemy.gd` alterna tipos, max 50, timer aleatorio 0.5-2s

## ⚙️ Mecánicas Principales (Player.gd)

### Escudo (Sistema Core)
```gdscript
# Variables clave
max_shield = 100.0
shield = 100.0
shield_recharge_time = 10.0
shield_recharging = false

# Lógica damage():
if shield == 100 and not recharging:
    shield = 0; recharging = true  # Se rompe, NO pierde vida
    # 10s recarga lineal → shield vuelve a 100
else:
    lives -= 1  # Solo si escudo no está lleno/recargando
```
- **HUD**: `ShieldBar` (Sprite 5 frames) + `ShieldBreakIcon` (visible 1.5s al romperse)

### Dash
- Tecla: `Shift` / Gamepad `LB`/`A`
- Velocidad 900 por 0.15s, tint azul temporal

### Disparo Dual
- 2 balas simultáneas desde `Cannons/LeftCannon` y `RightCannon`
- Cooldown vía `ShootTimer` (~0.2-0.3s)

### Gamepad Support
- Auto-registra actions en `_ready()`: `controller_shoot` (RB), `controller_dash` (LB/A), `controller_pause` (Start)
- Eje derecho (stick) para movimiento, trigger derecho (eje 7) para disparo continuo

## 📝 Convenciones de Código

### Nomenclatura
- **Scripts**: `PascalCase.gd` (Player.gd, EnemyBlue.gd)
- **Escenas**: `PascalCase.tscn` (Player.tscn, Stage.tscn)
- **Variables**: `snake_case` (`shield_recharge_time`, `enemies_destroyed`)
- **Constantes**: `UPPER_SNAKE` (`BLUE`, `RED` preloads)
- **Señales/Callbacks**: `_on_NodeName_signal_name` (Godot default)

### Estructura Script Típica
```gdscript
extends NodeType

# Exports @ top
export var speed = 600
export (PackedScene) var Bullet

# onready @ top
onready var sprite = $Sprite

# Variables estado
var lives = 4
var can_shoot = true

# _ready() → init, connections
# _physics_process(delta) → movement, timers
# Funciones juego: shoot(), damage(), game_over()
# Callbacks: _on_Area_area_entered(area)
# Helpers privados: _update_shield_bar(), _play_damage_anim()
```

### Grupos de Colisión (Strings)
| Grupo | Uso |
|-------|-----|
| `"player"` | Nave jugador |
| `"bullet"` | Balas jugador |
| `"enemy"` | Enemigos (base) |
| `"enemy_bullet"` | Disparos enemigos |
| `"meteor"` | Meteoritos |

### Patrones Comunes
- **Instanciar y añadir a padre**: `var inst = PackedScene.instance(); get_parent().add_child(inst)`
- **Posición global para spawn**: `inst.global_position = $SpawnPoint.global_position`
- **Puntos al destruir**: `if get_parent().has_method("add_score"): get_parent().add_score(100)`
- **Explosión**: `preload("res://sprites/Explosion.tscn").instance()` → set `global_position` → `get_parent().add_child()`

## 🔧 Tasks Comunes para Agentes

### Añadir Nuevo Tipo Enemigo
1. Crear `EnemyNuevo.gd` extendiendo `Enemy.gd`
2. Implementar `_physics_process` con movimiento único
3. Crear `.tscn` con: Area2D root, CollisionShape2D, AnimatedSprite, ShootPoint (Position2D), ShootTimer, VisibilityNotifier2D, AudioStreamPlayer×2
4. En `SpawnerEnemy.gd`: añadir a `enemies` array en `_ready()` o export `spawn_nuevo`

### Añadir Power-up
1. Script `PowerUp.gd` extends `Area2D` + grupo `"powerup"`
2. En `_on_area_entered(area)`: `if area.is_in_group("player"): apply_effect(area); queue_free()`
3. Spawnear desde `Stage.gd` o nuevo `PowerUpSpawner` (Timer aleatorio)
4. Efectos: `player.shield = min(100, player.shield + 25)`, `player.lives += 1`, `player.speed *= 1.5` (con Timer reset)

### Nuevo Nivel (Stage 4)
1. Duplicar `Stage3.tscn` → `Stage4.tscn`, cambiar música/fondo/texto "Nivel 4"
2. En `Stage.gd`: `check_level()` → `elif score >= 6000: level = 4`
3. `apply_level()`: `4: $SpawnerEnemy/SpawnTimer.wait_time = 0.3`
4. `DefenseCompleted.gd`: caso `current_stage == 3` → `change_scene("res://stage/Stage4.tscn")`
5. `Globals.current_stage = 4`

### Cambiar Resolución / Escalado
- `project.godot`: `window/stretch/mode="2d"`, `aspect="keep"`
- Base viewport ~1024px ancho (ver `Utils.view_size`)
- UI usa Anchors en CanvasLayer → responsive automático

## 🐛 Debug / Testing Tips

### Print Debug Activos
- `print("ENEMIGO DESTRUIDO")` en Enemy.gd:94
- `print("Vidas:", lives)` en Player.gd:107
- `print("ESCUDO ROTO/RECARGADO")` en Player.gd

### Cheats Rápidos (para testing)
En `Player._physics_process` añadir temporalmente:
```gdscript
if Input.is_action_just_pressed("ui_select"):  # Enter
    shield = 100; _update_shield_bar()  # Escudo full
if Input.is_action_just_pressed("ui_page_up"):  # PageUp
    lives = 4; update_lives()  # Vidas full
```

### Verificar Colisiones
- `CollisionShape2D` debe cubrir sprite visible
- Enemigos: `Enemy.tscn` tiene `CollisionShape2D` + `Area2D` root
- Balas: `Bullet.tscn` / `EnemyBullet.tscn` → `Area2D` + `CollisionShape2D` + `VisibilityNotifier2D`

## 📦 Assets Críticos (No Borrar)
- `sprites/barritas/00.png`–`07.png` + `All.png` → frames escudo (5 frames en `ShieldBar` hframes=5)
- `sprites/explosiones/part_1-4/` → frames explosión (Explosion.gd usa 20 frames 128×128)
- `fonts/m5x7.ttf`, `orbitron/Orbitron-VariableFont_wght.ttf` → HUD textos
- `Music/*.wav` → **MUY GRANDES** (80MB+), convertir a .ogg para export

## 🚫 Qué NO Tocar Sin Cuidado
- `project.godot` input_map (shoot, dash, pause, controller_*) — rompería controles
- `Utils.gd` — usado por TODO (enemigos, spawner, meteoros, player)
- `Globals.gd` — estado persistente entre escenas
- Jerarquía `CanvasLayer` en Stage.tscn — HUD anclado a viewport

## 🔗 Referencias Rápidas Archivos Clave

| Funcionalidad | Archivo Principal |
|---------------|-------------------|
| Movimiento/Disparo/Dash/Escudo Player | `Player.gd` (286 líneas) |
| Lógica Nivel (Score, Level, GameOver, HUD) | `stage/Stage.gd` (115 líneas) |
| Enemigo Base (vida, disparo, explosión) | `Enemy/Enemy.gd` (97 líneas) |
| Enemy Azul (onda) | `Enemy/EnemyBlue.gd` (40 líneas) |
| Enemy Rojo (caída rápida) | `Enemy/EnemyRed.gd` (8 líneas) |
| Spawner Oleadas | `Enemy/SpawnerEnemy.gd` (54 líneas) |
| Meteoritos | `Meteor.gd` (21 líneas), `stage/MeteorSpawner.gd` (14 líneas) |
| Bala Jugador | `Bullet.gd` (9 líneas) |
| Bala Enemigo | `EnemyBullet.gd` (15 líneas) |
| Menú Principal | `main/Control.gd` (14 líneas) |
| Victoria/Progresión | `completed/DefenseCompleted.gd` (23 líneas) |
| Utilidades Globales | `libs/utils.gd` (19 líneas) |
| Estado Global | `completed/Globals.gd` (9 líneas) |

---

*Generado para asistencia de IA en desarrollo. Mantener actualizado al modificar arquitectura.*