unit
class Torpedo
    %TOrpedo will periodically fire, homing in on the shark. It increases speed and fires more depending on how many points the player has.
    export move, draw, logic, px, py, speedUp, timerDown, fire, explode, show, hide
    % instance variables
    var isActive : boolean := false
    var respawnTimer : int := 10
    var counter : int := respawnTimer

    var torp : int := Pic.FileNew ("torpedo.bmp")
    var boom : int := Pic.FileNew ("boom.bmp")

    var tSprite : int := Sprite.New (torp)
    Sprite.Hide (tSprite)
    Sprite.SetHeight (tSprite, 3)

    var px : int := 1
    var py : int := 1
    var speed : int := 5
    
    proc show
	Sprite.Show (tSprite)
    end show
    
    proc hide
	Sprite.Hide (tSprite)
    end hide

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    proc move (subx, suby, sharkx, sharky : int)
	if isActive then
	    px -= speed
	    if px > sharkx then
		if py < sharky and py < maxy div 2 then
		    py += speed div 2
		else
		    py -= speed div 2
		end if
	    end if
	else
	    px := subx
	    py := suby
	end if
    end move

    proc draw
	Sprite.SetPosition (tSprite, px, py, true)
    end draw

    procedure fire
	Sprite.Show (tSprite)
	isActive := true
    end fire

    procedure explode
	Sprite.ChangePic (tSprite, boom)
	Time.Delay (300)
	Sprite.Hide (tSprite)
	Sprite.ChangePic (tSprite, torp)
	isActive := false
    end explode

    proc speedUp
	if speed < 10 then
	    speed += 2
	end if
    end speedUp

    proc timerDown
	if respawnTimer > 3 then
	    respawnTimer -= 1
	end if
    end timerDown

    proc logic (gTick, subx, suby, sharkx, sharky : int)
	move (subx, suby, sharkx, sharky)
	if isActive then
	    draw
	end if
	if gTick = 60 then
	    counter -= 1
	    if counter = 0 then
		fire
		counter := respawnTimer
	    end if
	end if

	if px < -100 then
	    Sprite.Hide (tSprite)
	    isActive := false
	end if
    end logic

end Torpedo
