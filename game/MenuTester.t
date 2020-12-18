View.Set ("graphics:1800;900,position:center;center,offscreenonly")

var t1 : int := Pic.FileNew ("Title1.bmp")
var t2 : int := Pic.FileNew ("Title2.bmp")
var t3 : int := Pic.FileNew ("Title3.bmp")
var logo : int := Pic.FileNew ("logo.bmp")
var lSprite : int := Sprite.New (logo)
var yVal : int := maxy + 200
var down : int := 5
var tS : int := Sprite.New (t2)
Sprite.Show (tS)
Sprite.SetHeight(tS,1)
Sprite.SetPosition (tS, maxx div 2, maxy div 2, true)
Sprite.Show (lSprite)
Sprite.SetHeight(lSprite,2)
Sprite.SetPosition (lSprite, maxx - 350, yVal, true)
loop
    yVal -= down
    down += 10
    Sprite.SetPosition (lSprite, maxx - 350, yVal, true)
    Time.Delay(5)
    View.Update
    exit when yVal <= maxy div 2 + 100
end loop
Sprite.ChangePic(tS, t3)
Time.Delay(100)
Sprite.ChangePic(tS, t2)
Time.Delay(100)
Sprite.ChangePic(tS, t1)
