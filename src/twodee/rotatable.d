/**
 * Interface to be implemented by everything that can be rotated.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.rotatable;


/**
 * Interface to be implemented by everything that can be rotated. The rotation
 * is expressed in radians; increasing the rotation value makes the object turn
 * in the clockwise direction.
 */
interface Rotatable
{
   /// Returns the rotation, in radians.
   public @property float rotation() const;

   /// Sets the rotation.
   public @property void rotation(float rotation);
}


/**
 * A default implementation for Rotatable objects. The "postSet" parameter, if
 * not an empty string, shall contain code to be executed after the rotation is
 * changed. One typical action to perform after changing the coordinates is to
 * dirty the bounding box.
 */
mixin template RotatableDefaultImplementation(string postSet = "")
{
   public @property float rotation() const{ return rotation_; }

   public @property void rotation(float rotation)
   {
      this.rotation_ = rotation;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private float rotation_ = 0.0;
}
