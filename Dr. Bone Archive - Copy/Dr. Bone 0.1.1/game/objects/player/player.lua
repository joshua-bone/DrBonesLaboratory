---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="e6f08228-36ca-4334-aee9-5269955b51d9"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"
this.name="Player"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {{{T,180},F}}   --{{this, this.d},floor}
end

--rotates direction in editor
this.EditorRotate=EditorRotate

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="T"      --occupies top
this.removes="T"       --removes top
this.clone=Clone       -- allow individual instances
this.transparent=4 --top transparency (1=floor, 2=bottom, 3=center, 4=top)
this.sound=LoadSound(WD.."game/sounds/player.wav")

this.PreInit=function(this)
  Globals[this.guid]={}   -- set initial count to zero
  gamestate.camera.focus=nil

end

this.init=function(this,x,y,z)
  local camera=gamestate.camera
  ListAppend(Globals[this.guid],this)

--ATTRIBUTES
  this.a.player=true      -- attribute player

--STATS
  this.a.power=1
  
--SPEED,  FORCE,  LOCATION
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this:stop()
  this.lasttick=0 --the last time at which this tried to move
  MoveToList(this,Pending)      -- add object to active list
  if gamestate~=Editor then
    camera.focus=this
    camera.x=this.x+(this.fromx-this.x)*this.offset   -- track the camera
    camera.y=this.y+(this.fromy-this.y)*this.offset
    gamestate.CurrentDeck=this.z
  end
end

this.Read=function(this,params)
  this.d=params[2]              -- read direction
end

this.Write=function(this,T)
  return {T,this.d}      -- write the direction
end

--stops the object's motion
this.stop=function(this)
  this.offset=0
  this.MoveSpeed=0
  this.fromx,this.fromy,this.fromz=this.x,this.y,this.z
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  if obj.a.power<=this.a.power then 
    return 0,0               -- can't enter if equal or less power
  else
    return speed,force       --can enter if more powerful
  end
end

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  death.start(this,"explode",30); -- remove player
  return speed, force
end  

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

this.logic=function(this,event)       -- game logic call per game frame
  local camera=gamestate.camera
  if not ContinueMove(this) then      -- if we have reached the center
    local dur=tick-this.lasttick
    if event~=0 and dur>5 then         -- if a keypress, and less than 8 ticks since we tried to move last
      this.lasttick=tick              --reset time of last move attempt
      if (TryMove(this,dirs[event],1/12,1))==0 then  --try to move
        PlaySound(this.sound) 
        Hover(this,1/12,1) 			    -- hover if move fails
      end
    else
      Hover(this,1/12,1)              --hover if no keypress
    end
  end
  --if camera.focus==this then
    camera.x=this.x+(this.fromx-this.x)*this.offset   -- track the camera
    camera.y=this.y+(this.fromy-this.y)*this.offset
	gamestate.CurrentDeck=this.z
  --end
  PlayHud[3][2]["inventory"]=HudInventory       -- draw inventory
  MoveToList(this,Complete)                         -- we are done
end