package;

import lime.utils.Assets;
import haxe.Json;

using StringTools;

class Language {
    public static var currentLanguage:String = "english";
    public static var languageData:Dynamic;
    public static var languages:Array<String> = ["english", "spanish"];

    public static function initLanguage() {
        var json = Json.parse(Paths.getTextFromFile("data/localization/list.json"));
        var loadLanguage:String = ClientPrefs.language;

        var languageJsonPath:String = Reflect.getProperty(json, loadLanguage);
        languageData = Json.parse(Paths.getTextFromFile("data/localization/" + languageJsonPath));
        updateCurrentLanguage();
    }

    public static function getLanguageDisplayStr(language:String = ""):String {
        var lang:String = "English";
        if (language == null || language.length < 1)
            language = ClientPrefs.language;

        for (langItem in languages) {
            if (langItem == language) {
                lang = g(langItem); // Get the display language from the json
            }
        }

        return lang;
    }

    public static function getAllLanguages(displayName:Bool = false):Array<String> {
        if (displayName) {
            var displayLanguages:Array<String> = [];
            for (lang in languages) {
                displayLanguages.push(getLanguageDisplayStr(lang));
            }
            return displayLanguages;
        }
        return languages;
    }

    public static function g(field:String = "no_translation", defaultVal:String = "Null!") {
        var got = Reflect.getProperty(languageData, field);
        var ret = got;
        if (got == null) ret = defaultVal;
        return ret;
    }

    public static function changeLanguage(language:String = "english") {
        ClientPrefs.language = language;
        ClientPrefs.saveSettings();
        updateCurrentLanguage();
        initLanguage();
    }

    public static function updateCurrentLanguage() {
        currentLanguage = ClientPrefs.language;
    }

    public static function convert(str:String):String {
        return str.replace(' ', '_').toLowerCase();
    }
}