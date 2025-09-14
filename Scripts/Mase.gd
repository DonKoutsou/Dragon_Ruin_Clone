extends Node

class_name MazeGenerator

static var maze : Array[Array]

var width = 10
var height = 10

func generate_maze():
	maze = []
	for y in range(height):
		maze.append([])
		for x in range(width):
			maze[y].append({"visited": false, "walls": [true, true, true, true]})  # N E S W

	_carve(0, 0)

var dx = [0, 1, 0, -1]
var dy = [-1, 0, 1, 0]

func _carve(x, y):
	maze[y][x]["visited"] = true
	var dirs = [0, 1, 2, 3]
	dirs.shuffle()
	for dir in dirs:
		var nx = x + dx[dir]
		var ny = y + dy[dir]
		#make sure we are not out of bounds
		if nx >= 0 and nx < width and ny >= 0 and ny < height:
			#make sure we havent generated the neighbor yet
			if (not maze[ny][nx]["visited"]):
				maze[y][x]["walls"][dir] = false
				maze[ny][nx]["walls"][(dir+2)%4] = false   # Opposite wall
				_carve(nx, ny)
