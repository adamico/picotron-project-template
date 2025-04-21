local pgui = require('pgui')

local Title = SceneManager:addState('Title')

local new_game_clicked = false
local quit_clicked = false

local font_width = 5
local font_height = 5

function Title:update()
  pgui:refresh()
  local new_game_text  = 'New Game'
  local quit_text      = 'Quit'

  local max_text_width = max(#new_game_text, #quit_text)
  local margin         = 3
  local gap            = 3
  local contents       = {
    {'button', {text=new_game_text, margin=margin, stroke=true}},
    {'button', {text=quit_text,     margin=margin, stroke=true}}
  }

  local buttons_stack_pos = vec(
    Screen.w/2 - max_text_width*font_width/2 - margin*2,
    Screen.h/2 - #contents*font_height/2     - margin*2
  )

  local stack = pgui:component('vstack', {
    box      = false,
    contents = contents,
    color    = {16, 9, 7, 0},
    gap      = gap,
    height   = 0,
    margin   = 0,
    pos      = buttons_stack_pos,
    stroke   = false
  })

  new_game_clicked = stack[1]
  quit_clicked = stack[2]

  if new_game_clicked then Game:gotoState('Play') end
end

function Title:draw()
  cls()
  pal()
  rectfill(0, Screen.h/8, Screen.w, Screen.h/4, 3)
  print(GameTitle, Screen.w/2 - #GameTitle*font_width/2, Screen.h/8 + font_height*2, 7)

  if quit_clicked then print("Clicked Quit!", 0, 0, 7) end

  local footer = 'V'..GameVersion..' by '..GameAuthor..' '..GameDate

  line(0, Screen.h/2, Screen.w, Screen.h/2, 1)

  rectfill(0, Screen.h - 20, Screen.w, Screen.h, 1)
  print(footer, Screen.w - #footer*font_width-font_width*4, Screen.h - 14, 7)
  pgui:draw()

  -- self:drawGuides()
end

function Title:drawGuides()
  line(Screen.w/2, 0, Screen.w/2, Screen.h, 7)
  line(0, Screen.h/2, Screen.w, Screen.h/2, 7)
end

function Title:enteredState() end
function Title:exitedState() end

return title