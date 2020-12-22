%Import and objects
import Ladder in "Ladder.cla", Barrel in "Barrel.cla"

%%%Setting Screen
View.Set ("offscreenonly")
setscreen ("graphics:1800;900")

%%%OPTIONS VARIABLES
var musicOn : boolean := true %these two control music and FX
var fxOn : boolean := true
var hardMode : boolean := false % turns on hard mode
var restart : boolean := false % if true, restarts back to the menu.

%SETTING UP THE SCOREBOARD
var names : array 1 .. 5 of string % array of player names
var scores : array 1 .. 5 of int % array of high scores
var userName : string % current player's name (get)
var counter : int := 0 % used to iterate through score array
var stream1 : int
var stream2 : int
var arcadefont := Font.New ("ArcadeClassic:22")
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
%%---------------------------------------------------------------LADDERS!!!!
var ladders : array 1 .. 13 of ^Ladder % array of ladder objects
var ladderX : array 1 .. 13 of int := init (700, 300, 710, 560, 485, 145, 1600, 1350, 1100, 1700, 1660, 1400, 1300)
var ladderY : array 1 .. 13 of int := init (172, 368, 558, 368, 172, 558, 172, 172, 368, 368, 558, 558, 558)
%above are the coordinate pairs

for i : 1 .. upper (ladders) % init for all ladders
    new ladders (i)
    ^ (ladders (i)).setPosition (ladderX (i), ladderY (i))
end for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var barrels : array 1 .. 10 of ^Barrel

for i : 1 .. upper (barrels)
    new barrels (i)
end for

%GAME VARIABLES
var gameTick : int := 1 % Think of this as frame #. Used in some math and patterns.
var alternate : boolean := true % used for karel
var playing : boolean := true %if the music should play
var startMusic : boolean := false % starts the bg music
var isVuln : boolean := true % allows player to be hit.
var hasTreat : boolean := false
var delayNum : int := 20

var vulnTimer : int := 60
var score : int := 0
var lives : int := 3
var user_input : array char of boolean
var direction : string := ""
var posx : int := 100
var posy : int := 150
var gLevel : int := 150
var gLevels : array 1 .. 4 of int := init (150, 350, 540, 730)
var gLevelNow : int := 150
var gLevelPrev : int := 150


var onGround : boolean := false
var onLadder : boolean := false
var canTeleport : boolean := false % lets players teleport
var canMove : boolean := false % Freezes player at the very start of the game
var velocity : int := 0 %players Y velocity
var gravity : int := -1 % Gravity level.
var floaty : int := posy %Used for the "floating" animation when on ground
var offset : real := 0
var jumpVal : int := 12
var sparkFrame : int := 1 %frame control of the spark obstacle
var dx : int := 4
var dUp : int := 5
var dDown : int := 7


var mouseX : int % Mouse controls
var mouseY : int
var dummy1 : int
var dummy2 : int

var barrelnum : int := 1

var powerUpX : array 1 .. 3 of int := init (150, 420, 1065)
var powerUpY : array 1 .. 3 of int := init (170, 370, 560)
var powX : int
var powY : int
var powerUpActive : boolean := true
var currentPowerUp : string
var pChooser : int


%%Sprite Setup==============================
%Pics
var IdleR : int := Pic.FileNew ("IdleR.bmp") %PLAYER
var IdleL : int := Pic.FileNew ("IdleL.bmp")
var JumpR : int := Pic.FileNew ("JumpR.bmp")
var JumpL : int := Pic.FileNew ("JumpL.bmp")
var FallR : int := Pic.FileNew ("FallR.bmp")
var FallL : int := Pic.FileNew ("FallL.bmp")
var Flash : int := Pic.FileNew ("Flash.bmp")
var death1 : int := Pic.FileNew ("Death1.bmp") %death animation pics
var death2 : int := Pic.FileNew ("Death2.bmp")
var death3 : int := Pic.FileNew ("Death3.bmp")
var death4 : int := Pic.FileNew ("Death4.bmp")
var death5 : int := Pic.FileNew ("Death5.bmp")
var death6 : int := Pic.FileNew ("Death6.bmp")

var BG : int := Pic.FileNew ("Background.bmp") %BG

var spark1 : int := Pic.FileNew ("Barrel1.bmp") % Spark frames (animated)
var spark2 : int := Pic.FileNew ("Barrel2.bmp") % For some reason...
var spark3 : int := Pic.FileNew ("Barrel3.bmp") % Arrays don't work with
var spark4 : int := Pic.FileNew ("Barrel4.bmp") % Pictures... :((((
var spark5 : int := Pic.FileNew ("Barrel5.bmp")
var spark6 : int := Pic.FileNew ("Barrel6.bmp")

var teleON : int := Pic.FileNew ("TeleporterON.bmp") % teleporter on/off
var teleOFF : int := Pic.FileNew ("TeleporterOFF.bmp")

var pLadder : int := Pic.FileNew ("Ladder.bmp") % loads in ladder picture
var bLadder : int := Pic.FileNew ("BrokenLadder.bmp") % loads in broken ladder picture

var karel1 : int := Pic.FileNew ("Karel1.bmp")
var karel2 : int := Pic.FileNew ("Karel2.bmp")
var karelLove : int := Pic.FileNew ("Karel3.bmp")

var treatFull : int := Pic.FileNew ("Treats1.bmp")
var treatEmpty : int := Pic.FileNew ("Treats2.bmp")
var treatIcon : int := Pic.FileNew ("TreatIcon.bmp")

var star : int := Pic.FileNew ("Invincible.bmp")
var speedUp : int := Pic.FileNew ("SpeedUp.bmp")
var ladderUp : int := Pic.FileNew ("LadderUp.bmp")
%Sprites-------------------------------------
var PlayerSprite : int := Sprite.New (IdleR)

var teleporter1 : int := Sprite.New (teleON)

var teleporter2 : int := Sprite.New (teleON)

var karel : int := Sprite.New (karel1)

var treats : int := Sprite.New (treatFull)

var trIcon : int := Sprite.New (treatIcon)

var sPower : int := Sprite.New (speedUp)

proc spriteSetup
    Sprite.Show (PlayerSprite)
    Sprite.SetHeight (PlayerSprite, 1)

    Sprite.Show (teleporter1)
    Sprite.SetHeight (teleporter1, 0)

    Sprite.Show (teleporter2)
    Sprite.SetHeight (teleporter2, 0)

    Sprite.Show (karel)
    Sprite.SetHeight (karel, 0)
    Sprite.SetPosition (karel, 100, 130, true)

    Sprite.Show (treats)
    Sprite.SetHeight (treats, 0)
    Sprite.SetPosition (treats, 1700, 725, true)

    Sprite.SetPosition (trIcon, 1700, 875, true)
end spriteSetup

proc spriteHider
    Sprite.SetPosition (PlayerSprite, 2000, 2000, true)
    Sprite.SetPosition (teleporter1, 2000, 2000, true)
    Sprite.SetPosition (teleporter2, 2000, 2000, true)
    Sprite.SetPosition (karel, 2000, 2000, true)
    Sprite.SetPosition (treats, 2000, 2000, true)
    Sprite.SetPosition (sPower, 2000, 2000, true)

    for i : 1 .. upper (barrels)
	^ (barrels (i)).setPosition (2000, 2000)
    end for
    cls
end spriteHider
%=========================MUSIC-
process introPlay % call at beginning to play intro
    Music.PlayFile ("DKIntro.mp3")
    startMusic := true
end introPlay

process BGPlay %BG music.
    loop
	if startMusic then
	    Music.PlayFile ("DKmusic.mp3")
	end if
    end loop
end BGPlay

process pauseMusic % call via fork to stop all music playing
    loop
	if playing = false then
	    Music.PlayFileStop
	    playing := true
	end if
    end loop
end pauseMusic

process deathMusic
    Music.PlayFile ("DKDeath.mp3")
end deathMusic

process pointMusic
    Music.PlayFile ("DKPoints.wav")
end pointMusic

%%==============================================FUNCTIONS AND PROCEDURES
process makeVulnerable (t : int)
    vulnTimer := t
    var altShow : boolean := true
    loop
	vulnTimer -= 1
	if vulnTimer mod 3 = 0 then
	    altShow := not altShow
	end if
	if altShow then
	    Sprite.Show (PlayerSprite)
	else
	    Sprite.Hide (PlayerSprite)
	end if
	delay (delayNum)
	exit when vulnTimer < 1
    end loop
    isVuln := true
    Sprite.Show (PlayerSprite)
end makeVulnerable

function distanceFrom (x1, y1, x2, y2 : int) : int % distance fucntion.
    result round (sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2))
end distanceFrom


%%%MOVE PROCEDURE. ONLY FOR RIGHT LEFT. ALWAYS ACTIVE

procedure move ()
    %screen boundaries: 35, 815, 985, 1765, use OR to check
    Input.KeyDown (user_input) % Gets User Input
    if onLadder then
	if user_input (KEY_UP_ARROW) then
	    posy += dUp
	elsif user_input (KEY_DOWN_ARROW) then
	    posy -= dDown
	end if
    else
	if user_input (KEY_RIGHT_ARROW) and (posx < 812 or (posx > 815 and posx < 1765)) then %Collider test
	    posx += dx
	    direction := "R"
	elsif user_input (KEY_LEFT_ARROW) and ((posx > 35 and posx < 820) or posx > 985) then
	    posx -= dx
	    direction := "L"
	elsif user_input (KEY_ESC) then
	    get c
	elsif user_input ('q') then
	    lives := 0
	end if

	if onGround then
	    if direction = "R" then
		Sprite.ChangePic (PlayerSprite, IdleR)
	    else
		Sprite.ChangePic (PlayerSprite, IdleL)
	    end if
	elsif velocity > 0 then
	    if direction = "R" then
		Sprite.ChangePic (PlayerSprite, JumpR)
	    else
		Sprite.ChangePic (PlayerSprite, JumpL)
	    end if
	else
	    if direction = "R" then
		Sprite.ChangePic (PlayerSprite, FallR)
	    else
		Sprite.ChangePic (PlayerSprite, FallL)
	    end if
	end if
    end if
end move

%%%JUMP PROCEDURE. IF PLAYER IS ON THE GROUND, THEY CAN JUMP
procedure jump ()
    Input.KeyDown (user_input)
    if user_input (KEY_SHIFT) and onGround and onLadder = false then
	velocity := jumpVal
	posy += velocity
	onGround := false
    end if
end jump

%%%FALL PROCEDURE
proc fall ()
    if posy > gLevelNow and onLadder = false then
	onGround := false
    end if
    if onGround = false then %Falling
	posy += velocity
	velocity += gravity
    else
	velocity := 0
    end if
end fall


%%%CHECKING IF ON GROUND PROCEDURE
procedure grounder ()
    for i : 1 .. upper (gLevels)
	if ((posy + velocity) - gLevels (i)) <= 0 and gLevels (i) <= posy then   % Checks if player will be on or below the ground next frame, and puts them on the ground if so
	    onGround := true
	    posy := gLevels (i)
	    gLevelNow := gLevels (i)
	    if i = 1 then
		gLevelPrev := 150
	    else
		gLevelPrev := gLevels (i - 1)
	    end if
	end if
	if posy < gLevelNow then
	    gLevelNow := gLevelPrev
	end if
    end for

end grounder
%%%CHECKING IF ON LADDER

procedure isOnLadder (l : ^Ladder)
    Input.KeyDown (user_input)
    if ^l.canClimb (posx, posy) then
	if user_input (KEY_UP_ARROW) then
	    if posy - ^l.getY > 180 then
		onLadder := false
	    else
		onLadder := true
	    end if
	elsif user_input (KEY_DOWN_ARROW) and posy > ^l.getY then
	    onLadder := true
	end if
	if posy < gLevelPrev then
	    onLadder := false
	    posy := gLevelPrev
	end if
	if user_input (KEY_DOWN_ARROW) and posy < ^l.getY then
	    onLadder := false
	end if
	if posy - ^l.getY > 180 then
	    onLadder := false
	end if
    else
	onLadder := false
    end if
end isOnLadder

proc deathAnimation
    Sprite.ChangePic (PlayerSprite, death1)
    delay (400)
    Sprite.ChangePic (PlayerSprite, death2)
    delay (400)
    Sprite.ChangePic (PlayerSprite, death3)
    delay (400)
    Sprite.ChangePic (PlayerSprite, death4)
    delay (400)
    Sprite.ChangePic (PlayerSprite, death5)
    delay (400)
    Sprite.ChangePic (PlayerSprite, death6)
    delay (1800)
end deathAnimation


proc death
    playing := false
    playing := true
    lives -= 1
    dx := 4
    dUp := 5
    dDown := 7
    if musicOn then
	fork deathMusic
    end if
    deathAnimation
    delay (10)
    posx := 100
    posy := 150
    onLadder := false
    playing := true
end death

%Draws all the barrels and moves/animates the active ones when necessary
proc drawBarrels
    if lives > 0 then
	for i : 1 .. upper (barrels)
	    if ^ (barrels (i)).getState then
		^ (barrels (i)).draw
		^ (barrels (i)).move
		if gameTick mod 5 = 0 then
		    ^ (barrels (i)).nextFrame
		end if
	    end if
	end for
    end if
end drawBarrels

proc barrelRandomizer (b : ^Barrel) %will set a barrel to respawn at a random side.
    if Rand.Int (1, 2) = 1 then
	^b.setPosition (120, 750)
	^b.setDirection ("Down")
	^b.faller
	^b.setSide (0)
	^b.setScore (false)
    else
	^b.setPosition (1040, 750)
	^b.setDirection ("Down")
	^b.faller
	^b.setSide (1)
	^b.setScore (false)
    end if
end barrelRandomizer

proc barrelLogic
    for i : 1 .. upper (barrels)
	if ^ (barrels (i)).getState then % If the barrel is "active"
	    if distanceFrom ( ^ (barrels (i)).getX, ^ (barrels (i)).getY, posx, posy) < 50 and isVuln then
		death
		isVuln := false
		fork makeVulnerable (60)
	    elsif posx - ^ (barrels (i)).getX < 24 and posx - ^ (barrels (i)).getX > -24 then
		if posy - ^ (barrels (i)).getY > 30 and posy - ^ (barrels (i)).getY < 180 then
		    if ^ (barrels (i)).scoredOn = false then
			if fxOn then
			    fork pointMusic
			end if
			score += 100
			^ (barrels (i)).setScore (true)
		    end if
		end if
	    end if

	    for j : 1 .. upper (gLevels) % checks if the barrel is on the ground, and if so, starts moving it left or right
		if ^ (barrels (i)).onGround = false then
		    if ^ (barrels (i)).getY - gLevels (j) + 30 < 1 and ^ (barrels (i)).getY - gLevels (j) + 30 > -6 and ^ (barrels (i)).onThingy = false then
			^ (barrels (i)).randDirection
			^ (barrels (i)).grounder
		    end if
		end if
	    end for

	    if ^ (barrels (i)).side = 0 then %COllision detectors for either the right or left side.
		if (( ^ (barrels (i)).getX < 35) or ( ^ (barrels (i)).getX > 815)) then
		    % checks if the barrel is colliding with a wall as inLS or inRS
		    ^ (barrels (i)).reverseDirection
		    if ( ^ (barrels (i)).getX < 40) and ( ^ (barrels (i)).getY < 150) then
			barrelRandomizer (barrels (i)) %teleports to top of a side
		    end if
		end if
	    else
		if (( ^ (barrels (i)).getX < 985) or ( ^ (barrels (i)).getX > 1765)) then
		    ^ (barrels (i)).reverseDirection
		    if ( ^ (barrels (i)).getX < 1000) and ( ^ (barrels (i)).getY < 150) then
			barrelRandomizer (barrels (i))
		    end if
		end if
	    end if


	    for k : 1 .. upper (ladders) %Checks to see if a barrel can go down a ladder, then randomly decides if it wants to
		if ( ^ (ladders (k)).canAccess ( ^ (barrels (i)).getX, ^ (barrels (i)).getY)) then
		    if gameTick mod 5 = 0 then
			^ (barrels (i)).goDown
			^ (barrels (i)).faller
			^ (barrels (i)).onThing
		    end if
		else
		    ^ (barrels (i)).offThing
		end if
	    end for
	end if
    end for
    if lives = 0 then
	for i : 1 .. upper (barrels)
	    ^ (barrels (i)).disable
	end for
    end if
end barrelLogic

proc barrelActivator
    if gameTick = 1 then
	^ (barrels (barrelnum)).activate
	barrelnum += 1
	if barrelnum > upper (barrels) then
	    barrelnum := 1
	end if
    end if
end barrelActivator

%Procedure Teleport
% COORDS : 275 722 <---> 1040 190

proc teleporter (px, py : int)
    if canTeleport then
	if py > 720 then
	    if px - 275 < 20 and px - 275 > -20 then
		Sprite.ChangePic (PlayerSprite, Flash)
		Time.Delay (90)
		posx := 1040
		posy := 190
		Sprite.SetPosition (PlayerSprite, posx, posy, true)
		Sprite.ChangePic (PlayerSprite, Flash)
		Time.Delay (180)
		onGround := false
		canTeleport := false
		isVuln := false
		fork makeVulnerable (60)
	    end if
	elsif py < 190 then
	    if px - 1040 < 20 and px - 1040 > -20 then
		Sprite.ChangePic (PlayerSprite, Flash)
		Time.Delay (90)
		posx := 275
		posy := 740
		Sprite.SetPosition (PlayerSprite, posx, posy, true)
		Sprite.ChangePic (PlayerSprite, Flash)
		Time.Delay (180)
		onGround := false
		canTeleport := false
		isVuln := false
		fork makeVulnerable (60)
	    end if
	end if
    end if

    if distanceFrom (px, py, 275, 725) > 100 and distanceFrom (px, py, 1050, 190) > 100 then
	canTeleport := true
    end if
end teleporter

proc teleportDrawer
    if canTeleport = false then
	Sprite.ChangePic (teleporter1, teleOFF)
	Sprite.ChangePic (teleporter2, teleOFF)
    else
	Sprite.ChangePic (teleporter1, teleON)
	Sprite.ChangePic (teleporter2, teleON)
    end if
    Sprite.SetPosition (teleporter1, 275, 735, true)
    Sprite.SetPosition (teleporter2, 1040, 155, true)
end teleportDrawer

proc ladderDrawing ()
    for i : 1 .. 13
	if ^ (ladders (i)).isBroken then
	    Pic.Draw (bLadder, ladderX (i) - 24, ladderY (i) - 72, 2)
	else
	    Pic.Draw (pLadder, ladderX (i) - 24, ladderY (i) - 72, 2)
	end if
    end for
end ladderDrawing

procedure karelDrawing
    if distanceFrom (posx, posy, 100, 130) < 40 then
	if hasTreat then
	    Sprite.ChangePic (karel, karelLove)
	    Sprite.ChangePic (treats, treatFull)
	    hasTreat := false
	    Sprite.Hide (trIcon)
	    score += 10000
	    if fxOn then
		fork pointMusic
	    end if
	end if
    else
	if gameTick mod 10 = 0 then
	    alternate := not alternate
	    if alternate then
		Sprite.ChangePic (karel, karel1)
	    else
		Sprite.ChangePic (karel, karel2)
	    end if
	end if
    end if
end karelDrawing

procedure treatChecker
    if distanceFrom (posx, posy, 1700, 725) < 30 then
	Sprite.ChangePic (treats, treatEmpty)
	hasTreat := true
	Sprite.Show (trIcon)
	Sprite.ChangePic (karel, karelLove)
    end if
end treatChecker

proc powerUpSpawner
    if powerUpActive then
	powerUpActive := false
	powX := powerUpX (Rand.Int (1, 3))
	powY := powerUpY (Rand.Int (1, 3))
	Sprite.SetPosition (sPower, powX, powY, true)
	pChooser := Rand.Int (1, 3)
	if pChooser = 1 then
	    Sprite.ChangePic (sPower, speedUp)
	    currentPowerUp := "speedUp"
	elsif pChooser = 2 then
	    Sprite.ChangePic (sPower, ladderUp)
	    currentPowerUp := "ladderUp"
	else
	    Sprite.ChangePic (sPower, star)
	    currentPowerUp := "star"
	end if
	Sprite.Show (sPower)
    end if
end powerUpSpawner

proc powerEffect
    if distanceFrom (posx, posy, powX, powY) < 40 and powerUpActive = false then
	if currentPowerUp = "speedUp" and dx < 8 then
	    dx += 1
	elsif currentPowerUp = "ladderUp" and dUp < 9 then
	    dUp += 1
	    dDown += 1
	else
	    isVuln := false
	    fork makeVulnerable (300)
	end if
	powerUpActive := true
    end if
end powerEffect

procedure gameOver
    var ch : char
    var win2 : int := Window.Open ("graphics:600;800;nobuttonbar;")
    Window.Select (win2)
    Draw.Text ("GAME OVER", maxx div 2 - length ("GAME OVER") * 8, 700, arcadefont, black)
    delay (100)
    Draw.Text ("SCORE:  " + intstr (score), maxx div 3, 650, arcadefont, black)
    delay (100)
    Draw.Text ("ENTER YOUR NAME:", maxx div 2 - length ("ENTER YOUR NAME:") * 8, 100, arcadefont, black)
    delay (100)
    locatexy (maxx div 2, 50)
    get userName
    sortList
    addList (userName, score)
    updateList
    printList
    close: stream1
    close: stream2
    Draw.Text ("PRESS ENTER TO EXIT", maxx div 2 - length ("PRESS ENTER TO EXIT") * 8, 50, arcadefont, black)
    get ch
    Window.Close (win2)
    restart := true
end gameOver

procedure game (mode : int)
    lives := 3
    powerUpActive := true
    for i : 1 .. upper (barrels)
	if Rand.Int (1, 2) = 1 then
	    ^ (barrels (i)).setPosition (70, 750)
	    ^ (barrels (i)).setSide (0) % 0 represents left
	else
	    ^ (barrels (i)).setPosition (1040, 750)
	    ^ (barrels (i)).setSide (1) % 1 represents right
	end if
	^ (barrels (i)).disable
	^ (barrels (i)).faller
	^ (barrels (i)).setDirection("Down")
    end for
    
    delayNum := mode
    spriteSetup
    %**********GAME SETUP******************************
    Pic.Draw (BG, 0, 0, 0)
    ^ (ladders (4)).wreck
    ^ (ladders (5)).wreck
    ^ (ladders (6)).wreck

    ^ (ladders (9)).wreck
    ^ (ladders (11)).wreck
    ^ (ladders (13)).wreck

    %**********************************************************GAME LOOP****************************************************
    ladderDrawing ()
    lives := 3
    if musicOn then
	fork introPlay
	fork BGPlay
	fork pauseMusic
    end if
    loop
	%Floaty animation
	if onGround then
	    if gameTick < 30 then
		offset := 0.2 * (gameTick) - 3
	    else
		offset := 3 - 0.2 * (gameTick - 30)
	    end if
	    floaty := posy + round (offset)
	else
	    floaty := posy
	end if
	%%%%%DRAWING STUFF
	%BG: If you ever want to free up memory, put this outside the loop and get rid of CLS. Can't use put tho. Works cause sprites are only "moved", not drawn.

	Sprite.SetPosition (PlayerSprite, posx, floaty, true) % Draw the Player

	%%%%%%%%

	grounder ()

	for i : 1 .. upper (ladders)
	    if posx - ^ (ladders (i)).getX < 30 and posx - ^ (ladders (i)).getX > -30 then
		if posy - ^ (ladders (i)).getY < 210 and posy - ^ (ladders (i)).getY > -200 then
		    isOnLadder (ladders (i))
		end if
	    end if
	end for

	if canMove then
	    move ()
	end if
	jump ()
	fall ()
	teleporter (posx, posy)
	teleportDrawer
	drawBarrels
	barrelActivator
	karelDrawing
	treatChecker
	powerUpSpawner
	powerEffect
	barrelLogic

	gameTick += 1 %Gametick
	if gameTick > 60 then
	    gameTick := 1
	    canMove := true
	    if score > 0 then
		score -= 10
	    end if
	end if

	%DEV STUFF
	%locate (1, 1)
	Draw.FillBox (0, 900, 1800, 850, black)
	Draw.Text ("LIVES: " + intstr (lives) + "            " + "SCORE: " + intstr (score), 50, 860, arcadefont, white)
	%put "gameTick:", gameTick : 5, " X: ", posx, " Y: ", posy, " On Ladder: ", onLadder, " Mouse X: ", mouseX, " Mouse Y: ", mouseY, " barrel X: "
	%-- Next Frame
	Time.Delay (delayNum)
	View.Update
	%--
	exit when lives = 0
    end loop
    spriteHider
    playing := false
    musicOn := false
    cls
    gameOver
    musicOn := true
    restart := true
end game



%OPTIONS SETUP===================================================

var canInput : boolean := true %Puts a timer on inputs so the menu is easy to control
var inputTimer : int := 1 %increments until timer is lifted (at 8), then resets to 1
var turnOff : boolean := true %mus.playfilestop is very laggy so cannot be activated every frame

var exiter : boolean := false
var opCounter : int := 1 %keeps track of player cursor

var arrow : int := Pic.FileNew ("Arrow.bmp") %cursor img
var point : int := Sprite.New (arrow) % this is the player cursor

proc optionsSetup
    Sprite.Show (point)
    exiter := false
    opCounter := 1
end optionsSetup

proc cursorDraw

    Input.KeyDown (user_input)
    if canInput then
	if user_input (KEY_UP_ARROW) then
	    opCounter -= 1
	    canInput := false
	elsif user_input (KEY_DOWN_ARROW) then
	    opCounter += 1
	    canInput := false
	elsif user_input ('z') then
	    canInput := false
	    Draw.FillBox (0, 0, maxx, maxy, 58)
	    if opCounter = 1 then
		musicOn := not musicOn
	    elsif opCounter = 2 then
		fxOn := not fxOn
	    else
		hardMode := not hardMode
	    end if
	elsif user_input (KEY_SHIFT) then
	    exiter := true
	end if
    end if

    if opCounter = 1 then
	Sprite.SetPosition (point, 320, 715, true)
    elsif opCounter = 2 then
	Sprite.SetPosition (point, 320, 615, true)
    else
	Sprite.SetPosition (point, 320, 515, true)
    end if

    if opCounter < 1 then
	opCounter := 3
    elsif opCounter > 3 then
	opCounter := 1
    end if
end cursorDraw


proc optionsDrawer
    Draw.Text ("MUSIC: ", 400, 700, menuFont, white)
    if musicOn then
	Draw.Text ("ON", 800, 700, menuFont, white)
	turnOff := true
    else
	Draw.Text ("OFF", 800, 700, menuFont, white)
	if turnOff then
	    Music.PlayFileStop
	    turnOff := false
	end if
    end if
    Draw.Text ("SOUND FX: ", 400, 600, menuFont, white)
    if fxOn then
	Draw.Text ("ON", 800, 600, menuFont, white)
    else
	Draw.Text ("OFF", 800, 600, menuFont, white)
    end if

    Draw.Text ("DIFFICULTY: ", 400, 500, menuFont, white)

    if hardMode then
	Draw.Text ("HARD", 800, 500, menuFont, white)
    else
	Draw.Text ("EASY", 800, 500, menuFont, white)
    end if

    Draw.Text ("TIP: TRY DISABLING MUSIC AND SOUND TO BOOST PERFORMANCE.", maxx div 2 - length ("TIP: TRY DISABLING MUSIC AND SOUND TO BOOST PERFORMANCE.") * 8, 300, arcadefont, white)
    Draw.Text ("PRESS LSHIFT TO GET BACK TO THE MAIN MENU.", maxx div 2 - length ("PRESS LSHIFT TO GET BACK TO THE MAIN MENU.") * 12, 250, menuFont, white)
end optionsDrawer


proc options
    Draw.FillBox (0, 0, maxx, maxy, 58)
    optionsSetup
    loop
	optionsDrawer
	cursorDraw
	delay (10)

	if canInput = false then
	    inputTimer += 1
	    if inputTimer > 16 then
		inputTimer := 1
		canInput := true
	    end if
	end if

	exit when exiter = true
	restart := true
    end loop
    cls
end options

%%%%%%%%%%%%%%%%%%%%%%%%%

%%MENU SETUP=-----------------------------------------
var floaty2 : int := 560 %These are used to make the logo float up and down using linear algebra
var offset2 : real := 0
var dummychar : char

var menuBG : int := Pic.FileNew ("TitleCard.bmp") %Pictures. Loaded in to use for sprites.
var arcade : int := Pic.FileNew ("Arcade.bmp")
var how2play : int := Pic.FileNew ("HowToPlay.bmp")
var optionsPic : int := Pic.FileNew ("Options.bmp")
var logo : int := Pic.FileNew ("Logo.bmp")
var instructions : int := Pic.FileNew ("Instructions.bmp")

var image : int := Sprite.New (arcade) %sprites. this one is for the game mode image
var logoSprite : int := Sprite.New (logo) % this is the logo

var posCounter : int := 1 %keeps track of player cursor

process menuMusic % forking is necessary to play music - it pauses the program otherwise.
    loop
	if musicOn then
	    Music.PlayFile ("DKMenu.mp3")
	end if
    end loop
end menuMusic

proc menuSetup
    spriteHider
    Sprite.Show (image)
    Sprite.SetPosition (image, 433, 423, true)

    Sprite.Show (point)
    Sprite.Show (logoSprite)

    if musicOn then
	fork menuMusic
    else
	Music.PlayFileStop
    end if
    Pic.Draw (menuBG, 0, 0, 0)
end menuSetup

proc menuEnder
    Music.PlayFileStop
    Sprite.Hide (image)
    Sprite.Hide (point)
    Sprite.Hide (logoSprite)
end menuEnder

proc logoDrawer
    if gameTick < 30 then
	offset2 := 0.6 * (gameTick) - 10
    else
	offset2 := 10 - 0.6 * (gameTick - 30)
    end if
    floaty2 := 560 + round (offset2)
    Sprite.SetPosition (logoSprite, 1500, floaty2, true)
end logoDrawer

proc textDrawer
    Draw.Text ("START GAME", 1300, 340, menuFont, black)
    Draw.Text ("START GAME", 1300, 350, menuFont, white)

    Draw.Text ("HOW TO PLAY", 1300, 270, menuFont, black)
    Draw.Text ("HOW TO PLAY", 1300, 280, menuFont, white)

    Draw.Text ("OPTIONS", 1300, 190, menuFont, black)
    Draw.Text ("OPTIONS", 1300, 200, menuFont, white)
end textDrawer

proc imageDrawer
    if posCounter = 1 then
	Sprite.ChangePic (image, arcade)
	Sprite.SetPosition (point, 1250, 365, true)
    elsif posCounter = 2 then
	Sprite.ChangePic (image, how2play)
	Sprite.SetPosition (point, 1250, 295, true)
    else
	Sprite.ChangePic (image, optionsPic)
	Sprite.SetPosition (point, 1250, 215, true)
    end if
end imageDrawer

proc menu
    loop
	put "hello"
	var difficulty : int
	if hardMode then
	    difficulty := 15
	else
	    difficulty := 20
	end if
	menuSetup
	textDrawer
	loop
	    imageDrawer
	    logoDrawer

	    Input.KeyDown (user_input)

	    if canInput then
		if user_input (KEY_UP_ARROW) then
		    posCounter -= 1
		    canInput := false
		elsif user_input (KEY_DOWN_ARROW) then
		    posCounter += 1
		    canInput := false
		elsif user_input ('z') then
		    menuEnder
		    if posCounter = 1 then
			game (difficulty)
		    elsif posCounter = 2 then
			cls
			Pic.Draw (instructions, 0, 0, 0)
			get dummychar
			restart := true
			cls
		    else
			options
		    end if
		end if
	    end if

	    if posCounter < 1 then
		posCounter := 3
	    elsif posCounter > 3 then
		posCounter := 1
	    end if


	    gameTick += 1

	    if canInput = false then
		inputTimer += 1
		if inputTimer > 8 then
		    inputTimer := 1
		    canInput := true
		end if
	    end if

	    if gameTick > 60 then
		gameTick := 1
	    end if
	    delay (20)
	    exit when restart = true
	end loop
	if restart = true then
	    restart := false
	end if
    end loop
end menu

%%%%%%%%%%%%%%%'
menu
game (20)

/*code sandbox
 %    if posy + velocity < gLevel then     % Checks if player will be on or below the ground next frame, and puts them on the ground if so
 %        onGround := true
 %        posy := gLevel
 %    end if

 proc ladderDrawing ()
 for i : 1 .. upper (ladders)
 ^ (ladders (i)).setPosition (ladderX (i), ladderY (i))
 end for
 end ladderDrawing
 */
