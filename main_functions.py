#Called upon class creation
Init()
	
#Called upon game start
OnGameStart()
	
#Called every fixed update frame (0.02 seconds)
OnTick()
	
#Called every update frame
OnFrame()
	
#Called after every update frame
OnLateFrame()	

#Called every second
OnSecond()
	
#Called upon chat input from the player
OnChatInput(message: string)
	
#Called upon any player spawning
OnPlayerSpawn(player: Player, character: Character)
	
#Called upon any character spawning
OnCharacterSpawn(character: Character)
	
#Called upon a character dying. Killer may be null.
OnCharacterDie(victim: Character, killer: Character, killerName: string)

#Called upon a character being damaged. Killer may be null.
OnCharacterDamaged(victim: Character, killer: Character, killerName: string, damage: Int)
	
#Called upon a player joining the room
OnPlayerJoin(player: Player)
	
#Called upon a player leaving the room
OnPlayerLeave(player: Player)
	
#Called upon receiving Network.SendMessage. 
OnNetworkMessage(sender: Player, message: string)

#Called upon a UI button with given name being pressed.
OnButtonClick(buttonName: string)
	
