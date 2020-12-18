unit
class PowerUp
    %Powerup falls through the screen periodically, activating a power when touched 
    export isActive, show, hide, grab, fall, timerTick, logic, setID, powerID, px, py, setTimer, redraw, respawn
    % instance variables
    var powerID : int     % 1 is star, 2 is shield, 3 is TIME STOP
    var pStar : int := Pic.FileNew ("upStar.bmp")
    var pTime : int := Pic.FileNew ("upTime.bmp")
    var pShield : int := Pic.FileNew ("upShield.bmp")
    var powerSprite : int := Sprite.New (pStar)
    Sprite.SetHeight (powerSprite, 5)

    var px : int := Rand.Int (100, maxx - 100)
    var py : int := maxy + 100

    var isActive : boolean := false
    var timer : int := 5

    proc show
	Sprite.Show (powerSprite)
    end show

    proc hide
	Sprite.Hide (powerSprite)
    end hide

    proc setID (id : int)
	powerID := id
    end setID

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    procedure grab
	isActive := false
	Sprite.Hide (powerSprite)
    end grab

    proc fall
	py -= 3
    end fall

    proc redraw
	if powerID = 1 then
	    Sprite.ChangePic (powerSprite, pStar)
	elsif powerID = 2 then
	    Sprite.ChangePic (powerSprite, pShield)
	elsif powerID = 3 then
	    Sprite.ChangePic (powerSprite, pTime)
	end if
    end redraw
    
    proc respawn
	Sprite.Show (powerSprite)
	powerID := Rand.Int (1, 3)
	if powerID = 1 then
	    Sprite.ChangePic (powerSprite, pStar)
	elsif powerID = 2 then
	    Sprite.ChangePic (powerSprite, pShield)
	elsif powerID = 3 then
	    Sprite.ChangePic (powerSprite, pTime)
	end if
	isActive := true
	px := Rand.Int (100, maxx - 100)
	py := maxy + 100
	timer := Rand.Int (20, 40)
    end respawn

    proc setTimer (t : int)
	timer := t
    end setTimer

    proc timerTick
	timer -= 1
	if timer <= 0 then
	    respawn
	end if
    end timerTick

    proc logic (tick : int)
	Sprite.SetPosition (powerSprite, px, py, true)
	if py > -500 then
	    fall
	end if
	if tick = 1 then
	    timerTick
	end if
    end logic
end PowerUp
