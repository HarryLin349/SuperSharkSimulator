unit
class Fish
    %Fish controls the logic for the fishes as well as the drawing procedures.
    export setPosition, initialize, move, logic, draw, px, py, eat, show, hide
    % instance variables

    var wL : int := Pic.FileNew ("FishWL.bmp")
    var wR : int := Pic.FileNew ("FishWR.bmp")

    var bL : int := Pic.FileNew ("FishBL.bmp")
    var bR : int := Pic.FileNew ("FishBR.bmp")
    var fishSprite : int := Sprite.New (wL)

    var isBlack : boolean := true %true := white
    var isRight : boolean := true
    var isUp : boolean := false
    var isAlive : boolean := true
    var px : int := Rand.Int (100, maxx - 100)
    var py : int := Rand.Int (50, maxy div 2 - 50)
    var isScared : boolean := false

    proc show
	Sprite.Show (fishSprite)
    end show

    proc hide
	Sprite.Hide (fishSprite)
    end hide

    proc initialize
	if Rand.Int (1, 2) = 2 then
	    Sprite.ChangePic (fishSprite, wL)
	    isBlack := false
	else
	    Sprite.ChangePic (fishSprite, bL)
	    isBlack := true
	end if
	Sprite.Show (fishSprite)
	Sprite.SetHeight (fishSprite, 2)
    end initialize

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    procedure eat
	isAlive := false
	Sprite.Hide (fishSprite)
	px := -100
    end eat

    procedure checkShark (x, y : int)
	if round (sqrt ((x - px) ** 2 + (y - py) ** 2)) < 250 then
	    isScared := true
	else
	    isScared := false
	end if
    end checkShark

    proc reverse
	isRight := not isRight
    end reverse

    proc reverseY
	isUp := not isUp
    end reverseY

    proc move (sharkVx, sharkVy, sharkY : int)
	if (px > -100 and px < maxx + 100) and (py > -20) then
	    if isScared then
		px += sharkVx div 1.5
		if sharkVx < 0 then
		    isRight := false
		else
		    isRight := true
		end if
		if py < maxy div 2 then
		    if py > sharkY then
			py += 3
		    else
			py -= 3
		    end if
		else
		    py -= 2
		end if
	    else
		if isRight then
		    px += 1
		else
		    px -= 1
		end if
		if py < maxy div 2 then

		    if isUp then
			py += 1
		    else
			py -= 1
		    end if
		else
		    py -= 3
		    reverseY
		end if

	    end if
	else
	    if Rand.Int (1, 2) = 1 then
		px := -50
	    else
		px := maxx + 50
	    end if
	    py := Rand.Int (30, maxy div 2 - 30)
	    isAlive := true
	    initialize
	end if
    end move

    proc draw
	Sprite.SetPosition (fishSprite, px, py, true)
	if isBlack then
	    if isRight then
		Sprite.ChangePic (fishSprite, bR)
	    else
		Sprite.ChangePic (fishSprite, bL)
	    end if
	else
	    if isRight then
		Sprite.ChangePic (fishSprite, wR)
	    else
		Sprite.ChangePic (fishSprite, wL)
	    end if
	end if
    end draw

    proc logic (sVx, sVy, sX, sY : int)
	checkShark (sX, sY)
	move (sVx, sVy, sY)
	if isAlive then
	    draw
	end if
	if Rand.Int (1, 20) = 1 then
	    if Rand.Int (1, 20) = 1 then
		reverse
	    end if
	    if Rand.Int (1, 5) = 1 then
		reverseY
	    end if
	end if
    end logic
end Fish
