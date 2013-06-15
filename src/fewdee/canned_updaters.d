/**
 * A set of handy, ready-to-use updaters.
 *
 * These updaters are naïve in a certain sense. They simply do their job without
 * knowing anything about the rest of the world. If you add, say, two different
 * position updaters acting upon the same object, they will "fight" with each
 * other and the object will probably jump between unrelated positions.
 *
 * On the other hand, using them requires very little effort, and therefore they
 * are an excellent way to make your graphics and interfaces more "lively".
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.canned_updaters;

import allegro5.allegro;
import fewdee.colorable;
import fewdee.interpolators;
import fewdee.positionable;
import fewdee.rotatable;
import fewdee.scalable;
import fewdee.updater;


/**
 * Adds to a given $(D Updater) an updater function that will change the
 * position of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose position will be updated.
 *    destX = The x coordinate of the destination position.
 *    destY = The y coordinate of the destination position.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target position.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 */
public void addPositionUpdater(Updater updater, Positionable target,
                               float destX, float destY, double duration,
                               GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto xInterpolator = maker(target.x, destX, duration);
   auto yInterpolator = maker(target.y, destY, duration);

   updater.add(
      delegate(dt)
      {
         t += dt;
         target.x = xInterpolator(t);
         target.y = yInterpolator(t);
         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the alpha
 * (opacity) of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of Updater.
 *
 * Notice that this works just like a color interpolator -- except that it
 * touches only the alpha channel. A color interpolator and an alpha
 * interpolator would "fight" with each other if active at the same time on the
 * same target.
 *
 * TODO: So, it would probably make sense to implement a $(D addRGBUpdater())
 *    function.
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose alpha will be updated.
 *    destAlpha = The desired target alpha.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target alpha.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 */
public void addAlphaUpdater(Updater updater, Colorable target,
                            float destAlpha, double duration,
                            GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   float ir, ig, ib, ia;
   al_unmap_rgba_f(target.color, &ir, &ig, &ib, &ia);

   auto alphaInterpolator = maker(ia, destAlpha, duration);

   updater.add(
      delegate(dt)
      {
         t += dt;

         float r, g, b, a;
         al_unmap_rgba_f(target.color, &r, &g, &b, &a);

         immutable newColor = al_map_rgba_f(r, g, b, alphaInterpolator(t));

         target.color = newColor;

         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the color
 * of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * A color updater can change the alpha (opacity) of an object, but if you want
 * to use only the alpha channel, using an alpha interpolator is simpler.
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose color will be updated.
 *    destColor = The desired target color.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target color.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 *
 * See_Also: addAlphaUpdater
 */
public void addColorUpdater(Updater updater, Colorable target,
                            in ref ALLEGRO_COLOR destColor, double duration,
                            GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   float ir, ig, ib, ia;
   al_unmap_rgba_f(target.color, &ir, &ig, &ib, &ia);

   float fr, fg, fb, fa;
   al_unmap_rgba_f(destColor, &fr, &fg, &fb, &fa);

   auto rInterpolator = maker(ir, fr, duration);
   auto gInterpolator = maker(ig, fg, duration);
   auto bInterpolator = maker(ib, fb, duration);
   auto aInterpolator = maker(ia, fa, duration);

   updater.add(
      delegate(dt)
      {
         t += dt;
         immutable newColor = al_map_rgba_f(rInterpolator(t),
                                            gInterpolator(t),
                                            bInterpolator(t),
                                            aInterpolator(t));
         target.color = newColor;

         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the scale
 * of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose scale will be updated.
 *    destScaleX = The desired target scale along the x axis.
 *    destScaleY = The desired target scale along the y axis.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target scale.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 */
public void addScaleUpdater(Updater updater, Scalable target,
                            float destScaleX, float destScaleY, double duration,
                            GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto xScaleInterpolator = maker(target.scaleX, destScaleX, duration);
   auto yScaleInterpolator = maker(target.scaleY, destScaleY, duration);

   updater.add(
      delegate(dt)
      {
         t += dt;
         target.scaleX = xScaleInterpolator(t);
         target.scaleY = yScaleInterpolator(t);
         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater), an updater function that will change the
 * rotation of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose rotation will be updated.
 *    destAlpha = The desired target rotation, in radians.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target scale.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 */
public void addRotationUpdater(Updater updater, Rotatable target,
                               float destRotation, double duration,
                               GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto rotInterpolator = maker(target.rotation, destRotation, duration);

   updater.add(
      delegate(dt)
      {
         t += dt;
         target.rotation = rotInterpolator(t);
         return t < duration;
      });
}
