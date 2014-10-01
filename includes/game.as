﻿import classes.Characters.PlayerCharacter;
import classes.GUI;
import classes.StorageClass;
import classes.UIComponents.SquareButton;
import flash.events.Event;

public function get canSaveAtCurrentLocation():Boolean
{

	if(inCombat()) 
		return false;

	if (this.inSceneBlockSaving)
		return false;

	return this.rooms[this.currentLocation].canSaveInRoom
}

// Wrap some newline shit to make eventBuffer more consistent
public function addToEventBuffer(msg:String):void
{
	if (eventBuffer.length == 0)
	{
		eventBuffer += "\n" + msg;
	}
	else
	{
		eventBuffer += "\n\n" + msg;
	}
}



// Temp display stuff for perks
public function showPerkListHandler(e:Event = null):void
{
	var pButton:SquareButton = (userInterface as GUI).perkDisplayButton;
	if (pButton.isActive && !pButton.isHighlighted)
	{
		showPerksList();
		pButton.Highlight();
	}
	else if (pButton.isActive && pButton.isHighlighted)
	{
		userInterface.showPrimaryOutput();
		pButton.DeHighlight();
	}
}

public function showPerksList():void
{
	clearOutput2();
	clearGhostMenu();
	addGhostButton(0, "Next", showPerkListHandler);
	
	var perkList:Array = (pc as PlayerCharacter).perks;
	
	for (var i:int = 0; i < perkList.length; i++)
	{
		var perk:StorageClass = perkList[i] as StorageClass;
		if (perk.combatOnly == false)
		{
			output2("<b>" + perk.storageName + "</b> - " + perk.tooltip + "\n");
		}
	}
}

function crew(counter:Boolean = false):Number {
	if(!counter) {
		clearOutput();
		this.clearMenu();
	}
	var crewMessages:String = "";
	var count:int = 0;
	if(celiseIsCrew()) {
		count++;
		if(!counter) {
			this.addButton(count - 1,"Celise",celiseFollowerInteractions);
			crewMessages += "\n\nCelise is onboard, if you want to go see her. The ship does seem to stay clean of spills and debris with her around.";
		}
	}
	if(reahaIsCrew())
	{
		count++;
		if(!counter)
		{
			addButton(count-1,"Reaha",approachShipBoardReahaWhyDidntSavinCodeThisHeWasntExhaustedYesterday);
			crewMessages += "\n\nReaha is currently meandering around the ship, arms clutched under her hefty bosom, her nipples hooked up to a small portable milker.";
		}
	}
	if (annoIsCrew())
	{
		count++;
		if (!counter)
		{
			addButton(count - 1, "Anno", annoFollowerApproach);
			if (hours >= 6 && hours <= 7 || hours >= 19 && hours <= 20) crewMessages += "\n\nAnno is walking about in her quarters, sorting through her inventory and organizing some of her equipment.";
			else if (hours >= 12 || hours <= 13) crewMessages += "\n\nAnno's busy doing a quick workout in her quarters to the beat of some fast-paced ausar heavy metal. <i>“Gotta keep in shape!”</i> she says.";
			else crewMessages += "\n\nAnno is sitting in the common area with her nose buried in half a dozen different data slates. It looks like she's splitting her attention between the latest Warp Gate research and several different field tests of experimental shield generators.";
		}
	}
	if(!counter) {
		if(count > 0) {
			output("Who of your crew do you wish to interact with?" + crewMessages);
		}
		this.addButton(14,"Back",mainGameMenu);
	}
	return count;
}
function rest():void {
	//Turn encounters back on.
	flags["ENCOUNTERS_DISABLED"] = undefined;

	clearOutput();
	if(this.chars["PC"].HPRaw < this.chars["PC"].HPMax()) {
		this.chars["PC"].HP(Math.round(this.chars["PC"].HPMax() * .2));
	}
	if(this.chars["PC"].energy() < this.chars["PC"].energyMax()) {
		this.chars["PC"].energy(Math.round(this.chars["PC"].energyMax() * .2));
	}
	var minutes:int = 230 + rand(20) + 1;
	processTime(minutes);
	output("You sit down and rest for around " + num2Text(Math.round(minutes/60)) + " hours.");
	this.clearMenu();
	this.addButton(0,"Next",mainGameMenu);
}

function sleep(outputs:Boolean = true):void {
	
	//Turn encounters back on.
	flags["ENCOUNTERS_DISABLED"] = undefined;
	
	var minutes:int = 420 + rand(80) + 1
	
	if(outputs) 
	{
		clearOutput();
		
		// Anno interjection
		if (flags["ANNO_SLEEPWITH_INTRODUCED"] == undefined && annoIsCrew())
		{
			annoSleepWithIntroduce();
			return;
		}
		
		if ((pc.XPRaw >= pc.XPMax()) && pc.level < 7 && flags["LEVEL_UP_AVAILABLE"] == undefined)
		{
			(pc as PlayerCharacter).unspentStatPoints += 13;
			(pc as PlayerCharacter).unclaimedClassPerks += 1;
			(pc as PlayerCharacter).unclaimedGenericPerks += 1;
			
			pc.level++;
			pc.XPRaw = 0;
			pc.maxOutHP();
			
			// Enable the button
			userInterface.levelUpButton.Activate();
			
			eventBuffer += "\n\nA nights rest is just what you needed; you feel faster... stronger... harder....\n<b>Level Up is available!</b>";
		}
		
		//CELISE NIGHT TIME BEDTIMEZ
		if(celiseIsCrew() && rand(3) == 0 && flags["CREWMEMBER_SLEEP_WITH"] == undefined)
		{
			celiseOffersToBeYourBedSenpai();
			return;
		}
		else if (annoIsCrew() && rand(3) == 0 && flags["CREWMEMBER_SLEEP_WITH"] == "ANNO")
		{
			annoSleepSexyTimes();
			return;
		}
		
		output("You lie down and sleep for about " + num2Text(Math.round(minutes/60)) + " hours.");
	}
	
	if (this.chars["PC"].HPRaw < this.chars["PC"].HPMax()) 
	{
		this.chars["PC"].HP(Math.round(this.chars["PC"].HPMax()));
	}
	
	if (this.chars["PC"].energy() < this.chars["PC"].energyMax()) this.chars["PC"].energyRaw = this.chars["PC"].energyMax();
	
	processTime(minutes);

	mimbraneSleepEvents();
	
	this.clearMenu();
	if (flags["ANNO_SLEEPWITH_DOMORNING"] != undefined) this.addButton(0, "Next", annoMorningRouter);
	else this.addButton(0,"Next",mainGameMenu);
}

function shipMenu():Boolean {
	rooms["SHIP INTERIOR"].outExit = shipLocation;
	this.addButton(9,"Fly",flyMenu);

	if(shipLocation == "TAVROS HANGAR") {
		setLocation("SHIP\nINTERIOR","TAVROS STATION","SYSTEM: KALAS");
	}
	else if(shipLocation == "SHIP HANGAR") {
		setLocation("SHIP\nINTERIOR","MHEN'GA","SYSTEM: ARA ARA");
	}
	else if(shipLocation == "201") setLocation("SHIP\nINTERIOR","TARKUS","SYSTEM: REDACTED");
	else if(shipLocation == "500") setLocation("SHIP\nINTERIOR","NEW TEXAS","SYSTEM: NYE");
	if(currentLocation == "SHIP INTERIOR") {
		if(crew(true) > 0) {
			this.addButton(8,"Crew",crew);
		}
	}
	return false;
}

function flyMenu():void {
	clearOutput();
	if(pc.hasStatusEffect("Disarmed"))
	{
		output("<b>Your gear is still locked up in customs. You should go grab it before you jump out of system.");
		clearMenu();
		addButton(14,"Back",mainGameMenu);
		return;
	}
	output("Where do you want to go?");
	this.clearMenu();
	if(shipLocation != "TAVROS HANGAR") 
		this.addButton(0,"Tavros",flyTo,"Tavros");
	else addDisabledButton(0,"Tavros");
	if(shipLocation != "SHIP HANGAR") 
		this.addButton(1,"Mhen'ga",flyTo,"Mhen'ga");
	else addDisabledButton(1,"Mhen'ga");
	//Planet #2 unlocked!
	if(flags["UNLOCKED_JUNKYARD_PLANET"] != undefined)
	{
		if(shipLocation != "201") addButton(2,"Tarkus",flyTo,"Tarkus");
		else addDisabledButton(2,"Tarkus");
	}
	else addDisabledButton(2,"Locked","Locked","You need to find your father's probe on Mhen'ga to get this planet's coordinates.");
	if(shipLocation != "500") addButton(3,"New Texas",flyTo,"New Texas");
	else addDisabledButton(3,"New Texas","New Texas","You're already there.");
	this.addButton(14,"Back",mainGameMenu);
}

function flyTo(arg:String):void {
	
	if (flags["SUPRESS TRAVEL EVENT"] == 1)
	{
		flags["SUPRESS TRAVEL EVENT"] = 0;
	}
	else
	{
		var tEvent:Function = tryProcTravelEvent();
		if (tEvent != null)
		{
			incomingMessage(tEvent, arg);
			return;
		}
	}
	
	clearOutput();
	
	if(arg == "Mhen'ga") {
		shipLocation = "SHIP HANGAR";
		currentLocation = "SHIP HANGAR";
		output("You fly to Mhen'ga");
		output(" and step out of your ship.");
	}
	else if(arg == "Tavros") {
		shipLocation = "TAVROS HANGAR";
		currentLocation = "TAVROS HANGAR";
		output("You fly to Tavros");
		output(" and step out of your ship.");
	}
	else if(arg == "Tarkus")
	{
		shipLocation = "201";
		output("You slow your ship down as you near the orbit of your next destination, Loora. As you scale down from near a third the speed of light, the planet begins to come into focus ahead: surrounded by a dense field of asteroids looms the two sundered halves of the goblin world. What should be a lifeless system, however, teems with activity: your sensors go wild as you approach the riven planet, alerting you to massive electrical activity below. The planet - or perhaps more accurately, planets - are two halves of different wholes, unsubtly chained together with a massive space tether whose every link must be the size of a dreadnought. Good god, it must have taken the resources of an entire race to erect such a technological marvel: no wonder the new pioneers have been so interested in the planet.");
		output("\n\nSlow and steady, you guide your vessel through the asteroid field around the planet. Now that you're closer, though, those asteroids look more like debris than rock: hulls of space ships and ruined clumps of satellites mashed together over centuries of disuse now litter the upper atmosphere of Tarkus, making your approach difficult. More than once, a mass of space debris bounces off your shields, sending shudders through the hull. Finally, though, you break through, heat shields going up as you make the dive planetside.");
		output("\n\nYour nav beacon guides you in most of the way, directing you towards what looks like a derelict capital ship in the middle of a great red wasteland, littered with debris from all manner of machines and vessels. This whole planet is little more than a junkyard, a once-ripe world ravished by the march of a civilization that has left little more than its garbage in its wake. You shudder at the sight of the ruined landscape as you're guided in toward an open docking bay on the side of the ancient-looking, monolithic ship, flying past a glowing hull plate reading NOVA. It looks vaguely like a human vessel, but not of a make or model you've ever seen, and it looks centuries old, a derelict of ancient days. How'd it get all the way out here? Benching the question for now, you loop around the broadside of the capsized capital ship, easing into your appointed docking bay - a hastily spray-painted square on the deck, surrounded by other explorers' ships.");
	}
	else if(arg == "New Texas") {
		shipLocation = "500";
		currentLocation = "500";
		landOnNewTexas();
	}
	processTime(600 + rand(30));
	this.clearMenu();
	this.addButton(0,"Next",mainGameMenu);
}

function move(arg:String, goToMainMenu:Boolean = true):void {
	//Reset the thing that disabled encounters
	flags["ENCOUNTERS_DISABLED"] = undefined;
	var moveMinutes:int = rooms[currentLocation].moveMinutes;
	if(pc.hasItem(new Hoverboard())) {
		moveMinutes -= 1;
		if(moveMinutes < 1) moveMinutes = 1;
	}
	processTime(moveMinutes);
	currentLocation = arg;
	var map:* = mapper.generateMap(currentLocation);
	this.userInterface.setMapData(map);
	
	trace("Printing map for " + currentLocation);
	//mapper.printMap(map);
	//process time here, then back to mainGameMenu!
	mainGameMenu();
}

function statusTick():void {
	var shitToCut:Array = new Array();
	for(var x:int = this.chars["PC"].statusEffects.length-1; x >= 0; x--) 
	{
		//trace("Checking status effect: " + x + " of " + (this.chars["PC"].statusEffects.length-1));
		//If times, count dat shit down.
		if(this.chars["PC"].statusEffects[x].minutesLeft > 0) 
		{
			this.chars["PC"].statusEffects[x].minutesLeft--;
			//TIMER OVER!
			if(this.chars["PC"].statusEffects[x].minutesLeft <= 0) 
			{
				//CERTAIN STATUSES NEED TO CLEAR SOME SHIT.
				if(this.chars["PC"].statusEffects[x].storageName == "Crabbst") 
				{
					this.chars["PC"].physiqueMod -= this.chars["PC"].statusEffects[x].value2;
					this.chars["PC"].reflexesMod += this.chars["PC"].statusEffects[x].value2;
					this.chars["PC"].aimMod += this.chars["PC"].statusEffects[x].value2;
					this.chars["PC"].intelligenceMod += this.chars["PC"].statusEffects[x].value2;
					this.chars["PC"].willpowerMod += this.chars["PC"].statusEffects[x].value2;
				}
				//Horse pill gets bonus proc!
				if(this.chars["PC"].statusEffects[x].storageName == "Horse Pill")
				{
					var pill = new HorsePill();
					eventQueue[eventQueue.length] = pill.lastPillTF;
				}
				//Boobswell ends!
				if(this.chars["PC"].statusEffects[x].storageName == "Boobswell Pads")
				{
					//Message text, last boob size increase. 7 days later.
					eventBuffer += "\n\nUnfortunately, as you admire your now-larger bosom, you realize that the gentle, wet rumble of the pads has come to a stop. <b>It looks like you’ve exhausted the BoobSwell Pads";
					if(pc.bRows() > 1) eventBuffer += "on your " + num2Text2(this.chars["PC"].statusEffects[x].value1+1) + " row of breasts";
					eventBuffer += "!</b> You peel them off your [pc.skinFurScales] and toss them away.";
				}
				if(this.chars["PC"].statusEffects[x].storageName == "Mead") 
				{
					this.chars["PC"].physiqueMod -= this.chars["PC"].statusEffects[x].value2;
					this.chars["PC"].reflexesMod += this.chars["PC"].statusEffects[x].value2 * .5;
					this.chars["PC"].aimMod += this.chars["PC"].statusEffects[x].value2 * .5;
					this.chars["PC"].intelligenceMod += this.chars["PC"].statusEffects[x].value2 * .5;
					this.chars["PC"].willpowerMod += this.chars["PC"].statusEffects[x].value2 * .5;
				}
				if(this.chars["PC"].statusEffects[x].storageName == "X-Zil-rate")
				{
					this.chars["PC"].physiqueMod -= this.chars["PC"].statusEffects[x].value2;
					trace("X-Zil-rate Expired: " + this.chars["PC"].statusEffects[x].value2);
				}
				if(this.chars["PC"].statusEffects[x].storageName == "Quivering Quasar")
				{
					this.chars["PC"].physiqueMod -= this.chars["PC"].statusEffects[x].value2;
					trace("Quivering Quasar: " + this.chars["PC"].statusEffects[x].value2);
				}
				if(this.chars["PC"].statusEffects[x].storageName == "Zil Sting")
				{
					this.chars["PC"].reflexesMod += this.chars["PC"].statusEffects[x].value1;
					this.chars["PC"].libidoMod -= this.chars["PC"].statusEffects[x].value1;
				}
				if (pc.statusEffects[x].storageName == "Naleen Venom")
				{
					pc.physiqueMod += pc.statusEffects[x].value1;
					pc.aimMod += pc.statusEffects[x].value1;
					pc.willpowerMod += pc.statusEffects[x].value1;
					pc.reflexesMod += pc.statusEffects[x].value1;
				}
				//Mark out the ones that need cut!
				shitToCut[shitToCut.length] = x;
				//trace("Marking slot: " + x + " to cut");
			}
			
		}
	}	
	
	//Cut the statuses that expired and need cut.
	while(shitToCut.length > 0)
	{
		trace("REMOVING " + chars["PC"].statusEffects[shitToCut[0]].storageName + " in slot " + shitToCut[0] + " due to status effect time out.");
		this.chars["PC"].statusEffects.splice(shitToCut[0],1);
		shitToCut.splice(0,1);
	}
}

public function variableRoomUpdateCheck():void
{
	//Handle planet explosions
	if(flags["TARKUS_DESTROYED"] == 1 && rooms["211"].southExit != "") 
	{
		trace("PLANET BLEWED UP. HIDIN ROOMS");
		rooms["211"].southExit = "";
		rooms["213"].southExit = "";
	}
	else if(rooms["211"].southExit == "" && flags["TARKUS_DESTROYED"] == undefined)
	{
		trace("PLANET DIDN'T BLOWED UP. LINKIN' ROOMS");
		rooms["211"].southExit = "215";
		rooms["213"].southExit = "295";
	}
	
	//Kelly's work - close/open Xenogen Biotech.
	//Open up shop: link room
	if(hours >= 6 && hours < 17) 
	{
		rooms["SOUTH ESBETH 2"].northExit = "KELLY'S OFFICE";
		rooms["BURT'S BACK END"].removeFlag(GLOBAL.NPC);
		//Add back in icons.
		if(!rooms["JULIAN'S OFFICE"].hasFlag(GLOBAL.NPC)) rooms["JULIAN'S OFFICE"].addFlag(GLOBAL.NPC);
		if(!rooms["KELLY'S OFFICE"].hasFlag(GLOBAL.NPC)) rooms["KELLY'S OFFICE"].addFlag(GLOBAL.NPC);
	}
	//Close shop: 
	else
	{
		//rooms["SOUTH ESBETH 2"].northExit = "";
		//Get rid of icons
		rooms["KELLY'S OFFICE"].removeFlag(GLOBAL.NPC);
		rooms["JULIAN'S OFFICE"].removeFlag(GLOBAL.NPC);
		//Add Kelly icon in the bar
		if(!rooms["BURT'S BACK END"].hasFlag(GLOBAL.NPC)) rooms["BURT'S BACK END"].addFlag(GLOBAL.NPC);
	}

	//Sexbot factory opeeeeeen.
	if(flags["SEXBOTS_SCANNED_FOR_COLENSO"] != undefined && flags["SEXBOTS_SCANNED_FOR_COLENSO"] >= 4)
	{
		rooms["256"].southExit = "294";
	}
	
	// Annos shop
	if (!steeleTechTarkusShopAvailable())
	{
		rooms["303"].removeFlag(GLOBAL.NPC);
	}
	else
	{
		rooms["303"].addFlag(GLOBAL.NPC);
	}
	
	// Deck 13 Reactor -> Databank room
	if (flags["DECK13_REACTOR_DOOR_OPEN"] == undefined)
	{
		rooms["DECK 13 REACTOR"].northExit = undefined;
	}
	else
	{
		rooms["DECK 13 REACTOR"].northExit = "DECK 13 SECONDARY REACTOR";
	}

	// Deck 13 Reactor -> Vents
	if (flags["DECK13_REACTOR_DOOR_OPEN"] != undefined)
	{
		rooms["DECK 13 REACTOR"].eastExit = undefined;
	}
	else
	{
		rooms["DECK 13 REACTOR"].eastExit = "DECK 13 VENTS";
	}
}

public function processTime(arg:int):void {
	var x:int = 0;
	var tightnessChanged:Boolean = false;
	if(this.chars["PC"].ballFullness < 100) this.chars["PC"].cumProduced(arg);
	var productionFactor:Number = 100/(1920) * ((this.chars["PC"].libido() * 3 + 100)/100);
	
	//Double time
	if(this.chars["PC"].hasPerk("Extra Ardor")) productionFactor *= 2;
	
	//BOOZE QUADRUPLES TIEM!
	if(this.chars["PC"].hasStatusEffect("X-Zil-rate") || this.chars["PC"].hasStatusEffect("Mead") || this.chars["PC"].hasStatusEffect("X-Zil-rate"))
	productionFactor *= 4;
	
	//Half time.
	else if (this.chars["PC"].hasPerk("Ice Cold")) productionFactor /= 2;
	
	//Actually apply lust.
	this.chars["PC"].lust(arg * productionFactor);
	
	//Top off shields
	this.chars["PC"].shieldsRaw = this.chars["PC"].shieldsMax();
	
	PregnancyManager.updatePregnancyStages(chars, arg);
	
	//milk is chunked out all at once due to lazies
	if(arg > 0 && pc.canLactate()) 
	{
		pc.milkProduced(arg);
		milkGainNotes();
	}
	
	if (flags["MIMBRANES BITCH TIMER"] == undefined)
	{
		flags["MIMBRANES BITCH TIMER"] = arg;
	}
	else
	{
		flags["MIMBRANES BITCH TIMER"] += arg;
	}
	
	if (flags["MIMBRANES BITCH TIMER"] >= 300)
	{
		flags["MIMBRANES BITCH TIMER"] = 0;
		mimbranesComplainAndShit();
	}

	//Queue up procs for boobswell shit
	if(pc.hasStatusEffect("Boobswell Pads")) boobswellStuff(arg);

	//loop through every minute
	while(arg > 0) {
		//Check for shit that happens.
		//Actually move time!
		this.minutes++;

		//Status Effect Updates
		statusTick();
		
		//Tarkus'splosions
		if(flags["TARKUS_BOMB_TIMER"] != undefined && flags["TARKUS_BOMB_TIMER"] > 0)
		{
			flags["TARKUS_BOMB_TIMER"]--;
			bombStatusUpdate();
			if(flags["TARKUS_BOMB_TIMER"] == 0) eventQueue[eventQueue.length] = bombExplodes;
		}

		//Tick hours!
		if (this.minutes >= 60) {
			
			// Lust increase per hour
			mimbraneSweatHandler();
			
			this.minutes = 0;
			this.hours++;
			//Hours checks here!
			variableRoomUpdateCheck();
			if(flags["SHEKKA_TALK_COOLDOWN"] != undefined)
			{
				if(flags["SHEKKA_TALK_COOLDOWN"] > 0) flags["SHEKKA_TALK_COOLDOWN"]--;
				if(flags["SHEKKA_TALK_COOLDOWN"] < 0) flags["SHEKKA_TALK_COOLDOWN"] = 0;
			}
			if(flags["FLAHNE_PISSED"] > 0) {
				flags["FLAHNE_PISSED"]--;
				if(flags["FLAHNE_PISSED"] < 0) flags["FLAHNE_PISSED"] = 0;
			}
			if(chars["ALISS"].lust() < 70)
			{
				chars["ALISS"].lust(5);
			}
			if(chars["SHEKKA"].lust() < 50) chars["SHEKKA"].lust(15);

			//Lactation effect updates
			lactationUpdateHourTick();
			//Horse pill procs!
			if(pc.hasStatusEffect("Horse Pill"))
			{
				var pill = new HorsePill();
				//eventQueue[eventQueue.length] = pill.pillTF;
				pill.pillTF();
			}	
			//Cunt stretching stuff
			if(this.chars["PC"].hasVagina()) {
				for(x = 0; x < this.chars["PC"].totalVaginas(); x++) {
					//Count da stretch cooldown or reset if at minimum.
					if(this.chars["PC"].vaginas[x].loosenessRaw > this.chars["PC"].vaginas[x].minLooseness) this.chars["PC"].vaginas[x].shrinkCounter++;
					else this.chars["PC"].vaginas[x].shrinkCounter = 0;
					//Reset for this cunt.
					tightnessChanged = false;
					if(this.chars["PC"].vaginas[x].loosenessRaw < 2) {}
					else if(this.chars["PC"].vaginas[x].loosenessRaw <= 2 && this.chars["PC"].vaginas[x].shrinkCounter >= 200) tightnessChanged = true;
					else if(this.chars["PC"].vaginas[x].loosenessRaw < 4 && this.chars["PC"].vaginas[x].shrinkCounter >= 150) tightnessChanged = true;
					else if(this.chars["PC"].vaginas[x].loosenessRaw < 5 && this.chars["PC"].vaginas[x].shrinkCounter >= 110) tightnessChanged = true;
					else if(this.chars["PC"].vaginas[x].loosenessRaw >= 5 && this.chars["PC"].vaginas[x].shrinkCounter >= 75) tightnessChanged = true;
					if(tightnessChanged) {
						this.chars["PC"].vaginas[x].loosenessRaw--;
						eventBuffer += "\n\n<b>Your </b>";
						if(this.chars["PC"].totalVaginas() > 1) eventBuffer += "<b>" + num2Text2(x+1) + "</b> ";
						eventBuffer += "<b>" + this.chars["PC"].vaginaDescript(x) + " has recovered from its ordeals, tightening up a bit.</b>";
					}
				}
			}
			//Butt stretching stuff
			//Count da stretch cooldown or reset if at minimum.
			if(this.chars["PC"].ass.loosenessRaw > this.chars["PC"].ass.minLooseness) this.chars["PC"].ass.shrinkCounter++;
			else this.chars["PC"].ass.shrinkCounter = 0;
			//Reset for this cunt.
			tightnessChanged = false;
			if(this.chars["PC"].ass.loosenessRaw < 2) {}
			if(this.chars["PC"].ass.loosenessRaw == 2 && this.chars["PC"].ass.shrinkCounter >= 72) tightnessChanged = true;
			if(this.chars["PC"].ass.loosenessRaw == 3 && this.chars["PC"].ass.shrinkCounter >= 48) tightnessChanged = true;
			if(this.chars["PC"].ass.loosenessRaw == 4 && this.chars["PC"].ass.shrinkCounter >= 24) tightnessChanged = true;
			if(this.chars["PC"].ass.loosenessRaw == 5 && this.chars["PC"].ass.shrinkCounter >= 12) tightnessChanged = true;
			if(tightnessChanged) {
				this.chars["PC"].ass.loosenessRaw--;
				if(this.chars["PC"].ass.loosenessRaw <= 4) eventBuffer += "\n\n<b>Your " + this.chars["PC"].assholeDescript() + " has recovered from its ordeals and is now a bit tighter.</b>";
				else eventBuffer += "\n\n<b>Your " + this.chars["PC"].assholeDescript() + " recovers from the brutal stretching it has received and tightens up.</b>";
			}
			//Cunt snake pregnancy stuff
			if(pc.hasCuntSnake() && flags["CUNT_TAIL_PREGNANT_TIMER"] > 0) {
				flags["CUNT_TAIL_PREGNANT_TIMER"]--;
				if(flags["CUNT_TAIL_PREGNANT_TIMER"] == 1) {
					flags["CUNT_TAIL_PREGNANT_TIMER"] = 0;
					eventQueue[eventQueue.length] = giveBirthThroughCuntTail;
				}
			}

			//Days ticks here!
			if(this.hours >= 24) {
				this.days++;
				this.hours = 0;
				if(chars["ALISS"].lust() >= 70)
				{
					chars["ALISS"].orgasm();
				}
				//Cunt snake tomfoolery
				if(this.chars["PC"].hasCuntTail()) {
					if(flags["DAYS_SINCE_FED_CUNT_TAIL"] == undefined) flags["DAYS_SINCE_FED_CUNT_TAIL"] = 1;
					else flags["DAYS_SINCE_FED_CUNT_TAIL"]++;
				}
				//Reset 'dem venus pitcher hoz
				if(currentLocation != "OVERGROWN ROCK 12" && flags["ROOM_80_VENUS_PITCHER_ASLEEP"] != undefined) flags["ROOM_80_VENUS_PITCHER_ASLEEP"] = undefined;
				if(currentLocation != "VINED JUNGLE 3" && flags["ROOM_65_VENUS_PITCHER_ASLEEP"] != undefined) flags["ROOM_65_VENUS_PITCHER_ASLEEP"] = undefined;
				if(currentLocation != "DEEP JUNGLE 2" && flags["ROOM_61_VENUS_PITCHER_ASLEEP"] != undefined) flags["ROOM_61_VENUS_PITCHER_ASLEEP"] = undefined;

				// Tick up all of the attached mimbranes days since last fed
				mimbranesIncreaseDaysSinceFed();
			}
		}
		arg--;
	}
	//Check to see if something changed in this department
	milkMultiplierGainNotificationCheck();
	//Queue up dumbfuck procs
	if(pc.hasStatusEffect("Dumbfuck"))
	{
		//Got some cums to pile oN?
		if(pc.hasStatusEffect("Dumbfuck Orgasm Procced"))
		{
			//No sneezes set up yet. Start dis shit.
			if(!pc.hasStatusEffect("Dumbfuck Orgasm Queued"))
			{
				pc.createStatusEffect("Dumbfuck Orgasm Queued", pc.statusEffectv1("Dumbfuck Orgasm Procced"), 0, 0, 0, true, "", "", false, 0);
			}
			//Already got some. PILE ON!
			else pc.addStatusValue("Dumbfuck Orgasm Queued",1,pc.statusEffectv1("Dumbfuck Orgasm Procced"));
			//Clear out the holding status now that we're cued up for sneezin'
			pc.removeStatusEffect("Dumbfuck Orgasm Procced");
		}
		//Add to event queue so long as it isn't on there already
		if(pc.hasStatusEffect("Dumbfuck Orgasm Queued") && eventQueue.indexOf(procDumbfuckStuff) == -1)
		{
			eventQueue[eventQueue.length] = procDumbfuckStuff;
		}
	}
	
	updatePCStats();
}

function boobswellStuff(time:Number = 0):void
{
	//Message text, boob size+. Every 6 hours or so.
	//Every minute = .003 breastRating. = 5.5 hours per cup size.
	var swelledRows:Array = new Array();
	//Loop through statuses and find out which boobs are covered.
	for(var x:Number = 0; x < pc.statusEffects.length; x++)
	{
		//Boobswell on!
		if(pc.statusEffects[x].storageName == "Boobswell Pads")
		{
			//Add to the list of covered rows.
			swelledRows.push(pc.statusEffects[x].value1);
		}
	}
	//While rows remain that need processed.
	while(swelledRows.length > 0)
	{
		//Bonus lust for each extra row:
		pc.lust(time/10);
		//Use x to hold the original value for later comparison.
		x = pc.breastRows[swelledRows[swelledRows.length-1]].breastRating();
		trace("BOOBSWELL! Original titty: " + x);
		trace("Time: " + time + " Amount grown from time: " + (time * 0.003));
		//Actually change it
		pc.breastRows[swelledRows[swelledRows.length-1]].breastRatingRaw += time * 0.003;
		trace("BOOBSWELL! Post titty: " + pc.breastRows[swelledRows[swelledRows.length-1]].breastRating());
		
		if(Math.floor(pc.breastRows[swelledRows[swelledRows.length-1]].breastRating()) > Math.floor(x) 
			&& (Math.floor(pc.breastRows[swelledRows[swelledRows.length-1]].breastRating()) % 2 == 0 || Math.floor(pc.breastRows[swelledRows[swelledRows.length-1]].breastRating()) < 6))
		{
			trace("BOOBSWELL OUTPUT TRIGGERED");
			eventBuffer += "\n\nThanks to the BoobSwell pads you’re wearing, your chest is slowly but steadily filling out! <b>You figure that ";
			if(pc.bRows() == 1) eventBuffer += "you ";
			else eventBuffer += "your " + num2Text2(swelledRows[swelledRows.length-1]+1) + " row of breasts ";
			eventBuffer += "could now fit into an [pc.breastCupSize " + swelledRows[swelledRows.length-1] + "] bra!</b>";
		}
		swelledRows.splice(swelledRows.length-1,1);
	}
}

//Notes about milk gain increases
function milkGainNotes():void
{
	var x:int = 0;
	//Cross 75% milk fullness +1 cup
	//This doubles past F-cup
	if(pc.hasStatusEffect("Pending Gain Milk Note: 75"))
	{
		//Bump size!
		for(x = 0; x < pc.bRows(); x++)
		{
			if(pc.breastRows[x].breastRatingRaw >= 5) pc.breastRows[x].breastRatingLactationMod = 1.5;
			else pc.breastRows[x].breastRatingLactationMod = 1;
		}
		eventBuffer += "\n\nThere's no way you could miss how your [pc.fullChest] have swollen up with [pc.milk]. You figure it won't be long before they're completely full. It might be a good idea to milk them soon. <b>With all that extra weight, ";

		if(pc.bRows() > 1) eventBuffer += "the top row is ";
		else eventBuffer += "they're ";
		eventBuffer += "currently [pc.breastCupSize]s";
		if(pc.bRows() > 1) eventBuffer += ", and the others are similarly swollen";
		eventBuffer += ".</b>";
		pc.removeStatusEffect("Pending Gain Milk Note: 75");
	}
	//Cross 100% milk fullness + 1.5 cups
	//This doubles past F-cup
	if(pc.hasStatusEffect("Pending Gain Milk Note: 100"))
	{
		//Bump size!
		for(x = 0; x < pc.bRows(); x++)
		{
			if(pc.breastRows[x].breastRatingRaw >= 5) pc.breastRows[x].breastRatingLactationMod = 2.5;
			else pc.breastRows[x].breastRatingLactationMod = 1.5;
		}
		eventBuffer += "\n\nYour [pc.fullChest] feel more than a little sore. They're totally and unapologetically swollen with [pc.milk]. You heft the [pc.breastCupSize]s and sigh, swearing you can almost hear them slosh. <b>They're totally full.</b>";
		pc.removeStatusEffect("Pending Gain Milk Note: 100");
	}
	//Cross 150% milk fullness + 2 cups
	//This doubles past F-cup
	if(pc.hasStatusEffect("Pending Gain Milk Note: 150"))
	{
		//Bump size!
		for(x = 0; x < pc.bRows(); x++)
		{
			if(pc.breastRows[x].breastRatingRaw >= 5) pc.breastRows[x].breastRatingLactationMod = 3.5;
			else pc.breastRows[x].breastRatingLactationMod = 2;
		}
		eventBuffer += "\n\nYour [pc.nipples] are extraordinarily puffy at the moment, practically suffused with your neglected [pc.milk]. It's actually getting kind of painful to hold in all that liquid weight, and if ";
		if(pc.upperUndergarment is BountyBra) eventBuffer += "you weren't wearing a <b>Bounty Bra</b>, your body would be slowing down production";
		else eventBuffer += "you don't take care of it soon, a loss of production is likely";
		eventBuffer += ". Right now, they're swollen up to [pc.breastCupSize]s.";
		pc.removeStatusEffect("Pending Gain Milk Note: 150");
	}
	//Hit 200% milk fullness cap + 3 cups
	//This doubles past F-cup
	if(pc.hasStatusEffect("Pending Gain Milk Note: 200"))
	{
		//Bump size!
		for(x = 0; x < pc.bRows(); x++)
		{
			if(pc.breastRows[x].breastRatingRaw >= 5) pc.breastRows[x].breastRatingLactationMod = 4.5;
			else pc.breastRows[x].breastRatingLactationMod = 3;
		}
		eventBuffer += "\n\nThe tightness in your [pc.fullChest] is almost overwhelming. You feel so full – so achingly stuffed – that every movement is a torture of breast-swelling delirium. You can't help but wish for relief or a cessation of your lactation, whichever comes first. ";
		if(pc.upperUndergarment is BountyBra) eventBuffer += "<b>Your Bounty Bra will keep your [pc.fullChest] producing despite the uncomfortable fullness.</b>";
		else eventBuffer += "<b>If you don't tend to them, your [pc.breastCupSize]s will stop producing [pc.milk].</b>";
		pc.removeStatusEffect("Pending Gain Milk Note: 200");
	}
}

function lactationUpdateHourTick():void
{
	//These are easy since they proc with time passage and can be added to event buffer.
	//Milk Multiplier crosses a 10 point threshold while dropping
	//Drops .5 an hour above 150 fullness. 1 above 200 fullness
	//Milk Rate drops by .1 an hour above 200.
	var originalMultiplier = pc.milkMultiplier;
	//Bounty bra never loses milkMultiplier!
	if(pc.upperUndergarment is BountyBra)
	{

	}
	else
	{
		if(pc.milkFullness >= 200) 
		{
			if(pc.hasPerk("Milky")) pc.milkMultiplier -= .2;
			else pc.milkMultiplier -= 1;
		}
		else if(pc.milkFullness >= 150) 
		{
			if(!pc.hasPerk("Milky")) pc.milkMultiplier -= .5;
		}
	}
	//Drops a tiny amount if below 50.
	if(pc.milkMultiplier < 50 && !(pc.upperUndergarment is BountyBra)) {
		if(!pc.hasPerk("Milky")) pc.milkMultiplier -= 0.1;
		else pc.milkMultiplier -= 0.02;
		if(pc.milkFullness > 0) 
		{
			pc.milkFullness -= 1;
			if(pc.milkFullness < 0) pc.milkFullness = 0;
		}
	}
	if(pc.milkMultiplier < 0) pc.milkMultiplier = 0;
	//90
	if(pc.milkMultiplier < 90 && originalMultiplier >= 90) eventBuffer += "\n\nYou're pretty sure that your lactation is starting to slow down a little bit. If you don't start milking yourself, you'll eventually stop producing.";
	//80
	if(pc.milkMultiplier < 80 && originalMultiplier >= 80) eventBuffer += "\n\nLow level tingles in your [pc.chest] remind you that producing [pc.milk] is something your body does, but if you keep ignoring yourself, you won't for too much longer.";
	//70
	if(pc.milkMultiplier < 70 && originalMultiplier >= 70) eventBuffer += "\n\nYou're feeling pretty sore in your [pc.chest], but it's not getting that much worse. <b>You're pretty sure that you're lactating less as a result of the inattention to your chest.</b>";
	//60	
	if(pc.milkMultiplier < 60 && originalMultiplier >= 60) eventBuffer += "\n\nYour body's ability to produce [pc.milk] is diminishing to the point where your [pc.fullChest] are barely making any more. It won't take long before you stop production entirely.";
	//50
	if(pc.milkMultiplier < 50 && originalMultiplier >= 50) {
		for(var x:int = 0; x < pc.bRows(); x++)
		{
			pc.breastRows[x].breastRatingLactationMod = 0;
		}
		eventBuffer += "\n\nLike a switch has been flipped inside you, you feel your body's [pc.milk]-factories power down. <b>You've stopped lactating entirely.</b>";
		if(pc.milkFullness >= 75) 
		{
			eventBuffer += " The swelling from your over-filled [pc.fullChest] goes down as well, leaving you with [pc.breastCupSize]s.";
			pc.milkFullness = 75;
		}

	}
}

//Milk Multiplier crosses a 10 point threshold from raising
function milkMultiplierGainNotificationCheck():void
{
	//kGAMECLASS cheat to cheat these messages into the event buffer? Or pass event buffer as an argument? Regardless, seems the cleanest way to keep it from interrupting the scene it gets called in.
	//30
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 30")) {
		eventBuffer += "\n\nThe soreness in your [pc.nipples] is both persistent and pleasant in its own unique way. There's no disguising how it makes your [pc.chest] practically glow with warmth.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 30");
	}
	//40
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 40")) {
		eventBuffer += "\n\nTingles run through your [pc.fullChest] every now and again. Your [pc.nipples] even feel moist. Perhaps you'll start lactating soon?";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 40");
	}
	//50
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 50")) {
		eventBuffer += "\n\nA single droplet of [pc.milk] escapes from one of your [pc.nipples]";
		if(pc.isChestGarbed()) eventBuffer += ", staining your [pc.upperGarments] [pc.milkColor]";
		eventBuffer += ". <b>You're lactating</b>, albeit slowly.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 50");
	}
	//60
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 60")) {
		eventBuffer += "\n\nJudging by the feelings in your [pc.fullChest], you can safely say that you're making [pc.milk] faster than before. Is that what ";
		if(pc.hasPregnancy()) eventBuffer += "it feels like to be an expectant mother?";
		else eventBuffer += "expectant mothers feel like?";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 60");
	}
	//70
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 70")) {
		eventBuffer += "\n\nYou're pretty sure you're lactating even more now. As a matter of fact, a scan by your codex confirms it. Your body is producing a decent amount of milk, perhaps a little under half its maximum capability.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 70");
	}
	//80
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 80")) {
		eventBuffer += "\n\nHeat suffuses your chest, just another indication that your [pc.fullChest] have passed a new threshold of productivity. You're definitely lactating harder.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 80");
	}
	//90
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 90")) {
		eventBuffer += "\n\nThere's no doubt about how bountiful your [pc.fullChest] are feeling, swollen with potential just waiting to be milked out so that they can produce more. <b>You're getting close to having your body as trained for lactation as possible.</b>";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 90");
	}
	//100
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 100")) {
		eventBuffer += "\n\nA wonderful, productive feeling swells in your [pc.fullChest], tingling hotly. A quick scan with your codex reports that your body is making [pc.milk] at its full capacity.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 100");
	}
	//110
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 110")) {
		eventBuffer += "\n\nSomehow, your body is adapting to all the milking its been put through, and your [pc.fullChest] feel more powerful and fecund than ever before. Your chest is a well-trained milking machine.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 110");
	}
	//125
	if(pc.hasStatusEffect("Pending Gain MilkMultiplier Note: 125")) {
		eventBuffer += "\n\nYour chest is practically singing in delight, and the only thing it sings about is [pc.milk] - rivers of never ending, liquid flows that will spill from you unceasingly. You have trained them to lactate as well as anything can be trained. If you want to make any more [pc.milk], you'll have to grow your [pc.fullChest] bigger or turn science.";
		pc.removeStatusEffect("Pending Gain MilkMultiplier Note: 125");
	}
}

function badEnd():void {
	output("\n\n<b>GAME OVER</b>\n\n(Access the main menu to start a new character or the data menu to load a saved game. The buttons are located in the lower left of the game screen.)");
	clearMenu();
}
