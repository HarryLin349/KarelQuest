import Ladder in "Ladder.cla", Barrel in "Barrel.cla"

var barrel1 : ^Barrel
new barrel1
var gameTick : int := 1

var spark1 : int := Pic.FileNew ("Barrel1.bmp")
var spark2 : int := Pic.FileNew ("Barrel2.bmp")
var spark3 : int := Pic.FileNew ("Barrel3.bmp")
var spark4 : int := Pic.FileNew ("Barrel4.bmp")
var spark5 : int := Pic.FileNew ("Barrel5.bmp")
var spark6 : int := Pic.FileNew ("Barrel6.bmp")

^barrel1.setPosition(600,600)

setscreen ("graphics:1800;900")%PURGE
loop
    ^barrel1.draw
    ^barrel1.move
    gameTick += 1
    if gameTick mod 5 = 0 then
	^barrel1.nextFrame
    end if

    if gameTick = 45 then
	^barrel1.randDirection
    end if

    if gameTick > 60 then
	gameTick := 1
    end if
    Time.Delay (20)
end loop
