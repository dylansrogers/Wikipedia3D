extends Spatial

onready var book = preload("res://Models/Book/book.tscn")

var dummyTex

var books = []
var textures = []
var pages
var inSight
var readable
var caseID
var sectionID
var distance
var lodculldist1 = 25
var lodculldist2 = 55

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func populateShelf(pages):
	var x = 0
	var y = 0
	self.pages = pages
	inSight = true
	readable = true
	for n in ceil(len(pages)/float(50)):
		if n % 25 == 0:
			y += 1
			x=0
		books.append(book.instance())
		books[n].translation = Vector3(6.85 - x*.575,10.1 - y*2.9,0)
		books[n].get_node("KinematicBody").caseID = caseID
		books[n].get_node("KinematicBody").bookID = n
		books[n].get_node("KinematicBody").pages = pages
		if n == ceil(len(pages)/float(50)) - 1:
			books[n].get_node("KinematicBody").maxPages = len(pages)%50
		else:
			books[n].get_node("KinematicBody").maxPages = 50
		x += 1
		add_child(books[n])
	for n in len(books):
		var spine = books[n].get_node("Spine")
		var mat = spine.get_surface_material(0)
		var texture = ImageTexture.new()
		var image = Image.new()
		image.load("user://Cache/"+str(sectionID)+"/"+str(caseID)+"_"+str(n)+".png")
		texture.create_from_image(image)
		mat.albedo_texture = texture
		textures.append(texture)
		
func _process(delta):
	distance = self.global_transform.origin.distance_to(get_tree().get_root().get_node("Spatial/Character").get_global_transform().origin)
	if (distance > lodculldist1) && (readable or not inSight) && (distance <= lodculldist2):
		readable = false
		inSight = true
		for n in len(books):
			books[n].visible = true
			var spine = books[n].get_node("Spine")
			var mat = spine.get_surface_material(0)
			mat.albedo_texture = dummyTex
	elif (distance <= lodculldist1) and not readable:
		readable = true
		inSight = true
		for n in len(books):
			var spine = books[n].get_node("Spine")
			var mat = spine.get_surface_material(0)
			mat.albedo_texture = textures[n]
	elif (distance > lodculldist2) && inSight:
		inSight = false
		readable = false
		for b in books:
			b.visible = false
