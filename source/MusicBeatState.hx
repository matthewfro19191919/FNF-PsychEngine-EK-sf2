package;

import openfl.geom.Rectangle;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
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

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	var cSize:Int = 10;
	public function doMessage(text:String, duration:Float = 5)
	{
		var txt:FlxText = new FlxText(FlxG.width / 2, 10, 0, text + '\n', 16); // i hate flx text
		txt.cameras = [FlxG.camera];
		txt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		var panel = new FlxSprite(0, 0);
		makeSelectorG(panel, Std.int(txt.width) + 15, Std.int(txt.height - 24) + 15, 0xFF000000);
		panel.cameras = [FlxG.camera];

		var panelbg:FlxSprite = new FlxSprite(5, 5);
		makeSelectorG(panelbg, Std.int(txt.width) + 5, Std.int(txt.height - 24) + 5, 0xFF302E2E);
		panelbg.cameras = [FlxG.camera];

		txt.screenCenter(X);
		panel.screenCenter(X);
		panelbg.screenCenter(X);
		txt.y = -(txt.height);
		panel.y = -(panel.height);
		panelbg.y = -(panelbg.height);

		add(panel);
		add(panelbg);
		add(txt);

		FlxTween.tween(panel, {y: 10}, 0.5);
		FlxTween.tween(panelbg, {y: 15}, 0.5);
		FlxTween.tween(txt, {y: 20}, 0.5, {
			onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(duration, function(tmr:FlxTimer) {
					FlxTween.tween(panel, {y: -panel.height}, 0.5);
					FlxTween.tween(panelbg, {y: -panelbg.height - 5}, 0.5);
					FlxTween.tween(txt, {y: -txt.height - 10}, 0.5, {
						onComplete: function(twn:FlxTween) {
							remove(panel);
							remove(panelbg);
							remove(txt);
						}
					});
				});
			}
		});
	}

	function makeSelectorG(panel:FlxSprite,w,h,color:FlxColor)
	{
		panel.makeGraphic(w, h, color);
		panel.pixels.fillRect(new Rectangle(0, 190, panel.width, 5), 0x0);
		
		// Why did i do this? Because i'm a lmao stupid, of course
		// also i wanted to understand better how fillRect works so i did this shit lol???
		panel.pixels.fillRect(new Rectangle(0, 0, cSize, cSize), 0x0);														 //top left
		drawCircleCorner(panel,false, false,color);
		panel.pixels.fillRect(new Rectangle(panel.width - cSize, 0, cSize, cSize), 0x0);							 //top right
		drawCircleCorner(panel,true, false,color);
		panel.pixels.fillRect(new Rectangle(0, panel.height - cSize, cSize, cSize), 0x0);							 //bottom left
		drawCircleCorner(panel,false, true,color);
		panel.pixels.fillRect(new Rectangle(panel.width - cSize, panel.height - cSize, cSize, cSize), 0x0); //bottom right
		drawCircleCorner(panel,true, true,color);
	}

	function drawCircleCorner(panel:FlxSprite,flipX:Bool, flipY:Bool,color:FlxColor)
	{
		var antiX:Float = (panel.width - cSize);
		var antiY:Float = flipY ? (panel.height - 1) : 0;
		if(flipY) antiY -= 2;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 1), Std.int(Math.abs(antiY - 8)), 10, 3), color);
		if(flipY) antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 2), Std.int(Math.abs(antiY - 6)),  9, 2), color);
		if(flipY) antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 3), Std.int(Math.abs(antiY - 5)),  8, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 4), Std.int(Math.abs(antiY - 4)),  7, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 5), Std.int(Math.abs(antiY - 3)),  6, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 6), Std.int(Math.abs(antiY - 2)),  5, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 8), Std.int(Math.abs(antiY - 1)),  3, 1), color);
	}
}
