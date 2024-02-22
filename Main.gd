extends Node2D

@export var snake_scene : PackedScene

var score : int;
var gameStarted: bool = false;

var cells : int = 20;
var cellsSize : int = 50;

var foodPos: Vector2
var regenFood : bool=true

var oldData : Array
var snakeData : Array
var snake : Array

var start_pos = Vector2	(9,9)
var up = Vector2(0,-1)
var down = Vector2(0,1)
var left = Vector2(-1,0)
var right = Vector2(1,0)
var moveDirection = Vector2()
var canMove : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	newGame()
	
func newGame():
	get_tree().paused = false
	get_tree().call_group("segments","queue_free")
	$GameOverMenu.hide()
	score=0
	$Hud.get_node("scoreLabel").text= "SCORE: " + str(score)
	moveDirection=up
	canMove = true
	generateSnake()
	moveFood()

func generateSnake():
	oldData.clear()
	snakeData.clear()
	snake.clear()
	for i in range(3):
		addSegment(start_pos + Vector2(0,i))
	  
func addSegment(pos):
	snakeData.append(pos)
	var snakeSegment = snake_scene.instantiate()
	snakeSegment.position = (pos*cellsSize) +Vector2(0,cellsSize)
	add_child(snakeSegment)
	snake.append(snakeSegment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	moveSnake()
	
func moveSnake():
	if canMove:
		if Input.is_action_just_pressed("move_down") and moveDirection != up:
			moveDirection = down
			canMove = false
			if not gameStarted:
				startGame()
		if Input.is_action_just_pressed("move_up") and moveDirection != down:
			moveDirection = up
			canMove = false
			if not gameStarted:
				startGame()
		if Input.is_action_just_pressed("move_left") and moveDirection != right:
			moveDirection = left
			canMove = false
			if not gameStarted:
				startGame()
		if Input.is_action_just_pressed("move_right") and moveDirection != left:
			moveDirection = right
			canMove = false
			if not gameStarted:
				startGame()


func startGame():
	gameStarted = true
	$moveTimer.start()


func _on_move_timer_timeout():
	canMove = true
	oldData = [] + snakeData
	snakeData[0] += moveDirection
	for i in range(len(snakeData)):
		if i>0:
			snakeData[i] = oldData[i-1]
		snake[i].position = (snakeData[i]*cellsSize) + Vector2(0,cellsSize)
		
	checkOutOfBounds()
	checkSelfEaten()
	checkFoodEaten()

func checkOutOfBounds():
	if snakeData[0].x<0 or snakeData[0].x > cells-1 or snakeData[0].y<0 or snakeData[0].y > cells-1:
		endGame()

func checkSelfEaten():
	for i in range(1,len(snakeData)):
		if snakeData[0]==snakeData[i]:
			endGame()

func checkFoodEaten():
	if snakeData[0]==foodPos:
		score+=1
		$Hud.get_node("scoreLabel").text= "SCORE: " + str(score)
		addSegment(oldData[-1])
		moveFood()

func moveFood():
	while regenFood:
		regenFood = false
		foodPos = Vector2(randi_range(0,cells-1),randi_range(0,cells-1))
		for i in snakeData:
			if foodPos == i:
				regenFood=true
	$Food.position = (foodPos*cellsSize) + Vector2(0,cellsSize)
	regenFood = true


func endGame():
	$GameOverMenu.show()
	$moveTimer.stop()
	gameStarted = false
	get_tree().paused = true



func _on_game_over_menu_restart():
	newGame()
