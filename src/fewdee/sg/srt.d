/**
 * A scene graph node that performs scale, rotation and translation.
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sg.srt;

import allegro5.allegro;
import fewdee.sg.group;
import fewdee.sg.node_visitor;


/**
 * A scene graph node that performs scale, rotation and translation (in this
 * order).
 */
public class SRT: Group
{
   /// Accepts a $(D NodeVisitor). The Visitor pattern, you know.
   public override void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);

      visitor.visit(this);

      foreach(node; _children)
         node.accept(visitor);

      visitor.popNodeFromNodePath(this);
   }

   /// Returns the transform represented by this SRT node.
   public final @property const(ALLEGRO_TRANSFORM*) transform()
   {
      if (_isTransformDirty)
      {
         al_identity_transform(&transform_);
         al_translate_transform(&transform_, x, y);
         al_rotate_transform(&transform_, rotation);
         al_scale_transform(&transform_, scaleX, scaleY);
      }

      _isTransformDirty = false;

      return &transform_;
   }

   /**
    * The translation along the $(I x) axis.
    *
    * This is called $(D x) instead of something like $(D tx) to simplify use
    * with canned updaters.
    */
   public final @property float x() const { return _x; }

   /// Ditto
   public final @property void x(float x)
   {
      _x = x;
      _isTransformDirty = true;
   }

   /**
    * The translation along the $(I y) axis.
    *
    * This is called $(D y) instead of something like $(D ty) to simplify use
    * with canned updaters.
    */
   public final @property float y() const { return _y; }

   /// Ditto
   public final @property void y(float y)
   {
      _y = y;
      _isTransformDirty = true;
   }

   /// The scale along the $(I x) axis.
   public final @property float scaleX() const { return _scaleX; }

   /// Ditto
   public final @property void scaleX(float scaleX)
   {
      _scaleX = scaleX;
      _isTransformDirty = true;
   }

   /// The scale along the $(I y) axis.
   public final @property float scaleY() const { return _scaleY; }

   /// Ditto
   public final @property void scaleY(float scaleY)
   {
      _scaleY = scaleY;
      _isTransformDirty = true;
   }

   /// The rotation, in radians. The angle grows in the clockwise direction.
   public final @property float rotation() const { return _rotation; }

   /// Ditto
   public final @property void rotation(float rotation)
   {
      _rotation = rotation;
      _isTransformDirty = true;
   }

   /// Does $(D transform_) need to be recomputed?
   private bool _isTransformDirty = true;

   /// The translation along the $(I x) axis.
   private float _x = 0.0;

   /// The translation along the $(I y) axis.
   private float _y = 0.0;

   /// The scale along the $(I x) axis.
   private float _scaleX = 1.0;

   /// The scale along the $(I y) axis.
   private float _scaleY = 1.0;

   /// The rotation, in radians. The angle grows in the clockwise direction.
   private float _rotation = 0.0;

   /**
    * The transform.
    *
    * When $(D _isTransformDirty == true), it must be recomputed because at
    * least one of $(D x), $(D y), $(D scaleX), $(D scaleY) or $(D rotation) has
    * been assigned a new value.
    */
   private ALLEGRO_TRANSFORM transform_;
}
