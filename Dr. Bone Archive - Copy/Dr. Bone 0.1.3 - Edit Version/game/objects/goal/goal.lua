---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="bcc6d902-dfe6-4959-8609-98c582cbf8ea"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"
this.name="Goal"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="B"
this.removes="B"
this.sound=LoadSound(WD.."game/sounds/goal.wav")

this.examples=function(T,F)
  return {{T,F}}
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  if obj.a.player then
    PlaySound(this.sound)
    gamestate.SetWin("Success!")
  end
end

