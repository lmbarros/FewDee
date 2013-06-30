/**
 * @file
 * An abstract interface representing a low-level resource.
 *
 * @author Leandro Motta Barros
 */

module fewdee.low_level_resource;

/**
 * An abstract interface representing a low-level resource. Low-level resources
 * are thin wrappers around Allegro objects.
 */
public interface LowLevelResource
{
   /// De-allocates the resource.
   abstract void free();
}