local system_names = {
	"animateActors",
	"capture",
	"drawDebug",
	"drawActors",
	"drawBullets",
	"drawEnemies",
	"drawSpawners",
	"handleInput",
	"killBullets",
	"moveActors",
	"moveBullets",
	"moveCamera",
	"shoot",
	"spawnEnemies",
	"updateActorState",
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