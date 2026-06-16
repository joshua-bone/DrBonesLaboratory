gsParts={}
gsParts.ID="gsParts"
gsParts.Left, gsParts.Right={},{}
gsParts.Cam={}

gsParts.Start=function()
  gs=gsParts
  if not gs.Left.Item then
    gs.Left={Item=ObjLib["Wall"],
	         Render=grL.RenderEditPart,
			 Measure=grL.MeasureEditPart}
	gs.Right={Item=ObjLib["Floor"],
	          Render=grL.RenderEditPart,
			  Measure=grL.MeasureEditPart}
  end

  gs.BuildParts()  --loads into global Map
  gs.Cam={x=(#Map/2)+0.5, y=(#Map[1]/2)+0.5, z=20}
  gs.atZ=1
  gs.t=1 --tick to animate parts in gsParts
end

gsParts.KeyDown={
  DEFAULT=function(key)
    gsEditor.Start()
  end
}

gsParts.Render=function()
  gs.t=gs.t+1 --do the timer to animate parts
  grL.RenderMap(Map)
  grL.RenderCursor()
  grL.RenderHud(gs.hud)
  FlipScreen()
end

--grab an element from the map 
gsParts.PaintLeft=function(x,y)
  gsParts.Left.Item=Map[x][y][1][1]
  gsEditor.Start()
end

--grab an element from the map
gsParts.PaintRight=function(x,y)
  gsParts.Right.Item=Map[x][y][1][1]
  gsEditor.Start()
end

gsParts.hud={
{{gsParts.Left},{},{gsParts.Right}},
{{},{},{}},
{{},{},{}}}

gsParts.BuildParts=function()
  local saveLevel=Level
  Level={}
  Level.objects={}

  --keep track of where the Floor object is since some objects like to 
  --be shown over a Floor in the gsParts gamestate
  local Floor
  for i=1,#ObjDirectory do
    if ObjDirectory[i].ID=="Floor" then
	  Floor=i
	end
  end
  
  --build a List of objects to display in gsParts
  local List={}
  local pos=1 --position in the List
  for i=1,#ObjDirectory do
    Level.objects[i]={ID=ObjDirectory[i].ID}
	local obj=ObjLib[ObjDirectory[i].ID]
	if obj.examples then
	  local ex=obj.examples(i, Floor)
	  for j=1,#ex do
	    List[pos]=ex[j]
		pos=pos+1
	  end
	else
	  List[pos]=i
	  pos=pos+1
	end
  end
  
  --from the List we just created, build a Map for display in gsParts
  Level.map={{}}
  local x,y=1,1
  for i=1,#List do
    if Level.map[1][y]==nil then Level.map[1][y]={} end
	Level.map[1][y][x]=List[i]
	x=x+1
	if x>16 then
	  x=1
	  y=y+1
	end
  end
  Map=fxL.ParseMap(Level) --loads into global Map
  Level=saveLevel
end




















