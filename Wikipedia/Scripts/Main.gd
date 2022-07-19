extends Spatial

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var length = 6
var floorWidth
var floorLength

onready var case = preload("res://Models/Case/Case.tscn")
var cases = []
var articles = []
var sectionID = global.currentSection

var dummybookTex

onready var article = get_node("Article")
onready var titleLabel = get_node("TitleLabel")
onready var pageLabel = get_node("PageLabel")
onready var wikiRequest = get_node("HTTPRequest")

var currentBook
var currentBookMax
var currentCase
var currentPage

var consoleShown = false
onready var console = get_node("Console")

# Called when the node enters the scene tree for the first time.
func _ready():
	var directory = Directory.new();
	var doFolderExists = directory.dir_exists("user://Cache")
	if not doFolderExists:
		get_tree().change_scene_to(load("res://Scenes/ImageCache.tscn"))
		return
	
	db = SQLite.new()
	var file2Check = File.new()
	var doesFileExist = file2Check.file_exists("user://titles.db")
	if doesFileExist:
		db.path = "user://titles.db"
	else:
		db.path = "res://titles.db"
	db.verbose_mode = true
	db.open_db()
	db.query("SELECT count(*) AS count FROM titles WHERE SectionID = " + str(sectionID))
	var numArticles = db.query_result[0].count
	db.query("SELECT * FROM titles WHERE SectionID = " + str(sectionID))
	articles = db.query_result
	db.close_db()
	
	
	floorWidth = round(ceil(ceil(numArticles/float(3750)) / float(length)) * .85)
	floorLength = length * 2
	
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load("user://Cache/0/5_20.png")
	texture.create_from_image(image)
	dummybookTex = texture
	
	var tempMesh = PlaneMesh.new()
	tempMesh.size = Vector2(2,2)
	var tempMat = SpatialMaterial.new()
	tempMat.albedo_texture = load("res://Models/Floor/Carpet1.jpg")
	
	for w in floorWidth:
		for l in floorLength:
			var tempTile = MeshInstance.new()
			tempTile.mesh = tempMesh
			tempTile.scale = Vector3(5,1,5)
			tempTile.set_surface_material(0,tempMat)
			add_child(tempTile)
			tempTile.translate(Vector3(w*2,0,l*2))
	
	var x = 0
	var y = 0
	var dir = -1
	for n in ceil(numArticles/float(3750)):
		if n % length == 0:
			dir *= -1
			y += 1
			x += (1*dir)
		cases.append(case.instance())
		add_child(cases[n])
		cases[n].dummyTex = dummybookTex
		cases[n].caseID = n
		cases[n].sectionID = sectionID
		cases[n].translate(Vector3(-16*x,0,y*8))
		if y % 2 == 0:
			cases[n].rotate_y(3.14159)
			cases[n].translate(Vector3(0,0,5))
		if n == ceil(numArticles/float(3750)) - 1:
			cases[n].populateShelf(articles.slice(n*3750, len(articles) - 1))
		else:
			cases[n].populateShelf(articles.slice(n*3750, n*3750 + 3749))
		x += (1*dir)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		article.visible = false
		titleLabel.visible = false
		pageLabel.visible = false
	if Input.is_action_just_pressed("ui_left"): 
		if wikiRequest.get_http_client_status() == 0 and article.visible:
			if currentPage > 0:
				currentPage -= 1
				wikiRequest.request("https://en.wikipedia.org/w/api.php?action=query&pageids="+str(cases[currentCase].pages[(currentBook*50)+currentPage].ID)+"&prop=extracts&explaintext=true&format=json")
			else:
				currentPage = currentBookMax -1
				wikiRequest.request("https://en.wikipedia.org/w/api.php?action=query&pageids="+str(cases[currentCase].pages[(currentBook*50)+currentPage].ID)+"&prop=extracts&explaintext=true&format=json")
	if Input.is_action_just_pressed("ui_right"): 
		if wikiRequest.get_http_client_status() == 0 and article.visible:
			if currentPage < currentBookMax-1:
				currentPage += 1
				wikiRequest.request("https://en.wikipedia.org/w/api.php?action=query&pageids="+str(cases[currentCase].pages[(currentBook*50)+currentPage].ID)+"&prop=extracts&explaintext=true&format=json")
			else:
				currentPage = 0
				wikiRequest.request("https://en.wikipedia.org/w/api.php?action=query&pageids="+str(cases[currentCase].pages[(currentBook*50)+currentPage].ID)+"&prop=extracts&explaintext=true&format=json")
		
	if Input.is_action_just_pressed("console"):
		if consoleShown:
			console.visible = false
			consoleShown = false
			console.clear()
		else:
			console.visible = true
			consoleShown = true
			
	if Input.is_action_just_pressed("ui_accept"):
		if consoleShown:
			var command = console.text.split(" ")
			if len(command) < 2:
				console.text = "Invalid Command"
			else:
				runCommand(command[0], command[1])
			

func runCommand(com, arg):
	match(com):
		"load":
			if int(arg) >= 0 and int(arg) <= 27 and arg.is_valid_integer():
				console.clear()
				loadFloor(int(arg))
			else:
				console.text = "Invalid Floor"
		"setlod1":
			if arg.is_valid_integer() and int(arg) > 0:
				setlod1(int(arg))
				console.clear()
				consoleShown = false
				console.visible = false
		"setlod2":
			if arg.is_valid_integer() and int(arg) > 0:
				setlod2(int(arg))
				console.clear()
				consoleShown = false
				console.visible = false
		_:
			console.text = "Invalid Command"

func loadFloor(flr):
	global.currentSection = flr
	get_tree().change_scene("res://Scenes/Main.tscn")

func setlod1(lod):
	for case in cases:
		case.lodculldist1 = lod
func setlod2(lod):
	for case in cases:
		case.lodculldist2 = lod


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	result = json.result
	var keys = result["query"]["pages"].keys()
	var title = result["query"]["pages"][keys[0]]["title"]
	result = result["query"]["pages"][keys[0]]["extract"]
	article.visible = true
	titleLabel.visible = true
	titleLabel.text = title
	article.text = result
	pageLabel.visible = true
	pageLabel.text = "Page: " + str(currentPage + 1) + "/" + str(currentBookMax)
