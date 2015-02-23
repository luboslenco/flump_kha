//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

class Sprite extends Component
{
    /**
     * X position, in pixels.
     */
    public var x  :Float;

    /**
     * Y position, in pixels.
     */
    public var y  :Float;

    /**
     * Rotation angle, in degrees.
     */
    public var rotation  :Float;

    /**
     * Horizontal scale factor.
     */
    public var scaleX  :Float;

    /**
     * Vertical scale factor.
     */
    public var scaleY  :Float;

    /**
     * The X position of this sprite's anchor point. Local transformations are applied relative to
     * this point.
     */
    public var anchorX  :Float;

    /**
     * The Y position of this sprite's anchor point. Local transformations are applied relative to
     * this point.
     */
    public var anchorY  :Float;

    /**
     * The alpha (opacity) of this sprite, between 0 (invisible) and 1 (fully opaque).
     */
    public var alpha  :Float;

    public static var offsetX :Float = 0;
    public static var offsetY :Float = 0;

    /**
     * Whether this sprite should be drawn. Invisible sprites do not receive pointer events.
     */
    public var visible :Bool;

    public function new ()
    {
        _localMatrix = new Matrix();

        x = 0;
        y = 0;
        rotation = 0;
        scaleX = 1;
        scaleY = 1;
        anchorX = 0;
        anchorY = 0;
        alpha = 1;

        visible = true;
    }

    /**
     * Renders an entity hierarchy to the given Graphics.
     */
    public static function render (entity :Entity, g :kha.graphics2.Graphics)
    {
        // Render this entity's sprite
        var sprite = entity.get(Sprite);
        if (sprite != null) {
            var alpha = sprite.alpha;
            if (!sprite.visible || alpha <= 0) {
                return; // Prune traversal, this sprite and all children are invisible
            }

            //g.save();
            if (alpha < 1) {
                //g.multiplyAlpha(alpha);
                g.opacity = alpha;
            }
            
            //var matrix = sprite.getLocalMatrix();
            //g.transform(matrix.m00, matrix.m10, matrix.m01, matrix.m11, m02, m12);

            sprite.draw(g);
        }

        // Render all children
        var p = entity.firstChild;
        while (p != null) {
            var next = p.next;
            render(p, g);
            p = next;
        }

        // If save() was called, unwind it
        //if (sprite != null) {
        //    g.restore();
        //}
    }

    /**
     * The "natural" width of this sprite, without any transformations being applied. Used for hit
     * testing. This does not consider child sprites, use Sprite.getBounds for that.
     */
    public function getNaturalWidth () :Float
    {
        return 0;
    }

    /**
     * The "natural" height of this sprite, without any transformations being applied. Used for hit
     * testing. This does not consider child sprites, use Sprite.getBounds for that.
     */
    public function getNaturalHeight () :Float
    {
        return 0;
    }

    

    /**
     * Returns the local transformation matrix, relative to the parent. This matrix may be modified
     * to position the sprite, but any changes will be invalidated when the x, y, scaleX, scaleY,
     * rotation, anchorX, or anchorY properties are updated.
     */
    public function getLocalMatrix () :Matrix
    {
        if (localMatrixDirty) {
            localMatrixDirty = false;

            if(rotationDirty) {
                rotationDirty = false;
                var rotation :Float = Sprite.toRadians(this.rotation);
                _sinCache = Math.sin(rotation);
                _cosCache = Math.cos(rotation);
            }

            var scaleX :Float = this.scaleX;
            var scaleY :Float = this.scaleY;
            _localMatrix.set(_cosCache*scaleX, _sinCache*scaleX, -_sinCache*scaleY, _cosCache*scaleY, x, y);
            _localMatrix.translate(-anchorX, -anchorY);
        }
        return _localMatrix;
    }

    public static inline var PI = 3.141592653589793;
    inline public static function toRadians (degrees :Float) :Float
    {
        return degrees * PI/180;
    }

    /**
     * Returns the view transformation matrix, relative to the root. Do NOT modify this matrix.
     */
    public function getViewMatrix () :Matrix
    {
        if (isViewMatrixDirty()) {
            var parentSprite = getParentSprite();
            _viewMatrix = (parentSprite != null)
                ? Matrix.multiply(parentSprite.getViewMatrix(), getLocalMatrix(), _viewMatrix)
                : getLocalMatrix().clone(_viewMatrix);

            viewMatrixDirty = false;
            if (parentSprite != null) {
                _parentViewMatrixUpdateCount = parentSprite._viewMatrixUpdateCount;
            }
            ++_viewMatrixUpdateCount;
        }
        return _viewMatrix;
    }

    /**
     * Chainable convenience method to set the anchor position.
     * @returns This instance, for chaining.
     */
    public function setAnchor (x :Float, y :Float) :Sprite
    {
        anchorX = x;
        anchorY = y;
        return this;
    }

    /**
     * Chainable convenience method to center the anchor using the natural width and height.
     * @returns This instance, for chaining.
     */
    public function centerAnchor () :Sprite
    {
        anchorX = getNaturalWidth()/2;
        anchorY = getNaturalHeight()/2;
        return this;
    }

    /**
     * Chainable convenience method to set the position.
     * @returns This instance, for chaining.
     */
    public function setXY (x :Float, y :Float) :Sprite
    {
        this.x = x;
        this.y = y;
        return this;
    }
	
    /**
     * Chainable convenience method to set the alpha.
     * @returns This instance, for chaining.
     */
    public function setAlpha (alpha :Float) :Sprite
    {
        this.alpha = alpha;
        return this;
    }
	
    /**
     * Chainable convenience method to set the rotation.
     * @returns This instance, for chaining.
     */
    public function setRotation (rotation :Float) :Sprite
    {
        this.rotation = rotation;
        return this;
    }

    /**
     * Chainable convenience method to uniformly set the scale.
     * @returns This instance, for chaining.
     */
    public function setScale (scale :Float) :Sprite
    {
        scaleX = scale;
        scaleY = scale;
        return this;
    }

    /**
     * Chainable convenience method to set the scale.
     * @returns This instance, for chaining.
     */
    public function setScaleXY (scaleX :Float, scaleY :Float) :Sprite
    {
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        return this;
    }

    

    override public function onAdded ()
    {
    }

    override public function onRemoved ()
    {
    }

    override public function onUpdate ()
    {
    }

    /**
     * Draws this sprite to the given Graphics.
     */
    public function draw (g :kha.graphics2.Graphics)
    {
        // See subclasses
    }

    private function isViewMatrixDirty () :Bool
    {
        if (viewMatrixDirty) {
            return true;
        }
        var parentSprite = getParentSprite();
        if (parentSprite == null) {
            return false;
        }
        return _parentViewMatrixUpdateCount != parentSprite._viewMatrixUpdateCount
            || parentSprite.isViewMatrixDirty();
    }

    private function getParentSprite () :Sprite
    {
        if (owner == null) {
            return null;
        }
        var entity = owner.parent;
        while (entity != null) {
            var sprite = entity.get(Sprite);
            if (sprite != null) {
                return sprite;
            }
            entity = entity.parent;
        }
        return null;
    }

    private var _localMatrix :Matrix;

    private var localMatrixDirty :Bool = true;
    private var viewMatrixDirty :Bool = true;
    private var rotationDirty :Bool = true;

    private var _viewMatrix :Matrix = null;
    private var _viewMatrixUpdateCount :Int = 0;
    private var _parentViewMatrixUpdateCount :Int = 0;
    private var _sinCache :Float = 0;
    private var _cosCache :Float = 0;
}
