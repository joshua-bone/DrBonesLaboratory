---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="d2982f8c-6935-4129-9744-dcddfd11a6ba"
this.version="2008/04/27-15:36:00"
this.author="Joshua Bone"   

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {{{T,1},F},{{T,2},F}}  -- rule 1=piece, rule 2=gate, rule 3=extra piece
end

this.EditorShuffle=function(this)
  this.rule=3-this.rule
end

this.EditorRotate=this.EditorShuffle

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone       -- allow individual instances
this.transparent=3 --center transparency, (1=floor, 2=bottom, 3=center, 4=top)
this.sound={LoadSound(WD.."game/sounds/disk.wav"),
            LoadSound(WD.."game/sounds/unlock.wav"),
            LoadSound(WD.."game/sounds/accessdenied.wav")}

this.PreInit=function(this)
  Globals[this.guid]=0   -- set initial count to zero
end

--[[this.showpiecesleft=function(this)
  PlayLevel.hud[1][1][this.guid]="Floppy Disks Left "..Globals[this.guid]
end]]

this.init=function(this,x,y,z)
  if this.rule==1 then 
    if gamestate.ID~="Parts" then
      Globals[this.guid]=Globals[this.guid]+1 
	end
    this.a.pickup=true
    this.a.power=1
    this.MoveSpeed,this.MoveForce=0,0
    this.x,this.y,this.z=x,y,z
    this.offset=0
    this.fromx,this.fromy,this.fromz=x,y,z
    MoveToList(this,Pending)
  end    -- add real pieces
  --this.showpiecesleft(this)
end

this.Read=function(this,params)
    this.rule=params[2]
    this.occupies=({"C","TBNSEWC","C"})[this.rule]  -- piece,gate
    this.removes=this.occupies
    this.name=({"Floppy Disk","Computer Terminal"})[this.rule]
end

this.Write=function(this,T)
    return {T,this.rule}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------
  
this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  if obj.a.player==true then                                 -- player entering
    if this.rule==1 then return speed,force end                -- floppy disk
    if Globals[this.guid]==0 then return speed,force end  -- terminal
    PlaySound(this.sound[3])
  elseif obj.guid==block and obj.rule==3 then --glass block
    return speed,force
  end
  return 0,0
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  if this.rule==1 then
    if obj.guid==block and obj.rule==3 then
      obj.a.cargo=this
    elseif Globals[this.guid]~=0 then
      Globals[this.guid]=Globals[this.guid]-1
      if obj.a.player then PlaySound(this.sound[1]) end
        gamestate.score=math.min(MAXSCORE, gamestate.score+10)
        ListRemove(map[obj.x][obj.y][obj.z],this)                        --- remove whatever it was from the map
    end
  else 
    if obj.a.player then PlaySound(this.sound[2]) end
    ListRemove(map[obj.x][obj.y][obj.z],this)                        --- remove whatever it was from the map
  end 
end

this.logic=BlockLogic

this.Render=function(this,h)
  glPushMatrix()
  if this.offset then
    glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
  end
  local rule=(this.rule-1)*2
  if rule==0 then
    glEnable(GL_BLEND)
    glBlendFunc(GL_DST_COLOR,GL_ZERO)
    glCallList(this.glist+rule*2+1) --render the mask
    glBlendFunc(GL_ONE,GL_ONE)
  else
    if (Globals[this.guid] and Globals[this.guid]~=0) then h=h/2 end --darker when there are floppy disks remaining
  end
  glColor3f(h,h,h) --darken with depth
	glCallList(this.glist+rule)                     -- render the player
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."floppydisk.bmp")
  -- create the render list
  this.glist=glGenLists(3)
  local h=1/256
  local j
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.4,.4,CENTERLEVEL,0+h,(1-j)/2+h,1/2-h,(2-j)/2-h)
    glEndList()
  end
  glNewList(this.glist+2,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCubeUV(.5,.5,.5,1/2+h,1/2+h,1-h,1-h)
  glEndList()
end
