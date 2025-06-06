# Ideas: 
# Small and speedy titans RunSpeedBase
# Piñata titans
# AND one at the bridde
# Pumpkin soccer in the treee!!!
# more titan spawn points
#
# BUGS
# OnCharacterDie error probably masterclient
# Null check on island titan roaring and growing coroutine  

class Main
{
    BaseTitanAmount = 36;
    SeaTitanAmount = 6;
    
    CrawlerEnabled = true;
    ConfusedTitanEnabled = true;

    TitanRainEnabled = true; 
    TitanRainStartAmount = 15;
    TitanRainAmount = 15;

    ExplodersEnabled = true;
    ExploderStartAmount = 10;

    TeleportTitansEnabled = true;

    IslandTitanEnabled = true;
    IslandTitanMaxHealth = 7000;
    IslandTitanAngerThreshold = 0.5;

    _dialogTimer = 0;

    _crawlerSizeId = 2.001;
    _explodingSizeId = 2.005;
    _teleporerSizeID = 1.505;
    _chillingTitanSizeId = 2.205;
    _islandTitanSizeId = 3.001;

    _confusedTitanMaxHealthId = 2153;
    _confusedTitanGrowSpeed = 0.04;
    _confusedTitanStartSize = 3.0;

    _hasSpawned = false;
    _testPosition = Vector3();

    _gooberRotationTimerBase = 15;
    _gooberRotationTimer = 15;

    # @type List<int>
    _playerIdList = List();
    _playerCandyAmount = List();


    function OnGameStart()
    {
        if(Network.IsMasterClient) 
        {
            self._testPosition = Map.FindMapObjectByName("TestPosition").Position;
            Game.SpawnTitans("Default", self.BaseTitanAmount);
            self.SpawnConfusedTitan();
            self.SpawnSeaTitans();
            self.SpawnChillingBros();
            self.SpawnBabyCrawler();
            self.RandomizeCandySpawns();

            #teleporterTitan = Game.SpawnTitanAt("Normal", self._testPosition);
            #teleporterTitan.Size = self._teleporerSizeID;
            #teleporterTitan.MaxHealth = 3;
        }
    }

    

    function OnCharacterDie(victim, killer, killerName)
    {
        if(victim.Type == "Titan") 
        {
            # @type Titan
            titan = victim;
            if(victim.Name == "Island Titan")
            {
                Cutscene.ShowDialogue("Titan10", "Announcer", killerName + " killed the Island Titan!");
                self.SetDialogTimer(3);
            }
            if(titan.Size == self._crawlerSizeId)
            {
                Cutscene.ShowDialogue("Titan10", "Announcer", killerName + " has killed the cave crawler!");
                self.SetDialogTimer(3);
            }
            if(titan.MaxHealth == self._confusedTitanMaxHealthId)
            {
                Cutscene.ShowDialogue("Titan10", "Announcer", killerName + " has killed the growing titan!");
                self.SetDialogTimer(3);
            }
            if(titan.Size == self._explodingSizeId)
            {
                _position = Vector3(titan.Position.X, titan.Position.Y + 20.0, titan.Position.Z);
                _spawnedTitans = Game.SpawnTitansAt("Default", 6, _position);
                
                for(titan in _spawnedTitans) 
                {
                    _random = Random();
                    _velocity = _random.RandomFloat(-120000, 120000);
                    _velocityz = _random.RandomFloat(120000, -120000);
                    _titanSize = _random.RandomFloat(0.3, 0.6);
                    titan.Size = _titanSize;
                    titan.WalkSpeedBase = 17.0;
                    titan.RunSpeedBase = 17.0;

                    titan.RotateSpeed = 3.0;
                    titan.AttackSpeedMultiplier = 1.8;
                    titan.AddForce(Vector3(_velocity, 133000.0, _velocityz));
                }

                Game.SpawnEffect("Boom1", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom2", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom3", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom4", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom5", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom6", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("Boom7", victim.Position, Vector3(), 3.0);
                Game.SpawnEffect("GroundShatter", victim.Position, Vector3(), 3.0);
            }
        }
    }

    function OnTick()
    {
        if (Network.IsMasterClient && !Game.IsEnding)
        {
            titans = Game.Titans.Count;
            humans = Game.Humans.Count;
            playerShifters = Game.PlayerShifters.Count;
            self.MoveRock();

            for(titan in Game.Titans)
            {
                if(titan.MaxHealth == self._confusedTitanMaxHealthId)
                {
                    self.GrowTitan(titan);
                }
            }

            if (humans > 0 || playerShifters > 0)
            {
                self._hasSpawned = true;
            }
            if (titans == self.TitanRainStartAmount) 
            {
                self.TitanRain();
            }
            if (titans == self.ExploderStartAmount) 
            {
                self.SpawnExplodingTitans();
            }
            if (titans == 0)
            {
                self.CandyWinner();
                Game.End(10.0);
                return;
            }
            #if(self.TitanRainEnabled) 
            #{
            #    UI.SetLabelAll("TopCenter", "Titans left until next event: " + Convert.ToString(titans - self.TitanRainStartAmount));
            #}
            #elif (self.ExplodersEnabled)
            #{
            #    UI.SetLabelAll("TopCenter", "Titans left until next event: " + Convert.ToString(titans - self.ExploderStartAmount));
            #}
            #else
            #{
            #    UI.SetLabelAll("TopCenter", "Titans left: " + Convert.ToString(titans));
            #}
        }
    }

    function OnSecond()
    {

        titans = Game.Titans.Count;
        humans = Game.Humans.Count;
        playerShifters = Game.PlayerShifters.Count;
        
        # Rotate the goober on the sky island for spooky experience
        self._gooberRotationTimer = self._gooberRotationTimer - 1;
        if(self._gooberRotationTimer < 1) 
        {
            goober = Map.FindMapObjectByName("SkyIslandGoober");
            goober.Rotation = goober.Rotation + Vector3(0, 20, 0);
            self._gooberRotationTimer = self._gooberRotationTimerBase;
        }

        # Timer for hiding dialog
        if(self._dialogTimer > 0) 
        {
            self._dialogTimer = self._dialogTimer - 1;
            if(self._dialogTimer == 0) 
            {
                Cutscene.HideDialogue();
            }
        }        

        if (titans == 0)
        {
            self.CandyWinner();
            Game.End(10.0);
            return;
        }
        else
        {
            self.CandyProgress();
        }
    }

    function SetDialogTimer(duration)
    {
        self._dialogTimer = duration;
    }

    coroutine MakeChill(titan)
    {
        for(tick in Range(0, 10, 1))
        {
            wait 1.0;
            titan.Idle(2);
            wait 1.0;
            titan.Cripple(50000.0);
        }
    }

    coroutine MakeLaugh(titan)
    {
        for(tick in Range(0, 100000, 1))
        {
            wait 1.0;
            titan.Idle(3);
            wait 2.0;
            titan.Emote("Laugh");
        }
    }

    coroutine TitanRain() 
    {
        if(Network.IsMasterClient && self.TitanRainEnabled) {
            self.TitanRainEnabled = false;

            Cutscene.ShowDialogue("Titan10", "Announcer", "Holy guacamole it's raining titans!");
            self.SetDialogTimer(3);

            random = Random();
            RainA = Map.FindMapObjectByName("TitanRainA");
            RainB = Map.FindMapObjectByName("TitanRainB");
            
            i = 0;
            while(i < self.TitanRainAmount) 
            {
                delay = random.RandomFloat(0.8, 2.7);
                wait delay;
                RandomPosition = random.RandomVector3(RainA.Position, RainB.Position);
                Game.SpawnTitanAt("Default", RandomPosition);
                i = i + 1;
            }
        }
    }


    # Spawn Functions
    function SpawnCaveCrawler() 
    {
        if(Network.IsMasterClient) 
        {
            CrawlerSpawn = Map.FindMapObjectByName("Crawler Spawn");    
            CaveCrawler = Game.SpawnTitanAt("Crawler", CrawlerSpawn.Position);
            CaveCrawler.Size = self._crawlerSizeId;
            CaveCrawler.MaxHealth = 1000;
            CaveCrawler.Health = 1000;
            CaveCrawler.Name = "Cave Crawler";
            CaveCrawler.Emote("Roar");
            self.CrawlerEnabled = false;
        } 
    }

    function SpawnConfusedTitan() 
    {
         if(self.ConfusedTitanEnabled)
        {
            _confusedSpawn = Map.FindMapObjectByName("ConfusedSpawn").Position;
            _confusedTitan = Game.SpawnTitanAt("Normal", _confusedSpawn);
            _confusedTitan.Size = self._confusedTitanStartSize;
            _confusedTitan.MaxHealth = self._confusedTitanMaxHealthId;
            _confusedTitan.Health = self._confusedTitanMaxHealthId - 847;
        }
    }

    function SpawnBabyCrawler()
    {
        babySpawn = Map.FindMapObjectByName("Baby Crawler Spawn").Position;
        babyCrawler = Game.SpawnTitanAt("Crawler", babySpawn);
        babyCrawler.Size = 0.3;
        babyCrawler.RunSpeedBase = 0.2;
        babyCrawler.WalkSpeedBase = 0.2;
        babyCrawler.JumpForce = 0.4;
        babyCrawler.Name = "Baby crawlie";
    }

    function SpawnChillingBros()
    {
        chillerSpawn = Map.FindMapObjectByName("Chilling Titan Spawn").Position;
        chiller = Game.SpawnTitanAt("Normal", chillerSpawn, 270);
        chiller.Size = 4.0;
        chiller.DetectRange = 0.0;
        chiller.FocusRange = 0.0;
        chiller.Name = "Chiller";
        self.MakeChill(chiller);
        laugherSpawn = Map.FindMapObjectByName("Laughing Titan Spawn").Position;
        laugher = Game.SpawnTitanAt("Normal", laugherSpawn, 30);
        laugher.Size = 3.0;
        laugher.DetectRange = 0.0;
        laugher.FocusRange = 0.0;
        laugher.Name = "Happy titan";
        self.MakeLaugh(laugher);
    }

    function SpawnSeaTitans()
    {
        
        seaSpawn = Map.FindMapObjectByName("Sea Titan Spawn");
        
        for(index in Range(0, self.SeaTitanAmount, 1)) 
        {
            pos = self.RandomRegionPosition(seaSpawn);
            corners = seaSpawn.GetCorners();
            a = corners.Get(0);
            b = corners.Get(7);
            position = Random().RandomVector3(a, b);
            size = Random().RandomFloat(2.9, 4.8);
            
            titan = Game.SpawnTitanAt("Default", position);
            titan.Size = size;

            index = index + 1;
        }      
    }

    function SpawnExplodingTitans() 
    {
        if(Network.IsMasterClient && self.ExplodersEnabled) 
        {
            self.ExplodersEnabled = false;
            
            Game.Print("Exploding titans have spawned!");

            ExploderSpawn = Map.FindMapObjectByName("Exploder Spawn"); 
            _exploder = Game.SpawnTitanAt("Normal", ExploderSpawn.Position);
            _exploder2 = Game.SpawnTitanAt("Normal", ExploderSpawn.Position);
            _exploder.Size = self._explodingSizeId;
            _exploder2.Size = self._explodingSizeId;
            _exploder2.MaxHealth = 2;
            _exploder.MaxHealth = 2;
        } 
    }

    function SpawnTeleportingTitans()
    {

    }

    function SpawnIslandTitan() 
    {
        if(Network.IsMasterClient) 
        {
            SpawnPoint = Map.FindMapObjectByName("Island Titan Spawn");    
            titan = Game.SpawnTitanAt("Thrower", SpawnPoint.Position);
            titan.Size = self._islandTitanSizeId;
            titan.MaxHealth = self.IslandTitanMaxHealth;
            titan.Health = self.IslandTitanMaxHealth;
            titan.Name = "Island Titan";
            titan.AttackSpeedMultiplier = 2;
            titan.AttackPause = 0.4;
            titan.DetectRange = 100000;
            titan.FocusRange = 100000;
            titan.AttackWait = 0.4;
            titan.RunSpeedBase = 25;
            titan.RotateSpeed = 5;

            titan.Emote("Roar");
            self.IslandTitanBehaviour(titan);
            self.IslandTitanEnabled = false;
        } 
    }

    function RandomizeCandySpawns() {
        candies = Map.FindMapObjectsByTag("candy");
        realCandies = List();

        for(candy in candies) {
            keepCandy = Random().RandomFloat(0, 1) > 0.5;
            if(keepCandy) {
                realCandies.Add(keepCandy);
            } else {
                candyZoneName = candy.Name + "Zone";
                candyZone = Map.FindMapObjectByName(candyZoneName);
                candy.Active = false;
                candyZone.Active = false;
            }
        }

        Game.Print("There are " + Convert.ToString(realCandies.Count) + " candies this time.");
    }

    coroutine IslandTitanBehaviour(titan)
    {
        for(tick in Range(0, 100000, 1))
        {
            if(titan.Health != 0) 
            {
                wait 4.0;
                threshold = self.IslandTitanMaxHealth * self.IslandTitanAngerThreshold;
                isLow = titan.Health < threshold;
                
                if(isLow)
                {
                    titan.Idle(2.0);
                    wait 1.9;

                    titan.Emote("Roar");
                    wait 2.0;
                    titan.Size = titan.Size + 0.3;
                    titan.RunSpeedBase = titan.RunSpeedBase + 1;
                    Game.SpawnEffect("GroundShatter", titan.Position, Vector3(), titan.Size);
                    
                    wait 2.0;
                }
                else 
                {
                    titan.Idle(1.0);
                    wait 0.5;
                    titan.Emote("Laugh");
                    wait 3.0;
                }
            }
           
        }
    }

    function GrowTitan(titan)
    {
        sinwave = Math.Sin(Time.GameTime * 50);
        growth = self._confusedTitanGrowSpeed * sinwave;
        titan.Size = titan.Size + growth;
    }

    function MoveRock() 
    {
        v1 = Map.FindMapObjectsByName("vortex1");

        # @type List<float>
        list = List();
        list.Add(-0.77);
        list.Add(1.6);
        list.Add(2.86);
        list.Add(3.9);
        list.Add(4.92);
        list.Add(3.84);
        list.Add(3.38);
        list.Add(4.33);
        list.Add(4.23);
        list.Add(2.97);
        list.Add(4.02);
        list.Add(4.89);
        list.Add(3.25);
        list.Add(4.16);
        list.Add(-1.32);
        list.Add(3.5);
        list.Add(4.75);
        list.Add(4.82);
        list.Add(-4.14);
        list.Add(-4.03);
        list.Add(-4.96);
        list.Add(-4.89);
        list.Add(-0.78);
        list.Add(-3.85);
        list.Add(-0.28);
        list.Add(4.61);
        list.Add(-2.35);
        list.Add(1.9);
        list.Add(2.4);
        list.Add(-3.67);
        list.Add(-3.49);
        list.Add(-3.42);
        list.Add(-3.99);
        list.Add(-2.99);
        list.Add(-2.74);
        list.Add(-0.34);
        list.Add(-0.31);
        list.Add(0.41);
        list.Add(0.42);
        list.Add(-1.49);
        list.Add(3.01);
        list.Add(-0.49);
        list.Add(-2.56);
        list.Add(0.69);
        list.Add(2.44);
        list.Add(-4.81);
        list.Add(3.44);
        list.Add(-3.7);
        list.Add(-2.7);
        list.Add(-0.09);
        list.Add(2.05);
        list.Add(3.05);
        list.Add(0.55);
        list.Add(4.94);
        list.Add(1.8);
        list.Add(-2.02);
        list.Add(4.69);
        list.Add(-2.27);
        list.Add(1.98);
        list.Add(-4.34);
        list.Add(-4.27);
        list.Add(0.07);
        list.Add(0.22);
        list.Add(2.01);
        list.Add(3.19);
        list.Add(-1.18);
        list.Add(0.93);
        list.Add(-1.02);
        list.Add(1.25);
        list.Add(-4.59);
        list.Add(2.11);
        list.Add(-3.91);
        list.Add(4.64);
        list.Add(1.95);
        list.Add(-2.63);
        list.Add(3.65);
        list.Add(-4.38);
        list.Add(-1.92);
        list.Add(0.58);
        list.Add(1.02);
        list.Add(-3.25);
        list.Add(3.61);
        list.Add(2.9);
        list.Add(2.07);
        list.Add(-1.08);
        list.Add(-4.75);
        list.Add(4.06);
        list.Add(-1.76);
        list.Add(-1.94);
        list.Add(-1.71);
        list.Add(-0.22);
        list.Add(-4.53);
        list.Add(-2.21);
        list.Add(-2.63);
        list.Add(-0.7);
        list.Add(-1.4);
        list.Add(-0.46);
        list.Add(4.37);
        list.Add(0.98);
        list.Add(-1.38);
        list.Add(-3.61);
        list.Add(-4.64);
        list.Add(2.62);
        list.Add(4.47);
        list.Add(3.98);
        list.Add(2.54);
        list.Add(1.3);
        list.Add(1.41);
        list.Add(0.24);
        list.Add(3.48);
        list.Add(-3.33);
        list.Add(-2.19);
        list.Add(-0.02);
        list.Add(-3.03);
        list.Add(1.72);
        list.Add(2.13);
        list.Add(-3.15);
        list.Add(-4.92);
        list.Add(3.23);
        list.Add(-1.59);
        list.Add(-3.05);
        list.Add(2.65);
        list.Add(4.45);

        index = 0;
        
        for (rock in v1)
        {
            multiplier = list.Get(index);
            self.MoveOneRock(rock, multiplier);
            index = index+1;
        }
        
        ghostrock = Map.FindMapObjectByName("ghostrock");
        amptitude = 0.07;
        frequency = 60;
        time = Time.GameTime;
        sinwave = Math.Sin((time + 1)  * frequency);
        cowave = Math.Cos((time + 1) * frequency);
        sinwave2 = Math.Sin((time + 3)  * frequency * 2);
        sinwave3 = Math.Sin((time + 3)  * frequency * 2);
        cowave2 = Math.Cos((time + 8) * frequency * 3);
        cowave3 = Math.Cos((time + 8) * frequency * 3);

        movement = (sinwave * amptitude);
        movement2 = (cowave * amptitude);
        movement3 = (sinwave2 * amptitude * 2);
        movement4 = (cowave2 * amptitude * 2);
        movement5 = (sinwave3 * amptitude * 3);
        movement6 = (cowave3 * amptitude * 3);
        
        pos = ghostrock.Position;
        ghostrock.Position = Vector3(
            pos.X, 
            pos.Y + movement + movement3 + movement5, 
            pos.Z + movement2 + movement4 + movement6
        );
    }

    function MoveOneRock(rock, multiplier)
    {
        # @type MapObject()
        mRock = rock;
        amptitude = 0.45 * multiplier;
        frequency = 30 * multiplier;
        sinwave = Math.Sin(Time.GameTime  * frequency);
        cowave = Math.Cos(Time.GameTime * frequency);

        movement = sinwave * amptitude;
        movement2 = cowave * amptitude;
        pos = mRock.Position;
        mRock.Position = Vector3(pos.X, pos.Y + movement, pos.Z + movement2);
    }
    

    function EatCandy(name, id)
    {
        if(self._playerIdList.Contains(id) == false)
        {
            self._playerIdList.Add(id);
            self._playerCandyAmount.Add(0);
        }

        index = self.IndexOfValue(self._playerIdList, id);

        currentSnackAmount = self._playerCandyAmount.Get(index);
        currentSnackAmount = currentSnackAmount + 1;
        self._playerCandyAmount.Set(index, currentSnackAmount);
        
        Game.Print(name + " has eaten their " + Convert.ToString(currentSnackAmount) + " candy");

        candyAmount = Map.FindMapObjectsByTag("candy").Count;
        if(candyAmount == 10) {
            Game.Print("There are " + Convert.ToString(candyAmount) + " candies left.");
        }
        if(candyAmount == 5) {
            Game.Print("There are " + Convert.ToString(candyAmount) + " candies left.");
        }
        if(candyAmount == 0) {
            Game.Print("All the candies have been eaten! Enjoy titan rain!");
            self.TitanRainEnabled = true;
            self.TitanRain();
        }

    }

    function CandyProgress()
    {
       mostCandies = 0;
       winner = "No one";
       for(id in self._playerIdList)
       {
           candies = self.PlayerCandy(id);

           if(candies > mostCandies) 
           {
               mostCandies = candies;
               winner = self.PlayerName(id);
           }
       }

       titans = Game.Titans.Count;
       titansLeft = "(" + Convert.ToString(titans) + " titans left)";
       if(winner == "No one")
       {
           UI.SetLabelAll("TopCenter", "No one has found any candy. " + titansLeft);
       }
       else 
       {

           UI.SetLabelAll("TopCenter", winner + " is in the lead with " + Convert.ToString(mostCandies) + " candies. " + titansLeft);
       }
    }

    function CandyWinner()
    {
        mostCandies = 0;
        winner = "No one";
        for(id in self._playerIdList)
        {
            candies = self.PlayerCandy(id);

            if(candies > mostCandies) 
            {
                mostCandies = candies;
                winner = self.PlayerName(id);
            }
        }
        

        UI.SetLabelAll("MiddleCenter", "Gg! " + winner + " is the candy treasure hunt winner! They found " + Convert.ToString(mostCandies) + " candies!");
    }

    function PlayerCandy(id)
    {
        index = self.IndexOfValue(self._playerIdList, id);
        return self._playerCandyAmount.Get(index);
    }

    # Helpers
    function IndexOfValue(list, lookupValue)
    {
        index = 0;
        indexFound = false;
        while(!indexFound)
        {
            value = list.Get(index);
            if(value == lookupValue) 
            {
                indexFound = true;
            }
            else 
            {
                index = index + 1;
            }
        }

        return index;
    }

    function RandomRegionPosition(region) 
    {
        corners = region.GetCorners();
        a = corners.Get(0);
        b = corners.Get(7);
        position = Random().RandomVector3(a, b);

        return position;
    }

    function PlayerName(id)
    {
        for(player in Network.Players) {
            if(player.ID == id) {
                return player.Name;
            }
        }
        return "Player not found";
    }
}

component CrawlerGreeting {
    function OnCollisionExit(other) {
        if (other.Type == "Human" && Main.CrawlerEnabled == true)
        {
            # @type Human
            human = other;
            Main.SpawnCaveCrawler();
            Game.Print("The cave crawler has spawned!");
            Cutscene.ShowDialogue("Titan10", "Announcer", human.Name + " is first to enter the crawler cave!");
            Main.SetDialogTimer(3);
        }
    }
}

component WarpZone 
{

    WarpTarget = "Default";

    function OnCollisionEnter(other) {
    if(other.Type == "Human")
        {
            #@type Human
            human = other;
            warpB = Map.FindMapObjectByName(self.WarpTarget);
            human.Position = warpB.Position;
            yVelocity = Math.Abs(human.Velocity.Y * 100);
            human.AddForce(Vector3(0, 2900 + yVelocity, 0));
        }
    }
}

component CandyZone 
{

    CandyName = "Enter name of candy map component";

    function OnCollisionEnter(other) 
    {
        if(other.Type == "Human")
        {
            # @type Human
            human = other;
            self.MapObject.Active = false;
            candy = Map.FindMapObjectByName(self.CandyName);
            candy.Active = false;
            Game.SpawnEffect("Blood1", self.MapObject.Position, Vector3(), 1.0);
            Main.EatCandy(human.Player.Name, human.Player.ID);
        }
    }
}

component IslandZone 
{
    function OnCollisionEnter(other) {
        if (other.Type == "Human" && Main.IslandTitanEnabled == true)
        {
            # @type Human   
            human = other;
            Main.SpawnIslandTitan();
            Game.Print("ISLAND TITAN HAS SPAWNED!!!");
            Cutscene.ShowDialogue("Titan10", "Announcer", human.Name + " has awoken the island titan!");
            Main.SetDialogTimer(3);
        }
    }
}

component IslandTitanTeleportZone 
{

    function OnCollisionEnter(other) 
    {
        if(other.Type == "Titan")
        {
            #@type Titan
            titan = other;
            ExploderSpawn = Map.FindMapObjectByName("Exploder Spawn"); 
            titan.Position = ExploderSpawn.Position;
            Cutscene.ShowDialogue("Titan10", "Announcer", "The island titan is looking for prey on the main island!");
            Main.SetDialogTimer(3);
        }
    }
}
