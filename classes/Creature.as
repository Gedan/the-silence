﻿package classes {
	import classes.GameData.Characters.PlayerCharacter;
	import classes.CockClass;
	import classes.DataManager.Errors.VersionUpgraderError;
	import classes.GameData.Items.Miscellaneous.EmptySlot;
	import classes.VaginaClass;
	import classes.BreastRowClass;
	import classes.StorageClass;
	import classes.ItemSlotClass;
	import classes.DataManager.Serialization.ISaveable;
	import classes.DataManager.Serialization.VersionedSaveable;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import classes.GameData.StatTracking;
	import flash.utils.ByteArray;
	import classes.GLOBAL;
	import classes.GameData.Items.Miscellaneous.EmptySlot;
	import classes.Util.RandomInCollection;
	import classes.Engine.Interfaces.output;
	import classes.Resources.Busts.StaticRenders;

	/**
	 * I cannot yet implement "smart" detection of which characters (or furthermore, what *properties* of which characters)
	 * actually need to be serialized, because the raw storage types used throughout the Creature class (f.ex Cocks Array) are
	 * not aware of their parent class. One of the next goals will be to replace the raw storage containers with some form of
	 * interface container that can be aware of it's parent, and tie back into the serialization state.
	 * This needs to be done ti chain the getSaveObject()/loadSaveObject() to completion anyway, but we can then also hook back
	 * into a property on the parent container to detect changes-over-default. This would enable "deltasaves" in effect, where
	 * the only values stored are values that differ from compile-time values for each creature.
	 * Note to self: mx.utils has some describeType caching which may be a thing to look at. It also has some handy-dandy features
	 * for checking class properties (isDynamic etc, mx.utils.ObjectUtil)
	 */
	public class Creature extends VersionedSaveable {
		/**
		 * NeverSerialize is a seperate flag that can be applied on a creature-by-creature basis. Any creature with the
		 * NeverSerialize flag set will be omitted from the save/load process. There are probably many Creatures that will
		 * never actually need persistent storage throughout the lifetime of the game, so storing their state in player saves
		 * seems much overkill.
		 */
		protected var _neverSerialize: Boolean = false;
		public function get neverSerialize(): Boolean {
			return _neverSerialize;
		}

		private static const STAT_CLAMP_VALUE:Number = 0;
		
		//Constructor
		public function Creature() {
			this.addIgnoredField("neverSerialize");

			cocks = new Array();
			vaginas = new Array();
			breastRows = new Array();
			breastRows[0] = new BreastRowClass();
			perks = new Array();
			statusEffects = new Array();
			keyItems = new Array();
			inventory = new Array();
			sexualPreferences = new SexualPreferences();
		}

		//For enemies
		public var bustT:Class = StaticRenders.MISSING;
		public var INDEX:String = "";
		public var short: String = "";
		public var originalRace: String = "human";
		public var a: String = "a ";
		public var long: String = "You scrawny, yo.";
		public var description:String = "";
		public var capitalA: String = "A ";
		public var currentLocation:String = "";

		//Is a creature a 'pluralize' encounter - mob, etc. 
		public var plural: Boolean = false;

		//Lust vulnerability
		public var lustVuln: Number = 1;
		
		public function lustDamageMultiplier():Number
		{
			if (lustVuln == 0) return 0;
			return (lustVuln + meleeWeapon.bonusLustVuln + rangedWeapon.bonusLustVuln + armor.bonusLustVuln + upperUndergarment.bonusLustVuln + lowerUndergarment.bonusLustVuln + accessory.bonusLustVuln + shield.bonusLustVuln);
		}

		public var customDodge: String = "";
		public var customBlock: String = "";
		public var defaultMeleeAttack:String = "";
		public var defaultRangedAttack:String = "";

		//Clothing/Armor
		public var meleeWeapon: ItemSlotClass = new EmptySlot();
		public var rangedWeapon: ItemSlotClass = new EmptySlot();
		public var armor: ItemSlotClass = new EmptySlot();
		public var upperUndergarment: ItemSlotClass = new EmptySlot();
		public var lowerUndergarment: ItemSlotClass = new EmptySlot();
		public var accessory: ItemSlotClass = new EmptySlot();
		public var shield: ItemSlotClass = new EmptySlot();

		public var inventory: Array = new Array();

		public var typesBought: Array = new Array();
		public var sellMarkup: Number = 1;
		public var buyMarkdown: Number = 1;
		public var keeperGreeting: String = "<i>“Hello and welcome to my shop. Take a gander and let me know if you see anything you like,”</i>  " + a + short + " says with a smile.";
		public var keeperBuy: String = "What would you like to buy?";
		public var keeperSell: String = "What would you like to sell?";

		//Primary stats
		private var _physiqueRaw: Number = 3;
		public function get physiqueRaw():Number
		{
			return _physiqueRaw;
		}
		public function set physiqueRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_physiqueRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_physiqueRaw = v;
			}
		}

		private var _reflexesRaw: Number = 3;
		public function get reflexesRaw():Number
		{
			return _reflexesRaw;
		}
		public function set reflexesRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_reflexesRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_reflexesRaw = v;
			}
		}

		private var _aimRaw: Number = 3;
		public function get aimRaw():Number
		{
			return _aimRaw;
		}
		public function set aimRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_aimRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_aimRaw = v;
			}
		}

		private var _intelligenceRaw: Number = 3;
		public function get intelligenceRaw():Number
		{
			return _intelligenceRaw;
		}
		public function set intelligenceRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_intelligenceRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_intelligenceRaw = v;
			}
		}

		private var _willpowerRaw: Number = 3;
		public function get willpowerRaw():Number
		{
			return _willpowerRaw;
		}
		public function set willpowerRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_willpowerRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_willpowerRaw = v;
			}
		}

		private var _libidoRaw: Number = 3;
		public function get libidoRaw():Number
		{
			return _libidoRaw;
		}
		public function set libidoRaw(v:Number):void
		{
			if (v < Creature.STAT_CLAMP_VALUE)
			{
				_libidoRaw = Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				_libidoRaw = v;
			}
		}
		
		public var physiqueMod: Number = 0;
		public var reflexesMod: Number = 0;
		public var aimMod: Number = 0;
		public var intelligenceMod: Number = 0;
		public var willpowerMod: Number = 0;
		public var libidoMod: Number = 0;

		public var affinity: String = "intelligence";
		public var characterClass: int = GLOBAL.CLASS_SMUGGLER;

		//Combat Stats
		// I think some of my UI work has highlighted some areas where stats are doing things that aren't intended, or otherwise possibly broken.
		// The safest way I can think of fixing these issues, is to clamp the potential possible values given to the raw vars.
		
		// HP should probably never go BELOW 0, as it has implications on rest mechanics.
		private var _HPRaw: int = 0;
		
		public function get HPRaw():int { return _HPRaw; }
		public function set HPRaw(v:int):void
		{
			if (v < 0)
			{
				_HPRaw = 0;
			}
			else
			{
				_HPRaw = v;
			}
		}
		
		public var HPMod: int = 0;

		public var shieldsRaw: int = 0;
		public var lustRaw: Number = 0;
		public var lustMod: Number = 0;
		public var energyRaw: Number = 100;
		public var energyMod: Number = 0;
		public var teaseLevel: Number = 0;
		public var teaseXP: Number = 0;

		//Resistances
		public var resistances: Array = new Array(1, 1, 1, 1, 1, 1, 1, 1);
		public var bonusResistances: Array = new Array(0, 0, 0, 0, 0, 0, 0, 0);

		//Level Stats
		public var XPRaw: Number = 0;
		public var level: Number = 1;
		public var credits: Number = 500;
		//Perks used to store 'queued' perk buys
		public var perkPoints: Number = 0;

		//Appearance Variables
		public var femininity: Number = 50;
		public function femininityUnlocked(newFem:Number):Boolean 
		{
			return true;
		}
		public function femininityLockedMessage():String 
		{
			return "";
		}
		
		public var eyeType: Number = 0;
		public function eyeTypeUnlocked(newEyeType):Boolean 
		{
			return true;
		}
		public function eyeTypeLockedMessage():String
		{
			return "";
		}
		
		public var eyeColor: String = "";
		public function eyeColorUnlocked(newEyeColor:String):Boolean 
		{
			return true;
		}
		public function eyeColorLockedMessage():String 
		{
			return "";
		}
		
		public var tallness: Number = 0;
		public function tallnessUnlocked(newTallness:Number):Boolean
		{
			return true;
		}
		public function tallnessLockedMessage():String
		{
			return "";
		}

		public var thickness: Number = 0;
		public function thicknessUnlocked(newThickness:Number):Boolean
		{
			return true;
		}
		public function thicknessLockedMessage():String
		{
			return "";
		}

		public var tone: Number = 0;
		public function toneUnlocked(newTone:Number):Boolean
		{
			return true;
		}
		public function toneLockedMessage():String
		{
			return "";
		}

		public var hairColor: String = "no";
		public function hairColorUnlocked(newHairColor:String):Boolean
		{
			return true;
		}

		public function hairColorLockedMessage():String
		{
			return "";
		}

		public var scaleColor: String = "blue";
		public function scaleColorUnlocked(newScaleColor:String):Boolean
		{
			return true;
		}
		public function scaleColorLockedMessage():String
		{
			return "";
		}

		public var furColor: String = "brown";
		public function furColorUnlocked(newFurColor:String):Boolean
		{
			return true;
		}
		public function furColorLockedMessage():String
		{
			return "";
		}

		public var hairLength: Number = 0;
		public function hairLengthUnlocked(newHairLength:Number):Boolean
		{
			return true;
		}
		public function hairLengthLockedMessage():String
		{
			return "";
		}

		public var hairType: Number = 0;
		public function hairTypeUnlocked(newhairType:Number):Boolean
		{
			return true;
		}
		public function hairTypeLockedMessage():String
		{
			return "";
		}
		
		public var beardLength: Number = 0;
		public function beardLengthUnlocked(newBeardLength:Number):Boolean
		{
			return true;
		}
		public function beardLengthLockedMessage():String
		{
			return "";
		}

		public var beardStyle: Number = 0;
		public function beardStyleUnlocked(newBeardStyle:Number):Boolean
		{
			return true;
		}
		public function beardStyleLockedMessage():String
		{
			return "";
		}

		public var skinType: Number = 0;
		public function skinTypeUnlocked(newSkinType:Number):Boolean
		{
			return true;
		}
		public function skinTypeLockedMessage():String
		{
			return "";
		}

		public var skinTone: String = "albino";
		public function skinToneUnlocked(newSkinTone:String):Boolean
		{
			return true;
		}
		public function skinToneLockedMessage():String
		{
			return "";
		}

		public var skinFlags: Array = new Array();
		public function skinFlagsUnlocked(newFlags:*):Boolean
		{
			return true;
		}
		public function skinFlagsLockedMessage():String
		{
			return "";
		}

		public var faceType: Number = 0;
		public function faceTypeUnlocked(newFaceType:Number):Boolean
		{
			return true;
		}
		public function faceTypeLockedMessage():String
		{
			return "";
		}

		public var faceFlags: Array = new Array();
		public function faceFlagsUnlocked(newFlags:*):Boolean
		{
			return true;
		}
		public function faceFlagsLockedMessage():String
		{
			return "";
		}

		public var tongueType: Number = 0;
		public function tongueTypeUnlocked(newTongueType:Number):Boolean
		{
			return true;
		}
		public function tongueTypeLockedMessage():String
		{
			return "";
		}

		public var tongueFlags: Array = new Array();
		public function tongueFlagsUnlocked(newFlags:*):Boolean
		{
			return true;
		}
		public function tongueFlagsLockedMessage():String
		{
			return "";
		}

		public var lipMod:Number = 0;
		public function lipModUnlocked(newLipMod:Number):Boolean
		{
			return true;
		}
		public function lipModLockedMessage():String
		{
			return "";
		}
		public var lipColor:String = "peach";

		public var earType: Number = 0;
		public function earTypeUnlocked(newEarType:Number):Boolean
		{
			return true;
		}
		public function earTypeLockedMessage():String
		{
			return "";
		}

		public var antennae: Number = 0;
		public function antennaeUnlocked(newAntennaeNumber:Number):Boolean
		{
			return true;
		}
		public function antennaeLockedMessage():String
		{
			return "";
		}
		
		public var antennaeType: Number = 0;
		public function antennaeTypeUnlocked(newAntennaeType:Number):Boolean
		{
			return true;
		}
		public function antennaeTypeLockedMessage():String
		{
			return "";
		}
		
		public var horns: Number = 0;
		public function hornsUnlocked(newHornsNumber:Number):Boolean
		{
			return true;
		}
		public function hornsLockedMessage():String
		{
			return "";
		}
		
		public var hornType: Number = 0;
		public function hornTypeUnlocked(newHornType:Number):Boolean
		{
			return true;
		}
		public function hornTypeLockedMessage():String
		{
			return "";
		}
		
		public var hornLength: Number = 0;
		public function hornLengthUnlocked(newHornLength:Number):Boolean
		{
			return true;
		}
		public function hornLengthLockedMessage():String
		{
			return "";
		}
		
		public var armType: Number = 0;
		public function armTypeUnlocked(newArmType:Number):Boolean
		{
			return true;
		}
		public function armTypeLockedMessage():String
		{
			return "";
		}
		
		public var gills: Boolean = false;
		public function gillsUnlocked(newGills:Boolean):Boolean
		{
			return true;
		}
		public function gillsLockedMessage():String
		{
			return "";
		}
		
		public var wingType: Number = 0;
		public function wingTypeUnlocked(newWingType:Number):Boolean
		{
			return true;
		}
		public function wingTypeLockedMessage():String
		{
			return "";
		}

		public var legType: Number = 0;
		public function legTypeUnlocked(newLegType:Number):Boolean
		{
			if (newLegType != GLOBAL.TYPE_HUMAN && this.hasStatusEffect("Mimbrane Foot Left") || this.hasStatusEffect("Mimbrane Foot Right")) return false;
			return true;
		}
		public function legTypeLockedMessage():String
		{
			if (this.hasStatusEffect("Mimbrane Foot Left") && !this.hasStatusEffect("Mimbrane Foot Right") || !this.hasStatusEffect("Mimbrane Foot Left") && this.hasStatusEffect("Mimbrane Foot Right")) return "Suddenly your toes flex and dig, showing faint signs of your impending transformation. The appearance subsides, however, and you’re left with your " + foot() + ". With a heavy sigh, it would seem your Mimbrane refuses to give up the shape of your feet to whatever was in store for you before.";
			if (this.hasStatusEffect("Mimbrane Foot Left") && this.hasStatusEffect("Mimbrane Foot Right")) return "Suddenly your toes flex and dig, showing faint signs of your impending transformation. The appearance subsides, however, and you’re left with your " + feet() + ". With a heavy sigh, it would seem your Mimbranes refuse to give up the shape of your feet to whatever was in store for you before.";
			return "";
		}
		
		public var legCount: Number = 2;
		public function legCountUnlocked(newLegCount:Number):Boolean
		{
			if (this.hasStatusEffect("Mimbrane Foot Left") || this.hasStatusEffect("Mimbrane Foot Right")) return false;
			return true;
		}
		public function legCountLockedMessage():String
		{
			if ((this.hasStatusEffect("Mimbrane Foot Left") && !this.hasStatusEffect("Mimbrane Foot Right")) || !this.hasStatusEffect("Mimbrane Foot Left") && this.hasStatusEffect("Mimbrane Foot Right")) return "Your " + foot() + " clenches to an uncomfortable degree, refusing to be removed. The Mimbrane surrounding the extremity seems to counteract any attempts to remove its home.";
			if (this.hasStatusEffect("Mimbrane Foot Left") && this.hasStatusEffect("Mimbrane Foot Right")) return "Your " + feet() + " clench to an uncomfortable degree, refusing to be removed. The Mimbranes surrounding the extremities seem to counteract any attempts to remove their home.";
			return "";
		}
		
		public var legFlags: Array = new Array();
		public function legFlagsUnlocked(newFlags:*):Boolean
		{
			return true;
		}
		public function legFlagsLockedMessage():String
		{
			return "";
		}
		
		public var cumType: Number = GLOBAL.FLUID_TYPE_CUM;
		public function cumTypeUnlocked(newCumType:Number):Boolean
		{
			return true;
		}
		public function cumTypeLockedMessage():String
		{
			return "";
		}
		
		//0 - Waist
		//1 - Middle of a long tail. Defaults to waist on bipeds.
		//2 - Between last legs or at end of long tail.
		//3 - On underside of a tail, used for driders and the like, maybe?
		public var genitalSpot: Number = 0;
		public function genitalSpotUnlocked(newGenitalSpot:Number):Boolean
		{
			return true;
		}
		public function genitalSpotLockedMessage():String
		{
			return "";
		}

		public function genitalLocation(): Number {
			if (genitalSpot == 1 && legCount == 2) return 0;
			else if (genitalSpot == 3 && isDrider()) return 3;
			else return genitalSpot;
		}

		public var tailType: Number = 0;
		public function tailTypeUnlocked(newTailType:Number):Boolean
		{
			return true;
		}
		public function tailTypeLockedMessage():String
		{
			return "";
		}
		

		public var tailCount: Number = 0;
		public function tailCountUnlocked(newTailCount:Number):Boolean
		{
			return true;
		}
		public function tailCountLockedMessage():String
		{
			return "";
		}

		public var tailFlags: Array = new Array();
		public function tailFlagsUnlocked(newFlags:*):Boolean
		{
			return true;
		}
		public function tailFlagsLockedMessage():String
		{
			return "";
		}
		
		//Used to set cunt or dick type for cunt/dick tails!
		public var tailGenitalArg:Number = 0;
		public function tailGenitalArgUnlocked(newTailGenitalArg:Number):Boolean
		{
			return true;
		}
		public function tailGenitalArgLockedMessage():String
		{
			return "";
		}
		
		//tailGenital:
		//0 - none.
		//1 - cock
		//2 - vagina
		public var tailGenital: int = 0;
		public function tailGenitalUnlocked(newTailGenital:Number):Boolean
		{
			return true;
		}
		public function tailGenitalLockedMessage():String
		{
			return "";
		}

		//Tail venom is a 0-100 slider used for tail attacks. Recharges per hour.
		public var tailVenom: Number = 0;
		//Tail recharge determines how fast venom/webs comes back per hour.
		public var tailRecharge: Number = 5;
		//hipRating
		//0 - boyish
		//2 - slender
		//4 - average
		//6 - noticable/ample
		//10 - curvy//flaring
		//15 - child-bearing/fertile
		//20 - inhumanly wide
		public var hipRatingRaw:Number = 0;
		public var hipRatingMod:Number = 0;
		
		public function hipRating(arg:Number = 0, apply:Boolean = false):Number
		{
			if (apply)
			{
				hipRatingRaw = arg;
			}
			else
			{
				hipRatingRaw += arg;
			}
			
			var currHipRating:Number = hipRatingRaw + hipRatingMod;
			
			if (currHipRating < 0)
			{
				return 0;
			}
			else
			{
				return currHipRating;
			}
		}
		
		public function hipRatingUnlocked(newHipRating:Number):Boolean
		{
			return true;
		}
		public function hipRatingLockedMessage():String
		{
			return "";
		}

		//buttRating
		//0 - buttless
		//2 - tight
		//4 - average
		//6 - noticable
		//8 - large
		//10 - jiggly
		//13 - expansive
		//16 - huge
		//20 - inconceivably large/big/huge etc
		public var buttRatingRaw:Number = 0;
		public var buttRatingMod:Number = 0;
		
		public function buttRating(arg:Number = 0, apply:Boolean = false):Number
		{
			if (apply)
			{
				buttRatingRaw = arg;
			}
			else if (arg != 0)
			{
				buttRatingRaw += arg;
			}
			
			var currButtRating:Number = buttRatingRaw + buttRatingMod;
			
			if (currButtRating < 0)
			{
				return 0;
			}
			else
			{
				return currButtRating;
			}
		}
		
		public function buttRatingUnlocked(newButtRating:Number):Boolean
		{
			return true;
		}
		public function buttRatingLockedMessage():String
		{
			return "";
		}
		
		//Key items
		public var keyItems: Array;

		//Piercings
		public var nipplesPierced: Number = 0;
		public var nipplesPShort: String = "";
		public var nipplesPLong: String = "";
		public var lipPierced: Number = 0;
		public var lipPShort: String = "";
		public var lipPLong: String = "";
		public var tonguePierced: Number = 0;
		public var tonguePShort: String = "";
		public var tonguePLong: String = "";
		public var eyebrowPierced: Number = 0;
		public var eyebrowPShort: String = "";
		public var eyebrowPLong: String = "";
		public var earsPierced: Number = 0;
		public var earsPShort: String = "";
		public var earsPLong: String = "";
		public var nosePierced: Number = 0;
		public var nosePShort: String = "";
		public var nosePLong: String = "";

		//Sexual Stuff
		public var cocks: Array;
		public function cockLengthUnlocked(cockIndex:int, newCockLength:Number):Boolean
		{
			return true;
		}
		public function cockLengthLockedMessage():String
		{
			return "";
		}

		public function cockThicknessUnlocked(cockIndex:int, newCockThickness:Number):Boolean
		{
			return true;
		}
		public function cockThicknessLockedMessage():String
		{
			return "";
		}

		public function cockTypeUnlocked(cockIndex:int, newCockType:Number):Boolean
		{
			return true;
		}
		public function cockTypeLockedMessage():String
		{
			return "";
		}

		public function knotMultiplierUnlocked(cockIndex:int, newKnotMulti:Number):Boolean
		{
			return true;
		}
		public function knotMultiplierLockedMessage():String
		{
			return "";
		}

		public function flacidMultiplierUnlocked(cockIndex:int, newFlaccidMulti:Number):Boolean
		{
			return true;
		}
		public function flacidMultiplierLockedMessage():String
		{
			return "";
		}

		public function cockFlagsUnlocked(cockIndex:int, newFlags:*):Boolean
		{
			return true;
		}
		public function cockFlagsLockedMessage():String
		{
			return "";
		}

		//balls
		public var balls: Number = 0;
		public function ballsUnlocked(newBalls:Number):Boolean
		{
			if (newBalls == 0 && this.hasStatusEffect("Mimbrane Balls")) return false;
			return true;
		}
		public function ballsLockedMessage():String
		{
			if (this.hasStatusEffect("Mimbrane Balls")) return "A powerful tug around your " + ballsDescript() + " keeps them from disappearing into your body. The Mimbrane encapsulating your " +  sackDescript() + " seems poised to act against any attempts to fully remove your cum factories.";
			return "";
		}

		public var ballSizeRaw:Number = 1;
		public var ballSizeMod:Number = 1;
		
		public function ballDiameter():Number
		{
			return ballSize()/3.14;
		}

		public function ballVolume():Number
		{
			var radius:Number = ballDiameter()/2;
			return 4/3*3.14*radius*radius*radius;
		}

		public function ballSize(arg:Number = 0, apply:Boolean = false):Number
		{
			if (apply)
			{
				ballSizeRaw = arg;
			}
			else if (arg != 0)
			{
				ballSizeRaw += arg;
			}
			
			var currBallSize:Number = ballSizeRaw + ballSizeMod;
			
			if (currBallSize < 0)
			{
				return 0;
			}
			else
			{
				return currBallSize;
			}
		}
		
		public function ballSizeUnlocked(newBallSize:Number):Boolean
		{
			return true;
		}
		public function ballSizeLockedMessage():String
		{
			return "";
		}
		
		public var ballFullness: Number = 100;

		public function ballFullnessUnlocked(newBallFullness:Number):Boolean
		{
			return true;
		}
		public function ballFullnessLockedMessage():String
		{
			return "";
		}
		
		//Number of cumshots a day the PC can hold
		public var ballEfficiency: Number = 3;
		//Scales from 0 (never produce more) to infinity.
		public var refractoryRate: Number = 1;
		public var minutesSinceCum: Number = 0;
		public var timesCum: Number = 0;
		public var cockVirgin: Boolean = true;
		public var vaginas: Array;

		public function vaginaTypeUnlocked(vagIndex:int, newVagType:int):Boolean
		{
			return true;
		}
		public function vaginaTypeLockedMessage():String
		{
			return "";
		}

		public function clitsUnlocked(vagIndex:int, newClitNumber:int):Boolean
		{
			return true;
		}
		public function clitsLockedMessage():String
		{
			return "";
		}

		public function wetnessUnlocked(vagIndex:int, newWetness:Number):Boolean
		{
			return true;
		}
		public function wetnessLockedMessage():String
		{
			return "";
		}

		public function loosenessUnlocked(vagIndex:int, newLooseness:Number):Boolean
		{
			return true;
		}
		public function loosenessLockedMessage():String
		{
			return "";
		}

		public var clitLength: Number = .5;
		public function clitLengthUnlocked(newClitLength:Number):Boolean
		{
			return true;
		}
		public function clitLengthLockedMessage():String
		{
			return "";
		}
		
		public var elasticity: Number = 1;
		
		public var girlCumType: Number = GLOBAL.FLUID_TYPE_GIRLCUM;
		public function girlCumTypeUnlocked(newGirlCumType:Number):Boolean
		{
			return true;
		}
		public function girlCumTypeLockedMessage():String
		{
			return "";
		}
		
		public var vaginalVirgin: Boolean = true;
		public var breastRows: Array;

		public function breastsUnlocked(bRowIndex:int, newBreastCount:Number):Boolean
		{
			return true;
		}
		public function breastsLockedMessage():String
		{
			return "";
		}

		public function nippleTypeUnlocked(bRowIndex:int, newNippleType:Number):Boolean
		{
			return true;
		}
		public function nippleTypeLockedMessage():String
		{
			return "";
		}

		public function breastRatingUnlocked(bRowIndex:int, newBreastRating:Number):Boolean
		{
			return true;
		}
		public function breastRatingLockedMessage():String
		{
			return "";
		}

		public var nippleColor: String = "pink";
		public function nippleColorUnlocked(newNippleColor:String):Boolean
		{
			return true;
		}
		public function nippleColorLockedMessage():String
		{
			return "";
		}
		
		public var nipplesPerBreast: int = 1;
		public function nipplesPerBreastUnlocked(newNipplesPerBreast:int):Boolean
		{
			return true;
		}
		public function nipplesPerBreastLockedMessage():String
		{
			return "";
		}
		
		public var nippleLengthRatio: Number = 1;
		public function nippleLengthRatioUnlocked(newNippleLengthRatio:Number):Boolean
		{
			return true;
		}
		public function nippleLengthRatioLockedMessage():String
		{
			return "";
		}
		
		public var nippleWidthRatio: Number = 1;
		public function nippleWidthRatioUnlocked(newNippleWidthRatio:Number):Boolean
		{
			return true;
		}
		public function nippleWidthRatioLockedMessage():String
		{
			return "";
		}
		
		public var dickNippleMultiplier: int = 3;
		public function dickNippleMultiplierUnlocked(newDickNippleMultiplier:int):Boolean
		{
			return true;
		}
		public function dickNippleMultiplierLockedMessage():String
		{
			return "";
		}
		
		public var dickNippleType: int = 0;
		public function dickNippleTypeUnlocked(newDickNippleType:int):Boolean
		{
			return true;
		}
		public function dickNippleTypeLockedMessage():String
		{
			return "";
		}
		//This tracks whether or not the PC is actually producing yet. 0 to 100 with milk lactation starting above 50.
		public var milkMultiplier: Number = 0;
		public var milkType: Number = 0;
		public function milkTypeUnlocked(newMilkType:Number):Boolean
		{
			return true;
		}
		public function milkTypeLockedMessage():String
		{
			return "";
		}
		//This effects how much milk your tits can hold relative to human norms. High numbers = milk singularity
		public var milkStorageMultiplier:Number = 1;
		//This is a 1 to 100% measurement of how full yer tits are
		public var milkFullness:Number = 0;
		//The rate at which you produce milk. Scales from 0 to INFINITY.
		public var milkRate: Number = 10;

		public var ass = new VaginaClass(false);
		public var analVirgin: Boolean = true;
		public var perks: Array;
		public var statusEffects: Array;		

		//Used for misc shit
		var list: Array = new Array();

		public var sexualPreferences: SexualPreferences;

		//Functions
		//UTILITIES
		public function num2Text(number: Number): String {
			var returnVar: String = null;
			var numWords = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten");
			if (number > 10 || int(number) != number) {
				returnVar = "" + number;
			} else {
				returnVar = numWords[number];
			}
			return (returnVar);
		}

		public function buysType(arg: int): Boolean {
			for (var x: int = 0; x < typesBought.length; x++) {
				if (typesBought[x] == GLOBAL.ALL) return true;
				if (arg == typesBought[x]) return true;
			}
			return false;
		}

		public function getDescription(arg: String, arg2: * ): String {
			//trace("Legacy! Please access object members directly!")
			var firstLetter: String = arg.substr(0, 1);
			firstLetter = firstLetter.toLowerCase();
			var restOfString: String = arg.substr(1, arg.length);
			var desc: String = firstLetter + restOfString;
			//var desc = arg;
			var buffer: String = "<b>Error, invalid description. Passed description call: \"" + arg + "\" with argument: \"" + arg2 + "\"</b>";
			if (!arg2) arg2 = 0;
			switch (desc) {
				case "height":
					buffer = height();
					break;
				case "gear":
					buffer = gearDescript();
					break;
				case "short":
				case "name":
					buffer = short;
					break;
				case "race":
					buffer = race();
					break;
				case "armor":
					buffer = armor.longName;
					break;
				case "weapon":
					buffer = getWeaponName();
					break;
				case "meleeWeapon":
					buffer = meleeWeapon.longName;
					break;
				case "rangedWeapon":
					buffer = rangedWeapon.longName;
					break;
				case "lowerUndergarment":
					buffer = lowerUndergarment.longName;
					break;
				case "upperUndergarment":
					buffer = upperUndergarment.longName;
					break;
				case "upperGarment":
					buffer = upperGarmentDescript();
					break;
				case "upperGarments":
					buffer = upperGarmentsDescript();
					break;
				case "lowerGarments":
				case "underGarments":
					buffer = lowerGarmentsDescript();
					break;
				case "lowerGarment":
				case "underGarment":
					buffer = lowerGarmentDescript();
					break;
				case "skinNoun":
					buffer = skinNoun(true);
					break;
				case "skinFurScalesNoun":
					buffer = skinNoun(false);
					break;
				case "skinFurScales":
				case "skinfurscales":
					buffer = skinFurScales();
					break;
				case "skin":
					buffer = skin();
					break;
				case "ears":
					buffer = earsDescript();
					break;
				case "ear":
					buffer = earDescript();
					break;
				case "eyes":
					buffer = eyesDescript();
					break;
				case "eye":
					buffer = eyeDescript();
					break;
				case "eyePigment":
				case "eyeColor":
					buffer = eyeColor;
					break;
				case "hairsDescript":
					buffer = hairsDescript();
					break;
				case "hairDescript":
				case "hair":
					buffer = hairDescript();
					break;
				case "hairColor":
					buffer = hairColor;
					break;
				case "face":
					buffer = face();
					break;
				case "lips":
					buffer = pluralize(lipDescript());
					break;
				case "lip":
					buffer = lipDescript();
					break;
				case "lipColor":
					buffer = lipColor;
					break;
				case "tongue":
					buffer = tongueDescript();
					break;
				case "tail":
					buffer = tailDescript();
					break;
				case "tails":
					buffer = tailsDescript();
					break;
				case "crotch":
				case "groin":
					buffer = crotchDescript();
					break;
				case "base":
				case "sheath":
				case "sheathDescript":
					buffer = sheathDescript(arg2);
					break;
				case "biggestSheath":
				case "sheathBiggest":
					buffer = sheathDescript(biggestCockIndex());
					break;
				case "knot":
					buffer = knotDescript(arg2);
					break;
				case "multiCockDescript":
				case "multiCocks":
					buffer = multiCockDescript();
					break;
				case "cocks":
				case "cocksDescript":
					buffer = cocksDescript();
					break;
				case "cocksDescriptLight":
				case "cocksLight":
					buffer = cocksDescriptLight();
					break;
				case "cockNounComplex":
					buffer = cockNounComplex(arg2);
					break;
				case "cockNounSimple":
				case "cockNoun":
					buffer = simpleCockNoun(arg2);
					break;
				case "cocksNounSimple":
					buffer = simpleCocksNoun();
					break;
				case "cockColor":
				case "dickColor":
					buffer = cockColor(arg2);
					break;
				case "vaginaColor":
				case "cuntColor":
				case "pussyColor":
					buffer = vaginaColor(arg2);
					break;
				case "cockHead":
				case "cockhead":
					buffer = cockHead(arg2);
					break;
				case "cockHeads":
					buffer = cockHeads(arg2);
					break;
				case "cockDescript":
				case "cock":
					buffer = cockDescript(arg2);
					break;
				case "biggestCockDescript":
				case "biggestCock":
				case "cockBiggest":
					buffer = cockDescript(biggestCockIndex());
					break;
				case "biggestCockHead":
				case "cockHeadBiggest":
					buffer = cockHead(biggestCockIndex());
					break;
				case "smellestCockDescript":
				case "smallestCock":
				case "cockSmallest":
					buffer = cockDescript(smallestCockIndex());
					break;
				case "eachCockHead":
					buffer = eachCockHead();
					break;
				case "tailCock":
				case "cockTail":
					buffer = tailCockDescript();
					break;
				case "nipple":
				case "nippleDescript":
					buffer = nippleDescript(arg2);
					break;
				case "nipples":
				case "nipplesDescript":
					buffer = nipplesDescript(arg2);
					break;
				case "milkyNipple":
					buffer = nippleDescript(arg2, false, true);
					break;
				case "milkyNipples":
					buffer = nipplesDescript(arg2, true);
					break;
				case "nippleCockDescript":
				case "nippleCock":
				case "dickNipple":
					buffer = nippleCockDescript();
					break;
				case "nippleCocksDescript":
				case "nippleCocks":
				case "dickNipples":
					buffer = pluralize(nippleCockDescript());
					break;
				case "nippleColor":
					buffer = nippleColor;
					break;
				case "eachCock":
					buffer = eachCock();
					break;
				case "oneCock":
					buffer = oneCock();
					break;
				case "balls":
					buffer = ballsDescript();
					break;
				case "ball":
					buffer = ballsDescript();
					break;
				case "sack":
					buffer = sackDescript();
					break;
				case "chestDesc":
				case "chest":
					buffer = chestDesc();
					break;
				case "breastCupSize":
					buffer = breastCup(arg2);
					break;
				case "allChestDescript":
				case "fullChest":
					buffer = allChestDesc();
					break;
				case "biggestBreastDescript":
					buffer = biggestBreastDescript();
					break;
				case "breasts":
				case "boobs":
					buffer = breastDescript(arg2);
					break;
				case "cockClit":
					buffer = cockClit(arg2);
					break;
				case "assholeDescript":
				case "asshole":
					buffer = assholeDescript();
					break;
				case "buttDescript":
				case "butt":
				case "ass":
					buffer = buttDescript();
					break;
				case "hipDescript":
				case "hip":
					buffer = hipDescript();
					break;
				case "hipsDescript":
				case "hips":
					buffer = hipsDescript();
					break;
				case "thighDescript":
				case "thigh":
					buffer = thighDescript();
					break;
				case "thighsDescript":
				case "thighs":
					buffer = thighsDescript();
					break;
				case "vagina":
				case "pussy":
				case "cunt":
					buffer = vaginaDescript(arg2);
					break;
				case "vaginaNounSimple":
				case "vaginaNoun":
				case "pussyNoun":
					buffer = vaginaNounDescript(arg2);
					break;
				case "vaginas":
				case "pussies":
				case "cunts":
					buffer = vaginasDescript();
					break;
				case "eachVagina":
				case "eachPussy":
				case "eachCunt":
					buffer = eachVagina();
					break;
				case "oneVagina":
				case "onePussy":
				case "oneCunt":
					buffer = oneVagina();
					break;
				case "vagOrAss":
				case "pussyOrAsshole":
					buffer = vagOrAss(arg2);
					break;
				case "clit":
					buffer = clitDescript();
					break;
				case "eachClit":
					buffer = eachClit();
					break;
				case "oneClit":
					buffer = oneClit();
					break;
				case "clits":
					buffer = clitsDescript();
					break;
				case "tailVagina":
				case "tailCunt":
				case "cuntTail":
				case "tailgina":
					buffer = tailVaginaDescript();
					break;
				case "tailVaginas":
				case "tailCunts":
				case "cuntTails":
				case "tailginas":
					buffer = tailVaginasDescript();
					break;
				case "oneTailgina":
				case "oneTailCunt":
					buffer = oneTailVaginaDescript();
					break;
				case "milkNoun":
					buffer = fluidNoun(milkType);
					break;
				case "milkDescript":
				case "milk":
					buffer = milkDescript();
					break;
				case "cumDescript":
				case "cum":
					buffer = cumDescript();
					break;
				case "girlCumDescript":
				case "girlCum":
				case "girlcum":
					buffer = girlCumDescript();
					break;
				case "cumNoun":
					buffer = fluidNoun(cumType);
					break;
				case "girlCumNoun":
					buffer = fluidNoun(girlCumType);
					break;
				case "cumColor":
					buffer = cumColor();
					break;
				case "girlCumColor":
					buffer = girlCumColor();
					break;
				case "milkColor":
					buffer = milkColor();
					break;
				case "cumVisc":
					buffer = fluidViscosity(cumType);
					break;
				case "girlCumVisc":
					buffer = fluidViscosity(girlCumType);
					break;
				case "milkVisc":
					buffer = fluidViscosity(milkType);
					break;
				case "cumFlavor":
					buffer = fluidFlavor(cumType);
					break;
				case "girlCumFlavor":
					buffer = fluidFlavor(girlCumType);
					break;
				case "milkFlavor":
					buffer = fluidFlavor(milkType);
					break;
				case "leg":
					buffer = leg();
					break;
				case "legs":
					buffer = legs();
					break;
				case "leg(s)":
					buffer = legOrLegs();
					break;
				case "feet":
					buffer = feet();
					break;
				case "foot":
					buffer = foot();
					break;
				case "toes":
					buffer = toes();
					break;
				case "knees":
					buffer = kneesDescript();
					break;
				case "belly":
					buffer = bellyDescript();
					break;
				case "he":
				case "she":
				case "heShe": // Shamelessly stole these from Alderbro. :3
				case "ey":
					buffer = this.mf("he", "she");
					break;
				case "him":
				case "himHer":
				case "em":
					buffer = this.mf("him", "her");
					break;
				case "his":
				case "hisHer":
				case "eir":
					buffer = this.mf("his", "her");
					break;
				case "hisHers":
				case "eirs":
					buffer = this.mf("his", "hers");
					break;
				case "skinTone":
					buffer = this.skinTone;
					break;
				case "boy":
				case "girl":
					buffer = this.mf("boy", "girl");
					break;
				case "cockShape":
				case "cockshape":
				case "cockType":
				case "cocktype":
					buffer = cockShape(arg2);
					break;
				default:
					// error production is now done up-stream in the parser
					// Gedan: I ain't seeing no errors, so I'm gonna Throw on unknown tags to make their presence 120% obvious when turbotesting scenes.
					//throw new Error("Unmatched tag descriptor: " + desc);
					trace("ERROR: Unmatched tag descriptor detected: " + desc);
					return null; // "<b>Error, invalid description. Passed description call: \"" + arg + "\" with argument: \"" + arg2 + "\"</b>";
					
					break;
			}
			if (arg.charCodeAt(0) > 64 && arg.charCodeAt(0) < 90) buffer = upperCase(buffer);
			// trace("BUFFER OUT: " + buffer);
			return buffer;
		}
		public function Num2Text(number: int): String {
			return upperCase(num2Text(number));
		}
		public function numTwoText(number: int): String {
			var returnVar: String = null;
			var numWords = new Array("zero", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth");
			if (number > 10) {
				returnVar = "" + number + "th";
			} else {
				returnVar = numWords[number];
			}
			return (returnVar);
		}
		public function NumTwoText(number: int): String {
			return upperCase(numTwoText(number));
		}
		public function upperCase(str: String): String {
			var firstChar: String = str.substr(0, 1);
			var restOfString: String = str.substr(1, str.length);
			return firstChar.toUpperCase() + restOfString;
		}
		public function pluralize(str: String): String {
			var lastChar: String = str.substr(str.length - 1, str.length);
			var nextToLastChar: String = str.substr(str.length - 2, str.length - 1);
			//Various weird pluralize shits
			if (lastChar == "s") str += "es";
			else if (nextToLastChar == "s" && lastChar == "h") str += "es";
			else if (lastChar == "x") str += "es";
			//Normal pluralizes
			else str += "s";
			return str;
		}
		public function inventorySlots(): int {
			var slots:int = 10;
			if(accessory.shortName == "Cargobot") slots += 2;
			if(hasPerk("Hidden Loot")) slots += 2;
			return slots;
		}
		public function hasItem(arg:ItemSlotClass,amount:int = 1):Boolean
		{
			if(inventory.length == 0) return false;
			var foundAmount:int = 0;
			for(var x:int = 0; x < inventory.length; x++)
			{
				if(inventory[x].shortName == arg.shortName) foundAmount += inventory[x].quantity;
			}
			if(foundAmount >= amount) return true;
			return false;
		}
		public function destroyItem(arg:ItemSlotClass,amount:int = 1):void
		{
			if(inventory.length == 0) return;
			var foundAmount:int = 0;
			for(var x:int = 0; x < inventory.length; x++)
			{
				//Item in the slot?
				if(inventory[x].shortName == arg.shortName) 
				{
					//If we still need to eat some, eat em up!
					while(amount > 0 && inventory[x].quantity > 0) 
					{
						inventory[x].quantity--;
						amount--;
						if(inventory[x].quantity <= 0) inventory.splice(x,1);
					}
				}
			}
			return;
		}
		public function getWeaponName():String
		{
			if (!(rangedWeapon is EmptySlot)) return rangedWeapon.longName;
			if (!(meleeWeapon is EmptySlot)) return meleeWeapon.longName;
			return "fists";
		}
		public function orgasm(): void {
			lustRaw = 0;
			energy(-5);
			minutesSinceCum = 0;
			timesCum++;
			
			// NaN production was down to maxCum
			// if the player didn't have a cock, maxCum returns 0.
			// anything / 0 = NaN
			if (hasCock())
			{
				ballFullness = Math.round(((currentCum() - cumQ()) / maxCum()) * 100);
			}
			
			if (this is PlayerCharacter) 
			{
				StatTracking.track("sex/player/orgasms");
			}
			else
			{
				StatTracking.track("characters/" + this.short + "/orgasms");
			}
			
			if (hasStatusEffect("Dumbfuck"))
			{
				if(!hasStatusEffect("Dumbfuck Orgasm Procced"))
				{
					createStatusEffect("Dumbfuck Orgasm Procced", 0, 0, 0, 0, true, "", "", false, 0);
				}
				addStatusValue("Dumbfuck Orgasm Procced",1,1);
				trace("DUMBFUCK STATUS:" + statusEffectv1("Dumbfuck Orgasm Procced"));
			}
		}
		
		public function isNude(): Boolean {
			if(hasStatusEffect("Temporary Nudity Cheat")) return true;
			return (armor.shortName == "" && lowerUndergarment.shortName == "" && upperUndergarment.shortName == "");
		}
		public function isCrotchGarbed(): Boolean {
			if(hasStatusEffect("Temporary Nudity Cheat")) return false;
			return (armor.shortName != "" || lowerUndergarment.shortName != "");
		}
		public function isGroinCovered(): Boolean {
			return isCrotchGarbed();
		}
		public function isChestCovered(): Boolean {
			if(hasStatusEffect("Temporary Nudity Cheat")) return false;
			return (armor.shortName != "" || upperUndergarment.shortName != "");
		}
		public function isChestGarbed(): Boolean {
			return isChestCovered();
		}
		//XP!
		function XP(arg: int = 0): Number {
			XPRaw += arg;
			if (XPRaw >= XPMax()) XPRaw = XPMax();
			else if (XPRaw <= 0) XPRaw = 0;
			return XPRaw;
		}
		function XPMax(): Number {
			return level * level * 100;
		}
		//HP
		public function HP(arg: Number = 0): Number {
			HPRaw += arg;
			if (HPRaw > HPMax()) HPRaw = HPMax();
			return HPRaw;
		}
		public function HPMax(): Number {
			var hitPoints: Number = 15 + (level - 1) * 15 + HPMod;
			if (characterClass == GLOBAL.CLASS_MERCENARY)
				hitPoints += level * 5;
			if (characterClass == GLOBAL.CLASS_ENGINEER)
				hitPoints -= level * 5;
			return hitPoints;
		}
		public function maxHP(): Number {
			return HPMax();
		}
		public function maxOutHP(): void {
			HPRaw = HPMax();
		}
		//ENERGY
		public function energy(arg: Number = 0): Number {
			energyRaw += arg;
			if (energyRaw > energyMax()) energyRaw = energyMax();
			else if (energyRaw < energyMin()) energyRaw = energyMin();
			return energyRaw;
		}
		public function energyMax(): Number {
			return energyMod + 100;
		}
		public function energyMin(): Number {
			return 0;
		}
		public function maxOutEnergy(): void {
			energyRaw = energyMax();
		}
		//Lust
		public function lust(arg:Number = 0, apply:Boolean = false): Number 
		{
			if (apply) 
			{
				lustRaw = arg;
			}
			else if (arg != 0) 
			{
				lustRaw += arg;
				if (lustRaw > lustMax()) 
				{
					lustRaw = lustMax();
				}
				if (lustRaw < lustMin()) 
				{
					lustRaw = lustMin();
				}
			}
			
			var currLust:int = lustRaw + lustMod;

			if (currLust > lustMax()) 
			{
				return lustMax();
			}
			else if (currLust < lustMin())
			{
				return lustMin();
			}
			else 
			{
				return currLust;
			}
		}
		public function lustDamage(arg:Number = 0):Number
		{
			if(hasStatusEffect("Sex On a Meteor")) arg *= 1.5;
			if(hasPerk("Easy")) arg *= 1.2;
			return lust(arg);
		}
		//% of max. Useful for determining things like how strong a PC is for his/her level.
		public function PQ():Number
		{
			return Math.round(physique()/physiqueMax()*100);
		}
		public function physique(arg:Number = 0, apply:Boolean = false):Number 
		{
			if (apply) 
			{
				physiqueRaw = arg;
			}
			else if (arg != 0) 
			{
				physiqueRaw += arg;
				if (physiqueRaw > physiqueMax()) 
				{
					physiqueRaw = physiqueMax();
				}
			}

			var currPhys:int = physiqueRaw + physiqueMod;

			if(hasStatusEffect("Trip")) currPhys -= 4;

			if (currPhys > physiqueMax()) 
			{
				return physiqueMax();
			}
			else if (currPhys < Creature.STAT_CLAMP_VALUE)
			{
				return Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				return currPhys;
			}
		}
		
		public function reflexes(arg:Number = 0, apply:Boolean = false):Number
		{
			if (apply) 
			{
				reflexesRaw = arg;
			}
			else if (arg != 0) 
			{
				reflexesRaw += arg;
				if (reflexesRaw > reflexesMax())
				{
					reflexesRaw = reflexesMax();
				}
			}

			var currReflexes:int = reflexesRaw + reflexesMod;

			//Debuffs!
			if(hasStatusEffect("Trip")) currReflexes -= 4;

			if (currReflexes > reflexesMax())
			{
				return reflexesMax();
			}
			else if (currReflexes < Creature.STAT_CLAMP_VALUE)
			{
				return Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				return currReflexes;
			}
		}

		public function aim(arg:Number = 0, apply:Boolean = false):Number 
		{
			if (apply)
			{
				aimRaw = arg;
			}
			else if (arg != 0)
			{
				aimRaw += arg;
				if (aimRaw > aimMax())
				{
					aimRaw = aimMax();
				}
			}
			
			var currAim:int = aimRaw + aimMod;
			
			if (currAim > aimMax())
			{
				return aimMax();
			}
			else if (currAim < Creature.STAT_CLAMP_VALUE)
			{
				return Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				return currAim;
			}
		}

		// HUE
		public function IQ():Number
		{
			return Math.round(intelligence()/intelligenceMax()*100);
		}
		
		public function intelligence(arg:Number = 0, apply:Boolean = false):Number 
		{
			if (apply)
			{
				intelligenceRaw = arg;
			}
			else if (arg != 0)
			{
				//Certain bimbo TFs reduce gains by 50%.
				if(hasPerk("Drug Fucked") && arg > 0) arg /= 2;
				intelligenceRaw += arg;
				if (intelligenceRaw > intelligenceMax())
				{
					intelligenceRaw = intelligenceMax();
				}
			}

			var currInt:int = intelligenceRaw + intelligenceMod;

			if (currInt > intelligenceMax())
			{
				return intelligenceMax();
			}
			else if (currInt < Creature.STAT_CLAMP_VALUE)
			{
				return Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				return currInt;
			}
		}

		public function willpower(arg:Number = 0, apply:Boolean = false):Number 
		{
			if (apply)
			{
				willpowerRaw = arg;
			}
			else if (arg != 0)
			{
				if(arg < 0 && hasStatusEffect("Weak Will")) arg *= 2;
				willpowerRaw += arg;
				if (willpowerRaw > willpowerMax())
				{
					willpowerRaw = willpowerMax();
				}
			}
			var currWill:int = willpowerRaw + willpowerMod;

			//Level 7 Merc Perk
			if(hasPerk("Iron Will")) currWill += Math.floor(physique()/5);
			
			if (currWill > willpowerMax())
			{
				return willpowerMax();
			}
			else if (currWill < Creature.STAT_CLAMP_VALUE)
			{
				return Creature.STAT_CLAMP_VALUE;
			}
			else
			{
				return currWill;
			}
		}

		public function libido(arg:Number = 0, apply:Boolean = false):Number 
		{
			if (apply)
			{
				libidoRaw = arg;
			}
			else if (arg != 0)
			{
				//Certain bimbo TFs double gains
				if(hasPerk("Drug Fucked") && arg > 0) arg *= 2;
				libidoRaw += arg;
				if (libidoRaw > libidoMax())
				{
					libidoRaw = libidoMax();
				}
				if (libidoRaw < libidoMin())
				{
					libidoRaw = libidoMin();
				}
			}
			
			var currLib:int = libidoMod + libidoRaw;

			if (currLib > libidoMax())
			{
				return libidoMax();
			}
			else if (currLib < libidoMin())
			{
				return libidoMin();;
			}
			else
			{
				return currLib;
			}
		}

		public function lustMax(): Number {
			var bonus:int = 0;
			if(hasPerk("Inhuman Desire")) bonus += perkv1("Inhuman Desire");
			//trace("Max lust: " + (bonus + 100));
			return (100 + bonus);
		}
		public function lustMin(): Number {
			var bonus:int = 0;
			if(hasPerk("Drug Fucked")) bonus += 10;
			if(hasStatusEffect("Ellie's Milk")) bonus += 33;
			return (0 + bonus);
		}
		public function physiqueMax(): Number {
			var bonuses:int = 0;
			if(hasStatusEffect("Quivering Quasar")) bonuses += 5;
			return level * 5 + bonuses;
		}
		public function reflexesMax(): Number {
			return level * 5;
		}
		public function aimMax(): Number {
			return level * 5;
		}
		public function intelligenceMax(): Number {
			return level * 5;
		}
		public function willpowerMax(): Number {
			return level * 5;
		}
		public function libidoMax(): Number {
			return 100;
		}
		public function libidoMin(): Number {
			var bonus:int = 0;
			if(hasPerk("Drug Fucked")) bonus += 40;
			return (0 + bonus);
		}
		public function slowStatGain(stat: String, arg: Number = 0): Number {
			var statCurrent: Number = 0;
			var change: Number = 0;
			if (stat == "physique") statCurrent = physique();
			else if (stat == "reflexes") statCurrent = reflexes();
			else if (stat == "aim") statCurrent = aim();
			else if (stat == "intelligence") statCurrent = intelligence();
			else if (stat == "willpower") statCurrent = willpower();
			else if (stat == "libido") statCurrent = libido();
			else {
				trace("ERROR: slowStatGain called with stat argument of " + stat + ". This isn't a real stat!");
				return 0;
			}
			while (arg > 0) {
				arg--;
				if (statCurrent + change < 30) change++;
				else if (statCurrent + change < 40) change += .9;
				else if (statCurrent + change < 50) change += .8;
				else if (statCurrent + change < 60) change += .7;
				else if (statCurrent + change < 65) change += .6;
				else if (statCurrent + change < 70) change += .5;
				else if (statCurrent + change < 75) change += .4;
				else if (statCurrent + change < 80) change += .3;
				else if (statCurrent + change < 85) change += .25;
				else if (statCurrent + change < 90) change += .2;
				else if (statCurrent + change < 95) change += .15;
				if(arg < 0) arg = 0;
			}
			if (stat == "physique") return physique(change);
			else if (stat == "reflexes") return reflexes(change);
			else if (stat == "aim") return aim(change);
			else if (stat == "intelligence") return intelligence(change);
			else if (stat == "willpower") return willpower(change);
			else if (stat == "libido") return libido(change);
			else {
				trace("ERROR: slowStatGain got to the end with a stat that should've called the earlier error. Looks like the function has been changed, added to, or bugged. Make sure top stat list matches bottom!");
				return 0;
			}
		}
		public function hasEnergyWeapon():Boolean
		{
			return hasMeleeEnergyWeapon() || hasRangedEnergyWeapon();
		}
		public function hasMeleeEnergyWeapon():Boolean
		{
			if(meleeWeapon.damageType > 2 && meleeWeapon.damageType != 8) return true;
			return false;
		}
		public function hasRangedEnergyWeapon():Boolean
		{
			if(rangedWeapon.damageType > 2 && rangedWeapon.damageType != 8) return true;
			return false;
		}
		//Item bonus stats!
		public function attack(melee: Boolean = true): Number {
			var temp: int = 0;
			if (melee) temp += meleeWeapon.attack;
			else temp += rangedWeapon.attack;
			//Bonus to hit for Tech Specialists above level 7!
			if(hasPerk("Fight Smarter")) temp += Math.round(intelligence()/7);
			temp += armor.attack + upperUndergarment.attack + lowerUndergarment.attack + accessory.attack + shield.attack;
			return temp;
		}
		public function damage(melee: Boolean = true): Number {
			var temp: int = 0;
			if (melee) 
			{
				temp += meleeWeapon.damage;
				if(hasPerk("Low Tech Solutions") && !hasMeleeEnergyWeapon()) 
					temp += Math.ceil(meleeWeapon.damage * 0.2);
				if(hasPerk("Weapon Tweaks") && hasMeleeEnergyWeapon()) 
					temp += Math.ceil(meleeWeapon.damage * 0.2);
			}
			else 
			{
				temp += rangedWeapon.damage;
				if(hasPerk("Heavy Weapons") && !hasMeleeEnergyWeapon()) 
					temp += Math.ceil(rangedWeapon.damage * 0.2);
				if(hasPerk("Gun Tweaks") && hasMeleeEnergyWeapon()) 
					temp += Math.ceil(rangedWeapon.damage * 0.2);
				//Concentrated fire bonus!
				temp += statusEffectv1("Concentrated Fire");
				trace("Concentrated fire bonus applied: " + statusEffectv1("Concentrated Fire"));
			}
			temp += armor.damage + upperUndergarment.damage + lowerUndergarment.damage + accessory.damage + shield.damage;
			return temp;
		}
		public function defense(): Number {
			var temp: int = 0;
			temp += meleeWeapon.defense;
			temp += rangedWeapon.defense;
			temp += armor.defense + upperUndergarment.defense + lowerUndergarment.defense + accessory.defense + shield.defense;
			if (hasStatusEffect("Harden")) temp += 1;
			if (hasPerk("Armor Tweaks")) temp += Math.round(armor.defense * .2);
			if (hasStatusEffect("Burning")) 
			{
				temp -= 5;
				if(temp < 0) temp = 0;
			}
			return temp;
		}
		public function shieldDefense(): Number {
			var temp: int = 0;
			temp += meleeWeapon.shieldDefense;
			temp += rangedWeapon.shieldDefense;
			temp += armor.shieldDefense + upperUndergarment.shieldDefense + lowerUndergarment.shieldDefense + accessory.shieldDefense + shield.shieldDefense;
			return temp;
		}
		public function shields(arg: Number = 0): Number {
			shieldsRaw += arg;
			if (shieldsRaw > shieldsMax())
				shieldsRaw = shieldsMax();
			if (shieldsRaw < 0) shieldsRaw = 0;
			return shieldsRaw;
		}
		public function shieldsMax(): Number {
			var temp: int = 0;
			temp += meleeWeapon.shields;
			temp += rangedWeapon.shields;
			temp += armor.shields + upperUndergarment.shields + lowerUndergarment.shields + accessory.shields + shield.shields;
			if (hasPerk("Shield Tweaks")) temp += level * 2;
			if (hasPerk("Shield Booster")) temp += level * 4;

			//Debuffs!
			if(hasStatusEffect("Rusted Emitters")) temp = Math.round(temp * 0.75);
			//No proper shield generator? NO SHIELD!
			if(shield.shields == 0) temp = 0;
			return temp;
		}
		public function sexiness(): Number {
			var temp: int = 0;
			temp += meleeWeapon.sexiness;
			temp += rangedWeapon.sexiness;
			temp += armor.sexiness + upperUndergarment.sexiness + lowerUndergarment.sexiness + accessory.sexiness + shield.sexiness;
			return temp;
		}
		public function critBonus(melee: Boolean = true): Number {
			var temp: int = 0;
			if (melee) temp += meleeWeapon.critBonus;
			else temp += rangedWeapon.critBonus;
			temp += armor.critBonus + upperUndergarment.critBonus + lowerUndergarment.critBonus + accessory.critBonus + shield.critBonus;
			return temp;
		}
		public function evasion(): Number {
			var temp: int = 0;
			temp += meleeWeapon.evasion;
			temp += rangedWeapon.evasion;
			temp += armor.evasion + upperUndergarment.evasion + lowerUndergarment.evasion + accessory.evasion + shield.evasion;
			if (hasPerk("Agility")) {
				if ((temp *= .2) < 6) temp += 6;
				else temp = Math.round(temp * 1.2);
			}
			if (hasPerk("Improved Agility")) {
				temp += 6;
			}
			if (hasStatusEffect("Riposting"))
			{
				temp += 15;
			}
			if (hasStatusEffect("Stealth Field Generator")) temp += 80;
			if (temp > 90) temp = 90;
			return temp;
		}
		public function fortification(): Number {
			var temp: int = 0;
			temp += meleeWeapon.fortification;
			temp += rangedWeapon.fortification;
			temp += armor.fortification + upperUndergarment.fortification + lowerUndergarment.fortification + accessory.fortification + shield.fortification;
			return temp;
		}
		public function getResistance(type: int): Number {
			var total: Number = resistances[type];
			total += bonusResistances[type];
			total += armor.bonusResistances[type];
			total += accessory.bonusResistances[type];
			if((hasPerk("Tough") || hasStatusEffect("Harden")) && (type == GLOBAL.KINETIC || type == GLOBAL.SLASHING || type == GLOBAL.PIERCING)) 
			{
				if(hasPerk("Tough 2")) total -= 0.05;
				total -= .1;
			}
			if(total < 0) total = 0;
			return Math.round(total * 10) / 10;
		}
		public function getShieldResistance(type: int): Number {
			var total: Number = 1;
			var resist: Number = shield.bonusResistances[type];
			//Dampeners perk reduces vulnerabilities!
			if (resist < 0 && hasPerk("Enhanced Dampeners")) resist /= 2;
			total -= resist;
			return Math.round(total * 10) / 10;
		}
		public function hasSkinFlag(arg): Boolean {
			var temp: int = 0;
			while (temp < skinFlags.length) {
				if (skinFlags[temp] == arg) return true;
				temp++;
			}
			return false;
		}
		public function addSkinFlag(arg): void {
			if (!hasSkinFlag(arg)) skinFlags[skinFlags.length] = arg;
		}
		public function clearSkinFlags(): void {
			skinFlags = new Array();
		}
		public function hasFaceFlag(arg): Boolean {
			var temp: int = 0;
			while (temp < faceFlags.length) {
				if (faceFlags[temp] == arg) return true;
				temp++;
			}
			return false;
		}
		public function addFaceFlag(arg): void {
			if (!hasFaceFlag(arg)) faceFlags[faceFlags.length] = arg;
		}
		public function clearFaceFlags(): void {
			faceFlags = new Array();
		}
		public function hasTailFlag(arg): Boolean {
			for (var temp: int = 0; temp < tailFlags.length; temp++) {
				if (tailFlags[temp] == arg) return true;
			}
			return false;
		}
		public function addTailFlag(arg): void {
			if (!hasTailFlag(arg)) tailFlags[tailFlags.length] = arg;
		}
		public function clearTailFlags(): void {
			tailFlags = new Array();
		}
		public function hasLegFlag(arg): Boolean {
			for (var temp: int = 0; temp < legFlags.length; temp++) {
				if (legFlags[temp] == arg) return true;
			}
			return false;
		}
		public function addLegFlag(arg): void {
			if (!hasLegFlag(arg)) legFlags[legFlags.length] = arg;
		}
		public function clearLegFlags(): void {
			legFlags = new Array();
		}
		public function hasLeg(): Boolean {
			return (hasLegFlag(GLOBAL.FLAG_DIGITIGRADE) || hasLegFlag(GLOBAL.FLAG_PLANTIGRADE));
			return false;
		}
		public function hasLegs(): Boolean {
			return (hasLeg() && legCount > 1);
		}
		public function hasTongueFlag(arg): Boolean {
			var temp: int = 0;
			while (temp < tongueFlags.length) {
				if (tongueFlags[temp] == arg) return true;
				temp++;
			}
			return false;
		}
		public function addTongueFlag(arg): void {
			if (!hasTongueFlag(arg)) tongueFlags[tongueFlags.length] = arg;
		}
		public function displayTallness(): String {
			var buffer: String = "";
			buffer = Math.floor(tallness / 12) + "'";
			if (Math.round(tallness % 12) != 0) buffer += Math.round(tallness % 12) + "\"";
			return buffer;
		}
		public function lipRating(): Number {
			var rating: int = 0;
			//Hint of pout
			if (femininity > 65) rating = 1;
			//Shapely
			if (femininity > 72) rating = 2;
			//Full
			if (femininity > 80) rating = 3;
			//Full + Pouty
			if (femininity > 90) rating = 4;
			if (femininity > 100) rating = 5;

			return rating + lipMod;
		}
		public function lipsDescript(forcedAdjectives:Boolean = false): String {
			return lipDescript(forcedAdjectives);
		}
		public function lipDescript(forcedAdjectives:Boolean = false): String {
			//lipMod + some femininity divided by something to get result.
			var lips:int = lipMod + femininity / 25;
			var result:String = "";
			var adjectives:int = 0;
			//Size Adjectives
			if(rand(3) == 0 || forcedAdjectives)
			{
				if(lips <= 1)
				{
					if(rand(3) == 0) result += "pencil-thin";
					else if(rand(2) == 0) result += "lean";
					else result += "slender";
				}
				else if(lips <= 2)
				{
					if(rand(3) == 0) result += "nice";
					else if(rand(2) == 0) result += "petite";
					else result += "supple";
				}
				else if(lips <= 3)
				{
					if(rand(4) == 0) result += "full";
					else if(rand(3) == 0) result += "pouting";
					else if(rand(2) == 0) result += "shapely";
					else result += "plump";
				}
				else if(lips <= 4)
				{
					if(rand(3) == 0) result += "succulent";
					else if(rand(2) == 0) result += "juicy";
					else result += "luscious";
				}
				else if(lips <= 5)
				{
					if(rand(3) == 0) result += "voluptuous";
					else if(rand(2) == 0) result += "bee-stung";
					else result += "swollen";
				}
				else if(lips <= 6)
				{
					if(rand(4) == 0) result += "hypnotic";
					else if(rand(3) == 0) result += "dazzling";
					else if(rand(2) == 0) result += "fat";
					else result += "exquisitely large";
				}
				else if(lips <= 7)
				{
					if(rand(3) == 0) result += "hyper-engorged";
					else if(rand(2) == 0) result += "constantly pursed";
					else result += "bloated";
				}
				else if(lips <= 8)
				{
					if(rand(3) == 0) result += "'o' shaped";
					else if(rand(2) == 0) result += "whorish";
					else result += "permenantly puckered";
				}
				//Serious this is too big, bro
				else
				{
					if(rand(5) == 0) result += "jacquesian";
					else if(rand(4) == 0) result += "scylla-tier";
					else if(rand(2) == 0) result += "impossibly large";
					else result += "universe-distorting";
				}
				adjectives++;
			}
			//Color!
			if(rand(4) == 0 && lipColor != "peach")
			{
				if(adjectives > 0) result += ", ";
				result += lipColor;
				adjectives++;
			}
			//Nouns
			if(adjectives > 0) result += " ";
			var nouns:Array = new Array();
			//Build up the choices!
			nouns[nouns.length] = "lip";
			nouns[nouns.length] = "lip";
			nouns[nouns.length] = "lip";
			nouns[nouns.length] = "lip";
			//High libido sluttery
			if(libido() >= 50 && lips >= 2 && (hasVagina() || femininity >= 75)) nouns[nouns.length] = "dick-sucker";
			if(libido() >= 60 && lips >= 3 && (hasVagina() || femininity >= 75)) nouns[nouns.length] = "cock-sucker";
			if(libido() >= 65 && lips >= 4) nouns[nouns.length] = "dick-pillow";
			if(libido() >= 70 && lips >= 4) nouns[nouns.length] = "cock-pillow";
			if(libido() >= 80 && lips >= 5) nouns[nouns.length] = "fuck-pillow";
			if(libido() >= 90 && lips >= 5) nouns[nouns.length] = "oral fuck-cushion";
			if(libido() >= 90 && lips >= 6) nouns[nouns.length] = "pleasure-pillow";
			//Tack the selected choice onto result
			result += nouns[rand(nouns.length)];
			return result;
		}
		public function earDescript(): String {
			var adjectives:Array = new Array();
			var nouns:Array = ["ear"];
			var description:String = "";
			switch (earType)
			{
				case GLOBAL.TYPE_CANINE:
					adjectives[adjectives.length] = "pointed";
					adjectives[adjectives.length] = "ausar";
					adjectives[adjectives.length] = "furry";
					adjectives[adjectives.length] = "upraised";
					adjectives[adjectives.length] = "anubis-like";
					break;
				case GLOBAL.TYPE_EQUINE:
					adjectives[adjectives.length] = "equine";
					adjectives[adjectives.length] = "horse-like";
					adjectives[adjectives.length] = "furry";
					adjectives[adjectives.length] = "bestial";
					adjectives[adjectives.length] = "inhuman";
					break;
				case GLOBAL.TYPE_BOVINE:
					adjectives[adjectives.length] = "bovine";
					adjectives[adjectives.length] = "cow-like";
					adjectives[adjectives.length] = "floppy";
					adjectives[adjectives.length] = "softly furred";
					break;
				case GLOBAL.TYPE_RASKVEL:
					adjectives[adjectives.length] = "raskvel";
					adjectives[adjectives.length] = "obscenely long";
					adjectives[adjectives.length] = "oh-so sensitive";
					adjectives[adjectives.length] = "smooth-scaled";
					adjectives[adjectives.length] = "lengthy";
					break;
			}
			//Pick an adjective about 75% of the time
			if(rand(4) < 3 && adjectives.length > 0) description = adjectives[rand(adjectives.length)] + " ";
			//Pick a noun.
			description += nouns[rand(nouns.length)];
			return description;
		}
		public function earsDescript(): String {
			return pluralize(earDescript());
		}
		public function eyeDescript(): String {
			var adjectives:Array = new Array();
			var nouns:Array = ["eye"];
			var description:String = "";
			
			adjectives[adjectives.length] = eyeColor;

			//Show color 50% of the time
			if(rand(2) == 0 && adjectives.length > 0) description = adjectives[rand(adjectives.length)] + " ";
			//Pick a noun.
			description += nouns[rand(nouns.length)];
			return description;
		}
		public function eyesDescript(): String {
			return pluralize(eyeDescript());
		}
		public function tongueDescript(): String {
			return "tongue";
		}
		public function faceDesc(): String {
			var faceo: String = "";
			//0-10
			if (femininity < 10) {
				faceo = "a square chin";
				if(!hasBeard() && lipRating() > 2) faceo += ", " + pluralize(lipDescript(true)) + ", and chiseled jawline.";
				else if (!hasBeard()) faceo += " and chiseled jawline";
				else faceo += ", chiseled jawline, and " + beard();
			}
			//10+ -20
			else if (femininity < 20) {
				faceo = "a rugged looking " + face() + " ";
				if (hasBeard()) faceo += "and " + beard() + " that are";
				else if(lipRating() > 2) faceo += "and " + pluralize(lipDescript(true)) + " that are";
				else faceo += "that's surely handsome";
			}
			//21-28
			else if (femininity < 28) faceo = "a well-defined jawline, a pair of " + pluralize(lipDescript(true)) + ", and a fairly masculine profile";
			//28+-35 
			else if (femininity < 35) faceo = "a somewhat masculine, angular jawline and " + pluralize(lipDescript(true)) + "";
			//35-45
			else if (femininity < 45) faceo = "a pair of " + pluralize(lipDescript(true)) + " and the barest hint of masculinity in its structure";
			//45-55
			else if (femininity <= 55) faceo = "an androgynous set of features that would work on either a male or a female and " + pluralize(lipDescript(true)) + "";
			//55+-65
			else if (femininity <= 65) faceo = "a tiny touch of femininity to it, with gentle curves and " + pluralize(lipDescript(true)) + "";
			//65+-72
			else if (femininity <= 72) faceo = "a nice set of cheekbones and " + pluralize(lipDescript(true)) + "";
			//72+-80
			else if (femininity <= 80) faceo = "a beautiful, feminine shapeliness that's sure to draw attention and " + pluralize(lipDescript(true)) + "";
			//81-90
			else if (femininity <= 90) faceo = "a gorgeous profile with " + pluralize(lipDescript(true)) + ", a button nose, and noticeable eyelashes";
			//91-100
			else faceo = "a jaw-droppingly feminine shape with " + pluralize(lipDescript(true)) + ", an adorable nose, and long, beautiful eyelashes";
			return faceo;
		}
		//Modify femininity!
		public function modFem(change: Number, strength: Number = 1): String {
			var output: String = "";
			var old: String = faceDesc();
			//If already perfect!
			if (change == 0) return "";
			//Abord if at an end of the scale
			if (femininity <= femininityMin() && change < 0) return "";
			if (femininity >= femininityMax() && change > 0) return "";
			//Make the change!
			femininity += change;
			//Stay in bounds.
			if (femininity < femininityMin()) {
				change = (femininity - change) - femininityMin();
				femininity = femininityMin();
			}
			if (femininity > femininityMax()) {
				change = femininityMax() - (femininity - change);
				femininity = femininityMax();
			}
			//Large change
			if (Math.abs(change) > 5) {
				if (change > 0) output = "\n\n<b>Your facial features soften as your body becomes more feminine. (+" + Math.round(change * 10) / 10 + ")</b>";
				else output = "\n\n<b>Your facial features harden as your body becomes more masculine. (" + Math.round(change * 10) / 10 + ")</b>";
			}
			//Barely noticable change!
			else {
				if (change > 0) output = "\n\nThere's a tingling in your " + old + " as it changes imperceptibly towards being more feminine. (+" + Math.round(change * 10) / 10 + ")";
				else if (change < 0) output = "\n\nThere's a tingling in your " + old + " as it changes imperciptibly towards being more masculine. (" + Math.round(change * 10) / 10 + ")";
			}
			return output;
		}
		public function femininityMax(): Number {
			//Herms + genderless
			if ((!hasVagina() && !hasCock()) || (hasCock() && hasVagina)) return 85;
			else if (hasCock() && !hasVagina()) return 70;
			else return 100;
		}
		public function femininityMin(): Number {
			//Herms + genderless
			if ((!hasVagina() && !hasCock()) || (hasCock() && hasVagina)) return 20;
			else if (!hasCock() && hasVagina()) return 30;
			else return 000;
		}
		//Run this every hour to 'fix' femininity.
		public function fixFemininity(): String {
			var output: String = "";
			//BELOW MINIMUM! GET MORE GIRLY!
			if (femininity < femininityMin()) {
				output += "\n\n<b>Your incredibly masculine, chiseled features become a little bit softer from your body's changing hormones.";
				if (hasBeard()) {
					output += "  As if that wasn't bad enough, your " + beard() + " falls out too!";
					beardLength = 0;
					beardStyle = 0;
				}
				output += "</b>";
				femininity = femininityMin();
			}
			//ABOVE MAX! GET LESS GIRLY!
			else if (femininity > femininityMax()) {
				output += "\n\n<b>You find your overly feminine face loses a little bit of its former female beauty due to your body's changing hormones.</b>";
				femininity = femininityMax();
			}
			//LOSE DICK OR HAVE VAGINA? NO BEARD 4 U!
			if ((!hasCock() || hasVagina()) && hasBeard()) {
				output += "\n\n<b>Your beard falls out, leaving you with " + faceDesc() + ".</b>";
				beardLength = 0;
				beardStyle = 0;
			}
			return output;
		}
		public function hasBeard(): Boolean {
			if (beardLength > 0) return true;
			else return false;
		}
		public function beard(): String {
			if (hasBeard()) return "beard";
			else return "ERROR: NO BEARD! <b>YOU ARE NOT A VIKING AND SHOULD TELL FEN IMMEDIATELY.</b>";
		}
		public function modThickness(change: Number) {
			var oldN: Number = thickness;
			//Lose weight fatty!
			//Check bounds.
			if (change > 0 && change + thickness > 100) change = 100 - thickness;
			if (change < 0 && thickness - change < 0) change = thickness;
			//Cancel out if nowhere to go.
			if (change == 0) return "";
			thickness += change;
			//Display 'U GOT FAT'
			if (change > 0) return "\n\nYour center of balance changes a little bit as your body noticeably widens. (+" + Math.round(change * 10) / 10 + " body thickness)";
			//GET THIN BITCH
			else return "\n\nEach movement feels a tiny bit easier than the last.  Did you just lose a little weight!? (" + Math.round(change * 10) / 10 + " body thickness)";
			return "";
		}
		public function modTone(change: Number) {
			var oldN: Number = tone;
			//Check bounds
			if (change > 0 && change + tone > 100) change = 100 - tone;
			if (change < 0 && tone - change < 0) change = tone;
			if (change == tone) return "";
			tone += change;
			//DIsplay BITCH I WORK OUT
			if (change > 0) return "\n\nYour body feels a little more solid as you move, and your muscles look slightly more visible. (+" + Math.round(change * 10) / 10 + " muscle tone)";
			//Display DERP I HAVE GIRL MUSCLES
			else return "\n\nMoving brings with it a little more jiggle than you're used to.  You don't seem to have gained weight, but your muscles look less visible. (" + Math.round(change * 10) / 10 + " muscle tone)";
			return "";
		}
		public function skinFurScales(forceTone: Boolean = false, forceAdjective: Boolean = false, skin: Boolean = false): String {
			var output: String = "";
			var temp;
			//33% of the time, add an adjective.
			if (forceAdjective || this.rand(3) == 0) {
				if (hasSkinFlag(GLOBAL.FLAG_SMOOTH)) output += "smooth";
				else if (hasSkinFlag(GLOBAL.FLAG_THICK)) output += "thick";
				else if (hasSkinFlag(GLOBAL.FLAG_STICKY)) output += "sticky";
				else if (hasSkinFlag(GLOBAL.FLAG_FLUFFY) && !skin && skinType == GLOBAL.SKIN_TYPE_FUR) output += "fluffy";
			}
			//25% of time, describe skin tone.
			if (forceTone || this.rand(4) == 0) {
				if (output != "") output += ", ";
				if (skinType == GLOBAL.SKIN_TYPE_FUR && !skin) output += furColor;
				else if (skinType == GLOBAL.SKIN_TYPE_SCALES && !skin) output += scaleColor;
				else output += skinTone;
			}
			//Setup for words
			if (output != "") output += " ";
			//Set skin words.
			output += skinNoun(skin);
			return output;
		}
		public function skinNoun(skin: Boolean = false): String {
			var output: String = "";
			var temp: int = 0;
			//Set skin words.
			if (skinType == GLOBAL.SKIN_TYPE_SKIN || skin) {
				temp = this.rand(10);
				//if (temp <= 8) 
				output += "skin";
				//else output += "dermis";
			} else if (skinType == GLOBAL.SKIN_TYPE_FUR) {
				temp = this.rand(10);
				if (temp <= 7) output += "fur";
				else if (temp <= 8) output += "pelt";
				else output += "coat";
			} else if (skinType == GLOBAL.SKIN_TYPE_SCALES) {
				temp = this.rand(10);
				if (temp <= 7) output += "scales";
				else if (temp <= 8) output += "plates";
				else output += "lamina";
			} else if (skinType == GLOBAL.SKIN_TYPE_GOO) {
				if (temp <= 7) output += "goo";
				else output += "membrane";
			}
			return output;
		}
		public function skin(forceTone: Boolean = false, forceAdjective: Boolean = false): String {
			return skinFurScales(forceTone, forceAdjective, true);
		}
		public function face(forceAdjectives: Boolean = false): String {
			var output: String = "";
			//1 in 4 chance unless forcing adjectives
			if (this.rand(4) == 0 || forceAdjectives) {
				if (faceType == GLOBAL.TYPE_FELINE) output += "feline";
				if (faceType == GLOBAL.TYPE_EQUINE) output += "long";
				if (faceType == GLOBAL.TYPE_BOVINE) output += "bovine";
				if (hasFaceFlag(GLOBAL.FLAG_ANGULAR)) output += "angular";
				if (faceType == GLOBAL.TYPE_LIZAN || faceType == GLOBAL.TYPE_DRACONIC) output += "reptilian";
			}
			//Space if adjective'd
			if (output != "") output += " ";

			//Add Noun
			if (hasFaceFlag(GLOBAL.FLAG_MUZZLED) && this.rand(2) == 0) output += "muzzle";
			else if (this.rand(2) == 0 && hasFaceFlag(GLOBAL.FLAG_MUZZLED) && (faceType == GLOBAL.TYPE_LIZAN || faceType == GLOBAL.TYPE_DRACONIC))
				output += "snout";
			else output += "face";

			return output;
		}
		public function isBiped(): Boolean {
			//Naga/Centaur
			if (legCount != 2) return false;
			return true;
		}
		public function isNaga(): Boolean {
			if (legCount == 1 && legType == GLOBAL.TYPE_NAGA) return true;
			return false;
		}
		public function isTaur(): Boolean {
			if (legCount == 4) return true;
			return false;
		}
		public function isDrider(): Boolean {
			return (legCount >= 4 && (legType == GLOBAL.TYPE_DRIDER || legType == GLOBAL.TYPE_ARACHNID));
		}
		public function isGoo(): Boolean {
			if (legType == GLOBAL.TYPE_GOOEY) return true;
			return false;
		}
		public function isImmobilized(): Boolean {
			return (hasStatusEffect("Stunned") || hasStatusEffect("Paralyzed") || hasStatusEffect("Naleen Coiled"));
		}
		public function legs(forceType: Boolean = false, forceAdjective: Boolean = false): String {
			var select: Number = 0;
			//EDGE CASSES
			if (legType == GLOBAL.TYPE_SNAKE) return "coils";
			else if (legType == GLOBAL.TYPE_GOOEY && hasLegFlag(GLOBAL.FLAG_AMORPHOUS)) {
				select = this.rand(5);
				return "mounds of goo";
			}
			return leg(forceType, forceAdjective) + "s";
		}
		public function legOrLegs(forceType: Boolean = false, forceAdjective: Boolean = false): String {
			if (legCount == 1) return leg(forceType, forceAdjective);
			else return legs(forceType, forceAdjective);
		}
		public function tailDescript(): String {
			var adjectives:Array = new Array();
			var nouns:Array = ["tail"];
			var description:String = "";
			if(hasTailFlag(GLOBAL.FLAG_PREHENSILE)) 
			{
				adjectives[adjectives.length] = "talented";
				adjectives[adjectives.length] = "nimble";
			}
			if(hasTailFlag(GLOBAL.FLAG_LONG)) 
			{
				adjectives[adjectives.length] = "lengthy";
				adjectives[adjectives.length] = "long";
			}
			if(hasTailFlag(GLOBAL.FLAG_FLUFFY)) 
			{
				adjectives[adjectives.length] = "furry";
				adjectives[adjectives.length] = "furred";
				adjectives[adjectives.length] = "fluffy";
				adjectives[adjectives.length] = "soft";
			}
			if(hasTailFlag(GLOBAL.FLAG_SMOOTH)) 
			{
				adjectives[adjectives.length] = "smooth";
				adjectives[adjectives.length] = "sleek";
			}
			if(tailType == GLOBAL.TYPE_LAPINE)
			{
				adjectives[adjectives.length] = "twitching";
				adjectives[adjectives.length] = "rabbit-like";
				adjectives[adjectives.length] = "lapine";
			}
			else if(tailType == GLOBAL.TYPE_EQUINE)
			{
				adjectives[adjectives.length] = "equine";
				adjectives[adjectives.length] = "horse-like";
			}
			else if(tailType == GLOBAL.TYPE_CANINE)
			{
				adjectives[adjectives.length] = "ausar";
				adjectives[adjectives.length] = "dog-like";
			}
			else if(tailType == GLOBAL.TYPE_BOVINE)
			{
				adjectives[adjectives.length] = "bovine";
				adjectives[adjectives.length] = "cow-like";
			}		
			//Show color 50% of the time
			if(rand(2) == 0 && adjectives.length > 0) description = adjectives[rand(adjectives.length)] + " ";
			//Pick a noun.
			description += nouns[rand(nouns.length)];
			return description;
		}
		public function tailsDescript():String {
			if(tailCount == 1) return tailDescript();
			else if(tailCount > 1) return pluralize(tailDescript());
			else return "<b>ERROR: Taildescript called with no tails present</b>";
		}
		public function leg(forceType: Boolean = false, forceAdjective: Boolean = false): String {
			var select: Number = 0;
			var output: String = "";
			var typed: Boolean = false;
			var adjectived: Boolean = false;
			//SPECIAL CASES.
			if (legType == GLOBAL.TYPE_SNAKE) {
				select = this.rand(10);
				if (select <= 3) return "snake tail";
				else if (select <= 5) return "flexible tail";
				else if (select <= 7) return "coiled bottom half";
				else if (select <= 8) return "tail";
				else return "prehensile tail";
			}
			//8 - goo shit
			else if (legType == GLOBAL.TYPE_GOOEY && hasLegFlag(GLOBAL.FLAG_AMORPHOUS)) {
				if (select == 0) return "mound of goo";
				else if (select == 1) return "gelatinous mound";
				else if (select == 2) return "gooey base";
				else if (select == 3) return "semi-solid mass";
			}
			//NORMAL CASES.
			else
			{
				//Type 1/4 of the time.
				if (this.rand(4) == 0 || forceType) {
					select = this.rand(10);
					if (legType == GLOBAL.TYPE_EQUINE || legType == GLOBAL.TYPE_CENTAUR) {
						if (select <= 3) output += "equine";
						else if (select <= 6) output += "horse-like";
						else output += "hoof-capped";
					} else if (legType == GLOBAL.TYPE_BOVINE) {
						if (select <= 3) output += "bovine";
						else if (select <= 6) output += "cow-like";
						else output += "hoof-capped";
					} else if (legType == GLOBAL.TYPE_CANINE) {
						if (select <= 3) output += "canine";
						else if (select <= 6) output += "dog-like";
						else output += "paw-footed";
					} else if (legType == GLOBAL.TYPE_FELINE) {
						if (select <= 3) output += "feline";
						else if (select <= 6) output += "cat-like";
						else output += "graceful";
					} else if (legType == GLOBAL.TYPE_VULPINE) {
						if (select <= 3) output += "vulpine";
						else if (select <= 6) output += "fox-like";
						else output += "foxy";
					} else if (legType == GLOBAL.TYPE_BEE) {
						if (select <= 3) output += "chitinous";
						else if (select <= 5) output += "armored";
						else if (select <= 7) output += "insect-like";
						else output += "carapace-covered";
					} else if (legType == GLOBAL.TYPE_ARACHNID) {
						if (select <= 3) output += "chitinous";
						else if (select <= 5) output += "armored";
						else if (select <= 7) output += "insect-like";
						else output += "carapace-covered";
					} else if (legType == GLOBAL.TYPE_DRIDER) {
						if (select <= 1) output += "chitinous";
						else if (select <= 3) output += "armored";
						else if (select <= 5) output += "insect-like";
						else if (select <= 7) output += "carapace-covered";
						else output += "pointed";
					} else if (legType == GLOBAL.TYPE_LAPINE) {
						if (select <= 3) output += "lapine";
						else if (select <= 6) output += "rabbit-like";
						else output += "bunny";
					} else if (legType == GLOBAL.TYPE_LAPINE) {
						if (select <= 3) output += "lapine";
						else if (select <= 6) output += "rabbit-like";
						else output += "bunny";
					} else if (legType == GLOBAL.TYPE_AVIAN) {
						if (select <= 3) output += "avian";
						else if (select <= 6) output += "bird-like";
						else output += "harpy";
					} else if (legType == GLOBAL.TYPE_DRACONIC) {
						if (select <= 3) output += "draconic";
						else if (select <= 6) output += "dragon-like";
						else output += "reptilian";
					} else if (legType == GLOBAL.TYPE_LIZAN) {
						if (select <= 3) output += "lizan";
						else if (select <= 6) output += "reptile-like";
						else output += "reptilian";
					} else if (legType == GLOBAL.TYPE_DEMONIC) {
						if (select <= 3) output += "demon-like";
						else if (select <= 6) output += "demonic";
						else output += "claw-footed";
					} else if (legType == GLOBAL.TYPE_GOOEY) {
						if (select <= 2) output += "gooey";
						else if (select <= 5) output += "semi-solid";
						else if (select <= 7) output += "gelatinous";
						else output += "jiggly";
					} else if (legType == GLOBAL.TYPE_KANGAROO) {
						if (select <= 3) output += "kangaroo-like";
						else if (select <= 5) output += "powerful";
						else output += "'roo";
					} else if (legType == GLOBAL.TYPE_TANUKI) {
						if (select <= 3) output += "tanuki-like";
						else if (select <= 6) output += "dexterous";
						else output += "nimble";
					} else if (legType == GLOBAL.TYPE_DEER) {
						if (select <= 3) output += "deer-like";
						else if (select <= 6) output += "hooved";
						else output += "nimble";
					}
				}
				//ADJECTIVE!
				else if (this.rand(3) == 0 || forceAdjective) {
					if (legCount > 2 && this.rand(2) == 0) {
						output += "numerous";
					} else if (hasLegFlag(GLOBAL.FLAG_DIGITIGRADE)) {
						output += "digitigrade";
					} else if (hasLegFlag(GLOBAL.FLAG_DIGITIGRADE)) {
						output += "plantigrade";
					} else if (hasLegFlag(GLOBAL.FLAG_SCALED)) {
						output += "scaled";
					} else if (hasLegFlag(GLOBAL.FLAG_FURRED)) {
						select = this.rand(10);
						if (select <= 3) output += "furry";
						else if (select <= 6) output += "fuzzy";
						else output += "fur-covered";
					} else if (hasLegFlag(GLOBAL.FLAG_TENDRIL)) {
						output += "wiggling";
					}
				}
				//NOUN IT UP BITCHES!
				if (output != "") output += " ";
				output += "leg";
			}
			return output;
		}
		public function footAdjectives(forceType: Boolean = false, forceAdjective: Boolean = false) {
			var output: String = "";
			var select: int;
			//Type! 1/5 times
			if (this.rand(5) == 0) {
				select = this.rand(10);
				if (legType == GLOBAL.TYPE_EQUINE || legType == GLOBAL.TYPE_CENTAUR) {
					if (select <= 4) output += "equine";
					else output += "horse-like";
				} else if (legType == GLOBAL.TYPE_BOVINE) {
					if (select <= 4) output += "bovine";
					else output += "cow-like";
				} else if (legType == GLOBAL.TYPE_CANINE) {
					if (select <= 4) output += "canine";
					else output += "dog-like";
				} else if (legType == GLOBAL.TYPE_FELINE) {
					if (select <= 4) output += "feline";
					else output += "cat-like";
				} else if (legType == GLOBAL.TYPE_VULPINE) {
					if (select <= 4) output += "vulpine";
					else if (select <= 6) output += "fox-like";
					else output += "foxy";
				} else if (legType == GLOBAL.TYPE_BEE) {
					if (select <= 3) output += "chitinous";
					else if (select <= 5) output += "armored";
					else if (select <= 7) output += "insect-like";
					else output += "carapace-covered";
				} else if (legType == GLOBAL.TYPE_ARACHNID) {
					if (select <= 3) output += "chitinous";
					else if (select <= 5) output += "armored";
					else if (select <= 7) output += "insect-like";
					else output += "carapace-covered";
				} else if (legType == GLOBAL.TYPE_DRIDER) {
					if (select <= 1) output += "chitinous";
					else if (select <= 3) output += "armored";
					else if (select <= 5) output += "insect-like";
					else if (select <= 7) output += "carapace-covered";
					else output += "pointed";
				} else if (legType == GLOBAL.TYPE_LAPINE) {
					if (select <= 3) output += "lapine";
					else if (select <= 6) output += "rabbit-like";
					else output += "bunny";
				} else if (legType == GLOBAL.TYPE_LAPINE) {
					if (select <= 3) output += "lapine";
					else if (select <= 6) output += "rabbit-like";
					else output += "bunny";
				} else if (legType == GLOBAL.TYPE_AVIAN) {
					if (select <= 3) output += "avian";
					else if (select <= 6) output += "bird-like";
					else output += "taloned";
				} else if (legType == GLOBAL.TYPE_DRACONIC) {
					if (select <= 3) output += "draconic";
					else if (select <= 6) output += "clawed";
					else output += "reptilian";
				} else if (legType == GLOBAL.TYPE_LIZAN) {
					if (select <= 3) output += "lizan";
					else if (select <= 6) output += "clawed";
					else output += "reptilian";
				} else if (legType == GLOBAL.TYPE_DEMONIC) {
					if (select <= 3) output += "corrupted-looking";
					else if (select <= 6) output += "demonic";
					else output += "clawed";
				} else if (legType == GLOBAL.TYPE_GOOEY) {
					if (select <= 2) output += "gooey";
					else if (select <= 5) output += "semi-solid";
					else if (select <= 7) output += "gelatinous";
					else output += "jiggly";
				} else if (legType == GLOBAL.TYPE_KANGAROO) {
					if (select <= 3) output += "kangaroo-like";
					else if (select <= 5) output += "powerful";
					else output += "'roo";
				} else if (legType == GLOBAL.TYPE_TANUKI) {
					if (select <= 3) output += "tanuki-like";
					else if (select <= 6) output += "dexterous";
					else output += "nimble";
				} else if (legType == GLOBAL.TYPE_DEER) {
					if (select <= 4) output += "deer-like";
					else output += "nimble";
				}
			}
			//ADJECTIVE!
			if (this.rand(3) == 0 || forceAdjective) {
				if (hasLegFlag(GLOBAL.FLAG_SCALED)) {
					output += "scaled";
				} else if (hasLegFlag(GLOBAL.FLAG_FURRED)) {
					select = this.rand(10);
					if (select <= 3) output += "furry";
					else if (select <= 6) output += "fuzzy";
					else output += "fur-covered";
				} else if (hasLegFlag(GLOBAL.FLAG_TENDRIL)) {
					output += "wiggling";
				}
			}
			return output;
		}
		public function height():String
		{
			var buffer:String = "";
			buffer += Math.floor(tallness / 12) + " feet";
			if(tallness % 12 != 0) buffer += " and " + tallness % 12 + " inches";
			return buffer;
		}
		public function feet(forceType: Boolean = false, forceAdjective: Boolean = false): String {
			var select: Number = 0;
			var output: String = "";
			output = footAdjectives(forceType, forceAdjective);
			//Noun
			if (output != "") output += " ";
			if (hasLegFlag(GLOBAL.FLAG_HOOVES)) output += "hooves";
			else if (hasLegFlag(GLOBAL.FLAG_PAWS) && this.rand(2) == 0) output += "paws";
			else if (hasLegFlag(GLOBAL.FLAG_AMORPHOUS) && legType == GLOBAL.TYPE_GOOEY) output += "cilia";
			else if (hasLegFlag(GLOBAL.FLAG_HEELS) && this.rand(2) == 0) output += "high-heels";
			else output += "feet";
			return output;
		}
		public function foot(forceType: Boolean = false, forceAdjective: Boolean = false): String {
			var select: Number = 0;
			var output: String = "";
			output = footAdjectives(forceType, forceAdjective);
			//Noun
			if (output != "") output += " ";
			if (hasLegFlag(GLOBAL.FLAG_HOOVES)) output += "hoof";
			else if (hasLegFlag(GLOBAL.FLAG_PAWS) && this.rand(2) == 0) output += "paw";
			else if (hasLegFlag(GLOBAL.FLAG_AMORPHOUS) && legType == GLOBAL.TYPE_GOOEY) output += "undercarriage";
			else if (hasLegFlag(GLOBAL.FLAG_HEELS) && this.rand(2) == 0) output += "high-heel";
			else output += "foot";
			return output;
		}
		
		public function toes(): String {
			var select: Number = 0;
			var output: String = "";
			//Noun
			if (hasLegFlag(GLOBAL.FLAG_HOOVES)) output += "hoof-tips";
			else if (hasLegFlag(GLOBAL.FLAG_PAWS) && this.rand(2) == 0) output += "fuzzy toes";
			else if (hasLegFlag(GLOBAL.FLAG_AMORPHOUS) && legType == GLOBAL.TYPE_GOOEY) output += "cilia";
			else if (hasLegFlag(GLOBAL.FLAG_HEELS) && this.rand(2) == 0) output += "toes";
			else output += "toes";
			return output;
		}
		public function hasKnees():Boolean
		{
			return (hasLegFlag(GLOBAL.FLAG_DIGITIGRADE) || hasLegFlag(GLOBAL.FLAG_PLANTIGRADE));
		}
		public function kneesDescript(): String {
			var select: Number = 0;
			var output: String = "";
			//Noun
			if (hasLegFlag(GLOBAL.FLAG_AMORPHOUS) && legType == GLOBAL.TYPE_GOOEY) output += "cilia";
			else output += "knees";
			return output;
		}
		// Placeholder shit, sue me. Calling the ill excuse etc.
		public function bellyDescript(): String {
			var sBuilder:String = "";

			var belly:Number = bellyRating();
			//Wide fat PCs got da belly
			var toneMod:Number = thickness - tone;
			//Prevent negatives for the uberfit:
			if(toneMod < 0) toneMod = 0;
			//Worst = 100. Scale down by factor of 5
			toneMod /= 5;
			//Add to our working belly amount for funtimes:
			belly += toneMod;

			var sizeDescripts:Array = new Array();
			var pregDescripts:Array = new Array();

			//engorged, swollen, stuffed
			//cumflated only: cum-bloated (could even be wildcarded for honeycum or other things, depending on your tracking), cum-inflated, sloshing,
			if (belly <= 5)
			{
				if(tone >= 50) 
				{
					sizeDescripts[sizeDescripts.length] = "toned";
					sizeDescripts[sizeDescripts.length] = "sculpted";
				}
				sizeDescripts[sizeDescripts.length] = "flat";
				sizeDescripts[sizeDescripts.length] = "slim";
			}
			else if (belly <= 10)
			{
				sizeDescripts[sizeDescripts.length] = "soft";
				sizeDescripts[sizeDescripts.length] = "cushy";
			}
			else if (belly <= 15)
			{
				sizeDescripts[sizeDescripts.length] = "paunched";
				sizeDescripts[sizeDescripts.length] = "pudgy";
			}
			else if (belly <= 20)
			{
				sizeDescripts[sizeDescripts.length] = "large";
				sizeDescripts[sizeDescripts.length] = "hefty";
			}
			else if (belly <= 30)
			{
				sizeDescripts[sizeDescripts.length] = "considerable";
				sizeDescripts[sizeDescripts.length] = "generous";
				sizeDescripts[sizeDescripts.length] = "pregnant-looking";
			}
			else if (belly <= 40)
			{
				sizeDescripts[sizeDescripts.length] = "full";
				sizeDescripts[sizeDescripts.length] = "round";
				sizeDescripts[sizeDescripts.length] = "bulky";
				
			}
			else if (belly <= 50)
			{
				sizeDescripts[sizeDescripts.length] = "spacious";
				sizeDescripts[sizeDescripts.length] = "extensive";
				sizeDescripts[sizeDescripts.length] = "expansive";
			}
			else if (belly <= 60)
			{
				sizeDescripts[sizeDescripts.length] = "inflated";
				sizeDescripts[sizeDescripts.length] = "excessive";
				sizeDescripts[sizeDescripts.length] = "whopping";
				
			}
			else if (belly <= 70)
			{
				sizeDescripts[sizeDescripts.length] = "distended";
				sizeDescripts[sizeDescripts.length] = "immense";
				sizeDescripts[sizeDescripts.length] = "bloated";
			}
			else if (belly <= 80)
			{
				sizeDescripts[sizeDescripts.length] = "over-inflated";
				sizeDescripts[sizeDescripts.length] = "jumbo-sized";
			}
			else if (belly <= 90)
			{
				sizeDescripts[sizeDescripts.length] = "very distended";
				sizeDescripts[sizeDescripts.length] = "monumental";
				sizeDescripts[sizeDescripts.length] = "massive";
			}
			else
			{
				sizeDescripts[sizeDescripts.length] = "ginormous";
				sizeDescripts[sizeDescripts.length] = "over-inflated";
				sizeDescripts[sizeDescripts.length] = "blimp-like";
			}
			//Size: 50%
			if(rand(2) == 0)
			{
				sBuilder += sizeDescripts[rand(sizeDescripts.length)];
			}
			//Pregnant Stuff - 25% chance (note there's a 25% chance of occurring with belly size for 50% total)
			
			//Noun selection:
			if(belly < 10) sBuilder += "midriff";
			else if(belly < 20 && rand(2) == 0) sBuilder += "middle";
			else sBuilder += "belly";
			
			return sBuilder;
		}
		public function alphabetize(array, newKeyItem): void {
			//used to denote that the array has already had its new spot pushed on.
			var arrayed: Boolean = false;
			//used to store where the array goes
			var keyName: String = newKeyItem.storageName.toLowerCase();
			var keySlot: Number = 0
			var counter: Number = 0
			//Start the array if its the first bit
			if (array.length == 0) {
				array.push(newKeyItem);
				arrayed = true;
				keySlot = 0;
			}
			//If it belongs at the end, push it on
			if (array[array.length - 1].storageName.toLowerCase() < keyName && !arrayed) {
				array.push(newKeyItem);
				arrayed = true;
				keySlot = array.length - 1;
			}
			//If it belongs in the beginning, splice it in
			if (array[0].storageName.toLowerCase() > keyName && !arrayed) {
				array.splice(0, 0, newKeyItem);
				arrayed = true;
				keySlot = 0;
			}
			//Find the spot it needs to go in and splice it in.
			if (!arrayed) {
				counter = array.length;
				while (counter > 0 && !arrayed) {
					counter--;
					//If the current slot is later than new key
					if (array[counter].storageName.toLowerCase() > keyName) {
						//If the earlier slot is earlier than new key && a real spot
						if (counter - 1 >= 0) {
							//If the earlier slot is earlier slot in!
							if (array[counter - 1].storageName.toLowerCase() <= keyName) {
								arrayed = true;
								array.splice(counter, 0, newKeyItem);
								keySlot = counter;
							}
						}
						//If the item after 0 slot is later put here!
						else {
							//If the next slot is later we are go
							if (array[counter].storageName.toLowerCase() <= keyName) {
								arrayed = true;
								array.splice(counter, 0, newKeyItem);
								keySlot = counter;
							}
						}
					}
				}
			}
			//Fallback
			if (!arrayed) {
				array.push(newKeyItem);
				arrayed = true;
				keySlot = array.length - 1;
			}
			trace("Storage logged in slot " + keySlot + ": " + array[keySlot].storageName + " for " + short);
		}
		//Create a perk
		public function createPerk(keyName: String, value1: Number, value2: Number, value3: Number, value4: Number, desc: String = ""): void {
			var newKeyItem = new StorageClass();
			newKeyItem.storageName = keyName;
			newKeyItem.value1 = value1;
			newKeyItem.value2 = value2;
			newKeyItem.value3 = value3;
			newKeyItem.value4 = value4;
			newKeyItem.tooltip = desc;
			alphabetize(perks, newKeyItem);
		}
		//Create a status
		public function createStatusEffect(statusName: String, value1: Number = 0, value2: Number = 0, value3: Number = 0, value4: Number = 0, hidden: Boolean = true, iconName: String = "", tooltip: String = "", combatOnly: Boolean = false, minutesLeft: Number = 0): void {
			
			if (this.hasStatusEffect(statusName)) {
				trace("Status '" + statusName + "' already present on " + this.short);
				return;
			}

			var newStatusEffect = new StorageClass();
			newStatusEffect.storageName = statusName;
			newStatusEffect.value1 = value1;
			newStatusEffect.value2 = value2;
			newStatusEffect.value3 = value3;
			newStatusEffect.value4 = value4;
			newStatusEffect.hidden = hidden;
			newStatusEffect.iconName = iconName;
			newStatusEffect.tooltip = tooltip;
			newStatusEffect.combatOnly = combatOnly;
			newStatusEffect.minutesLeft = minutesLeft;
			alphabetize(statusEffects, newStatusEffect);

			trace("New status applied to " + short + ": " + statusName);
		}
		//Create a keyItem
		public function createKeyItem(keyName: String, value1: Number, value2: Number, value3: Number, value4: Number, description: String = ""): void {
			var newKeyItem = new StorageClass();
			newKeyItem.storageName = keyName;
			newKeyItem.value1 = value1;
			newKeyItem.value2 = value2;
			newKeyItem.value3 = value3;
			newKeyItem.value4 = value4;
			newKeyItem.tooltip = description;
			alphabetize(keyItems, newKeyItem);
			trace("New key item applied to " + short + ": " + keyName);
		}
		//REMOVING THINGS!
		//status
		public function removeStatusEffect(statusName: String): void {
			removeStorageSlot(statusEffects, statusName)
		}
		//statuses
		public function removeStatuses(): void {
			removeStorage(statusEffects);
		}
		public function clearCombatStatuses(): void {
			
			//trace("Removing combat statuses.");
			if (hasStatusEffect("Sensor Link"))
			{
				removeStatusEffect("Sensor Link");
				aimMod -= 5;
			}
			
			for (var x: int = statusEffects.length-1; x >= 0; x--) {
				if (statusEffects[x].combatOnly)
				{
					//trace("Removed: " + statusEffects[x].storageName + " at position " + x + ".");
					statusEffects.splice(x,1);
				}
				//else trace("Not a combat status: " + statusEffects[x].storageName + " at position " + x + ".");
			}
		}
		//perk
		public function removePerk(perkName: String): void {
			removeStorageSlot(perks, perkName);
		}
		//perks
		public function removePerks(): void {
			removeStorage(perks);
		}
		//key item
		public function removeKeyItem(itemName: String): void {
			removeStorageSlot(keyItems, itemName);
		}
		//key items
		public function removeKeyItems(): void {
			removeStorage(keyItems);
		}
		//remove all of a stored array
		public function removeStorage(array): void {
			var counter: Number = array.length;
			while (counter > 0) {
				counter--;
				array.splice(counter, 1);
			}
		}
		//General function used by all
		public function removeStorageSlot(array, storageName): void {
			trace("Removing storage slot...");
			var counter: Number = array.length;
			//Various Errors preventing action
			if (array.length <= 0) {
				trace("Attempted to remove storage slot " + storageName + " on " + short + " but chosen array has no members.");
				return;
			}
			while (counter > 0) {
				counter--;
				if (array[counter].storageName == storageName) {
					array.splice(counter, 1);
					trace("Removed \"" + storageName + "\" from a storage array on " + short + ".");
					counter = 0;
				}
			}
		}
		//CHECKING IF HAS A SPECIFIC STORAGE ITEM
		//Status
		public function hasStatusEffect(statusName: String): Boolean {
			return hasStorageName(statusEffects, statusName);
		}
		public function hasStatusEffectCount(statusName:String):Number
		{
			var counter: Number = statusEffects.length;
			var amount:int = 0;
			if (statusEffects.length <= 0) return 0;
			while (counter > 0) {
				counter--;
				if (statusEffects[counter].storageName == statusName) amount++;
			}
			return amount;
		}
		//Perk
		public function hasPerk(perkName: String): Boolean {
			return hasStorageName(perks, perkName);
		}
		public function hasKeyItem(keyName: String): Boolean {
			return hasStorageName(keyItems, keyName);
		}
		//General function.
		public function hasStorageName(array, storageName: String): Boolean {
			var counter: Number = array.length;
			if (array.length <= 0) return false;
			while (counter > 0) {
				counter--;
				if (array[counter].storageName == storageName) return true;
			}
			return false;
		}

		//MODIFYING STORAGE VARIABLES WITH SET OR ADD.
		public function setStatusValue(storageName: String, storageValueNum: int, newValue) {
			setStorageValue(statusEffects, storageName, storageValueNum, newValue);
		}
		public function getStatusMinutes(storageName: String)
		{
			var counter: Number = statusEffects.length;
			//Various Errors preventing action
			if (statusEffects.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, report it.
				if (statusEffects[counter].storageName == storageName) {
					return statusEffects[counter].minutesLeft;
				}
			}
			return -1;
		}
		public function hasCombatStatusEffect(storageName: String):Boolean {
			var array:Array = statusEffects;
			var counter: Number = array.length;
			if (array.length <= 0) return false;
			while (counter > 0) {
				counter--;
				if (array[counter].storageName == storageName && array[counter].combatOnly) return true;
			}
			return false;
		}
		public function setStatusMinutes(storageName: String, newMinutes:int)
		{
			var counter: Number = statusEffects.length;
			//Various Errors preventing action
			if (statusEffects.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (statusEffects[counter].storageName == storageName) {
					if (newMinutes < 0) {
						trace("ERROR: Change storage value with invalid value for given slot or invalid slot.");
						return;
					}
					statusEffects[counter].minutesLeft = newMinutes;
					return;
				}
			}
			trace("ERROR: Looking for status '" + storageName + "' to change minutes, and " + short + " does not have the status affect.");
			return;
		}
		public function setStatusTooltip(storageName: String, newTooltip:String)
		{
			var counter: Number = statusEffects.length;
			//Various Errors preventing action
			if (statusEffects.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (statusEffects[counter].storageName == storageName) {
					statusEffects[counter].tooltip = newTooltip;
					return;
				}
			}
			trace("ERROR: Looking for status '" + storageName + "' to change tooltip but couldn't find it.");
			return;
		}
		public function addStatusMinutes(storageName: String, newMinutes:int)
		{
			var counter: Number = statusEffects.length;
			//Various Errors preventing action
			if (statusEffects.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (statusEffects[counter].storageName == storageName) 
				{
					statusEffects[counter].minutesLeft += newMinutes;
					if (statusEffects[counter].minutesLeft < 0) {
						statusEffects[counter].minutesLeft = 0;
					}
					return;
				}
			}
			trace("ERROR: Looking for status '" + storageName + "' to add minutes, and " + short + " does not have the status affect.");
			return;
		}
		public function setKeyItemValue(storageName: String, storageValueNum: int, newValue) {
			setStorageValue(keyItems, storageName, storageValueNum, newValue);
		}
		public function setPerkValue(perkName: String, perkValueNum: Number = 1, newNum: Number = 0) {
			setStorageValue(perks, perkName, perkValueNum, newNum);
		}
		public function setPerkTooltip(perkName: String, perkTooltip: String):void
		{
			var counter: Number = perks.length;
			//Various Errors preventing action
			if (perks.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (perks[counter].storageName == perkName) {
					perks[counter].tooltip = perkTooltip;
					return;
				}
			}
			trace("ERROR: Looking for status '" + perkName + "' to change value " + perkTooltip + ", and " + short + " does not have the status affect.");
			return;
		}
		public function setStorageValue(array: Array, storageName: String, storageValueNum: int, newValue) {
			var counter: Number = array.length;
			//Various Errors preventing action
			if (array.length <= 0) return;
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (array[counter].storageName == storageName) {
					if (storageValueNum < 1 || storageValueNum > 5 || (storageValueNum == 5 && !newValue is String) || (storageValueNum > 0 && storageValueNum < 5 && !newValue is Number)) {
						trace("ERROR: Change storage value with invalid value for given slot or invalid slot.");
						return;
					}
					if (storageValueNum == 1) array[counter].value1 = newValue;
					else if (storageValueNum == 2) array[counter].value2 = newValue;
					else if (storageValueNum == 3) array[counter].value3 = newValue;
					else if (storageValueNum == 4) array[counter].value4 = newValue;
					else if (storageValueNum == 5) array[counter].description = newValue;
					return;
				}
			}
			trace("ERROR: Looking for status '" + storageName + "' to change value " + storageValueNum + ", and " + short + " does not have the status affect.");
			return;
		}
		public function addStatusValue(statusName: String, statusValueNum: Number = 1, newNum: Number = 0) {
			addStorageValue(statusEffects, statusName, statusValueNum, newNum);
		}
		public function addPerkValue(perkName: String, perkValueNum: Number = 1, newNum: Number = 0) {
			addStorageValue(perks, perkName, perkValueNum, newNum);
		}
		public function addKeyValue(statusName: String, statusValueNum: Number = 1, newNum: Number = 0) {
			addStorageValue(keyItems, statusName, statusValueNum, newNum);
		}
		public function addStorageValue(array, storageName: String, storageValueNum: Number = 1, newNum: Number = 0) {
			var counter: Number = statusEffects.length;
			//Various Errors preventing action
			if (array.length <= 0) {
				return;
				//trace("ERROR: Looking for storage '" + storageName + "' to add value " + storageValueNum + ", and " + short + " has no storage in array.");
			}
			while (counter > 0) {
				counter--;
				//Find it, change it, quit out
				if (array[counter].storageName == storageName) {
					if (storageValueNum < 1 || storageValueNum > 4) {
						trace("ERROR: AddStorageValue called with invalid status value number.");
						return;
					}
					if (storageValueNum == 1) array[counter].value1 += newNum;
					if (storageValueNum == 2) array[counter].value2 += newNum;
					if (storageValueNum == 3) array[counter].value3 += newNum;
					if (storageValueNum == 4) array[counter].value4 += newNum;
					return;
				}
			}
			trace("ERROR: Looking for status '" + storageName + "' to add value " + storageValueNum + ", and " + short + " does not have the status affect.");
			return;
		}

		private function storageValue(array, storageName, targetValue): Number {
			//trace("Finding storage value.");
			if (array.length == 0) return 0;
			if (!hasStorageName(array, storageName)) return 0;
			for (var counter: int = 0; counter < array.length; counter++) {
				//trace("Loop through once");
				if (array[counter].storageName == storageName) break;
			}
			//trace("Finished Loop");
			if (targetValue == 1) return array[counter].value1;
			else if (targetValue == 2) return array[counter].value2;
			else if (targetValue == 3) return array[counter].value3;
			else if (targetValue == 4) return array[counter].value4;
			return 0;
		}
		public function statusEffectv1(statusName: String): Number {
			return storageValue(statusEffects, statusName, 1);
		}
		public function statusEffectv2(statusName: String): Number {
			return storageValue(statusEffects, statusName, 2);
		}
		public function statusEffectv3(statusName: String): Number {
			return storageValue(statusEffects, statusName, 3);
		}
		public function statusEffectv4(statusName: String): Number {
			return storageValue(statusEffects, statusName, 4);
		}
		public function perkv1(statusName: String): Number {
			return storageValue(perks, statusName, 1);
		}
		public function perkv2(statusName: String): Number {
			return storageValue(perks, statusName, 2);
		}
		public function perkv3(statusName: String): Number {
			return storageValue(perks, statusName, 3);
		}
		public function perkv4(statusName: String): Number {
			return storageValue(perks, statusName, 4);
		}
		public function keyItemv1(statusName: String): Number {
			return storageValue(keyItems, statusName, 1);
		}
		public function keyItemv2(statusName: String): Number {
			return storageValue(keyItems, statusName, 2);
		}
		public function keyItemv3(statusName: String): Number {
			return storageValue(keyItems, statusName, 3);
		}
		public function keyItemv4(statusName: String): Number {
			return storageValue(keyItems, statusName, 4);
		}


		//Grow
		public function increaseCock(increase: Number, cockNum: Number): Number {
			if (hasPerk("Big Cock") >= 0) increase *= perks[hasPerk("Big Cock")].value1;
			if (hasPerk("Phallic Potential") >= 0) increase *= 1.5;
			if (hasPerk("Phallic Restraint") >= 0) increase *= .25;
			return cocks[cockNum].growCock(increase);
		}
		//BreastCup
		public function breastCup(rowNum: Number = 0, ratingCheck: int = -1): String {
			//Error catching.
			if (ratingCheck == -1 && rowNum + 1 > breastRows.length) return "ERROR-cup";
			//Set the breastRating to be checked or the artifical ratingCheck if not -1.
			var check: int = breastRows[rowNum].breastRating();
			if (ratingCheck >= 0) check = ratingCheck;
			//Get a cup size.
			if (check < 1) return "0-cup";
			else if (check < 2) return "A-cup";
			else if (check < 3) return "B-cup";
			else if (check < 4) return "C-cup";
			else if (check < 5) return "D-cup";
			else if (check < 6) return "DD-cup";
			else if (check < 7) return "big DD-cup";
			else if (check < 8) return "E-cup";
			else if (check < 9) return "big E-cup";
			else if (check < 10) return "EE-cup";
			else if (check < 11) return "big EE-cup";
			else if (check < 12) return "F-cup";
			else if (check < 13) return "big F-cup";
			else if (check < 14) return "FF-cup";
			else if (check < 15) return "big FF-cup";
			else if (check < 16) return "G-cup";
			else if (check < 17) return "big G-cup";
			else if (check < 18) return "GG-cup";
			else if (check < 19) return "big GG-cup";
			else if (check < 20) return "H-cup";
			else if (check < 21) return "big H-cup";
			else if (check < 22) return "HH-cup";
			else if (check < 23) return "big HH-cup";
			else if (check < 24) return "HHH-cup";
			else if (check < 25) return "I-cup";
			else if (check < 26) return "big I-cup";
			else if (check < 27) return "II-cup";
			else if (check < 28) return "big II-cup";
			else if (check < 29) return "J-cup";
			else if (check < 30) return "big J-cup";
			else if (check < 31) return "JJ-cup";
			else if (check < 32) return "big JJ-cup";
			else if (check < 33) return "K-cup";
			else if (check < 34) return "big K-cup";
			else if (check < 35) return "KK-cup";
			else if (check < 36) return "big KK-cup";
			else if (check < 37) return "L-cup";
			else if (check < 38) return "big L-cup";
			else if (check < 39) return "LL-cup";
			else if (check < 40) return "big LL-cup";
			else if (check < 41) return "M-cup";
			else if (check < 42) return "big M-cup";
			else if (check < 43) return "MM-cup";
			else if (check < 44) return "big MM-cup";
			else if (check < 45) return "MMM-cup";
			else if (check < 46) return "large MMM-cup";
			else if (check < 47) return "N-cup";
			else if (check < 48) return "large N-cup";
			else if (check < 49) return "NN-cup";
			else if (check < 50) return "large NN-cup";
			else if (check < 51) return "O-cup";
			else if (check < 52) return "large O-cup";
			else if (check < 53) return "OO-cup";
			else if (check < 54) return "large OO-cup";
			else if (check < 55) return "P-cup";
			else if (check < 56) return "large P-cup";
			else if (check < 57) return "PP-cup";
			else if (check < 58) return "large PP-cup";
			else if (check < 59) return "Q-cup";
			else if (check < 60) return "large Q-cup";
			else if (check < 61) return "QQ-cup";
			else if (check < 62) return "large QQ-cup";
			else if (check < 63) return "R-cup";
			else if (check < 64) return "large R-cup";
			else if (check < 65) return "RR-cup";
			else if (check < 66) return "large RR-cup";
			else if (check < 67) return "S-cup";
			else if (check < 68) return "large S-cup";
			else if (check < 69) return "SS-cup";
			else if (check < 70) return "large SS-cup";
			else if (check < 71) return "T-cup";
			else if (check < 72) return "large T-cup";
			else if (check < 73) return "TT-cup";
			else if (check < 74) return "large TT-cup";
			else if (check < 75) return "U-cup";
			else if (check < 76) return "large U-cup";
			else if (check < 77) return "UU-cup";
			else if (check < 78) return "large UU-cup";
			else if (check < 79) return "V-cup";
			else if (check < 80) return "large V-cup";
			else if (check < 81) return "VV-cup";
			else if (check < 82) return "large VV-cup";
			else if (check < 83) return "W-cup";
			else if (check < 84) return "large W-cup";
			else if (check < 85) return "WW-cup";
			else if (check < 86) return "large WW-cup";
			else if (check < 87) return "X-cup";
			else if (check < 88) return "large X-cup";
			else if (check < 89) return "XX-cup";
			else if (check < 90) return "large XX-cup";
			else if (check < 91) return "Y-cup";
			else if (check < 92) return "large Y-cup";
			else if (check < 93) return "YY-cup";
			else if (check < 94) return "large YY-cup";
			else if (check < 95) return "Z-cup";
			else if (check < 96) return "large Z-cup";
			else if (check < 97) return "ZZ-cup";
			else if (check < 98) return "large ZZ-cup";
			else if (check < 99) return "ZZZ-cup";
			else if (check < 100) return "large ZZZ-cup";
			else if (check < 101) return "hyper A-cup";
			else if (check < 102) return "hyper B-cup";
			else if (check < 103) return "hyper C-cup";
			else if (check < 104) return "hyper D-cup";
			else if (check < 105) return "hyper DD-cup";
			else if (check < 106) return "hyper big DD-cup";
			else if (check < 107) return "hyper E-cup";
			else if (check < 108) return "hyper big E-cup";
			else if (check < 109) return "hyper EE-cup";
			else if (check < 110) return "hyper big EE-cup";
			else if (check < 111) return "hyper F-cup";
			else if (check < 112) return "hyper big F-cup";
			else if (check < 113) return "hyper FF-cup";
			else if (check < 114) return "hyper big FF-cup";
			else if (check < 115) return "hyper G-cup";
			else if (check < 116) return "hyper big G-cup";
			else if (check < 117) return "hyper GG-cup";
			else if (check < 118) return "hyper big GG-cup";
			else if (check < 119) return "hyper H-cup";
			else if (check < 120) return "hyper big H-cup";
			else if (check < 121) return "hyper HH-cup";
			else if (check < 122) return "hyper big HH-cup";
			else if (check < 123) return "hyper HHH-cup";
			else if (check < 124) return "hyper I-cup";
			else if (check < 125) return "hyper big I-cup";
			else if (check < 126) return "hyper II-cup";
			else if (check < 127) return "hyper big II-cup";
			else if (check < 128) return "hyper J-cup";
			else if (check < 129) return "hyper big J-cup";
			else if (check < 130) return "hyper JJ-cup";
			else if (check < 131) return "hyper big JJ-cup";
			else if (check < 132) return "hyper K-cup";
			else if (check < 133) return "hyper big K-cup";
			else if (check < 134) return "hyper KK-cup";
			else if (check < 135) return "hyper big KK-cup";
			else if (check < 136) return "hyper L-cup";
			else if (check < 137) return "hyper big L-cup";
			else if (check < 138) return "hyper LL-cup";
			else if (check < 139) return "hyper big LL-cup";
			else if (check < 140) return "hyper M-cup";
			else if (check < 141) return "hyper big M-cup";
			else if (check < 142) return "hyper MM-cup";
			else if (check < 143) return "hyper big MM-cup";
			else if (check < 144) return "hyper MMM-cup";
			else if (check < 145) return "hyper large MMM-cup";
			else if (check < 146) return "hyper N-cup";
			else if (check < 147) return "hyper large N-cup";
			else if (check < 148) return "hyper NN-cup";
			else if (check < 149) return "hyper large NN-cup";
			else if (check < 150) return "hyper O-cup";
			else if (check < 151) return "hyper large O-cup";
			else if (check < 152) return "hyper OO-cup";
			else if (check < 153) return "hyper large OO-cup";
			else if (check < 154) return "hyper P-cup";
			else if (check < 155) return "hyper large P-cup";
			else if (check < 156) return "hyper PP-cup";
			else if (check < 157) return "hyper large PP-cup";
			else if (check < 158) return "hyper Q-cup";
			else if (check < 159) return "hyper large Q-cup";
			else if (check < 160) return "hyper QQ-cup";
			else if (check < 161) return "hyper large QQ-cup";
			else if (check < 162) return "hyper R-cup";
			else if (check < 163) return "hyper large R-cup";
			else if (check < 164) return "hyper RR-cup";
			else if (check < 165) return "hyper large RR-cup";
			else if (check < 166) return "hyper S-cup";
			else if (check < 167) return "hyper large S-cup";
			else if (check < 168) return "hyper SS-cup";
			else if (check < 169) return "hyper large SS-cup";
			else if (check < 170) return "hyper T-cup";
			else if (check < 171) return "hyper large T-cup";
			else if (check < 172) return "hyper TT-cup";
			else if (check < 173) return "hyper large TT-cup";
			else if (check < 174) return "hyper U-cup";
			else if (check < 175) return "hyper large U-cup";
			else if (check < 176) return "hyper UU-cup";
			else if (check < 177) return "hyper large UU-cup";
			else if (check < 178) return "hyper V-cup";
			else if (check < 179) return "hyper large V-cup";
			else if (check < 180) return "hyper VV-cup";
			else if (check < 181) return "hyper large VV-cup";
			else if (check < 182) return "hyper W-cup";
			else if (check < 183) return "hyper large W-cup";
			else if (check < 184) return "hyper WW-cup";
			else if (check < 185) return "hyper large WW-cup";
			else if (check < 186) return "hyper X-cup";
			else if (check < 187) return "hyper large X-cup";
			else if (check < 188) return "hyper XX-cup";
			else if (check < 189) return "hyper large XX-cup";
			else if (check < 190) return "hyper Y-cup";
			else if (check < 191) return "hyper large Y-cup";
			else if (check < 192) return "hyper YY-cup";
			else if (check < 193) return "hyper large YY-cup";
			else if (check < 194) return "hyper Z-cup";
			else if (check < 195) return "hyper large Z-cup";
			else if (check < 196) return "hyper ZZ-cup";
			else if (check < 197) return "hyper large ZZ-cup";
			else if (check < 198) return "hyper ZZZ-cup";
			else if (check < 199) return "hyper large ZZZ-cup";
			else return "Jacques00-cup";
			return "Error-Cup (breastSize Error Number: " + check;
			//watermelon-sized
			//tent sized
			//truck sized
			//parachute sized
			//pool-sized
			//hanger-sized
			//town-sized
			//city-sized
			//state-sized
			//continent-sized
			//planet-sized
			//WTFISTHISWHYISNTITGAMEOVER?
		}
		public function bRows(): Number {
			return breastRows.length;
		}
		public function totalBreasts(): Number {
			var counter: Number = breastRows.length;
			var total: Number = 0;
			while (counter > 0) {
				counter--;
				total += breastRows[counter].breasts;
			}
			return total;
		}
		public function bRating(arg: int): Number {
			if (arg >= bRows()) return 0;
			else return breastRows[arg].breastRating();
		}
		public function bRatingRaw(arg:int):Number {
			if (arg >= bRows()) return 0;
			else return breastRows[arg].breastRatingRaw;
		}
		public function totalNipples(): Number {
			var counter: Number = breastRows.length;
			var total: Number = 0;
			while (counter > 0) {
				counter--;
				total += nipplesPerBreast * breastRows[counter].breasts;
			}
			return total;
		}
		public function totalNippleCocks():int
		{
			var count:int = 0;
			for (var i:int = 0; i < breastRows.length; i++)
			{
				if (breastRows[i].nippleType == GLOBAL.NIPPLE_TYPE_DICK)
				{
					count += nipplesPerBreast * breastRows[i].breasts;
				}
			}
			return count;
		}
		
		public function biggestTitSize(): Number {
			if (breastRows.length == 0) return -1;
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[index].breastRating() < breastRows[counter].breastRating()) index = counter;
			}
			return breastRows[index].breastRating();
		}
		public function smallestTitSize(): Number {
			if (breastRows.length == 0) return -1;
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[index].breastRating() > breastRows[counter].breastRating()) index = counter;
			}
			return breastRows[index].breastRating();
		}
		public function smallestTitRow(): Number {
			if (breastRows.length == 0) return -1;
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[index].breastRating() > breastRows[counter].breastRating()) index = counter;
			}
			return index;
		}
		public function biggestTitRow(): Number {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[index].breastRating() < breastRows[counter].breastRating()) index = counter;
			}
			return index;
		}
		public function canTitFuck(big: Boolean = false): Boolean {
			var threshhold: int = 3;
			if (big) threshhold = 7;
			for (var x: int = 0; x < bRows(); x++) {
				if (breastRows[x].breastRating() >= threshhold && breastRows[x].breasts > 1) return true;
			}
			return false;
		}
		public function canTriboobTitFuck(big: Boolean = false): Boolean {
			var threshhold: int = 3;
			if (big) threshhold = 7;
			for (var x: int = 0; x < bRows(); x++) {
				if (breastRows[x].breastRating() >= threshhold && breastRows[x].breasts > 2) return true;
			}
			return false;
		}
		//Arg is "how many rows minimum". "big" is if target dick requires big ol jubblies.
		public function canMultiRowTitFuck(arg: Number = 2, big: Boolean = false): Boolean {
			var threshhold: int = 3;
			if (big) threshhold = 7;
			var eligibleRows: int = 0;
			for (var x: int = 0; x < bRows(); x++) {
				if (breastRows[x].breastRating() >= threshhold && breastRows[x].breasts > 1) eligibleRows++;
			}
			return (eligibleRows >= arg);
		}
		public function mostBreastsPerRow(): Number {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[index].breasts < breastRows[counter].breasts) index = counter;
			}
			return breastRows[index].breasts;
		}
		//No arg = average, otherwise ask by row.
		public function breastsPerRow(arg: int = -1): Number {
			if (arg >= 0 && arg < bRows()) {
				return breastRows[arg].breasts;
			}
			//Average!
			var av: Number = 0;
			for (var x: int = 0; x < bRows(); x++) {
				av += breastRows[x].breasts;
			}
			return Math.round((av /= bRows()) * 10) / 10;
		}
		public function averageNipplesPerBreast(): Number {
			var counter: Number = breastRows.length;
			var breasts: Number = 0;
			var nipples: Number = 0;
			while (counter > 0) {
				counter--;
				breasts += breastRows[counter].breasts;
				nipples += nipplesPerBreast * breastRows[counter].breasts;
			}
			if (breasts == 0) return 0;
			return Math.floor(nipples / breasts);
		}
		public function hasASheath(): Boolean {
			for (var x: int = 0; x < cocks.length; x++) {
				if (cocks[x].hasFlag(GLOBAL.FLAG_SHEATHED)) return true;
			}
			return false;
		}
		public function hasFullSheaths():Boolean {
			for (var x: int = 0; x < cocks.length; x++) {
				if (!cocks[x].hasFlag(GLOBAL.FLAG_SHEATHED)) return false;
			}
			return true;	
		}
		public function hasSheath(arg: int = 0): Boolean {
			if (arg >= cocks.length) return false;
			if (cocks[arg].hasFlag(GLOBAL.FLAG_SHEATHED)) return true;
			return false;
		}
		public function hasKnot(arg: int = 0): Boolean {
			if (arg > cockTotal() - 1 || arg < 0) return false;
			return (cocks[arg].hasFlag(GLOBAL.FLAG_KNOTTED));
		}
		public function hasAKnot(): Boolean {
			for (var x: int = 0; x < cocks.length; x++) {
				if (cocks[x].hasFlag(GLOBAL.FLAG_KNOTTED)) return true;
			}
			return false;
		}
		public function hasCockFlag(arg: int = 0, cockNum: int = 0): Boolean {
			if (cockNum > cockTotal() - 1 || cockNum < 0) return false;
			return (cocks[cockNum].hasFlag(arg));
		}
		public function cockVolume(cockNum: Number, effective: Boolean = true): Number {
			if (cockNum >= cocks.length || cockNum < 0) return 0;
			if (effective) return (cocks[cockNum].effectiveVolume());
			else return (cocks[cockNum].volume());
		}
		public function cockTailVolume(effective: Boolean = true): Number {
			return tailCockVolume(effective);
		}
		public function tailCockVolume(effective: Boolean = true): Number {
			//Abstract size as a cylinder + half sphere for the tip.
			var cylinder: Number = 3.142 * 1.5 / 2 * 1.5 / 2 * (8 - 1.5);
			var tip: Number = (4 / 3 * 3.142 * 1.5 / 2 * 1.5 / 2 * 1.5 / 2) / 2;
			//If blunt, tip is converted to cylinder as well.
			if (tailGenitalArg == GLOBAL.TYPE_EQUINE) tip = (3.142 * 1.5 / 2 * 1.5 / 2 * 1.5);
			//If flared, tip is multiplied by 1.3.
			if (tailGenitalArg == GLOBAL.TYPE_EQUINE) tip = tip * 1.3;
			//If tapered, reduce total by a factor of 75%
			if (tailGenitalArg == GLOBAL.TYPE_CANINE) {
				tip = tip * .75;
				cylinder = cylinder * .75;
			}
			var temp: Number = Math.round((tip + cylinder) * 100) / 100;
			if (effective) {
				//if(GLOBAL.FLAG_LUBRICATED) temp *= .75;
				//if(hasFlag(GLOBAL.FLAG_STICKY)) temp *= 1.25;
			}
			return Math.round(temp * 100) / 100;
		}
		public function biggestCockLength(): Number {
			if (cocks.length == 0) return 0;
			return cocks[biggestCockIndex()].cLength();
		}
		public function biggestCockVolume(effective: Boolean = true): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) < cockVolume(counter, effective)) index = counter;
			}
			return cockVolume(index, effective);
		}
		//Find the second biggest dick and it's area.
		public function biggestCockVolume2(effective: Boolean = true): Number {
			if (cocks.length <= 1) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			var index2: Number = -1;
			//Find the biggest
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) < cockVolume(counter, effective)) index = counter;
			}
			//Reset counter and find the next biggest
			counter = cocks.length;
			while (counter > 0) {
				counter--;
				//Is this spot claimed by the biggest?
				if (counter != index) {
					//Not set yet?
					if (index2 == -1) index2 = counter;
					//Is the stored value less than the current one?
					if (cockVolume(index2, effective) < cockVolume(counter, effective)) {
						index2 = counter;
					}
				}
			}
			//If it couldn't find a second biggest...
			if (index == index2) return 0;
			return cockVolume(index2, effective);
		}
		public function longestCockIndex(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].cLength() < cocks[counter].cLength()) index = counter;
			}
			return index;
		}
		public function longestCockLength(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].cLength() < cocks[counter].cLength()) index = counter;
			}
			return cocks[index].cLength();
		}
		public function longestHorsecockLength(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if ((cocks[index].cType != GLOBAL.TYPE_EQUINE && cocks[counter].cType == GLOBAL.TYPE_EQUINE) || (cocks[index].cLength < cocks[counter].cLength() && cocks[counter].cType == GLOBAL.TYPE_EQUINE)) index = counter;
			}
			return cocks[index].cLength();
		}
		public function totalcThickness(): Number {
			var thick: Number = 0;
			var counter: Number = cocks.length;
			while (counter > 0) {
				counter--;
				thick += cocks[counter].thickness();
			}
			return thick;
		}
		public function thickestCock(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].thickness() < cocks[counter].thickness()) index = counter;
			}
			return index;
		}
		public function totalGirth(): Number {
			if (cocks.length == 0) return 0;
			var counter: int = 0;
			for (var x: int = 0; x < cocks.length; x++) {
				counter += cocks[x].cLength();
			}
			return counter;
		}
		public function thickestCockThickness(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].thickness() < cocks[counter].thickness()) index = counter;
			}
			return cocks[index].thickness();
		}
		public function thinnestCockIndex(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].thickness() > cocks[counter].thickness()) index = counter;
			}
			return index;
		}
		public function thinnestCockRatioIndex(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].cThicknessRatio() > cocks[counter].cThicknessRatio()) index = counter;
			}
			return index;
		}
		public function smallestCockIndex(effective: Boolean = true): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) > cockVolume(counter, effective)) {
					index = counter;
				}
			}
			return index;
		}
		public function smallestCockLength(): Number {
			if (cocks.length == 0) return 0;
			return cocks[smallestCockIndex()].cLength();
		}
		public function shortestCockIndex(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].cLength() > cocks[counter].cLength()) index = counter;
			}
			return index;
		}
		public function shortestCockLength(): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cocks[index].cLength() > cocks[counter].cLength()) index = counter;
			}
			return cocks[index].cLength();
		}
		//Find the biggest cock that fits inside a given value
		public function cockThatFits(fits: Number = 0, type: String = "area"): Number {
			trace("Fits value: " + fits);
			if (cocks.length <= 0) return -1;
			var counter: Number = cocks.length;
			//Current largest fitter
			var index: Number = -1;
			while (counter > 0) {
				counter--;
				if (type == "area") {
					if (cockVolume(counter, true) <= fits) {
						//If one already fits
						if (index >= 0) {
							//See if the newcomer beats the saved small guy
							if (cockVolume(counter, true) > cockVolume(index, true))
								index = counter;
						}
						//Store the index of fitting dick
						else index = counter;
					}
				} else if (type == "length") {
					if (cocks[counter].cLength() <= fits) {
						//If one already fits
						if (index >= 0) {
							//See if the newcomer beats the saved small guy
							if (cockVolume(counter, true) > cockVolume(index, true)) {
								index = counter;
							}
						}
						//Store the index of fitting dick
						else index = counter;
					}
				}
			}
			return index;
		}
		//Find the 2nd biggest cock that fits inside a given value
		public function cockThatFits2(fits: Number = 0): Number {
			if (cockTotal() == 1) return -1;
			var counter: Number = cocks.length;
			//Current largest fitter
			var index: Number = -1;
			var index2: Number = -1;
			while (counter > 0) {
				counter--;
				//Does this one fit?
				if (cockVolume(counter, true) <= fits) {
					//If one already fits
					if (index >= 0) {
						//See if the newcomer beats the saved small guy
						if (cockVolume(counter, true) > cockVolume(index, true)) {
							//Save old wang
							if (index != -1) index2 = index;
							index = counter;
						}
						//If this one fits and is smaller than the other great
						else {
							if ((cockVolume(index2, true) < cockVolume(counter, true)) && counter != index) {
								index2 = counter;
							}
						}
						if (index >= 0 && index == index2) trace("FUCK ERROR COCKTHATFITS2 SHIT IS BROKED!");
					}
					//Store the index of fitting dick
					else index = counter;
				}
			}
			return index2;
		}
		public function smallestCockArea(effective: Boolean = true): Number {
			if (cockTotal() == 0) return -1;
			return cockVolume(smallestCockIndex(), effective);
		}
		public function smallestCock(effective: Boolean = true): Number {
			return cockVolume(smallestCockIndex(), effective);
		}
		public function biggestCockIndex(effective: Boolean = true): Number {
			if (cocks.length == 0) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) < cockVolume(counter, effective)) index = counter;
			}
			return index;
		}
		//Find the second biggest dick's index.
		public function biggestCockIndex2(effective: Boolean = true): Number {
			if (cocks.length <= 1) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			var index2: Number = 0;
			//Find the biggest
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) < cockVolume(counter, effective)) index = counter;
			}
			//Reset counter and find the next biggest
			counter = cocks.length;
			while (counter > 0) {
				counter--;
				//Make sure index2 doesn't get stuck
				//at the same value as index1 if the
				//initial location is biggest.
				if (index == index2 && counter != index) index2 = counter;
				//Is the stored value less than the current one?
				if (cockVolume(index2, effective) < cockVolume(counter, effective)) {
					//Make sure we don't set index2 to be the same
					//as the biggest dick.
					if (counter != index) index2 = counter;
				}
			}
			//If it couldn't find a second biggest...
			if (index == index2) return 0;
			return index2;
		}
		public function smallestCockIndex2(effective: Boolean = true): Number {
			if (cocks.length <= 1) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			var index2: Number = 0;
			//Find the smallest
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) > cockVolume(counter, effective)) index = counter;
			}
			//Reset counter and find the next biggest
			counter = cocks.length;
			while (counter > 0) {
				counter--;
				//Make sure index2 doesn't get stuck
				//at the same value as index1 if the
				//initial location is biggest.
				if (index == index2 && counter != index) index2 = counter;
				//Is the stored value less than the current one?
				if (cockVolume(index2, effective) > cockVolume(counter, effective)) {
					//Make sure we don't set index2 to be the same
					//as the biggest dick.
					if (counter != index) index2 = counter;
				}
			}
			//If it couldn't find a second biggest...
			if (index == index2) return 0;
			return index2;
		}
		//Find the third biggest dick index.
		public function biggestCockIndex3(effective: Boolean = true): Number {
			if (cocks.length <= 2) return 0;
			var counter: Number = cocks.length;
			var index: Number = 0;
			var index2: Number = -1;
			var index3: Number = -1;
			//Find the biggest
			while (counter > 0) {
				counter--;
				if (cockVolume(index, effective) < cockVolume(counter, effective)) index = counter;
			}
			//Reset counter and find the next biggest
			counter = cocks.length;
			while (counter > 0) {
				counter--;
				//If this index isn't used already
				if (counter != index) {
					//Has index been set to anything yet?
					if (index2 == -1) index2 = counter;
					//Is the stored value less than the current one?
					else if (cockVolume(index2, effective) < cockVolume(counter, effective)) {
						index2 = counter;
					}
				}
			}
			//If it couldn't find a second biggest...
			if (index == index2 || index2 == -1) index2 = 0;
			//Reset counter and find the next biggest
			counter = cocks.length;
			while (counter > 0) {
				counter--;
				//If this index isn't used already
				if (counter != index && counter != index2) {
					//Has index been set to anything yet?
					if (index3 == -1) index3 = counter;
					//Is the stored value less than the current one?
					else if (cockVolume(index3, effective) < cockVolume(counter, effective)) {
						index3 = counter;
					}
				}
			}
			//If it fails for some reason.
			if (index3 == -1) index3 = 0;
			return index3;
		}
		protected function rand(max: Number): Number {
			return int(Math.random() * max);
		}
		public function wetness(arg: int = 0): Number {
			//If the player has no vaginas
			if (vaginas.length == 0 || arg >= vaginas.length) return 0;
			return vaginas[arg].wetness();
		}
		public function looseness(arg: int = 0): Number {
			//If the player has no vaginas
			if (vaginas.length == 0 || arg >= vaginas.length) return 0;
			return vaginas[arg].looseness;
		}
		public function lowestWetness(index:Boolean = false): Number {
			//If the player has no vaginas
			if (vaginas.length == 0) return 0;
			var wet:int = -1;
			for(var x:int = 0; x < vaginas.length; x++)
			{
				if(wet == -1) wet = x;
				if(vaginas[x].wetness < vaginas[wet].wetness) wet = x;
			}
			if(index) return wet;
			else return vaginas[wet].wetness;
		}
		public function lowestWetnessIndex():Number
		{
			return lowestWetness(true);
		}
		public function highestWetness(index:Boolean = false): Number {
			//If the player has no vaginas
			if (vaginas.length == 0) return 0;
			var wet:int = -1;
			for(var x:int = 0; x < vaginas.length; x++)
			{
				if(wet == -1) wet = x;
				if(vaginas[x].wetness > vaginas[wet].wetness) wet = x;
			}
			if(index) return wet;
			else return vaginas[wet].wetness;
		}
		public function highestWetnessIndex():Number
		{
			return highestWetness(true);
		}
		public function vaginalCapacity(arg: int = 0): Number {
			//If the player has no vaginas
			if (vaginas.length == 0) return 0;
			var amount:Number = vaginas[arg].capacity() * elasticity;
			if(isTaur()) amount += 400;
			return amount;
		}
		public function smallestVaginalCapacity(): Number {
			return vaginalCapacity(smallestVaginaIndex());
		}
		public function biggestVaginalCapacity(): Number {
			return vaginalCapacity(biggestVaginaIndex());
		}
		public function gapestVaginaLooseness(): Number {
			var counter: Number = vaginas.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (vaginas[index].looseness() < vaginas[counter].looseness()) index = counter;
			}
			return vaginas[counter].looseness();
		}
		public function wettestVaginalWetness(): Number {
			var counter: Number = vaginas.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (vaginas[index].wetness() < vaginas[counter].wetness()) index = counter;
			}
			return vaginas[counter].wetness();
		}
		public function driestVaginalWetness(): Number {
			var counter: Number = vaginas.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (vaginas[index].wetness() > vaginas[counter].wetness()) index = counter;
			}
			return vaginas[counter].wetness();
		}
		public function biggestVaginaIndex(): int {
			if (vaginas.length == 0) return 0;
			var counter: Number = vaginas.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (vaginalCapacity(index) < vaginalCapacity(counter)) index = counter;
			}
			return index;
		}
		public function smallestVaginaIndex(): int {
			if (vaginas.length == 0) return 0;
			var counter: Number = vaginas.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (vaginalCapacity(index) < vaginalCapacity(counter)) index = counter;
			}
			return index;
		}
		//Find the biggest cock that fits inside a given value
		public function cuntThatFits(fits: Number = 0): Number {
			if (vaginas.length <= 0) return -1;
			var counter: Number = vaginas.length;
			//Current largest fitter
			var index: Number = -1;
			while (counter > 0) {
				counter--;

				if (vaginalCapacity(counter) >= fits) {
					//If one already fits
					if (index >= 0) {
						//See if the newcomer beats the saved small guy
						if (vaginalCapacity(counter) < vaginalCapacity(index)) {
							index = counter;
						}
					}
					//Store the index of fitting dick
					else index = counter;
				}
			}
			return index;
		}
		public function analCapacity(): Number {
			return ass.capacity() * elasticity;
		}
		public function hasTentacleNipples():Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_TENTACLED) return true;
			}
			return false;
		}
		public function hasCuntNipples(): Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_FUCKABLE) index = counter;
			}
			if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_FUCKABLE) return true;
			return false;
		}
		public function hasFuckableNipples(): Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].fuckable()) index = counter;
			}
			if (breastRows[index].fuckable()) return true;
			return false;
		}
		public function hasLipples(): Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_LIPPLES) index = counter;
			}
			if (breastRows[index].nippleType == GLOBAL.NIPPLE_TYPE_LIPPLES) return true;
			return false;
		}
		public function hasDickNipples(): Boolean {
			//trace("THIS FUNCTION IS THE REASON THEY INVENTED AIDS. WHRYYYYYYYYYY!!!!!!!!!!!!!1111one!");
			return hasNippleCocks();
		}
		public function hasNippleCocks(): Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_DICK) return true;
			}
			return false;
		}
		public function hasFlatNipples(): Boolean {
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				if (breastRows[counter].nippleType == GLOBAL.NIPPLE_TYPE_FLAT) return true;
			}
			return false;
		}
		public function hasBreasts(): Boolean {
			if (breastRows.length > 0) {
				if (biggestTitSize() >= 1) return true;
			}
			return false;
		}
		public function hasNipples(): Boolean {
			if(nipplesPerBreast > 0) return true;
			return false;
		}
		public function canLactate():Boolean
		{
			//PC has reached lactation threshold!
			if(milkMultiplier > 50) return true;
			return false;
		}

		public function isLactating(): Boolean {
			//PC can't be lactating unless they canLactate!
			if(canLactate())
			{
				//Is there enough milk in yer tits for lactation?
				if(milkFullness >= 10)
				{
					//yes? true!
					return true;
				}
			}
			//Didn't proc any trues? Not lactating.
			return false;
		}
		public function canMilkSquirt():Boolean
		{
			if(milkFullness >= 80) return true;
			return false;
		}
		public function milkProduced(minutes: Number): Number {
			if(!canLactate()) return 0;
			//How many mLs produced?
			var mLsGained:Number = 1.73 * milkRate/10 * minutes;
			//Factor in current milkMultiplier
			mLsGained *= (milkMultiplier)/100;
			//Great. Now figure out how much fullness that adds.
			var fullnessDelta:Number = mLsGained / milkCapacity() * 100;
			
			//75% fullness notification
			if(milkFullness < 75 && milkFullness + fullnessDelta >= 75) createStatusEffect("Pending Gain Milk Note: 75");
			//100% notification!
			if(milkFullness < 100 && milkFullness + fullnessDelta >= 100) createStatusEffect("Pending Gain Milk Note: 100");

			//If we're going above 100.
			if(fullnessDelta + milkFullness > 100)
			{
				//If we start below 100, do that normally first
				if(milkFullness < 100)
				{
					var subHundredFullness:Number = 100 - milkFullness;
					milkFullness = 100;
					fullnessDelta -= subHundredFullness;
				}
				//150%
				if(milkFullness < 150 && milkFullness + fullnessDelta/2 >= 150) createStatusEffect("Pending Gain Milk Note: 150");
				//200%
				if(milkFullness < 200 && milkFullness + fullnessDelta/2 >= 200) createStatusEffect("Pending Gain Milk Note: 200");
				//Grow at half rate since we're over 100
				milkFullness += fullnessDelta/2;
			}

			//Not going above 100? Just add it
			else milkFullness += fullnessDelta;

			//Just check to make sure there's a cap for top end and bottom end
			if(milkFullness > 200) milkFullness = 200;
			else if(milkFullness < 0) {
				trace("ERROR: Flash sucks dicks at math and somehow got a negative milk fullness.");
				milkFullness = 0;
			}
			trace("Breast milk produced: " + mLsGained + ", Fullness: " + milkFullness + " Total mLs Held: " + milkQ(99) + ", Max mLs: " + milkCapacity());
			return mLsGained;
		}
		public function milkCapacity(arg:int = -1):Number
		{
			//400mLs + breastRating/2*100
			var capacity:Number = 0;
			//if arg == -1, mLs produced by biggest row.
			if(arg == -1)
			{
				capacity = (400 + biggestTitSize() / 2 * 100) * milkStorageMultiplier;
			}
			//if arg == 99, total mLs produced by all rows
			else if(arg == 99)
			{
				//Total it up!
				for(var x:int = 0; x < breastRows.length; x++)
				{
					capacity += (400 + breastRows[x].breastRating / 2 * 100);
				}
				capacity *= milkStorageMultiplier;
			}
			//otherwise, mLs produced by arg # row.
			else
			{
				if(arg < 0 || arg >= breastRows.length) return 0;
				else capacity = (400 + breastRows[arg].breastRatingRaw / 2 * 100) * milkStorageMultiplier;
			}
			return capacity;
		}
		public function milkQ(arg:int = -1):Number {
			return lactationQ(arg);
		}
		public function lactationQ(arg:int = -1): Number {
			var total:Number = 0;
			//So much easier now - just a quick lookup.
			//Arg -1 = amount from biggest tits.
			if(arg == -1) return milkFullness/100 * milkCapacity();
			//Arg 99 = amount from all tits
			else if(arg == 99)
			{
				//Total it up!
				for(var x:int = 0; x < breastRows.length; x++)
				{
					//trace("Row " + x + " mLs: " + (milkFullness * milkCapacity(x)));
					total += milkFullness/100 * milkCapacity(x);
				}
				//trace("MilkQ total: " + total);
				return total;
			}
			//Specific row
			else
			{
				if(arg < 0 || arg >= breastRows.length) return 0;
				else return milkFullness/100 * milkCapacity(arg);
			}
			//Failsafe:
			return 0;
		}
		public function boostLactation(amount:Number = 1):void
		{
			//Record this for tracking change
			var originalMultiplier = milkMultiplier;
			//If below 100...
			if(milkMultiplier < 100) {
				//If we cross 100 threshold, set to 100 & go for slow grow.
				if(milkMultiplier + amount > 100) 
				{
					amount = 100 - milkMultiplier;
					milkMultiplier = 100;
				}
				//Otherwise add it up and zero out amount.
				else {
					milkMultiplier += amount;
					amount = 0;
				}
			}
			//Milk multiplier is over 100... slow gro.
			if(amount > 0)
			{
				if(milkMultiplier < 110) milkMultiplier += amount/5;
				else if(milkMultiplier < 125) milkMultiplier += amount/10;
			}
			//Queue threshold notes!
			if(originalMultiplier < 30 && milkMultiplier >= 30) createStatusEffect("Pending Gain MilkMultiplier Note: 30");
			if(originalMultiplier < 40 && milkMultiplier >= 40) createStatusEffect("Pending Gain MilkMultiplier Note: 40");
			if(originalMultiplier < 50 && milkMultiplier >= 50) createStatusEffect("Pending Gain MilkMultiplier Note: 50");
			if(originalMultiplier < 60 && milkMultiplier >= 60) createStatusEffect("Pending Gain MilkMultiplier Note: 60");
			if(originalMultiplier < 70 && milkMultiplier >= 70) createStatusEffect("Pending Gain MilkMultiplier Note: 70");
			if(originalMultiplier < 80 && milkMultiplier >= 80) createStatusEffect("Pending Gain MilkMultiplier Note: 80");
			if(originalMultiplier < 90 && milkMultiplier >= 90) createStatusEffect("Pending Gain MilkMultiplier Note: 90");
			if(originalMultiplier < 100 && milkMultiplier >= 100) createStatusEffect("Pending Gain MilkMultiplier Note: 100");
			if(originalMultiplier < 110 && milkMultiplier >= 110) createStatusEffect("Pending Gain MilkMultiplier Note: 110");
			if(originalMultiplier < 125 && milkMultiplier >= 125) createStatusEffect("Pending Gain MilkMultiplier Note: 125");
		}
		//PC has been milked for "amount" fullness.
		public function milked(amount:Number = 50):Number
		{
			var x:int;
			if(hasPerk("Milky")) amount *= 1.5;
			//Boost lactation by a relevant amount
			if(milkMultiplier < 125) boostLactation(1 + Math.round(amount/50));
			//Actually reduce held milk
			milkFullness -= amount;
			//Set boob swelling to new appropriate tier
			setBoobSwelling();
			return milkFullness;
		}
		public function setBoobSwelling():void
		{
			var x:int;
			//No swelling!
			if(milkFullness < 75) 
			{
				//Reset swelling
				for(x = 0; x < bRows(); x++)
				{
					breastRows[x].breastRatingLactationMod = 0;
				}
			}
			//75 - 99
			else if(milkFullness < 100)
			{
				for(x = 0; x < bRows(); x++)
				{
					if(breastRows[x].breastRatingRaw >= 5) breastRows[x].breastRatingLactationMod = 1.5;
					else breastRows[x].breastRatingLactationMod = 1;
				}
			}
			//100 - 149
			else if(milkFullness < 150)
			{
				for(x = 0; x < bRows(); x++)
				{
					if(breastRows[x].breastRatingRaw >= 5) breastRows[x].breastRatingLactationMod = 2.5;
					else breastRows[x].breastRatingLactationMod = 1.5;
				}	
			}
			else if(milkFullness < 200)
			{
				for(x = 0; x < bRows(); x++)
				{
					if(breastRows[x].breastRatingRaw >= 5) breastRows[x].breastRatingLactationMod = 3.5;
					else breastRows[x].breastRatingLactationMod = 2;
				}
			}
			else
			{
				for(x = 0; x < bRows(); x++)
				{
					if(breastRows[x].breastRatingRaw >= 5) breastRows[x].breastRatingLactationMod = 4.5;
					else breastRows[x].breastRatingLactationMod = 3;
				}
			}
		}
		/*CoC-Tier old milk shits OVERHAUL MILK SYSTEM!
		public function boostLactation(todo: Number): Number {
			if (breastRows.length == 0) return 0;
			var counter: Number = breastRows.length;
			var index: Number = 0;
			var changes: Number = 0;
			var temp2: Number = 0;
			
			
			//Prevent lactation decrease if lactating.
			if (todo >= 0) {
				if (hasStatusEffect("Lactation Reduction") >= 0) setStatusValue("Lactation Reduction", 1, 0);
				if (hasStatusEffect("Lactation Reduc0") >= 0) removeStatusEffect("Lactation Reduc0");
				if (hasStatusEffect("Lactation Reduc1") >= 0) removeStatusEffect("Lactation Reduc1");
				if (hasStatusEffect("Lactation Reduc2") >= 0) removeStatusEffect("Lactation Reduc2");
				if (hasStatusEffect("Lactation Reduc3") >= 0) removeStatusEffect("Lactation Reduc3");
			}
			if(todo > 0) {
				while(todo > 0) {
					counter = breastRows.length;
					todo-= .1;
					while(counter > 0) {
						counter--;
						if(breastRows[index].lactationMultiplier > breastRows[counter].lactationMultiplier) index = counter;
					}
					temp2 = .1;
					if(breastRows[index].lactationMultiplier > 1.5) temp2 /= 2;
					if(breastRows[index].lactationMultiplier > 2.5) temp2 /= 2;
					if(breastRows[index].lactationMultiplier > 3) temp2 /= 2;
					changes += temp2;
					breastRows[index].lactationMultiplier += temp2;
				}
			}
			else {
				while(todo < 0) {
					counter = breastRows.length;
					index = 0;
					if(todo > -.1) {
						while(counter > 0) {
							counter--;
							if(breastRows[index].lactationMultiplier < breastRows[counter].lactationMultiplier) index = counter;
						}
						trace(biggestLactation());
						breastRows[index].lactationMultiplier += todo;
						if(breastRows[index].lactationMultiplier < 0) breastRows[index].lactationMultiplier = 0;
						todo = 0;
					}
					else {
						todo+= .1;
						while(counter > 0) {
							counter--;
							if(breastRows[index].lactationMultiplier < breastRows[counter].lactationMultiplier) index = counter;
						}
						temp2 = todo;
						changes += temp2;
						breastRows[index].lactationMultiplier += temp2;
						if(breastRows[index].lactationMultiplier < 0) breastRows[index].lactationMultiplier = 0;
					}
				}
			}
			return changes;
		}
		public function averageLactation(): Number {
			if (breastRows.length == 0) return 0;
			var counter: Number = breastRows.length;
			var index: Number = 0;
			while (counter > 0) {
				counter--;
				index += milkRate;
			}
			return Math.floor(index / breastRows.length);
		}*/
		//Body Type
		public function bodyType(): String {
			var desc: String = "";
			//OLD STUFF
			/*var strong:Number = 0;
			var desc:String = "";
			var lithe:Number = 0;
			//strong points
			if(str > 25) strong++;
			if(str > 50) strong++;
			if(str > 75) strong++;
			if(str > 99) strong++;
			//lithe points
			if(spe > 25) lithe++;
			if(spe > 50) lithe++;
			if(spe > 75) lithe++;
			if(spe > 99) lithe++;
			if(strong == 0) desc += "small muscles";
			if(strong == 1) desc += "average muscles ";
			if(strong == 2) desc += "strong muscles ";
			if(strong == 3) desc += "obvious muscles ";
			if(strong == 4) desc += "bodybuilder-like muscles ";
			if(lithe == strong) desc += "as quick as they are strong";
			if(lithe - 1 == strong) desc += "that look lean and quick";
			if(lithe - 2 == strong) desc += "that stand out on your sinewy frame";
			if(lithe - 3 == strong) desc += "that look lithe and quick";
			if(lithe - 4 == strong) desc += "that don't betray their incredible speed";
			if(lithe + 1 == strong) desc += "that aren't that quick";
			if(lithe + 2 == strong) desc += "hidden under a small layer of fat";
			if(lithe + 3 == strong) desc += "under some noticable pudge";
			if(lithe + 4 == strong) desc += "buried under lots of fat";
			*/
			//SUPAH THIN
			if (thickness < 10) {
				//SUPAH BUFF
				if (tone > 90) desc += "a lithe body covered in highly visible muscles";
				else if (tone > 75) desc += "an incredibly thin, well-muscled frame";
				else if (tone > 50) desc += "a very thin body that has a good bit of muscle definition";
				else if (tone > 25) desc += "a lithe body and only a little bit of muscle definition";
				else desc += "a waif-thin body, and soft, forgiving flesh";
			}
			//Pretty thin
			else if (thickness < 25) {
				if (tone > 90) desc += "a thin body and incredible muscle definition";
				else if (tone > 75) desc += "a narrow frame that shows off your muscles";
				else if (tone > 50) desc += "a somewhat lithe body and a fair amount of definition";
				else if (tone > 25) desc += "a narrow, soft body that still manages to show off a few muscles";
				else desc += "a thin, soft body";
			}
			//Somewhat thin
			else if (thickness < 40) {
				if (tone > 90) desc += "a fit, somewhat thin body and rippling muscles all over";
				else if (tone > 75) desc += "a thinner-than-average frame and great muscle definition";
				else if (tone > 50) desc += "a somewhat narrow body and a decent amount of visible muscle";
				else if (tone > 25) desc += "a moderately thin body, soft curves, and only a little bit of muscle";
				else desc += "a fairly thin form and soft, cuddle-able flesh";
			}
			//average
			else if (thickness < 60) {
				if (tone > 90) desc += "average thickness and a bevy of perfectly defined muscles";
				else if (tone > 75) desc += "an average-sized frame and great musculature";
				else if (tone > 50) desc += "a normal waistline and decently visible muscles";
				else if (tone > 25) desc += "an average body and soft, unremarkable flesh";
				else desc += "an average frame and soft, untoned flesh with a tendency for jiggle";
			} else if (thickness < 75) {
				if (tone > 90) desc += "a somewhat thick body that's covered in slabs of muscle";
				else if (tone > 75) desc += "a body that's a little bit wide and has some highly-visible muscles";
				else if (tone > 50) desc += "a solid build that displays a decent amount of muscle";
				else if (tone > 25) desc += "a slightly wide frame that displays your curves and has hints of muscle underneath";
				else desc += "a soft, plush body with plenty of jiggle";
			} else if (thickness < 90) {
				if (tone > 90) desc += "a thickset frame that gives you the appearance of a wall of muscle";
				else if (tone > 75) desc += "a burly form and plenty of muscle definition";
				else if (tone > 50) desc += "a solid, thick frame and a decent amount of muscles";
				else if (tone > 25) desc += "a wide-set body, some soft, forgiving flesh, and a hint of muscle underneath it";
				else {
					desc += "a wide, cushiony body";
					if (hasVagina() || biggestTitSize() > 3 || hipRating() > 7 || buttRating() > 7) desc += " and plenty of jiggle on your curves";
				}
			}
			//Chunky monkey
			else {
				if (tone > 90) desc += "an extremely thickset frame and so much muscle others would find you harder to move than a huge boulder";
				else if (tone > 75) desc += "a very wide body and enough muscle to make you look like a tank";
				else if (tone > 50) desc += "an extremely substantial frame packing a decent amount of muscle";
				else if (tone > 25) {
					desc += "a very wide body";
					if (hasVagina() || biggestTitSize() > 4 || hipRating() > 10 || buttRating() > 10) desc += ", lots of curvy jiggles,";
					desc += " and hints of muscle underneath";
				} else {
					desc += "a thick";
					if (hasVagina() || biggestTitSize() > 4 || hipRating() > 10 || buttRating() > 10) desc += ", voluptuous";
					desc += " body and plush, ";
					if (hasVagina() || biggestTitSize() > 4 || hipRating() > 10 || buttRating() > 10) desc += " jiggly curves";
					else desc += " soft flesh";
				}
			}
			return desc;
		}
		
		public var cumMultiplierRaw:Number = 1;
		public var cumMultiplierMod:Number = 0;
		public function cumMultiplier():Number
		{
			var multi:Number = cumMultiplierRaw + cumMultiplierMod;
			
			if (multi < 0) return 0;
			return multi;
		}
		
		//Calculate cum return
		public function cumQ(): Number {
			if (!hasCock()) return 0;
			var quantity: Number = 0;
			//lust - 50% = normal output.  0 = 75%. 100 = +125% output.
			var lustCoefficient: Number = (lust() / 2 + 75) / 100;
			quantity = cumMultiplier() * lustCoefficient * maxCum() / ballEfficiency;
			//Rut means bigger, ball-draining orgasms.
			quantity += statusEffectv1("rut");
			if (quantity > currentCum()) quantity = currentCum();
			//Round dat shit.
			quantity = Math.round(quantity / 10) * 10;
			trace("Cum produced: " + quantity);
			if (quantity < 2) quantity = 2;
			return quantity;
		}
		//Can hold about three average shots worth, since this is fantasy.
		public function maxCum(): Number {
			if (!hasCock()) return 0;
			var quantity: Number = 0;
			//Base value is ballsize*ballQ*cumefficiency by a factor of 2.
			//Other things that affect it: 
			//lust - 50% = normal output.  0 = 75%. 100 = +125% output.
			var lustCoefficient: Number = (lust() / 2 + 75) / 100;

			//Figure on 3x a cumshot value?
			if (balls == 0) quantity = Math.round(ballSize() * 2 * 2 * ballEfficiency);
			else quantity = Math.round(ballSize() * ballSize() * balls * 2 * ballEfficiency);
			return quantity;
		}
		public function currentCum(): Number {
			if(isNaN(ballFullness)) 
			{
				trace("ERROR: ballFullness is not a number. This has been rectified.");
				ballFullness = 0;
			}
			return Math.round(maxCum() * ballFullness/100);
		}
		public function cumProduced(minutes: Number): void {
			var cumDelta:Number = 0;
			//trace("MINUTES OF CUM CHARGING: " + minutes + " FULLNESS: " + ballFullness);
			if(isNaN(ballFullness)) 
			{
				trace("ERROR: ballFullness is not a number. This has been rectified.");
				ballFullness = 0;
			}
			
			// Why is this a loop? Just mul the final thing by total minutes. If we were firing events off that needed to be queued, or if the calculation depended on a value the algo actually changes (ie ballFullness was a part of the calc) then yeah, cycle minutes would be the /simple/ way to do it.
			cumDelta = refractoryRate / 60 * (ballSize() + 1) / 4 * ((balls <= 0) ? 2 : balls); // No balls == replace with 2 for purposes of the calc
			if(hasPerk("Breed Hungry")) cumDelta *= 2;
			ballFullness += (cumDelta * minutes);
			
			trace("AFTER FULLNESS: " + ballFullness);
			if (ballFullness >= 100) ballFullness = 100;
		}
		public function isSquirter(arg: int = 0): Boolean {
			if (!hasVagina()) return false;
			if (arg < 0 || arg >= totalVaginas()) return false;
			if (vaginas[arg].wetness() >= 4) return true;
			return false;
		}
		public function totalClits(): Number {
			if (vaginas.length == 0) return 0;
			var count: int = 0;
			
			for (var x:int = 0; x < vaginas.length; x++)
			{
				count += vaginas[x].clits;
			}
			
			return count;
		}
		public function findFirstOfcType(type: Number = 0): Number {
			var index: Number = 0;
			if (cocks[index].cType == type) return index;
			while (index < cocks.length) {
				index++;
				if (cocks[index].cType == type) return index;
			}
			trace("creature.findFirstOfcType ERROR - searched for cType: " + type + " and could not find it.");
			return 0;
		}
		//How many cocks?
		//Expanded to use an argument and replace horseCocks(), dogCocks(), etc.
		public function cockTotal(type: int = -1): Number {
			if (type == -1) return (cocks.length);
			var counter: int = 0;
			for (var x: int = 0; x < cocks.length; x++) {
				if (cocks[x].cType == type) counter++;
			}
			return counter;
		}
		//Alternate
		public function totalCocks(type: int = -1): Number {
			return cockTotal(type);
		}
		public function totalVaginas(type: int = -1): Number {
			if (type == -1) return (vaginas.length);
			var counter: int = 0;
			for (var x: int = 0; x < vaginas.length; x++) {
				if (vaginas[x].type == type) counter++;
			}
			return counter;
		}
		public function vaginaTotal(type: int = -1): Number {
			return totalVaginas(type);
		}
		//BOolean alternate
		public function hasCock(): Boolean {
			if (cocks.length >= 1) return true;
			return false;
		}
		public function hasCocks(): Boolean {
			if (cocks.length > 1) return true;
			return false;
		}
		public function hasTailCock(): Boolean {
			if (hasTailFlag(GLOBAL.FLAG_TAILCOCK) && tailCount > 0) return true;
			return false;
		}
		public function hasCockTail(): Boolean {
			return hasTailCock();
		}
		public function hasTailgina(): Boolean {
			return hasTailCunt();
		}
		public function hasCuntTail(): Boolean {
			return hasTailCunt();
		}
		public function hasTailCunt(): Boolean {
			if (tailType == GLOBAL.TYPE_CUNTSNAKE && tailCount > 0) return true;
			return false;
		}
		//In case there's ever different types of cuntTails available, we'll need different methods.
		public function hasCuntSnake(): Boolean {
			return hasTailCunt();
		}
		public function tailVaginaCapacity(): Number {
			return tailCuntCapacity();
		}
		public function tailCuntCapacity(): Number {
			if (!hasTailCunt()) return 0;
			if (vaginalCapacity(0) > 100) return vaginalCapacity(0);
			else return 100;
		}
		public function hasTail(): Boolean {
			if (tailType != GLOBAL.TYPE_HUMAN) return true;
			return false;
		}
		public function isBald(): Boolean {
			return (hairLength <= 0);
		}
		public function hasHair(): Boolean {
			return (hairLength > 0);
		}
		public function hasSockRoom(): Boolean {
			var index: int = cockTotal();
			while (index > 0) {
				index--;
				if (cocks[index].sock == "") return true;
			}
			return false
		}
		public function hasSock(arg: String = ""): Boolean {
			var index: int = cockTotal();
			while (index > 0) {
				index--;
				if (cocks[index].sock != "") {
					if (arg == "" || cocks[index].sock == arg) return true;
				}
			}
			return false
		}
		public function canAutoFellate(arg: int = 0): Boolean {
			if (!hasCock()) return false;
			if (arg >= 0) {
				if (arg >= cocks.length) return false;
				return (cocks[arg].cLength() >= 1 / 6 && (hasCockFlag(GLOBAL.FLAG_PREHENSILE, arg) || cocks[arg].cLength() / tallness <= 1 / 3) && genitalLocation() <= 1);
			}
			//Negative is code for see if any can.
			else {
				for (var x: int = 0; x < cocks.length; x++) {
					if (cocks[x].cLength() >= 1 / 6 && (hasCockFlag(GLOBAL.FLAG_PREHENSILE, x) || cocks[x].cLength() / tallness <= 1 / 3) && genitalLocation() <= 1)
						return true;
				}
				return false;
			}
		}
		public function canSelfSuck(arg: int = 0): Boolean {
			return canAutoFellate(arg);
		}
		public function aCockToSuck(): int {
			var choices: Array = new Array();
			for (var x: int = 0; x < cocks.length; x++) {
				if (cocks[x].cLength() >= 1 / 6 && (hasCockFlag(GLOBAL.FLAG_PREHENSILE, x) || cocks[x].cLength() / tallness <= 1 / 3) && genitalLocation() <= 1)
					choices[choices.length] = x;
			}
			if (choices.length == 0) return 0;
			else return choices[this.rand(choices.length)];
		}
		//Change cunt type!
		public function shiftVagina(slot:int = 0, type:int = 0): void {
			if (slot + 1 > vaginas.length) return;
			else if (slot < 0) return;

			//Set type
			vaginas[slot].type = type;

			//Clear flags
			vaginas[slot].clearFlags();

			//Add bonus flags and shit.
			if (type == GLOBAL.TYPE_EQUINE) {
				vaginas[slot].clits = 1;
				vaginas[slot].vaginaColor = "black";
				vaginas[slot].minLooseness = 2;
			}
			if (type == GLOBAL.TYPE_HUMAN) {
				vaginas[slot].clits = 1;
				vaginas[slot].vaginaColor = "pink";
			}
			if (type == GLOBAL.TYPE_BEE)
			{
				vaginas[slot].clits = 1;
				vaginas[slot].vaginaColor = "black and gold";
			}
		}
		//Change cock type
		public function shiftCock(slot: int = 0, type: int = -1): void {
			if (type == -1) // check if type was not passed, and if so, override with EQUINE
				type = GLOBAL.TYPE_EQUINE;
			if (slot + 1 > cocks.length) return;
			else if (slot < 0) return;

			//Set type
			cocks[slot].cType = type;

			//Clear flags
			cocks[slot].clearFlags();

			//Add bonus flags and shit.
			if (type == GLOBAL.TYPE_CANINE || type == GLOBAL.TYPE_VULPINE) {
				cocks[slot].knotMultiplier = 1.25;
				cocks[slot].cockColor = "bright red";
				cocks[slot].addFlag(GLOBAL.FLAG_TAPERED);
				cocks[slot].addFlag(GLOBAL.FLAG_KNOTTED);
				cocks[slot].addFlag(GLOBAL.FLAG_SHEATHED);
			}
			if (type == GLOBAL.TYPE_EQUINE) {
				cocks[slot].knotMultiplier = 1;
				if(rand(3) == 0) cocks[slot].cockColor = "black";
				else if(rand(3) == 0) cocks[slot].cockColor = "mottled pink and black";
				else cocks[slot].cockColor = "pink";
				cocks[slot].addFlag(GLOBAL.FLAG_BLUNT);
				cocks[slot].addFlag(GLOBAL.FLAG_FLARED);
				cocks[slot].addFlag(GLOBAL.FLAG_SHEATHED);
			}
			if (type == GLOBAL.TYPE_BEE) {
				if(rand(2) == 0) cocks[slot].cockColor = "black";
				else cocks[slot].cockColor = "amber";
				cocks[slot].knotMultiplier = 1;
				cocks[slot].addFlag(GLOBAL.FLAG_SMOOTH);
				cocks[slot].addFlag(GLOBAL.FLAG_FORESKINNED);
			}
			if (type == GLOBAL.TYPE_NAGA) {
				cocks[slot].cockColor = "purple";
				cocks[slot].knotMultiplier = 1;
				cocks[slot].addFlag(GLOBAL.FLAG_SMOOTH);
				cocks[slot].addFlag(GLOBAL.FLAG_TAPERED);
			}
		}
		//PC can fly?
		public function canFly(): Boolean {
			//web also makes false!
			if (hasStatusEffect("Web")) return false;
			if (wingType == GLOBAL.TYPE_BEE) return true;
			return false;
		}
		public function hasWings(): Boolean {
			return (wingType > 0);
		}
		//check for vagoo
		public function hasVagina(hole: int = 0): Boolean {
			if (vaginas.length > hole) return true;
			return false;
		}
		public function hasVaginaType(type: Number = 0): Boolean {
			if (vaginas.length == 0) return false;
			for (var x: int = 0; x < vaginas.length; x++) {
				if (vaginas[x].type == type) return true;
			}
			return false;
		}
		public function hasVirginVagina(): Boolean {
			return (vaginas.length > 0 && vaginalVirgin);
		}
		public function hasVirginCock(): Boolean {
			return (cocks.length > 0 && cockVirgin);
		}
		public function mfn(male: String, female: String, neuter: String): String {
			//1/2 facial
			var weighting: Number = femininity;
			//Tits count up to their rating for femininity
			if (biggestTitSize() >= 1) {
				trace("boobs confirmed");
				if (biggestTitSize() * 3 > 50) weighting += 50;
				else weighting += biggestTitSize() * 3;
			}
			//Flat chest + 20 masculine
			else if (biggestTitSize() == 0) {
				trace("no boobs confirmed");
				weighting -= 20;
			}
			//Hips give small boost
			if (hipRating() >= 6) weighting += hipRating() * 1.5;
			else weighting -= (6 - hipRating()) * 3;
			if (hairLength > 8) weighting += (hairLength - 7) * 1.5;
			else weighting -= (8 - hairLength) * 1.5;
			if (tone > 70) weighting -= 10;
			if (tone < 30) weighting += 10;
			if (lipRating() > 1) weighting += lipRating() * 3;
			if (hasBeard()) weighting -= 100;
			trace("Femininity Rating = " + weighting);
			//Neuters first!
			if (neuter != "") {
				if (weighting >= 45 && weighting <= 55 || hasStatusEffect("Force It Gender")) return neuter;
				else if (weighting < 45) return male;
				else return female;
			} else {
				if (weighting <= 49) return male;
				else return female;
			}

		}
		public function mf(male: String, female: String): String {
			return mfn(male, female, "");
		}
		public function rawmfn(male: String, female: String, neuter: String): String {
			if (!hasCock() && !hasVagina()) return neuter;
			else return rawmf(male, female);
		}
		public function rawmf(male: String, female: String): String {
			if (!hasVagina()) return male;
			else return female;
		}
		//Create a cock
		public function createCock(clength: Number = 5.5, cthickness: Number = 1): Boolean {
			if (cocks.length >= 10) return false;
			var newCock = new CockClass();
			cocks.push(newCock);
			cocks[cocks.length - 1].cThicknessRatioRaw = cthickness;
			cocks[cocks.length - 1].cLengthRaw = clength;
			return true;
		}
		public function createCockUnlocked(numCocks:int = 1):Boolean
		{
			return true;
		}
		public function createCockLockedMessage():String
		{
			return "";
		}
		
		//create vagoo
		public function createVagina(): Boolean {
			if (vaginas.length >= 3) return false;
			var newVagina = new VaginaClass();
			vaginas.push(newVagina);
			return true;
		}
		public function createVaginaUnlocked(numVag:int = 1):Boolean
		{
			return true;
		}
		public function createVaginaLockedMessage():String
		{
			return "";
		}
		
		//create a row of breasts
		public function createBreastRow(): Boolean {
			if (breastRows.length >= 10) return false;
			var newBreastRow = new BreastRowClass();
			breastRows.push(newBreastRow);
			return true;
		}
		public function createBreastRowUnlocked(numRows:int = 1):Boolean
		{
			return true;
		}
		public function createBreastRowsLockedMessage():String
		{
			return "";
		}
		
		public function removeJunk(array, arraySpot, totalRemoved): void {
			//Various Errors preventing action
			if (arraySpot < 0 || totalRemoved <= 0) {
				return;
			}
			if (array.length == 0) {
				//trace("ERROR: removeCock called but cocks do not exist.");
				return;
			}
			if (arraySpot > cocks.length - 1) {
				//trace("ERROR: removeCock failed - array location is beyond the bounds of the array.");
			} else {
				array.splice(arraySpot, totalRemoved);
				if (array == cocks) trace("Attempted to remove " + totalRemoved + " spots from cocks.");
				else if (array == vaginas) trace("Attempted to remove " + totalRemoved + " spots from vaginas.");
				else if (array == breastRows) trace("Attempted to remove " + totalRemoved + " spots from breastRows.");
			}
		}
		//Remove cocks
		public function removeCocks(): void {
			while (hasCock()) {
				removeCock(0, 1);
			}
		}
		public function removeCocksUnlocked():Boolean 
		{
			if (this.hasStatusEffect("Mimbrane Cock")) return false;
			return true;
		}
		public function removeCocksLockedMessage():String 
		{
			if (this.hasStatusEffect("Mimbrane Cock")) return "The Mimbrane surrounding your " + cockDescript(0) + " suddenly bursts to life and squeezes your dick for all it’s worth. Seems the parasite’s efforts are keeping you from losing your cock entirely.";
			return "";
		}
		
		//Remove cock
		public function removeCock(arraySpot, totalRemoved): void {
			removeJunk(cocks, arraySpot, totalRemoved);
		}
		public function removeCockUnlocked(arraySpot:int = 0, totalRemoved:int = 1):Boolean
		{
			if (cocks.length == 1 && this.hasStatusEffect("Mimbrane Cock")) return false;
			return true;
		}
		public function removeCockLockedMessage():String
		{
			if (cocks.length == 1 && this.hasStatusEffect("Mimbrane Cock")) return "The Mimbrane surrounding your " + cockDescript(0) + " suddenly bursts to life and squeezes your dick for all it’s worth. Seems the parasite’s efforts are keeping you from losing your cock entirely.";
			return "";
		}
		
		//Remove vaginas
		public function removeVaginas(): void {
			while (hasVagina()) {
				removeVagina(0, 1);
			}
		}
		public function removeVaginasUnlocked():Boolean
		{
			if (this.hasStatusEffect("Mimbrane Pussy")) return false;
			return true;
		}
		public function removeVaginasLockedMessage():String
		{
			if (this.hasStatusEffect("Mimbrane Pussy")) return "A powerful stretching overtakes your " + vaginaDescript(0) + ", your Mimbrane doing everything in its power to keep the feminine canyon from vanishing. Seems you won’t be able to get rid of your pussy so long as the parasite is in control of it.";
			return "";
		}

		//Remove vaginas
		public function removeVagina(arraySpot: int = 0, totalRemoved: int = 1): void {
			removeJunk(vaginas, arraySpot, totalRemoved);
		}
		public function removeVaginaUnlocked(arraySpot:int = 0, totalRemoved:int = 1):Boolean
		{
			if (vaginas.length == 1 && this.hasStatusEffect("Mimbrane Pussy")) return false;
			return true;
		}
		public function removeVaginaLockedMessage():String
		{
			if (vaginas.length == 1 && this.hasStatusEffect("Mimbrane Pussy")) return "A powerful stretching overtakes your " + vaginaDescript(0) + ", your Mimbrane doing everything in its power to keep the feminine canyon from vanishing. Seems you won’t be able to get rid of your pussy so long as the parasite is in control of it.";
			return "";
		}

		//Remove a breast row
		public function removeBreastRow(arraySpot, totalRemoved): void {
			removeJunk(breastRows, arraySpot, totalRemoved);
		}
		public function removeBreastRowUnlocked(arraySpot:int = 0, totalRemoved:int = 1):Boolean
		{
			if (breastRows.length == 1 && this.hasStatusEffect("Mimbrane Boobs")) return false;
			return true;
		}
		public function removeBreastRowLockedMessage():String
		{
			if (breastRows.length == 1 && this.hasStatusEffect("Mimbrane Boobs")) return "Your " + allChestDesc() + " pulls from your body with a tremendous force, resisting the attempt to flatten your girlish curves. The Mimbrane mounds refuse to be deflated, it seems.";
			return "";
		}

		public function race(): String {
			//Temp vars
			var temp: Number = 0;
			var rando: Number = 0;
			//Determine race type:
			var race: String = "human";
			if (horseScore() >= 2) race = "part horse-morph";
			if (ausarScore() >= 2 && race == "human") race = "half-ausar";
			if (kaithritScore() >= 2 && race == "human") race = "half-kaithrit";
			if (zilScore() >= 4) race = "zil";
			if (horseScore() >= 4) race = "horse-morph";
			if (pandaScore() >= 4) race = "panda-morph";
			if (naleenScore() >= 5 && isNaga()) race = "naleen";
			else if (isNaga()) race = "naga";
			return race;
		}
		
		public function isHuman():Boolean
		{
			return race() == "human";
		}
		
		public function isHalfHuman():Boolean
		{
			if (race().indexOf("half-") != -1) return true;
			return false;
		}
		//Placeholders
		public function cowScore():int
		{
			return bovineScore();
		}
		public function bovineScore():int
		{
			return 0;
		}
		public function horseScore(): int
		{
			var counter:int = 0;
			if (earType == GLOBAL.TYPE_EQUINE) counter++;
			if (tailType == GLOBAL.TYPE_EQUINE && hasTailFlag(GLOBAL.FLAG_LONG)) counter++;
			if (faceType == GLOBAL.TYPE_EQUINE) counter++;
			if (armType == GLOBAL.TYPE_EQUINE) counter++;
			if (legType == GLOBAL.TYPE_EQUINE) counter++;
			if (cockTotal(GLOBAL.TYPE_EQUINE) > 0) counter++;
			if (vaginaTotal(GLOBAL.TYPE_EQUINE) > 0) counter++;
			return counter;
		}
		public function pandaScore(): int
		{
			var counter:int = 0;
			if (earType == GLOBAL.TYPE_PANDA) counter++;
			if (tailType == GLOBAL.TYPE_PANDA) counter++;
			if (faceType == GLOBAL.TYPE_PANDA) counter++;
			if (armType == GLOBAL.TYPE_PANDA) counter++;
			if (legType == GLOBAL.TYPE_PANDA) counter++;
			if (thickness >= 65 && counter > 0) counter++;
			if (cockTotal(GLOBAL.TYPE_PANDA) > 0) counter++;
			if (vaginaTotal(GLOBAL.TYPE_PANDA) > 0) counter++;
			return counter;
		}
		public function ausarScore(): int {
			var counter: int = 0;
			if (earType == GLOBAL.TYPE_CANINE) counter++;
			if (tailType == GLOBAL.TYPE_CANINE && hasTailFlag(GLOBAL.FLAG_LONG) && hasTailFlag(GLOBAL.FLAG_FLUFFY) && hasTailFlag(GLOBAL.FLAG_FURRED)) counter++;
			if (faceType == GLOBAL.TYPE_HUMAN && counter > 0) counter++;
			if (armType == GLOBAL.TYPE_CANINE) counter++;
			return counter;
		}
		public function kaithritScore(): int {
			var counter: int = 0;
			if (earType == GLOBAL.TYPE_FELINE) counter++;
			if (tailType == GLOBAL.TYPE_FELINE && tailCount == 2) counter++;
			return counter;
		}
		public function zilScore(): int {
			var counter: int = 0;
			if (cockTotal(GLOBAL.TYPE_BEE) > 0) counter++;
			if (hasVagina(GLOBAL.TYPE_BEE)) counter++;
			if (armType == GLOBAL.TYPE_BEE) counter++;
			if (legType == GLOBAL.TYPE_BEE && legCount == 2) counter++;
			if (wingType == GLOBAL.TYPE_SMALLBEE || wingType == GLOBAL.TYPE_BEE) counter++;
			if (tailType == GLOBAL.TYPE_BEE && tailCount > 0) counter++;
			if (faceType == GLOBAL.TYPE_HUMAN && counter > 0) counter++;
			return counter;
		}
		public function naleenScore(): int {
			var counter: int = 0;
			if (isNaga()) counter += 2;
			if (faceType == GLOBAL.TYPE_NALEEN_FACE) counter++;
			if (armType == GLOBAL.TYPE_FELINE) counter++;
			if (earType == GLOBAL.TYPE_FELINE) counter++;
			if (hasStatusEffect("Genital Slit")) counter++;
			if (hasVagina(GLOBAL.TYPE_NAGA)) counter++;
			if (cockTotal(GLOBAL.TYPE_NAGA) > 0) counter++;
			if (skinType == GLOBAL.SKIN_TYPE_FUR && counter > 0) counter++;
			if (armType == GLOBAL.TYPE_FELINE && counter > 0) counter++;
			return counter;
		}
		public function sackDescript(forceAdjectives: Boolean = false, adjectives: Boolean = true): String {
			var desc: String = "";
			if ((adjectives && this.rand(3) == 0) || forceAdjectives) {
				if (ballFullness <= 0) desc += "painfully empty ";
				else if (ballFullness <= 20) desc += "empty ";
				else if (ballFullness >= 80 && ballFullness <= 100) desc += "mostly full ";
				else if (ballFullness > 100) {
					var temp: int = this.rand(5);
					if (temp == 0) desc += "full ";
					else if (temp == 1) desc += "sloshing ";
					else if (temp == 2) desc += "stuffed ";
					else if (temp == 3) desc += "bloated ";
					else desc += "cum-packed ";
				}
			}
			if (balls == 0) return "prostate";
			temp = this.rand(2);
			if (temp == 0) desc += "scrotum";
			if (temp == 1) desc += "sack";
			return desc;
		}
		public function cockClit(number: int = 0): String {
			if (hasCock() && number >= 0 && number < cockTotal()) return cockDescript(number);
			else return clitDescript();
		}
		public function sheathDescript(arg: Number = 0): String {
			if (hasSheath(arg)) return "sheath";
			else return "base";
		}
		public function knotDescript(arg: Number): String {
			if (hasKnot(arg)) return "knot";
			else return "base";
		}
		public function chestDesc(): String {
			if (biggestTitSize() < 1) return "chest";
			else return biggestBreastDescript();
		}
		public function allChestDesc(): String {
			if (biggestTitSize() < 1) return "chest";
			else return allBreastsDescript();
		}
		public function eachCock(): String {
			var desc: String = "";
			if (totalCocks() > 1) desc += "each of ";
			desc += "your " + cocksDescript();
			return desc;
		}
		public function oneCock(): String {
			var desc: String = "";
			if (totalCocks() > 1) desc += "one of ";
			desc += "your " + cocksDescript();
			return desc;
		}
		public function ballsDescript(forceCount: Boolean = false, forceSize: Boolean = false, forceSingular: Boolean = false): String {
			if (balls == 0) return "prostate";
			var descripted: int = 0;
			var rando: Number = 0;
			var desc: String = "";
			if (hasStatusEffect("Uniball") < 0 && (this.rand(4) == 0 || forceCount) && !forceSingular) {
				if (balls == 1) {
					rando = this.rand(4);
					if (rando == 0) desc += "single ";
					if (rando == 1) desc += "solitary ";
					if (rando == 2) desc += "lone ";
					if (rando == 3) desc += "individual ";
				}
				if (balls == 2) {
					rando = this.rand(3);
					if (rando == 0) desc += "pair of ";
					if (rando == 1) desc += "two ";
					if (rando == 2) desc += "two ";
				}
				if (balls == 3) {
					rando = this.rand(3);
					if (rando == 0) desc += "three ";
					if (rando == 1) desc += "triple ";
					if (rando == 2) desc += "trio of ";
				}
				if (balls == 4) {
					rando = this.rand(3);
					if (rando == 0) desc += "quartette of ";
					if (rando == 1) desc += "four ";
					if (rando == 2) desc += "four ";
				}
			}
			//size!
			if (ballSize() > 1 && (this.rand(3) <= 1 || forceSize)) {
				if (descripted > 0) desc += ", ";
				if (ballDiameter() <= 1) {}
				else if (ballDiameter() < 2) desc += "large";
				else if (ballDiameter() < 3) desc += "baseball-sized";
				else if (ballDiameter() < 4) desc += "apple-sized";
				else if (ballDiameter() < 5) desc += "grapefruit-sized";
				else if (ballDiameter() < 7) desc += "cantaloupe-sized";
				else if (ballDiameter() < 9) desc += "soccerball-sized";
				else if (ballDiameter() < 12) desc += "basketball-sized";
				else if (ballDiameter() < 15) desc += "watermelon-sized";
				else if (ballDiameter() < 18) desc += "beachball-sized";
				else desc += "hideously swollen and oversized";
				if (ballSize() > 1) descripted++;
			}
			//Uniball
			if (hasStatusEffect("Uniball") && this.rand(3) == 0) {
				if (descripted > 0) desc += ", ";
				rando == this.rand(4);
				if (rando == 0) desc += "tightly-compressed";
				else if (rando == 1) desc += "snug";
				else if (rando == 2) desc += "cute";
				else if (rando == 3) desc += "pleasantly squeezed";
				else desc += "compressed-together";
				descripted++;
			}
			//Descriptive
			if (ballFullness >= 100 && this.rand(3) == 0 && !forceSize) {
				if (descripted > 0) desc += ", ";
				rando = this.rand(3);
				if (rando == 0) desc += "overflowing";
				else if (rando == 1) desc += "swollen";
				else desc += "practically sloshing";
				descripted++;
			} else if (ballFullness >= 80 && this.rand(3) == 0 && !forceSize) {
				if (descripted > 0) desc += ", ";
				rando = this.rand(3);
				if (rando == 0) desc += "full";
				else if (rando == 1) desc += "heavy";
				else desc += "cum-engorged";
				descripted++;
			}
			//lusty
			else if (lust() > 90 && !descripted && this.rand(2) == 0 && !forceSize) {
				if (descripted > 0) desc += ", ";
				rando = this.rand(6);
				if (rando == 0) desc += "eager";
				else if (rando == 1) desc += "trembling";
				else if (rando == 2) desc += "needy";
				else if (rando == 3) desc += "desperate";
				else if (rando == 4) desc += "throbbing";
				else if (rando == 5) desc += "quaking";
				else desc += "heated";
				descripted++;
			}
			if (descripted) desc += " ";
			rando = this.rand(9);
			if (rando < 4) {
				if (balls == 4 && this.rand(2) == 0) desc += "quad";
				else desc += "ball";
			}
			if (rando >= 4 && rando < 6) desc += "testicle";
			if (rando == 6) desc += "teste";
			if (rando == 7) desc += "gonad";
			if (rando == 8) desc += "nut";
			if (balls > 0 || !forceSingular) desc += "s";
			return desc;
		}
		public function ballDescript(forceCount: Boolean = false, forcedSize: Boolean = false): String {
			return ballsDescript(forceCount, forcedSize, true);
		}
		public function assholeDescript(): String {
			var desc: String = "";
			var rando: Number = 0;
			var descripted: Number = 0;
			//66% wetness description
			if (this.rand(3) <= 1 && ass.wetness() >= 2) {
				if (ass.wetness() == 2) {
					if (this.rand(2) == 0) desc += "moist";
					else desc += "lubricated";
				} else if (ass.wetness() == 3) {
					if (this.rand(2) == 0) desc += "slimy";
					else desc += "slick";
				} else if (ass.wetness() == 4) {
					if (this.rand(2) == 0) desc += "lube-drooling";
					else desc += "soaked";
				} else if (ass.wetness() == 5) {
					if (this.rand(2) == 0) desc += "slime-drooling";
					else desc += "immaculately lubricated";
				}
				descripted++;
			}
			//25% tightness desc
			if (this.rand(4) == 0 || (ass.looseness() <= 1 && this.rand(4) <= 2)) {
				if (descripted > 0) desc += ", ";
				if (analVirgin && ass.hymen) {
					if (this.rand(3) == 0) desc += "virgin";
					else if (this.rand(2) == 0) desc += "unspoiled";
					else desc += "unclaimed";
				} else if (ass.looseness() == 1) {
					if (this.rand(2) == 0) desc += "tight";
					else desc += "narrow";
				} else if (ass.looseness() == 2) {
					if (this.rand(2) == 0) desc += "pliant";
					else desc += "supple";
				} else if (ass.looseness() == 3) {
					if (this.rand(2) == 0) desc += "loose";
					else desc += "welcoming";
				} else if (ass.looseness() == 4) {
					if (this.rand(2) == 0) desc += "stretched";
					else desc += "broad";
				} else if (ass.looseness() == 5) {
					if (this.rand(3) == 0) desc += "gaping";
					else if (this.rand(2) == 0) desc += "wide-open";
					else desc += "expansive";
				}
				descripted++;
			}
			if (descripted > 0) desc += " ";
			//Butt descriptor
			rando = this.rand(18);
			if (rando <= 2) desc += "ass";
			else if (rando <= 5) desc += "anus";
			else if (rando <= 7) desc += "pucker";
			else if (rando <= 10) desc += "asshole";
			else if (rando == 11) desc += "bum";
			else if (rando == 12) desc += "butthole";
			else if (rando <= 13) desc += "sphincter";
			else if (rando <= 15) desc += "backdoor";
			else if (rando <= 17) {
				if (tailType > 0) desc += "tailhole";
				else desc += "butthole";
			}
			return desc;
		}
		public function hipDescript(plural: Boolean = false): String {
			var desc: String = "";
			var rando: Number = 0;
			if (hipRating() <= 1) {
				if (thickness > 70) {
					rando = this.rand(3);
					if (rando == 0) desc = "tiny ";
					else if (rando == 1) desc = "narrow ";
					else if (rando == 2) desc = "boyish ";
				}
				//Normal
				else if (thickness >= 30) {
					if (this.rand(2) == 0) desc = "boyish ";
					else desc = "tiny ";
				}
				//Uberthin
				else {
					rando = this.rand(3);
					if (rando == 0) desc = "tiny ";
					else if (rando == 1) desc = "narrow ";
					else if (rando == 2) desc = "boyish ";
				}
			} else if (hipRating() < 4) {
				rando = this.rand(3);
				if (rando == 0) desc = "slender ";
				if (rando == 1) desc = "narrow ";
				if (rando == 2) desc = "thin ";
				if (thickness < 30) {
					if (this.rand(2) == 0) desc = "slightly-flared ";
					else desc = "curved ";
				}
			} else if (hipRating() < 6) {
				rando = this.rand(2);
				if (rando == 1) desc = "well-formed ";
				if (rando == 2) desc = "pleasant ";
				if (thickness < 30) {
					if (this.rand(2) == 0) desc = "flared ";
					else desc = "curvy ";
				}
			} else if (hipRating() < 10) {
				rando = this.rand(3);
				if (rando == 0) desc = "ample ";
				if (rando == 1) desc = "noticeable ";
				if (rando == 2) desc = "girly ";
				if (thickness < 30) {
					if (this.rand(2) == 0) desc = "flared ";
					else desc = "waspish ";
				}
			} else if (hipRating() < 15) {
				rando = this.rand(3);
				if (rando == 0) desc = "flared ";
				if (rando == 1) desc = "curvy ";
				if (rando == 2) desc = "wide ";
				if (thickness < 30) {
					if (this.rand(2) == 0) desc = "flared ";
					else desc = "waspish ";
				}
			} else if (hipRating() < 20) {
				if(femininity > 50 || hasVagina()) rando = this.rand(3);
				else rando = 0;
				if (thickness < 40) {
					if (this.rand(2) == 0) desc = "flared, ";
					else desc = "waspish, ";
				}
				if (rando == 0) desc += "voluptuous ";
				if (rando == 1) desc += "fertile ";
				if (rando == 2) desc += "child-bearing ";
				
			} else if (hipRating() >= 20) {
				if(femininity > 50 || hasVagina()) rando = this.rand(3);
				else rando = rand(2);
				if (thickness < 40) {
					if (this.rand(2) == 0) desc = "flaring, ";
					else desc = "incredibly waspish, ";
				}
				if (rando == 0) desc += "inhumanly-wide ";
				if (rando == 1) desc += "cow-like ";
				if (rando == 2) desc += "broodmother-sized ";
			}
			//Taurs
			if (isTaur() && this.rand(3) == 0) desc += "flank";
			//Non taurs or taurs who didn't roll flanks
			else {
				rando = this.rand(2);
				if (rando == 0) desc += "hip";
				if (rando == 1) desc += "thigh";
			}
			if (plural) desc = pluralize(desc);
			return desc;
		}
		public function thighDescript():String {
			return "thigh";
		}
		public function thighsDescript():String {
			return pluralize(thighDescript());
		}
		public function hipsDescript(): String {
			return hipDescript(true);
		}
		public function buttDescript(): String {
			var desc: String = "";
			var rando: Number = 0;
			if (buttRating() <= 1) {
				if (tone >= 60) desc += "incredibly tight, perky ";
				else {
					if (this.rand(2) == 0) desc = "tiny";
					else if (this.rand(2) == 0) desc = "very small";
					else desc = "dainty";
					//Soft PC's buns!
					if (tone <= 30 && this.rand(3) == 0) desc += " yet soft";
					desc += " ";
				}
			} else if (buttRating() < 4) {
				if (tone >= 65) {
					rando = this.rand(6);
					if (rando == 0) desc = "perky, muscular ";
					else if (rando == 1) desc = "tight, toned ";
					else if (rando == 2) desc = "firm ";
					else if (rando == 3) desc = "compact, muscular ";
					else if (rando == 4) desc = "tight ";
					else if (rando == 5) desc = "muscular, toned ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(4);
					if (rando == 0) desc = "tight ";
					if (rando == 1) desc = "firm ";
					if (rando == 2) desc = "compact ";
					if (rando == 3) desc = "petite ";
				}
				//FLABBAH
				else {
					rando = this.rand(7);
					if (rando == 0) desc = "small, heart-shaped ";
					else if (rando == 1) desc = "soft, compact ";
					else if (rando == 2) desc = "soft, heart-shaped ";
					else if (rando == 3) desc = "small, cushy ";
					else if (rando == 4) desc = "small ";
					else if (rando == 5) desc = "petite ";
					else if (rando == 6) desc = "snug ";
				}
			} else if (buttRating() < 6) {
				//TOIGHT LIKE A TIGER
				if (tone >= 65) {
					rando = this.rand(6);
					if (rando == 0) desc = "nicely muscled ";
					else if (rando == 1) desc = "nice, toned ";
					else if (rando == 2) desc = "muscly ";
					else if (rando == 3) desc = "nice toned ";
					else if (rando == 4) desc = "toned ";
					else if (rando == 5) desc = "fair ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(2);
					if (rando == 0) desc = "nice ";
					if (rando == 1) desc = "fair ";
				}
				//FLABBAH
				else {
					rando = this.rand(5);
					if (rando == 0) desc = "nice, cushiony ";
					else if (rando == 1) desc = "soft ";
					else if (rando == 2) desc = "nicely-rounded, heart-shaped ";
					else if (rando == 3) desc = "cushy ";
					else if (rando == 4) desc = "soft, squeezable ";
				}
			} else if (buttRating() < 8) {
				//TOIGHT LIKE A TIGER
				if (tone >= 65) {
					rando = this.rand(7);
					if (rando == 0) desc = "full, toned ";
					else if (rando == 1) return "muscly handful of ass";
					else if (rando == 2) desc = "shapely, toned ";
					else if (rando == 3) desc = "muscular, hand-filling ";
					else if (rando == 4) desc = "shapely, chiseled ";
					else if (rando == 5) desc = "full ";
					else if (rando == 6) desc = "chiseled ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(4);
					if (rando == 0) return "handful of ass";
					if (rando == 1) desc = "full ";
					if (rando == 2) desc = "shapely ";
					if (rando == 3) desc = "hand-filling ";
				}
				//FLABBAH
				else {
					rando = this.rand(8);
					if (rando == 0) desc = "somewhat jiggly ";
					else if (rando == 1) desc = "soft, hand-filling ";
					else if (rando == 2) desc = "cushiony, full ";
					else if (rando == 3) return "supple, handful of ass";
					else if (rando == 4) desc = "plush, shapely ";
					else if (rando == 5) desc = "full ";
					else if (rando == 6) desc = "soft, shapely ";
					else if (rando == 7) desc = "rounded, spongy ";
				}
			} else if (buttRating() < 10) {
				//TOIGHT LIKE A TIGER
				if (tone >= 65) {
					rando = this.rand(9);
					if (rando == 0) desc = "large, muscular ";
					else if (rando == 1) desc = "substantial, toned ";
					else if (rando == 2) desc = "big-but-tight ";
					else if (rando == 3) desc = "squeezable, toned ";
					else if (rando == 4) desc = "large, brawny ";
					else if (rando == 5) desc = "big-but-fit ";
					else if (rando == 6) desc = "powerful, squeezable ";
					else if (rando == 7) desc = "large ";
					else if (rando == 8) desc = "callipygean ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(10);
					if (rando <= 2) desc = "squeezable ";
					else if (rando <= 6) desc = "large ";
					else if (rando <= 8) desc = "substantial ";
					else desc = "callipygean ";
				}
				//FLABBAH
				else {
					rando = this.rand(10);
					if (rando == 0) desc = "large, bouncy ";
					else if (rando == 1) desc = "soft, eye-catching ";
					else if (rando == 2) desc = "big, slappable ";
					else if (rando == 3) desc = "soft, pinchable ";
					else if (rando == 4) desc = "large, plush ";
					else if (rando == 5) desc = "squeezable ";
					else if (rando == 6) desc = "cushiony ";
					else if (rando == 7) desc = "plush ";
					else if (rando == 8) desc = "pleasantly plump ";
					else if (rando == 9) desc = "callipygean ";
				}
			} else if (buttRating() < 13) {
				//TOIGHT LIKE A TIGER
				if (tone >= 65) {
					rando = this.rand(7);
					if (rando == 0) desc = "thick, muscular ";
					else if (rando == 1) desc = "big, burly ";
					else if (rando == 2) desc = "heavy, powerful ";
					else if (rando == 3) desc = "spacious, muscular ";
					else if (rando == 4) desc = "toned, cloth-straining ";
					else if (rando == 5) desc = "thick ";
					else if (rando == 6) desc = "thick, strong ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(4);
					if (rando == 0) desc = "jiggling ";
					if (rando == 1) desc = "spacious ";
					if (rando == 2) desc = "heavy ";
					if (rando == 3) desc = "cloth-straining ";
				}
				//FLABBAH
				else {
					rando = this.rand(9);
					if (rando == 0) desc = "super-soft, jiggling ";
					else if (rando == 1) desc = "spacious, cushy ";
					else if (rando == 2) desc = "plush, cloth-straining ";
					else if (rando == 3) desc = "squeezable, over-sized ";
					else if (rando == 4) desc = "spacious ";
					else if (rando == 5) desc = "heavy, cushiony ";
					else if (rando == 6) desc = "slappable, thick ";
					else if (rando == 7) desc = "jiggling ";
					else if (rando == 8) desc = "spacious ";
					else if (rando == 9) desc = "soft, plump ";
				}
			} else if (buttRating() < 16) {
				//TOIGHT LIKE A TIGER
				if (tone >= 65) {
					rando = this.rand(8);
					if (rando == 0) desc = "expansive, muscled ";
					else if (rando == 1) desc = "voluminous, rippling ";
					else if (rando == 2) desc = "generous, powerful ";
					else if (rando == 3) desc = "big, burly ";
					else if (rando == 4) desc = "well-built, voluminous ";
					else if (rando == 5) desc = "powerful ";
					else if (rando == 6) desc = "muscular ";
					else if (rando == 7) desc = "powerful, expansive ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(4);
					if (rando == 0) desc = "expansive ";
					if (rando == 1) desc = "generous ";
					if (rando == 2) desc = "voluminous ";
					if (rando == 3) desc = "wide ";
				}
				//FLABBAH
				else {
					rando = this.rand(11);
					if (rando == 0) desc = "pillow-like ";
					else if (rando == 1) desc = "generous, cushiony ";
					else if (rando == 2) desc = "wide, plush ";
					else if (rando == 3) desc = "soft, generous ";
					else if (rando == 4) desc = "expansive, squeezable ";
					else if (rando == 5) desc = "slappable ";
					else if (rando == 6) desc = "thickly-padded ";
					else if (rando == 7) desc = "wide, jiggling ";
					else if (rando == 8) desc = "wide ";
					else if (rando == 9) desc = "voluminous ";
					else if (rando == 10) desc = "soft, padded ";
				}
			} else if (buttRating() < 20) {
				if (tone >= 65) {
					rando = this.rand(6);
					if (rando == 0) desc = "huge, toned ";
					else if (rando == 1) desc = "vast, muscular ";
					else if (rando == 2) desc = "vast, well-built ";
					else if (rando == 3) desc = "huge, muscular ";
					else if (rando == 4) desc = "strong, immense ";
					else if (rando == 5) desc = "muscle-bound ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(5);
					if (rando == 0) desc = "huge ";
					if (rando == 1) desc = "vast ";
					if (rando == 2) desc = "giant ";
					if (rando == 3) return "jiggling expanse of ass";
					if (rando == 4) return "copious ass-flesh";
				}
				//FLABBAH
				else {
					rando = this.rand(11);
					if (rando == 0) desc = "vast, cushiony ";
					else if (rando == 1) desc = "huge, plump ";
					else if (rando == 2) desc = "expansive, jiggling ";
					else if (rando == 3) desc = "huge, cushiony ";
					else if (rando == 4) desc = "huge, slappable ";
					else if (rando == 5) desc = "seam-bursting ";
					else if (rando == 6) desc = "plush, vast ";
					else if (rando == 7) desc = "giant, slappable ";
					else if (rando == 8) desc = "giant ";
					else if (rando == 9) desc = "huge ";
					else if (rando == 10) desc = "swollen, pillow-like ";
				}
			} else {
				if (tone >= 65) {
					rando = this.rand(7);
					if (rando == 0) desc = "ginormous, muscle-bound ";
					else if (rando == 1) desc = "colossal yet toned ";
					else if (rando == 2) desc = "strong, tremdously large ";
					else if (rando == 3) return "colossal, muscly ass";
					else if (rando == 4) desc = "tremendous, muscled ";
					else if (rando == 5) desc = "ginormous, toned ";
					else if (rando == 6) desc = "colossal, well-defined ";
				}
				//Nondescript
				else if (tone >= 30) {
					rando = this.rand(4);
					if (rando == 0) desc = "ginormous ";
					if (rando == 1) desc = "colossal ";
					if (rando == 2) desc = "tremendous ";
					if (rando == 3) desc = "gigantic ";
				}
				//FLABBAH
				else {
					rando = this.rand(13);
					if (rando == 0) desc = "ginormous, jiggly ";
					else if (rando == 1) desc = "plush, ginormous ";
					else if (rando == 2) desc = "seam-destroying ";
					else if (rando == 3) desc = "tremendous, rounded ";
					else if (rando == 4) desc = "bouncy, colossal ";
					else if (rando == 5) desc = "thong-devouring ";
					else if (rando == 6) desc = "tremendous, thickly padded ";
					else if (rando == 7) desc = "ginormous, slappable ";
					else if (rando == 8) desc = "gigantic, rippling ";
					else if (rando == 9) desc = "gigantic ";
					else if (rando == 10) desc = "ginormous ";
					else if (rando == 11) desc = "colossal ";
					else if (rando == 12) desc = "tremendous ";
				}
			}
			rando = this.rand(21);
			if (rando <= 4) desc += "butt";
			else if (rando <= 9) desc += "ass";
			else if (rando <= 11) desc += "backside";
			else if (rando == 12) {
				if (buttRating() >= 10) desc += "booty";
				else desc += "derriere";
			} else if (rando == 13) desc += "rump";
			else if (rando == 14) desc += "bottom";
			else if (rando == 15) desc += "behind";
			else if (rando == 16) desc += "keister";
			else if (rando == 17) desc += mf("butt", "tush");
			else if (rando == 18) desc += "rear end";
			else if (rando == 19) desc += "heinie";
			else if (rando == 20) desc += "posterior";
			//if(rando == 2) desc += "cheeks";
			return desc;
		}
		public function nipplesDescript(rowNum = 0, forceLactation:Boolean = false): String {
			return nippleDescript(rowNum, true, forceLactation);
		}
		public function nippleDescript(rowNum: Number = 0, plural: Boolean = false, forceLactation:Boolean = false): String {
			//DEBUG SHIT!
			if (rowNum > (breastRows.length - 1)) return "<B>Error: Invalid breastRows (" + rowNum + ") passed to nippleDescript()</b>";
			if (rowNum < 0) return "<B>Error: Invalid breastRows (" + rowNum + ") passed to nippleDescript()</b>";
			var descripted: Number = 0;
			var description: String = "";
			var rando: Number = 0;
			//Size descriptors 25% chance
			if (this.rand(4) == 0 && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_FUCKABLE && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_FLAT && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_INVERTED) {
				//TINAHHHH
				if (nippleLength(rowNum) < .25) {
					rando = this.rand(3);
					if (rando == 0) description += "tiny";
					if (rando == 1) description += "itty-bitty";
					if (rando == 2) description += "teeny-tiny";
					if (rando == 3) description += "dainty";
				}
				//Prominant
				else if (nippleLength(rowNum) < 1) {
					rando = this.rand(5);
					if (rando == 0) description += "prominent";
					if (rando == 1) description += "pencil eraser-sized";
					if (rando == 2) description += "eye-catching";
					if (rando == 3) description += "pronounced";
					if (rando == 4) description += "striking";
				}
				//Big 'uns
				else if (nippleLength(rowNum) < 2) {
					rando = this.rand(4);
					if (rando == 0) description += "forwards-jutting";
					if (rando == 1) description += "over-sized";
					if (rando == 2) description += "fleshy";
					if (rando == 3) description += "large protruding";
				}
				//'Uge
				else if (nippleLength(rowNum) < 3.2) {
					rando = this.rand(5);
					if (rando == 0) description += "elongated";
					if (rando == 1) description += "massive";
					if (rando == 2) description += "awkward";
					if (rando == 3) description += "lavish";
					if (rando == 4) description += "hefty";
				}
				//Massive
				else {
					rando = this.rand(5);
					if (rando == 0) description += "bulky";
					if (rando == 1) description += "ponderous";
					if (rando == 2) description += "thumb-sized";
					if (rando == 3) description += "cock-sized";
					if (rando == 4) description += "cow-like";
				}
				descripted++;
			}
			//Milkiness/Arousal/Wetness Descriptors 33% of the time
			if ((this.rand(3) == 0 || forceLactation) && descripted < 2) {
				//Fuckable chance first!
				if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_FUCKABLE) {
					if (descripted > 0) description += ", ";
					//Fuckable and lactating?
					if (isLactating()) {
						rando = this.rand(5);
						if (rando <= 3) description += "lactating";
						else description += "lactation-slicked";
					}
					//Just fuckable
					else {
						rando = this.rand(9);
						if (rando == 0) description += "wet";
						if (rando == 1) description += "mutated";
						if (rando == 2) description += "slimy";
						if (rando == 3) description += "damp";
						if (rando == 4) description += "moist";
						if (rando == 5) description += "slippery";
						if (rando == 6) description += "oozing";
						if (rando == 7) description += "sloppy";
						if (rando == 8) description += "dewy";
					}
					descripted++;
				}
				//Lipples
				else if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_LIPPLES) {
					if (descripted > 0) description += ", ";
					if (isLactating()) {
						rando = this.rand(5);
						if (rando <= 3) description += "drooling";
						else description += "lactation-slicked";
					}
					//Just fuckable
					else {
						rando = this.rand(4);
						if (rando == 0) description += "puffy";
						if (rando == 1) description += "pouty";
						if (rando == 2) description += "parted";
						if (rando == 3) description += "luscious";
					}
					descripted++;
				}
				//Dicknipples
				else if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_DICK) {
					if (descripted > 0) description += ", ";
					rando = this.rand(3);
					if (rando == 0) description += "cock-concealing";
					else if (rando == 1) description += "dick-hiding";
					else if (rando == 2) description += "shaft-shrouding";
					descripted++;
				}
				//Flat
				else if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_FLAT) {
					if (descripted > 0) description += ", ";
					rando = this.rand(3);
					if (rando == 0) description += "tipless";
					else if (rando == 1) description += "flat";
					else if (rando == 2) description += "puffy";
					else if (rando == 3) description += "pebbly";
					descripted++;
				}
				//Inverted
				else if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_INVERTED) {
					if (descripted > 0) description += ", ";
					if (rando == 0) description += "inverted";
					descripted++;
				}
				//Just lactating!
				else if (isLactating() && milkFullness > 50) {
					if (descripted > 0) description += ", ";
					//Light lactation
					if (milkRate < 65) {
						rando = this.rand(2);
						if (rando == 0) description += "moistened";
						if (rando == 1) description += "slightly lactating";
					}
					//Moderate lactation
					else if (milkRate <= 85) {
						rando = this.rand(3);
						if (rando == 0) description += "lactating";
						if (rando == 1) description += "milky";
						if (rando == 2) description += "milk-seeping";
					}
					//Heavy lactation
					else {
						rando = this.rand(4);
						if (rando == 0) description += "dripping";
						if (rando == 1) description += "dribbling";
						if (rando == 2) description += "milk-leaking";
						if (rando == 3) description += "drooling";
					}
					descripted++;
				}
			}
			//Possible arousal descriptors
			else if (this.rand(3) == 0 && descripted < 2 && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_FLAT && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_INVERTED && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_LIPPLES && breastRows[rowNum].nippleType != GLOBAL.NIPPLE_TYPE_FUCKABLE) {
				if (lust() > 50 && lust() < 75) {
					if (descripted > 0) description += ", ";
					rando = this.rand(5);
					if (rando == 0) description += "erect";
					if (rando == 1) description += "perky";
					if (rando == 2) description += "erect";
					if (rando == 3) description += "firm";
					if (rando == 4) description += "tender";
					descripted++;
				}
				if (lust() >= 75) {
					if (descripted > 0) description += ", ";
					rando = this.rand(4);
					if (rando == 0) description += "throbbing";
					if (rando == 1) description += "trembling";
					if (rando == 2) description += "needy";
					if (rando == 3) description += "throbbing";
					descripted++;
				}
			}
			if (descripted && this.rand(2) == 0 && nipplesPierced > 0 && rowNum == 0) {
				if (descripted > 0) description += ", ";
				if (nipplesPierced == 5) description += "chained ";
				else description += "pierced ";
				descripted++;
			}
			if (!descripted && skinType == GLOBAL.SKIN_TYPE_GOO) {
				if (descripted > 0) description += ", ";
				rando = this.rand(3);
				if (rando == 0) description += "slime-slick ";
				if (rando == 1) description += "goopy ";
				if (rando == 2) description += "slippery ";
			}
			/*if(!descripted && hasStatusEffect("Black Nipples") >= 0) {
				rando = this.rand(3);
				if(rando == 0) description += "black ";
				else if(rando == 1) description += "ebony ";
				else description += "sable ";
			}*/
			//Nounsssssssss*BOOM*
			if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_FUCKABLE) {
				rando = this.rand(5);
				if (descripted > 0) description += ", ";
				if (rando == 0) description += "penetrable nipple";
				else if (rando == 1) description += "fuckable nip";
				else if (rando == 2) description += "fuckable nipple";
				else if (rando == 3) description += "pliable nipple-cunt";
				else if (rando == 4) description += "stretchy nipple-cunt";
			} else if (breastRows[rowNum].nippleType == GLOBAL.NIPPLE_TYPE_LIPPLES) {
				rando = this.rand(5);
				if (descripted > 0) {
					if (rando > 2) description += ", ";
					else description += " ";
				}
				if (rando <= 1) description += "lipple";
				else if (rando == 2) description += "lip-nipple";
				else if (rando == 3) description += "kissable nipple";
				else if (rando == 4) description += "mouth-like nipple";
			}
			//Normals
			else {
				rando = this.rand(5);
				if (descripted > 0) description += " ";
				if (rando <= 1) description += "nipple";
				if (rando == 2) {
					if (isLactating() && nippleLength(rowNum) >= 1) description += "teat";
					else description += "nipple";
				}
				if (rando == 3) {
					if (isLactating() && nippleLength(rowNum) >= 1) description += "teat";
					else description += "nipple";
				}
				if (rando == 4) description += "bud";
			}
			if (plural) description = pluralize(description);
			return description;
		}
		public function hairDescript(forceLength: Boolean = false, forceColor: Boolean = false): String {
			var descript: String = "";
			var descripted: Number = 0;
			//Bald folks get one-off quick description
			if (hairLength == 0) {
				if (this.rand(2) == 0) descript += "shaved ";
				else descript += "bald ";
				descript += "head";
				return descript;
			}
			//50% odds of adjectives
			if (forceLength || this.rand(2) == 0) {
				if (hairLength < 1) {
					if (this.rand(2) == 0) descript += "close-cropped";
					else descript += "trim";
				} else if (hairLength < 3) descript += "short";
				else if (hairLength < 6) descript += "shaggy";
				else if (hairLength < 10) descript += "moderately long";
				else if (hairLength < 16) {
					if (this.rand(2) == 0) descript += "long";
					else descript += "shoulder-length";
				} else if (hairLength < 26) {
					if(rand(3) == 0) descript += "very long";
					else if(rand(2) == 0) descript += "back-length";
					else descript += "lengthy";
					//Disabled alternate due to weirdness:
					//"long flowing locks, [haircolor] hair"
					//else descript += "long flowing locks";
				} else if (hairLength < tallness / 2) descript += "ass-length";
				else if (hairLength < tallness) descript += "obscenely long";
				else {
					if (this.rand(2) == 0) descript += "floor-length";
					else descript += "floor-dragging";
				}
				descripted++;
			}
			// COLORS
			if (forceColor || this.rand(2) == 0) {
				if (descripted > 0) descript += ", ";
				descript += hairColor;
				descripted++;
			}
			//Mane special stuff.
			if (hasPerk("Mane") && hairLength > 3 && this.rand(2) == 0) {
				//Oddball shit
				if (this.rand(2) == 0 && descripted < 2) {
					if (hairType == GLOBAL.HAIR_TYPE_TRANSPARENT) {
						if (descripted > 0) descript += ", ";
						descript += "transparent";
						descripted++;
					}
				}
				if (descripted > 0) descript += " mane";
				if (hairType == GLOBAL.HAIR_TYPE_FEATHERS) descript += " of feathers";
				if (hairType == GLOBAL.HAIR_TYPE_GOO) descript += " of goo";
				if (hairType == GLOBAL.HAIR_TYPE_TENTACLES) descript += " of tentacles";
			}
			//Not manes
			else {
				//Oddball shit
				if (this.rand(2) == 0 && descripted < 2) {
					if (hairType == GLOBAL.HAIR_TYPE_TRANSPARENT) {
						if (descripted > 0) descript += ", ";
						descript += "transparent";
						descripted++;
					} else if (hairType == GLOBAL.HAIR_TYPE_GOO) {
						if (descripted > 0) descript += ", ";
						descript += "gooey";
						descripted++;
					}
				}
				if (descripted > 0) descript += " ";
				if (hairType == GLOBAL.HAIR_TYPE_TENTACLES && this.rand(2) == 0) descript += "tentacle-hair";
				else if (hairType == GLOBAL.HAIR_TYPE_FEATHERS && this.rand(2) == 0) descript += "plumage";
				else descript += "hair";
			}
			return descript;
		}
		public function hairsDescript(forceLength: Boolean = false, forceColor: Boolean = false): String {
			var descript: String = "";
			var descripted: Number = 0;
			//Bald folks get one-off quick description
			if (hairLength == 0) {
				if (this.rand(2) == 0) descript += "shaved ";
				else descript += "bald ";
				descript += "head";
				return descript;
			}
			//50% odds of adjectives
			if (forceLength || this.rand(2) == 0) {
				if (hairLength < 1) {
					if (this.rand(2) == 0) descript += "close-cropped";
					else descript += "trim";
				} else if (hairLength < 3) descript += "short";
				else if (hairLength < 6) descript += "shaggy";
				else if (hairLength < 10) descript += "moderately long";
				else if (hairLength < 16) {
					if (this.rand(2) == 0) descript += "long";
					else descript += "shoulder-length";
				} else if (hairLength < 26) {
					if (this.rand(2) == 0) descript += "very long";
					else descript += "long flowing locks";
				} else if (hairLength < 40) descript += "ass-length";
				else if (hairLength < tallness) descript += "obscenely long";
				else {
					if (this.rand(2) == 0) descript += "floor-length";
					else descript += "floor-dragging";
				}
				descripted++;
			}
			// COLORS
			if (forceColor || this.rand(2) == 0) {
				if (descripted > 0) descript += ", ";
				descript += hairColor;
				descripted++;
			}
			//Not manes
			//Oddball shit
			if (this.rand(2) == 0 && descripted < 2) {
				if (hairType == GLOBAL.HAIR_TYPE_TRANSPARENT) {
					if (descripted > 0) descript += ", ";
					descript += "transparent";
					descripted++;
				}
			}
			if (descripted > 0) descript += " ";
			if (hairType == GLOBAL.HAIR_TYPE_TENTACLES) descript += "tentacles";
			else if (hairType == GLOBAL.HAIR_TYPE_FEATHERS) descript += "feathers";
			else if (hairType == GLOBAL.HAIR_TYPE_GOO) descript += "locks of goo";
			else descript += "locks";
			return descript;
		}
		public function eachClit(): String {
			if (totalClits() > 1) return "each of your " + pluralize(clitDescript());
			else return "your " + clitDescript();
		}
		public function oneClit(): String {
			if (totalClits() > 1) return "one of your " + pluralize(clitDescript());
			else return "your " + clitDescript();
		}
		public function clitsDescript(): String {
			if (totalClits() > 1) return pluralize(clitDescript());
			else return clitDescript();
		}
		public function clitDescript(pussy: Number = 0): String {
			var descript: String = "";
			var randt: Number = this.rand(10);
			var descripted: Number = 0;
			//Length Adjective - 50% chance
			if (this.rand(3) == 0) {
				//small clits!
				if (clitLength <= .4) {
					if (randt < 3) descript += "tiny";
					else if (randt < 6) descript += "little";
					else if (randt < 8) descript += "petite";
					else if (randt == 8) descript += "diminutive";
					else descript += "miniature";
					descripted++;
				}
				//"average".  
				else if (clitLength < 1) {
					//no size comment
				}
				//Biggies!
				else if (clitLength < 4) {
					if (randt < 4) descript += "large";
					else if (randt < 9) descript += "substantial";
					else descript += "considerable";
					descripted++;
				}
				//'Uge 
				else if (clitLength < 10) {
					if (randt < 2) descript += "dick-sized";
					else if (randt < 4) descript += "phallus-like";
					else if (randt < 6) descript += "cock-like";
					else if (randt < 8) descript += "banana-sized";
					else if (randt == 8) descript += "hulking";
					else descript += "bulky";
					descripted++;
				} else {
					if (randt < 3) descript += "monster";
					else if (randt < 6) descript += "tremendous";
					else if (randt < 8) descript += "colossal";
					else if (randt == 8) descript += "enormous";
					else descript += "oversized";
					descripted++;
				}
			}
			//Descriptive descriptions - 50% chance of being called
			if (this.rand(3) == 0 && descripted < 2) {
				//Elizabeth descriptors
				if (skinType == GLOBAL.SKIN_TYPE_FUR && hasVaginaType(GLOBAL.TYPE_VULPINE) && this.rand(3) <= 1) {
					if (descripted > 0) descript += ", ";
					descript += "foxy ";
					descripted++;
				}
				//Horny descriptors - 75% chance
				else if (lust() > 70 && this.rand(4) < 3 && !descripted) {
					if (descripted > 0) descript += ", ";
					randt = this.rand(3);
					if (randt == 0) descript += "throbbing";
					if (randt == 1) descript += "pulsating";
					if (randt == 2) descript += "hard";
					descripted++;
				}
				//High libido - always use if no other descript
				else if (libido() > 50 && this.rand(3) < 2 && !descripted) {
					if (descripted > 0) descript += ", ";
					randt = this.rand(4);
					if (randt == 0) descript += "insatiable";
					if (randt == 1) descript += "greedy";
					if (randt == 2) descript += "demanding";
					if (randt == 3) descript += "rapacious";
					descripted++;
				}
			}
			if (hasVagina()) {
				if (vaginas[0].clitPierced > 0 && descripted < 2 && this.rand(3) < 2) {
					if (descripted > 0) descript += ", ";
					descript += "pierced";
					descripted++;
				}
			} else return ("ERROR: CLITDESCRIPT WITH NO CLIT");
			//Clit nouns
			if (descripted > 0) descript += " ";
			//HYPHENING SHIT ONTO DOSE NOUNS, YO!
			if (skinType == GLOBAL.SKIN_TYPE_FUR && hasVaginaType(GLOBAL.TYPE_CANINE) && this.rand(2) == 0) descript += "bitch-";
			//Horse descriptors - 50%
			else if (skinType == GLOBAL.SKIN_TYPE_FUR && hasVaginaType(GLOBAL.TYPE_EQUINE) && this.rand(3) <= 0) descript += "mare-";
			randt = this.rand(10);
			if (randt == 0) 
			{
				if(clitLength >= 5) descript += "girl-pole";
				else descript += "clit";
			}
			else if (randt == 1) descript += "clitty";
			else if (randt == 2) descript += "button";
			else if (randt == 3) descript += "pleasure-buzzer";
			else if (randt == 4) descript += "clit";
			else if (randt == 5) descript += "clitty";
			else if (randt == 6) descript += "button";
			else if (randt == 7) descript += "clit";
			else if (randt == 8) descript += "clit";
			else if (randt == 9) descript += "button";
			return descript;
		}
		public function vagOrAss(arg: int = 0): String {
			if (hasVagina()) return vaginaDescript(arg);
			else return assholeDescript();
		}
		//Vaginas + Descript
		public function oneTailVaginaDescript():String
		{
			var buffer:String = "";
			if(tailCount > 1) buffer += "one of ";
			buffer += "your ";
			if(tailCount > 1) buffer += pluralize(tailVaginaDescript());
			else buffer += tailVaginaDescript();
			return buffer;
		}
		public function tailVaginasDescript(forceAdjectives: Boolean = false, adjectives: Boolean = true): String {
			if(tailCount > 1) return pluralize(tailVaginaDescript(forceAdjectives,adjectives));
			else if(tailCount == 1) return tailVaginaDescript(forceAdjectives,adjectives);
			else return "ERROR: TAIL DESCRIPT CALLED WITH NO TAILS PRESENT.";
		}
		public function tailVaginaDescript(forceAdjectives: Boolean = false, adjectives: Boolean = true): String {
			//Vars
			var vag: String = "";
			var descripted: int = 0;
			var temp: int = 0;

			//low chance of size descriptor
			if (((adjectives && this.rand(100) <= 25) || forceAdjectives)) {
				temp = this.rand(10);
				if (temp <= 3) vag += "tight";
				else if (temp <= 5) vag += "clingy";
				else if (temp <= 7) vag += "supple";
				else vag += "velvety-soft";
				descripted++;
			}
			//wetness descript - 30% display rate
			if (descripted < 2 && ((adjectives && this.rand(100) > 70) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				temp = this.rand(17);
				if (temp <= 3) vag += "wet";
				else if (temp <= 5) vag += "sultry";
				else if (temp <= 8) vag += "sweltering";
				else if (temp <= 11) vag += "slippery";
				else if (temp <= 13) vag += "slick";
				else vag += "lube-leaking";
				descripted++;
			}
			//Elasticity references!
			if (descripted < 2 && elasticity >= 1.5 && ((adjectives && this.rand(3) == 0) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				if (elasticity >= 5) {
					temp = this.rand(10);
					if (temp <= 3) vag += "super-stretchy";
					else if (temp <= 7) vag += "incredibly elastic";
					else vag += "powerfully pliable";
				} else {
					temp = this.rand(10);
					if (temp <= 1) vag += "stretchy";
					else if (temp <= 3) vag += "elastic";
					else if (temp <= 5) vag += "pliable";
					else if (temp <= 7) vag += "flexible";
					else vag += "pliant";
				}
				descripted++;
			}
			if (descripted < 2 && skinType == GLOBAL.SKIN_TYPE_GOO && ((adjectives && this.rand(3) == 0) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				if (this.rand(2) == 0) vag += "gooey";
				else vag += "slimy";
				descripted++;
			}
			//50% of time, simple cunt.
			if (this.rand(2) == 0) {
				if (descripted > 0) vag += " ";
				vag += vaginaNoun(tailGenitalArg, true);
			}
			//50% of the time, complex cunt!
			else {
				if (descripted > 0) vag += ", ";
				vag += vaginaNoun(tailGenitalArg);
			}
			return vag;
		}
		public function vaginaNounDescript(vaginaNum: Number = 0):String
		{
			if(vaginaNum > vaginas.length || vaginaNum < 0) return "ERROR, INVALID PUSSY";
			else return vaginaNoun(vaginas[vaginaNum].type);
		}
		public function vaginaNoun(type: int = 0, simple: Boolean = false): String {
			var vag: String = "";
			var temp: int = 0;
			if (type == GLOBAL.TYPE_EQUINE) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "equine gash";
					else if (temp <= 3) vag += "animalistic vagina";
					else if (temp <= 5) vag += "animalistic cunny";
					else if (temp <= 7) vag += "equine honeypot";
					else if (temp <= 9) vag += "dusky snatch";
					else if (temp <= 11) vag += "equine cunt";
					else if (temp <= 13) vag += "pheromone-laden pussy";
					else vag += "musky mare-cunt";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "horse-pussy";
					else if (temp <= 3) vag += "mare-cunt";
					else if (temp <= 5) vag += "fuck-hole";
					else if (temp <= 7) vag += "horse-twat";
					else if (temp <= 9) vag += "mare-twat";
					else if (temp <= 11) vag += "centaur-snatch";
					else if (temp <= 13) vag += "animal-pussy";
					else if (temp <= 15) vag += "mare-pussy";
					else vag += "horse-cunt";
				}
			}
			//Maybe doge?
			else if (type == GLOBAL.TYPE_CANINE) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "canine gash";
					else if (temp <= 3) vag += "small-lipped vagina";
					else if (temp <= 5) vag += "animalistic cunny";
					else if (temp <= 7) vag += "canine honeypot";
					else if (temp <= 9) vag += "canine snatch";
					else if (temp <= 11) vag += "canine cunt";
					else if (temp <= 13) vag += "animalistic pussy";
					else vag += "fragrant dog-cunt";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "dog-pussy";
					else if (temp <= 3) vag += "bitch-cunt";
					else if (temp <= 5) vag += "fuck-hole";
					else if (temp <= 7) vag += "dog-twat";
					else if (temp <= 9) vag += "animal-twat";
					else if (temp <= 13) vag += "animal-pussy";
					else if (temp <= 15) vag += "dog-pussy";
					else vag += "dog-cunt";
				}
			}
			//Slimgina?
			else if (type == GLOBAL.TYPE_GOOEY) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "slimey vagina";
					else if (temp <= 3) vag += "gooey pussy";
					else if (temp <= 5) vag += "slimy cunt";
					else if (temp <= 7) vag += "syrupy hole";
					else if (temp <= 9) vag += "juicy twat";
					else if (temp <= 11) vag += "slimy gash";
					else if (temp <= 13) vag += "gooey honeypot";
					else vag += "slimey snatch";
				} else {
					temp = this.rand(16);
					if (temp <= 1) vag += "slime-gina";
					else if (temp <= 3) vag += "goo-pussy";
					else if (temp <= 5) vag += "slime-cunt";
					else if (temp <= 7) vag += "fuck-hole";
					else if (temp <= 9) vag += "goo-twat";
					else if (temp <= 11) vag += "slime-gash";
					else if (temp <= 13) vag += "honeypot";
					else vag += "slime-snatch";
				}
			} else if (type == GLOBAL.TYPE_SIREN || type == GLOBAL.TYPE_ANEMONE) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "wriggling gash";
					else if (temp <= 3) vag += "stinger-ringed vagina";
					else if (temp <= 5) vag += "cilia-filled cunny";
					else if (temp <= 7) vag += "siren-like honeypot";
					else if (temp <= 9) vag += "aphrodisiac-laced snatch";
					else if (temp <= 11) vag += "tentacle-filled cunt";
					else if (temp <= 13) vag += "alien pussy";
					else vag += "wiggly cunt";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "siren-pussy";
					else if (temp <= 3) vag += "siren-snatch";
					else if (temp <= 5) vag += "fuck-hole";
					else if (temp <= 7) vag += "venom-twat";
					else if (temp <= 9) vag += "twat";
					else if (temp <= 11) vag += "snatch";
					else if (temp <= 13) vag += "venmon-pussy";
					else if (temp <= 15) vag += "siren-pussy";
					else vag += "cunt";
				}
			} else if (type == GLOBAL.TYPE_BEE) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "thick-lipped gash";
					else if (temp <= 3) vag += "alien vagina";
					else if (temp <= 5) vag += "inhuman cunt";
					else if (temp <= 7) vag += "zil-like honeypot";
					else if (temp <= 9) vag += "exceptionally smooth pussy";
					else if (temp <= 11) vag += "exotic slit";
					else if (temp <= 13) vag += "thick-lipped pussy";
					else vag += "seductive snatch";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "zil-pussy";
					else if (temp <= 3) vag += "honey-cunt";
					else if (temp <= 5) vag += "honey-box";
					else if (temp <= 7) vag += "zil-twat";
					else if (temp <= 9) vag += "pussy";
					else if (temp <= 11) vag += "xeno-snatch";
					else if (temp <= 13) vag += "pussy";
					else if (temp <= 15) vag += "zil-cunt";
					else vag += "twat";
				}
			} else if (type == GLOBAL.TYPE_NAGA) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "reptilian gash";
					else if (temp <= 3) vag += "naleen-like slit";
					else if (temp <= 5) vag += "snake-like cunt";
					else if (temp <= 7) vag += "semi-concealed pussy";
					else if (temp <= 9) vag += "supple pussy";
					else if (temp <= 11) vag += "snake-like box";
					else if (temp <= 13) vag += "alien cunt";
					else vag += "half-hidden twat";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "naleen-cunt";
					else if (temp <= 3) vag += "snake-pussy";
					else if (temp <= 5) vag += "box";
					else if (temp <= 7) vag += "snake-twat";
					else if (temp <= 9) vag += "pussy";
					else if (temp <= 11) vag += "xeno-cunt";
					else if (temp <= 13) vag += "pussy";
					else if (temp <= 15) vag += "slit";
					else vag += "slit";
				}
			} else if (type == GLOBAL.TYPE_VANAE) {
				if (!simple) {
					temp = this.rand(16);
					if (temp <= 1) vag += "tentacle-laden gash";
					else if (temp <= 3) vag += "writhing pussy";
					else if (temp <= 5) vag += "human-like cunt";
					else if (temp <= 7) vag += "vanae pussy";
					else if (temp <= 9) vag += "supple pussy";
					else if (temp <= 11) vag += "xeno-cunt";
					else if (temp <= 13) vag += "alien pussy";
					else vag += "silky twat";
				} else {
					temp = this.rand(18);
					if (temp <= 1) vag += "vanae-cunt";
					else if (temp <= 3) vag += "tenta-pussy";
					else if (temp <= 5) vag += "box";
					else if (temp <= 7) vag += "vanae-twat";
					else if (temp <= 9) vag += "pussy";
					else if (temp <= 11) vag += "xeno-cunt";
					else if (temp <= 13) vag += "pussy";
					else if (temp <= 15) vag += "twat";
					else vag += "cunt";
				}
			} else {
				if (!simple) {
					temp = this.rand(5);
					if (temp <= 1) vag += "human ";
					else vag += "terran ";
				}
				temp = this.rand(16);
				if (temp <= 2) vag += "vagina";
				else if (temp <= 5) vag += "pussy";
				else if (temp <= 8) vag += "cunt";
				else if (temp <= 9) vag += "fuck-hole";
				else if (temp <= 10) vag += "muff";
				else if (temp <= 12) vag += "twat";
				else if (temp <= 13) vag += "gash";
				else if (temp <= 14) vag += "cunny";
				else if (temp <= 14) vag += "honeypot";
				else if (temp <= 15) vag += "snatch";
			}
			return vag;
		}
		
		//Vaginas + Descript
		public function vaginaDescript(vaginaNum: Number = 0, forceAdjectives: Boolean = false, adjectives: Boolean = true): String {
			if (vaginaNum > (vaginas.length - 1)) return "<B>Error: Invalid vagina number (" + vaginaNum + ") passed to vaginaDescript()</b>";
			if (vaginaNum < 0) return "<B>Error: Invalid vaginaNum (" + vaginaNum + ") passed to vaginaDescript()</b>";
			//If no vaginas back the fuck out
			if (vaginas.length < 0) return "VAGINA ERROR";

			//Vars
			var vag: String = "";
			var descripted: int = 0;
			var bonus: int = 0;
			var temp: int = 0;

			//Bonus chance for virgins
			if (vaginalVirgin) bonus += 20
			//Color super low chance!
			if (adjectives && !forceAdjectives && rand(15) == 0)
			{
				if (vaginas[vaginaNum].vaginaColor.length > 0)
				{
					descripted++;
					vag += vaginas[vaginaNum].vaginaColor;
				}
				else
				{
					trace("Vagina doesn't have a color set!");
				}
			}
			//low chance of size descriptor
			if (((adjectives && this.rand(100) <= 25 + bonus) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				//Virgin overpowers other shit half the time.
				if (vaginalVirgin && this.rand(2) == 0) {
					temp = this.rand(11);
					if (temp <= 3) vag += "virgin";
					else if (temp <= 5) vag += "virginal";
					else if (temp <= 7) vag += "unclaimed";
					else if (temp <= 9) vag += "unspoiled";
					else vag += "pure";
				} else if (vaginas[vaginaNum].looseness() <= 1) {
					temp = this.rand(11);
					if (temp <= 4) vag += "tight";
					else if (temp <= 5) vag += "vice-like";
					else if (temp <= 6) vag += "constricting";
					else if (temp <= 8) vag += "unstretched";
					else vag += "narrow";
				} else if (vaginas[vaginaNum].looseness() <= 2) {
					temp = this.rand(10);
					//if (temp <= 5) vag += "average";
					//else 
					vag += "supple";
				} else if (vaginas[vaginaNum].looseness() <= 3) {
					temp = this.rand(10);
					if (temp <= 4) vag += "loose";
					else if (temp <= 6) vag += "slightly-stretched";
					else if (temp <= 8) vag += "loosened";
					else vag += "lax";
				} else if (vaginas[vaginaNum].looseness() <= 4) {
					temp = this.rand(11);
					if (temp <= 3) vag += "slightly-gaped";
					else if (temp <= 5) vag += "well-loosened";
					else if (temp <= 7) vag += "open";
					else if (temp <= 8) vag += "widened";
					else if (temp <= 9) vag += "barely-spread";
					else vag += "parted";
				} else {
					temp = this.rand(11);
					if (temp <= 4) vag += "gaped";
					else if (temp <= 8) vag += "cavernous";
					else if (temp <= 9) vag += "wide-open";
					else vag += "ruined";
				}
				descripted++;
			}
			//wetness descript - 30% display rate
			if (descripted < 2 && ((adjectives && this.rand(100) > 70) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				if (vaginas[vaginaNum].wetness() == 0) {
					temp = this.rand(10);
					if (temp <= 4) vag += "dry";
					else if (temp <= 7) vag += "unlubricated";
					else vag += "moistureless";
				} else if (vaginas[vaginaNum].wetness() <= 1) {
					temp = this.rand(10);
					if (temp <= 4) vag += "moist";
					else if (temp <= 7) vag += "sticky";
					else vag += "dewy";
				} else if (vaginas[vaginaNum].wetness() <= 2) {
					temp = this.rand(10);
					if (temp <= 3) vag += "wet";
					else if (temp <= 5) vag += "sultry";
					else if (temp <= 8) vag += "sweltering";
					else vag += "slippery";
				} else if (vaginas[vaginaNum].wetness() <= 3) {
					temp = this.rand(12);
					if (temp <= 3) vag += "slick";
					else if (temp <= 6) vag += "drenched";
					else if (temp <= 9) vag += "sopping";
					else vag += "soaked";
				} else if (vaginas[vaginaNum].wetness() <= 4) {
					temp = this.rand(9);
					if (temp <= 2) vag += "drooling";
					else if (temp <= 5) vag += "dripping";
					else vag += "lube-leaking";
				} else {
					temp = this.rand(12);
					if (temp <= 2) vag += "slavering";
					else if (temp <= 5) vag += "slobbering";
					else if (temp <= 8) vag += "puddling";
					else vag += "crotch-soaking";
				}
				descripted++;
			}
			//Elasticity references!
			if (descripted < 2 && elasticity >= 1.5 && ((adjectives && this.rand(3) == 0) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				if (elasticity >= 5) {
					temp = this.rand(10);
					if (temp <= 3) vag += "super-stretchy";
					else if (temp <= 7) vag += "incredibly elastic";
					else vag += "powerfully pliable";
				} else {
					temp = this.rand(10);
					if (temp <= 1) vag += "stretchy";
					else if (temp <= 3) vag += "elastic";
					else if (temp <= 5) vag += "pliable";
					else if (temp <= 7) vag += "flexible";
					else vag += "pliant";
				}
				descripted++;
			}
			if (descripted < 2 && skinType == GLOBAL.SKIN_TYPE_GOO && ((adjectives && this.rand(3) == 0) || forceAdjectives)) {
				if (descripted > 0) vag += ", ";
				if (this.rand(2) == 0) vag += "gooey";
				else vag += "slimy";
				descripted++;
			}
			/*CoC's black cunts. Might still use!
			if(vaginaType() == 5 && this.rand(2) == 0) {
				if(descripted) vag += ", ";
				rand = Math.floor(Math.random() * 8);
				if(rand == 0) vag += "black";
				else if(rand == 1) vag += "onyx";
				else if(rand == 2) vag += "ebony";
				else if(rand == 3) vag += "dusky";
				else if(rand == 4) vag += "sable";
				else if(rand == 5) vag += "obsidian";
				else if(rand == 6) vag += "midnight-hued";
				else vag += "jet black";
				descripted = true;
			}*/
			//50% of time, simple cunt.
			if (this.rand(2) == 0) {
				if (descripted > 0) vag += " ";
				vag += vaginaNoun(vaginas[vaginaNum].type, true);
			}
			//50% of the time, complex cunt!
			else {
				if (descripted > 0) vag += ", ";
				vag += vaginaNoun(vaginas[vaginaNum].type);
			}
			return vag;
		}
		//eachVagina
		public function eachVagina(): String {
			var desc: String = "";
			if (vaginas.length > 1) desc += "each of ";
			desc += "your " + vaginasDescript();
			return desc;
		}
		//oneVagina
		public function oneVagina(): String {
			var desc: String = "";
			if (vaginas.length > 1) desc += "one of ";
			desc += "your " + vaginasDescript();
			return desc;
		}
		//Allvagina descript
		public function vaginasDescript(): String {
			if (vaginas.length == 1) return vaginaDescript();
			if (vaginas.length > 1) return pluralize(vaginaDescript(this.rand(vaginas.length)));
			return "ERROR: vagina<b>s</b>Descript called with no vaginas.";
		}
		public function multiCockDescript(): String {
			if (cocks.length < 1) return "<B>Error: multiCockDescript() called with no penises present.</B>";
			//Get cock counts
			var descript: String = "";
			var rando: Number = 0;
			var descripted: Boolean = false;

			//Single dick gets normal output
			if (cocks.length == 1) return cockDescript(0);

			//Numbers!
			else if (cocks.length <= 2) {
				//For cocks that are the same
				if (hasSamecType()) {
					rando = this.rand(5);
					if (rando == 0) descript += "pair of ";
					if (rando == 1) descript += "two, ";
					if (rando == 2) descript += "brace of ";
					if (rando == 3) descript += "matching, ";
					if (rando == 4) descript += "twin, ";
				}
				//Nonidentical
				else {
					rando = this.rand(3);
					if (rando == 0) descript += "pair of ";
					if (rando == 1) descript += "two, ";
					if (rando == 2) descript += "brace of ";
				}
			} else if (cocks.length <= 3) {
				//For samecocks
				if (hasSamecType()) {
					rando = this.rand(5);
					if (rando == 0) descript += "three, ";
					if (rando == 1) descript += "group of ";
					if (rando == 2) descript += "menage a trois of ";
					if (rando == 3) descript += "triad of ";
					if (rando == 4) descript += "triumvirate of ";
				} else {
					rando = this.rand(2);
					if (rando == 0) descript += "three, ";
					if (rando == 1) descript += "group of ";
				}
			}
			//Large numbers of cocks!
			else {
				rando = this.rand(4);
				if (rando == 0) descript += "bundle of ";
				if (rando == 1) descript += "obscene group of ";
				if (rando == 2) descript += "cluster of ";
				if (rando == 3) descript += "wriggling bunch of ";
			}
			//Append Nounse
			if (hasSamecType()) descript += cockAdjective() + ", " + pluralize(cockNoun(cocks[0].cType, false, false));
			else {
				rando = this.rand(4);
				if (rando == 0) descript += cockAdjective() + ", mutated cocks";
				if (rando == 1) descript += cockAdjective() + ", mutated dicks";
				if (rando == 2) descript += cockAdjective() + ", mixed cocks";
				if (rando == 3) descript += cockAdjective() + ", mismatched dicks";
			}
			return descript;
		}
		public function hasSamecType(): Boolean {
			if (cocks.length == 0) return false;
			var first: int = cocks[0].cType;
			for (var x: int = 0; x < cocks.length; x++) {
				if (cocks[x].cType != first) return false;
			}
			return true;
		}
		private function clearList(): void {
			list = new Array();
		}
		private function addToList(arg): void {
			list[list.length] = arg;
		}
		private function formatList(): String {
			var stuff: String = "";
			if (list.length == 1) return list[0];
			for (var x: int = 0; x < list.length; x++) {
				stuff += list[x];
				if (list.length == 2 && x == 0) {
					stuff += " and ";
				} else if (x < list.length - 2) {
					stuff += ", ";
				} else if (x < list.length - 1) {
					stuff += ", and ";
				}
			}
			list = new Array();
			return stuff;
		}
		public function gearDescript(): String {
			clearList();
			if (armor.shortName != "") addToList(armor.longName);
			if (upperUndergarment.shortName != "") addToList(upperUndergarment.longName);
			if (lowerUndergarment.shortName != "") addToList(lowerUndergarment.longName);
			if (isNude()) addToList("gear");
			return formatList();
		}
		public function crotchDescript():String {

			clearList();
			
			//Nothing to talk about? K
			if(!hasCock() && !hasVagina()) 
			{
				if(rand(2) == 0) return "bare crotch";
				else return "bare groin";
			}
			//Make da list!
			if(hasCock()) addToList(cocksDescript());
			if(balls > 0) addToList(ballsDescript());
			if(hasVagina()) addToList(vaginasDescript());
			
			return formatList();
		}
		public function lowerGarmentDescript(): String {
			if (lowerUndergarment.shortName != "") return lowerUndergarment.longName;
			else if (armor.shortName != "") return armor.longName;
			else return "nothing";
		}
		public function upperGarmentDescript(): String {
			if (upperUndergarment.shortName != "") return upperUndergarment.longName;
			else if (armor.shortName != "") return armor.longName;
			else return "nothing";
		}
		public function upperGarmentsDescript(): String {
			if (upperUndergarment.shortName != "" && armor.shortName != "") return armor.longName + " and " + upperUndergarment.longName;
			else if (upperUndergarment.shortName != "") return upperUndergarment.longName;
			else if (armor.shortName != "") return armor.longName;
			else return "nothing";
		}
		public function lowerGarmentsDescript(): String {
			if (lowerUndergarment.shortName != "" && armor.shortName != "") return armor.longName + " and " + lowerUndergarment.longName;
			else if (lowerUndergarment.shortName != "") return lowerUndergarment.longName;
			else if (armor.shortName != "") return armor.longName;
			else return "nothing";
		}
		//Basic multiple cock description.
		public function cocksDescript(): String {
			if (cocks.length < 1) return "<b>ERROR: NO WANGS DETECTED for cocksDescript()</b>";
			//Single dicks are normal.
			else if (cocks.length == 1) return cockDescript();
			//Matched dicks get full cocknoun.
			if (hasSamecType()) return pluralize(cockAdjective() + ", " + cockNoun(cocks[0].cType, false));
			//Unmatched get default types
			else return pluralize(cockAdjective() + " " + cockNoun(0, true));
		}
		//Ultra-basic multiple cock description
		public function cocksDescriptLight(): String {
			var output: String = "";
			if (cocks.length < 1) return "<b>ERROR: NO WANGS DETECTED for cocksDescript()</b>";
			if (hasSamecType()) output += cockNoun(cocks[0].cType);
			else output += cockNoun(0);
			//pluralize dat shit
			if (cockTotal() > 1) output = pluralize(output);
			return output;
		}
		public function simpleCockNoun(arg: Number): String {
			if (cocks.length < 1) return "<b>ERROR: NO WANGS DETECTED for simpleCockNoun()</b>";
			return cockNoun(cocks[arg].cType, true);
		}
		public function simpleCocksNoun():String {
			var output:String = "";
			
			if (cocks.length < 1) return "<b>ERROR: NO WANGS DETECTED for simpleCocksNoun()</b>";
			if (hasSamecType()) output += cockNoun(cocks[0].cType, true);
			else output += cockNoun(0, true);
			
			if (cocks.length > 1) output = pluralize(output);
			
			return output;
		}
		public function cockNounComplex(arg: Number): String {
			if (cocks.length < 1) return "<b>ERROR: NO WANGS DETECTED for cockNounComplex()</b>";
			return cockNoun(cocks[arg].cType, false);
		}
		
		// Spit back a singular word related to the shape of the target cock, with the minimum
		// of ambiguity. Basically describe a very clear feature of the cock, either its type or a flag.
		// I didn't want to potentially fuck up an existing descriptor in the process, so I've opted to keep it separate.
		public function cockShape(cockIndex:int):String
		{
			var cock:CockClass = cocks[cockIndex];
			
			var collection:Array = [];
			
			// main shapes
			switch (cock.cType)
			{
				case GLOBAL.TYPE_HUMAN:
					collection = ["terran"];
					break;
					
				case GLOBAL.TYPE_CANINE:
					collection = ["canine"];
					break;					
					
				case GLOBAL.TYPE_VULPINE:
					collection = ["vulpine"];
					break;
					
				case GLOBAL.TYPE_EQUINE:
					collection = ["equine"];
					break;
					
				case GLOBAL.TYPE_DEMONIC:
					collection = ["demonic", "nodule-laden"]
					break;
					
				case GLOBAL.TYPE_TENTACLE:
					collection = ["tentacle"];
					break;
					
				case GLOBAL.TYPE_FELINE:
					collection = ["feline", "barbed"];
					break;
					
				case GLOBAL.TYPE_NAGA:
				case GLOBAL.TYPE_SNAKE:
					collection = ["snake", "reptilian"];
					break;
					
				case GLOBAL.TYPE_DRACONIC:
					collection = ["draconic"];
					break;
					
				case GLOBAL.TYPE_BEE:
					collection = ["zil"];
					break;
					
				case GLOBAL.TYPE_KANGAROO:
					collection = ["kangaroo"];
					break;
					
				default:
					trace("Fallback cock shape used in cockShape() for type: " + GLOBAL.TYPE_NAMES[cock.cType]);
					collection = ["cock"];
					break;
			}
			
			// flag overrides
			if (cock.hasFlag(GLOBAL.FLAG_KNOTTED)) collection.push("knotted");
			if (cock.hasFlag(GLOBAL.FLAG_FLARED)) collection.push("flared");
			if (cock.hasFlag(GLOBAL.FLAG_BLUNT)) collection.push("blunt");
			if (cock.hasFlag(GLOBAL.FLAG_PREHENSILE)) collection.push("prehensile");
			if (cock.hasFlag(GLOBAL.FLAG_TAPERED)) collection.push("tapered");
			
			return RandomInCollection(collection);
		}
		
		//Cock nouns with a single, toggleable adjective. Used all over the place, yo.
		public function cockNoun(type: Number, simple: Boolean = true, tail: Boolean = false): String {
			var descript: String = "";
			var noun: String = "";
			var rando: Number = 0;
			//If a taildick, convert to human so we can mention its a tailcock 50% of the time!
			if (tail && this.rand(2) == 0) {
				type = GLOBAL.TYPE_HUMAN;
			}
			if (type == GLOBAL.TYPE_HUMAN) {
				if (!simple) {
					rando = this.rand(7);
					if (rando <= 3) descript += "human ";
					else descript += "terran ";
				}
				rando = this.rand(10) + 1;
				if (tail) noun += "tail-";
				if (rando <= 4) noun += "cock";
				else if (rando <= 6) noun += "prick";
				else if (rando <= 7) noun += "pecker";
				else noun += "shaft";
			} else if (type == GLOBAL.TYPE_CANINE || type == GLOBAL.TYPE_VULPINE) {
				if (!simple) {
					rando = this.rand(8);
					if (rando <= 0 && type == GLOBAL.TYPE_CANINE) descript += "canine ";
					else if (rando <= 0) descript += "vulpine ";
					else if (rando <= 1) descript += "pointed ";
					else if (rando <= 2) descript += "knotty ";
					else if (rando <= 3) descript += "bestial ";
					else if (rando <= 4) descript += "animalistic ";
					else if (rando <= 5) descript += "canine ";
					else if (rando <= 6) descript += "animalistic ";
					else descript += "knotted ";
				}
				if (type == GLOBAL.TYPE_CANINE) {
					rando = this.rand(11);
					if (rando == 0) noun += "doggie-dong";
					else if (rando == 1) noun += "shaft";
					else if (rando == 2) noun += "prick";
					else if (rando == 3) noun += "dog-shaft";
					else if (rando == 4) noun += "cock";
					else if (rando == 5) noun += "puppy-pecker";
					else if (rando == 6) noun += "dog-dick";
					else if (rando == 7) noun += "shaft";
					else if (rando == 8) noun += "member";
					else if (rando == 9) noun += "cock";
					else noun += "dog-cock";
				} else {
					rando = this.rand(11);
					if (rando == 0) noun += "dong";
					else if (rando == 1) noun += "shaft";
					else if (rando == 2) noun += "prick";
					else if (rando == 3) noun += "fox-shaft";
					else if (rando == 4) noun += "cock";
					else if (rando == 5) noun += "vixen-pricker";
					else if (rando == 6) noun += "fox-dick";
					else if (rando == 7) noun += "shaft";
					else if (rando == 8) noun += "member";
					else if (rando == 9) noun += "cock";
					else noun += "fox-cock";
				}
			} else if (type == GLOBAL.TYPE_EQUINE) {
				if (!simple) {
					rando = this.rand(7);
					if (rando == 0) descript += "flared ";
					else if (rando == 1) descript += "equine ";
					else if (rando == 2) descript += "bestial ";
					else if (rando == 3) descript += "flat-tipped ";
					else if (rando == 4) descript += "animalistic ";
					else if (rando == 5) descript += "blunted ";
					else descript += "sheath-girded ";
				}
				rando = this.rand(10);
				if (rando <= 0) noun += "horse-cock";
				else if (rando <= 1) noun += "prick";
				else if (rando <= 2) noun += "horse-shaft";
				else if (rando <= 3) noun += "horse-member";
				else if (rando <= 4) noun += "stallion-prick";
				else if (rando <= 5) noun += "dong";
				else if (rando <= 6) noun += "beast-cock";
				else if (rando <= 7) noun += "stallion-cock";
				else if (rando <= 8) noun += "tool";
				else noun += "phallus";
			} else if (type == GLOBAL.TYPE_DEMONIC) {
				if (!simple) {
					rando = this.rand(9);
					if (rando == 0) descript += "nub-covered ";
					else if (rando == 1) descript += "nubby ";
					else if (rando == 2) descript += "perverse ";
					else if (rando == 3) descript += "bumpy ";
					else if (rando == 4) descript += "demonic ";
					else if (rando == 5) descript += "cursed ";
					else if (rando == 6) descript += "infernal ";
					else if (rando == 7) descript += "unholy ";
					else descript += "blighted ";
				}
				rando = this.rand(11);
				if (rando <= 0 && descript != "demonic") noun += "demon-dick";
				else if (rando <= 1) noun += "shaft";
				else if (rando <= 2) noun += "cock";
				else if (rando <= 3) noun += "pecker";
				else if (rando <= 4) noun += "demon-dick";
				else if (rando <= 5) noun += "cock";
				else if (rando <= 6) noun += "dong";
				else if (rando <= 7) noun += "prick";
				else if (rando <= 8) noun += "prick";
				else if (rando <= 9) noun += "member";
				else noun += "tool";
			} else if (type == GLOBAL.TYPE_TENTACLE) {
				if (!simple) {
					rando = this.rand(9);
					if (rando == 0) descript += "twisting ";
					else if (rando == 1) descript += "wriggling ";
					else if (rando == 2) descript += "sinuous ";
					else if (rando == 3) descript += "squirming ";
					else if (rando == 4) descript += "writhing ";
					else if (rando == 5) descript += "smooth ";
					else if (rando == 6) descript += "undulating ";
					else if (rando == 7) descript += "slithering ";
					else descript += "vine-like ";
				}
				rando = this.rand(11);
				if (rando <= 0) noun += "tentacle-prick";
				else if (rando <= 1) noun += "plant-shaft";
				else if (rando <= 2) noun += "tentacle-cock";
				else if (rando <= 3) noun += "cock-tendril";
				else if (rando <= 4) noun += "tentacle-pecker";
				else if (rando <= 5) noun += "plant-prick";
				else if (rando <= 6) {
					noun += "penile flora";
					descript = "";
				} else if (rando <= 7) noun += "shaft";
				else if (rando <= 8) noun += "tentacle-dick";
				else if (rando <= 9 && descript != "vine-like ") noun += "vine-prick";
				else noun += "cock";
			} else if (type == GLOBAL.TYPE_FELINE) {
				if (!simple) {
					rando = this.rand(8);
					if (rando == 0) descript += "feline ";
					else if (rando == 1) descript += "spine-covered ";
					else if (rando == 2) descript += "spined ";
					else if (rando == 3) descript += "pink ";
					else if (rando == 4) descript += "animalistic ";
					else if (rando == 5) descript += "soft-barbed ";
					else if (rando == 6) descript += "nubby ";
					else descript += "slithering ";
				}
				rando = this.rand(11);
				if (rando == 0) noun += "dick";
				else if (rando <= 1) noun += "cat-cock";
				else if (rando <= 2) noun += "kitty-cock";
				else if (rando <= 3) noun += "prick";
				else if (rando <= 4) noun += "kitty-prick";
				else if (rando <= 5) noun += "cat-penis";
				else if (rando <= 6) noun += "member";
				else if (rando <= 7) noun += "shaft";
				else if (rando <= 8) noun += "shaft";
				else if (rando <= 9) noun += "dick";
				else noun += "kitten-prick";
			} else if (type == GLOBAL.TYPE_NAGA || type == GLOBAL.TYPE_SNAKE) {
				if (!simple) {
					rando = this.rand(8);
					if (rando == 0) descript += "reptilian ";
					else if (rando == 1) descript += "purple ";
					else if (rando == 2) descript += "inhuman ";
					else if (rando == 3) descript += "reptilian ";
					else if (rando == 4) descript += "purple ";
					else if (rando == 5) descript += "serpentine ";
					else if (rando == 6) descript += "bulbous ";
					else descript += "bulging ";
				}
				rando = this.rand(11);
				if (rando == 0) noun += "dick";
				else if (rando == 1) noun += "cock";
				else if (rando == 2) noun += "snake-cock";
				else if (rando == 3) noun += "prick";
				else if (rando == 4) noun += "prick";
				else if (rando == 5) noun += "member";
				else if (rando == 6) noun += "phallus";
				else if (rando == 7) noun += "shaft";
				else if (rando == 8) noun += "tool";
				else if (rando == 9) noun += "snake-shaft";
				else noun += "snake-dick";
			} else if (type == GLOBAL.TYPE_ANEMONE) {
				if (!simple) {
					rando = this.rand(8);
					if (rando == 0) descript += "tentacle-ringed ";
					else if (rando == 1) descript += "blue ";
					else if (rando == 2) descript += "stinger-laden ";
					else if (rando == 3) descript += "pulsating ";
					else if (rando == 4) descript += "stinger-coated ";
					else if (rando == 5) descript += "near-transparent ";
					else if (rando == 6) descript += "tentacle-ringed ";
					else descript += "squirming ";
				}
				rando = this.rand(11);
				if (rando == 0) noun += "anemone-dick";
				if (rando == 1) noun += "cock";
				if (rando == 2) noun += "member";
				if (rando == 3) noun += "shaft";
				if (rando == 4) noun += "prick";
				if (rando == 5) noun += "anemone-prick";
				if (rando == 6) noun += "member";
				if (rando == 7) noun += "cock";
				if (rando == 8) noun += "dick";
				if (rando == 9) noun += "shaft";
				if (rando == 10) noun += "shaft";
			} else if (type == GLOBAL.TYPE_KANGAROO) {
				if (!simple) {
					rando = this.rand(8);
					if (rando == 0) descript += "kangaroo-like ";
					else if (rando == 1) descript += "pointed ";
					else if (rando == 2) descript += "marsupial ";
					else if (rando == 3) descript += "tapered ";
					else if (rando == 4) descript += "curved ";
					else if (rando == 5) descript += "near-transparent ";
					else if (rando == 6) descript += "tentacle-ringed ";
					else descript += "squirming ";
				}
				rando = this.rand(11);
				if (rando == 0) noun += "dick";
				else if (rando <= 1) noun += "cock";
				else if (rando <= 2) noun += "member";
				else if (rando <= 3) noun += "shaft";
				else if (rando <= 4) noun += "pecker";
				else if (rando <= 5 && descript != "kangaroo-like ") noun += "kangaroo-cock";
				else if (rando <= 6) noun += "prick";
				else if (rando <= 7 && descript != "kangaroo-like ") noun += "kangaroo-dick";
				else if (rando <= 8) noun += "cock";
				else if (rando <= 9 && descript != "kangaroo-like ") noun += "kangaroo-cock";
				else noun += "shaft";
			} else if (type == GLOBAL.TYPE_DRACONIC) {
				if (!simple) {
					rando = this.rand(8);
					if (rando == 0) descript += "dragon-like ";
					else if (rando == 1) descript += "segmented ";
					else if (rando == 2) descript += "pointed ";
					else if (rando == 3) descript += "knotted ";
					else if (rando == 4) descript += "mythic ";
					else if (rando == 5) descript += "draconic ";
					else if (rando == 6) descript += "tapered ";
					else descript += "scaly ";
				}
				rando = this.rand(11);
				if (rando <= 0) noun += "dick";
				else if (rando <= 1) noun += "shaft";
				else if (rando <= 2) noun += "prick";
				else if (rando <= 3 && descript != "dragon-like ") noun += "dragon-cock";
				else if (rando <= 4) noun += "phallus";
				else if (rando <= 5) noun += "tool";
				else if (rando <= 6) noun += "dick";
				else if (rando <= 7) noun += "cock";
				else if (rando <= 8 && descript != "dragon-like ") noun += "dragon-dick";
				else if (rando <= 9) noun += "endowment";
				else noun += "shaft";
			} else if (type == GLOBAL.TYPE_BEE) {
				if (!simple) {
					rando = this.rand(7);
					if (rando == 0) descript += "foreskin-covered ";
					else if (rando == 1) descript += "thick-skinned ";
					else if (rando == 2) descript += "fleshy ";
					else if (rando == 3) descript += "skin-shrouded ";
					else if (rando == 4) descript += "alien ";
					else if (rando == 5) descript += "vaguely human-like ";
					else descript += "smooth ";
				}
				rando = this.rand(11);
				if (rando == 0) noun += "zil-dick";
				if (rando == 1) noun += "cock";
				if (rando == 2) noun += "member";
				if (rando == 3) noun += "shaft";
				if (rando == 4) noun += "phallus";
				if (rando == 5) noun += "zil-prick";
				if (rando == 6) noun += "member";
				if (rando == 7) noun += "zil-cock";
				if (rando == 8) noun += "dick";
				if (rando == 9) noun += "tool";
				if (rando == 10) noun += "shaft";
			}
			/* To return if Third writes it!
			else if(type == 10) {
				rando = this.rand(12);
				if(rando == 0) descript+="coerl cock";
				if(rando == 1) descript+="tentacle-tipped phallus";
				if(rando == 2) descript+="starfish-tipped shaft";
				if(rando == 3) descript+="alien member";
				if(rando == 4) descript+="almost-canine dick";
				if(rando == 5) descript+="bizarre prick";
				if(rando == 6) descript+="beastly cock";
				if(rando == 7) descript+="cthulhu-tier cock";
				if(rando == 8) descript+="coerl cock";
				if(rando == 9) descript+="animal dong";
				if(rando == 10) descript+="star-capped tool";
				if(rando == 11) descript+="knotted erection";
			}*/
			else {
				noun += "Error. Cock type does not have a cock noun configuration.";
			}
			return descript + noun;
		}
		//New cock adjectives.  The old one sucked dicks
		public function cockAdjective(cockNum: Number = -1) {
			var descript: String = "";
			var rando: Number = 0;
			var multi: Boolean = false;
			//If used for multiple cocks, set multi flag
			if (cockNum < 0) {
				//Since we have multi dicks lets talk about the biggest!
				cockNum = biggestCockIndex();
				multi = true;
			}

			//Color: 1/15 chance
			if (!multi && rand(15) == 0)
			{
				descript += cocks[cockNum].cockColor;
			}
			//Pierced - 1/5 chance
			else if (!multi && this.rand(5) == 0 && cocks[cockNum].pierced > 0) {
				descript += "pierced";
			}
			//Cocksocks!
			else if (!multi && this.rand(5) == 0 && cocks[cockNum].sock != "") {
				rando = this.rand(6);
				if (rando == 0) descript += "sock-sheathed";
				else if (rando == 1) descript += "garment-wrapped";
				else if (rando == 2) descript += "smartly dressed";
				else if (rando == 3) descript += "cloth-shrouded";
				else if (rando == 4) descript += "fabric swaddled";
				else descript += "covered";
			}
			//Goo - 1/4 chance
			else if (skinType == GLOBAL.SKIN_TYPE_GOO && this.rand(4) == 0) {
				rando = this.rand(3);
				if (rando == 0) descript += "goopey";
				else if (rando == 1) descript += "gooey";
				else descript += "slimy";
			}
			//Knot - 1/5 chance. Only specifically called out if dick isn't dog, since knot shows up with the
			//canine nouns.
			else if(rand(5) == 0 && cocks[cockNum].hasFlag(GLOBAL.FLAG_KNOTTED) && cocks[cockNum].cType != GLOBAL.TYPE_CANINE && cocks[cockNum].cType != GLOBAL.TYPE_SNAKE && cocks[cockNum].cType != GLOBAL.TYPE_NAGA)
			{
				if(rand(3) == 0)  descript += "knotted";
				else if(rand(2) == 0) descript += "bulbous";
				else descript += "knotty";
			}
			//Length 1/3 chance
			else if (this.rand(3) == 0) {
				if (cocks[cockNum].cLength() < 3) {
					rando = this.rand(4);
					if (rando == 0) descript = "little";
					else if (rando == 1) descript = "toy-sized";
					else if (rando == 2) descript = "mini";
					else if (rando == 3) descript = "budding";
					else descript = "tiny";
				} else if (cocks[cockNum].cLength() < 5) {
					rando = this.rand(2);
					if (rando == 0) descript = "short";
					else descript = "small";
				} else if (cocks[cockNum].cLength() < 7) {
					rando = this.rand(2);
					if (rando == 0) descript = "fair-sized";
					else descript = "nice";
				} else if (cocks[cockNum].cLength() < 11) {
					rando = this.rand(3);
					if (rando == 0) {
						if (cocks[cockNum].cType == GLOBAL.TYPE_EQUINE) descript = "pony-sized";
						else descript = "long";
					} else if (rando == 1) {
						if (cocks[cockNum].cType == GLOBAL.TYPE_EQUINE) descript = "colt-like";
						else descript = "lengthy";
					} else descript = "sizable";
				} else if (cocks[cockNum].cLength() < 14) {
					rando = this.rand(3);
					if (rando == 0) descript = "huge";
					else if (rando == 1) {
						if (cocks[cockNum].cType == GLOBAL.TYPE_CANINE) descript = "mastiff-like";
						else descript = "cucumber-length";
					} else descript = "foot-long";
				} else if (cocks[cockNum].cLength() < 18) {
					rando = this.rand(3);
					if (rando == 0) descript = "massive";
					else if (rando == 1) descript = "knee-length";
					else descript = "forearm-length";
				} else if (cocks[cockNum].cLength() < 30) {
					rando = this.rand(3);
					if (rando == 0) descript = "enormous";
					else if (rando == 1) descript = "giant";
					else descript = "arm-length";
				} else if (cocks[cockNum].cLength() < 50) {
					rando = this.rand(7);
					if (cocks[cockNum].cType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "towering";
						else if (rando == 1) descript = "freakish";
						else if (rando == 2) descript = "monstrous";
						else if (rando == 3) descript = "imposing";
						else if (rando == 4) descript = "prodigious";
						else if (rando == 5) descript = "hyper";
						else descript = "massive";
					}
				} else if (cocks[cockNum].cLength() < 100) {
					rando = this.rand(8);
					if (cocks[cockNum].cType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "person-sized";
						else if (rando == 1) descript = "ridiculously massive";
						else if (rando == 2) descript = "extremely prodigious";
						else if (rando == 3) descript = "overly imposing";
						else if (rando == 4) descript = "floor-dragging";
						else if (rando == 5) descript = "colossal";
						else if (rando == 6) descript = "very hyper";
						else descript = "monumental";
					}
				} else {
					rando = this.rand(6);
					if (cocks[cockNum].cType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "car-sized";
						else if (rando == 1) descript = "vehicle-sized";
						else if (rando == 2) descript = "movement-impairing";
						else if (rando == 3) descript = "floor-dragging";
						else if (rando == 4) descript = "extremely hyper";
						else descript = "monumental";
					}
				}
			}
			//Hornyness 1/2
			else if (lust() > 75 && this.rand(2) == 0) {
				//Uber horny like a baws!
				if (lust() > 90) {
					//Weak as shit cum
					if (cumQ() < 50) {
						if (this.rand(2) == 0) descript += "throbbing";
						else descript += "pulsating";
					}
					//lots of cum? drippy.
					else if (cumQ() < 200) {
						rando = this.rand(3);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else descript += "leaking";
					}
					//Tons of cum
					else {
						rando = this.rand(5);
						if (rando == 0) descript += "very drippy";
						else if (rando == 1) descript += "pre-gushing";
						else if (rando == 2) descript += "cum-bubbling";
						else if (rando == 3) descript += "pre-slicked";
						else descript += "pre-drooling";
					}
				}
				//A little less lusty, but still lusty.
				else if (lust() > 75) {
					if (cumQ() < 50) {
						rando = this.rand(5);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else descript += "eager";
					}
					//A little drippy
					else if (cumQ() < 200) {
						rando = this.rand(10);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else if (rando == 4) descript += "eager";
						else if (rando < 7) descript += "fluid-beading";
						else descript += "slowly-oozing";
					}
					//uber drippy
					else {
						rando = this.rand(4);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else if (rando == 2) descript += "fluid-leaking";
						else descript += "leaking";
					}
				}
			}
			//Girth - fallback
			else {
				if (cocks[cockNum].thickness() <= .99) {
					rando = this.rand(3);
					if (rando == 0) descript += "thin";
					else if (rando == 1) descript += "slender";
					else descript += "narrow";
				} else if (cocks[cockNum].thickness() <= 1.2) {
					rando = this.rand(3);
					if (rando == 0) descript += "ordinary";
					else if (rando == 1) descript += "fleshy";
					else descript += "substantial";
				} else if (cocks[cockNum].thickness() <= 1.6) {
					rando = this.rand(3);
					if (rando == 0) descript += "ample";
					else if (rando == 1) descript += "meaty";
					else descript += "generously-proportioned";
				} else if (cocks[cockNum].thickness() <= 2) {
					rando = this.rand(4);
					if (rando == 0) descript += "broad";
					else if (rando == 1) descript += "girthy";
					else if (rando == 2) descript += "expansive";
					else descript += "thick";
				} else if (cocks[cockNum].thickness() <= 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "fat";
					else if (rando == 1) descript += "wide";
					else if (rando == 2) descript += "voluminous";
					else descript += "distended";
				} else if (cocks[cockNum].thickness() > 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "inhumanly distended";
					else if (rando == 1) descript += "bloated";
					else if (rando == 2) descript += "mammoth";
					else descript += "monstrously thick";
				}
			}
			return descript;
		}
		//New cock adjectives.  The old one sucked dicks
		public function statCockAdjective(l: int, w: int, type: int = 0) {
			var descript: String = "";
			var rando: Number = 0;
			var multi: Boolean = false;
			//Goo - 1/4 chance
			if (skinType == GLOBAL.SKIN_TYPE_GOO && this.rand(4) == 0) {
				rando = this.rand(3);
				if (rando == 0) descript += "goopey";
				else if (rando == 1) descript += "gooey";
				else descript += "slimy";
			}
			//Length 1/3 chance
			else if (this.rand(3) == 0) {
				if (l < 3) {
					rando = this.rand(4);
					if (rando == 0) descript = "little";
					else if (rando == 1) descript = "toy-sized";
					else if (rando == 2) descript = "mini";
					else if (rando == 3) descript = "budding";
					else descript = "tiny";
				} else if (l < 5) {
					rando = this.rand(2);
					if (rando == 0) descript = "short";
					else descript = "small";
				} else if (l < 7) {
					rando = this.rand(2);
					if (rando == 0) descript = "fair-sized";
					else descript = "nice";
				} else if (l < 11) {
					rando = this.rand(3);
					if (rando == 0) {
						if (type == GLOBAL.TYPE_EQUINE) descript = "pony-sized";
						else descript = "long";
					} else if (rando == 1) {
						if (type == GLOBAL.TYPE_EQUINE) descript = "colt-like";
						else descript = "lengthy";
					} else descript = "sizable";
				} else if (l < 14) {
					rando = this.rand(3);
					if (rando == 0) descript = "huge";
					else if (rando == 1) {
						if (type == GLOBAL.TYPE_CANINE) descript = "mastiff-like";
						else descript = "cucumber-length";
					} else descript = "foot-long";
				} else if (l < 18) {
					rando = this.rand(3);
					if (rando == 0) descript = "massive";
					else if (rando == 1) descript = "knee-length";
					else descript = "forearm-length";
				} else if (l < 30) {
					rando = this.rand(3);
					if (rando == 0) descript = "enormous";
					else if (rando == 1) descript = "giant";
					else descript = "arm-length";
				} else if (l < 50) {
					rando = this.rand(7);
					if (type == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "towering";
						else if (rando == 1) descript = "freakish";
						else if (rando == 2) descript = "monstrous";
						else if (rando == 3) descript = "imposing";
						else if (rando == 4) descript = "prodigious";
						else if (rando == 5) descript = "hyper";
						else descript = "massive";
					}
				} else if (l < 100) {
					rando = this.rand(8);
					if (type == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "person-sized";
						else if (rando == 1) descript = "ridiculously massive";
						else if (rando == 2) descript = "extremely prodigious";
						else if (rando == 3) descript = "overly imposing";
						else if (rando == 4) descript = "floor-dragging";
						else if (rando == 5) descript = "colossal";
						else if (rando == 6) descript = "very hyper";
						else descript = "monumental";
					}
				} else {
					rando = this.rand(6);
					if (type == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "car-sized";
						else if (rando == 1) descript = "vehicle-sized";
						else if (rando == 2) descript = "movement-impairing";
						else if (rando == 3) descript = "floor-dragging";
						else if (rando == 4) descript = "extremely hyper";
						else descript = "monumental";
					}
				}
			}
			//Hornyness 1/2
			else if (lust() > 75 && this.rand(2) == 0) {
				//Uber horny like a baws!
				if (lust() > 90) {
					//Weak as shit cum
					if (cumQ() < 50) {
						if (this.rand(2) == 0) descript += "throbbing";
						else descript += "pulsating";
					}
					//lots of cum? drippy.
					else if (cumQ() < 200) {
						rando = this.rand(3);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else descript += "leaking";
					}
					//Tons of cum
					else {
						rando = this.rand(5);
						if (rando == 0) descript += "very drippy";
						else if (rando == 1) descript += "pre-gushing";
						else if (rando == 2) descript += "cum-bubbling";
						else if (rando == 3) descript += "pre-slicked";
						else descript += "pre-drooling";
					}
				}
				//A little less lusty, but still lusty.
				else if (lust() > 75) {
					if (cumQ() < 50) {
						rando = this.rand(5);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else descript += "eager";
					}
					//A little drippy
					else if (cumQ() < 200) {
						rando = this.rand(10);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else if (rando == 4) descript += "eager";
						else if (rando < 7) descript += "fluid-beading";
						else descript += "slowly-oozing";
					}
					//uber drippy
					else {
						rando = this.rand(4);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else if (rando == 2) descript += "fluid-leaking";
						else descript += "leaking";
					}
				}
			}
			//Girth - fallback
			else {
				if (w <= .99) {
					rando = this.rand(3);
					if (rando == 0) descript += "thin";
					else if (rando == 1) descript += "slender";
					else descript += "narrow";
				} else if (w <= 1.2) {
					rando = this.rand(3);
					if (rando == 0) descript += "ordinary";
					else if (rando == 1) descript += "fleshy";
					else descript += "substantial";
				} else if (w <= 1.6) {
					rando = this.rand(3);
					if (rando == 0) descript += "ample";
					else if (rando == 1) descript += "meaty";
					else descript += "generously-proportioned";
				} else if (w <= 2) {
					rando = this.rand(4);
					if (rando == 0) descript += "broad";
					else if (rando == 1) descript += "girthy";
					else if (rando == 2) descript += "expansive";
					else descript += "thick";
				} else if (w <= 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "fat";
					else if (rando == 1) descript += "wide";
					else if (rando == 2) descript += "voluminous";
					else descript += "distended";
				} else if (w > 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "inhumanly distended";
					else if (rando == 1) descript += "bloated";
					else if (rando == 2) descript += "mammoth";
					else descript += "monstrously thick";
				}
			}
			return descript;
		}
		public function nippleLength(row: int = 0): Number {
			if (row >= bRows()) return 0;
			else if (row < 0) return 0;
			else return nippleLengthRatio * .25 * ((10 + breastRows[row].breastRating()) / 10)
		}
		public function nippleWidth(row: int = 0): Number {
			if (row >= bRows()) return 0;
			else if (row < 0) return 0;
			else return nippleWidthRatio * .5 * ((10 + breastRows[row].breastRating()) / 10)
		}
		//New cock adjectives.  The old one sucked dicks
		public function nippleCockAdjective(plural: Boolean = false) {
			var descript: String = "";
			var rando: Number = 0;
			var l: Number = nippleLength(0) * dickNippleMultiplier;
			var w: Number;
			if (l <= 10) w = l / 6;
			else if (l <= 30) w = (l - 10) / 10 + 10 / 6;
			else w = 20 / 10 + 10 / 6 + (l - 30) / 20;
			//Nipple descriptions 1/4 of the time!
			if (this.rand(4) == 0) {
				if (this.rand(3) == 0) descript += "nipple-sheathed";
				else if (this.rand(2) == 0) descript += nippleColor + "-surrounded";
				else {
					if (plural) descript += "areola-wreathed";
					else descript += "areolae-wreathed";
				}
			}
			//Goo - 1/4 chance
			else if (skinType == GLOBAL.SKIN_TYPE_GOO && this.rand(4) == 0) {
				rando = this.rand(3);
				if (rando == 0) descript += "goopey";
				else if (rando == 1) descript += "gooey";
				else descript += "slimy";
			}
			//Length 1/3 chance
			else if (this.rand(3) == 0) {
				if (l < 3) {
					rando = this.rand(4);
					if (rando <= 1) descript = "little";
					else if (rando == 2) descript = "mini";
					else if (rando == 3) descript = "budding";
					else descript = "tiny";
				} else if (l < 5) {
					rando = this.rand(2);
					if (rando == 0) descript = "short";
					else descript = "small";
				} else if (l < 7) {
					rando = this.rand(2);
					if (rando == 0) descript = "fair-sized";
					else descript = "nice";
				} else if (l < 11) {
					rando = this.rand(3);
					if (rando == 0) {
						if (dickNippleType == GLOBAL.TYPE_EQUINE) descript = "pony-sized";
						else descript = "long";
					} else if (rando == 1) {
						if (dickNippleType == GLOBAL.TYPE_EQUINE) descript = "colt-like";
						else descript = "lengthy";
					} else descript = "sizable";
				} else if (l < 14) {
					rando = this.rand(3);
					if (rando == 0) descript = "huge";
					else if (rando == 1) {
						if (dickNippleType == GLOBAL.TYPE_CANINE) descript = "mastiff-like";
						else descript = "cucumber-length";
					} else descript = "foot-long";
				} else if (l < 18) {
					rando = this.rand(3);
					if (rando == 0) descript = "massive";
					else if (rando == 1) descript = "knee-length";
					else descript = "forearm-length";
				} else if (l < 30) {
					rando = this.rand(3);
					if (rando == 0) descript = "enormous";
					else if (rando == 1) descript = "giant";
					else descript = "arm-length";
				} else if (l < 50) {
					rando = this.rand(7);
					if (dickNippleType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "towering";
						else if (rando == 1) descript = "freakish";
						else if (rando == 2) descript = "monstrous";
						else if (rando == 3) descript = "imposing";
						else if (rando == 4) descript = "prodigious";
						else if (rando == 5) descript = "hyper";
						else descript = "massive";
					}
				} else if (l < 100) {
					rando = this.rand(8);
					if (dickNippleType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "person-sized";
						else if (rando == 1) descript = "ridiculously massive";
						else if (rando == 2) descript = "extremely prodigious";
						else if (rando == 3) descript = "overly imposing";
						else if (rando == 4) descript = "floor-dragging";
						else if (rando == 5) descript = "colossal";
						else if (rando == 6) descript = "very hyper";
						else descript = "monumental";
					}
				} else {
					rando = this.rand(6);
					if (dickNippleType == GLOBAL.TYPE_FELINE && this.rand(4) == 0) descript = "coiled ";
					else {
						if (rando == 0) descript = "car-sized";
						else if (rando == 1) descript = "vehicle-sized";
						else if (rando == 2) descript = "movement-impairing";
						else if (rando == 3) descript = "floor-dragging";
						else if (rando == 4) descript = "extremely hyper";
						else descript = "monumental";
					}
				}
			}
			//Hornyness 1/2
			else if (lust() > 75 && this.rand(2) == 0) {
				//Uber horny like a baws!
				if (lust() > 90) {
					//Weak as shit cum
					if (cumQ() < 50) {
						if (this.rand(2) == 0) descript += "throbbing";
						else descript += "pulsating";
					}
					//lots of cum? drippy.
					else if (cumQ() < 200) {
						rando = this.rand(3);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else descript += "leaking";
					}
					//Tons of cum
					else {
						rando = this.rand(5);
						if (rando == 0) descript += "very drippy";
						else if (rando == 1) descript += "pre-gushing";
						else if (rando == 2) descript += "cum-bubbling";
						else if (rando == 3) descript += "pre-slicked";
						else descript += "pre-drooling";
					}
				}
				//A little less lusty, but still lusty.
				else if (lust() > 75) {
					if (cumQ() < 50) {
						rando = this.rand(5);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else descript += "eager";
					}
					//A little drippy
					else if (cumQ() < 200) {
						rando = this.rand(10);
						if (rando == 0) descript += "turgid";
						else if (rando == 1) descript += "blood-engorged";
						else if (rando == 2) descript += "rock-hard";
						else if (rando == 3) descript += "stiff";
						else if (rando == 4) descript += "eager";
						else if (rando < 7) descript += "fluid-beading";
						else descript += "slowly-oozing";
					}
					//uber drippy
					else {
						rando = this.rand(4);
						if (rando == 0) descript += "dribbling";
						else if (rando == 1) descript += "drooling";
						else if (rando == 2) descript += "fluid-leaking";
						else descript += "leaking";
					}
				}
			}
			//Girth - fallback
			else {
				if (w <= .99) {
					rando = this.rand(3);
					if (rando == 0) descript += "thin";
					else if (rando == 1) descript += "slender";
					else descript += "narrow";
				} else if (w <= 1.2) {
					rando = this.rand(3);
					if (rando == 0) descript += "ordinary";
					else if (rando == 1) descript += "fleshy";
					else descript += "substantial";
				} else if (w <= 1.6) {
					rando = this.rand(3);
					if (rando == 0) descript += "ample";
					else if (rando == 1) descript += "meaty";
					else descript += "generously-proportioned";
				} else if (w <= 2) {
					rando = this.rand(4);
					if (rando == 0) descript += "broad";
					else if (rando == 1) descript += "girthy";
					else if (rando == 2) descript += "expansive";
					else descript += "thick";
				} else if (w <= 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "fat";
					else if (rando == 1) descript += "wide";
					else if (rando == 2) descript += "voluminous";
					else descript += "distended";
				} else if (w > 3.5) {
					rando = this.rand(4);
					if (rando == 0) descript += "inhumanly distended";
					else if (rando == 1) descript += "bloated";
					else if (rando == 2) descript += "mammoth";
					else descript += "monstrously thick";
				}
			}
			return descript;
		}
		public function cumColor(): String {
			return fluidColor(cumType);
		}
		public function milkColor(): String {
			return fluidColor(milkType);
		}
		public function girlCumColor(): String {
			return fluidColor(girlCumType);
		}
		public function fluidFlavor(arg: int):String {
			var temp:int = rand(10);
			//CUM & MILK TYPES
			if (arg == GLOBAL.FLUID_TYPE_MILK)
			{
				if (temp <= 4) return "creamy";
				else if (temp <= 7) return "delicious";
				else if (temp <= 8) return "sweet";
				else return "creamy";
			} else if(arg == GLOBAL.FLUID_TYPE_CUM) {
				if (temp <= 6) return "salty";
				else return "potent";
			} else if (arg == GLOBAL.FLUID_TYPE_HONEY) {
				if (temp <= 4) return "sweet";
				else if (temp <= 7) return "syrupy";
				else return "sugary";
			} else if (arg == GLOBAL.FLUID_TYPE_OIL) {
				return "tasteless";
			} else if (arg == GLOBAL.FLUID_TYPE_MILKSAP) {
				if (temp <= 4) return "creamy";
				else if (temp <= 7) return "sweet";
				else if (temp <= 8) return "sugary";
				else return "delicious";
			} else if (arg == GLOBAL.FLUID_TYPE_GIRLCUM) {
				if (temp <= 6) return "tangy";
				else return "flavorful";
			} else if (arg == GLOBAL.FLUID_TYPE_CUMSAP) {
				if (temp <= 4) return "salty-sweet";
				else if (temp <= 7) return "syrupy";
				else return "salty";
			} else if (arg == GLOBAL.FLUID_TYPE_CHOCOLATE_MILK)
			{
				if (temp <= 2) return "creamy";
				else if (temp <= 4) return "delicious";
				else if (temp <= 5) return "sweet";
				else if (temp <= 8) return "chocolatey";
				else return "rich";
			} 
			return "bland";
		}
		public function fluidViscosity(arg: int):String {
			var temp:int = rand(10);
			//CUM & MILK TYPES
			if (arg == GLOBAL.FLUID_TYPE_MILK || arg == GLOBAL.FLUID_TYPE_CHOCOLATE_MILK)
			{
				return "creamy";
			} else if(arg == GLOBAL.FLUID_TYPE_CUM) {
				if (temp <= 5) return "thick";
				else if (temp <= 7) return "slick";
				else return "creamy";
			} else if (arg == GLOBAL.FLUID_TYPE_HONEY) {
				if (temp <= 5) return "sticky";
				else return "slick";
			} else if (arg == GLOBAL.FLUID_TYPE_OIL) {
				if (temp <= 4) return "slippery";
				return "slick";
			} else if (arg == GLOBAL.FLUID_TYPE_MILKSAP) {
				if (temp <= 4) return "creamy";
				else return "syrupy";
			} else if (arg == GLOBAL.FLUID_TYPE_GIRLCUM) {
				if (temp <= 6) return "slick";
				else return "slippery";
			} else if (arg == GLOBAL.FLUID_TYPE_CUMSAP) {
				if (temp <= 4) return "slick";
				else if (temp <= 7) return "sticky";
				else return "syrupy";
			}
			return "fluid";
		}
		public function fluidColor(arg: int): String {
			var temp: int = this.rand(10);
			//CUM & MILK TYPES
			if (arg == GLOBAL.FLUID_TYPE_MILK || arg == GLOBAL.FLUID_TYPE_CUM) {
				if (temp <= 4) return "white";
				else if (temp <= 6) return "alabaster";
				else if (temp <= 7) return "ivory";
				else return "pearly";
			} else if (arg == GLOBAL.FLUID_TYPE_HONEY) {
				if (temp <= 4) return "amber";
				else if (temp <= 7) return "yellow";
				else if (temp <= 8) return "gold";
				else return "tawny";
			} else if (arg == GLOBAL.FLUID_TYPE_OIL) {
				if (temp <= 4) return "semi-transparent";
				else if (temp <= 7) return "transluscent brown";
				else return "lucent";
			} else if (arg == GLOBAL.FLUID_TYPE_MILKSAP) {
				if (temp <= 4) return "whitish-yellow";
				else if (temp <= 7) return "ivory gold";
				else if (temp <= 8) return "off-white";
				else return "pearly";
			} else if (arg == GLOBAL.FLUID_TYPE_GIRLCUM) {
				if (temp <= 4) return "transluscent";
				else if (temp <= 7) return "clear";
				else return "semi-transparent";
			} else if (arg == GLOBAL.FLUID_TYPE_CUMSAP) {
				if (temp <= 4) return "off white";
				else if (temp <= 7) return "pearl-marbled amber";
				else return "ivory-amber";
			} else if(arg == GLOBAL.FLUID_TYPE_CHOCOLATE_MILK) {
				if (temp <= 4) return "chocolate";
				else if(temp <= 7) return "creamy brown, chocolate";
				else return "dark, chocolate";
			} else if (arg == GLOBAL.FLUID_TYPE_VANAE_MAIDEN_MILK) {
				if (temp <= 4) return "pink";
				else if (temp <= 7) return "milky-pink";
				else return "pink-marbled cream";
			} else if (arg == GLOBAL.FLUID_TYPE_VANAE_HUNTRESS_MILK) {
				if (temp <= 4) return "violet";
				else if (temp <= 7) return "milky-violet";
				else return "violet-marbled cream";
			}
			
			return "ERROR, INVALID FLUID TYPE.";
		}
		public function fluidNoun(arg: int): String {
			var temp: int = this.rand(10);
			//CUM & MILK TYPES
			if (arg == GLOBAL.FLUID_TYPE_MILK) {
				if (temp <= 4) return "milk";
				else return "cream";
			} else if (arg == GLOBAL.FLUID_TYPE_CUM) {
				return "cum";
			} else if (arg == GLOBAL.FLUID_TYPE_HONEY) {
				return "honey";
			} else if (arg == GLOBAL.FLUID_TYPE_OIL) {
				return "oil";
			} else if (arg == GLOBAL.FLUID_TYPE_MILKSAP) {
				return "milk-sap";
			} else if (arg == GLOBAL.FLUID_TYPE_GIRLCUM) {
				return "girl-cum";
			} else if (arg == GLOBAL.FLUID_TYPE_CUMSAP) {
				if (rand(4) <= 1) return "cum-sap";
				else if (rand(2) == 0) return "botanical spunk";
				else return "floral jism";
			} else if(arg == GLOBAL.FLUID_TYPE_CHOCOLATE_MILK) {
				return "milk";
			} else if (arg == GLOBAL.FLUID_TYPE_VANAE_MAIDEN_MILK || arg == GLOBAL.FLUID_TYPE_VANAE_HUNTRESS_MILK) {
				return "milk";
			}
			return "ERROR: NONVALID FLUID TYPE PASSED TO fluidNoun";
		}
		public function milkDescript(): String {
			var temp: int = this.rand(10);
			var desc: String = "";
			var described: Boolean = false;
			if (this.rand(3) == 0) {
				desc += fluidColor(milkType);
				described = true;
			}
			if (described) desc += " ";
			desc += fluidNoun(milkType);
			return desc;
		}
		public function cumDescript(): String {
			var temp: int = this.rand(10);
			var desc: String = "";
			var described: Boolean = false;
			if (this.rand(3) == 0) {
				desc += fluidColor(cumType);
				described = true;
			}
			if (described) desc += " ";
			desc += fluidNoun(cumType);
			return desc;
		}
		public function girlCumDescript(): String {
			var temp: int = this.rand(10);
			var desc: String = "";
			var described: Boolean = false;
			if (this.rand(3) == 0) {
				desc += fluidColor(girlCumType);
				described = true;
			}
			if (described) desc += " ";
			desc += fluidNoun(girlCumType);
			return desc;
		}
		public function nippleCockDescript(): String {
			var descript: String = "";
			//Non boring descriptions!
			//70% of the time add a descriptor
			if (this.rand(10) <= 6) {
				descript += nippleCockAdjective();
				//50% of the time add supplimental cock adjective with the noun.
				if (this.rand(2) == 0) descript += ", " + cockNoun(dickNippleType, false);
				//Otherwise normal
				else descript += " " + cockNoun(dickNippleType, true);
			}
			//These guys get a bonus adjective 70% of the time.
			else {
				if (this.rand(10) <= 6) descript += cockNoun(dickNippleType, false);
				else descript += cockNoun(dickNippleType);
			}
			return descript;
		}
		public function nippleCocksDescript(appearance: Boolean = false): String {
			var descript: String = "";
			//Non boring descriptions!
			//70% of the time add a descriptor
			if (this.rand(10) <= 6 && !appearance) {
				descript += nippleCockAdjective();
				//50% of the time add supplimental cock adjective with the noun.
				if (this.rand(2) == 0) descript += ", " + cockNoun(dickNippleType, false);
				//Otherwise normal
				else descript += " " + cockNoun(dickNippleType, true);
			}
			//These guys get a bonus adjective 70% of the time.
			else {
				if (this.rand(10) <= 6 && !appearance) descript += cockNoun(dickNippleType, false);
				else descript += cockNoun(dickNippleType);
			}
			return pluralize(descript);
		}
		public function cockColor(arg2:int = 0):String
		{
			if(!hasCock() || arg2 < 0 || arg2 >= cockTotal()) return "ERROR";
			else return cocks[arg2].cockColor;
		}
		public function vaginaColor(arg2:int = 0):String
		{
			if(!hasVagina() || arg2 < 0 || arg2 >= vaginaTotal()) return "ERROR";
			else return vaginas[arg2].vaginaColor;	
		}
		public function cockDescript(cockNum: Number = 0): String {
			if (totalCocks() == 0) return "<b>ERROR: CockDescript Called But No Cock Present</b>";
			if (cockTotal() <= cockNum && cockNum != 99) return "<b>ERROR: CockDescript called with index of " + cockNum + " - out of BOUNDS</b>";

			var descript: String = "";
			//Non boring descriptions!
			if (cockNum != 99) {
				//70% of the time add a descriptor
				if (this.rand(10) <= 6) {
					descript += cockAdjective(cockNum);
					//50% of the time add supplimental cock adjective with the noun.
					if (this.rand(2) == 0) {
						descript += ", " + cockNoun(cocks[cockNum].cType, false);
					}
					//Otherwise normal
					else descript += " " + cockNoun(cocks[cockNum].cType, true);
				}
				//These guys get a bonus adjective 70% of the time.
				else {
					if (this.rand(10) <= 6) descript += cockNoun(cocks[cockNum].cType, false);
					else descript += cockNoun(cocks[cockNum].cType);
				}
			}
			//Boring descriptions. Mostly the same but kinda lame, actually.
			else {
				//70% of the time add a descriptor
				if (this.rand(10) <= 6) descript += cockAdjective(-1) + " " + cockNoun(0);
				else descript += cockNoun(0);
			}
			return descript;
		}
		public function tailCockDescript(): String {
			var descript: String = "";
			//Non boring descriptions!

			//70% of the time add a descriptor
			if (this.rand(10) <= 6) {
				descript += statCockAdjective(8, 2);
				//50% of the time add supplimental cock adjective with the noun.
				if (this.rand(2) == 0) descript += ", " + cockNoun(tailGenitalArg, false, true);
				//Otherwise normal
				else descript += " " + cockNoun(tailGenitalArg, false, true);
			}
			//These guys get a bonus adjective 70% of the time.
			else {
				if (this.rand(10) <= 6) descript += cockNoun(tailGenitalArg, false, true);
				else descript += cockNoun(tailGenitalArg, true, true);
			}
			return descript;
		}
		public function allBreastsDescript(): String {
			var storage: String = "";
			var temp: int;
			if (breastRows.length == 0) {
				temp = this.rand(5);
				if (temp == 0) return "unremarkable chest muscles";
				else if (temp == 1) return "chest";
				else if (temp == 2) return "pectorals";
				else if (temp == 3) return "flat chest";
				else return mf("manly", "boyish") + " chest";
			}
			if (breastRows.length == 2) {
				temp = this.rand(2);
				if (totalBreasts() == 4 && temp == 0) storage += "quad ";
				else if (totalBreasts() == 4) storage += "four ";
				else storage += "two rows of ";
			}
			if (breastRows.length == 3) {
				if (this.rand(2) == 0) storage += "three rows of ";
				else storage += "multi-layered ";
			}
			if (breastRows.length == 4) {
				if (this.rand(2) == 0) storage += "four rows of ";
				else storage += "four-tiered ";
			}
			if (breastRows.length == 5) {
				if (this.rand(2) == 0) storage += "five rows of ";
				else storage += "five-tiered ";
			}
			storage += biggestBreastDescript();
			return storage;
		}
		public function breastSize(val: Number): String {
			var descript: String = "";
			var choice: Number = 0;
			//Catch all for dudes.
			if (val < 1) return "manly";
			//Small - A->B
			if (val <= 2) {
				choice = this.rand(4);
				if (choice == 0) descript += "palmable";
				else if (choice == 1) descript += "tight";
				else if (choice == 2) descript += "perky";
				else if (choice == 3) descript += "baseball-sized";
			}
			//C-D
			else if (val <= 4) {
				choice = this.rand(5);
				if (choice == 0) descript += "nice";
				else if (choice == 1) descript += "hand-filling";
				else if (choice == 2) descript += "well-rounded";
				else if (choice == 3) descript += "supple";
				//else if(choice == 4) descript += "softball-sized ";
			}
			//DD->big EE
			else if (val < 11) {
				choice = this.rand(5);
				if (choice == 0) descript += "big";
				if (choice == 1) descript += "large";
				if (choice == 2) descript += "pillowy";
				if (choice == 3) descript += "jiggly";
				if (choice == 4) descript += "volleyball-sized";
			}
			//F->big FF
			else if (val < 15) {
				choice = this.rand(4);
				if (choice == 0) descript += "soccerball-sized";
				else if (choice == 1) descript += "hand-overflowing";
				else if (choice == 2) descript += "generous";
				else if (choice == 3) descript += "jiggling";
			}
			//G -> HHH
			else if (val < 24) {
				choice = this.rand(4);
				if (choice == 0) descript += "basketball-sized";
				else if (choice == 1) descript += "whorish";
				else if (choice == 2) descript += "cushiony";
				else if (choice == 3) descript += "wobbling";
			}
			//I -> KK
			else if (val < 35) {
				choice = this.rand(4);
				if (choice == 0) descript += "massive motherly";
				else if (choice == 1) descript += "luscious";
				else if (choice == 2) descript += "smothering";
				else descript += "prodigious";
			}
			//K- > MMM+
			else {
				choice = this.rand(5);
				if (choice == 0) descript += "mountainous";
				else if (choice == 1) descript += "monumental";
				else if (choice == 2) descript += "back-breaking";
				else if (choice == 3) descript += "exercise-ball-sized";
				else descript += "immense";
			}
			return descript;
		}
		public function breastDescript(rowNum: Number): String {
			//ERROR PREVENTION
			if (breastRows.length - 1 < rowNum) return "<b>ERROR, breastDescript() working with invalid breastRow</b>";
			if (breastRows.length == 0) return "<b>ERROR, breastDescript() called when no breasts are present.</b>";

			var temp: int;
			var descript: String = "";
			var noun: String = "";
			var descripted: Boolean = false;
			if (breastRows[rowNum].breastRating() < 1) {
				temp = this.rand(10);
				if (temp <= 3) return "pecs";
				else if (temp <= 6) return "flat, almost non-existant breasts";
				else return "pectoral muscles";
			}
			//50% of the time size-descript them
			if (this.rand(2) == 0) {
				descript += breastSize(breastRows[rowNum].breastRating());
				descripted = true;
			}
			if (isLactating() > 1.5) {
				if (descripted) descript += ", ";
				if (milkType == GLOBAL.FLUID_TYPE_MILK) {
					temp = this.rand(4);
					if (temp == 0) descript += "lactating";
					else if (temp == 1) descript += "milky";
					else if (temp == 2) descript += "milk-filled";
					else descript += "fluid-filled";
				} else if (milkType == GLOBAL.FLUID_TYPE_HONEY) {
					temp = this.rand(4);
					if (temp == 0) descript += "honey-filled";
					else if (temp == 1) descript += "honey-stuffed";
					else if (temp == 2) descript += "sweet";
					else descript += "fluid-filled";
				}
				//Generic catch all
				else {
					temp = this.rand(2);
					if (temp == 0) descript += "lactating";
					else descript += "fluid-filled";
				}
				descripted = true;
			}
			//Nouns!
			temp = this.rand(14);
			if (temp == 0) noun += "breasts";
			else if (temp <= 1) {
				if (isLactating()) noun += "udders";
				else noun += "breasts";
			} else if (temp <= 3) {
				if (breastRows[rowNum].breastRating() > 4 && this.rand(2) == 0) noun += "tits";
				else noun += "breasts";
			} else if (temp <= 6) noun += "tits";
			else if (temp <= 7) {
				if (!isLactating()) noun += "jugs";
				else noun += "udders";
			} else if (temp <= 8) {
				if (breastRows[rowNum].breastRating() > 6) noun += "love-pillows";
				else noun += "boobs";
			} else if (temp <= 9) {
				if (breastRows[rowNum].breastRating() > 6) noun += "tits";
				else noun += "breasts";
			} else if (temp <= 11) noun += "mammaries";
			else if (temp <= 12) noun += "melons";
			else noun += "mounds";
			if (descripted) descript += " ";
			return descript + noun;
		}
		public function biggestBreastDescript(): String {
			return (breastDescript(biggestTitRow()));
		}
		public function eachCockHead(): String {
			if (cockTotal() == 1) return "your " + cockHead(-1);
			else return "each of your " + pluralize(cockHead(-1));
		}
		public function oneCockHead(): String {
			if (cockTotal() == 1) return "your " + cockHead(-1);
			else return "one of your " + pluralize(cockHead(-1));
		}
		public function cockHead(cockNum: Number = 0): String {
			var temp: int;
			var type: int;
			if (cocks.length == 0)
				return "ERROR. CockHead lookup with no cocks!";
			if (cockNum < 0) type = GLOBAL.TYPE_HUMAN;
			else type = cocks[cockNum].cType;
			if (cockNum > cocks.length - 1) return "ERROR";

			return cockHeadGetName(type);
		}
		public function cockHeads(cockNum:Number = 0):String {
			if(cockTotal() == 1) return cockHead(cockNum);
			else return pluralize(cockHead(cockNum));
		}
		public function tailCockHead(): String {
			if (!hasTailCock()) return "|||<b>ERROR:</b> No tail cock to describe |||";
			return cockHeadGetName(tailGenitalArg);
		}
		public function cockHeadGetName(type: int = 0): String {
			var temp: int;
			var type: int;
			if (cocks.length == 0)
				return "ERROR. CockHead lookup with no cocks!";
			if (type == GLOBAL.TYPE_EQUINE) {
				temp = this.rand(5);
				if (temp == 0) return "flare";
				else if (temp <= 1) return "blunt head";
				else if (temp <= 2) return "equine glans";
				else if (temp <= 3) return "flat tip";
				else return "cock-head";
			} else if (type == GLOBAL.TYPE_CANINE || type == GLOBAL.TYPE_VULPINE) {
				temp = this.rand(5);
				if (temp == 0) return "canine crown";
				else if (temp <= 1) return "pointed cock-head";
				else if (temp <= 2) return "narrow glans";
				else if (temp <= 3) return "tip";
				else return "cock-head";
			} else if (type == GLOBAL.TYPE_DEMONIC) {
				temp = this.rand(5);
				if (temp == 0) return "tainted crown";
				else if (temp <= 1) return "nubby head";
				else if (temp <= 2) return "demonic glans";
				else if (temp <= 3) return "nub-ringed tip";
				else return "cock-head";
			} else if (type == GLOBAL.TYPE_TENTACLE) {
				temp = this.rand(6);
				if (temp == 0) return "crown";
				else if (temp <= 1) return "tentacle-head";
				else if (temp <= 2) return "floral glans";
				else if (temp <= 3) return "tip";
				else if (temp <= 4) return "mushroom-like tip";
				else return "wide, plant-like crown";
			} else if (type == GLOBAL.TYPE_NAGA || type == GLOBAL.TYPE_LIZAN || type == GLOBAL.TYPE_SNAKE) {
				temp = this.rand(6);
				if (temp == 0) return "point";
				else if (temp <= 1) return "narrow tip";
				else if (temp <= 2) return "purple, pointed glans";
				else if (temp <= 3) return "tip";
				else if (temp <= 4) return "violet tip";
				else return "reptilian crown";
			} else if (type == GLOBAL.TYPE_ANEMONE || type == GLOBAL.TYPE_SIREN) {
				temp = this.rand(6);
				if (temp == 0) return "blue tip";
				else if (temp == 1) return "tentacle-ringed glans";
				else if (temp == 2) return "exotic cock-head";
				else if (temp == 3) return "aphrodisiac-laced head";
				else return "wiggling crown";
			}
			/*if(cocks[cockNum].cType == 10) {
				temp = this.rand(5);
				if(temp == 0) return "star tip";
				else if(temp == 1) return "blooming cock-head";
				else if(temp == 2) return "open crown";
				else if(temp == 3) return "alien tip";
				else return "bizarre head";
			}*/
			else {
				temp = this.rand(5);
				if (temp == 0) return "crown";
				else if (temp <= 1) return "head";
				else if (temp <= 2) return "glans";
				else if (temp <= 3) return "tip";
				else return "cock-head";
			}
		}

		/**
		 * Effectively an interface to define the default sexual preferences for a given creature.
		 * Ensure that the function is overridden before calling this (or the error can be replaced with a "default" set
		 * of possible sexprefs for ALL creatures.
		 */
		public function setDefaultSexualPreferences(): void {
			throw new Error("Sexual preferences must be configured on a per-creature basis before this function should be called! Override the function signature in the child creature class.");
		}

		/**
		 * Effectively an interface to define a method to "reset" a creature for combat; reset its health, energy or whatever,
		 * and set whatever other game-system stuff we need for combat to be "ready"
		 */
		public function prepForCombat(): void {
			throw new Error("Each creature must define its own method to prepare for combat!");
		}
		
		/**
		 * These methods are stubs, intended to be overriden on a character-by-character basis.
		 * Check the PlayerCharacter class to see what I mean.
		 */
		
		public function loadInCunt(cumFrom:Creature, vagIndex:int = -1):Boolean
		{
			return false;
		}
		
		public function loadInAss(cumFrom:Creature):Boolean
		{
			return false;
		}
		public function girlCumInMouth(cumFrom:Creature):Boolean
		{
			return false;
		}
		public function loadInMouth(cumFrom:Creature):Boolean
		{
			return false;
		}
		
		public function loadInNipples(cumFrom:Creature):Boolean
		{
			return false;
		}
		
		public function loadInCuntTail(cumFrom:Creature):Boolean
		{
			return false;
		}
		
		public var bellyRatingRaw:Number = 0;
		public var bellyRatingMod:Number = 0;
		public function bellyRating():Number
		{
			return bellyRatingRaw + bellyRatingMod;
		}
			
		function cuntChange(arg:int, volume:Number, display:Boolean = true, spacingsF:Boolean = true, spacingsB:Boolean = false):Boolean 
		{
			return holeChange(arg,volume,display,spacingsF,spacingsB);
		}
		
		function buttChange(volume:Number, display:Boolean = true, spacingsF:Boolean = true, spacingsB:Boolean = false):Boolean 
		{
			return holeChange(-1,volume,display,spacingsF,spacingsB);
		}
		
		function cockChange(spacingsF:Boolean = true, spacingsB:Boolean = false):Boolean 
		{
			if (cockVirgin && hasCock())
			{
				cockVirgin = false;
				if (spacingsF) output(" ");
				
				if (this is PlayerCharacter)
				{
					output("<b>You have succumbed to your desires and lost your </b>");
					if (hasVagina()) output("<b>masculine </b>");
					output("<b>virginity.</b>");
				}
				else
				{
					output("<b>" + short + " has succumbed to " + mf("his", "her") + " and lost " + mf("his", "her"));
					if (hasVagina()) output(" masculine");
					output(" virginity.</b>");
				}
				
				if (spacingsB) output(" ");
				return true;
			}
			return false;
		}
		
		function holeChange(hole:int, volume:Number, display:Boolean = true, spacingsF:Boolean = true, spacingsB:Boolean = false):Boolean 
		{
			var stretched:Boolean = false;
			var devirgined:Boolean = false;
			var capacity:Number;
			var holePointer:VaginaClass;
			//Set capacity based on the hole.
			if(hole == -1) {
				capacity = analCapacity();
				holePointer = ass;
			}
			else {
				if(hole+1 > totalVaginas()) return false;
				else {
					capacity = vaginalCapacity(hole);
					holePointer = vaginas[hole];
				}
			}
			//cArea > capacity = autostreeeeetch.
			if(volume >= capacity) {
				if(holePointer.looseness() >= 5) {}
				else holePointer.looseness(1);
				stretched = true;
			}
			//If within top 10% of capacity, 50% stretch
			else if(volume >= .9 * capacity && rand(2) == 0) {
				holePointer.looseness(1);
				stretched = true;
			}
			//if within 75th to 90th percentile, 25% stretch
			else if(volume >= .75 * capacity && rand(4) == 0) {
				holePointer.looseness(1);
				stretched = true;
			}
			//If virgin
			if (holePointer.hymen || (hole < 0 && analVirgin) || (hole >= 0 && vaginalVirgin)) {
				if (display)
				{
					if (spacingsF) output(" ");
					if (this is PlayerCharacter)
					{
						if (holePointer.hymen)
						{
							output("<b>Your hymen is torn</b>");
							holePointer.hymen = false;
						}
						else output("<b>You have been penetrated</b>");
						
						if (hole >= 0 && vaginalVirgin) output("<b>, robbing you of your vaginal virginity</b>");
						
						else if (analVirgin) output("<b>, robbing you of your anal virginity</b>");
						
						output("<b>.</b>");
					}
					else
					{
						if (holePointer.hymen)
						{
							output("<b>" + short + "s hymen is torn</b>");
							holePointer.hymen = false;
						}
						else output("<b>" + short + " has been penetrated</b>");
						
						if (hole >= 0 && vaginalVirgin)	output("<b>, robbing " + mf("him", "her") + " of " + mf("his", "her") + " vaginal virginity</b>");
						
						else if (analVirgin) output("<b>, robbing " + mf("him", "her") + " of " + mf("his", "her") + " anal virginity</b>");
						
						output("<b>.</b>");
					}
					if(spacingsB) output(" ");
				}
				
				if (hole >= 0 && vaginalVirgin) vaginalVirgin = false;
				else if (analVirgin) analVirgin = false;
				devirgined = true;
			}
			//Delay anti-stretching
			if(volume >= .35 * capacity) {
				if(hole >= 0) {
					holePointer.shrinkCounter = 0;
				}
				else {
					holePointer.shrinkCounter = 0;
				}
			}
			if(stretched) {
				trace(short + " HOLE CODE #:" + hole + " STRETCHED TO " + holePointer.looseness() + ".");
				//STRETCH SUCCESSFUL - begin flavor text if outputting it!
				if(display) {
					//Virgins get different formatting
					if(devirgined) {
						//If no spaces after virgin loss
						if(!spacingsB) output(" ");
					}
					//Non virgins as usual
					else if(spacingsF) output(" ");
					if (hole >= 0) {
						if (this is PlayerCharacter)
						{
							if(holePointer.looseness() >= 5) output("<b>Your " + vaginaDescript(hole) + " is stretched painfully wide, gaped in a way that practically invites huge monster-cocks to plow you.</b>");
							else if(holePointer.looseness() >= 4) output("<b>Your " + vaginaDescript(hole) + " painfully stretches, the lips now wide enough to gape slightly.</b>");
							else if(holePointer.looseness() >= 3) output("<b>Your " + vaginaDescript(hole) + " is now somewhat loose.</b>");
							else if(holePointer.looseness() >= 2) output("<b>Your " + vaginaDescript(hole) + " is a little more used to insertions.</b>");
							else output("<b>Your " + vaginaDescript(hole) + " is stretched out a little bit.</b>");
						}
						else
						{
							if(holePointer.looseness() >= 5) output("<b>" + short + "s " + vaginaDescript(hole) + " is stretched painfully wide, gaped in a way that practically invites huge monster-cocks to plow " + mf("him", "her") +".</b>");
							else if(holePointer.looseness() >= 4) output("<b>" + short + "s " + vaginaDescript(hole) + " painfully stretches, the lips now wide enough to gape slightly.</b>");
							else if(holePointer.looseness() >= 3) output("<b>" + short + "s " + vaginaDescript(hole) + " is now somewhat loose.</b>");
							else if(holePointer.looseness() >= 2) output("<b>" + short + "s " + vaginaDescript(hole) + " is a little more used to insertions.</b>");
							else output("<b>" + short + "s " + vaginaDescript(hole) + " is stretched out a little bit.</b>");
						}
					}
					else {
						if (this is PlayerCharacter)
						{
							if(holePointer.looseness() >= 5) output("<b>Your " + assholeDescript() + " is stretched painfully wide, gaped in a way that practically invites huge monster-cocks to plow you.</b>");
							else if(holePointer.looseness() >= 4) output("<b>Your " + assholeDescript() + " painfully dilates, the pucker now able to gape slightly.</b>");
							else if(holePointer.looseness() >= 3) output("<b>Your " + assholeDescript() + " is now somewhat loose.</b>");
							else if(holePointer.looseness() >= 2) output("<b>Your " + assholeDescript() + " is a little more used to insertions.</b>");
							else output("<b>Your " + assholeDescript() + " is stretched out a little bit.</b>");
						}
						else
						{
							if(holePointer.looseness() >= 5) output("<b>" + short + "s " + assholeDescript() + " is stretched painfully wide, gaped in a way that practically invites huge monster-cocks to plow " + mf("him", "her") +".</b>");
							else if(holePointer.looseness() >= 4) output("<b>" + short + "s " + assholeDescript() + " painfully stretches, the lips now wide enough to gape slightly.</b>");
							else if(holePointer.looseness() >= 3) output("<b>" + short + "s " + assholeDescript() + " is now somewhat loose.</b>");
							else if(holePointer.looseness() >= 2) output("<b>" + short + "s " + assholeDescript() + " is a little more used to insertions.</b>");
							else output("<b>" + short + "s " + assholeDescript() + " is stretched out a little bit.</b>");
						}
					}
					if(spacingsB) output(" ");
				}
			}
			return (stretched || devirgined);
		}
	}
}
