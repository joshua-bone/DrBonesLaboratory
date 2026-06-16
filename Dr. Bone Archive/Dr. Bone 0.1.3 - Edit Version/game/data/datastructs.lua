--DATA STRUCTURES

mouse={}
mousemap={}
crosshair={x=0,y=0}

keynames={}
keynames[8]="BACKSPACE"
keynames[9]="TAB"
keynames[13]="ENTER"
keynames[16]="SHIFT"
keynames[17]="CTRL"
keynames[27]="ESC"
keynames[112]="F1"
keynames[113]="F2"
keynames[114]="F3"
keynames[115]="F4"
keynames[116]="F5"
keynames[117]="F6"
keynames[118]="F7"
keynames[119]="F8"
keynames[120]="F9"
keynames[121]="F10"
keynames[122]="F11"
keynames[123]="F12"
keynames[38]="UP"
keynames[40]="DOWN"
keynames[37]="LEFT"
keynames[39]="RIGHT"
keynames[187]="PLUS"
keynames[189]="MINUS"
keynames[65]="A"
keynames[90]="Z"

library={}                        -- where the library versions get loaded
Globals={}                        -- global storage indexed by guid

dirs={N=0,W=90,S=180,E=270}
dirs[0]="N"
dirs[90]="W"
dirs[180]="S"
dirs[270]="E"

colors={
  black={0,0,0},
  red={1,0,0},
  green={0,1,0},
  yellow={1,1,0},
  blue={0,0,1},
  magenta={1,0,1},
  cyan={0,1,1},
  white={1,1,1},
  lgray={3/4,3/4,3/4},
  gray={1/2,1/2,1/2},
  dgray={1/8,1/8,1/8},
  orange={1,1/3,0},
  _brown={1,3/4,1/2},
  brown={6/16,3/16,0}
}

mousemap={x=0,y=0}

HudInventory={Render=RenderInventory,Measure=MeasureInventory}

-- set default paint brushes
default_objects={
{g="9a41f5ef-e6a2-405d-9416-113b927d0659"},  --floor.lua
{g="f52413b1-9bf7-463e-9e60-84794fafef1a"},  --wall.lua
}

MapObjects={}



Pending={}  -- objects that still need to be processed this gameframe
Complete={} -- objects that have been processed, and will become pending next frame
Inactive={} -- objects that have been put to sleep, and will not become pending next frame

vectors={}  -- a translation array of direction to vector
vectors[0]={dx=0,dy=-1}
vectors[180]={dx=0,dy=1}
vectors[270]={dx=1,dy=0}
vectors[90]={dx=-1,dy=0}


-- write a data structure of numbers, tables, booleans and strings to a file
-- level is used to add new line characters for easier formatting
writers={}
--[[writers.list=function(file,value,level) -- helps replay
  file:write("{")
  local j,i=0
  for i=1,#value do 
    file:write(value[i]..",")
    j=j+1 if j==60 then file:write("\n") j=0 end
  end
  file:write("}")
end]]
writers.boolean=function(file,value,level) if value then file:write("true") else file:write("false") end end
writers.string=function(file,value,level) file:write('"'..value..'"') end  -- assume no double quotes in strings
writers.number=function(file,value,level) file:write(tostring(value)) end
writers.table=function(file,value,level)
  if level==3 then file:write("\n") end   -- formats the map
  file:write("{")
  local first=true
  for key,item in pairs(value) do
    if first then first=false else file:write(",") end
    local fnc=writers[type(item)]
    if fnc~=nil then
      if level==1 and type(key)~="number" then file:write("\n") end  -- format the highest level
      if type(key)~="number" then file:write(key.."=") end
      if writers[key]==nil then key=type(item) end -- custom writers
      writers[key](file,item,level+1)
    end
  end
  c=true
  file:write("}")
end

--------------------------------------------------------------------------
-- debug tool: dumpit("variable name",variable) to dump values and tables--
dumpit={}
dumpit.boolean=function(name,value) if value==true then print(name.."=true") else print(name.."=false") end end
dumpit.number=function(name,value) print(name.."="..value) end
dumpit.string=function(name,value) print(name.."='"..value.."'") end
dumpit.default=function(name,value) print(name.."=(#"..type(value).."#)") end
dumpit["function"]=function(name,value) print(name.."=function()") end
dumpit.key={}
dumpit.key.string=function(name,key,value) dumpit.dump(name.."."..key,value) end
dumpit.key.number=function(name,key,value) dumpit.dump(name.."["..key.."]",value) end
dumpit.key.default=function(name,key,value) dumpit.dump(name.."[(#"..type(key).."#)]",value) end
dumpit.table=function(name,value)
  if value[dumpit]==true then return end -- lock out recursion
  value[dumpit]=true
  local key,item
  for key,item in pairs(value) do
    if key~=dumpit then -- hide this function
      local k=type(key) if dumpit.key[k]==nil then k="default" end
      dumpit.key[k](name,key,item)
    end
  end
  value[dumpit]=nil
end
dumpit.dump=function(name,value) local t=type(value) if dumpit[t]==nil then t="default" end dumpit[t](name,value) end

-------------------- death types --------------------
death={explode={},sink={},shrink={}}

death.explode.vectors={
{-.375,-.375,.375},{-.125,-.375,.375},{.125,-.375,.375},{.375,-.375,.375},
{-.375,-.125,.375},{-.125,-.125,.375},{.125,-.125,.375},{.375,-.125,.375},
{-.375,.125,.375},{-.125,.125,.375},{.125,.125,.375},{.375,.125,.375},
{-.375,.375,.375},{-.125,.375,.375},{.125,.375,.375},{.375,.375,.375},
}

death.explode.render=function(this,h)
  local i
  local time=tick-this.deathtick
  local s=time*(1/(this.deathduration/3))
  local b=.5-(time*(1/(this.deathduration*2)))
  for i=1,#death.explode.vectors do
    local v=death.explode.vectors[i]
    glPushMatrix()  -- save the matrix because we are going to modify it
    glTranslatef(v[1]*s,v[2]*s,v[3]*s)  -- offset from middle of square
    glScalef(b,b,b)
    this:deathrendersave(h)
    glPopMatrix()                             -- restore the matrix
  end
end

death.sink.render=function(this,h)
  local time=tick-this.deathtick
  local s=time/this.deathduration
  glPushMatrix()  -- save the matrix because we are going to modify it
  glTranslatef(0,0,-s)
  this:deathrendersave(h)
  glPopMatrix()                             -- restore the matrix
end

death.shrink.render=function(this,h)
  local time=tick-this.deathtick
  local s=1-(time/this.deathduration)
  glPushMatrix()  -- save the matrix because we are going to modify it
  glScalef(s,s,s)
  this:deathrendersave(h)
  glPopMatrix()                             -- restore the matrix
end

-- Experimental for removing
death.logic=function(this,event)
  local time=tick-this.deathtick
  MoveToList(this,Complete)                         -- we are done
  if time>this.deathduration then
    RemoveFromGame(this)	  -- remove object
  end
end

death.start=function(obj,type,duration,message)
  obj.deathmessage=message
  obj.deathduration=duration
  obj.deathtick=tick
  obj.deathrendersave=obj.Render
  obj.TestEnter=nil
  obj.TestExit=nil
  obj.TestEnter2=nil
  obj.TestExit2=nil
  obj.StartEnter=nil
  obj.StartExit=nil
  obj.FinishEnter=nil
  obj.FinishExit=nil
  obj.guid=nil
  if death[type]~=nil then
    obj.logic=death.logic
    obj.Render=death[type].render
    MoveToList(obj,Complete)          -- wake it up
    return
  end
  RemoveFromGame(obj)	  -- remove object
end
