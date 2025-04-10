local system_names = {
	"animatePlayer",
	"capture",
	"drawDebug",
	"drawPlayer",
	"handleInput",
	"move",
	"moveCamera",
	"updatePlayerState",
}

for name in all(system_names) do
	include("systems/"..name..".lua")
end

-- drawPowerups()
-- drawParticles()
-- drawFloats()
-- drawUi()
-- playerShoot(Player, Position) -- instantiate player bullet entities
-- monsterShoot(Player, Position) -- instantiate monster bullet entities
-- collision()
-- spawnMonsters()
-- spawnLoot()
-- checkPlayerProtected()
-- checkPlayerForm()
-- playerTurn
-- doGameOver()
-- harmLoot()
-- executeMonsterAi()
-- getPowerUp()
-- doEndLevel()