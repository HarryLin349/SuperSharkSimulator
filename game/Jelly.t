unit
class Jelly
    %The Jelly moves through the sea by swimming, shocking the shark if it gets close
    export move, draw, logic, px, py, eat, show, hide
    % instance variables
    var isAlive : boolean := true
    var j1 : int := Pic.FileNew ("Jelly1.bmp")
    var j2 : int := Pic.FileNew ("Jelly2.bmp")
    var e1 : int := Pic.FileNew ("Elec1.bmp")
    var e2 : int := Pic.FileNew ("Elec2.bmp")
    var elecBool : boolean := true

    var jSprite : int := Sprite.New (j1)
%    Sprite.Show (jSprite)
    Sprite.SetHeight (jSprite, 1)

    var eSprite : int := Sprite.New (e1)
 %   Sprite.Show (eSprite)
    Sprite.SetHeight (eSprite, 2)

    var px : int := maxx + 300
    var py : int := maxy div 2 - 200
    var dx : int := 8
    var vx : int := 1
    var topSpeed : int := 6
    
    proc show
	Sprite.Show(eSprite)
	Sprite.Show(jSprite)
    end show
    
    proc hide
	Sprite.Hide(eSprite)
	Sprite.Hide(jSprite)
    end hide

    procedure eat
	isAlive := false
	Sprite.Hide (jSprite)
    end eat

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    proc move (gameTick : int)
	if gameTick > 14 then
	    if gameTick = 15 then
		dx := topSpeed
	    end if
	    px += dx
	    if gameTick mod 5 = 0 and dx > 3 then
		dx -= vx
	    end if
	else
	    px += 2
	end if
	
	if px > maxx + 300 then
	    px := -Rand.Int(300,600)
	    py := maxy div 2 - Rand.Int(50,350)
	    topSpeed := Rand.Int(6,12)
	end if
    end move

    proc draw (gameTick : int)
	Sprite.SetPosition (jSprite, px, py, true)
	Sprite.SetPosition (eSprite, px, py, true)
	if gameTick = 15 then
	    Sprite.ChangePic (jSprite, j1)
	elsif gameTick = 1 then
	    Sprite.ChangePic (jSprite, j2)
	end if
	if gameTick mod 5 = 0 then
	    elecBool := not elecBool
	end if
	if elecBool then
	    Sprite.ChangePic (eSprite, e1)
	else
	    Sprite.ChangePic (eSprite, e2)
	end if
    end draw

    proc logic (gTick : int)
	move (gTick)
	if isAlive then
	    draw (gTick)
	end if
    end logic

end Jelly
