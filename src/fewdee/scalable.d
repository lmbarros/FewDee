/**
 * Interface to be implemented by everything that can be scaled.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.scalable;


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
 * A default implementation for $(D Scalable) objects. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * one of the position coordinates is changed. One typical action to perform
 * after changing the coordinates is to dirty the bounding box.
 */
mixin template ScalableDefaultImplementation(string postSet = "")
{
   public @property float scaleX() const{ return _scaleX; }

   public @property void scaleX(float scaleX)
   {
      this._scaleX = scaleX;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property float scaleY() const { return _scaleY; }

   public @property void scaleY(float scaleY)
   {
      this._scaleY = scaleY;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private float _scaleX = 1.0;
   private float _scaleY = 1.0;
}
