---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="5a6469bf-bd90-496a-824f-4fe98b7e70c7"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Connector"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.PaintWith=function(this,x,y,z)
  this.lastx,this.lasty,this.lastz=this.x,this.y,this.z
  this.x,this.y,this.z=x,y,z
  local w
  local cell=map[x][y][z]
  for w=#cell,1,-1 do
    if cell[w].connect then cell[w]:connect(this,x,y,z) end
  end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies,this.removes="TBNSEWFC",""
this.clone=Clone
this.transparent=4 --top transparency  --uses a graphics mask
this.sound=LoadSound(WD.."game/sounds/connector.wav")