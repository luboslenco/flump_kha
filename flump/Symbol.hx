//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

/**
 * Defines an exported SWF symbol.
 */
interface Symbol
{
    /**
     * The name of this symbol.
     */
    var name (get, null) :String;

    /**
     * Instantiate a sprite that displays this symbol.
     */
    function createSprite () :Sprite;
}
