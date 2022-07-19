extends Node2D

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
var articles = []
var label
var vport_img
var vport
var sectionID

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("Cache")
	for k in 28:
		sectionID = k
		dir.make_dir("Cache/" + str(sectionID))
		db = SQLite.new()
		var file2Check = File.new()
		var doesFileExist = file2Check.file_exists("user://titles.db")
		if doesFileExist:
			db.path = "user://titles.db"
		else:
			db.path = "res://titles.db"
		db.verbose_mode = true
		db.open_db()
		db.query("SELECT * FROM titles WHERE SectionID = " + str(sectionID))
		articles = db.query_result
		db.close_db()
		label = get_node("Viewport/Label")
		vport = get_node("Viewport")
			
		for c in ceil(len(articles)/float(3750)):
			var numcaseArticles
			var caseArticles
			if c == ceil(len(articles)/float(3750)) - 1:
				numcaseArticles = ceil(len(articles.slice(c*3750,len(articles)))/float(50))
				caseArticles = articles.slice(c*3750,len(articles))
			else:
				numcaseArticles = ceil(len(articles.slice(c*3750,(c*3750 + 3749)))/float(50))
				caseArticles = articles.slice(c*3750,(c*3750 + 3749))
			for n in numcaseArticles:
				if n == numcaseArticles - 1 and c == ceil(len(articles)/float(3750)) - 1:
					label.text = caseArticles[n*50].SortTitle.substr(0,6) + "\n" + "-" + "\n" + caseArticles[len(caseArticles) - 1].SortTitle.substr(0,6)
				else:
					label.text = caseArticles[n*50].SortTitle.substr(0,6) + "\n" + "-" + "\n" + caseArticles[(n*50) + 49].SortTitle.substr(0,6)
				
				yield(VisualServer, "frame_post_draw")
				vport_img = vport.get_texture().get_data()
				vport_img.flip_y()
				vport_img.lock()
				vport_img.save_png("user://Cache/"+str(sectionID)+"/"+str(c)+"_"+str(n)+".png")
			
	get_tree().change_scene_to(load("res://Scenes/Main.tscn"))
