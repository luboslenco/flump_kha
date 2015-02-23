//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

/**
 * Components are bits of data and logic that can be added to entities.
 */
class Component
{
    /** The entity this component is attached to, or null. */
    public var owner :Entity = null;

    /** The owner's next component, for iteration. */
    public var next :Component = null;

    /**
     * Called after this component has been added to an entity.
     */
    public function onAdded ()
    {
    }

    /**
     * Called just before this component has been removed from its entity.
     */
    public function onRemoved ()
    {
    }

    /**
     * Called when this component receives a game update.
     * @param dt The time elapsed since the last frame, in seconds.
     */
    public function onUpdate ()
    {
    }
}
