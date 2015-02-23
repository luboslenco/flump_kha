//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

import flump.Format;

/**
 * Defines a Flump atlased texture.
 */
class BitmapSymbol implements Symbol
{
    public var name (get, null) :String;
    public var texture (default, null) :Texture;
    public var anchorX (default, null) :Float;
    public var anchorY (default, null) :Float;

    public function new (json :TextureFormat, atlas :kha.Image)
    {
        _name = json.symbol;

        var rect = json.rect;
        texture = new Texture(atlas, rect[0], rect[1], rect[2], rect[3]);

        var origin = json.origin;
        if (origin != null) {
            anchorX = origin[0];
            anchorY = origin[1];
        } else {
            anchorX = 0;
            anchorY = 0;
        }
    }

    public function createSprite () :ImageSprite
    {
        var sprite = new ImageSprite(texture);
        sprite.setAnchor(anchorX, anchorY);
        return sprite;
    }

    inline private function get_name () :String
    {
        return _name;
    }

    private var _name :String;
}
