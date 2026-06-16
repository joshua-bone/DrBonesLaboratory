---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="bcc6d902-dfe6-4959-8609-98c582cbf8ea"
this.name="Goal"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="B"  --occupies bottom layer
this.removes="B"   --removes bottom layer
this.sound=LoadSound(WD.."game/sounds/goal.wav")

this.examples=function(T,F)
  return {{T,F}}  --in item select screen, returns this on top of a floor
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

--anything can enter

this.FinishEnter=function(this,obj)
  if obj.a.player then
    PlaySound(this.sound)
    gamestate.SetWin("Success!")
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render= function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist+(tick/2)%8)
end

this.Load=function(this)
    this.Resource=LoadTexture(this.path.."graphics/0004_goal.bmp")
    this.glist=glGenLists(8)
    local j
    for j = 0,7 do
      glNewList(this.glist+j,GL_COMPILE)
        glBindTexture(GL_TEXTURE_2D,this.Resource)
        RenderPlaneUV(.4,.4,-.48,0,(7-j)/8,1,(8-j)/8)
      glEndList()
    end
end