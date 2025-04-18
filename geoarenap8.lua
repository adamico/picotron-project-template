--
title 		= "geoarena"
version   = "0.1"
author 	  = "kc00l"
date 			= "2020"
--

-- ★todo★

-- add key as loot to activate
--  portal to next level

-- more level layouts

-- more enemies
-- monster level pools
-- end game

-- add k powerup to retain
--   s,c,l

-- add f powerup to freeze mobs

-- add r powerup for radar

-- add rare loot to retain size
--  after death

-- zoundz
--  size up

-- merge all actors in
--  one function
-- game modes
-- improve endlevel
-- improve capture anim
-- improve shoot graphics
-- preroll level

-- achievements
-- explodeval
-- add juiciness
-- enlarge bullets with laser power
-- logo

function explode(s,delimiter)
 delimiter = delimiter or ","
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)==delimiter then
   add(retval,sub(s,lastpos,i-1))
   lastpos=i+1
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function explodeset(_set)
 local _retarr={}
	local a=explode(_set,"_")
	for i,subarr in pairs(a) do
		local b=explodeval(subarr)
		_retarr[i]={}
		for j,v in pairs(b) do
			_retarr[i][j]=v
		end
	end
	return _retarr
end

state=0
next=0
title_len=#title*4

dirx=explodeval("-1,1,0,0,1,1,-1,-1")
diry=explodeval("0,0,-1,1,-1,1,1,-1")

--sounds
fire=0
death=1
mdeath=2

-- tile number for uncaptured squares
uncaptured=192

-- player tiles number ★fix with color swap
ptiles=explodeval("241,242,243,244")

-- player sprites for different sizes
psp=explodeset("1_2,4_2,3,4_2,3,3,4_8,9,10,11")
--	{
--		{1},{2,4},{2,3,4},
--		{2,3,3,4},{8,9,10,11}
--	}

-- player colors
pcols=explodeval("11,8,9,12")
pcols2=explodeval("3,2,4,5")
pspc={
	{
		{7,11,3,11}, --inner colors
		{11,7,11,7}, --mid colors
	},
	{
		{7,8,2,8},
		{8,7,8,7},
	},
	{
		{7,9,4,9},
		{9,7,9,7},
	},
	{
		{7,12,5,12},
		{12,7,12,7}
	}	
}

-- players starting positions
-- ★ take in account level layout
pposx=explodeval("1,14,14,1")
pposy=explodeval("1,14,1,14")
prangle={0,0.5,0.5,0}

-- power up types
putypes=explode("c,s,l")

-- fade animation
function shift(s)
 t=0
 state=4
 next=s
 fade(0,-100,8)
end

function update_shift()
	t+=1
	if t>12 then
	 t=0
		state=next
  fade(-100,0,8)
	end
end

function _init ()
 -- splash screen --
-- splash = 1
-- splashcols = {0, 1, 6, 7, 7, 6, 1}
-- while (splash < 40) do
-- 	local cl = splashcols[flr(splash / 5) + 1]
-- 	cls()
--  print("kc00l software", 42, 54, cl)
--  print("presentsヤよや", 42, 62, cl)
--  flip()
--  splash+=1
-- end
	particles={}
	floats={}
	loot={}
	
	blink=false
 t=0
 cl=7
	startgame()
end

function _update60()
	updateparticles()
	updatefloats()
	if (state==0) update_home()
	if (state==1) update_game()
	if (state==2) update_endlevel()
	if (state==3) update_gameover()
	if (state==4) update_shift()

	maybe_update_fade()
end

function _draw()
	if (state==0) draw_home()
	if (state==1) draw_game()
	if (state==2) draw_endlevel()
	if (state==3) draw_gameover()

	maybe_fade()
end

function startgame()
	actors={}
	np=1
	winner=nil	
	
	--★ set np in title screen
	for i=1,np do
		addactor(i,"player")
	end
	
	initlevels()

	lvlgoal=60

	clvl=1
	newlevel()
end

function initlevels()
	-- levels map offset
	lvlx=explodeval("16,32,48")
	lvly=explodeval("0,0,0")
 
 lvl_b={}
 
 lvlhb={
 	{},
 	{
 	 {x=8,y=48,x2=8*5,y2=8*4},
 	 {x=80,y=48,x2=8*5,y2=8*4},
 	},
 	{
 	 {x=40,y=40,x2=8*6,y2=8*6}
 	},
 }
 
	lvlsq={}
	local totalsq=196
	
	local lvlsqdelta={0,40,36}
	for k,v in pairs(lvlsqdelta) do
		lvlsq[k]=totalsq-v
	end

 mon_log={
 	triangle={
 		ani=explodeval("64,65,66,67"),
			hp=2,
		 speed=0.25,
		 los=4,
		 rate=1200,
		 hit=make_hit(0,1,6,7)
  }
 }
 
 mon_minl={
 	triangle=1
 }
 
 mon_maxl={
 	triangle=4
 }
end

function newlevel()
	copymap(lvlx[clvl],lvly[clvl])
 initlvlhitboxes()
 initsquares()
	for actor in all(actors) do
		resetplayer(actor)
		squares[pposx[actor.pn+1]][pposy[actor.pn+1]]=ptiles[actor.pn+1]
		actor.score=1/lvlsq[clvl]*100
	end
	for l in all(loot) do
		del(loot,l)
	end
 setpowerups()
 setmonsterspool()
 addloot(8,112)
 addloot(112,8)
end

function copymap(x,y)
 local tile
 for _x=0,15 do
  for _y=0,15 do
   tile=mget(_x+x,_y+y)
   mset(_x,_y,tile)
  end
 end
end

function initlvlhitboxes()
 for hb in all(lvlhb[clvl]) do
 	local b=addlvlblock(hb.x,hb.y)
	 b.hit=make_hit(0,0,hb.x2,hb.y2)
 end
end

function initsquares()
	squares={}
	for x=1,14 do
		local ys={}
		for y=1,14 do
			local tile=mget(x+lvlx[clvl],y+lvly[clvl])
   add(ys,tile) 
 	end
 	add(squares,ys)
 end
end

function resetplayer(p)
	p.size=1
	p.x=pposx[p.pn+1]*8
	p.y=pposy[p.pn+1]*8

	p.r_angle=prangle[p.pn+1]
	checkform(p)
end

function setpowerups()		
 local val
	powerups={}
	for x=1,14 do
		local ys={}
		for y=1,14 do
			if rnd(5)<1 and	squares[x][y]==192 then
			 val=getrnd(putypes)
			else
			 val=" "
			end
			add(ys,val)
		end
		add(powerups,ys)
	end
end

function setmonsterspool()
	monsters={}
	mon_pool={}
	
	-- ★ init enemy types and behavior
 for name,mon in pairs(mon_log) do
		--  can this monster spawn
		--   in the current lvl?
	 if mon_minl[name]<=clvl and
	    mon_maxl[name]>=clvl then
	 --  add monster and max current population
	  mon_pool[name]=4
  end
 end
end
-->8
--updates

function update_game()
	for actor in all(actors) do
		if actor.dead==false then
			checkform(actor)
			checkprotected(actor)
			animplayer(actor)
	 	if btn(4,actor.pn) and
	 				not actor.moving then
	 	 local lx,ly=processinput(actor)
	 		if lx==0 and ly==0 then
	 		 capture(actor)
				elseif actor.laser_p>0 then
					shoot(actor,lx,ly)
				end
	 	elseif btnp(5,actor.pn) then
	 		turn(actor)
	 	else
				move(actor)
				actor.ct=0
				actor.capturing=false
			end	
			
			collisions(actor)
			
			if (actor.hp<0) gover(actor) 
			
	 	if actor.score>lvlgoal then
	 		winner=actor.pn+1
	 		shift(2)
			end
	 end
		
		for l in all(loot) do
			anim(l)
			l.life -=1000
			if(l.life==0) del(loot,l)
		end
	end
 
	spawnmonsters()
  
 for monster in all(monsters) do
 	anim(monster)
 	monster.task(monster)
	end

 if (alldead()) shift(3)
end

function update_endlevel()
	if (btn(4,winner-1)) then
	 shift(1)
	 clvl+=1
		newlevel()
	end
end

function update_gameover()
	if btn(4) then
		shift(1)
		startgame()
	end
end

function update_home ()
	if (btn(4)) shift(1)
end

-- functions

function checkprotected(p)
	local x,y=p.x,p.y
	local protcount=0
	local size=p.size
	local rangle=p.r_angle
	
	if size<5 then
		if size==1 then
			if (capturedtile(p,p.x,p.y)) protcount+=1
		else
			-- size 2-4
			local i=0
			while i<size do
			 if (capturedtile(p,x+8*cos(rangle),y+8*sin(rangle))) protcount+=1
				i+=1
			end
		end
	else
	 -- size 5
	 for _x=1,2 do
			for _y=1,2 do
			 if (capturedtile(p,x+8*(_x-1),y+8*(_y-1))) protcount+=1
	  end
		end
	 protcount=protcount==4 and 5 or protcount
	end
	
	p.protected=protcount==size
end

function checkform(p)
	local r_angle=p.r_angle
 local mult=0
 
	if p.size<5 then
		if p.size==1 then		
   --★ unneeded?
  	p.form={1000,1000}
		 p.hit=make_hit(1,1,5,5)
		else
   for i=1,p.size do
   	mult+=2^(i-1)
   end
			local newsize=8*p.size-0.6*p.size
			
			if sin(r_angle)==0 then
				--l/r
				-- r
				p.hit=make_hit(1,1,newsize,5)
				p.form={8,8+mult}
				if cos(r_angle)<0 then
					-- l
	   	p.form={8,8*mult}
					p.hit=flip_hit(p.hit,8,"h")
				end
			else
				--u/d
				-- u
				p.hit=make_hit(1,1,5,newsize)
	   p.form={8*mult,8}
				
				if sin(r_angle)<0 then
				 -- d
					p.hit=flip_hit(p.hit,8,"v")
		   p.form={8+mult,8}
				end
			end
		end
	else
		p.hit=make_hit(2,2,12,12)
		p.form={0b1100,0b1100}
	end
end

function updateparticles()
 local _p
 for i=#particles,1,-1 do
  _p=particles[i]
  _p.age+=1
  if _p.age>_p.mage then
   del(particles,particles[i])
  else
   if _p.tpe==2 then
 			local _prect=make_rect(_p.hit,_p.x,_p.y)

				-- bullets
				for monster in all(monsters) do   			
     local monsterr=make_rect(monster.hit,monster.x,monster.y)	
   		if collide(_prect,monsterr) then
   			hit(_p,monster)
   			del(particles,particles[i])
					end
				end
   	if not inbounds(_p.x,_p.y,112,8) then
   		del(particles,particles[i])
   	end
   end

   -- change colors
   if #_p.colarr==1 then
    _p.col=_p.colarr[1]
   else
   	if _p.tpe==2 then
   	 _p.col=_p.colarr[1]
   	 _p.col2=_p.colarr[2]
   	else
	    local _ci=_p.age/_p.mage
	    _ci=1+flr(_ci*#_p.colarr)
	    _p.col=_p.colarr[_ci]
   	end
   end
 		
 		--circle explosion
			if _p.tpe==1 then
				--decrease radius over particle age
				_p.r-=_p.age/4			
			end   

   --move particle
   _p.x+=_p.dx
   _p.y+=_p.dy
  end
 end  
end

function updatefloats()
 for f in all(floats) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>50 then
   del(floats,f)
  end
 end
end

function gover(a)
	a.dead=true
end

function move(a)
	if not a.moving then
		local dx,dy=processinput(a)
		local size=a.size
		local rangle=a.r_angle		
  
		a.destx=a.x+dx*8
		a.desty=a.y+dy*8

		if size==5 then
			a.highx=dx>0 and a.x-8+dx*3*8 or a.destx
			a.highy=dy>0 and a.y-8+dy*3*8 or a.desty
		else
		 if dy==0 then
	  -- moving l/r
				a.highx=cos(rangle)==dx 
				         and a.x+dx*size*8
													or a.destx					
		  a.highy=a.desty
		 else
		 	-- moving u/d
		 	a.highx=a.destx
		 	a.highy=sin(rangle)==dy
		 									 and a.y+dy*size*8
		 									 or a.desty
		 end
		end
	
		local player_r=make_rect(a.hit,a.highx,a.highy)
	 local collidewithlvlrect=false

	 for b in all(lvl_b) do
	 	local r=make_rect(b.hit,b.x,b.y)
	 	if (collide(player_r,r))	collidewithlvlrect=true
	 end
		
		if issolid(a.highx,a.highy) 
		 or isoccupied(a.highx,a.highy)
			or collidewithlvlrect
			then
			a.destx=a.x
			a.desty=a.y
		else
			a.moving=true
		end
	end

	local dx=a.destx-a.x
	local dy=a.desty-a.y
	if a.x!=a.destx then
		a.x+=sgn(dx)*a.speed_p
	elseif a.y!=a.desty then
		a.y+=sgn(dy)*a.speed_p
	else
	 a.moving=false
	end	
end

function processinput(a)
	local _dx,_dy=0,0
	for i=0,3 do
		if btnp(i,a.pn) then
		 _dx=dirx[i+1]
		 _dy=diry[i+1]
		end
	end
	
	return _dx,_dy
end

function capturedtile(a,x,y)
	local x=x and x or ceil(a.x/8)
	local y=y and y or ceil(a.y/8)
	
	local tilex,tiley=ceil(x/8),ceil(y/8)
 local current_tile=squares[tilex][tiley]
 return current_tile==ptiles[a.pn+1]
end

function capture(a)
 local x=a.x
 local y=a.y
 cur_tiles={}
 local size=a.size
 local rangle=a.r_angle
 
	if size<5 then
	 for i=1,size do
	 	local tilex=x/8+(i-1)*cos(rangle)
	 	local tiley=y/8+(i-1)*sin(rangle)
			if cancapture(a,tilex,tiley) then
		 	add(cur_tiles,{
		 		val=squares[tilex][tiley],
		 		x=tilex,
		 		y=tiley}
		 	)
	 	end	
	 end	
	else
		for i=1,4 do
	 	local tilex,tiley

			if i<=2 then
				tilex=flr(x/8)+i-1
				tiley=flr(y/8)
			else
				tilex=flr(x/8)+i-3
				tiley=flr(y/8)+1
			end
			if cancapture(a,tilex,tiley) then
		 	add(cur_tiles,{
		 		val=squares[tilex][tiley],
		 		x=tilex,
		 		y=tiley}
		 	)
			end
		end
	end
 
 if #cur_tiles>0 then
 	a.capturing=true
  a.ct+=a.capt_p
 end
  
 if a.ct>=100 then
 	for cur_tile in all(cur_tiles) do
			local tilex=cur_tile.x
			local tiley=cur_tile.y
			local current_tile=cur_tile.val
			squares[tilex][tiley]=ptiles[a.pn+1]
	  a.ct=0
	  a.score+=1/lvlsq[clvl]*100
			
			-- check for powerups
			if powerups[tilex][tiley] then
				getpowerup(a,powerups[tilex][tiley],tilex*8,tiley*8)
				powerups[tilex][tiley]=""	
			end
	
	  -- check for other players
			if current_tile!=uncaptured and
						current_tile!=ptiles[a.pn+1]
			 then
			 local owner=lookup(ptiles,current_tile)
				actors[owner].score-=1/lvlsq[clvl]*100
			end
	  
	  a.capturing=false
 	end
 end
end

function cancapture(a,x,y)
	local val=squares[x][y]
	return not capturedtile(a,x,y)
	 	 or val!=ptiles[a.pn+1]
end

function shoot(a,x,y)
	a.capturing=false
	a.ct=0
	sfx(fire)
	local power=a.laser_p
	local sspdx=x*power
	local sspdy=y*power
	local sage=max(30,15*power)
 local rangle=a.r_angle
 local size=a.size
 local shots={}
 
 if size==5 then
  --right
		shots[1]=addpart(a.x+8,a.y,power,0,2,sage,{a.col,a.col2},16)
		shots[2]=addpart(a.x+8,a.y+8,power,0,2,sage,{a.col,a.col2},16)
		--down
		shots[3]=addpart(a.x,a.y+8,0,power,2,sage,{a.col,a.col2},32)
		shots[4]=addpart(a.x+8,a.y+8,0,power,2,sage,{a.col,a.col2},32)
		--left
		shots[5]=addpart(a.x,a.y,-power,0,2,sage,{a.col,a.col2},16,true)
		shots[6]=addpart(a.x,a.y+8,-power,0,2,sage,{a.col,a.col2},16,true)
		--up
		shots[7]=addpart(a.x,a.y,0,-power,2,sage,{a.col,a.col2},32,false,true)
		shots[8]=addpart(a.x+8,a.y,0,-power,2,sage,{a.col,a.col2},32,false,true)
	else
	 -- check shot direction
	 -- shoot l/r
		if y==0 then   
	  -- rotation l/r
	  if cos(rangle)!=0 then
	   -- calculate x offset
	  	local ox=cos(rangle)==x and (size-1)*cos(rangle)*8 or 0
	  	local s=addpart(a.x+ox,a.y,sspdx,sspdy,2,sage,{a.col,a.col2})
	  	add(shots,s)
	  else
	  	-- rotation u/d
	   for i=1,size do
	    local oy=sin(rangle)<0 and (i-size)*8 or (i-1)*8
				 local s=addpart(a.x,a.y+oy,sspdx,sspdy,2,sage,{a.col,a.col2})
			 	add(shots,s)
				end
			end
	  
		 for i,s in pairs(shots) do
		  -- set sprite and h flip	  
		  s.spr=16
		 	if (x<0) s.fliph=true
		 end
		else
			-- shot u/d
			
			-- rotation u/d
	  if sin(rangle)!=0 then
				-- calculate y offset
	  	local oy=sin(rangle)==y and (size-1)*sin(rangle)*8 or 0
	  	local s=addpart(a.x,a.y+oy,sspdx,sspdy,2,sage,{a.col,a.col2})
	  	add(shots,s)
	  else
	  	-- rotation l/r
			 for i=1,size do
		   local ox=cos(rangle)<0 and (i-size)*8 or (i-1)*8
				 local s=addpart(a.x+ox,a.y,sspdx,sspdy,2,sage,{a.col,a.col2})
			 	add(shots,s)
			 end
   end	
	  -- set sprite and v flip
		 for i,s in pairs(shots) do
		 	s.spr=32
			 if (y<0) s.flipv=true
			end
		end
	end
end

function turn(p)
 if p.size>1 and canturn(p) then		
		-- get current orientation
		local curangle=p.r_angle
		-- turn player clockwise
		local newangle=curangle==0.75 and 0 or curangle-0.25
		p.r_angle=newangle
	end
end

function canturn(p)
	local rangle,size=p.r_angle,p.size
 local x,y=p.x,p.y
 local solidc=0
 
 for i=1,size-1 do
 	if issolid(x+i*-sin(rangle)*8,y+i*cos(rangle)*8) then
   solidc+=1
  end
 end
 return solidc==0
end

function getpowerup(a,power,x,y)
	--★
	if power=="c" then
		-- faster capture
		if a.capt_p<a.capt_pmax then
			a.capt_c+=1
			addfloat(power,x+2,y,pcols[a.pn+1])

			if a.capt_c==3 then
			 a.capt_p+=1
				addfloat("capture up!",x-8,y,pcols[a.pn+1])
			 a.capt_c=0
			end
		end
	end

	if power=="s" then
		-- faster movement
		if a.speed_p<a.speed_pmax then
			a.speed_c+=1
			addfloat(power,x+2,y,pcols[a.pn+1])

			if a.speed_c==3 then
			 a.speed_p*=2
				addfloat("speed up!",x-8,y,pcols[a.pn+1])
			 a.speed_c=0
			end
		end
	end

	if power=="l" then
		-- shoot laser
		if a.laser_p<a.laser_pmax then
			a.laser_c+=1
			addfloat(power,x+2,y,pcols[a.pn+1])

			if a.laser_c==3 then
			 a.laser_p+=1
				addfloat("laser up!",x-8,y,pcols[a.pn+1])
			 a.laser_c=0
			end
		end
	end
	
	if power=="g" then
		grow(a)
	end
end

function anim(m)
	m.t+=1
 m.sp=getframe(m.ani,m.t)
	if (m.t>38) m.t=1
end

function animplayer(p)
	p.t+=1

 p.incol=getframe(pspc[p.pn+1][1],p.t)
 p.micol=getframe(pspc[p.pn+1][2],p.t)
	
	p.sp=psp[p.size]
	if (p.t>38) p.t=1
end

function issolid(x,y)
	local tle=mget(ceil(x/8),ceil(y/8))
 local flag=fget(tle,0)
	return flag and true or false
end

function isfarfromplayers(x,y,d)
	local mx,my=x/8,y/8
 local far=0
 for a in all(actors) do
 	if dist(mx,my,a.x/8,a.y/8)>=d then
 		far+=1
 	end
 end
 
 return far>=#actors
end

function isoccupied(x,y)
	local tle=mget(x/8,y/8)
 local occupied=false
 for a in all(actors) do
		if (a.x==x and a.y==y) occupied=true 	
 end
 return occupied
end

-- collision check

function collisions(p)
	local player_r=make_rect(p.hit,p.x,p.y)

	for l in all(loot) do
		if collide(player_r,make_rect(l.hit,l.x,l.y)) then
			hit(p,l)
		end
	end

	for enemy in all(monsters) do
		local enemy_r=make_rect(enemy.hit,enemy.x,enemy.y)

	 if collide(player_r,enemy_r) and
					not p.protected then
 		hit(enemy,p)
		end
	end
end

function make_hit(x1,y1,x2,y2)
 return {["x1"]=x1,["y1"]=y1,["x2"]=x2,["y2"]=y2}
end

function flip_hit(hit,val,axe)
	local x1,x2,y1,y2=
		hit.x1,hit.x2,hit.y1,hit.y2
	if axe=="v" then
	 --flips vertically
	 y1=val-hit.y2-1
	 y2=val-hit.y1-1
	else
		-- flips horizontally
		x1=val-hit.x2-1
	 x2=val-hit.x1-1
	end
	
 return make_hit(x1,y1,x2,y2)
end

function make_rect(hit,x,y)
 local x1=hit.x1+x
 local y1=hit.y1+y
 local x2=hit.x2+x
 local y2=hit.y2+y
 return make_hit(x1,y1,x2,y2)
end

function collide(r1,r2)
 if r1.x2<r2.x1 or r1.x1>r2.x2 or r1.y2<r2.y1 or r1.y1>r2.y2 then
  return false
 end
 return true
end

function collide2(a1,a2,fliph,flipv)
 local x1,y1,w1,h1,x2,y2,w2,h2=
  a1.x,a1.y,a1.w,a1.h,
  a2.x,a2.y,a2.w,a2.h

 local hit=false
 local xd=abs((x1+(w1/2))-(x2+(w2/2)))
 local xs=w1*0.5+w2*0.5
 local yd=abs((y1+(h1/2))-(y2+(h2/2)))
 local ys=h1/2+h2/2
 if (xd<xs and yd<ys) hit=true
 
 return hit	
end

function hit(obj1,obj2)
	if obj2.tpe=="player" then
		obj2.hp-=1	
		explosion(obj2)
  sfx(death)
		obj2.moving=false
		resetplayer(obj2)

		return
	elseif obj2.tpe=="monster" then
		obj2.hp-=1
		obj2.flash=10
		if obj2.hp<0 then
			explosion(obj2)
			sfx(mdeath)
			addloot(obj2.x,obj2.y)
			del(monsters,obj2)
		end
		return
	elseif obj2.tpe=="loot" then
		--loot
		if cangrow(obj1) then
			getpowerup(obj1,"g")
			del(loot,obj2)
		end
		return
	end
end

function grow(p)
	p.size+=1
	
	if (issolid(p.x+8,p.y)) then
		p.r_angle=0.5
	end
	p.sp=psp[p.size]
end

function cangrow(p)
	return p.size<p.size_max
end

function alldead()
	dead=0
	
	for a in all(actors) do
		if (a.hp<0) dead+=1
	end
	
	return dead==np
end
-->8
--draws

function draw_home()
	t=(t+1)%20
 blink=(t<10)
	cls()
	pal()
	line(0,64,128,64,1)
	rectfill(0,16,128,32,3)
	print(title,65-title_len/2,21,0)
	print(title,64-title_len/2,20,7)
	rectfill(0,119,128,128,1)
	print(version..'ヤよや'..author..'ヤよや'..date,16, 121, 6)
 if (blink) pal(7,6)
	print("press 🅾️   ",50,62,cl)
end

function draw_game()
	cls()
	map()
	
	drawsquares()
	drawpowerups()
	drawparticles()
	
 for l in all(loot) do
	 draw_outline(drawactor,0,l)
	 drawactor(l)
		--hitrect(l)
 end
 	
	for a in all(actors) do
		drawui(a)
		drawcapture(a)
		draw_outline(drawplayer,0,a)
		drawplayer(a)
	end
	
	for m in all(monsters) do
		draw_outline(drawmonster,0,m)
		drawmonster(m)
		--hitrect(m)
	end

-- for b in all(lvl_b) do
--		hitrect(b)
--	end
	drawfloats()
end

function drawsquares()
 for x=1,14 do
 	for y=1,14 do
 		mset(x,y,squares[x][y])
 	end
 end
end

function drawpowerups()
	for x=1,14 do
		for y=1,14 do
		 local val=powerups[x][y]
			print(val,x*8+2,y*8+1,8)
		end
	end
end

function drawfloats()
 for f in all(floats) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end
end

function drawparticles()
 for _p in all(particles) do
  -- pixel particle
  if _p.tpe==0 then
   pset(_p.x,_p.y,_p.col)
  -- circle particle
  elseif _p.tpe==1 then
  	circfill(_p.x,_p.y,_p.r,_p.col)
  elseif _p.tpe==2 then
 		-- shoot
 		palt(15,true)
 		palt(0,false)
			pal(6,_p.col)
			pal(5,_p.col2)
			spr(_p.spr,_p.x,_p.y,1,1,_p.fliph,_p.flipv)
			palt()
			--hitrect(_p)
  end 
 end  
end

function drawui(a)
	local pn=a.pn
	local score=ceil(a.score).."%"
	local hp=0
	while hp<a.hp do
		hp+=1
	end 
	local scx=max(0,(pposx[pn+1]-6)*8)
	local oy=(pn==0 or pn==2) and -8 or 10
	local scy=(pposy[pn+1])*8+oy
	if a.dead then
		print("p"..(pn+1).." ".."😐 "..score,scx,scy,a.col)
 else
		print("p"..(pn+1).." "..hp.."♥ "..score.." "..drawpui(a).c.." "..drawpui(a).s.." "..drawpui(a).l,scx,scy,a.col)
	end
end

function drawcapture(a)
	if a.capturing then
		local x,y,ct,pn=a.x/8,a.y/8,a.ct,a.pn
	
		local ctile=193+pn
		if ct<33 then
		 anicapture(a,a.x,a.y,ctile)
	 elseif ct>33 and ct<66 then
		 anicapture(a,a.x,a.y,ctile+16)
	 elseif ct>66 and ct<100 then
		 anicapture(a,a.x,a.y,ctile+32)
		end		
	end
end

function anicapture(a,x,y,tile)
	local cur_tiles={}
	local size=a.size
	local ox=cos(a.r_angle)
	local oy=sin(a.r_angle)
	if size<5 then
	 for i=1,size do
	 	local tilex=x/8+(i-1)*ox
	 	local tiley=y/8+(i-1)*oy
	 	add(cur_tiles,{
	 		val=tile,
	 		x=tilex,
	 		y=tiley}
	 	)
	 end	
	else
		for i=1,4 do
	 	local tilex
	 	local tiley

			if i<=2 then
				tilex=x/8+i-1
				tiley=y/8
			else
				tilex=x/8+i-3
				tiley=y/8+1
			end
	 	add(cur_tiles,{
	 		val=tile,
	 		x=tilex,
	 		y=tiley}
	 	)
		end
	end

	for cur_tile in all(cur_tiles) do
		mset(cur_tile.x,cur_tile.y,cur_tile.val)
	end
end

function drawactor(a)
	palt(15,true)
	palt(0,false)
	spr(a.sp,a.x,a.y)
	palt()
end

function drawplayer(a)
	if a.dead==false then
		palt(15,true)
		palt(0,false)
  pal(7,a.incol)
 	pal(6,a.micol)
		if a.size<5 then
			for i,sp in pairs(a.sp) do
				local angle=a.r_angle
				local sx=a.x+(i-1)*8*cos(angle)
				local sy=a.y+(i-1)*8*sin(angle)
				local newsp
				if sin(angle)==0 then
		 		newsp=sp
		 		if (cos(angle)<0) sx-=1
				else
  		 newsp=sp+3
		 		if (sin(angle)<0) sy-=1
				end
				spr(newsp,sx,sy,1,1,cos(angle)<0,sin(angle)<0)
			end
		else
			for i,sp in pairs(a.sp) do
				local sx,sy
				if i<=2 then
					sx=a.x+(i-1)*8
					sy=a.y
				else
					sx=a.x+(i-3)*8
					sy=a.y+8
				end
				spr(sp,sx,sy)
			end
		end

		palt()
		--hitrect(a)
	end
end

function drawmonster(m)
	palt(15,true)
	palt(0,false)
	if m.flash>0 then
		m.flash-=1
		pal(4,7)
		pal(9,7)
	end
	spr(m.sp,m.x,m.y)
	palt()
end

function drawpui(a)
	--★
	local _c,_s,_l="","",""
	for pu in all(putypes) do
		if pu=="c" and a.capt_c>0 then
			for i=1,a.capt_c do
				_c=_c..pu
			end
		elseif pu=="s" and a.speed_c>0 then
			for i=1,a.speed_c do
				_s=_s..pu
			end
		elseif pu=="l" and a.laser_c>0 then
			for i=1,a.laser_c do
				_l=_l..pu
			end
		end
	end
	return {c=_c,s=_s,l=_l}
end

-- end level
function draw_endlevel()
	t = (t + 1) % 20
 blink = (t < 10)

	local pcol=actors[winner].col
	
	cls()
	pal()
 if (blink) pal(pcol,darken(pcol))
	print("player "..winner..", you won!",42,50,pcol)
	print("press 🅾️",42,62,pcol)
end

-- gameover
function draw_gameover ()
	t = (t + 1) % 20
 blink = (t < 10)
	cls()
	pal()
 if (blink) pal(10, 9)
	print("game over",42, 50, 10)
	print("press 🅾️", 42, 62, cl)
	print(version..'ヤよや'..author..'ヤよや'..date,16, 121, 6)
end

function hitrect(a)
	local r=make_rect(a.hit,a.x,a.y)
	rect(r.x1,r.y1,r.x2,r.y2,8)
end

--
-- credits to trasevol dog
-- source: 
-- https://trasevol.dog/2017/03/28/doodle-insights-10-low-rez-spriting/

-- calling with no parameters resets it
function all_colors_to(c)
 if c then
  for i=0,15 do
   pal(i,c)
  end
 else
  for i=0,15 do
   pal(i,i)
  end
 end
end

-- 'draw' must be a function callback
-- 'c' defaults to 0 if not set
-- 'arg' will be given to the draw function (optional)
function draw_outline(draw,c,arg)
 local c=c or 0
 all_colors_to(c)
 
 camera(-1,0) draw(arg)
 camera(1,0)  draw(arg)
 camera(0,-1) draw(arg)
 camera(0,1)  draw(arg)
 
 camera(0,0)
 all_colors_to()
end
-->8
--libraries

-----crossfade
_shex={["0"]=0,["1"]=1,
["2"]=2,["3"]=3,["4"]=4,["5"]=5,
["6"]=6,["7"]=7,["8"]=8,["9"]=9,
["a"]=10,["b"]=11,["c"]=12,
["d"]=13,["e"]=14,["f"]=15}
_pl={[0]="00000015d67",
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
    [15]="0024ef77777"}
_pi=0-- -100=>100, remaps spal
_pe=0-- end pi val of pal fade
_pf=0-- frames of fade left
function fade(from,to,f)
    _pi=from _pe=to _pf=f
end

function maybe_update_fade ()
 if (_pf>0) then --pal fade
  if (_pf==1) then
   _pi=_pe
  else
   _pi+=((_pe-_pi)/_pf)
  end
   _pf-=1
 end
end

function maybe_fade ()
	local pix=6+flr(_pi/20+0.5)
	if(pix!=6) then
	    for x=0,15 do
	        pal(x,_shex[sub(_pl[x],pix,pix)],1)
	    end
	else pal() end
end

function getframe(ani,at)
 return ani[flr(at/8)%#ani+1]
end

darkcols={}
darkcols[11]=3
darkcols[8]=2

function darken(col)
	return darkcols[col]
end

function lookup(table,value)
	local index={}

	for k,v in pairs(table) do
		index[v]=k
	end
 return index[value]
end

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end

function getrnd(arr)
	return arr[1+flr(rnd(#arr))]
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end

function inbounds(x,y,maxv,minv)
 return not (x<minv or y<minv or x>maxv or y>maxv)
end
-->8
--objects

function addactor(n,tpe)
 local a={
		destx=0,desty=0,
		mode="alive",
		protected=false,
		dead=false,
		moving=false,
		capturing=false,
		capt_p=1,
		capt_c=0,
		capt_pmax=3,
		speed_p=1,
		speed_c=0,
		speed_pmax=3,
		laser_p=0,
		laser_c=0,
		laser_pmax=3,
		size=1,
		size_max=5,
		form={8,8},
		angle=0,
		t=0,ct=0,
		score=0,hp=5,
	}
	
	a.r_angle=prangle[n]
	a.tpe=tpe and tpe or "player"
	a.pn=n-1
 a.col=pcols[n]
 a.col2=pcols2[n]
	a.sp=psp[a.size]
	
	add(actors,a)
	
	return a
end

function addmonster(_kind,_x,_y)
	m={
		tpe="monster",
		kind=_kind,
		x=_x,y=_y,
		t=0,
		angle=0,
		task=wait,
		flash=0,
		size=1,
		--★ metatables, merge tables?
		hit=mon_log[_kind].hit,
		ani=mon_log[_kind].ani,
		los=mon_log[_kind].los,
		speed=mon_log[_kind].speed,
		hp=mon_log[_kind].hp
	}
	
	add(monsters,m)
	return m
end

function addpart(_x,_y,_dx,_dy,_type,_maxage,_col,_spr,_fliph,_flipv)
	local _p={
		x=_x,y=_y,
		dx=_dx,dy=_dy,
		tpe=_type,
		mage=_maxage,age=0,
		col=0,colarr=_col,
		r=10,
		spr=_spr,
		fliph=_fliph,
		flipv=_flipv
	}
	
	_p.hit=make_hit(2,2,5,5)
	
	add(particles,_p)
	return _p
end

function addpowerup(x,y,val)
	powerups[x][y]=val
end

function addloot(_x,_y,_val)
 local _l={
 	tpe="loot",
 	x=_x,y=_y,
 	w=4,h=4,
 	hp=0,
 	val=_val,
 	dead=false,
 	ani={17,18,19,20},
 	sp=17,
 	t=0,
 	life=300000,
 	size=1
 }
 
 add(loot,_l)

	_l.hit=make_hit(1,1,6,6)
 
 return _l
end

function addfloat(_txt,_x,_y,_c)
 add(floats,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function addlvlblock(_x,_y)
	local _b={
		x=_x,
		y=_y
	}
	
	add(lvl_b,_b)
	
	return _b
end

function spawnmonsters()
 for name,num in pairs(mon_pool) do
		if #monsters<num and time()%3==0 then
			local maxnum=num-#monsters+1
			placemonsters(min(maxnum,flr(rnd(maxnum))),name)
		end
	end
end

function placemonsters(n,kind)
	local mx,my
	while n>0 do
		mx,my=(flr(rnd(13)+1))*8,(flr(rnd(13)+1))*8

		if not isoccupied(mx,my) and
					isfarfromplayers(mx,my,6)
			then
			addmonster(kind,mx,my)
			n-=1
		end
	end
end

function explosion(_a)
	for i=1,10 do
  local _ang=rnd()
  local _dx=sin(_ang)*1
  local _dy=cos(_ang)*1
 
 	-- gravity affected pixel
  addpart(_a.x+4,_a.y+4,_dx,_dy,0,60,{_a.col,5})
 end
 
 -- circle
 addpart(_a.x+4,_a.y+4,0,0,1,100,{7,6})
end

function wait(m)
	local p=nearestactor(m)
	if (cansee(m,p) or p.capturing) and
			 not p.protected
	 then
  m.task=attack
 else
 	local tx,ty

		if m.tx and m.ty then
	 	if ((flr(m.tx/8)==flr(m.x/8)
	 		and flr(m.ty/8)==flr(m.y/8)))
	 		then
	 	 tx,ty=getrndtile()
			else
				tx=m.tx
				ty=m.ty
			end 	
		else
	 	tx,ty=getrndtile()
	 end

 	movemonster(m,tx,ty,m.speed)
	end
end

function getrndtile()
 local candx,candy
 repeat
  candx,candy=flr(rnd(13)+1)*8,flr(rnd(13)+1)*8
	until not isoccupied(candx,candy)
	return candx,candy
end

function attack(m)
	local p=nearestactor(m)
	if (cansee(m,p) or p.capturing) and
			 not p.protected
		then
		movemonster(m,p.x,p.y,m.speed*1.75)
	else
		m.task=wait
	end
end

function nearestactor(m)
 local mx,my=m.x/8,m.y/8
 local cand=actors[1]
 local cdist=dist(mx,my,cand.x/8,cand.y/8)
	for a in all(actors) do
		local ndist=dist(mx,my,a.x/8,a.y/8)
		if ndist<cdist then
		 cand=a
		 cdist=ndist
		end
	end
	
	return cand
end

function cansee(m,p)
	mdist=dist(m.x/8,m.y/8,p.x/8,p.y/8)
 return mdist<=m.los
end

function movemonster(m,tx,ty,speed)
	m.tx,m.ty=tx,ty
	
 local newangle=atan2(tx-m.x,ty-m.y)
 --lerp
 m.angle=angle_lerp(m.angle,newangle,0.1)

 --move
 m.x+=speed*cos(m.angle)
 m.y+=speed*sin(m.angle)
end

function angle_lerp(angle1,angle2, t)
 angle1%=1
 angle2%=1

 if abs(angle1-angle2)>0.5 then
  if angle1>angle2 then
   angle2+=1
  else
   angle1+=1
  end
 end

 return ((1-t)*angle1+t*angle2)%1
end