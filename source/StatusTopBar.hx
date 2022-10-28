package;

import openfl.events.Event;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.addons.ui.FlxUIAssets;
import openfl.Lib;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import flixel.system.FlxAssets;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.BitmapData;

class StatusTopBar extends Sprite {
    var _defaultScale:Float = 1.0;

    var bar:Bitmap;
    var min:Bitmap;
    var max:Bitmap;
    var clo:Bitmap;
    var text:TextField;

    var lerpY:Float = 0;

    @:keep
	public function new()
	{
		super();

		visible = true;
		scaleX = _defaultScale;
	    scaleY = _defaultScale;
		bar = new Bitmap(new BitmapData(Lib.current.stage.stageWidth, 50, true, 0x7F000000));
		addChild(bar);

		text = new TextField();
		text.width = bar.width;
		text.height = bar.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.LEFT;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "Friday Night Funkin': Psych Engine";

        var bx:Float = 0;
        var winclose:BitmapData;
        winclose = BitmapData.fromFile(FlxUIAssets.IMG_WIN_CLOSE);
        clo = new Bitmap(winclose);
        clo.x = bx;
        addChild(clo);

        bx += 16;
        var winmax:BitmapData;
        winmax = BitmapData.fromFile(FlxUIAssets.IMG_WIN_MAXIMIZE);
        max = new Bitmap(winmax);
        max.x = bx;
        addChild(max);

        bx += 16;
        var winmin:BitmapData;
        winmin = BitmapData.fromFile(FlxUIAssets.IMG_WIN_MINIMIZE);
        min = new Bitmap(winmin);
        min.x = bx;
        addChild(min);

        screenCenter();
		y = -height;
        lerpY = -height;
		visible = true;

        //stage.addEventListener(Event.RESIZE, screenCenter);
	}

	private override function __enterFrame(MS:Float):Void
	{
        var elapsed:Float = MS / 1000;

        //if (FlxG.mouse.screenY <= 20)
            lerpY = 0;
        //else
            //lerpY = -height;

        //y = FlxMath.lerp(y, lerpY, (MS / 1000) * 5);
        y = 0;
        visible = true;

        trace(y);
    }

    public function hitbox():Bool {
        var mousePoint = FlxG.mouse.getScreenPosition();
        if (mousePoint.y < 21)
            return true;
    
        return true;
    }

    public function screenCenter(?_):Void
    {
        trace('resiz');
        scaleX = _defaultScale;
	    scaleY = _defaultScale;

        /*x = FlxG.game.x;
        width = FlxG.game.width;
        bar.x = 0;
        bar.width = FlxG.game.width;
        //text.width = bar.width;
        text.x = 0;

        var bx:Float = width - 16;
        clo.x = bx;
        bx -= 16;
        max.x = bx;
        bx -= 16;
        min.x = bx;*/
    }
}