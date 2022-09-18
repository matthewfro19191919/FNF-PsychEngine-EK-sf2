package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import Language as Lang;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		title = Lang.g(Lang.convert(title));
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option(Lang.g('options_note_splash'),
			Lang.g('options_note_splash_desc'),
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_hide_hud'),
			Lang.g('options_hide_hud_desc'),
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option(Lang.g('options_time_bar'),
			Lang.g('options_time_bar_desc'),
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option(Lang.g('options_flashing_lights'),
			Lang.g('options_flashing_lights_desc'),
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_camera_zoom'),
			Lang.g('options_camera_zoom_desc'),
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_score'),
			Lang.g('options_score_desc'),
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_healthbar'),
			Lang.g('options_healthbar_desc'),
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option(Lang.g('options_fps'),
			Lang.g('options_fps_desc'),
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option(Lang.g('options_pause_song'),
			Lang.g('options_pause_song_desc'),
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option(Lang.g('options_check_for_updates'),
			Lang.g('options_check_for_updates_desc'),
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option(Lang.g('options_combostacking'),
			Lang.g('options_combostacking_desc'),
			'comboStacking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(Lang.g('options_language'),
			Lang.g('options_language_desc'),
			'language',
			'string',
			'english',
			Language.getAllLanguages());
		option.isLanguage = true;
		option.onChange = onUpdateLanguage;
		addOption(option);

		super();

		onUpdateLanguage(); //At the end of super because then it will crash
		//(the options werent added yet)
	}

	var changedMusic:Bool = false;
	function onUpdateLanguage()
	{
		for (option in optionsArray){
			if (option.isLanguage) {
				if (option.child != null) {
					option.child.text = Language.getLanguageDisplayStr(ClientPrefs.language);
				}
			}
		}
		descText.text = Language.g('options_language_desc');
	}

	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
