/**
 * Interface to be implemented by everything that can be scaled.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.scalable;


/// Interface to be implemented by everything that can be scaled.
interface Scalable
{
   /// Returns the scale along the x axis.
   public @property float scaleX() const;

   /// Sets the scale along the x axis.
   public @property void scaleX(float scaleX);

   /// Returns the scale along the y axis.
   public @property float scaleY() const;

   /// Sets the scale along the y axis.
   public @property void scaleY(float scaleY);
}


/**
 * A default implementation for Scalable objects. The "postSet" parameter, if
 * not an empty string, shall contain code to be executed after one of the
 * position coordinates is changed. One typical action to perform after changing
 * the coordinates is to dirty the bounding box.
 */
mixin template ScalableDefaultImplementation(string postSet = "")
{
   public @property float scaleX() const{ return scaleX_; }

   public @property void scaleX(float scaleX)
   {
      this.scaleX_ = scaleX;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property float scaleY() const { return scaleY_; }

   public @property void scaleY(float scaleY)
   {
      this.scaleY_ = scaleY;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private float scaleX_ = 1.0;
   private float scaleY_ = 1.0;
}
