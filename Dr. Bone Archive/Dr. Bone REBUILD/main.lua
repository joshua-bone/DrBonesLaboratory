print("66"-"44")
BCOL="white20" --background color
TEXTBOXCOLOR="black"
TEXTBOXBORDERSIZE=0.2
HUDZVAL=-50 --default z value for hud rendering
MAXPLAYERNAME=24 --max player name length
MENULISTSIZE=30 --entries displayed in a menu list
SCREENMARGIN=0.5 --margin between edge of screen and hud text
TCOLOR="yellow" --default text color
FLOORLEVEL=-.5 --floors of all kinds
BOTTOMLEVEL=-.499 --buttons
CENTERLEVEL=-.498 --pickups
TOPLEVEL=-.497 --blocks, monsters, player


--known issue: we're rendering EVERYTHING in the level.
--this could slow things down a LOT
--see grL.RenderMap()


version=" 0.0.0"

print("Begin")

ObjLib=nil       --global, holds all game objects, index by name
ObjDirectory=nil --global, used to build ObjLib & for ordering the gsParts gamestate
Player=nil 		 --global, will be used throughout to keep track of current player account
Level=nil  		 --global, will point to currently loaded level
Map=nil    		 --global, will point to in-play version of the currently loaded level map
gs=nil     		 --global, will always point to the current gamestate
this=nil   		 --global, used for code clarity when loading and coding game objects
Pending=nil  	 --global, store objects that need to do logic this tick
Complete=nil 	 --global, store objects that have already done logic this tick

--load useful functions
dofile("data/functions.lua")

--interface with the user and the main program
dofile("data/interface.lua")

--init the graphics
dofile("data/graphics.lua")

--init the gamestates
dofile("data/gsMenu.lua")
dofile("data/gsParts.lua")
dofile("data/gsEditor.lua")


--makes an ObjDirectory, still need to make an ObjLib by loading objects
dofile("data/ObjDirectory.lua")
fxL.LoadObjects() --makes an ObjLib

--start the gamestate
gsMenu.Start()