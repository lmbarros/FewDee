/**
 * A scene graph node that displays a $(D Sprite).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.sprite_node;

import allegro5.allegro;
import std.conv;
import fewdee.aabb;
import fewdee.color;
import fewdee.sprite;
import fewdee.sg.drawable;


/// A collection of same-sized bitmaps and a few additional bits.
public class SpriteNode: Drawable
{
   /**
    * Constructs the $(D SpriteNode).
    *
    * Parameters:
    *    spriteTemplate = The $(D SpriteTemplate) upon which the internal $(D
    *       Sprite) instance will be based.
    */
   public this(SpriteTemplate spriteTemplate)
   {
      _sprite = new Sprite(spriteTemplate);
   }

   /// Draws the $(D SpriteNode) to the current target.
   public override void draw()
   {
      _sprite.draw();
   }

   // Inherit docs
   protected override void recomputeAABB(ref AABB aabb)
   {
      const w = _sprite.spriteTemplate.width;
      const h = _sprite.spriteTemplate.height;
      const cx = _sprite.spriteTemplate.centerX;
      const cy = _sprite.spriteTemplate.centerY;

      aabb = AABB(y - cy, y + h - cy,
                  x - cx, x + w - cx);
   }

   /// The underlying $(D Sprite).
   public final @property inout(Sprite) sprite() inout
   {
      return _sprite;
   }

   /// The $(I x) coordinate of the position.
   public final @property float x() const
   {
      return _sprite.x;
   }

   /// Ditto.
   public final @property void x(float x)
   {
      _sprite.x = x;
      dirtyAABB();
   }

   /// The $(I y) coordinate of the position.
   public final @property float y() const
   {
      return _sprite.y;
   }

   /// Ditto.
   public final @property void y(float y)
   {
      _sprite.y = y;
      dirtyAABB();
   }

   /// The rotation, in radians.
   public final @property float rotation() const { return _sprite.rotation; }

   /// Ditto.
   public final @property void rotation(float rotation)
   {
      _sprite.rotation = rotation;
      dirtyAABB();
   }

   /// The sprite scale.
   public final @property void scale(float scale)
   {
      _sprite.scaleX = scale;
      _sprite.scaleY = scale;
      dirtyAABB();
   }

   /// The sprite scale along the $(I x) axis.
   public final @property float scaleX() const { return _sprite.scaleX; }

   /// Ditto.
   public final @property void scaleX(float scaleX)
   {
      _sprite.scaleX = scaleX;
      dirtyAABB();
   }

   /// The sprite scale along the $(I y) axis.
   public final @property float scaleY() const { return _sprite.scaleY; }

   /// Ditto.
   public final @property void scaleY(float scaleY)
   {
      _sprite.scaleY = scaleY;
      dirtyAABB();
   }

   /// The sprite color.
   public final @property ref inout(Color) color() inout
   {
      return _sprite.color;
   }

   /// Ditto.
   public final @property void color(in Color color)
   {
      _sprite.color = color;
   }

   /// Ditto.
   public final @property void color(in ALLEGRO_COLOR color)
   {
      _sprite.color.rgba = color;
   }

   /// Give direct access to the underlying $(D Sprite).
   public alias _sprite this;

   /**
    * The $(D Sprite) "encapsulated" by this $(D SpriteNode).
    *
    * This is $(D public) just to make the $(D alias this) work.
    */
   public Sprite _sprite;
}
