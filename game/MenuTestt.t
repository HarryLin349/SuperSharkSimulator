var input : array char of boolean
var prev : array char of boolean
var keyDown : boolean
loop
    Input.KeyDown (input)
    if input(KEY_UP_ARROW) then
	keyDown := true
    else
	keyDown := false
    end if
    if keyDown = false and prev(KEY_UP_ARROW) then
	put "Up Released" ..
    end if
    prev := input
end loop
