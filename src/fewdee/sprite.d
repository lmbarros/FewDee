/**
 * One word: Sprites.
 *
 * There are two sprite-related classes. One of them, $(D SpriteTemplate),
 * stores data (like animations) that can be shared among several sprites. The
 * second one, $(D Sprite), represents an "instance" of a $(D
 * SpriteTemplate). This design allows to cheaply instantiate a large number of
 * sprites that provide some nice, high-level features.
 *
 * In addition to these two classes, some related utilities are also included
 * here. (As I write this, the only one is a function used together with an $(D
 * Updater) to play sprite animations.)
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.sprite;

import std.conv;
import allegro5.allegro;
import fewdee.bitmap;
import fewdee.updater;


/**
 * A sprite template, which contains a collection of same-sized images and a
 * collection of animations.
 *
 * Notice that it has a collection of $(I images), not of $(D Bitmap)s. What I
 * call an "image" here, is a rectangular area within a $(D Bitmap). Yup, this
 * means that you can use sprite sheets (but it is OK to use one separate $(D
 * Bitmap) for each image -- though it may be less efficient than using sprite
 * sheets).
 */
public class SpriteTemplate
{
   /// Constructs the $(D SpriteTemplate) leaving its size uninitialized.
   public this()
   {
      // do nothing
   }

   /**
    * Constructs the $(D SpriteTemplate) initializing its size.
    *
    * Parameters:
    *    width = The width of the images, in pixels. Must be greater than zero.
    *    height = The height of the images, in pixels. Must be greater than
    *       zero.
    */
   public this(uint width, uint height)
   {
      setSize(width, height);
   }

   /**
    * Constructs the $(D SpriteTemplate) initializing its size and adding
    * bitmaps as the sprite images.
    *
    * Parameters:
    *    width = The width of the images, in pixels. Must be greater than zero.
    *    height = The height of the images, in pixels. Must be greater than
    *       zero.
    *    bitmaps = The bitmaps to add. For each bitmap, one image comprising the
    *       whole bitmap will be added.
    */
   public this(uint width, uint height, Bitmap[] bitmaps...)
   {
      setSize(width, height);
      foreach (bitmap; bitmaps)
         addImage(bitmap, bitmap.width, bitmap.height);
   }

   /**
    * Sets the width and height of the sprite images.
    *
    * This must be called before adding images. (But notice that the
    * constructors taking $(D width) and $(D height) parameters already call
    * this.)
    *
    * Parameters:
    *    width = The width of the images, in pixels. Must be greater than zero.
    *    height = The height of the images, in pixels. Must be greater than
    *       zero.
    */
   public final void setSize(uint width, uint height)
   in
   {
      assert(width > 0);
      assert(height > 0);
   }
   body
   {
      _width = width;
      _height = height;
   }

   /**
    * Sets the center (reference point) of the $(D Sprite).
    *
    * Parameters:
    *    x = The horizontal coordinate, in pixels, measured from the left side
    *       of the image, and growing to the right.
    *    y = The vertical coordinate, in pixels, measured from the top side of
    *       the image, and growing to the bottom.
    */
   public final void setCenter(float x, float y)
   {
      _centerX = x;
      _centerY = y;
   }

   /// The width of the $(D SpriteTemplate) images, in pixels.
   public final @property int width()
   {
      return _width;
   }

   /// The height of the $(D SpriteTemplate) images, in pixels.
   public final @property int height()
   {
      return _height;
   }

   /// The horizontal coordinate of the sprite center (reference point).
   public final @property float centerX()
   {
      return _centerX;
   }

   /// The vertical coordinate of the sprite center (reference point).
   public final @property float centerY()
   {
      return _centerY;
   }

   /**
    * Adds an image to the collection of images.
    *
    * You must call $(D setSize() before calling this method. (But notice that
    * the constructors taking $(D width) and $(D height) parameters do call $(D
    * setSize().)
    *
    * Parameters:
    *    bitmap = The $(D Bitmap) containing the image.
    *    x = The column of pixels (within $(D bitmap)) where the image
    *       starts. This measured from the left to the right, and the first
    *       column of the bitmap is column $(D 0).
    *    y = The row of pixels (within $(D bitmap)) where the image starts. This
    *       measured from the top to the bottom, and the first row of the bitmap
    *       is row $(D 0).
    *
    * Returns:
    *    Returns the index of the newly added image. Indexes are numbered
    *    sequentially: the first image is $(D 0), the second is $(D 1) and so
    *    on.
    */
   public final size_t addImage(Bitmap bitmap, uint x, uint y)
   in
   {
      assert(_width > 0, "Must call 'setSize()' before adding images");
      assert(_height > 0, "Must call 'setSize()' before adding images");
      assert(bitmap.width > x + width - 1,
             "Bitmap is not large enough. Bitmap width is "
             ~ to!string(bitmap.width) ~ ", x is " ~ to!string(x)
             ~ ", sprite width is " ~ to!string(width));
      assert(bitmap.height > y + height - 1,
             "Bitmap is not large enough. Bitmap height is "
             ~ to!string(bitmap.height) ~ ", x is " ~ to!string(x)
             ~ ", sprite height is " ~ to!string(height));
   }
   body
   {
      _images ~= Image(bitmap, x, y);
      return _images.length - 1;
   }

   /**
    * Adds an animation to the collection of animations.
    *
    * Parameters:
    *    name = The animation name, which the way to identify it. It is invalid
    *       to try to add an animation with a name that was already used.
    *    frames = The animation frames.
    */
   public final void addAnimation(string name, Frame[] frames...)
   in
   {
      assert(name !in _animations, "Animation '" ~ name ~ "' already exists");

      foreach(frame; frames)
      {
         assert(frame.time >= 0.0, "Frame times cannot be negative");
         assert(frame.image < _images.length,
                "Frame " ~ to!string(frame.image) ~ " is not valid (sprite "
                ~ "has " ~ to!string(_images.length) ~ " images)");
      }
   }
   body
   {
      _animations[name] = frames;
   }

   /// The structure used internally to represent a sprite image.
   private struct Image
   {
      /// The bitmap where the image is located.
      public Bitmap bitmap;

      /// The $(I x) coordinate of the image within $(D bitmap).
      public uint x;

      /// The $(I y) coordinate of the image within $(D bitmap).
      public uint y;
   }

   /// Data describing one frame of a sprite animation.
   public struct Frame
   {
      /// The index of the image displayed in this frame.
      public size_t image;

      /// The duration, in seconds, of this frame.
      public float time;
   }

   /// The collection of images.
   Image[] _images;

   /**
    * The collection of animations.
    *
    * Animations are indexed by a string identifier. Each animation is a list
    * (er, a dynamic array) of animation frames.
    */
   Frame[][string] _animations;

   /**
    * The width, in pixels, of the images used by this $(D Sprite).
    *
    * If it is equals to zero, it is considered uninitialized.
    */
   private uint _width = 0;

   /**
    * The height, in pixels, of the images used by this $(D Sprite).
    *
    * If it is equals to zero, it is considered uninitialized.
    */
   private uint _height = 0;

   /**
    * The horizontal coordinate of the sprite center (reference point), in
    * pixels, measured from the left side of the image, and growing to the
    * right.
    */
   private float _centerX = 0;

   /**
    * The vertical coordinate of the sprite center (reference point), in pixels,
    * measured from the top side of the image, and growing to the bottom.
    */
   private float _centerY = 0;
}


/**
 * An instance of a $(D SpriteTemplate).
 *
 * This is what you ultimately need to display a sprite on the screen. (But you
 * can display images on the screen without using a sprite! You could use a $(D
 * Bitmap), for instance, but a $(D Sprite) provides some neat, higher-level
 * features.)
 *
 * TODO: This should be Colorable, and possibly Rotatable and Scaled.
 */
public class Sprite
{
   /**
    * Constructs the $(D Sprite).
    *
    * Parameters:
    *    spriteTemplate = The template on which this sprite is based.
    */
   public this(SpriteTemplate spriteTemplate)
   {
      _template = spriteTemplate;
   }

   /**
    * Draws the $(D Sprite) in the current target bitmap.
    *
    * Parameters:
    *    x = The $(I x) drawing coordinate, in pixels, measured from the screen
    *       left side.
    *    y = The $(I y) drawing coordinate, in pixels, measured from the screen
    *       upper side.
    */
   public final void draw(float x, float y)
   {
      auto image = _template._images[_currentImage];
      al_draw_bitmap_region(
         image.bitmap,
         image.x, image.y, _template.width, _template.height, // image rectangle
         x - _template.centerX, y - _template.centerY, // drawing position
         0); // flags
   }

   /*
    * The index of the current sprite image.
    *
    * This current image is the one that gets drawn when $(D draw()) is called.
    */
   public final @property size_t currentImage() const
   {
      return _currentImage;
   }

   /// Ditto.
   public final @property void currentImage(size_t index)
   {
      _currentImage = index;
   }

   /// The template this $(D Sprite) is based on.
   private SpriteTemplate _template;

   /// The index (into $(D _images)) of the current image.
   private size_t _currentImage;
}


/**
 * Adds to a given updater an updater function that will execute a sprite
 * animation.
 *
 * Parameters:
 *    updater = The $(D Updater) that will do the work.
 *    sprite = The sprite to be animated.
 *    animationName = The name of the animation to play.
 *    speed = The relative speed of the animation. Use $(D 0.6) to play at half
 *       of the nominal speed, $(D 2.0) to play twice as fast as the nominal
 *       speed, and so on.
 *    loop = Wanna play the animation in loop? If not (the default), the updater
 *       function will stop as soon as the animation finishes. If you do, the
 *       animation will stop only if you remove the updater function manually
 *       from $(D updater)).
 */
public UpdaterFuncID addAnimation(
   Updater updater, Sprite sprite, string animationName,
   double speed = 1.0, bool loop = false)
in
{
   assert(animationName in sprite._template._animations,
          "Unknown animation '" ~ animationName ~ "'");
}
body
{
   auto frames = sprite._template._animations[animationName];
   auto currentFrame = 0;
   sprite.currentImage = frames[0].image;
   auto timeForNextImage = frames[0].time;

   return updater.add(
      delegate(dt)
      {
         timeForNextImage -= dt * speed;
         if (timeForNextImage <= 0.0)
         {
            if (currentFrame < frames.length - 1)
            {
               // Advance to the next frame
               const alreadyElapsed = -timeForNextImage;
               sprite.currentImage = frames[++currentFrame].image;
               timeForNextImage = frames[currentFrame].time - alreadyElapsed;
               return true;
            }
            else
            {
               if (loop)
               {
                  // Reached the last frame, but we are looping. Rewind.
                  currentFrame = 0;
                  const alreadyElapsed = -timeForNextImage;
                  sprite.currentImage = frames[currentFrame].image;
                  timeForNextImage = frames[currentFrame].time - alreadyElapsed;
                  return true;
               }
               else
               {
                  // Reached the last frame and is not looping. We are done!
                  return false;
               }
            }
         }
         return true;
      });
}
