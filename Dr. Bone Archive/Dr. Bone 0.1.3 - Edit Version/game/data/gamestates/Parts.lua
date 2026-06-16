-------------
--PARTS
-------------

Parts={left={},right={},camera={x=0,y=0,z=20}} 
Parts.ID="Parts"

PartsHud={   --SHOULD BE PART OF PARTS GAMESTATE BUT IT ISN'T, NEED TO FIX
{{Parts.left},{"Parts","Left and right click to select part"},{Parts.right}}
,{{},{},{}}
,{{},{},{
MakeClickableText("Exit",NMTCOLOR, MTCOLOR,function() Editor.Start()() end,nil),
}}
}

Parts.Start=function(page)
  gamestate=Parts                              -- capture the game events
  BuildParts(page)
  Parts.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=20}
  Parts.CurrentDeck=1
end

Parts.render=function()
  MapRender(map)
  RenderCursor()
  drawhud(PartsHud,19)
  FlipScreen()
end

Parts.OnTimer=function()
  tick=tick+1
end

Parts.PaintLeft=GrabLeft
Parts.PaintRight=GrabRight

Parts.KeyDown={
  DEFAULT=function(key)
    Editor.Start()
    return
  end,
}
