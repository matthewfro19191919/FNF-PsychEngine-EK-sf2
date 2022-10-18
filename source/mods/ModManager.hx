package mods;

import achievements.Achievements;
import haxe.Json;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef Mod = {
    var name:String;
    var description:String;
}

typedef Award = {
    var name:String;
    var description:String;
    var hidden:Bool;
}

class ModManager {
    public static var loadedMods:Map<String, Mod> = new Map<String, Mod>();

    public static function getMods():Array<String> {
        #if MODS_ALLOWED
        return Paths.getModDirectories();
        #else
        return [];
        #end
    }
    
    public static function getPackOf(mod:String):Mod {
        #if MODS_ALLOWED
        var path = Paths.mods(mod + '/pack.json');
		if(FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if(rawJson != null && rawJson.length > 0) {
				var stuff:Mod = Json.parse(rawJson);
                if (!loadedMods.exists(mod)) {
                    loadedMods.set(mod, stuff);
                }
            }
        }
        if (loadedMods.exists(mod)) {
            return loadedMods.get(mod);
        }
        #end
        return {
            name: null,
            description: null
        };
    }

    public static function getModIconPath(mod:String):String {
        #if MODS_ALLOWED
        return Paths.mods(mod + '/pack.png');
        #else
        return Paths.getPreloadPath('images/fnf.png');
        #end
    }

    public static function loadModAchievements() {
        #if MODS_ALLOWED
        for (mod in Paths.getGlobalMods()) {
            var thisModAchievements:Array<Dynamic> = [];
            for (achieve in FileSystem.readDirectory(Paths.modsAchievements(mod))) {

                if (achieve.endsWith('.json')) {

                    var path = Paths.modsAchievements(mod, achieve);
                    if(FileSystem.exists(path)) {
                        var rawJson:String = File.getContent(path);
                        if(rawJson != null && rawJson.length > 0) {
                            var achievement:Award = Json.parse(rawJson);
                            thisModAchievements.push([
                                achievement.name, 
                                achievement.description, 
                                achieve.replace('.json', ''), 
                                achievement.hidden,
                                mod
                            ]);
                        }
                    }
                }
            }

            Achievements.modAchievements.set(mod, thisModAchievements);
        }
        #end
    }
}