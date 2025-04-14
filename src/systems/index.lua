local system_names = {
	"animateActors",
	"capture",
	"drawDebug",
	"drawActors",
	"drawBullets",
	"drawSpawners",
	"drawUI",
	"handleInput",
	"killBullets",
	"moveActors",
	"moveBullets",
	"moveCamera",
	"shoot",
	"spawnEnemies",
	"updateActorState"
}

for name in all(system_names) do
	include("src/systems/"..name..".lua")
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