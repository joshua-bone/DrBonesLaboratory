--colors: 1 red   2 green    3 yellow   4 blue    5 magenta    6 cyan     7 orange  8 brown

---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="be4c179f-9c1c-494a-8af6-fd305f8f7013"
this.version="2009/05/20-18:20:00"
this.name="Toggle Button"
this.author="Joshua Bone"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.colors={"red","green","yellow","blue","magenta","cyan","orange","brown"}

this.examples=function(T,F)
  return {{{T,1},F}}
end

--change color in editor
this.EditorShuffle=function(this,dir)
  this.color=(this.color+dir)%8
  if this.color==0 then this.color=8 end
end  

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone       -- allow individual instances
this.sound=LoadSound(WD.."game/sounds/button.wav")

this.PreInit=function(this)
   Globals[this.guid]={1,1,1,1,1,1,1,1}      -- set toggle state for passively toggled elements
   Globals["activetoggles"]={{},{},{},{},{},{},{},{}} --for actively toggled elements
end   

this.Read=function(this,params)
  this.color=params[2]
  this.occupies="B"
  this.removes="B"
end

this.Write=function(this,T)
    return {T,this.color}
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  PlaySound(this.sound)
  Globals[this.guid][this.color]=3-Globals[this.guid][this.color]     -- passive toggle
  local list = Globals["activetoggles"][this.color]
  for i=1,#list do
    list[i]:activeToggle()
  end   
end


