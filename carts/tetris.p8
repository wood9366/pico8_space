pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
screen = { w = 128, h = 128 }
area = { bw=14, bh=24 }
block = { s=4 }
blocks = {}
shape = { bx=1, by=1, t=1 }
next_shape = { x = 0, y = 0, m = 1, t = 1 }
freeze = { by=0, f=false, d=true }
game = {
  drop_time = 0.5,
  music_time = 16,
  music_gap_time = 5,
  score = 0,
}
t = {
  dt = 0, pt = 0,
  drop = 0,
  music = 0,
  music_gap = 0
}
del_anim = {
  frames = {
		  { x = 16, y = 0, t = 0 },
		  { x = 20, y = 0, t = .03 },
		  { x = 24, y = 0, t = .06 },
		  { t = .1 }
		},
		t = .2,
		loop = false
}

full_row_mask = (1 << area.bw) - 1

del_anim_t = nil
del_anim_f = 1

function _init()
  printh("== tetris")
  
  area.w = area.bw * block.s
  area.h = area.bh * block.s
  area.x = (screen.w - area.w) \ 2
  area.y = screen.h - 6 - area.h
  
  next_shape.x = area.x + area.w + 1
  next_shape.y = area.y
  
  palt(0)
  
  init_game()
  
  del_anim_t = 0
  del_anim_f = 1
end

function init_game()
  for i=1,area.bh do
    blocks[i] = 0
  end
  
  game.score = 0
  
  t.pt = time()
  t.drop = game.drop_time
  t.music = game.music_time
  t.music_gap = 0
  
  next_shape.t = rand_shape()
  new_shape()
  
  music(0, 1000)
end

function rand_shape()
  return ceil(rnd(#shapes))
end

function new_shape()
  shape.t = next_shape.t
  local st = shapes[shape.t]
  shape.bx = (area.bw - st.w) \ 2 + st.ox
  shape.by = area.bh + st.oy
  next_shape.t = rand_shape()
  freeze.d = true
end

function _update()
--  printh("=> update")
  local ct = time()
  t.dt = ct - t.pt
  t.pt = ct
  
  if del_anim_t then
		  local del_anim_pt = del_anim_t
		  del_anim_t += t.dt
--		  printh("t: " .. tostr(del_anim_t))
		  for f=del_anim_f,#del_anim.frames do
		    local fa = del_anim.frames[f]
		    if del_anim_pt < fa.t and
		      del_anim_t >= fa.t
		    then
		      del_anim_f = f
		      break
		    end
		  end
		  if del_anim_t >= del_anim.t then
		    if del_anim.loop then
		      del_anim_t = 0
		      del_anim_f = 1
		    else
		      del_anim_t = nil
		    end
		  end
  end
  
  if not del_anim_t and btnp(4) then
    del_anim_t = 0
    del_anim_f = 1
  end
  
  if t.music > 0 then
    t.music -= t.dt
    if t.music <= 0 then
      music(-1,1000)
      t.music_gap = game.music_gap_time
    end
  end
  
  if t.music_gap > 0 then
    t.music_gap -= t.dt
    if t.music_gap <= 0 then
      music(0,1000)
      t.music = game.music_time
    end
  end
  
		freeze.f = false
  
  local dx = 0
  local dy = 0
  local is_drop = false
  local is_trans = false
  
  t.drop -= t.dt
  if t.drop <= 0 then
    t.drop = game.drop_time
    dy = -1
  end

  if btnp(0) then
    dx = -1
  elseif btnp(1) then
    dx = 1
  end
		
		if btnp(3) then
    t.drop = game.drop_time
    dy = -1
  elseif btnp(4) then
    is_trans = true
  elseif btnp(5) then
    is_drop = true
		end
  
  if is_drop then
    t.drop = game.drop_time
    for by=shape.by,0,-1 do
      if is_shape_freeze(shape.t,shape.bx,by) then
        freeze.f = true
        freeze.by = by+1
        break		        
      end
    end
  elseif dy < 0 then
    if not shape_move(0,dy) then   
		    freeze.f = true
		    freeze.by = shape.by
    end
  elseif dx ~= 0 then
    if shape_move(dx,0) then
      freeze.d = true
    end
  elseif is_trans then
    local st = shapes[shape.t]
    if not is_shape_freeze(st.n,shape.bx,shape.by) then
      shape.t = st.n
      freeze.d = true
    end
  end
  
  if freeze.d then
    freeze.d = false
    for by=shape.by,0,-1 do
      if is_shape_freeze(shape.t,shape.bx,by) then
        freeze.pby = by+1
        break		        
      end
    end
  end
  
  if freeze.f then
    if shape_freeze(shape.t,shape.bx,freeze.by) then
		    -- remove full rows
		    local n=0
		    local by=1
		    while by <= area.bh do
		      if blocks[by] == full_row_mask then
		        deli(blocks,by)
		        add(blocks,0)
		        n+=1
		      else
		        by += 1
		      end    
		    end
		    game.score += n
		    new_shape()
		  else
		    printh("== game over")
		    init_game()
		  end
  end
end

function shape_freeze(t,bx,by)
  local ret = true
  foreach_shape_blocks(t,function(sx,sy)
    local bx = bx + sx
    local by = by + sy
    if bx >= 1 and bx <= area.bw and
      by >= 1 and by <= area.bh
    then
      set_block(bx,by)
    else
      ret = false
    end
  end)
  return ret
end

function is_shape_freeze(t,bx,by)
  local st = shapes[t]
  local l = bx - st.ox
  local r = l + st.w - 1
  local b = by - st.oy
--  local t = b + st.h - 1
  local is_in_area =
    l >= 1 and
    r <= area.bw and
    b >= 1
    
  if not is_in_area then
    return true
  end
    
  local is_conflict = false
  foreach_shape_blocks(t, function(sx,sy)
    if has_block(bx + sx,
      by + sy)
    then
      is_conflict = true
    end
  end)
  
  if is_conflict then
    return true
  end
  
  return false
end

function shape_move(dx,dy)
  local bx = shape.bx + dx
  local by = shape.by + dy
  
  if is_shape_freeze(shape.t,bx,by) then
    return false
  end
  
  shape.bx = bx
  shape.by = by
  
  return true
end

function draw_block(x,y)
  sspr(8,0,block.s,block.s,x,y)
end

function draw_area_block(bx,by,s,m)
  s = s or 0
  m = m or 0
  if bx >= 1 and
    bx <= area.bw and
    by >= 1 and
    by <= area.bh
  then
    local x = area.x + (bx-1) * block.s
				local y = (area.y + area.h - block.s) -
				      (by-1) * block.s
    if s == 1 then
      local x1 = x + block.s - 1
      local y1 = y + block.s - 1
      fillp(0b1010010110100101.100)
      if 0b1000 & m == 0 then
        line(x,y,x,y1,0x77)
      end
      if 0b0100 & m == 0 then
        line(x1,y,x1,y1,0x77)
      end
      if 0b0010 & m == 0 then
        line(x,y,x1,y,0x77)
      end
      if 0b0001 & m == 0 then
        line(x,y1,x1,y1,0x77)
      end
      fillp()
    else
				  draw_block(x,y)
				end
		end
end

function blocks_row_mask(bx)
  return 1 << (area.bw - bx)
end

function has_block(bx,by)
  if bx < 1 or
    bx > area.bw or
    by < 1 or
    by > area.bh
  then
    return false
  end
  
  return blocks_row_mask(bx)
		  & blocks[by] > 0
end

function set_block(bx,by)
  blocks[by] |= blocks_row_mask(bx)  
end

function clear_block(bx,by)
  blocks[by] &= ~blocks_row_mask(bx)
end

function draw_blocks()
		for y=1,area.bh do
		  for x=1,area.bw do
		    if has_block(x,y) then
		      draw_area_block(x,y)
		    end
		  end
		end
end

function draw_area()
  rect(area.x-1, area.y-1,
    area.x+area.w,
    area.y+area.h,7)
end

function shape_has_block(t,sx,sy)
  local st = shapes[t]
  if sx < 0 or
    sx >= st.w or
    sy < 0 or
    sy >= st.h
  then
    return false
  end
  local m = 1 << sy * st.w + (st.w - sx - 1)
  return m & st.m > 0
end

function foreach_shape_blocks(t,cb,m)
  m = m or 0
  local st = shapes[t]
  local ox = st.ox
  local oy = st.oy
  -- lt
  if m == 1 then
    ox = 0
    oy = st.h - 1
  -- lb
  elseif m == 2 then
    ox = 0
    oy = 0
  end
  for sx=0,st.w-1 do
    for sy=0,st.h-1 do
      if shape_has_block(t,sx,sy) then
        if cb then
          cb(sx - ox, sy - oy)
        end
      end
    end
  end  
end

function draw_shape(t,x,y,s)
	 foreach_shape_blocks(t, function(sx,sy)
    draw_block(
      x + sx * block.s,
      y + -sy * block.s)   
  end,s)
end

function draw_area_shape(t,bx,by,s)
--  printh("shape: " .. tostr(t) .. ", s: " .. tostr(s))
  local st = shapes[t]
  foreach_shape_blocks(t, function(sx,sy)
    local m = 0
    if shape_has_block(t,sx-1+st.ox,sy+st.oy) then
      m |= 0b1000
    end
    if shape_has_block(t,sx+1+st.ox,sy+st.oy) then
      m |= 0b0100
    end
    if shape_has_block(t,sx+st.ox,sy+1+st.oy) then
      m |= 0b0010
    end
    if shape_has_block(t,sx+st.ox,sy-1+st.oy) then
      m |= 0b0001
    end
--    printh("sx: " .. tostr(sx+st.ox) .. ", sy: " .. tostr(sy+st.oy) .. ", m: " .. tostr_bits(m,4))
    draw_area_block(
      bx + sx,
      by + sy,
      s,m)
  end)
end

function _draw()
  cls(1)
  
--  print("music: " .. tostr(flr(t.music)) .. ", gap: " .. tostr(flr(t.music_gap)), 10, 3)
  print("score: " .. tostr(game.score), 10, 17)
--  print("x: " .. tostr(shape.bx) .. " y: " .. tostr(shape.by) .. ", t: " .. tostr(shape.t) .. ", nt: " .. tostr(next_shape.t), 10, 10)
  
  palt()
  if del_anim_t then
    local fa = del_anim.frames[del_anim_f]
--		  printh(">> fa: " .. tostr(fa.x) .. ", " .. tostr(fa.y))
		  for i=1,4 do
  		  if fa.x and fa.y then
				    sspr(fa.x,fa.y,4,4,100+i*4,10)
				  end
				end
  end

  palt(0)
  draw_area_block(shape.bx, shape.by)
  draw_blocks()
  draw_area()
  palt()
  if not freeze.d then
    draw_area_shape(shape.t,shape.bx,freeze.pby,1)
  end
  palt(0)
  draw_area_shape(shape.t,shape.bx,shape.by)
  draw_shape(next_shape.t,next_shape.x,next_shape.y,next_shape.m)
end
-->8
shapes = {
  -- 1 11 2 111 3 01 4 100
  --   10   001   01   111
  --   10         11 
  { w=2, h=3, m=0b111010, ox=0, oy=2, n=2, p=4 },
  { w=3, h=2, m=0b111001, ox=2, oy=1, n=3, p=1 },
  { w=2, h=3, m=0b010111, ox=1, oy=0, n=4, p=2 },
  { w=3, h=2, m=0b100111, ox=0, oy=0, n=1, p=3 },
  -- 5 11 6 001 7 10 8 111
  --   01   111   10   100
  --   01         11 
  { w=2, h=3, m=0b110101, ox=1, oy=2, n=6, p=8 },
  { w=3, h=2, m=0b001111, ox=2, oy=0, n=7, p=5 },
  { w=2, h=3, m=0b101011, ox=0, oy=0, n=8, p=6 },
  { w=3, h=2, m=0b111100, ox=0, oy=1, n=5, p=7 },  
  -- 9 10 10 011
  --   11    110
  --   01 
  { w=2, h=3, m=0b101101, ox=1, oy=1, n=10, p=10 },
  { w=3, h=2, m=0b011110, ox=1, oy=0, n=9, p=9 },
  -- 11 01 12 110
  --    11    011
  --    10 
  { w=2, h=3, m=0b011110, ox=0, oy=1, n=12, p=12 },
  { w=3, h=2, m=0b110011, ox=1, oy=0, n=11, p=11 },
  -- 13 01 14 010 15 10 16 111
  --    11    111    11    010
  --    01           10
  { w=2, h=3, m=0b011101, ox=1, oy=1, n=14, p=16 },
  { w=3, h=2, m=0b010111, ox=1, oy=0, n=15, p=13 },
  { w=2, h=3, m=0b101110, ox=0, oy=1, n=16, p=14 },
  { w=3, h=2, m=0b111010, ox=1, oy=1, n=13, p=15 },
  -- 17 1111 18 1
  --            1
  --            1
  --            1
  { w=4, h=1, m=0b1111, ox=0, oy=0, n=18, p=18 },
  { w=1, h=4, m=0b1111, ox=0, oy=3, n=17, p=17 },
  -- 19 11
  --    11
  { w=2, h=2, m=0b1111, ox=0, oy=1, n=19, p=19 }
}
-->8
function tostr_bits(n,p)
  p = p or 0
  local s = ""
  while flr(n) > 0 do
    if n & 0b1 > 0 then
		    s = tostr(1) .. s
		  else
		    s = tostr(0) .. s
		  end
		  n = n >>> 1
		end
		p -= #s
		for i=1,p do
		  s = tostr(0) .. s
		end
		return "0b" .. s
end
__gfx__
00000000677677776776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000766070077660677667760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000766070077660600500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600577776005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012000001c3301c33017330183301a3301a3301833017330153301533015330183301c3301c3301a33018330173301733017330183301a3301a3301c3301c3301833018330153301533015330153300000000000
01200000000001a3301a3301d33021330213301f3301d3301c3301c3301c330183301c3301c3301a33018330173301733017330183301a3301a3301c3301c3301833018330153301533015330153300000000000
__music__
00 00414344
00 01424344

