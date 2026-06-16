---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="d2982f8c-6935-4129-9744-dcddfd11a6ba"
this.name="Floppy Disk"   

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {{T,F}}  --in the item select screen, return this on top of a floor
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.transparent=3 --center transparency, (1=floor, 2=bottom, 3=center, 4=top)
this.sound=LoadSound(WD.."game/sounds/disk.wav")
this.occupies="C" --occupies center
this.removes="C" --removes center

this.PreInit=function(this)
  Globals[this.guid]=0   -- set initial count to zero
end

--[[this.showpiecesleft=function(this)
  PlayLevel.hud[1][1][this.guid]="Floppy Disks Left "..Globals[this.guid]
end]]

this.init=function(this)
    if gamestate.ID~="Parts" then
      Globals[this.guid]=Globals[this.guid]+1 
	end
end

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------
  
this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==-1 or obj.a.player==true then --can enter if player or falling from above
    return speed, force
  else
    return 0,0
  end
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
    if obj.a.player and Globals[this.guid]~=0 then
      Globals[this.guid]=Globals[this.guid]-1
      PlaySound(this.sound)
      gamestate.score=math.min(MAXSCORE, gamestate.score+10)
      ListRemove(map[obj.x][obj.y][obj.z],this)                        --- remove whatever it was from the map
    end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glPushMatrix()
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+1) --render the mask
  glBlendFunc(GL_ONE,GL_ONE)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist)           
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0005_floppydisk.bmp")
  -- create the render list
  this.glist=glGenLists(2)
  local h=1/256
  local j
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.4,.4,CENTERLEVEL,0,(1-j)/2+h,1,(2-j)/2-h)
    glEndList()
  end
end
