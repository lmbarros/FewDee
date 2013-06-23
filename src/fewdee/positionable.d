/**
 * Interface to be implemented by everything that has a position in the 2D
 * world.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.positionable;


/**
 * Interface to be implemented by everything that has a position in the 2D
 * world.
 */
interface Positionable
{
   /// Returns the x coordinate of the position.
   public @property float x() const;

   /// Sets the x coordinate of the position.
   public @property void x(float x);

   /// Returns the y coordinate of the position.
   public @property float y() const;

   /// Sets the y coordinate of the position.
   public @property void y(float y);
}


/**
 * A default implementation for $(D Positionable) objects. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * one of the position coordinates is changed. One typical action to perform
 * after changing the coordinates is to dirty the bounding box.
 */
mixin template PositionableDefaultImplementation(string postSet = "")
{
   public @property float x() const{ return _x; }

   public @property void x(float x)
   {
      this._x = x;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property float y() const { return _y; }

   public @property void y(float y)
   {
      this._y = y;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private float _x = 0.0;
   private float _y = 0.0;
}
