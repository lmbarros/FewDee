/**
 * A color representation that can behave either as in premultiplied alpha
 * blending or as in conventional alpha blending.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.color;

import allegro5.allegro;


/**
 * A "split personality" color representation, which can behave either as in
 * premultiplied alpha blending or as in conventional alpha blending.
 *
 * Premultiplied alpha blending has some nice advantages over conventional alpha
 * blending, so FewDee adopts it wholeheartedly. however, conventional alpha
 * blending is arguably more intuitive to use in some common situations (for
 * example, when you want to make an object completely transparent and then make
 * it opaque again).
 *
 * $(D Color) intends to provide the advantages of premultiplied alpha blending,
 * while offering some additional features that allow it to be used as if color
 * and opacity were independent (as in conventional alpha blending).
 *
 * This comes at a price, both in space and time. First, some additional space
 * is used by a $(D Color) (in comparison to any more orthodox color
 * representation, like $(D ALLEGRO_COLOR). Second, there is some CPU overhead:
 * since internally a $(D Color) effectively keeps two different color
 * representations, it has to keep both of them in-sync whenever a $(D Color)
 * object is updated.
 *
 * One more thing: the two representations cannot always be kept in-sync. In
 * particular, when the RGBA color (the premultiplied alpha one) represents an
 * "additive blending color" (alpha equals to zero, RGB components different
 * than zero), there is no equivalent in conventional alpha blending. So, if you
 * mix both representations, you better know what you are doing.
 *
 * Doing common things should be simple in FewDee. That was one of the main
 * motivations for creating it. So, I guess that paying the extra price of using
 * $(D Color) objects is worth it.
 *
 * See_also:
 *    http://home.comcast.net/~tom_forsyth/blog.wiki.html%23%5B%5BPremultiplied%2520alpha%5D%5D,
 *    http://blogs.msdn.com/b/shawnhar/archive/2009/11/06/premultiplied-alpha.aspx
 */
struct Color
{
   /**
    * The RGBA color, normally interpreted as if premultiplied alpha blending is
    * being used.
    */
   public final @property ALLEGRO_COLOR rgba() const
   {
      return _rgba;
   }

   /// Ditto.
   public final @property void rgba(in ALLEGRO_COLOR rgba)
   {
      _rgba = rgba;

      float r, g, b, a;
      al_unmap_rgba_f(rgba, &r, &g, &b, &a);
      _opacity = a;
      if (a > 0)
         _baseColor = [ r/a, g/a, b/a ];
      else
         _baseColor = [ 0, 0, 0 ];
   }

   /**
    * The, er, "color component of the color" (that is, without opacity), as if
    * conventional alpha blending is used.
    */
   public final @property float[3] baseColor() const
   {
      return _baseColor;
   }

   /// Ditto.
   public final @property void baseColor(in float[3] baseColor)
   {
      _baseColor = baseColor;
      recomputeRGBA();
   }

   /// The opacity , as if conventional alpha blending is used.
   public final @property float opacity() const
   {
      return _opacity;
   }

   /// Ditto.
   public final @property void opacity(in float opacity)
   {
      _opacity = opacity;
      recomputeRGBA();
   }

   /**
    * Recomputes the $(D _rgba) member, after either component of the
    * "conventional alpha blending" representation is changed.
    */
   private final void recomputeRGBA()
   {
      _rgba = al_map_rgba_f(_baseColor[0] * _opacity,
                            _baseColor[1] * _opacity,
                            _baseColor[2] * _opacity,
                            _opacity);
   }

   /// The premultiplied alpha color; the "main" color representation.
   public ALLEGRO_COLOR _rgba = { 1.0, 1.0, 1.0, 1.0 };

   /**
    * The "base color", used for the "conventional alpha blending"
    * representation.
    */
   private float[3] _baseColor = [ 1.0, 1.0, 1.0 ];

   /// The opacity, used for the "conventional alpha blending" representation.
   private float _opacity = 1.0;

   alias rgba this;
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
