package;

import flixel.system.FlxAssets.FlxShader;

class GlowEffect {
    public var shader:GlowEffectShader = new GlowEffectShader();

    public function new():Void
    {
        shader.iTime.value = [0];
    }

    public function update(elapsed:Float):Void
    {
        shader.iTime.value[0] += elapsed;
    }
}

class GlowEffectShader extends FlxShader {
    @:glFragmentSource('//SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    //****MAKE SURE TO remove the parameters from mainImage.
    //SHADERTOY PORT FIX

    const float blurSize = 3.0/512.0;
    const float intensity = 5;
    void mainImage()
    {
        vec4 sum = vec4(0);
        vec2 texcoord = fragCoord.xy/iResolution.xy;
        int j;
        int i;

        //thank you! http://www.gamerendering.com/2008/10/11/gaussian-blur-filter-shader/ for the 
        //blur tutorial
        // blur in y (vertical)
        // take nine samples, with the distance blurSize between them
        sum += texture(iChannel0, vec2(texcoord.x - 4.0*blurSize, texcoord.y)) * 0.05;
        sum += texture(iChannel0, vec2(texcoord.x - 3.0*blurSize, texcoord.y)) * 0.09;
        sum += texture(iChannel0, vec2(texcoord.x - 2.0*blurSize, texcoord.y)) * 0.12;
        sum += texture(iChannel0, vec2(texcoord.x - blurSize, texcoord.y)) * 0.15;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y)) * 0.16;
        sum += texture(iChannel0, vec2(texcoord.x + blurSize, texcoord.y)) * 0.15;
        sum += texture(iChannel0, vec2(texcoord.x + 2.0*blurSize, texcoord.y)) * 0.12;
        sum += texture(iChannel0, vec2(texcoord.x + 3.0*blurSize, texcoord.y)) * 0.09;
        sum += texture(iChannel0, vec2(texcoord.x + 4.0*blurSize, texcoord.y)) * 0.05;
            
            // blur in y (vertical)
        // take nine samples, with the distance blurSize between them
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 4.0*blurSize)) * 0.05;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 3.0*blurSize)) * 0.09;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 2.0*blurSize)) * 0.12;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - blurSize)) * 0.15;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y)) * 0.16;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + blurSize)) * 0.15;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 2.0*blurSize)) * 0.12;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 3.0*blurSize)) * 0.09;
        sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 4.0*blurSize)) * 0.05;

        //increase blur with intensity!
        //fragColor = sum*intensity + texture(iChannel0, texcoord); 
        if(sin(iTime) > 0.0)
            fragColor = sum * sin(iTime)+ texture(iChannel0, texcoord);
        else
            fragColor = sum * -sin(iTime)+ texture(iChannel0, texcoord);
    }')

    public function new()
    {
        super();
    }
}