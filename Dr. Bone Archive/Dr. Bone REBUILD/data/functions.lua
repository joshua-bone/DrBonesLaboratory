--functions library
fxL={}

-----------------------------------------------------
--datastructs in alphabetical order with descriptions
-----------------------------------------------------


-----------------------------------------------------
--functions in alphabetical order with descriptions
-----------------------------------------------------

fxL.AddObject=function(obj,x,y,z)
  obj.a, obj.i={},{}
  local cell=Map[x][y][z]
  if not cell then return end
  local w
  --remove conflicting objects
  local removes=obj.removes
  for w=#cell, 1, -1 do
    local deleted=false
	local existing=cell[w]
	local occupies=existing.occupies
	if occupies then
	  local j
	  for j=1,#occupies do
	    local i
		for i=1,#removes do
		  if occupies:byte(j)==removes:byte(i) then
		    fxL.ListRemove(cell, existing)
			deleted=true
		    break
		  end
		  if deleted then break end
		end
	  end
	end
  end
  
  --add in the new object
  local newobj=obj.copy(obj)
  table.insert(cell,newobj)
end

--returns a copy of a table
fxL.DeepCopy=function(orig)
  local copy
  if type(orig)=="table" then
    copy={}
	for key,val in pairs(orig) do
	  copy[key]=val
	end
  else
    copy=orig
  end
  return copy
end

--same as DeepCopy, but clones tables within the table, too. 
fxL.DeepDeepCopy = function(source) 
  local destination             --will result in stack overflow if source is large.
  if type(source)=="table" then
    destination={}
   local key,value
   for key,value in pairs(source) do
      if type(value)=="table" then
        destination[key]=fxL.DeepDeepCopy(value)
      else
        destination[key]=value
      end
    end
  else
    destination=source
  end
  return destination
end

fxL.GenerateGuid=function()
  local i
  local guid=""
  for i=1,8 do
    if i>=3 and i<=6 then guid=guid.."-" end
    guid = guid..string.format('%04x', math.random(2^16))
  end
  return guid
end

fxL.GenerateLevel=function(x,y,z)
  if not x then x=20 end
  if not y then y=20 end
  if not z then z=2 end
  local l={}
  l.author=Player.name
  l.authorguid=Player.guid
  l.date=os.date()
  l.atZ=1 --the z-level of the map that we are focused on
  l.objects={
   {ID="Floor"},
  }
  l.guid=fxL.GenerateGuid()
  l.title="New Level"
  l.time=0
  l.map={}
  local i,j,k
  for k=1,z do
    table.insert(l.map,{})
    for j=1,y do
	  table.insert(l.map[k],{})
	  for i=1,x do
	    table.insert(l.map[k][j],1)
	  end
	end
  end
  return l
end

fxL.InitMap=function(map)
  --local holdmap=Map --save the current Map 
  local w,x,y,z
  Pending={}
  Complete={}
  
  --call global initializations (affects all copies of an object)
  for w=1,#Level.objects do 
    local obj=ObjLib[Level.objects[w].ID]
	if obj.GlobalInit then obj:GlobalInit() end
  end
  
  --call local initializations (affects only this copy of an object)
  for x=1,#map do
    for y=1,#map[x] do
	  for z=1,#map[x][y] do
	    for w=1,#map[x][y][z] do
		  local obj=map[x][y][z][w]
		  obj.a={} --initialize attributes
		  obj.i={} --initialize inventory
		  if obj.LocalInit then obj:LocalInit(x,y,z) end
		end
	  end
	end
  end
end

fxL.ListRemove=function(list,obj)
  local z,l
  l=#list
  for z=1,l do
    if list[z]==obj then
      for z=z+1,l do
        list[z-1]=list[z]
      end
      list[l]=nil
      return
    end
  end
end

fxL.LoadObjects=function()
  ObjLib={}
  local i
  for i=1,#ObjDirectory do
    this={} --global, used for loading game objects
	--default copy fx returns same object
	this.copy=function(a) return a end 
	this.ID=ObjDirectory[i].ID
    dofile(ObjDirectory[i].f) --load object code into 'this'
	this:Load() --load object's graphics resources
	ObjLib[this.ID]=this
  end
end



--take a map in written format from a level and turn it into gameplay format
fxL.ParseMap=function(l)
  local w,x,y,z
  local MapObjects={} --hold the objects this map uses
  local WriteMap={} --hold the parsed version of the level map
  local instance     --hold specific copy of an object
  for w=1,#l.objects do  --bookkeeping b/w object library and level.map
    table.insert(MapObjects, ObjLib[l.objects[w].ID])
  end
  for z=1,#l.map do
    for y=1,#l.map[z] do
	  for x=1,#l.map[z][y] do
	    local ReadCell=l.map[z][y][x]
		local WriteCell={}
		if type(ReadCell)=="table" then --if multiple objects in cell
		  for w=1,#ReadCell do
		    local obj=ReadCell[w]
			if type(obj)=="table" then --if we need to pass parameters
			  instance=MapObjects[obj[1]]
			  
			  --make a copy of the object the way the object wants to do it
			  instance=instance:copy()
			  
			  --pass the parameters to the object
			  if instance.Read then instance:Read(obj) end
			  
			else --if we don't need to pass parameters
			  instance=MapObjects[obj]
			  
              --make a copy of the object the way the object wants to do it
			  instance=instance:copy()
			end 
			table.insert(WriteCell, instance)
		  end 
		else --if only one object in cell
		  instance=MapObjects[ReadCell]
		  if instance.copy then instance=instance:copy() end
		  table.insert(WriteCell, instance)
		end  --if
		if x>#WriteMap then WriteMap[x]={} end
		if y>#WriteMap[x] then WriteMap[x][y]={} end
		WriteMap[x][y][z]=WriteCell
	  end 
	end 
  end 
  fxL.InitMap(WriteMap)
  return WriteMap
end  

fxL.Print=function(t)
  if type(t)=="table" then
    print("{")
    for key, val in pairs(t) do
	  if type(val)=="table" then
	    print(key.."=")
		fxL.Print(val)
	  elseif type(val)=="function" then
	    print("function "..key)
	  else
	    print(key.."="..val)
	  end
	end
	print("}")
  else
    print(t)
  end
  
end

fxL.WriteLevel=function(level, map)
  level.atZ=gs.atZ
  level.LastCam=gs.Cam
  local w,x,y,z
  local found={}
  local tempg=Globals   -- we need to save these
  Globals={}      -- clear out globals
  level.objects={}
  level.map={}
  local n=1
  for z=1,#map[1][1] do --scan the map
	level.map[z]={}
	for y=1,#map[1] do -- scan the map
		level.map[z][y]={}
		for x=1,#map do
			level.map[z][y][x]={}
			for w=1,#map[x][y][z] do
				local obj=map[x][y][z][w]  -- got an object
				if found[obj.ID]==nil then  -- add it to the object list
					level.objects[n]={ID=obj.ID} found[obj.ID]=n n=n+1
				end
				if obj.Write then   -- add it to the new map
					level.map[z][y][x][w]=obj.Write(obj,found[obj.ID]) -- if it has a Write function
				else
					level.map[z][y][x][w]=found[obj.ID]     -- default is just the type number
				end
			end
		end
    end
  end
  Globals=tempg   -- restore the globals
end

fxL.WritePlayerList=function()
  local file=io.open("data/players.lua", "w")
	  --Players
  file:write("PlayerAccounts={")
  --writers.table(file,PlayerAccounts,1)
  for i=1,#PlayerAccounts do
    file:write("\n{")
    for key, val in pairs(PlayerAccounts[i]) do
	  if key=="levels" or key=="levelsets" then
	    file:write(key.."={},")
	  else
	    local fnc=inL.writers[type(val)]
		if fnc then
		  if type(key)~="number" then file:write(key.."=") end
		  fnc(file, val, 2)
		  file:write(",")
		end
	  end
	end
	file:write("},")
  end
  file:write("\n}\n")
  
  --Levels
  for i=1,#PlayerAccounts do
    local levels=PlayerAccounts[i].levels
	for guid, level in pairs(levels) do
	  file:write("PlayerAccounts["..i.."].levels['"..guid.."']=")
	  inL.writers.table(file, level, 2)
      file:write("\n")
	end
  end
  
  file:close()
end