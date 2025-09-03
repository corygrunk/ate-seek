-- ate-seek
-- 8 step sequencer

Tab = require('tabutil')
local enc1 = 0
local enc2 = 0
local enc3 = 1.0

counter = 0
notes = {0,3,5,6,7,9,11}
steps = {0,0,0,0,0,0,0,0}
selected_step = 1


function init() 
  clock.run(redraw_clock)
  screen_dirty = true
  clock.run(clk)
  crow.output[2].action = 'pulse()'
end

function clk()
  while true do
    clock.sync(1/4)
    counter = counter + 1
    if counter > #notes then counter = 1 end
    crow.output[1].volts = steps[counter]/12
    crow.output[2]()
    
    screen_dirty = true
  end
end


function key(n,z)
  if n == 1 and z == 1 then
    print('Key 1')
  elseif n == 2 and z == 1 then
    print('Key 2')
  elseif n == 3 and z == 1 then
    print('Key 3')
  end
  screen_dirty = true
end


function enc(n,d)
  if n == 1 then
    enc1 = util.clamp(enc1 + d,0,100)
  elseif n == 2 then
    enc2 = util.clamp(enc2 + d,1,#steps)
    selected_step = enc2
  elseif n == 3 then
    enc3 = util.clamp(enc3 + d,1,#notes)
    steps[selected_step] = notes[enc3]
  end
  screen_dirty = true
end


function redraw()
  screen.clear()
  screen.aa(0)
  screen.font_face(1)
  screen.font_size(8)
  screen.level(15)
  -- screen.pixel(0, 0) ----------- make a pixel at the north-western most terminus
  -- screen.pixel(127, 0) --------- and at the north-eastern
  -- screen.pixel(127, 63) -------- and at the south-eastern
  -- screen.pixel(0, 63) ---------- and at the south-western
  
local line_bottom = 50
local line_spacing = 127 / 12  -- Distribute 8 lines evenly across screen width
local line_length = 6         -- Length of each line

for i = 1, 8 do
    local x_start = i * line_spacing
    local x_end = x_start + line_length

    if i == selected_step then screen.level(15) else screen.level(4) end
    if i == counter then screen.level(8) end
    
    screen.move(x_start, line_bottom)
    screen.line(x_end, line_bottom)
    screen.stroke()
    
    screen.move(x_start + 3, line_bottom + 8)
    screen.text_center(steps[i])
    
    screen.move(5,5)
    screen.text(counter)
end


  screen.fill() ---------------- fill the termini and message at once
  screen.update() -------------- update space

  screen_dirty = false
end


function redraw_clock()
  while true do
    clock.sleep(1/15)
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
end



-- UTILITY TO RESTART SCRIPT FROM MAIDEN
function r()
  norns.script.load(norns.state.script)
end
