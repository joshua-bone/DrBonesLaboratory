GameCamera={x=0,y=0,z=10}                     --default camera settings

SetTitle("Dr. Bone's Laboratory"..version)

--constants
MAPPATH="/game/data/map.lua"
BKMAPPATH="/game/data/bkmap.lua"
MAXSTR=30 --Max horizontal string length for hints, map names etc
MAXHINT=8 --Max #of rows allowed for a hint
FLOORLEVEL=-.49 --floors of all kinds
BOTTOMLEVEL=-.48 --buttons
CENTERLEVEL=-.47 --pickups
TOPLEVEL=-.46 --blocks, monsters, player
MAXVOLUME=10000 --maximum volume allowed for a level of dimensions x*y*z (10000 is enough for a 100x100x1 or a 32x32x9)
MAXTIME=999 --maximum time limit
TEXTSIZE=19--larger number->smaller text
BKGDCOLOR="black" --background color
TCOLOR="cyan"  --default text color
NMTCOLOR="yellow"  --clickable text color, mouse not over text
MTCOLOR="green" --clickable text color, mouse over text
WTCOLOR="red"  --warning text color
STCOLOR="magenta" --special message text color
MAXSCORE=99999 --maximum score allowed for a level
LISTNUM=5 --maximum entries displayed in a menu list

--global objects referenced by multiple gamestates
--displayed here for bookkeeping purposes
level, bklevel=nil,nil
map, bkmap=nil,nil
tick, bktick=0,0
event, event2=0,0
CurrentAccount=nil

dofile("game/data/directory.lua")
dofile("game/data/functions.lua")
dofile("game/data/datastructs.lua")  
dofile("game/data/gamestates.lua") 
math.randomseed(os.time()) 

WD=getcwd().."/"
print("Begin")

PrintOn=print                     -- save the current print function
PrintOff=function() end           -- create a null print function
--print=PrintOff                    -- printing off by default
print=PrintOn

-- init the graphics on loading
glShadeModel(GL_SMOOTH)		-- Enable Smooth Shading

local x=colors[BKGDCOLOR][1]
local y=colors[BKGDCOLOR][2]
local z=colors[BKGDCOLOR][3]
glClearColor(x,y,z,0)		-- Set Background Color
x,y,z=nil,nil,nil
glClearDepth(1)			-- Depth Buffer Setup
glEnable(GL_DEPTH_TEST)		-- Enables Depth Testing
glDepthFunc(GL_LEQUAL)			-- The Type Of Depth Testing To Do
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)	-- Really Nice Perspective Calculations
--glLightfv(GL_LIGHT1, GL_AMBIENT,  1/2, 1/2, 1/2, 1.0);  -- Ambient Light Values
--glLightfv(GL_LIGHT1, GL_DIFFUSE,  1, 1, 1, 1.0);  -- Diffuse Light Values
--glLightfv(GL_LIGHT1, GL_POSITION,  -1.0, 1.0, 1.0, 0);   -- Light direction
--glLightfv(GL_LIGHT1, GL_SPECULAR,  -1.0, 1.0, 1.0, 0);   -- Light direction
--glEnable(GL_LIGHT1)
--glEnable(GL_COLOR_MATERIAL)
--glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE)

FileName="Untitled"

LoadObject(default_objects[1])
LoadObject(default_objects[2])
Parts.left.item=library["f52413b1-9bf7-463e-9e60-84794fafef1a"]    -- wall
Parts.right.item=library["9a41f5ef-e6a2-405d-9416-113b927d0659"]   -- floor
Parts.left.Render=RenderEditPart
Parts.right.Render=RenderEditPart
Parts.left.Measure=MeasureEditPart
Parts.right.Measure=MeasureEditPart

Parts.Start(1) --initializes all game elements
SelectPlayer.Start()

screen={width=20,height=0}

