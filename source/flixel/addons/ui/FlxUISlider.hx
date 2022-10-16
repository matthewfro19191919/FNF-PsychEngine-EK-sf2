package flixel.addons.ui;

import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUIAssets;

class FlxUISliderNew extends FlxUIGroup {

    public var parentVariable:Dynamic;
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
    public override function new(x:Float, y:Float, width:Int, height:Int, parentVariable:Dynamic, variable:String, min:Float, max:Float, ?minLabel:String, ?maxLabel:String) {
        super(x, y);
        this.parentVariable = parentVariable;
        this.variable = variable;
        this.min = min;
        this.max = max;

        if (minLabel == null) minLabel = Std.string(min);
        if (maxLabel == null) maxLabel = Std.string(max);

        var btnSizeStr:Array<String> = FlxUIAssets.SLIDER_BUTTON.split(",");
        var btnSize:Array<Int> = [Std.parseInt(btnSizeStr[0]), Std.parseInt(btnSizeStr[1])];
        sliderSprite = new FlxSprite(0, 0).loadGraphic(FlxUIAssets.IMG_SLIDER, true, btnSize[0], btnSize[1]);

        bar = new FlxBar(0, sliderSprite.y + sliderSprite.height, LEFT_TO_RIGHT, width, height, parentVariable, variable, min, max);
        bar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE, true, FlxColor.BLACK);
        bar.y -= bar.height / 2;

        this.minLabel = new FlxUIText(bar.x, bar.y + bar.height + 5, 0, minLabel);
        this.maxLabel = new FlxUIText(bar.x + bar.width, bar.y + bar.height + 5, 0, maxLabel);
        this.maxLabel.x -= this.maxLabel.width;
        this.valueLabel = new FlxUIText(sliderSprite.x, sliderSprite.y - 8, 0, '');

        add(this.minLabel);
        add(this.maxLabel);
        add(bar);
        add(sliderSprite);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(sliderSprite, camera) || FlxG.mouse.overlaps(bar, camera))) {
            __isBeingMoved = true;
        }
        if (FlxG.mouse.justReleased) __isBeingMoved = false;
        if (__isBeingMoved) {
            var cursorX = FlxG.mouse.getScreenPosition(camera).x - bar.x;
            if (parentVariable != null && variable != null) {
                if (step != 0) {
                    Reflect.setProperty(parentVariable, variable, CoolUtil.wrapTo(min + (Math.floor(max / bar.width * cursorX / step) * step), min, max));
                } else {
                    Reflect.setProperty(parentVariable, variable, CoolUtil.wrapTo(min + (max / bar.width * cursorX), min, max));
                }
            } else {
                trace("object is null");
            }
        }

        if (parentVariable != null && variable != null) bar.value = Reflect.getProperty(parentVariable, variable);
        sliderSprite.x = bar.x + ((bar.percent / 100) * bar.width) - (sliderSprite.width / 2);
        valueLabel.text = Std.string(bar.value);
        valueLabel.x = sliderSprite.x + (sliderSprite.width / 2) - (valueLabel.width / 2);
    }
}