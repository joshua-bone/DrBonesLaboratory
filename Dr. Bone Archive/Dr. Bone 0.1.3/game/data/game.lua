GameCamera={x=0,y=0,z=8}                     --default camera settings

SetTitle("Dr. Bone's Laboratory"..version)

--constants
MAPPATH="/game/data/map.lua"
FLOORLEVEL=-.49 --floors of all kinds
BOTTOMLEVEL=-.48 --buttons
CENTERLEVEL=-.47 --pickups
TOPLEVEL=-.46 --blocks, monsters, player



dofile("game/data/directory.lua")
dofile("game/data/functions.lua")
dofile("game/data/datastructs.lua")  
dofile("game/data/gamestates.lua")      

WD=getcwd().."/"
print("Begin")


PrintOn=print                     -- save the current print function
PrintOff=function() end           -- create a null print function
--print=PrintOff                    -- printing off by default
print=PrintOn

-- init the graphics on loading
glShadeModel(GL_SMOOTH)		-- Enable Smooth Shading
glClearColor(0,0,0,0)		-- Black Background
glClearDepth(1)			-- Depth Buffer Setup
glEnable(GL_DEPTH_TEST)		-- Enables Depth Testing
glDepthFunc(GL_LEQUAL)			-- The Type Of Depth Testing To Do
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)	-- Really Nice Perspective Calculations
glLightfv(GL_LIGHT1, GL_AMBIENT,  1/2, 1/2, 1/2, 1.0);  -- Ambient Light Values
glLightfv(GL_LIGHT1, GL_DIFFUSE,  1, 1, 1, 1.0);  -- Diffuse Light Values
glLightfv(GL_LIGHT1, GL_POSITION,  -1.0, 1.0, 1.0, 0);   -- Light direction
--glLightfv(GL_LIGHT1, GL_SPECULAR,  -1.0, 1.0, 1.0, 0);   -- Light direction
glEnable(GL_LIGHT1)
glEnable(GL_COLOR_MATERIAL)
glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE)

FileName="Untitled"

LoadObject(default_objects[1])
LoadObject(default_objects[2])
Parts.left.item=library["f52413b1-9bf7-463e-9e60-84794fafef1a"]    -- wall
Parts.right.item=library["9a41f5ef-e6a2-405d-9416-113b927d0659"]   -- floor
Parts.left.Render=RenderEditPart
Parts.right.Render=RenderEditPart
Parts.left.Measure=MeasureEditPart
Parts.right.Measure=MeasureEditPart

event=0
tick=0

menu.Start()
screen={width=20,height=0}

