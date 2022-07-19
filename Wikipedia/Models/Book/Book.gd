extends KinematicBody

var caseID
var bookID

onready var main = get_tree().get_root().get_node("Spatial")
var pages

var maxPages 

var maxDist = 10
var mouse_in = false

func _on_KinematicBody_mouse_entered():
	mouse_in = true

func _on_KinematicBody_mouse_exited():
	mouse_in = false

func _process(delta):
	if mouse_in == true:
		if Input.is_action_just_pressed("mouse_button_left") and self.global_transform.origin.distance_to(get_tree().get_root().get_node("Spatial/Character").get_global_transform().origin) < maxDist:
			main.currentCase = caseID
			main.currentPage = 0
			main.currentBook = bookID
			main.currentBookMax = maxPages
			main.wikiRequest.request("https://en.wikipedia.org/w/api.php?action=query&pageids="+str(pages[bookID*50].ID)+"&prop=extracts&explaintext=true&format=json")
			
