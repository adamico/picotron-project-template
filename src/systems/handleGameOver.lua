local HandleGameOver = tiny.system(class('HandleGameOver'))

function HandleGameOver:update(_dt)
  if #Players == 0 then
    Game:gotoState('GameOver')
  end
end

return HandleGameOver