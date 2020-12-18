setscreen ("graphics:1800;900")

var mouseX : int % Mouse controls
var mouseY : int
var button : int
var cX : int := maxx div 2
var cY : int := maxy div 2

var gunX : int
var gunY : int
var gX : int
var gY : int
var gunLength := 10

var slope : real

function distanceFrom (x1, y1, x2, y2 : int) : int % distance fucntion.
    result round (sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2))
end distanceFrom

function qChecker (x,y : int) : int
    if x < cX and y > cY then
	result 1
    elsif x > cX and y > cY then
	result 2
    elsif x < cX and y < cY then
	result 3
    elsif x > cX then
	result 4
    end if
    result 1
end qChecker

proc updateGun
    if mouseX - cX = 0 and mouseY > cY then
	slope := 0
	gunX := cX
	gunY := cY + gunLength
    elsif mouseX - cX = 0 and mouseY < cY then
	slope := 0
	gunX := cX
	gunY := gunLength - cX
    elsif mouseY - cY = 0 and mouseX > cX then
	slope := 0
	gunX := gunLength + cX
	gunY := cY
    elsif mouseY - cY = 0 and mouseX > cX then
	slope := 0
	gunX := gunLength - cX
	gunY := cY
    else
	slope := (mouseY - cY) / (mouseX - cX)
	gunX := round (sqrt (gunLength / 1 + (slope ** 2))) + cX
	gunY := round (slope * gunX) + cY
    end if
end updateGun

loop
    Mouse.Where (mouseX, mouseY, button)
    Draw.FillOval (cX, cY, 20, 20, blue)
    updateGun
    Draw.ThickLine (cX, cY, gunX, gunY, 10, black)
    Time.Delay (10)
    View.Update
    cls
end loop
