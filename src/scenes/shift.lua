local shift = {}

shift.init = function(new_scene)
	Scene = 4
	NextScene = new_scene
  shift.t = 0
	shift.fade(0,-100,8)
end

shift.update = function()
	shift.t = shift.t + 1
	if shift.t > 12 then
		shift.t = 0
		Scene = NextScene
		shift.fade(-100, 0, 8)
	end
end

-----crossfade
local _shex={["0"]=0,["1"]=1,
["2"]=2,["3"]=3,["4"]=4,["5"]=5,
["6"]=6,["7"]=7,["8"]=8,["9"]=9,
["a"]=10,["b"]=11,["c"]=12,
["d"]=13,["e"]=14,["f"]=15}

local _pl={
  [0]="00000015d67",
  [1]="0000015d677",
  [2]="0000024ef77",
  [3]="000013b7777",
  [4]="0000249a777",
  [5]="000015d6777",
  [6]="0015d677777",
  [7]="015d6777777",
  [8]="000028ef777",
  [9]="000249a7777",
  [10]="00249a77777",
  [11]="00013b77777",
  [12]="00013c77777",
  [13]="00015d67777",
  [14]="00024ef7777",
  [15]="0024ef77777"
}

local _pi=0-- -100=>100, remaps spal
local _pe=0-- end pi val of pal fade
local _pf=0-- frames of fade left

shift.fade = function(from,to,f)
    _pi=from _pe=to _pf=f
end

shift.maybe_update_fade = function()
 if _pf > 0 then --pal fade
  if _pf == 1 then
   _pi = _pe
  else
   _pi = _pi + ((_pe-_pi)/_pf)
  end
   _pf = _pf - 1
 end
end

shift.maybe_fade = function()
	local pix=6+flr(_pi/20+0.5)
	if(pix ~= 6) then
	    for x=0,15 do
	        pal(x,_shex[sub(_pl[x],pix,pix)],1)
	    end
	else pal() end
end

return shift