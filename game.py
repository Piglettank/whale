## Game

# Game functions such as spawning titans and managing game state.
Field	        Type	        Readonly	    Description
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
IsEnding        bool            true            Is the game currently ending.
EndTimeLeft     float           true            Time left before game restarts.
Titans          List(Titan)     true            List of titans currently alive.
Shifters	    List(Shifter)	true	        List of shifters currently alive.
Humans	        List(Human)	    true	        List of humans currently alive.
AITitans	    List(Titan)	    true	        List of AI titans currently alive.
AIShifters	    List(Shifter)	true	        List of AI shifters currently alive.
AIHumans	    List(Human)	    true	        List of AI humans currently alive.
PlayerTitans	List(Titan)	    true	        List of player titans currently alive.
PlayerShifters	List(Shifter)	true	        List of player shifters currently alive.
PlayerHumans	List(Human)	    true	        List of player humans currently alive.
Loadouts	    List(string)	true	        List of allowed player loadouts.

# Functions
Function                                    Returns	    Description
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
Debug(message: string)	                    null	    Prints a message to the debug console (accessible using F11).
Print(message: string)	                    null	    Prints a message to the chat window.
PrintAll(message: string)	                null	    Prints a message to all players chat window.
End(delay: float)	                        null	    Ends the game and restarts after given delay. Master client only.
SpawnTitan(type: string)	                Titan	    Spawn a titan. Master client only. Valid types: "Default", "Dummy", "Normal", "Abnormal", "Punk", "Crawler".
SpawnTitanAt(                               Titan       Spawn a titan at position. Master client only.
    type: string, 
    position: Vector3, 
    optional rotationY: float
    )	                    	 
SpawnTitans(type:string, amount: int)	    List(Titan)	Spawn amount titans. Master client only
SpawnTitansAt(                              List(Titan) Spawn amount titans at position. Master client only
    type:string, 
    amount: int, 
    position: Vector3, 
    optional rotationY: float
    )		
SpawnTitansAsync(type: string, amount: int)	null	    Spawn amount titans over time. Note that no titan list is returned.
SpawnTitansAtAsync(                         null	    Spawn amount titans at position over time.
    type: string, 
    amount: int, 
    position: Vector3, 
    optional rotationY: float
    )	
SpawnShifter(type: string)	                Shifter	    Spawn a shifter. Master client only. Valid types: "Annie"
SpawnShifterAt(type: string, position: Vector3, optional rotationY: float)	Shifter	Spawn a shifter at position.
SpawnPlayer(player: Player, force: bool)	null	Spawns the given player. Must be the given player or masterclient. If force is true, will kill the existing player and respawn them, otherwise will only spawn if the player is dead.
SpawnPlayerAt(player: Player, force: bool, position: Vector3, optional rotationY: float)	null	Spawns the player at a given position.
SpawnPlayerAll(force: bool)	null	Spawns all players. Master client only.
SpawnPlayerAtAll(force: bool, position: Vector3, optional rotationY: float)	null	Spawns all players at position.
GetGeneralSetting(setting: string)	bool | int | float | string	Retrieves the value of the given general tab setting. Dropdown setting's values are ordered 0,n.Example: GetGeneralSetting("Difficulty") returns 0 for training, 1 for easy, 2 for normal, and 3 for hard.
GetTitanSetting(setting: string)	bool | int | float | string	Retrieves the value of the given titan tab setting.
GetMiscSetting(setting: string)	bool | int | float | string	Retrieves the value of the given misc tab setting. Dropdown setting's values are ordered 0,n.Example: GetMiscSetting("PVP")returns results ordered 0,n in order of the dropdown list of the setting.0 for off, 1 for ffa, and 2 for teams.
SpawnProjectile(projectile: string, position: Vector3, rotation: Vector3, velocity: Vector3, gravity: Vector3, liveTime: float, team: string, [extra params])	null	Spawns a projectile. Valid projectiles: ThunderSpear, CannonBall, Flare, BladeThrow, Smokebomb, Rock1. ThunderSpear takes two extra params (radius: float, color: Color)Flare takes extra param (color: Color).
SpawnProjectileWithOwner(projectile: string, position: Vector3, rotation: Vector3, velocity: Vector3, gravity: Vector3, liveTime: float, owner: Character, [extra params])	null	Spawns a projectile from the given character as its owner.
# Valid effects: ThunderSpearExplode, GasBurst, GroundShatter, Blood1, Blood2, PunchHit, GunExplode, CriticalHit, TitanSpawn, TitanDie1, TitanDie2, Boom1, Boom2..., Boom7, TitanBite, ShifterThunder, BladeThrowHit, APGTrail, SingleSplash, WaterWake, Splash, Splash1...Splash3. ThunderSpearExplode takes extra params explodeColor (Color) and killSound (bool).
SpawnEffect(effect: string, position: Vector3, rotation: Vector3, scale: float, [params])	null	Spawns an effect. 
SetPlaylist(playlist: string)	null	Sets the music playlist. Valid playlists: Default, Boss, Menu, Peaceful, Battle, 
RacingSetSong(song: string)	null	Sets the music song.
FindCharacterByViewID(viewID: int)	Character	Returns character from View ID.


class Titan {

}

component WarpZoneB {
    function OnCollisionEnter(other) {
        if(other.Type == "Human") 
        {
            warpA = Map.FindMapObjectByName("PipeHeadA");
            other.Position = warpA.Position;
            other.AddForce(Vector3(0, 10000.0, 0))
        }
    }
}