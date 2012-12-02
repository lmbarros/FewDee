/**
 * A set of handy, ready-to-use updaters.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.canned_updaters;

import fewdee.interpolators;
import fewdee.positionable;
import fewdee.updater;


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// xxxxxxxxxxxx Docs!
public void addPositionUpdater(T)(Updater updater, Positionable target,
                                  float destX, float destY, double duration,
                                  T maker)
   if (__traits(isFloating, maker(0.0, 0.0, 1.0)(0.0)))
{
   double t = 0.0;

   auto xInterpolator = maker(target.x, destX, duration);
   auto yInterpolator = maker(target.y, destY, duration);

   updater.add(delegate(dt)
               {
                  t += dt;
                  target.x = xInterpolator(t);
                  target.y = yInterpolator(t);
                  return t < duration;
               });
}


