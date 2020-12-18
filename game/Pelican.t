unit
class Pelican
    %Pelican flies through the air, increasing altitude and speed if the shark is above the water.
    export move, draw, logic, px, py, eat, isAlive, show, hide
    % instance variables
    var isAlive : boolean := true
    var p1 : int := Pic.FileNew ("Pelican1.bmp")
    var p2 : int := Pic.FileNew ("Pelican2.bmp")
    var p3 : int := Pic.FileNew ("Pelican3.bmp")
    var pSprite : int := Sprite.New (p1)
 %   Sprite.Show (pSprite)
    Sprite.SetHeight (pSprite, 1)

    var px : int := maxx + 300
    var py : int := maxy - 300
    var spawny : int := py
    var dx : int := 2
    var dy : int := 4

    proc show
	Sprite.Show (pSprite)
    end show
    
    proc hide
	Sprite.Hide (pSprite)
    end hide
    
    procedure eat
	isAlive := false
	Sprite.Hide (pSprite)
    end eat

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    proc move (above : boolean)
	px += dx
	if px > maxx + 200 then
	    spawny := Rand.Int (maxy - 300, maxy - 150)
	    py := spawny + 100
	    px := -800
	    dx := Rand.Int (3, 5)
	    isAlive := true
	    Sprite.Show (pSprite)
	end if
	if px > 0 and px < maxx then
	    if above then
		py += dy
		px += 3
	    else
		if py > spawny then
		    py -= 1
		end if
	    end if
	end if
    end move

    proc draw (gameTick : int)
	Sprite.SetPosition (pSprite, px, py, true)
	if gameTick = 1 or gameTick = 50 then
	    Sprite.ChangePic (pSprite, p1)
	elsif gameTick = 10 or gameTick = 40 then
	    Sprite.ChangePic (pSprite, p2)
	elsif gameTick = 20 or gameTick = 30 then
	    Sprite.ChangePic (pSprite, p3)
	end if
    end draw

    proc logic (gTick : int, bool : boolean)
	move (bool)
	if isAlive then
	    draw (gTick)
	end if
    end logic

end Pelican
