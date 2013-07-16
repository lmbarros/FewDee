/**
 * Default implementations for $(D Colorable), $(D Positionable) and friends.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.internal.default_implementations;

/**
 * A default implementation for objects that have a color. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * the color is changed.
 */
mixin template ColorableDefaultImplementation(string postSet = "")
{
   /// The object color.
   public final @property ref inout(Color) color() inout
   {
      return _color;
   }

   /// Ditto.
   public final @property void color(in Color color)
   {
      _color = color;

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// Ditto.
   public final @property void color(in ALLEGRO_COLOR color)
   {
      _color.rgba = color;

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The object color.
   private Color _color;
}



/**
 * A default implementation for objects that can be positioned. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * one of the position coordinates is changed. One typical action to perform
 * after changing the coordinates is to dirty the bounding box.
 */
mixin template PositionableDefaultImplementation(string postSet = "")
{
   /// The $(I x) coordinate of the object position.
   public final @property float x() const { return _x; }

   /// Ditto.
   public final @property void x(float x)
   {
      _x = x;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The $(I y) coordinate of the object position.
   public final @property float y() const { return _y; }

   /// Ditto.
   public final @property void y(float y)
   {
      _y = y;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The $(I x) coordinate of the object position.
   private float _x = 0.0;

   /// The $(I y) coordinate of the object position.
   private float _y = 0.0;
}


/**
 * A default implementation for objects that can be rotated. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * the rotation is changed. One typical action to perform after changing the
 * coordinates is to dirty the bounding box.
 */
mixin template RotatableDefaultImplementation(string postSet = "")
{
   /// The object rotation, in radians.
   public final @property float rotation() const { return _rotation; }

   /// Ditto.
   public final @property void rotation(float rotation)
   {
      _rotation = rotation;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The object rotation, in radians.
   private float _rotation = 0.0;
}


/**
 * A default implementation for objects that can be scaled. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * one of the position coordinates is changed. One typical action to perform
 * after changing the coordinates is to dirty the bounding box.
 */
mixin template ScalableDefaultImplementation(string postSet = "")
{
   /// The object scale.
   public final @property void scale(float scale)
   {
      _scaleX = scale;
      _scaleY = scale;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The object scale along the $(I x) axis.
   public final @property float scaleX() const { return _scaleX; }

   /// Ditto.
   public final @property void scaleX(float scaleX)
   {
      _scaleX = scaleX;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The object scale along the $(I y) axis.
   public final @property float scaleY() const { return _scaleY; }

   /// Ditto.
   public final @property void scaleY(float scaleY)
   {
      _scaleY = scaleY;
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   /// The object scale along the $(I x) axis.
   private float _scaleX = 1.0;

   /// The object scale along the $(I y) axis.
   private float _scaleY = 1.0;
}
