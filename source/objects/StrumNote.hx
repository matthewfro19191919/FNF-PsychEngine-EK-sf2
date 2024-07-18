package objects;

import backend.ExtraKeysHandler;
import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	private var trackedScale:Float = 0.7;
	private var player:Int;
	private var initialWidth:Float = 0;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int) {
		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arrowRGBIndex = getIndex(PlayState.SONG.mania, leData);

		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[arrowRGBIndex];

		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[arrowRGBIndex];
		
		@:bypassAccessor
		{
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = null;
		if(PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		else skin = Note.defaultNoteSkin;

		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		texture = skin; //Load texture and anims
		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			initialWidth = width;

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			// animation.addByPrefix('green', 'arrowUP');
			// animation.addByPrefix('blue', 'arrowDOWN');
			// animation.addByPrefix('purple', 'arrowLEFT');
			// animation.addByPrefix('red', 'arrowRIGHT');
			initialWidth = width;

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * trackedScale));

			animation.addByPrefix('static', 'arrow${getAnimSet(getIndex(PlayState.SONG.mania, noteData)).strum}');
			animation.addByPrefix('pressed', '${getAnimSet(getIndex(PlayState.SONG.mania, noteData)).anim} press', 24, false);
			animation.addByPrefix('confirm', '${getAnimSet(getIndex(PlayState.SONG.mania, noteData)).anim} confirm', 24, false);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function retryBound() {
		trackedScale = trackedScale * 0.85;
		setGraphicSize(Std.int(initialWidth * trackedScale));
		updateHitbox();
		postAddedToGroup();
	}

	public function postAddedToGroup() {
		playAnim('static');
		var padding:Int = 0;
		if (PlayState.SONG.mania > 4) {
			padding = 4 * (PlayState.SONG.mania - 4);
		}

		// x = StrumBoundaries.getMiddlePoint().x;
		// x += ((Note.swagWidthUnscaled * trackedScale) - padding) * (-((PlayState.SONG.mania + 1) / 2) + noteData);
		// x += 25;
		// x += ((FlxG.width / 2) * player);
		ID = noteData;

		centerStrum(padding);
	}

	public function centerStrum(padding) {
		x = player == 0 ? 320 : 960;
		x += ((Note.swagWidthUnscaled * trackedScale) - padding) * (-((PlayState.SONG.mania+1) / 2) + noteData);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}

	public function getIndex(mania:Int, note:Int) {
		return ExtraKeysHandler.instance.data.keys[mania].notes[note];
	}

	public function getAnimSet(index:Int) {
		return ExtraKeysHandler.instance.data.animations[index];
	}
}

class StrumBoundaries {
	public static var minBoundaryOpponent:FlxPoint = new FlxPoint(30, 50);
	public static var maxBoundaryOpponent:FlxPoint = new FlxPoint(630, 160);

	public static function getMiddlePoint():FlxPoint {
		return new FlxPoint(Std.int(getBoundaryWidth().x/2),Std.int(getBoundaryWidth().y/2));
	}

	public static function getBoundaryWidth():FlxPoint {
		return new FlxPoint(Std.int((maxBoundaryOpponent.x - minBoundaryOpponent.x)),Std.int((maxBoundaryOpponent.y - minBoundaryOpponent.y)));
	}
}