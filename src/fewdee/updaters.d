/**
 * A set of handy, ready-to-use updaters.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.updaters;

import fewdee.interpolators;
import fewdee.positionable;
import fewdee.updater;


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// Add one of those neat template conditions
public void addPositionUpdater(T)(Updater updater, Positionable target,
                                  float destX, float destY, double duration,
                                  T maker)
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


