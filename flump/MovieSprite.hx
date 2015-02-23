//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

import flump.MovieSymbol;

/**
 * An instanced Flump animation.
 */
class MovieSprite extends Sprite
{
    /** The symbol this sprite displays. */
    public var symbol (default, null) :MovieSymbol;

    /** The current playback position in seconds. */
    public var position (get, set) :Float;

    /**
     * The playback speed multiplier of this movie, defaults to 1.0. Higher values will play faster.
     * This does not affect the speed of nested child movies, use `flambe.SpeedAdjuster` if you need
     * that.
     */
    public var speed (default, null) :Float;

    /** Whether this movie is currently paused. */
    public var paused :Bool = false;

    public var skipNext :Bool = false;

    /** Emitted when this movie loops back to the beginning. */
    //public var looped (get, null) :Signal0;

    public function new (symbol :MovieSymbol)
    {
        super();
        this.symbol = symbol;

        speed = 1;

        _animators = [];
        for (ii in 0...symbol.layers.length) {
            var layer = symbol.layers[ii];
            _animators.push(new LayerAnimator(layer));
        }

        _frame = 0;
        _position = 0;
        goto(1);
    }

    /**
     * Retrieves a named layer from this movie. Children can be added to the returned entity to add
     * sprites that move with the layer, which for example, can be used to add equipment sprites to
     * an avatar.
     * @param required If true and the layer is not found, an error is thrown.
     */
    public function getLayer (name :String, required :Bool = true) :Entity
    {
        for (animator in _animators) {
            if (animator.layer.name == name) {
                return animator.content;
            }
        }
        if (required) {
            throw "Missing layer";//.withFields(["name", name]);
        }
        return null;
    }

    override public function onAdded ()
    {
        super.onAdded();

        for (animator in _animators) {
            owner.addChild(animator.content);
        }
    }

    override public function onRemoved ()
    {
        super.onRemoved();

        // Detach the animator content layers so they don't get disconnected during a disposal. This
        // may be a little hacky as it prevents child components from ever being formally removed.
        for (animator in _animators) {
            owner.removeChild(animator.content);
        }
    }

    override public function onUpdate ()
    {
        var dt = fox.sys.Time.delta;

        super.onUpdate();

        if (!paused && !skipNext) {
            // Neither paused nor skipping set, advance time
            _position += speed*dt;
            if (_position > symbol.duration) {
                _position = _position % symbol.duration;

                //if (_looped != null) {
                //    _looped.emit();
                //}
            }
        }
        else if (skipNext) {
            // Not paused, but skip this time step
            skipNext = false;
        }

        var newFrame = _position*symbol.frameRate;
        goto(newFrame);
    }

    private function goto (newFrame :Float)
    {
        if (_frame == newFrame) {
            return; // No change
        }

        var wrapped = newFrame < _frame;
        if (wrapped) {
            for (animator in _animators) {
                animator.needsKeyframeUpdate = true;
                animator.keyframeIdx = 0;
            }
        }
        for (animator in _animators) {
            animator.composeFrame(newFrame);
        }

        _frame = newFrame;
    }

    inline private function get_position () :Float
    {
        return _position;
    }

    private function set_position (position :Float) :Float
    {
        return _position = clamp(position, 0, symbol.duration);
    }

    static function clamp<T:Float> (value :T, min :T, max :T) :T
    {
        return if (value < min) min
            else if (value > max) max
            else value;
    }

    /*private function get_looped () :Signal0
    {
        if (_looped == null) {
            _looped = new Signal0();
        }
        return _looped;
    }*/

    /**
     * Internal method to set the position to 0 and skip the next update. This is required to modify
     * the playback position of child movies during an update step, so that after the update
     * trickles through the children, they end up at position=0 instead of position=dt.
     */
    public function rewind ()
    {
        _position = 0;
        skipNext = true;
    }

    private var _animators :Array<LayerAnimator>;

    private var _position :Float;
    private var _frame :Float;

    //private var _looped :Signal0 = null;
}

private class LayerAnimator
{
    public var content (default, null) :Entity;

    public var needsKeyframeUpdate :Bool = false;
    public var keyframeIdx :Int = 0;

    public var layer :MovieLayer;

    public function new (layer :MovieLayer)
    {
        this.layer = layer;

        content = new Entity();
        if (layer.empty) {
            _sprites = null;

        } else {
            // Populate _sprites with the Sprite at each keyframe, reusing consecutive symbols
            _sprites = [];
            for (ii in 0...layer.keyframes.length) {
                var kf = layer.keyframes[ii];
                var s:Sprite = null;
                if (ii > 0 && layer.keyframes[ii-1].symbol == kf.symbol) {
                    s = _sprites[ii-1];
                } else if (kf.symbol == null) {
                    s = new Sprite();
                } else {
                    s = kf.symbol.createSprite();
                }
                _sprites.push(s);
            }

            content.add(_sprites[0]);
        }
    }

    public function composeFrame (frame :Float)
    {
        if (_sprites == null) {
            // TODO(bruno): Test this code path
            // Don't animate empty layers
            return;
        }

        var keyframes = layer.keyframes;
        var finalFrame = keyframes.length - 1;

        if (frame > layer.frames) {
            // TODO(bruno): Test this code path
            // Not enough frames on this layer, hide it
            content.get(Sprite).visible = false;
            keyframeIdx = finalFrame;
            needsKeyframeUpdate = true;
            return;
        }

        while (keyframeIdx < finalFrame && keyframes[keyframeIdx+1].index <= frame) {
            ++keyframeIdx;
            needsKeyframeUpdate = true;
        }

        var sprite;
        if (needsKeyframeUpdate) {
            needsKeyframeUpdate = false;
            // Switch to the next instance if this is a multi-layer symbol
            sprite = _sprites[keyframeIdx];
            if (sprite != content.get(Sprite)) {
                if (Type.getClass(sprite) == MovieSprite) {
                    var movie :MovieSprite = cast sprite;
                    movie.rewind();
                }
                content.add(sprite);
            }
        } else {
            sprite = content.get(Sprite);
        }

        var kf = keyframes[keyframeIdx];
        var visible = kf.visible && kf.symbol != null;
        sprite.visible = visible;
        if (!visible) {
            return; // Don't bother animating invisible layers
        }

        var x = kf.x;
        var y = kf.y;
        var scaleX = kf.scaleX;
        var scaleY = kf.scaleY;
        var skewX = kf.skewX;
        var skewY = kf.skewY;
        var alpha = kf.alpha;

        if (kf.tweened && keyframeIdx < finalFrame) {
            var interp = (frame-kf.index) / kf.duration;
            var ease = kf.ease;
            if (ease != 0) {
                var t;
                if (ease < 0) {
                    // Ease in
                    var inv = 1 - interp;
                    t = 1 - inv*inv;
                    ease = -ease;
                } else {
                    // Ease out
                    t = interp*interp;
                }
                interp = ease*t + (1 - ease)*interp;
            }

            var nextKf = keyframes[keyframeIdx + 1];
            x += (nextKf.x-x) * interp;
            y += (nextKf.y-y) * interp;
            scaleX += (nextKf.scaleX-scaleX) * interp;
            scaleY += (nextKf.scaleY-scaleY) * interp;
            skewX += (nextKf.skewX-skewX) * interp;
            skewY += (nextKf.skewY-skewY) * interp;
            alpha += (nextKf.alpha-alpha) * interp;
        }

        // From an identity matrix, append the translation, skew, and scale
        var matrix = sprite.getLocalMatrix();
        var sinX = 0.0, cosX = 1.0;
        var sinY = 0.0, cosY = 1.0;
        if (skewX != 0) {
            sinX = Math.sin(skewX);
            cosX = Math.cos(skewX);
        }
        if (skewY != 0) {
            sinY = Math.sin(skewY);
            cosY = Math.cos(skewY);
        }

        matrix.set(cosY*scaleX, sinY*scaleX, -sinX*scaleY, cosX*scaleY, x, y);

        sprite.x = x;
        sprite.y = y;
        sprite.scaleX = scaleX;
        sprite.scaleY = scaleY;
        sprite.rotation = Math.atan2(matrix.m10, matrix.m11);

        // Append the pivot
        matrix.translate(-kf.pivotX, -kf.pivotY);

        sprite.anchorX = kf.pivotX;
        sprite.anchorY = kf.pivotY;
        sprite.alpha = alpha;
    }

    // The sprite to show at each keyframe index, or null if this layer has no symbol instances
    private var _sprites :Array<Sprite>;
}
