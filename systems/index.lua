local system_names = {
	"animatePlayer",
	"capture",
	"drawDebug",
	"drawPlayer",
	"drawBullets",
	"drawEnemies",
	"drawSpawners",
	"handleInput",
	"killBullets",
	"move",
	"moveBullets",
	"moveCamera",
	"shoot",
	"spawnEnemies",
	"updatePlayerState",
}

for name in all(system_names) do
	include("systems/"..name..".lua")
end

-- drawPowerups()
-- drawParticles()
-- drawFloats()
-- drawUi()
-- collision()
-- spawnLoot()
-- checkPlayerProtected()
-- checkPlayerForm()
-- playerTurn
-- doGameOver()
-- harmLoot()
-- executeMonsterAi()
-- getPowerUp()
-- doEndLevel()