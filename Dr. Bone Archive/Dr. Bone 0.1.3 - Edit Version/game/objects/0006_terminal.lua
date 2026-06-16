---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="273d5de9-4f65-43fe-80ef-f94e854cd8ca"
this.name="Computer Terminal"   

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T} --in the item select screen, return just this
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="TBNSEWC"  --occupies everything BUT floor (can place over ice, fire, water, force)
this.removes=this.occupies  --removes everything BUT floor

this.sound={LoadSound(WD.."game/sounds/unlock.wav"),
            LoadSound(WD.."game/sounds/accessdenied.wav")}

this.Write=function(this,T)
    return {T,this.rule}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------
  
this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local floppy="d2982f8c-6935-4129-9744-dcddfd11a6ba"
  if obj.a.player==true then                                 -- player entering
    if Globals[floppy] and Globals[floppy]>0 then 
      PlaySound(this.sound[2]) --"ACCESS DENIED"
	else
	  return speed, force
	end
  end
  return 0,0
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  PlaySound(this.sound[1])
  ListRemove(map[obj.x][obj.y][obj.z],this) 
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  local floppy="d2982f8c-6935-4129-9744-dcddfd11a6ba"
  if (Globals[floppy] and Globals[floppy]>0) then h=h/2 end --darker when there are floppy disks remaining
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist)               
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0006_terminal.bmp")
  -- create the render list
  this.glist=glGenLists(1)
  glNewList(this.glist, GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCubeUV(.45,.45,.5,0,0,1,1)
  glEndList()
end
