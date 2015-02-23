//
// Flump for Haxe Kha - https://github.com/luboslenco/flump_kha
// Ported from Flambe - https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flump;

@:final class Entity
{
    /** This entity's parent. */
    public var parent (default, null) :Entity = null;

    /** This entity's first child. */
    public var firstChild (default, null) :Entity = null;

    /** This entity's next sibling, for iteration. */
    public var next (default, null) :Entity = null;

    /** This entity's first component. */
    public var firstComponent (default, null) :Component = null;

    public function new ()
    {
    }

    /**
     * Add a component to this entity. Any previous component of this type will be replaced.
     * @returns This instance, for chaining.
     */
    public function add (component :Component) :Entity
    {
        // Remove the component from any previous owner. Don't just call dispose, which has
        // additional behavior in some components (like Disposer).
        if (component.owner != null) {
            component.owner.remove(component);
        }

        // Append it to the component list
        var tail = null, p = firstComponent;
        while (p != null) {
            tail = p;
            p = p.next;
        }
        if (tail != null) {
            tail.next = component;
        } else {
            firstComponent = component;
        }

        component.owner = this;
        component.next = null;
        component.onAdded();

        return this;
    }

    /**
     * Remove a component from this entity.
     * @return Whether the component was removed.
     */
    public function remove (component :Component) :Bool
    {
        var prev :Component = null, p = firstComponent;
        while (p != null) {
            var next = p.next;
            if (p == component) {
                // Splice out the component
                if (prev == null) {
                    firstComponent = next;
                } else {
                    prev.owner = this;
                    prev.next = next;
                }

                p.onRemoved();
                p.owner = null;
                p.next = null;
                return true;
            }
            prev = p;
            p = next;
        }
        return false;
    }

    public function get<A:Component> (componentClass :Class<A>):A
    {
        var p = firstComponent;
        while (p != null)
        {
            if (Std.is(p, componentClass))
            {
                return cast p;
            }

            p = p.next;
        }
        return null;
    }

    /**
     * Adds a child to this entity.
     * @param append Whether to add the entity to the end or beginning of the child list.
     * @returns This instance, for chaining.
     */
    public function addChild (entity :Entity) :Entity
    {
        if (entity.parent != null) {
            entity.parent.removeChild(entity);
        }
        entity.parent = this;

        // Append it to the child list
        var tail = null, p = firstChild;
        while (p != null) {
            tail = p;
            p = p.next;
        }
        if (tail != null) {
            tail.next = entity;
        } else {
            firstChild = entity;
        }

        return this;
    }

    public function removeChild (entity :Entity)
    {
        var prev :Entity = null, p = firstChild;
        while (p != null) {
            var next = p.next;
            if (p == entity) {
                // Splice out the entity
                if (prev == null) {
                    firstChild = next;
                } else {
                    prev.next = next;
                }
                p.parent = null;
                p.next = null;
                return;
            }
            prev = p;
            p = next;
        }
    }

    public function update() {
        var p = firstComponent;
        while (p != null)
        {
            p.onUpdate();
            p = p.next;
        }

        var c = firstChild;
        while (c != null)
        {
            c.update();
            c = c.next;
        }
    }
}
