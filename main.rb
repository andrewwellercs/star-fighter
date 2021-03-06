require 'ruby2d'
# require "Curses"
# include Curses
require_relative 'point3d'
require_relative 'camera'
require_relative 'enemy'
require_relative 'bullet'

def setCrosshairPoints(crosshairPoints)
	mousex = get :mouse_x
	mousey = get :mouse_y
	size = 15
	#we have two layers of points, the first and the second
	#the second (4-7) is behind the first on the z axis
	#it creates kind of a cool effect for crosshairrs
	crosshairPoints[0].x = mousex - Window.width/2 + size
	crosshairPoints[0].y = mousey - Window.height/2 + size
	crosshairPoints[4].x = mousex - Window.width/2 + size
	crosshairPoints[4].y = mousey - Window.height/2 + size

	crosshairPoints[1].x = mousex - Window.width/2 + size
	crosshairPoints[1].y = mousey - Window.height/2 - size
	crosshairPoints[5].x = mousex - Window.width/2 + size
	crosshairPoints[5].y = mousey - Window.height/2 - size

	crosshairPoints[2].x = mousex - Window.width/2 - size
	crosshairPoints[2].y = mousey - Window.height/2 - size
	crosshairPoints[6].x = mousex - Window.width/2 - size
	crosshairPoints[6].y = mousey - Window.height/2 - size

	crosshairPoints[3].x = mousex - Window.width/2 - size
	crosshairPoints[3].y = mousey - Window.height/2 + size
	crosshairPoints[7].x = mousex - Window.width/2 - size
	crosshairPoints[7].y = mousey - Window.height/2 + size
end

def drawTunnel(points, cam)
	for i in 0..points.size do
		#first we got some empty lists
		coords1 = []
		coords2 = []
		coords3 = []
		coords4 = []
		if i < points.size-4
			dz = points[i].z - cam.loc.z
			if dz < 100 and dz > -10
				#this just builds a quad for the walls of the tunnel
				if (i % 4 != 3)
					coords1 = points[i].getProjection(cam)
					coords2 = points[i+1].getProjection(cam)
					coords3 = points[i+5].getProjection(cam)
					coords4 = points[i+4].getProjection(cam)
				else
					coords1 = points[i].getProjection(cam)
					coords2 = points[i-3].getProjection(cam)
					coords3 = points[i+1].getProjection(cam)
					coords4 = points[i+4].getProjection(cam)
				end
				val = dz*2
				# puts val
				#change this lmao it makes them have random colors
				Quad.new(
				  x1: coords1[0], y1: coords1[1],
				  x2: coords2[0], y2: coords2[1],
				  x3: coords3[0], y3: coords3[1],
				  x4: coords4[0], y4: coords4[1],
				  color: ["green", 'blue', 'gray','red'],
				  z: -10
				)
			end
		end
	end
end

def main
	set title: "3d test"
	set width: 1024
	set height: 768

	#movement flags for player
	moving_up = false
	moving_down = false
	moving_left = false
	moving_right = false

	#camera for rendering outside world
	cam = Camera.new(Window.width, Window.height)
	#camera for rendering hud and crosshairs
	personalCam = Camera.new(Window.width, Window.height)
	#start behind the tunnel
	cam.loc.z = -100
	points = []	
	enemies = [Enemy.new(5000,5000,200)]
	enemies.push(Enemy.new(rand(10000), rand(10000), cam.loc.z + 300))

	player_bullets = []
	enemy_bullets = []

	# enemies.push(Enemy.new(5000,5000, 200))

	#build the tunnel
	crosshairPoints = [Point3d.new(0,0,1),
					   Point3d.new(0,0,1),
					   Point3d.new(0,0,1),
					   Point3d.new(0,0,1),
					   Point3d.new(0,0,1.5),
					   Point3d.new(0,0,1.5),
					   Point3d.new(0,0,1.5),
					   Point3d.new(0,0,1.5)]

	#push a square tunnel to the points array
	for i in 1..500 do
		#top left
		points.push(Point3d.new(0,0,i*10))
		#bottom left
		points.push(Point3d.new(0,10000,i*10))
		#bottom right
		points.push(Point3d.new(10000,10000,i*10))
		#top right
		points.push(Point3d.new(10000,0,i*10))
	end
	
	#put the player in the middle of the tunnel
	cam.loc.x = 5000
	cam.loc.y = 5000

#BEGINNING UPDATE LOOP
	update do
		#get rid of window contents
		Window.clear
		#logic here
		cam.loc.z += 0.5

		#get mouse location for crosshair
		setCrosshairPoints(crosshairPoints)

		#keyboard events
		on :key_down do |event|
			case event.key
			when "w"
				moving_up = true
			when "a"
				moving_left = true
			when "s"
				moving_down = true
			when "d"
				moving_right = true
			end
		end
		on :key_up do |event|
			case event.key
			when "w"
				moving_up = false
			when "a"
				moving_left = false
			when "s"
				moving_down = false
			when "d"
				moving_right = false
			end
			# puts event.key
		end

		on :mouse_down do |event|
			case event.button
			when :left
				mousex = Window.mouse_x
				mousey = Window.mouse_y
				dx = mousex - Window.width/2
				dy = mousey - Window.height/2
				dx *= 10
				dy *= 10
				new_point = Point3d.new(cam.loc.x + dx, cam.loc.y + dy, cam.loc.z+5)
				player_bullets.push(Bullet.new(new_point, 3))
			end
		end

		#process inputs and movement flags
		if (moving_right)
			cam.loc.x += 200
		end
		if (moving_left)
			cam.loc.x -= 200
		end
		if (moving_up)
			cam.loc.y -= 200
		end
		if (moving_down)
			cam.loc.y += 200
		end

		#draw the tunnel
		drawTunnel(points, cam)
		#then draw the crosshair
		crosshairPoints.each do |pnt|
			coords = pnt.getProjection(personalCam)
			Square.new(
				x: coords[0],
				y: coords[1],
				size: 10,
				color: 'green',
				z: 100)
		end

		# if (enemies[0].loc.z < cam.loc.z)
		# 	enemies[0] = Enemy.new(rand(10000), rand(10000), cam.loc.z + 300)
		# end
		# enemies.push(Enemy.new(rand(10000), rand(10000), cam.loc.z + 300))

		enemies.each do |enemy|
			if (enemy.loc.z < cam.loc.z)
				enemies.delete(enemy)
				enemies.push(Enemy.new(rand(10000), rand(10000), cam.loc.z + 300))
			end

			enemy.update
			eCoords = enemy.loc.getProjection(cam)
			relSize = enemy.getRenderedSize(cam)
			Image.new(
				'enemy.png',
				x: eCoords[0],
				y: eCoords[1],
				width: relSize[0], height: relSize[1]
				)
		end

		player_bullets.each do |bullet|
			puts bullet
			if (bullet.start.z - cam.loc.z > 100)
				player_bullets.delete(bullet)
			else
				bullet.update()
				startCoords = bullet.start.getProjection(cam)
				dz = bullet.start.z - cam.loc.z
				# endCoords = bullet.end.getProjection(cam)
				# Line.new(
				# 	x1: startCoords[0],
				# 	y1: startCoords[1],
				# 	x2: endCoords[0],
				# 	y2: endCoords[1],
				# 	width:10,
				# 	color: 'red'
				# 	)
				Circle.new(
					x: startCoords[0],
					y: startCoords[1],
					radius: 1000/dz)
			end
		end

		#render the Cornes of the tunnel, might use later, idk
		
		# points.each do|pnt|
		# 	coords = pnt.getProjection(cam)
		# 	dz = pnt.z- cam.loc.z
		# 	if (dz > 0 and dz < 100)
		# 		Square.new(
		# 			x: coords[0],
		# 			y: coords[1],
		# 			size: 1000/dz,
		# 			color: 'white',
		# 			z: 1)
		# 	end
		# end
		# rendering gray rectangles
		
	end
#END UPDATE LOOP
	show
end

inMenu = true

main()