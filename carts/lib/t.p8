pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

t_name = nil
t_tests = {}

function t_begin(name)
  t_name = name
  t_tests = {}
end

function t_ok(cond, msg)
  msg = msg or "-"
  if t_name then
    add(t_tests, { cond=cond, msg=msg })
  end
end

function t_end()
  if t_name then
    local fails = {}
    
    for i=1,#t_tests do
      local t=t_tests[i]
      if not t.cond then
        add(fails, {i=i,t=t})
      end
    end
    
    printh("== test ["
      .. t_name .. "] "
      .. (#fails == 0 and "success" or "fail"))
  
    for t in all(fails) do
      printh(" "
       .. t.i .. "/" .. #t_tests
       .. " "
       .. t.t.msg)
    end
  end
end
-->8

function _init()
  t_begin("ttt")
  t_ok(true, "t1")
  t_ok(false, "t2")
  t_ok(false, "t3")
  t_ok(true, "t4")
  t_ok(true, "t5")
  t_ok(false, "t6")
  t_end()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000