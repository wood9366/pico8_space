pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- module: id

id_groups = {
  def = {
    ids = {},
    next = 0,
    max = 32767
  }
}

function id_init(groups)
  for grp in all(groups) do
    if grp.name then
      id_groups[grp.name] = {
        ids = {},
        next = 0,
        max = grp.max or 32767
      }
    end
  end
end

function id_get(group)
  group = group or "def"
  local grp = id_groups[group]
--  printh("> " .. grp.next)
--  for id in all(grp.ids) do
--    printh("  " .. id)
--  end
  if #grp.ids > 0 then
    return deli(grp.ids)
  else
    assert(grp.next <= grp.max,
      "id [" .. group .. "] max")
    local next_id = grp.next
    grp.next += 1
    return next_id
  end
end

function id_back(id, group)
  group = group or "def"
  local grp = id_groups[group]
  if id < grp.max
    and count(grp.ids, id) == 0
  then
    add(grp.ids, id)
  end
end
-->8
#include t.p8:0

id_init({
  { name = "anim", max = 5 },
  { name = "xxx", max = 2 }
})

t_begin("id")

t_ok(id_get("anim") == 0)
t_ok(id_get("anim") == 1)
t_ok(id_get("anim") == 2)
t_ok(id_get("xxx") == 0)
t_ok(id_get("xxx") == 1)
t_ok(id_get("anim") == 3)
t_ok(id_get("anim") == 4)
id_back(2,"anim")
t_ok(id_get("anim") == 2)
t_ok(id_get("xxx") == 2)
id_back(1,"xxx")
t_ok(id_get("xxx") == 1)
--t_ok(id_get("xxx") == 3)
id_back(0,"anim")
id_back(4,"anim")
t_ok(id_get("anim") == 4)
t_ok(id_get("anim") == 0)
t_ok(id_get("anim") == 5)
--t_ok(id_get("anim") == 6)

t_end()
__gfx__
00000000677600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000766067766776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000766060050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012000001c3301c33017330183301a3301a3301833017330153301533015330183301c3301c3301a33018330173301733017330183301a3301a3301c3301c3301833018330153301533015330153300000000000
01200000000001a3301a3301d33021330213301f3301d3301c3301c3301c330183301c3301c3301a33018330173301733017330183301a3301a3301c3301c3301833018330153301533015330153300000000000
__music__
00 00414344
00 01424344

