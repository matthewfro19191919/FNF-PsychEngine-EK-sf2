package;

import flixel.group.FlxSpriteGroup;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

using StringTools;

class CustomFadeTransition extends FlxSpriteGroup {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var transition:String = null;

	//2022
	public function new(duration:Float, isTransIn:Bool, transition:Null<String> = null) {
		super();

		this.transition = transition;
		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		
		var grdangle:Int = 90;
		var flipx:Bool = false;
		if (transition == null) this.transition = ClientPrefs.transition;
		var shit:Array<Int> = [width, height + 400];
		switch (this.transition) {
			case 'Horizontal Fade':
				grdangle = 180;
				flipx = true;
		}
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]), 1, grdangle);
		transGradient.scrollFactor.set();
		transGradient.flipX = flipx;

		transBlack = new FlxSprite().makeGraphic(shit[0] + 200, shit[1], FlxColor.BLACK);
		transBlack.scrollFactor.set();

		if (!this.transition.startsWith('Zoom')) {
			add(transGradient);
			add(transBlack);
		}

		switch (this.transition) {
			default:
				transGradient.y -= (shit[0] - FlxG.width) / 2;
				transBlack.y = transGradient.y;
				
				if(isTransIn) {
					transGradient.y = transBlack.y - transBlack.height;
					FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				} else {
					transGradient.y = -transGradient.height;
					transBlack.y = transGradient.y - transBlack.height + 50;
					leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				}
			case 'Horizontal Fade':
				transGradient.x -= (shit[0] - FlxG.width);
				transBlack.x = transGradient.x;
				
				if(isTransIn) {
					transGradient.x = transBlack.x - transBlack.width;
					FlxTween.tween(transGradient, {x: transGradient.width + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				} else {
					transGradient.x = -transGradient.width;
					transBlack.x = transGradient.x - transBlack.width;
					leTween = FlxTween.tween(transGradient, {x: transGradient.width + 50}, duration, {onComplete: mf, ease: FlxEase.linear});
				}
			case 'Wheel Fade':
				transGradient.x -= (shit[0] - FlxG.width);
				transBlack.x = transGradient.x;

				transGradient.origin.set(transGradient.width, transGradient.height);
				transBlack.origin.set(transGradient.width, transGradient.height);
				
				if(isTransIn) {
					transGradient.x = transBlack.x - transBlack.width;
					FlxTween.tween(transGradient, {angle: -90}, duration, {onComplete: mf, ease: FlxEase.linear});
				} else {
					transGradient.x = -transGradient.width;
					transBlack.x = transGradient.x - transBlack.width;
					transGradient.angle = 90;
					transBlack.angle = 90;
					leTween = FlxTween.tween(transGradient, {angle: 0}, duration, {onComplete: mf, ease: FlxEase.linear});
				}
			case 'Zoom in vertical':
				for (camera in FlxG.cameras.list) {
					if (isTransIn) {
						camera.setPosition(camera.x, -camera.height);
						camera.zoom = 0.5;
						FlxTween.tween(camera, {zoom: camera.initialZoom, y:0}, duration, {onComplete: mf, ease: FlxEase.cubeOut});
					} else 
						FlxTween.tween(camera, {zoom: 0.5,y: FlxG.height}, duration, {onComplete: mf, ease: FlxEase.cubeOut});
				}
			case 'Zoom in horizontal':
				for (camera in FlxG.cameras.list) {
					if (isTransIn) {
						camera.setPosition(-camera.width, camera.y);
						camera.zoom = 0.5;
						var posTo = 0;
						FlxTween.tween(camera, {zoom: camera.initialZoom}, duration, {onComplete: mf, ease: FlxEase.cubeOut, startDelay: duration / 2});
						FlxTween.tween(camera, {x: posTo}, duration, {onComplete: mf, ease: FlxEase.cubeOut});
					} else {
						var posTo = FlxG.width;
						FlxTween.tween(camera, {zoom: 0.5}, duration, {onComplete: mf, ease: FlxEase.cubeOut});
						FlxTween.tween(camera, {x: posTo}, duration, {onComplete: mf, ease: FlxEase.cubeOut, startDelay: duration / 2});
					}
				}
		}

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transGradient.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	function mf(_) {
		if(CustomFadeTransition.finishCallback != null) {
			CustomFadeTransition.finishCallback();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		switch (transition) {
			default:
				if(isTransIn) {
					transBlack.y = transGradient.y + transGradient.height;
				} else {
					transBlack.y = transGradient.y - transBlack.height;
				}
			case 'Horizontal Fade':
				if(isTransIn) {
					transBlack.x = transGradient.x + transGradient.width;
				} else {
					transBlack.x = transGradient.x - transBlack.width;
				}
			case 'Wheel Fade':
				transBlack.angle = transGradient.angle;
			case 'Zoom in vertical' | 'Zoom in horizontal': // nothing!
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}