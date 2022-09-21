package;

import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

typedef SubProperties = {
	var deletePrevious:Bool;
	var fadeOut:Bool;
	var fadeIn:Bool;
	var subText:String;
	var typeIn:Bool;
	var typeOut:Bool;
	var raisesLast:Bool;
	var italic:Bool;
	var bold:Bool;
}

typedef SubExam = {
	var font:String;
	var size:Int;
	var border:Bool;
	var alignment:String;
	var length:String;
	var colorArray:Array<Int>;
}

/*
Heavily modified class of https://github.com/EyeDaleHim/FNF-Mechanics/blob/main/source/SubtitleHandler.hx
all credit goes to EyeDaleHim#8508
*/
class SubtitleHandler
{
	public static var camera = null;
	public static var list:Array<Subtitle> = [];

	public static function makeline(value1:String, value2:String)
	{
		if (camera == null)
		{
			camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}

		var examV1:SubProperties = examinateSubProperties(value1);
		var examV2:SubExam = examinateEventValue(value2);

		var subSprite:Subtitle = new Subtitle(examV1, examV2);
		subSprite.subBG.screenCenter();
		subSprite.subText.screenCenter();
		switch(examV2.alignment) {
			case "LEFT": 
				subSprite.subBG.x = 96;
				subSprite.subText.x = 100;
			case "RIGHT": 
				subSprite.subBG.x = FlxG.width - 96;
				subSprite.subText.x = FlxG.width - 100;
			case "CENTER":
				subSprite.subBG.screenCenter();
				subSprite.subText.screenCenter();
		}

		subSprite.subBG.y = subSprite.subText.y = FlxG.height * 0.85;
		subSprite.yValue -= subSprite.subBG.height;
		list.unshift(subSprite);

		for (sub in list)
		{
			sub.ID = list.indexOf(sub);

			if (sub != null)
			{
				if (sub.ID != 0)
				{
					if (subSprite.raiseLast) {
						sub.yValue = list[sub.ID - 1].yValue - sub.subBG.height;
					}
					if (subSprite.deletePrev) {
						sub.onKill();
					}
				}
			}
		}

		FlxG.state.add(subSprite);
	}

	// Called if the state is destroyed
	public static function destroy(cameraMakeNull:Bool = true)
	{
		if (cameraMakeNull) camera = null;
		FlxDestroyUtil.destroyArray(list);
		list = [];
	}

	public static function examinateEventValue(evalue:String = ""):SubExam {
		var subExam:SubExam = null;
		subExam = {
			size: 24,
			font: "vcr.ttf",
			border: true,
			alignment: "LEFT",
			length: "50", // Dumbass got his thin null !!! lol lets make it small !!! fu!
			colorArray: [255, 255, 255]
		};

		var exam1:Array<String> = evalue.split("|");
		for (i in exam1) {
			var exam2:Array<String> = i.split('=');
			var v1:String = exam2[0];
			var v2:String = exam2[1];
			switch (v1) {
				case "length":
					subExam.length = v2;
				case "size":
					subExam.size = Std.parseInt(v2);
				case "font":
					subExam.font = v2;
				case "border":
					subExam.border = boolFromString(v2);
				case "alignment":
					subExam.alignment = v2;
				case "rc":
					subExam.colorArray[0] = Std.parseInt(v2);
				case "bc":
					subExam.colorArray[1] = Std.parseInt(v2);
				case "gc":
					subExam.colorArray[2] = Std.parseInt(v2);
			}
		}

		return subExam;
	}

	public static function examinateSubProperties(evalue:String = ""):SubProperties {
		var subExam:SubProperties = null;
		subExam = {
			deletePrevious: false,
			fadeOut: false,
			fadeIn: false,
			subText: "",
			typeIn: false,
			typeOut: false,
			raisesLast: true,
			bold: false,
			italic: false
		};

		var exam1:Array<String> = evalue.split("|");
		for (i in exam1) {
			var exam2:Array<String> = i.split('=');
			var v1:String = exam2[0];
			var v2:String = exam2[1];
			switch (v1) {
				case "deletePrevious":
					subExam.deletePrevious = boolFromString(v2);
				case "fadeOut":
					subExam.fadeOut = boolFromString(v2);
				case "fadeIn":
					subExam.fadeIn = boolFromString(v2);
				case "subText":
					subExam.subText = v2;
				case "typeIn":
					subExam.typeIn = boolFromString(v2);
				case "typeOut":
					subExam.typeOut = boolFromString(v2);
				case "raisesLast":
					subExam.raisesLast = boolFromString(v2);
			}
		}

		return subExam;
	}

	public static function boolFromString(string:String):Bool {
		return string == "true" ? true : false;
	}
}

class Subtitle extends FlxTypedGroup<FlxSprite>
{
	public var aliveTime:Float = 0;
	public var killTime:Float = 5.0;

	public var subBG:FlxSprite;
	public var subText:FlxText;

	public var lerpFrom:Float = FlxG.height * 0.85;
	public var yValue:Float = FlxG.height * 0.85;

	public var typedIn:Bool = false;
	public var typedOut:Bool = false;
	public var fadeIn:Bool = false;
	public var fadeOut:Bool = false;
	public var deletePrev:Bool = false;
	public var raiseLast:Bool = false;
	public var textToType:String = "";

	private var typeCharIndex:Int = 0;
	private var charArray:Array<String> = [];
	private var typeTmr:Float = 0;

	private var typeOutTmr:Float = 0;

	override public function new(value1:SubProperties, value2:SubExam)
	{
		super();

		var time:Float = Std.parseFloat(value2.length) / 1000;
		var text:String = value1.subText;
		var size:Int = value2.size;
		var border:Bool = value2.border;
		var alignment:String = value2.alignment;
		var font:String = value2.font;

		textToType = text;
		raiseLast = value1.raisesLast;
		deletePrev = value1.deletePrevious;
		fadeOut = value1.fadeOut;
		fadeIn = value1.fadeIn;
		typedOut = value1.typeOut;
		typedIn = value1.typeIn;

		killTime = time;

		if (typedIn) {
			typeCharIndex = 0;
			charArray = textToType.split('');
			text = '';
		}

		subText = new FlxText(0, lerpFrom + 4, 0, text, size);
		subText.setFormat(Paths.font(font), size);
		if (border) subText.setFormat(Paths.font(font), size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subText.cameras = [SubtitleHandler.camera];
		switch(alignment) {
			case "LEFT": subText.alignment = LEFT;
			case "RIGHT": subText.alignment = RIGHT;
			case "CENTER": subText.alignment = CENTER;
		}

		var colorFormat:FlxTextFormat = new FlxTextFormat(FlxColor.fromRGB(value2.colorArray[0],
			value2.colorArray[1], value2.colorArray[2]),
			value1.bold, value1.italic, FlxColor.BLACK);

		if (!typedIn) {
			subText.applyMarkup(text, [new FlxTextFormatMarkerPair(colorFormat, '<color>')]);
		}

		subBG = new FlxSprite(0, lerpFrom).makeGraphic(Math.floor(subText.width + 8), Math.floor(subText.height + 8), FlxColor.BLACK);
		subBG.alpha = 0.6;
		subBG.cameras = [SubtitleHandler.camera];

		if (fadeIn) {
			subText.alpha = 0.0001;
			subBG.alpha = 0.0001;
		}

		trace(killTime, 'fi:' + fadeIn, 'fo:'+fadeOut);

		add(subBG);
		add(subText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		aliveTime += elapsed;

		if (typedIn && subText.text != textToType && typeTmr > 0.1) {
			typeTmr = 0;
			subText.text += charArray[typeCharIndex];
			typeCharIndex++;
		}
		typeTmr += elapsed;

		if (aliveTime >= killTime)
		{
			if (fadeOut) {
				subText.alpha -= elapsed;
				subBG.alpha = subText.alpha * 0.6;
			} else if (!typedOut) {
				onKill();
			}
			if (typedOut) {
				if (subText.text.length > 0 && typeOutTmr > 0.1) {
					typeOutTmr = 0;
					subText.text = subText.text.substring(0, subText.text.length - 1);
				}
				typeOutTmr += elapsed;
			}
		} else
		{
			if (subText.alpha <= 1 && fadeIn) {
				subText.alpha += elapsed;
				subBG.alpha = subText.alpha * 0.6;
			}
		}

		subBG.y = FlxMath.lerp(subBG.y, yValue, elapsed * 5);
		subText.y = FlxMath.lerp(subBG.y, yValue, elapsed * 5) + 4;

		if ((subText.alpha <= 0) || (subText.text.length < 1 && typedOut))
		{
			onKill();
		}
	}

	public function onKill() {
		FlxTween.cancelTweensOf(subText);
		FlxTween.cancelTweensOf(subBG);
		
		destroy();

		FlxDestroyUtil.destroy(subText);
		FlxDestroyUtil.destroy(subBG);

		SubtitleHandler.list.remove(this);
	}
}
