%This game is an endless acade type game where the player improves their skills to try and get a high score.
%The player controls a shark with the mouse, swimming underwater and jumping out of the sea
%To eat fish, seagulls, and pelicans. These animals will try and avoid you, while
%Hazards like thunderbolts, jellyfish, and torpedos try to hit you. The player must constantly eat to
%Keep their hunger meter from falling, while avoiding damage that drops their hunger meter. There are
%also 3 power ups that will assist the player. The game ends when the player's score drops to 0.


import Cloud in "Cloud.t", Seagull in "Seagull.t", Pelican in "Pelican.t", Fish in "Fish.t", Jelly in "Jelly.t", Torpedo in "Torpedo.t", PowerUp in "PowerUp.t"
%Imports classes to program
setscreen ("graphics:1800;900") %Used to resize the screen
View.Set ("graphics:1800;900,position:center;center,offscreenonly") %Used to resize the screen (more options)
var arcadefont := Font.New ("ArcadeClassic:20") %These variables are to load in fonts.
var menufont := Font.New ("ArcadeClassic:36")
var smallfont := Font.New ("ArcadeClassic:18")

process explodeFX %These processes are all sound effects or music. .WAV = sound FX, .mp3 = music
    Music.PlayFile ("explode.wav")
end explodeFX

process chompFX
    Music.PlayFile ("chomp.wav")
end chompFX

process shockFX
    Music.PlayFile ("shock.wav")
end shockFX

process popFX
    Music.PlayFile ("pop.wav")
end popFX

process bgMusic
    Music.PlayFile ("Megalovania.mp3")
end bgMusic

process tutorialMusic
    Music.PlayFile ("tutorial.mp3")
end tutorialMusic

var playFX : boolean := true %These variables control the thunder FX and when it should play (when cloud strikes it plays)
var playFX2 : boolean := true

%%%%%%%%%%%%%%%%%%%%%%%%%MENU PICS AND SPRITES (Used to load in pictures and manipulate them on screen)
var t1 : int := Pic.FileNew ("Title1.bmp")
var t2 : int := Pic.FileNew ("Title2.bmp")
var t3 : int := Pic.FileNew ("Title3.bmp") %These three are used for the title screen animation
var logo : int := Pic.FileNew ("logo.bmp") %Game Logo loaded in
var lSprite : int := Sprite.New (logo) %Sprite to display the logo
var yVal : int := maxy + 300 %Controls the position of the logo
var down : int := 5 %Controls the acceleration of the logo
var tS : int := Sprite.New (t2) %Sprite for the menu

var arrow : int := Pic.FileNew ("Arrow.bmp") %Menu arrow to select
var aSprite : int := Sprite.New (arrow) %Controls the menu arrow pic
%%%

%HIGHSCORES
%SETTING UP THE SCOREBOARD
var names : array 1 .. 5 of string % array of player names
var scores : array 1 .. 5 of int % array of high scores
var userName : string % current player's name (get)
var counter : int := 0 % used to iterate through score array
var stream1 : int
var stream2 : int
var menuFont := Font.New ("ArcadeClassic:30") %menu font.
var c : char

open : stream1, "highscores.txt", get
loop % gets current high score leaderboard through file streaming
    exit when eof (stream1)
    counter += 1
    get : stream1, names (counter)
    get : stream1, scores (counter)
end loop

proc sortList %bubble sorts the scores and corresponding names from high to low
    var tempScore : int
    var tempName : string
    for decreasing i : 5 .. 1
	for j : 2 .. i
	    if scores (j - 1) < scores (j) then
		tempScore := scores (j - 1)
		scores (j - 1) := scores (j)
		scores (j) := tempScore
		tempName := names (j - 1)
		names (j - 1) := names (j)
		names (j) := tempName
	    end if
	end for
    end for
end sortList

proc updateList %streams scoreboard BACK to file
    open : stream2, "highscores.txt", put
    var count2 : int := 0
    for i : 1 .. 5
	put : stream2, names (i), " ", scores (i)
    end for
end updateList

proc addList (name : string, num : int) % adds a new player and score on the leaderboard if they should be added
    if num > scores (5) then
	scores (5) := num
	names (5) := name
    end if
    sortList
end addList

proc printList %print list.
    Draw.Text ("HIGH SCORES", maxx div 2 - length ("HIGH SCORES") * 8, 600, arcadefont, black)
    for i : 1 .. 5
	Draw.Text (names (i) + "     " + intstr (scores (i)), maxx div 3 - 80, 600 - i * 80, arcadefont, black)
    end for
end printList
%OBJECTS (For hazards and enemies)
var cloud : ^Cloud
new cloud

var cloud2 : ^Cloud
new cloud2 %2 clouds will scroll across the screen and strike lightning vertically. Refer to cloud class

var gull : ^Seagull
new gull %Refer to class file

var pelican : ^Pelican
new pelican %Refer to class file

var jelly : ^Jelly
new jelly %Refer to class file

var fishes : array 1 .. 8 of ^Fish %Refer to class file. Array of 8 objects.

for i : 1 .. upper (fishes) %initialize will choose a random colour and direction for the fish
    new fishes (i)
    ^ (fishes (i)).initialize
end for

var torpedo : ^Torpedo %Refer to class file
new torpedo

var pUp : ^PowerUp %Refer to class file
new pUp
%GAME VARIABLES
var endGame : boolean := false %Ends the game as an exit condition
var isVuln : boolean := true %Checks if the shark can take damage
var mouseX : int % Mouse controls
var mouseY : int
var button : int

var posX : int := maxx div 2 %Position of the shark
var posY : int := maxy div 2
var offsetX : int := posX %Offsets are used to find the position of the shark's mouth (the mouth hitbox used for eating)
var offsetY : int := posY

var subX : int := maxx - 150 %Controls the position of the submarine that fires torpedos
var subY : int := maxy div 2 - 100

var dY : int %Used to keep track of the shark's velocity
var dX : int
var vY : int := 0

var tempX : int %Used to preserve the shark's velocity before jumping (jumping locks controls)
var tempY : int

var gravity : int := 2 %gravity

var gameTick : int := 1 %Global timer tick that controls logic and events locked to periodic cycles
var hunger : int := 500 %Hunger meter
var tickDown : int := 5 %Keeps track of how much the gameTick changes
var points : int := 0 %Keeps track of the points

var comboTimer : int := 200 %Timer before the combo resets to 0
var cMult : real := 1 %COmbo multiplier
var combo : int := 0 %Combo count

var challengeCount : int := 0 %USed to keep track of the diffuculty of the game
var challengeMsg : string := "NORMAL" %Status of the game. Goes from "NORMAL" to "AHHHHHH!!!"

var powerUp : int := Rand.Int (1, 3) %Generates the "ID" of a powerup. 1 = Invincible 2 = shield 3 = timestop
var timeSlow : boolean := false
var timeDelay : int
var timeSkip : int
var hasShield : boolean := false

var powerX : int %Position of the powerup
var powerY : int
%%%%%%%%%PICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var sharkR : int := Pic.FileNew ("sharkRight.bmp") % all directions of the shark/.
var sharkRU : int := Pic.FileNew ("sharkRightUp.bmp")
var sharkRD : int := Pic.FileNew ("sharkRightDown.bmp")
var sharkL : int := Pic.FileNew ("sharkLeft.bmp")
var sharkLU : int := Pic.FileNew ("sharkLeftUp.bmp")
var sharkLD : int := Pic.FileNew ("sharkLeftDown.bmp")
var BG : int := Pic.FileNew ("sharkBG.bmp") %Background picture
var sub : int := Pic.FileNew ("sub.bmp") %Submarine pic

var bubble := Pic.FileNew ("BubbleShield.bmp") %Shield pic for sprite


%%%%%SPRITES
var sharkSprite : int := Sprite.New (sharkR)
var subSprite : int := Sprite.New (sub)
var shieldSprite : int := Sprite.New (bubble)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process makeVulnerable (t : int) %Flickers sprite. After an inputted amount of time, makes the player vulnerable.
    combo := 0
    var vulnTimer : int := t
    var altShow : boolean := true
    loop
	vulnTimer -= 1
	if vulnTimer mod 3 = 0 then
	    altShow := not altShow
	end if
	if altShow then
	    Sprite.Show (sharkSprite)
	else
	    Sprite.Hide (sharkSprite)
	end if
	Time.Delay (10)
	exit when vulnTimer < 1 or endGame = true
    end loop
    isVuln := true
    Sprite.Show (sharkSprite)
end makeVulnerable

function distanceFrom (x1, y1, x2, y2 : int) : int     % distance fucntion.
    result round (sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2))
end distanceFrom

proc move %Moves the shark to the mouse
    Mouse.Where (mouseX, mouseY, button)
    dX := (mouseX - posX) div 20
    dY := (mouseY - posY) div 20

    if vY < -70 then
	vY := -70
    end if

    if posY <= maxy div 2 then
	posX += dX
	if vY < 0 then
	    posY += dY + vY
	    vY += gravity * 3
	else
	    vY := 0
	    posY += dY
	end if
	if (maxy div 2 - posY) < 50 then
	    tempX := dX
	    tempY := dY + 10
	end if
    else
	posX += tempX
	posY += tempY
	posY += vY
	vY -= gravity
    end if
end move

process stopTime %Stops time for a short while
    /*
     var timeSlow : boolean
     var timeDelay : int
     var timeSkip : int
     */
    timeSlow := true
    timeDelay := 2
    Time.Delay (500)
    timeDelay := 3
    Time.Delay (500)
    timeDelay := 4
    Time.Delay (500)
    timeDelay := 61
    Time.Delay (5000)
    timeDelay := 3
    Time.Delay (500)
    timeDelay := 2
    Time.Delay (500)


    timeSlow := false
    timeDelay := 1
    timeSkip := 1
end stopTime

proc drawShark %Draws the shark sprite
    if posY <= maxy div 2 then %Uses logic to determine what direction the shark is facing
	if dX < 0 then
	    if dY > 5 then
		Sprite.ChangePic (sharkSprite, sharkLU)
		offsetX := -20
		offsetY := 20
	    elsif dY < -5 then
		Sprite.ChangePic (sharkSprite, sharkLD)
		offsetX := -20
		offsetY := -20
	    else
		Sprite.ChangePic (sharkSprite, sharkL)
		offsetX := -30
		offsetY := 0
	    end if
	elsif dX > 0 then
	    if dY > 5 then
		Sprite.ChangePic (sharkSprite, sharkRU)
		offsetX := 20
		offsetY := 20
	    elsif dY < -5 then
		Sprite.ChangePic (sharkSprite, sharkRD)
		offsetX := 20
		offsetY := -20
	    else
		Sprite.ChangePic (sharkSprite, sharkR)
		offsetX := 30
		offsetY := 0
	    end if
	end if
    else
	if tempX < 0 then
	    if tempY + vY > 5 then
		Sprite.ChangePic (sharkSprite, sharkLU)
	    elsif tempY + vY < -5 then
		Sprite.ChangePic (sharkSprite, sharkLD)
	    else
		Sprite.ChangePic (sharkSprite, sharkL)
	    end if
	elsif tempX > 0 then
	    if tempY + vY > 5 then
		Sprite.ChangePic (sharkSprite, sharkRU)
	    elsif tempY + vY < -5 then
		Sprite.ChangePic (sharkSprite, sharkRD)
	    else
		Sprite.ChangePic (sharkSprite, sharkR)
	    end if
	end if
    end if
    Sprite.SetPosition (sharkSprite, posX, posY, true)
    if hasShield then
	Sprite.SetPosition (shieldSprite, posX, posY, true)
	Sprite.Show (shieldSprite)
    end if
end drawShark

proc tick %Iterates the timer
    gameTick += 1
    if gameTick > 60 then
	gameTick := 1
    end if
end tick

proc comboCount %Updates the combo multiplier
    if comboTimer > 0 then
	comboTimer -= 7
    end if
    if comboTimer <= 0 then
	combo := 0
    end if
    if combo = 0 then
	cMult := 1
    else
	cMult := 1 + ((combo - 1) * 0.1)
    end if
end comboCount

proc hitboxes %Hitbox logic for all the creatures and hazards
    if ^pUp.isActive then

	if distanceFrom (posX + offsetX, posY + offsetY, ^pUp.px, ^pUp.py) < 50 then
	    ^pUp.grab
	    if ^pUp.powerID = 1 then
		isVuln := false
		fork makeVulnerable (800)
	    elsif ^pUp.powerID = 2 then
		hasShield := true
	    else
		fork stopTime
	    end if
	end if
    end if

    if ^gull.isAlive then
	if distanceFrom (posX + offsetX, posY + offsetY, ^gull.px, ^gull.posy) < 50 then
	    hunger += 100
	    ^gull.eat

	    combo += 1
	    comboTimer := 200
	    points += round (100 * cMult)
	end if
    end if

    if ^pelican.isAlive then
	if distanceFrom (posX + offsetX, posY + offsetY, ^pelican.px, ^pelican.py) < 60 then
	    hunger += 175
	    ^pelican.eat

	    combo += 1
	    comboTimer := 200
	    points += round (250 * cMult)
	end if
    end if

    if ^cloud.lightning and isVuln then
	if playFX then
	    fork explodeFX
	    playFX := false
	end if
	if posX - ^cloud.px < 40 and posX - ^cloud.px > -40 then
	    if hasShield then
		fork popFX
		Sprite.Hide (shieldSprite)
		hasShield := false
		isVuln := false
		Time.Delay (300)
		fork makeVulnerable (100)
	    else
		fork shockFX
		hunger -= 100
		Time.Delay (300)
		isVuln := false
		fork makeVulnerable (100)
	    end if
	end if
    else
	playFX := true
    end if

    if ^cloud2.isActive then
	if ^cloud2.lightning and isVuln then
	    if playFX2 then
		fork explodeFX
		playFX2 := false
	    end if
	    if posX - ^cloud2.px < 40 and posX - ^cloud2.px > -40 then
		if hasShield then
		    fork popFX
		    Sprite.Hide (shieldSprite)
		    hasShield := false
		    isVuln := false
		    Time.Delay (300)
		    fork makeVulnerable (100)
		else
		    fork shockFX
		    hunger -= 100
		    Time.Delay (300)
		    isVuln := false
		    fork makeVulnerable (100)
		end if
	    end if
	else
	    playFX2 := true
	end if
    end if

    if isVuln then
	if distanceFrom (posX, posY, ^jelly.px, ^jelly.py) < 60 then
	    if hasShield then
		fork popFX
		Sprite.Hide (shieldSprite)
		hasShield := false
		isVuln := false
		Time.Delay (300)
		fork makeVulnerable (100)
	    else
		hunger -= 100
		fork shockFX
		Time.Delay (300)
		isVuln := false
		fork makeVulnerable (100)
	    end if
	end if

	if distanceFrom (posX, posY, ^torpedo.px, ^torpedo.py) < 60 then
	    if hasShield then
		fork popFX
		Sprite.Hide (shieldSprite)
		^torpedo.explode
		hasShield := false
		isVuln := false
		fork makeVulnerable (100)
	    else
		hunger -= 100
		^torpedo.explode
		isVuln := false
		fork explodeFX
		fork makeVulnerable (100)
	    end if
	end if
    end if
end hitboxes

proc subLogic %MOves the submarine
    Sprite.SetPosition (subSprite, subX, subY, true)
    if subY < maxy div 2 - 100 then
	if subY - posY < -10 then
	    subY += 2
	elsif subY - posY > 10 then
	    subY -= 2
	end if
    else
	subY -= 1
    end if
end subLogic


proc increaseSpeed %INcreases the speed and "challenge" of the game every time the score reaches a vertain threshold
    if points div 500 = challengeCount then
	challengeCount += 1
	^torpedo.speedUp
	^torpedo.timerDown
	if challengeCount = 1 then
	    challengeMsg := "NORMAL"
	elsif challengeCount = 2 then
	    challengeMsg := "HEATING UP"
	elsif challengeCount = 3 then
	    challengeMsg := "TORPEDO FURY"
	elsif challengeCount = 4 then
	    challengeMsg := "CLOUD++"
	elsif challengeCount = 5 then
	    challengeMsg := "SUPER HOT"
	else
	    challengeMsg := "AHHHHH!!!"
	end if
    end if
end increaseSpeed

procedure gameOver     %GAMEOVER---------------------------------------------------------------Fs
    open : stream1, "highscores.txt", get
    var ch : char
    var win2 : int := Window.Open ("graphics:600;800,position:center;center")
    Window.Select (win2)
    Draw.Text ("GAME OVER", maxx div 2 - length ("GAME OVER") * 8, 700, arcadefont, black)
    delay (100)
    Draw.Text ("SCORE:  " + intstr (points), maxx div 3, 650, arcadefont, black)
    delay (100)
    Draw.Text ("ENTER YOUR NAME:", maxx div 2 - length ("ENTER YOUR NAME:") * 8, 100, arcadefont, black)
    delay (100)
    locatexy (maxx div 2, 50)
    get userName
    sortList
    addList (userName, points)
    updateList
    printList
    close : stream1
    close : stream2
    Draw.Text ("PRESS ENTER TWICE TO EXIT", maxx div 2 - length ("PRESS ENTER TWICE TO EXIT") * 8, 50, arcadefont, black)
    get ch
    Window.Close (win2)
end gameOver

%Draw.FillBox (0, 0, maxx, maxy div 2, black)


proc titleAnimation (clear : boolean) %Animates the title
    yVal := maxy + 300
    down := 5
    if clear then
	Sprite.Hide (tS)
	Sprite.Hide (lSprite)
	Sprite.Hide (aSprite)
	cls
    else
	Sprite.Show (tS)
	Sprite.SetHeight (tS, 0)
	Sprite.SetPosition (tS, maxx div 2, maxy div 2, true)
	Sprite.Show (lSprite)
	Sprite.SetHeight (lSprite, 1)
	Sprite.SetPosition (lSprite, maxx - 350, yVal, true)
	loop
	    yVal -= down
	    down += 10
	    Sprite.SetPosition (lSprite, maxx - 350, yVal, true)
	    Time.Delay (10)
	    View.Update
	    exit when yVal <= maxy div 2 + 200
	end loop
	fork explodeFX
	Sprite.ChangePic (tS, t3)
	Time.Delay (100)
	Sprite.ChangePic (tS, t2)
	Time.Delay (100)
	Sprite.ChangePic (tS, t1)
	Time.Delay (100)
	Sprite.Hide (tS)
	Pic.Draw (t1, 0, 0, 1)
    end if
end titleAnimation

proc spriteHider %Hides all the sprites
    Sprite.Hide (sharkSprite)
    Sprite.Hide (subSprite)
    ^cloud.hide
    ^cloud2.hide
    ^gull.hide
    ^pelican.hide
    ^jelly.hide
    ^torpedo.hide
    ^pUp.hide
    for i : 1 .. upper (fishes)
	^ (fishes (i)).hide
    end for
end spriteHider

proc spriteLoader %Shows all the sprites
    Sprite.Show (sharkSprite)
    Sprite.Show (subSprite)
    ^cloud.show
    ^gull.show
    ^pelican.show
    ^jelly.show
    for i : 1 .. upper (fishes)
	^ (fishes (i)).initialize
    end for
end spriteLoader

proc drawMsg %Draws the menu text with an "outline"
    Draw.Text ("START GAME", maxx - 453, maxy div 2 - 150, menufont, black)
    Draw.Text ("START GAME", maxx - 447, maxy div 2 - 150, menufont, black)
    Draw.Text ("START GAME", maxx - 450, maxy div 2 - 153, menufont, black)
    Draw.Text ("START GAME", maxx - 450, maxy div 2 - 147, menufont, black)
    Draw.Text ("START GAME", maxx - 450, maxy div 2 - 150, menufont, white)

    Draw.Text ("HOW TO PLAY", maxx - 453, maxy div 2 - 250, menufont, black)
    Draw.Text ("HOW TO PLAY", maxx - 447, maxy div 2 - 250, menufont, black)
    Draw.Text ("HOW TO PLAY", maxx - 450, maxy div 2 - 253, menufont, black)
    Draw.Text ("HOW TO PLAY", maxx - 450, maxy div 2 - 247, menufont, black)
    Draw.Text ("HOW TO PLAY", maxx - 450, maxy div 2 - 250, menufont, white)
end drawMsg

proc playGame % resets game variables to initial value and plays the game
    timeSlow := false
    timeDelay := 1
    timeSkip := 1
    fork makeVulnerable (1)

    hunger := 500
    new cloud
    new cloud2
    new gull
    new pelican
    new jelly
    for i : 1 .. upper (fishes)
	new fishes (i)
	^ (fishes (i)).initialize
    end for
    new torpedo

    Sprite.Show (sharkSprite)
    Sprite.Show (subSprite)
    ^cloud.show
    ^gull.show
    ^pelican.show
    ^jelly.show
    for i : 1 .. upper (fishes)
	^ (fishes (i)).initialize
    end for
    endGame := false
    Pic.Draw (BG, 0, 0, 1)
    fork bgMusic
    loop     %GAME
	Mouse.Where (mouseX, mouseY, button)
	move
	drawShark
	hitboxes
	tick
	if timeSlow then
	    if gameTick mod 5 = 0 then
		hunger += 1
	    end if
	    for i : 1 .. upper (fishes)
		if distanceFrom (posX + offsetX, posY + offsetY, ^ (fishes (i)).px, ^ (fishes (i)).py) < 40 then
		    ^ (fishes (i)).eat

		    points += round (15 * cMult)
		    hunger += 30
		    combo += 1
		    comboTimer := 200
		end if
	    end for

	    if gameTick mod timeDelay = 0 then
		if posY > maxy div 2 then
		    ^pelican.logic (gameTick, true)
		else
		    ^pelican.logic (gameTick, false)
		end if
		^cloud.logic
		if challengeCount >= 4 then
		    ^cloud2.activate
		    ^cloud2.logic
		    ^cloud2.show
		end if
		^gull.logic (gameTick, posY, posY)
		^jelly.logic (gameTick)
		^torpedo.logic (gameTick, subX, subY - 50, posX, posY)
		subLogic
		increaseSpeed
		^pUp.logic (gameTick)
		for i : 1 .. upper (fishes)
		    ^ (fishes (i)).logic (dX, dY, posX, posY)
		end for
	    end if
	else
	    if posY > maxy div 2 then
		^pelican.logic (gameTick, true)
	    else
		^pelican.logic (gameTick, false)
	    end if
	    ^cloud.logic
	    if challengeCount >= 4 then
		^cloud2.activate
		^cloud2.logic
		^cloud2.show
	    end if
	    ^gull.logic (gameTick, posY, posY)
	    ^jelly.logic (gameTick)
	    ^torpedo.logic (gameTick, subX, subY - 50, posX, posY)
	    subLogic
	    increaseSpeed
	    ^pUp.logic (gameTick)
	    for i : 1 .. upper (fishes)
		^ (fishes (i)).logic (dX, dY, posX, posY)
		if distanceFrom (posX + offsetX, posY + offsetY, ^ (fishes (i)).px, ^ (fishes (i)).py) < 40 then
		    ^ (fishes (i)).eat

		    points += round (10 * cMult)
		    hunger += 30
		    combo += 1
		    comboTimer := 200
		end if
	    end for
	end if
	if hunger > 500 then
	    hunger := 500
	end if

	if gameTick mod 5 = 0 then
	    comboCount
	    hunger -= 1
	    if challengeCount >= 2 then
		hunger -= 1
	    end if
	    if challengeCount >= 6 then
		hunger -= 1
	    end if
	end if
	if gameTick mod 5 = 0 then
	    Draw.FillBox (0, maxy, maxx, maxy - 40, black)

	    Draw.Text ("HUNGER:", 10, maxy - 30, arcadefont, white)
	    Draw.Box (150, maxy - 13, 650, maxy - 27, white)
	    Draw.FillBox (150, maxy - 13, hunger + 150, maxy - 27, white)

	    Draw.Text ("COMBO x" + realstr (cMult, 2), 680, maxy - 30, arcadefont, white)
	    Draw.Box (850, maxy - 13, 1050, maxy - 27, white)
	    Draw.FillBox (850, maxy - 13, comboTimer + 850, maxy - 27, white)

	    Draw.Text ("POINTS: " + intstr (points), maxx - 700, maxy - 30, arcadefont, white)
	    Draw.Text ("STATUS: " + challengeMsg, maxx - 450, maxy - 30, arcadefont, white)
	end if
	Time.Delay (5)
	View.Update
	if hunger < 0 then
	    gameOver
	    endGame := true
	end if
	exit when endGame = true
    end loop
end playGame


proc how2Play %PLays the tutorial (modified version of the game)
    timeSlow := false
    timeDelay := 1
    timeSkip := 1

    new cloud
    new cloud2
    new gull
    new pelican
    new jelly
    new pUp

    for i : 1 .. upper (fishes)
	new fishes (i)
	^ (fishes (i)).initialize
    end for
    spriteHider
    ^pelican.hide
    new torpedo
    Sprite.Show (sharkSprite)

    var input : array char of boolean
    var prev : array char of boolean
    var keyDown : boolean := false
    Input.KeyDown (input)
    prev := input

    endGame := false
    var birdShow : boolean := true
    var hazardShow : boolean := true
    var subShow : boolean := true
    var pUpShow : boolean := true

    var stepNum : int := 1

    Pic.Draw (BG, 0, 0, 1)
    fork tutorialMusic
    loop     %INSTRUCTIONS
	Input.KeyDown (input)
	if input (KEY_SHIFT) then
	    keyDown := true
	else
	    keyDown := false
	end if

	if keyDown = false and prev (KEY_SHIFT) then
	    stepNum += 1
	end if

	prev := input

	Mouse.Where (mouseX, mouseY, button)
	move
	drawShark
	hitboxes
	tick
	Draw.FillBox (300, 100, maxx - 300, maxy div 2 - 100, black)
	if stepNum = 1 then
	    Draw.Text ("Hey there! Welcome to Shark Simulator!", 320, 300, smallfont, white)
	    Draw.Text ("(Press Shift to continue...)", 320, 250, smallfont, white)
	elsif stepNum = 2 then
	    Draw.Text ("For now, try moving the shark around.", 320, 300, smallfont, white)
	    Draw.Text ("The shark will follow your mouse, and will", 320, 250, smallfont, white)
	    Draw.Text ("go faster if the mouse is farther away", 320, 200, smallfont, white)
	    Draw.Text ("(Press Shift to continue...)", 320, 150, smallfont, white)
	elsif stepNum = 3 then
	    Draw.Text ("Great! Now try jumping out of the water.", 320, 300, smallfont, white)
	    Draw.Text ("Just move your mouse above the water.", 320, 250, smallfont, white)
	    Draw.Text ("The faster and farther you move it, the higher it will jump.", 320, 200, smallfont, white)
	elsif stepNum = 4 then
	    Draw.Text ("It's a bit empty...Let's add some fish!", 320, 300, smallfont, white)
	    Draw.Text ("Simply move your mouth to a fish to eat it.", 320, 250, smallfont, white)
	    Draw.Text ("Eating will give you points and fill your hunger.", 320, 200, smallfont, white)
	elsif stepNum = 5 then
	    Draw.Text ("TIP: Fish will swim faster if you chase them very quickly.", 320, 300, smallfont, white)
	    Draw.Text ("Approach slowly. They also can't swim up or down fast,", 320, 250, smallfont, white)
	    Draw.Text ("so try and approach from above or below.", 320, 200, smallfont, white)
	elsif stepNum = 6 then
	    Draw.Text ("See the hunger meter up there? Your hunger will", 320, 300, smallfont, white)
	    Draw.Text ("constantly go down, and you'll die if it hits zero.", 320, 250, smallfont, white)
	    Draw.Text ("(It's the tutorial so you wont die though)", 320, 200, smallfont, white)
	elsif stepNum = 7 then
	    Draw.Text ("Let's add some birds. Practice eating them.", 320, 300, smallfont, white)
	    Draw.Text ("Gulls will fly straight, but Pelicans will", 320, 250, smallfont, white)
	    Draw.Text ("fly higher and faster when you're above water.", 320, 200, smallfont, white)
	elsif stepNum = 8 then
	    Draw.Text ("There are many hazards in the ocean.", 320, 300, smallfont, white)
	    Draw.Text ("Jellyfish will shock you, and storm clouds may strike.", 320, 250, smallfont, white)
	    Draw.Text ("If you're hurt your hunger meter will drop!", 320, 200, smallfont, white)
	elsif stepNum = 9 then
	    Draw.Text ("Pesky humans will also try to hunt you.", 320, 300, smallfont, white)
	    Draw.Text ("The submarine will try and follow you,", 320, 250, smallfont, white)
	    Draw.Text ("and then shoot torpedos from time to time.", 320, 200, smallfont, white)
	elsif stepNum = 10 then
	    Draw.Text ("You may have noticed the combo meter", 320, 300, smallfont, white)
	    Draw.Text ("in the HUD. You are rewarded for eating multiple", 320, 250, smallfont, white)
	    Draw.Text ("things in succession before the meter drops.", 320, 200, smallfont, white)
	elsif stepNum = 11 then
	    Draw.Text ("The higher your combo, the more points", 320, 300, smallfont, white)
	    Draw.Text ("you earn when eating stuff. Getting hit", 320, 250, smallfont, white)
	    Draw.Text ("will drop your multiplier to 1x however.", 320, 200, smallfont, white)
	elsif stepNum = 12 then
	    Draw.Text ("There are also some powerups to collect.", 320, 300, smallfont, white)
	    Draw.Text ("Experiment with a few.", 320, 250, smallfont, white)
	    Draw.Text ("This one will slow time.", 320, 200, smallfont, white)
	elsif stepNum = 13 then
	    Draw.Text ("This one gives you a shield that protects against 1 hit.", 320, 300, smallfont, white)
	elsif stepNum = 14 then
	    Draw.Text ("This one gives you invincibility for a short time.", 320, 300, smallfont, white)
	elsif stepNum = 15 then
	    Draw.Text ("That's it! The game will get harder the more", 320, 300, smallfont, white)
	    Draw.Text ("points you have. Try and get a high score before dying.", 320, 250, smallfont, white)
	    Draw.Text ("Press SHIFT to exit the tutorial.", 320, 200, smallfont, white)
	end if
	if stepNum >= 4 then
	    if timeSlow then
		if gameTick mod timeDelay = 0 then
		    for i : 1 .. upper (fishes)
			^ (fishes (i)).show
			^ (fishes (i)).logic (dX, dY, posX, posY)
		    end for
		end if
	    else
		for i : 1 .. upper (fishes)
		    ^ (fishes (i)).show
		    ^ (fishes (i)).logic (dX, dY, posX, posY)
		end for
	    end if

	    for i : 1 .. upper (fishes)
		if distanceFrom (posX + offsetX, posY + offsetY, ^ (fishes (i)).px, ^ (fishes (i)).py) < 40 then
		    ^ (fishes (i)).eat
		    points += round (15 * cMult)
		    hunger += 30
		    combo += 1
		    comboTimer := 200
		end if
	    end for
	end if

	if stepNum >= 7 then
	    if birdShow then
		^gull.show
		^pelican.show
		^gull.setPosition (-50, maxy - 200)
		birdShow := false
	    end if

	    if timeSlow then
		if gameTick mod timeDelay = 0 then
		    ^gull.logic (gameTick, posY, posY)
		    if posY > maxy div 2 then
			^pelican.logic (gameTick, true)
		    else
			^pelican.logic (gameTick, false)
		    end if
		end if
	    else
		^gull.logic (gameTick, posY, posY)
		if posY > maxy div 2 then
		    ^pelican.logic (gameTick, true)
		else
		    ^pelican.logic (gameTick, false)
		end if
	    end if

	    if ^gull.isAlive then
		if distanceFrom (posX + offsetX, posY + offsetY, ^gull.px, ^gull.posy) < 50 then
		    hunger += 100
		    ^gull.eat
		    combo += 1
		    comboTimer := 200
		    points += round (100 * cMult)
		end if
	    end if

	    if ^pelican.isAlive then
		if distanceFrom (posX + offsetX, posY + offsetY, ^pelican.px, ^pelican.py) < 60 then
		    hunger += 175
		    ^pelican.eat
		    combo += 1
		    comboTimer := 200
		    points += round (250 * cMult)
		end if
	    end if
	end if

	if stepNum >= 8 then

	    if timeSlow then
		if gameTick mod timeDelay = 0 then
		    ^jelly.logic (gameTick)
		    ^cloud.logic
		end if
	    else
		^jelly.logic (gameTick)
		^cloud.logic
	    end if

	    if hazardShow then
		^jelly.show
		^cloud.show
		hazardShow := false
	    end if

	    if ^cloud.lightning and isVuln then
		if playFX then
		    fork explodeFX
		    playFX := false
		end if
		if posX - ^cloud.px < 40 and posX - ^cloud.px > -40 then
		    if hasShield then
			fork popFX
			Sprite.Hide (shieldSprite)
			hasShield := false
			isVuln := false
			Time.Delay (300)
			fork makeVulnerable (100)
		    else
			fork shockFX
			hunger -= 100
			Time.Delay (300)
			isVuln := false
			fork makeVulnerable (100)
		    end if
		end if
	    else
		playFX := true
	    end if



	    if isVuln then
		if distanceFrom (posX, posY, ^jelly.px, ^jelly.py) < 60 then
		    if hasShield then
			fork popFX
			Sprite.Hide (shieldSprite)
			hasShield := false
			isVuln := false
			Time.Delay (300)
			fork makeVulnerable (100)
		    else
			hunger -= 100
			fork shockFX
			Time.Delay (300)
			isVuln := false
			fork makeVulnerable (100)
		    end if
		end if

		if distanceFrom (posX, posY, ^torpedo.px, ^torpedo.py) < 60 then
		    if hasShield then
			fork popFX
			Sprite.Hide (shieldSprite)
			^torpedo.explode
			hasShield := false
			isVuln := false
			fork makeVulnerable (100)
		    else
			hunger -= 100
			^torpedo.explode
			isVuln := false
			fork explodeFX
			fork makeVulnerable (100)
		    end if
		end if
	    end if
	end if

	if stepNum >= 9 then
	    if subShow then
		Sprite.Show (subSprite)
		subShow := false
		^torpedo.speedUp
		^torpedo.timerDown
		^torpedo.speedUp
		^torpedo.timerDown
		^torpedo.timerDown
	    end if

	    if timeSlow then
		if gameTick mod timeDelay = 0 then
		    subLogic
		    ^torpedo.logic (gameTick, subX, subY - 50, posX, posY)
		end if
	    else
		subLogic
		^torpedo.logic (gameTick, subX, subY - 50, posX, posY)
	    end if
	end if

	if stepNum = 12 then
	    ^pUp.setID (3)
	    ^pUp.redraw
	end if

	if stepNum = 13 then
	    ^pUp.setID (2)
	    ^pUp.redraw
	end if

	if stepNum = 14 then
	    ^pUp.setID (1)
	    ^pUp.redraw
	end if

	if stepNum >= 12 then
	    if pUpShow then
		^pUp.show
		^pUp.setTimer (-1)
		pUpShow := false
	    end if

	    ^pUp.logic (gameTick)

	    if ^pUp.isActive then
		if distanceFrom (posX + offsetX, posY + offsetY, ^pUp.px, ^pUp.py) < 50 then
		    ^pUp.grab
		    if ^pUp.powerID = 1 then
			isVuln := false
			fork makeVulnerable (800)
		    elsif ^pUp.powerID = 2 then
			hasShield := true
		    else
			fork stopTime
		    end if
		end if
	    end if

	    if ^pUp.py < -50 then
		^pUp.setTimer (-1)
	    end if

	end if

	if stepNum >= 16 then
	    cls
	    endGame := true
	end if


	if hunger > 500 then
	    hunger := 500
	end if

	if gameTick mod 5 = 0 then
	    comboCount
	    hunger -= 1
	    if challengeCount >= 2 then
		hunger -= 1
	    end if
	    if challengeCount >= 6 then
		hunger -= 1
	    end if
	end if

	if gameTick mod 5 = 0 then
	    Draw.FillBox (0, maxy, maxx, maxy - 40, black)

	    Draw.Text ("HUNGER:", 10, maxy - 30, arcadefont, white)
	    Draw.Box (150, maxy - 13, 650, maxy - 27, white)
	    Draw.FillBox (150, maxy - 13, hunger + 150, maxy - 27, white)

	    Draw.Text ("COMBO x" + realstr (cMult, 2), 680, maxy - 30, arcadefont, white)
	    Draw.Box (850, maxy - 13, 1050, maxy - 27, white)
	    Draw.FillBox (850, maxy - 13, comboTimer + 850, maxy - 27, white)

	    Draw.Text ("POINTS: " + intstr (points), maxx - 700, maxy - 30, arcadefont, white)
	    Draw.Text ("STATUS: N/A", maxx - 450, maxy - 30, arcadefont, white)
	end if

	Time.Delay (10)
	View.Update
	if hunger < 0 then
	    hunger := 500
	end if
	exit when endGame = true
    end loop
end how2Play


proc menu %MAin menu of the game
    var onTop : boolean := true
    var input : array char of boolean
    var prev : array char of boolean
    var keyDown : boolean := false
    var exitLoop : boolean := false
    loop
	exitLoop := false
	Music.PlayFileStop
	spriteHider
	titleAnimation (false)
	points := 0

	drawMsg
	Sprite.Show (aSprite)

	Input.KeyDown (input)
	prev := input
	loop
	    Input.KeyDown (input)
	    if input (KEY_UP_ARROW) or input (KEY_DOWN_ARROW) then
		keyDown := true
	    else
		keyDown := false
	    end if

	    if keyDown = false and (prev (KEY_UP_ARROW) or prev (KEY_DOWN_ARROW)) then
		onTop := not onTop
	    end if

	    prev := input

	    if onTop then
		Sprite.SetPosition (aSprite, maxx - 520, maxy div 2 - 130, true)
	    else
		Sprite.SetPosition (aSprite, maxx - 520, maxy div 2 - 230, true)
	    end if

	    if input (' ') then
		if onTop then
		    spriteHider
		    titleAnimation (true)
		    playGame
		    exitLoop := true
		    cls
		else
		    spriteHider
		    titleAnimation (true)
		    how2Play
		    exitLoop := true
		end if
	    end if
	    Time.Delay (10)
	    exit when exitLoop = true
	end loop
    end loop
end menu

menu
/*
 NOTES===================================================
 if gameTick mod 2 = 0 then
 Draw.FillOval (posX + offsetX, posY + offsetY, 40, 40, blue)
 else
 Draw.FillOval (posX + offsetX, posY + offsetY, 40, 40, red)
 end if
 Draw.FillOval (posX, posY, 10, 10, white)
 */
/*
 if posY < maxy div 2 then
 drawBubbles
 end if
 */


/*
 var input : array char of boolean
 var prev : array char of boolean
 var keyDown : boolean := false
 Input.KeyDown (input)
 prev := input

 loop
 Input.KeyDown (input)
 if input (' ') then
 keyDown := true
 else
 keyDown := false
 end if
 if keyDown = false and prev (' ') then
 put "Up Released" ..
 end if
 prev := input
 end loop

 */
