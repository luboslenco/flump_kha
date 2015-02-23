//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

/**
 * A loaded texture image.
 */
class Texture //extends Asset
{
    public var image :kha.Image;
    public var sourceX :Int;
    public var sourceY :Int;
    public var sourceW :Int;
    public var sourceH :Int;

    public function new(image:kha.Image, sourceX:Int, sourceY:Int, sourceW:Int, sourceH:Int) {
        this.image = image;
        this.sourceX = sourceX;
        this.sourceY = sourceY;
        this.sourceW = sourceW;
        this.sourceH = sourceH;
    }
}
