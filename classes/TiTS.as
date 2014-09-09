﻿package classes
{
	import classes.GameData.Perks;
	import classes.TiTS_Settings;
	import classes.UIComponents.MainButton;
	import fl.transitions.Tween;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.display.MovieClip;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import classes.RoomClass;
	
	// Game content managers
	import classes.GameData.TooltipManager;
	import classes.GameData.CodexManager;
	import classes.GameData.GameOptions;
	
	import fl.transitions.easing.None;

	import classes.InputManager;
	import classes.Characters.*;

	// Items
	import classes.Items.Protection.*
	import classes.Items.Guns.*
	import classes.Items.Melee.*
	import classes.Items.Apparel.*
	import classes.Items.Miscellaneous.*
	import classes.Items.Accessories.*

	import classes.Parser.ParseEngine;

	import classes.DataManager.DataManager;
	import classes.GameData.StatTracking;
	import classes.GUI;
	import classes.Mapper;
	import classes.StringUtil;

	//Build the bottom drawer
	public class TiTS extends MovieClip
	{
		// Smoosh all the included stuff into the TiTS class
		// this is a HORRIBLE way of architecting the system, but it's better then not
		// using classes at all
		
		include "../includes/CodexEntries.as";
		
		/*
		include "../includes/combat.as";
		include "../includes/items.as";
		include "../includes/creation.as";
		include "../includes/engine.as";
		include "../includes/game.as";
		include "../includes/masturbation.as";
		include "../includes/NPCTemplates.as";
		include "../includes/appearance.as";
		include "../includes/rooms.as";
		include "../includes/roomFunctions.as";
		include "../includes/debug.as";
		include "../includes/ControlBindings.as";
		
		include "../includes/travelEvents.as";		
		include "../includes/lightsOut.as";
		*/
			
		public var chars:Object;
		public var foes:Array;

		// This needs to ideally be moved somewhere else, I'm just stopping the GUI code from being used to store game-data models
		public var days:int;
		public var hours:int;
		public var minutes:int;

		// Queued event system
		public var eventBuffer:String;
		public var eventQueue:Array;

		// Version string/value
		public var version:String;

		// Room data
		public var rooms:Object;

		public var temp:int;
		public var items:Object;
		
		//Toggles
		public var gameOptions:GameOptions;
		
		public function get silly():Boolean { return gameOptions.sillyMode; }
		public function get easy():Boolean { return gameOptions.easyMode; }
		public function get debug():Boolean { return gameOptions.debugMode; }
		
		public function set silly(v:Boolean):void { gameOptions.sillyMode = v; }
		public function set easy(v:Boolean):void { gameOptions.easyMode = v; }
		public function set debug(v:Boolean):void { gameOptions.debugMode = v; }
		
		public var inputManager:InputManager;

		//Lazy man state checking
		public var currentLocation:String;
		public var shipLocation:String;
		public var inSceneBlockSaving:Boolean;

		public var parser:ParseEngine;

		public var dataManager:DataManager;
		public var userInterface:GUI;

		public var shopkeep:Creature;
		public var itemScreen:*;
		public var lootScreen:*;
		
		public var useItemFunction;
		public var itemUser:Creature;
		public var itemTarget:Creature;

		public var flags:Dictionary;

		public var combatStage;

		// LE MAP
		public var mapper:Mapper;

		// Hacky fix for some UI updating problems under Chrome
		public var whatTheFuck:Sprite;
		public var whatTheFuckToggleState:Boolean;
		
		// Game data
		private var _perkDB:Perks;
		public function get perkDB():Perks { return _perkDB; }

		public function TiTS()
		{
			kGAMECLASS = this;
			dataManager = new DataManager();
			gameOptions = new GameOptions();
			
			hours = 0;
			minutes = 0;
			days = 0;

			trace("TiTS Constructor")

			version = "0.02.51";

			//temporary nonsense variables.
			temp = 0;
			combatStage = 0;

			import classes.Creature;
			import classes.ItemSlotClass;
			import classes.ScriptParser;
			import classes.ShipClass;

			chars = new Object();
			foes = new Array();
			
			//What inventory screen is up?
			shopkeep = undefined;
			itemScreen = undefined;
			lootScreen = undefined;
			
			// lootList = new Array();
			useItemFunction = undefined;
			itemUser = undefined;
			itemTarget = undefined;

			this.inSceneBlockSaving = false;
			
			eventQueue = new Array();
			eventBuffer = "";
			
			//Toggles
			silly = false;
			easy = false;
			debug = false;

			//Lazy man state checking
			currentLocation = "SHIP HANGAR";
			shipLocation = "SHIP HANGAR";

			parser = new ParseEngine(this, TiTS_Settings);

			flags = new Dictionary();

			// Major class variable setup: ------------------------------------------------------------
			initializeRooms();
			
			// dick about with mapper: ------------------------------------------------------------
			mapper = new Mapper(this.rooms)

			//Lazy man shortcuts! Need reset after reinitialization of data.
			//pc = chars[0];

			this.chars["PC"] = new PlayerCharacter();
			_perkDB = new Perks();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			this.inputManager = new InputManager(stage, false);
			this.setupInputControls();
			
			// set up the user interface: ------------------------------------------------------------
			this.userInterface = new GUI(this, stage);
			this.clearMenu();

			this.addEventListener(Event.FRAME_CONSTRUCTED, finishInit);
		}
		
		private function finishInit(e:Event):void
		{
			this.removeEventListener(Event.FRAME_CONSTRUCTED, finishInit);
			this.configureCodex();
			this.userInterface.showMainMenu();
			this.userInterface.toggleBarTweens();
			buildWTF();
			this.userInterface.toggleBarTweens();
		}
		
		private function buildWTF():void
		{
			whatTheFuck = new Sprite();
			whatTheFuck.name = "wtf";
			whatTheFuck.graphics.beginFill(0x333E52, 1);
			whatTheFuck.graphics.drawRect(0, 0, 2, 2);
			whatTheFuck.graphics.endFill();
			
			stage.addChild(whatTheFuck);
			whatTheFuck.x = 1199;
			whatTheFuck.y = 799;
		}
		
		public function toggleWTF():void
		{
			whatTheFuckToggleState != whatTheFuckToggleState;
			
			var start:int;
			var end:int;
			
			if (whatTheFuckToggleState == false)
			{
				start = 1199;
				end = 0;
			}
			else
			{
				start = 0;
				end = 1199;
			}
			
			var tw:Tween = new Tween(whatTheFuck, "x", None.easeNone, start, end, 12, false); 
		}
		
		// Proxy clearMenu calls so we can hook them for controlling save-enabled state
		// Or alternatively, shim this shit so we don't have to differentiate between
		// TiTs engine calls and UI calls. This shit is getting ridiculous.		
		public function clearMenu(saveDisable:Boolean = true):void 
		{
			this.inSceneBlockSaving = saveDisable;
			this.userInterface.clearMenu();
		}
		
		public function clearGhostMenu():void
		{
			this.userInterface.clearGhostMenu();
		}
		
		public function buttonClick(evt:MouseEvent):void 
		{
			toggleWTF();
			
			if (!inCombat()) 
			{
				this.userInterface.showBust("none");
			}
			
			if (evt.currentTarget is MainButton)
			{
				trace("Button " + (evt.currentTarget as MainButton).buttonName + " clicked");
			}
			else
			{
				trace("Button " + evt.currentTarget.caption.text + " clicked.");
			}
			
			if (evt.currentTarget.arg == undefined)
			{
				if (evt.currentTarget.func != null) evt.currentTarget.func();
			}
			else
			{
				if (evt.currentTarget.func != null) evt.currentTarget.func(evt.currentTarget.arg);
			}
			
			if (chars["PC"] != undefined)
			{
				updatePCStats();
			}
			
			userInterface.updateTooltip((evt.currentTarget as DisplayObject));
		}
		
		public function showBust(... args):void
		{
			userInterface.showBust.apply(null, args);
		}
		
		public function showName(name:String):void
		{
			userInterface.showName(name);
		}
		
		public function addButton(slot:int, cap:String = "", func:Function = undefined, arg:* = undefined, ttHeader:String = null, ttBody:String = null):void
		{
			userInterface.addButton(slot, cap, func, arg, ttHeader, ttBody);
		}
		
		public function addGhostButton(slot:int, cap:String = "", func:Function = undefined, arg:* = undefined, ttHeader:String = null, ttBody:String = null):void
		{
			userInterface.addGhostButton(slot, cap, func, arg, ttHeader, ttBody);
		}
		
		public function addDisabledButton(slot:int, cap:String = "", ttHeader:String = null, ttBody:String = null):void
		{
			userInterface.addDisabledButton(slot, cap, ttHeader, ttBody);
		}
		
		public function addDisabledGhostButton(slot:int, cap:String = "", ttHeader:String = null, ttBody:String = null):void
		{
			userInterface.addDisabledGhostButton(slot, cap, ttHeader, ttBody);
		}
		
		public function addItemButton(slot:int, item:ItemSlotClass, func:Function = undefined, arg:* = undefined, ttHeader:String = null, ttBody:String = null, seller:Creature = null, buyer:Creature = null):void
		{
			var comparisonString:String = null;
			var compareItem:ItemSlotClass = null;
			
			if (item.type == GLOBAL.RANGED_WEAPON)
			{
				compareItem = (chars["PC"] as Creature).rangedWeapon;
			}
			else if (item.type == GLOBAL.MELEE_WEAPON)
			{
				compareItem = (chars["PC"] as Creature).meleeWeapon;
			}
			else if (item.type == GLOBAL.ARMOR || item.type == GLOBAL.CLOTHING)
			{
				compareItem = (chars["PC"] as Creature).armor;
			}
			else if (item.type == GLOBAL.SHIELD)
			{
				compareItem = (chars["PC"] as Creature).shield;
			}
			else if (item.type == GLOBAL.LOWER_UNDERGARMENT)
			{
				compareItem = (chars["PC"] as Creature).lowerUndergarment;
			}
			else if (item.type == GLOBAL.UPPER_UNDERGARMENT)
			{
				compareItem = (chars["PC"] as Creature).upperUndergarment;
			}
			else if (item.type == GLOBAL.ACCESSORY)
			{
				compareItem = (chars["PC"] as Creature).accessory;
			}
			
			if (compareItem == null)
			{
				compareItem = new NoItem();
			}
			
			comparisonString = item.compareTo(compareItem, seller, buyer);
			
			// Do GUI stuff with the compareItem string -- can probably mangle a call together a call to addButton() to do the needful
			// if we have any null arguments at this point rather than throwing an error and shit.
			userInterface.addItemButton(slot, item.shortName, item.quantity, func, arg, ttHeader, ttBody, comparisonString);
		}
		
		public function addOverrideItemButton(slot:int, item:ItemSlotClass, buttonName:String, func:Function = undefined, arg:* = undefined, ttHeader:String = null, ttBody:String = null):void
		{
			var comparisonString:String = null;
			var compareItem:ItemSlotClass = null;
			
			if (item.type == GLOBAL.RANGED_WEAPON)
			{
				compareItem = (chars["PC"] as Creature).rangedWeapon;
			}
			else if (item.type == GLOBAL.MELEE_WEAPON)
			{
				compareItem = (chars["PC"] as Creature).meleeWeapon;
			}
			else if (item.type == GLOBAL.ARMOR || item.type == GLOBAL.CLOTHING)
			{
				compareItem = (chars["PC"] as Creature).armor;
			}
			else if (item.type == GLOBAL.SHIELD)
			{
				compareItem = (chars["PC"] as Creature).shield;
			}
			else if (item.type == GLOBAL.LOWER_UNDERGARMENT)
			{
				compareItem = (chars["PC"] as Creature).lowerUndergarment;
			}
			else if (item.type == GLOBAL.UPPER_UNDERGARMENT)
			{
				compareItem = (chars["PC"] as Creature).upperUndergarment;
			}
			else if (item.type == GLOBAL.ACCESSORY)
			{
				compareItem = (chars["PC"] as Creature).accessory;
			}
			
			if (compareItem == null)
			{
				compareItem = new NoItem();
			}
			
			comparisonString = item.compareTo(compareItem);
			
			var itemHeader:String = null;
			var itemBody:String = null;
			
			if (ttHeader != null && ttHeader.length > 0) itemHeader = ttHeader;
			if (ttBody != null && ttBody.length > 0) itemBody = ttBody;
			
			if (itemHeader == null || itemHeader.length == 0) itemHeader = TooltipManager.getFullName(item.shortName);
			if (itemBody == null || itemBody.length == 0) itemBody = TooltipManager.getTooltip(item.shortName);
			
			// Do GUI stuff with the compareItem string -- can probably mangle a call together a call to addButton() to do the needful
			// if we have any null arguments at this point rather than throwing an error and shit.
			userInterface.addItemButton(slot, buttonName, 1, func, arg, itemHeader, itemBody, comparisonString);
		}
		
		public function removeButton(slot:int):void
		{
			userInterface.addDisabledButton(slot);
		}
		
		public function refreshFontSize():void
		{
			userInterface.refreshFontSize(gameOptions.fontSize);
		}
		
		public function showCodex():void
		{
			this.userInterface.showCodex();
			this.codexHomeFunction();
			this.clearGhostMenu();
			// TESTO BUTTONO
			//addGhostButton(0, "Database", function():void { } );
			//addGhostButton(1, "Messages", function():void { } );
			//addGhostButton(2, "Log", function():void { } );
			//addGhostButton(3, "CHEEVOS", function():void { } );
			addGhostButton(4, "Back", this.userInterface.showPrimaryOutput);
		}
		
		public function levelUpHandler(e:Event = null):void
		{
			if (!this.userInterface.levelUpButton.isActive) return;
			
			if (!this.userInterface.levelUpButton.isHighlighted)
			{
				// Select the correct entry point for the level up system
				if ((pc as PlayerCharacter).unspentStatPoints > 0)
				{
					this.userInterface.showLevelUpStats(pc);
				}
				else if ((pc as PlayerCharacter).unclaimedClassPerks > 0)
				{
					this.userInterface.showLevelUpPerks(pc);
				}
				// else if ((pc as PlayerCharacter).unclaimedGenericPerks > 0)
				//{
				//		this.userInterface.showLevelUpGenericPerks(pc);
				//}
				this.userInterface.levelUpButton.Glow();
			}
			else
			{
				this.userInterface.showPrimaryOutput();
				this.userInterface.levelUpButton.DeGlow();
			}
		}
		
		public function spacebarKeyEvt():void
		{
			this.userInterface.SpacebarEvent();
		}

		// Proxy through and tweak the input manager along the way
		public function displayInput():void
		{
			this.inputManager.ignoreInputKeys(true);
			this.userInterface.displayInput();
		}
		
		public function removeInput():void
		{
			this.inputManager.ignoreInputKeys(false);
			this.userInterface.removeInput();
		}
		
		public function pressButton(arg:int = 0):void 
		{
			if (this.userInterface.PressButton(arg, inCombat()))
			{
				updatePCStats();
			}
		}

		// New passthroughs to GUI to handle scroll event controls
		public function upScrollText():void
		{
			this.userInterface.upScrollText();
		}
		
		public function downScrollText():void
		{
			this.userInterface.downScrollText();
		}
		
		public function pageUpScrollText():void
		{
			this.userInterface.pageUpScrollText();
		}
		
		public function pageDownScrollText():void
		{
			this.userInterface.pageDownScrollText();
		}
		
		public function homeScrollText():void
		{
			this.userInterface.homeScrollText();
		}
		
		public function endScrollText():void
		{
			this.userInterface.endScrollText();
		}
		
		public function nextOutputPage():void
		{
			this.userInterface.BufferPageNextHandler();
		}
		
		public function prevOutputPage():void
		{
			this.userInterface.BufferPagePrevHandler();
		}
		
		// Cheaty hooks for stuff
		public function IsFunction(name:String):Boolean
		{
			if (this[name] != undefined) return true;
			return false;
		}
		
		public function ExecuteFunction(name:String):void
		{
			this[name]();
		}
		
		public function get pc():*
		{
			return chars["PC"];
		}
		public function get monster():*
		{
			if(foes.length == 0) return chars["PC"];
			else return foes[0];
		}

		public function get celise():*
		{
			return chars["CELISE"];
		}

		public function get rival():*
		{
			return chars["RIVAL"];
		}

		public function get geoff():*
		{
			return chars["GEOFF"];
		}

		public function get flahne():*
		{
			return chars["FLAHNE"];
		}

		public function get zilpack():*
		{
			return chars["ZILPACK"];
		}

		public function get zil():*
		{
			return chars["ZIL"];
		}

		public function get penny():*
		{
			return chars["PENNY"];
		}

		public function get shekka():*
		{
			return chars["SHEKKA"];
		}

		public function get burt():*
		{
			return chars["BURT"];
		}

		public function get zilFemale():*
		{
			return chars["ZILFEMALE"];
		}

		public function get cuntsnake():*
		{
			return chars["CUNTSNAKE"];
		}
		
		public function get reaha():*
		{
			return chars["REAHA"];
		}
		
		public function get dane():*
		{
			return chars["DANE"];
		}
		
		public function get mimbrane():*
		{
			return chars["MIMBRANE"];
		}
		public function get anno():*
		{
			return chars["ANNO"];
		}
		
		public function get kiro():*
		{
			return chars["KIRO"];
		}
		
		public function get saendra():*
		{
			return chars["SAENDRA"];
		}
		public function get sera():*
		{
			return chars["SERA"];
		}
		
		public function get vanae():*
		{
			return this.monster;
		}
		public function get vanaeMaiden():*
		{
			return chars["MAIDEN_VANAE"];
		}
		public function get vanaeHuntress():*
		{
			return chars["HUNTRESS_VANAE"];
		}
	
		function doParse(script:String, markdown=false):String 
		{
			return parser.recursiveParser(script, markdown);
		}


		/*
		MOST of this should be broken up into simple shim-functions that call the real, relevant function in userInterface:GUI
		I'm breaking it out into a separate class, and just manipulating those class variables for the moment
		once that's working, I can start piecemeal moving things to functions in GUI.

		*/

		//1: TEXT FUNCTIONS
		public function output(words:String, markdown:Boolean = false):void 
		{
			this.userInterface.outputBuffer += doParse(words, markdown);
			this.userInterface.output();
		}

		public function clearOutput():void 
		{
			this.userInterface.clearOutput();
		}

		public function output2(words:String, markdown:Boolean = false):void
		{
			this.userInterface.outputBuffer2 += doParse(words, markdown);
			this.userInterface.output2();
		}

		public function clearOutput2():void
		{
			this.userInterface.clearOutput2();
		}

		public function outputCodex(words:String, markdown:Boolean = false):void
		{
			this.userInterface.outputCodexBuffer += doParse(words, markdown);
		}

		public function clearOutputCodex():void
		{
			this.userInterface.clearOutputCodex();
		}

		// HTML tag formatting wrappers, because lazy as fuck
		public function header(words:String):String
		{
			return String("<span class='header'>" + words + "</span>\n");
		}

		public function blockHeader(words:String):String
		{
			return String("<span class='blockHeader'>" + words + "</span>\n");
		}

		public function num2Text(number:Number):String {
			var returnVar:String = null;
			var numWords = new Array("zero","one","two","three","four","five","six","seven","eight","nine","ten");
			if (number > 10 || int(number) != number) {
				returnVar = "" + number;
			} 
			else {
				returnVar = numWords[number];
			}
			return(returnVar);
		}
		public function num2Text2(number:int):String {
			var returnVar:String = null;
			var numWords = new Array("zero","first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth");
			if (number > 10) {
				returnVar = "" + number + "th";
			} 
			else {
				returnVar = numWords[number];
			}
			return(returnVar);
		}

		public function author(arg:String):void 
		{
			userInterface.author(arg);
		}
		function leftBarClear():void {
			this.userInterface.leftBarClear();
		}
		function hidePCStats():void {
			this.userInterface.hidePCStats()
		}
		function showPCStats():void {
			this.userInterface.showPCStats()
		}
		function showNPCStats():void {
			this.userInterface.showNPCStats()
		}
		function hideNPCStats():void {
			this.userInterface.hideNPCStats()
		}
		function showMinimap():void {
			this.userInterface.showMinimap();
		}
		function hideMinimap():void {
			this.userInterface.hideMinimap();
		}
		function deglow():void 
		{
			this.userInterface.deglow()
		}	
		
		public function updatePCStats():void {
			if (pc.short != "uncreated" && pc.short.length > 0)
				this.userInterface.setGuiPlayerNameText(pc.short);
			else
				this.userInterface.setGuiPlayerNameText("");

			updateStatBar(this.userInterface.playerShields,pc.shields(),pc.shieldsMax());

			updateStatBar(this.userInterface.playerHP,pc.HP(),pc.HPMax());
			updateStatBar(this.userInterface.playerLust,pc.lust(),pc.lustMax());
			updateStatBar(this.userInterface.playerEnergy,pc.energy(),pc.energyMax());
			
			updateStatBar(this.userInterface.playerPhysique,pc.physique(),pc.physiqueMax());	
			updateStatBar(this.userInterface.playerReflexes,pc.reflexes(),pc.reflexesMax());
			updateStatBar(this.userInterface.playerAim,pc.aim(),pc.aimMax());
			updateStatBar(this.userInterface.playerIntelligence,pc.intelligence(),pc.intelligenceMax());
			updateStatBar(this.userInterface.playerWillpower,pc.willpower(),pc.willpowerMax());
			updateStatBar(this.userInterface.playerLibido, pc.libido(), pc.libidoMax());
			updateStatBar(this.userInterface.playerXP, pc.XP(), pc.XPMax());

			
			this.userInterface.playerStatusEffects = this.chars["PC"].statusEffects;
			this.userInterface.playerLevel.value = pc.level;
			this.userInterface.playerCredits.value = pc.credits;
			
			this.userInterface.time = timeText();
			this.userInterface.days = String(days);
			this.userInterface.showSceneTag();
			
			updateNPCStats();
		}

		function timeText():String 
		{
			var buffer:String = ""
			
			if (hours < 10)
			{
				buffer += "0";
			}
			
			buffer += hours + ":";
			
			if (minutes < 10) 
			{
				buffer += "0";
			}
			
			buffer += minutes;
			return buffer;
		}

		function updateNPCStats():void {
			if(foes.length >= 1) {
				updateStatBar(this.userInterface.monsterShield, foes[0].shields(),  foes[0].shieldsMax());
				updateStatBar(this.userInterface.monsterHP,     foes[0].HP(),       foes[0].HPMax());
				updateStatBar(this.userInterface.monsterLust,   foes[0].lust(),     foes[0].lustMax());
				updateStatBar(this.userInterface.monsterEnergy, foes[0].energy(),   foes[0].energyMax());
				
				this.userInterface.monsterLevel.value = String(foes[0].level);
				this.userInterface.monsterRace.value = StringUtil.toTitleCase(foes[0].originalRace);
				if(foes[0].hasCock()) {
					if(foes[0].hasVagina())	
						this.userInterface.monsterSex.value = "Herm";
					else this.userInterface.monsterSex.value = "Male";
				}
				else if(foes[0].hasVagina()) this.userInterface.monsterSex.value = "Female";
				else this.userInterface.monsterSex.value = "???";
				
				this.userInterface.monsterStatusEffects = foes[0].statusEffects;
			}
		}
		
		function updateStatBar(arg:StatBar ,value = undefined, max = undefined):void {
			//if(title != "" && title is String) arg.masks.labels.text = title;
			if(max != undefined) 
				arg.setMax(max);
			if(value != undefined && arg.visible == true) 
			{
				if(arg.getGoal() != value) 
				{
					arg.setGoal(value);
					//trace("SETTING GOAL");
				}
			}
		}
	}
}