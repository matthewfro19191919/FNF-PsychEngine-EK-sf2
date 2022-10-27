package;

import flixel.FlxSprite;

class RatingSpr extends FlxSprite {
    public var updateShader:Bool = false;
    var glowShader:GlowEffect;

    public function new(x=0,y=0) {
        super(x,y);

        glowShader = new GlowEffect();
		shader = glowShader.shader;
    }

    override function update(elapsed) {
        if (updateShader) {
            glowShader.update(elapsed);
        }
    }
}