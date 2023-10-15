pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

x=5
y=5
size=6

function _draw()
  cls()
  
  palt(0)
  
  for j=1,4 do
				for i=1,8 do
				  local c = i+(j-1)*8-17
				  local px=x+(i-1)*15
				  local py=y+(j-1)*25
				  print(c,px,py,7)
				  py+=10
				  rectfill(px,py,px+size,py+size,c)
				end
		end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
