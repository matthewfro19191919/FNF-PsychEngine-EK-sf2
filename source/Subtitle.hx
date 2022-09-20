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

typedef SubProperties = {
	var deletePrevious:Bool;
	var fadeOut:Bool;
	var fadeIn:Bool;
	var subText:String;
	var typeIn:Bool;
	var typeOut:Bool;
	var raisesLast:Bool;
}

class SubtitleHandler
{
	public static var camera = null;
	public static var list:Array<Subtitle> = [];

	public static function makeline(text:String, time:Float = 5.0)
	{
		if (camera == null)
		{
			camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}

		var subSprite:Subtitle = new Subtitle(text, time);
		subSprite.subBG.screenCenter();
		subSprite.subText.screenCenter();

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
					sub.yValue = list[sub.ID - 1].yValue - sub.subBG.height;
				}
			}
		}

		FlxG.state.add(subSprite);
	}

	// Called if the state is destroyed
	public static function destroy()
	{
		camera = null;
		FlxDestroyUtil.destroyArray(list);
		list = [];
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

	override public function new(text:String, time:Float = 5.0)
	{
		super();

		killTime = time;

		subText = new FlxText(0, lerpFrom + 4, 0, text, 24);
		subText.setFormat(Paths.font("vcr.ttf"), 24);
		subText.cameras = [SubtitleHandler.camera];

		subBG = new FlxSprite(0, lerpFrom).makeGraphic(Math.floor(subText.width + 8), Math.floor(subText.height + 8), FlxColor.BLACK);
		subBG.alpha = 0.6;
		subBG.cameras = [SubtitleHandler.camera];

		add(subBG);
		add(subText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		aliveTime += elapsed;
		if (aliveTime >= killTime)
		{
			subText.alpha -= elapsed;
			subBG.alpha = subText.alpha * 0.6;
		}

		subBG.y = FlxMath.lerp(subBG.y, yValue, elapsed * 5);
		subText.y = FlxMath.lerp(subBG.y, yValue, elapsed * 5) + 4;

		if (subText.alpha <= 0)
		{
			FlxTween.cancelTweensOf(subText);
			FlxTween.cancelTweensOf(subBG);
			
			destroy();

			FlxDestroyUtil.destroy(subText);
			FlxDestroyUtil.destroy(subBG);

			SubtitleHandler.list.remove(this);
		}
	}
}
