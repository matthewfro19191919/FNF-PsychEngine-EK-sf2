package flixel.addons.ui;

import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUIAssets;
import flixel.util.FlxColor;

class FlxUISlider extends FlxUIGroup {

    public var object:Dynamic;
    public var variable:String;
    public var min:Float = 0;
    public var max:Float = 100;

    public var sliderSprite:FlxSprite;
    public var bar:FlxBar;

    public var minLabel:FlxUIText;
    public var maxLabel:FlxUIText;
    public var valueLabel:FlxUIText;

    private var __isBeingMoved:Bool = false;

    public var step:Float = 0;
    public override function new(x:Float, y:Float, width:Int, height:Int, object:Dynamic, variable:String, min:Float, max:Float, gradientBar:Bool = true) {
        super(x, y);
        this.object = object;
        this.variable = variable;
        this.min = min;
        this.max = max;

        var btnSizeStr:Array<String> = FlxUIAssets.SLIDER_BUTTON.split(",");
        var btnSize:Array<Int> = [Std.parseInt(btnSizeStr[0]), Std.parseInt(btnSizeStr[1])];
        sliderSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(FlxUIAssets.IMG_SLIDER, 'shared'), true, btnSize[0], btnSize[1]);
        sliderSprite.animation.add('normal', [0]);
        sliderSprite.animation.add('hover', [1]);
        sliderSprite.animation.add('click', [2]);

        bar = new FlxBar(0, sliderSprite.y + sliderSprite.height, LEFT_TO_RIGHT, width, height, object, variable, min, max);
        if (gradientBar)
            bar.createGradientBar([0x88222222], [FlxColor.RED, 0xFF00FF1E], 1, 0, true, 0xFF000000);
        else
            bar.createFilledBar(0x88222222, FlxColor.WHITE, true, FlxColor.BLACK);

        bar.y -= bar.height / 2;

        this.minLabel = new FlxUIText(bar.x, bar.y + bar.height + 5, 0, Std.string(min));
        this.maxLabel = new FlxUIText(bar.x + bar.width, bar.y + bar.height + 5, 0, Std.string(max));
        this.maxLabel.x -= this.maxLabel.width;
        this.valueLabel = new FlxUIText(sliderSprite.x, sliderSprite.y - 8, 0, '');

        add(this.minLabel);
        add(this.maxLabel);
        add(bar);
        add(sliderSprite);
        add(this.valueLabel);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(sliderSprite, camera) || FlxG.mouse.overlaps(bar, camera))) {
            __isBeingMoved = true;
        } 
        
        if (__isBeingMoved) { 
            sliderSprite.animation.play('click');
        } else if (FlxG.mouse.overlaps(sliderSprite, camera)) {
            sliderSprite.animation.play('hover');
        } else {
            sliderSprite.animation.play('normal');
        }

        if (FlxG.mouse.justReleased) __isBeingMoved = false;
        if (__isBeingMoved) {
            var cursorX = FlxG.mouse.getScreenPosition(camera).x - bar.x;
            if (object != null && variable != null) {
                if (step != 0)
                    Reflect.setProperty(object, variable, CoolUtil.boundTo(min + (Math.floor((max-min) / bar.width * cursorX / step) * step), min, max));
                else
                    Reflect.setProperty(object, variable, CoolUtil.boundTo(min + ((max-min) / bar.width * cursorX), min, max));
            } else
                  trace("object is null");
        }

        if (object != null && variable != null) bar.value = Reflect.getProperty(object, variable);
        sliderSprite.x = bar.x + ((bar.percent / 100) * bar.width) - (sliderSprite.width / 2);
        valueLabel.text = Std.string(bar.value);
        valueLabel.x = sliderSprite.x + (sliderSprite.width / 2) - (valueLabel.width / 2);
    }
}