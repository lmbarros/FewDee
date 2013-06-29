/**
 * Interface to be implemented by everything that can be colored.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.colorable;

import allegro5.allegro;


/**
 * Interface to be implemented by everything that can be colored.
 *
 * Colors have two simultaneous representations. First, the are represented as a
 * RGBA quartet (an $(D ALLEGRO_COLOR)), by default interpreted as a
 * "premultiplied alpha color" (this is the color that is really used
 * internally when drawing). Second, there is a (arguably more intuitive) "base
 * color" plus opacity representation, which mimics the conventional alpha
 * blending. As much as possible, when setting one of the representations, the
 * other is updated accordingly. But there are cases in which the conversion is
 * not possible (case in point: when the RGBA color represents an "additive
 * blending color" -- alpha equals to zero, RGB components different than
 * zero). So, if you mix both representations, you better know what you are
 * doing.
 */
interface Colorable
{
   /// Returns the low-level RGBA color.
   public @property ALLEGRO_COLOR rgba() const;

   /// Sets low-level RGBA color.
   public @property void rgba(in ALLEGRO_COLOR color);

   /// Returns the base color.
   public @property float[3] baseColor() const;

   /// Sets the base color.
   public @property void baseColor(in float[3] baseColor);

   /// Returns the opacity.
   public @property float opacity() const;

   /// Sets the opacity.
   public @property void opacity(in float opacity);
}


/**
 * A default implementation for $(D Colorable) objects. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * the color is changed.
 */
mixin template ColorableDefaultImplementation(string postSet = "")
{
   public @property ALLEGRO_COLOR rgba() const
   {
      return _rgba;
   }

   public @property void rgba(in ALLEGRO_COLOR color)
   {
      _rgba = color;

      float r, g, b, a;
      al_unmap_rgba_f(color, &r, &g, &b, &a);
      _opacity = a;
      if (a > 0)
         _baseColor = [ r/a, g/a, b/a ];
      else
         _baseColor = [ 0, 0, 0 ];

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property float[3] baseColor() const
   {
      return _baseColor;
   }

   public @property void baseColor(in float[3] baseColor)
   {
      _baseColor = baseColor;
      recomputeRGBA();

      _rgba = al_map_rgba_f(_baseColor[0] * _opacity,
                            _baseColor[1] * _opacity,
                            _baseColor[2] * _opacity,
                            _opacity);
      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property float opacity() const
   {
      return _opacity;
   }

   public @property void opacity(in float opacity)
   {
      _opacity = opacity;
      recomputeRGBA();

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private final void recomputeRGBA()
   {
      _rgba = al_map_rgba_f(_baseColor[0] * _opacity,
                            _baseColor[1] * _opacity,
                            _baseColor[2] * _opacity,
                            _opacity);
   }

   private ALLEGRO_COLOR _rgba = { 1.0, 1.0, 1.0, 1.0 };
   private float[3] _baseColor = [ 1.0, 1.0, 1.0 ];
   private float _opacity = 1.0;
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
