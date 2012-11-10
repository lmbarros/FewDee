/**
 * A scene graph node that performs scale, rotation and translation.
 *
 * Authors: Leandro Motta Barros
 */

module twodee.sg.srt;

import allegro5.allegro;
import twodee.sg.group;
import twodee.sg.node_visitor;


/**
 * A scene graph node that performs scale, rotation and translation (in this
 * order).
 */
class SRT: Group
{
   /// Accepts a NodeVisitor. The Visitor pattern, you know.
   public override void accept(NodeVisitor visitor)
   {
      visitor.pushNodeToNodePath(this);

      visitor.visit(this);

      foreach(node; children_)
         node.accept(visitor);

      visitor.popNodeFromNodePath(this);
   }

   public @property const(ALLEGRO_TRANSFORM*) transform()
   {
      if (isDirty_)
      {
         al_identity_transform(&transform_);
         al_translate_transform(&transform_, tx, ty);
         al_rotate_transform(&transform_, r);
         al_scale_transform(&transform_, sx, sy);
      }

      isDirty_ = false;

      return &transform_;
   }

   /// Gets the translation along the x axis.
   public @property float tx() const { return tx_; }

   /// Gets the translation along the y axis.
   public @property float ty() const { return ty_; }

   /// Gets the scale along the x axis.
   public @property float sx() const { return sx_; }

   /// Gets the scale along the y axis.
   public @property float sy() const { return sy_; }

   /// Gets the rotation.
   public @property float r() const { return r_; }

   /// Gets the translation along the x axis.
   public @property void tx(float tx) { tx_ = tx; isDirty_ = true; }

   /// Gets the translation along the y axis.
   public @property void ty(float ty) { ty_ = ty; isDirty_ = true; }

   /// Gets the scale along the x axis.
   public @property void sx(float sx) { sx_ = sx; isDirty_ = true; }

   /// Gets the scale along the y axis.
   public @property void sy(float sy) { sy_ = sy; isDirty_ = true; }

   /// Gets the rotation.
   public @property void r(float r) { r_ = r; isDirty_ = true; }

   /// Does transform_ need to be recomputed?
   private bool isDirty_ = true;

   /// The translation along the x axis.
   private float tx_ = 0.0;

   /// The translation along the x axis.
   private float ty_ = 0.0;

   /// The scale along the x axis.
   private float sx_ = 1.0;

   /// The scale along the y axis.
   private float sy_ = 1.0;

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // radians? counter-clockwise?
   /// The rotation.
   private float r_ = 0.0;

   /**
    * The transform. When isDirty_ == true, it must be recomputed because at
    * least one of tx, ty, sy, sy or r has been assigned a new value.
    */
   private ALLEGRO_TRANSFORM transform_;
}
