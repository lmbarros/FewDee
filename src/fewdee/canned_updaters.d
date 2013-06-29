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
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 */
public
UpdaterFuncID addPositionUpdater(Updater updater, Positionable target,
                                 float destX, float destY, double duration,
                                 GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto xInterpolator = maker(target.x, destX, duration);
   auto yInterpolator = maker(target.y, destY, duration);

   return updater.add(
      delegate(dt)
      {
         t += dt;
         target.x = xInterpolator(t);
         target.y = yInterpolator(t);
         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the opacity
 * of a given object, without changing the "base color".
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of Updater.
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose alpha will be updated.
 *    destOpacity = The desired target opacity.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target alpha.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 *
 * See_also: addBaseColorUpdater
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 */
public UpdaterFuncID addOpacityUpdater(Updater updater, Colorable target,
                                       float destOpacity, double duration,
                                       GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;
   auto opacityInterpolator = maker(target.opacity, destOpacity, duration);

   return updater.add(
      delegate(dt)
      {
         t += dt;
         immutable newOpacity = opacityInterpolator(t);
         target.opacity = newOpacity;
         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the "base
 * color" of a given object, without touching its opacity.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose color will be updated.
 *    destBaseColor = The desired target base color (as its RGB components).
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target base color.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 *
 * See_Also: addOpacityUpdater
 */
public
UpdaterFuncID addBaseColorUpdater(Updater updater, Colorable target,
                                  in float[3] destBaseColor, double duration,
                                  GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   immutable float[3] rgb = target.baseColor;
   auto rInterpolator = maker(rgb[0], destBaseColor[0], duration);
   auto gInterpolator = maker(rgb[1], destBaseColor[1], duration);
   auto bInterpolator = maker(rgb[2], destBaseColor[2], duration);

   return updater.add(
      delegate(dt)
      {
         t += dt;
         immutable float[3] newBaseColor = [ rInterpolator(t),
                                             gInterpolator(t),
                                             bInterpolator(t) ];
         target.baseColor = newBaseColor;

         return t < duration;
      });
}


/**
 * Adds to a given $(D Updater) an updater function that will change the color
 * (the "real" RGBA, premultiplied alpha color) of a given object.
 *
 * D's uniform function call syntax (UFCS) allows to call this as if it was a
 * method of $(D Updater).
 *
 * Parameters:
 *    updater = The $(D Updater) to which the updater function will be added.
 *    target = The object whose color will be updated.
 *    destRGBA = The desired target RGBA color.
 *    duration = The time, in seconds, it will take to go from the current to
 *       the target base color.
 *    maker = A function that will be used to create the necessary
 *       interpolators. You'll typically call $(D
 *       fewdee.interpolators.interpolatorMaker()) here.
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 */
public UpdaterFuncID addRGBAUpdater(Updater updater, Colorable target,
                                    in ALLEGRO_COLOR destRGBA, double duration,
                                    GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;
   float ir, ig, ib, ia;
   al_unmap_rgba_f(target.rgba, &ir, &ig, &ib, &ia);

   float fr, fg, fb, fa;
   al_unmap_rgba_f(destRGBA, &fr, &fg, &fb, &fa);

   auto rInterpolator = maker(ir, fr, duration);
   auto gInterpolator = maker(ig, fg, duration);
   auto bInterpolator = maker(ib, fb, duration);
   auto aInterpolator = maker(ia, fa, duration);

   return updater.add(
      delegate(dt)
      {
         t += dt;
         immutable newColor = al_map_rgba_f(rInterpolator(t),
                                            gInterpolator(t),
                                            bInterpolator(t),
                                            aInterpolator(t));
         target.rgba = newColor;

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
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 */
public UpdaterFuncID
addScaleUpdater(Updater updater, Scalable target,
                float destScaleX, float destScaleY, double duration,
                GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto xScaleInterpolator = maker(target.scaleX, destScaleX, duration);
   auto yScaleInterpolator = maker(target.scaleY, destScaleY, duration);

   return updater.add(
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
 *
 * Returns:
 *    An "updater function ID", that can be passed to the $(D Updater)'s $(D
 *    remove()) method in order to stop the canned updater before it finishes.
 */
public
UpdaterFuncID addRotationUpdater(Updater updater, Rotatable target,
                                 float destRotation, double duration,
                                 GenericInterpolatorMakerDelegate_t maker)
{
   auto t = 0.0;

   auto rotInterpolator = maker(target.rotation, destRotation, duration);

   return updater.add(
      delegate(dt)
      {
         t += dt;
         target.rotation = rotInterpolator(t);
         return t < duration;
      });
}
