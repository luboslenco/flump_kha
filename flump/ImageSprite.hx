//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

/**
 * A fixed-size sprite that displays a single texture.
 */
class ImageSprite extends Sprite
{
    /**
     * The texture being displayed, or null if none.
     */
    public var texture :Texture;

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
    }

    override public function draw (g :kha.graphics2.Graphics)
    {
        if (texture != null && visible) {

            //var matrix = getLocalMatrix();
            //g.pushTransformation(new kha.math.Matrix3([matrix.m00, matrix.m01, matrix.m02, matrix.m10, matrix.m11, matrix.m12, 0, 0, 1]));

            var _x = x - anchorX * scaleX + Sprite.offsetX;
            var _y = y - anchorY * scaleY + Sprite.offsetY;

            var _ox = _x + (anchorX * scaleX);
            var _oy = _y + (anchorY * scaleY);
            g.pushRotation(rotation, _ox, _oy);

            g.drawScaledSubImage(texture.image,
                texture.sourceX, texture.sourceY,
                texture.sourceW, texture.sourceH,
                _x, _y,
                texture.sourceW * scaleX, texture.sourceH * scaleY);

            //g.drawSubImage(texture.image, 0, 0, texture.sourceX, texture.sourceY, texture.sourceW, texture.sourceH);

            g.popTransformation();
        }
    }

    override public function getNaturalWidth () :Float
    {
        return (texture != null) ? texture.image.width : 0;
    }

    override public function getNaturalHeight () :Float
    {
        return (texture != null) ? texture.image.height : 0;
    }
}
