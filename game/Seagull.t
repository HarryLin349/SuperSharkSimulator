unit
class Seagull
    %Seagull is a bird that moves up and down through the screen. TOuching it will eat it.
    export setPosition, move, draw, logic, isAlive, eat, px, posy, show, hide
    % instance variables
    var gullPic : boolean := true
    var gull1 : int := Pic.FileNew ("seagull1.bmp")
    var gull2 : int := Pic.FileNew ("seagull2.bmp")

    var gullSprite : int := Sprite.New (gull1)
    Sprite.SetHeight (gullSprite, 2)

    var px : int := maxx + 300
    var py : int := maxy - 200
    var posy : int := py
    var dx : int := 3

    var offset : real
    var isAlive : boolean := true

    proc show
	Sprite.Show (gullSprite)
    end show

    proc hide
	Sprite.Hide (gullSprite)
    end hide

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    procedure eat
	isAlive := false
	Sprite.Hide (gullSprite)
    end eat

    proc move (gameTick : int)
	px -= dx
	if px < -100 then
	    px := maxx + 800
	    dx := Rand.Int (5, 7)
	    isAlive := true
	    Sprite.Show (gullSprite)
	end if
	if gameTick < 30 then
	    offset := 5 * (gameTick) - 75
	else
	    offset := 75 - 5 * (gameTick - 30)
	end if
	posy := py + round (offset)
    end move

    proc draw (gameTick : int)
	Sprite.SetPosition (gullSprite, px, posy, true)
	if gameTick mod 10 = 0 then
	    gullPic := not gullPic
	end if
	if gullPic then
	    Sprite.ChangePic (gullSprite, gull1)
	else
	    Sprite.ChangePic (gullSprite, gull2)
	end if
    end draw

    proc logic (gTick, x, y : int)
	move (gTick)
	if isAlive then
	    draw (gTick)
	end if
    end logic
end Seagull
