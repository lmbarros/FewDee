/**
 * Interface to be implemented by everything that can be colored.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.colorable;

import allegro5.allegro;


/// Interface to be implemented by everything that can be colored.
interface Colorable
{
   /// Returns the color.
   public @property ALLEGRO_COLOR color() const;

   /// Sets the color.
   public @property void color(in ALLEGRO_COLOR color);
}


/**
 * A default implementation for Colorable objects. The "postSet" parameter, if
 * not an empty string, shall contain code to be executed after the color is
 * changed.
 */
mixin template ColorableDefaultImplementation(string postSet = "")
{
   public @property ALLEGRO_COLOR color() const
   {
      return color_;
   }

   public @property void color(in ALLEGRO_COLOR color)
   {
      this.color_ = color;

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private ALLEGRO_COLOR color_ = { 1.0, 1.0, 1.0, 1.0 };
}


// Theoretically, ALLEGRO_COLOR is an opaque type that should be accessed only
// through functions like al_map_rgba_f(). However, being able to initialize it
// directly simplifies the code a lot. So, here we just make sure that the
// ALLEGRO_COLOR structure still is like we expect it to be. If ALLEGRO_COLOR is
// changed, at least one of these static asserts will fail to alert us that the
// code must be somehow updated.
static assert(is(typeof(ALLEGRO_COLOR.r) == float));
static assert(is(typeof(ALLEGRO_COLOR.g) == float));
static assert(is(typeof(ALLEGRO_COLOR.b) == float));
static assert(is(typeof(ALLEGRO_COLOR.a) == float));
