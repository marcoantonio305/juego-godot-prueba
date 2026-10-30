extends CharacterBody2D


var vida:int = 12

@export var velocidad_normal: float = 120.0
@export var velocidad_dash: float = 500.0

@onready var timer_decisiones: Timer = $TimerDecisiones

enum Estado {IDLE, PERSEGUIR, DASH, DISPARAR}
var estado_actual: Estado = Estado. IDLE
var direccion_movimiento: Vector2 = Vector2.ZERO
var jugador: Personaje = null

func _ready()-> void:
	# Buscar añ jugador mediante su tipo "Personaje" o por el grupo "jugador"
	_buscar_jugador()
	
	#Configurar el timer para cambiar de acción cada 1.2 segundos
	timer_decisiones.wait_time = 1.2
	timer_decisiones.timeout.connect(_elegir_accion_aleatoria)
	timer_decisiones.start()
	
func _physics_process(delta: float) -> void:
	# Si pierde la referencia del jugador, (por ejemplo, al morir) la busca de nuevo
	if not is_instance_valid(juagdor):
		_buscar_jugador()
		
	match estado_actual:
		Estado.IDLE:
			velocity = Vector2.ZERO
	
