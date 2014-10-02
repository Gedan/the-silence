package classes.UIComponents.SideBarComponents 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import classes.UIComponents.UIStyleSettings;
	
	/**
	 * ...
	 * @author Gedan
	 */
	public class GeneralInfoBlock extends Sprite
	{
		private var _headerText:TextField;
		private var _headerUnderline:Sprite;
		
		private var _timeLabel:TextField;
		private var _timeText:TextField;
		
		private var _daysLabel:TextField;
		private var _daysText:TextField;
		
		private var _sceneLabel:TextField;
		private var _sceneText:TextField;
		
		public function get time():TextField { return _timeText; }
		public function get days():TextField { return _daysText; }

		public function HideTime():void
		{
			_timeText.visible = false;
			_daysText.visible = false;
		}
		
		public function ShowTime():void
		{
			_timeText.visible = true;
			_daysText.visible = true;
		}
		
		public function GeneralInfoBlock() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.BuildHeader();
			this.BuildDisplays();
		}
		
		private function BuildHeader():void
		{
			_headerUnderline = new Sprite();
			_headerUnderline.x = 0;
			_headerUnderline.y = 22;
			_headerUnderline.graphics.beginFill(UIStyleSettings.gHighlightColour, 1);
			_headerUnderline.graphics.drawRect(0, 0, 190, 1);
			_headerUnderline.graphics.endFill();
			this.addChild(_headerUnderline);
			
			_headerText = new TextField();
			_headerText.x = 10;
			_headerText.y = 0;
			_headerText.width = 190;
			_headerText.defaultTextFormat = UIStyleSettings.gStatBlockHeaderFormatter;
			_headerText.embedFonts = true;
			_headerText.antiAliasType = AntiAliasType.ADVANCED;
			_headerText.text = "GALACTIC STANDARD";
			_headerText.mouseEnabled = false;
			_headerText.mouseWheelEnabled = false;
			this.addChild(_headerText);
		}
		
		private function BuildDisplays():void
		{
			// Time Display
			_timeLabel = new TextField();
			_timeLabel.x = 10;
			_timeLabel.y = _headerUnderline.y - 2;
			_timeLabel.width = 125;
			_timeLabel.defaultTextFormat = UIStyleSettings.gGeneralInfoLabelFormatter;
			_timeLabel.embedFonts = true;
			_timeLabel.antiAliasType = AntiAliasType.ADVANCED;
			_timeLabel.multiline = false;
			_timeLabel.wordWrap = false;
			_timeLabel.text = "TERRAN TIME";
			_timeLabel.mouseEnabled = false;
			_timeLabel.mouseWheelEnabled = false;
			this.addChild(_timeLabel);
			_timeLabel.height = _timeLabel.textHeight + 3;
			
			_timeText = new TextField();
			_timeText.x = 132;
			_timeText.y = _headerUnderline.y + 2;
			_timeText.width = 60;
			_timeText.defaultTextFormat = UIStyleSettings.gGeneralInfoValueFormatter;
			_timeText.embedFonts = true;
			_timeText.antiAliasType = AntiAliasType.ADVANCED;
			_timeText.multiline = false;
			_timeText.wordWrap = false;
			_timeText.text = "--:--";
			_timeText.background = false;
			_timeText.mouseEnabled = false;
			_timeText.mouseWheelEnabled = false;
			this.addChild(_timeText);
			_timeText.height = _timeText.textHeight - 2;
			
			// Days Display
/*			_daysLabel = new TextField();
			_daysLabel.x = 10;
			_daysLabel.y = _timeLabel.y + _timeLabel.height - 6;
			_daysLabel.width = 117;
			_daysLabel.defaultTextFormat = UIStyleSettings.gGeneralInfoLabelFormatter;
			_daysLabel.embedFonts = true;
			_daysLabel.antiAliasType = AntiAliasType.ADVANCED;
			_daysLabel.multiline = false;
			_daysLabel.wordWrap = false;
			_daysLabel.text = "SOLAR DAYS";
			_daysLabel.mouseEnabled = false;
			_daysLabel.mouseWheelEnabled = false;
			this.addChild(_daysLabel);
			_daysLabel.height = _daysLabel.textHeight + 3;
			
			_daysText = new TextField();
			_daysText.x = 121;
			_daysText.y = _timeText.y + _timeText.height - 7;
			_daysText.width = 71;
			_daysText.defaultTextFormat = UIStyleSettings.gGeneralInfoValueFormatter;
			_daysText.embedFonts = true;
			_daysText.antiAliasType = AntiAliasType.ADVANCED;
			_daysText.multiline = false;
			_daysText.wordWrap = false;
			_daysText.text = "-----";
			_daysText.background = false;
			_daysText.mouseEnabled = false;
			_daysText.mouseWheelEnabled = false;
			this.addChild(_daysText);
			_daysText.height = _daysLabel.textHeight + 1;*/
		}
	}

}