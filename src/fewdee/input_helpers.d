/**
 * Helpers used to implement $(D InputState)s and $(D InputTrigger)s.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.input_helpers;

import std.exception;
import fewdee.config;
import fewdee.input_manager;



/**
 * Is this $(D ConfigValue) an associative array and does it have a number field
 * named $(D s)?
 */
package bool hasNumber(const ConfigValue c, string s)
{
   return c.isAA && s in c.asAA && c[s].isNumber;
}


/**
 * Is this $(D ConfigValue) an associative array and does it have a string field
 * named $(D s)?
 */
package bool hasString(const ConfigValue c, string s)
{
   return c.isAA && s in c.asAA && c[s].isString;
}


/**
 * Is this $(D ConfigValue) an associative array and does it have a string field
 * named $(D s)?
 */
package bool hasBoolean(const ConfigValue c, string s)
{
   return c.isBoolean && s in c.asAA && c[s].isBoolean;
}


/**
 * Is this $(D ConfigValue) an associative array and does it have a list field
 * named $(D s)?
 */
package bool hasList(const ConfigValue c, string s)
{
   return c.isAA && s in c.asAA && c[s].isList;
}


/**
 * Is this $(D ConfigValue) an associative array and does it have an associative
 * array field named $(D s)?
 *
 * Notice that, if $(D c[s]) is an empty table, this will return $(D false),
 * because an empty table is considered to be an empty list.
 *
 * See_also: hasPossiblyEmptyAA
 */
package bool hasAA(const ConfigValue c, string s)
{
   return c.isAA && s in c.asAA && c[s].isAA;
}


/**
 * Is this $(D ConfigValue) an associative array and does it have an associative
 * array field named $(D s)?
 */
package bool hasPossiblyEmptyAA(const ConfigValue c, string s)
{
   return c.isAA && s in c.asAA && (c[s].isAA || c[s].isEmptyTable);
}


/**
 * Instantiates and initializes an $(D InputTrigger) based on the data in $(D
 * c).
 */
package InputTrigger makeInputTrigger(const ConfigValue c)
out (result)
{
   assert(result !is null);
}
body
{
   enforce(hasString(c, "class"));
   InputTrigger it = cast(InputTrigger)(Object.factory(c["class"].asString));
   enforce(it !is null);
   it.memento = c;

   return it;
}


/// Instantiates and initializes an $(D InputState) based on the data in $(D c).
package InputState makeInputState(const ConfigValue c)
out (result)
{
   assert(result !is null);
}
body
{
   enforce(hasString(c, "class"));
   InputState s = cast(InputState)(Object.factory(c["class"].asString));
   enforce(s !is null);
   s.memento = c;

   return s;
}
