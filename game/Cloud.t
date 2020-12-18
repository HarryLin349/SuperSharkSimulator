unit
class Cloud
    %CLoud is a horizontally moving object that will occasionally and randomly strike lightning to harm the shark.
    export setPosition, move, draw, logic, shock, px, isShocking, lightning, show, hide, isActive, activate

    % instance variables
    var isActive : boolean := false
    var isShocking : boolean := false
    var lightning : boolean := false
    var cloudPic : boolean := true
    var timer : int := 1

    var cloud1 : int := Pic.FileNew ("CloudW.bmp")
    var cloud2 : int := Pic.FileNew ("CloudB.bmp")

    var light1 : int := Pic.FileNew ("lightning1.bmp")
    var light2 : int := Pic.FileNew ("lightning2.bmp")

    var cloudSprite : int := Sprite.New (cloud1)
    Sprite.SetHeight (cloudSprite, 2)

    var lightSprite : int := Sprite.New (light1)
    Sprite.Hide (lightSprite)
    Sprite.SetHeight (lightSprite, 1)

    var px : int := maxx + 300
    var py : int := maxy - 100
    var dx : int := 3


    proc show
	Sprite.Show (cloudSprite)
    end show

    proc hide
	Sprite.Hide (cloudSprite)
	Sprite.Hide(lightSprite)
    end hide

    proc activate
	isActive := true
    end activate

    procedure setPosition (x, y : int)
	px := x
	py := y
    end setPosition

    procedure shock
	timer += 1
	if timer < 120 then
	    if timer > 60 then
		Sprite.Show (lightSprite)
		Sprite.SetPosition (lightSprite, px, maxy div 2 - 50, true)
		lightning := true
	    end if
	    if timer mod 5 = 0 then
		cloudPic := not cloudPic
	    end if
	    if cloudPic = false then
		Sprite.ChangePic (cloudSprite, cloud2)
		Sprite.ChangePic (lightSprite, light1)
	    else
		Sprite.ChangePic (cloudSprite, cloud1)
		Sprite.ChangePic (lightSprite, light2)
	    end if
	else
	    Sprite.Hide (lightSprite)
	    isShocking := false
	    lightning := false
	    timer := 1
	    Sprite.ChangePic (cloudSprite, cloud1)
	end if
    end shock

    proc move
	px -= dx
	if px < -100 then
	    px := maxx + 800
	    dx := Rand.Int (2, 5)
	end if
    end move

    
    proc draw
	Sprite.SetPosition (cloudSprite, px, py, true)
    end draw

    proc logic
	if Rand.Int (1, 500) = 100 then
	    isShocking := true
	end if
	if isShocking then
	    shock
	else
	    move
	end if
	draw
    end logic
end Cloud
