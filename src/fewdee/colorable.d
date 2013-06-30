/**
 * Interface to be implemented by everything that can be colored.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.colorable;

import allegro5.allegro;
public import fewdee.color; // import publicly; all clients will need 'Color'


/**
 * Interface to be implemented by everything that can be colored.
 *
 * See_also: Color
 */
interface Colorable
{
   /// Returns the color.
   public @property ref inout(Color) color() inout;

   /// Sets the color.
   public @property void color(in Color color);

   /// Ditto.
   public @property void color(in ALLEGRO_COLOR color);
}


/**
 * A default implementation for $(D Colorable) objects. The $(D postSet)
 * parameter, if not an empty string, shall contain code to be executed after
 * the color is changed.
 */
mixin template ColorableDefaultImplementation(string postSet = "")
{
   public @property ref inout(Color) color() inout
   {
      return _color;
   }

   public @property void color(in Color color)
   {
      _color = color;

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   public @property void color(in ALLEGRO_COLOR color)
   {
      _color.rgba = color;

      static if (postSet != "")
      {
         mixin(postSet);
      }
   }

   private Color _color;
}
