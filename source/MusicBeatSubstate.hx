package;

import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import flixel.text.FlxText;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxSprite;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

}

class MessagePopup extends FlxText
{
    public var disableTime:Float;
    public var messageBar:FlxSprite;
	public var messageBarBG:FlxSprite;
	public var fadeDuration:Float;
	public var goingOut:Bool = false;
    public function new(text:Dynamic, color:Int = 0xFFffffff, fadeDuration:Float = 6)
    {
        super(0, -25, 0, text + '\n', 16);
		this.disableTime = fadeDuration;
		this.fadeDuration = fadeDuration;
		setFormat(Paths.font("vcr.ttf"), 20, color, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		messageBarBG = new FlxSprite(-10, -10).makeGraphic(Std.int(width)+20, Std.int(height - 24) + 20, 0x00000000);
        FlxSpriteUtil.drawRoundRect(messageBarBG, 0, 0, Std.int(width) + 20, Std.int(height - 24) + 20, 30, 30, 0xFF000000);
        messageBar = new FlxSprite(0, 0).makeGraphic(Std.int(width)+10, Std.int(height - 24) + 10, 0x00000000);
        FlxSpriteUtil.drawRoundRect(messageBar, 0, 0, Std.int(width)+10, Std.int(height - 24), 30, 30, 0xFF302E2E);
        messageBar.screenCenter(X);
		messageBarBG.screenCenter(X);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		messageBar.y = -messageBar.height;
		messageBarBG.y = -messageBarBG.height;
		y = -height - 25;

        messageBar.cameras = cameras;
        messageBar.scrollFactor.set();
		messageBarBG.cameras = cameras;
		messageBarBG.scrollFactor.set();
        screenCenter(X);
        scrollFactor.set();
    }
    override function draw():Void
    {
		messageBarBG.draw();
        messageBar.draw();
		FlxTween.tween(messageBarBG, {y: 10}, 0.5);
        FlxTween.tween(this, {y: 25}, 0.5);
        FlxTween.tween(messageBar, {y: 20}, 0.5);
        super.draw();
    }
    override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime < 0) destroy();
		if(disableTime < 1) {
			goOut();
			goingOut = true;
		}
	}

	public function goOut() {
		messageBarBG.y -= 1;
		messageBar.y -= 1;
		y -= 1;
	}
}