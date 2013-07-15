/**
 * Compile-time generation of integer IDs from strings.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.strid;


/**
 * Internal helper that converts a character to an integer that fits in 5 bits.
 *
 * Since a "regular character" uses 8 bits, the allowed input range for this
 * function must be limited. Only the following characters are supported by this
 * function:
 * $(OL
 *    $(LI Letters from "a" to "z". Both upper and lower case letters are
 *       accepted, but the function is case insensitive.)
 *    $(LI Numbers from 0 to 3. Accepting more numbers would be nice, but we got
 *       out of bits.)
 *    $(LI Spaces.)
 *    $(LI Hyphens ("-")).
 * )
 */
private pure uint to5BitInt(char c)()
out(result)
{
   import std.conv;
   assert(result < 2 ^^ 5, "Result doesn't fit in 5 bits");
}
body
{
   import std.ascii;

   enum charVal = toLower(c) - 'a';

   static assert(
      c == ' ' || c == '-' || c == '0' || c == '1' || c == '2' || c == '3'
      || charVal <= 'z' - 'a', "Character '" ~ c ~ "' is not valid. Please use "
      "only letters, hyphens, spaces and numbers from 0 to 3.");

   static if (c == ' ')
      return 0;
   else if (c == '-')
      return 1;
   else if (c == '0')
      return 2;
   else if (c == '1')
      return 3;
   else if (c == '2')
      return 4;
   else if (c == '3')
      return 5;
   else if (charVal <= 'z' - 'a')
      return charVal + 6;
}


/**
 * Converts a string value into a non-negative integer value that fits into an
 * $(D int).
 *
 * The string must be between 1 and 6 characters long. Strings shorter than six
 * characters are actually padded with spaces to the left, so "abcde" and
 * "[space]abcde" will be converted to the same number.
 *
 * Only a limited set of characters is accepted: letters from "a" to "z",
 * numbers from "0" to "3", spaces (" ") and hyphens ("-").
 */
public template strID(string s)
if (s.length == 6)
{
   enum strID = to5BitInt!(s[0]) << 5 * 5
      | to5BitInt!(s[1]) << 4 * 5
      | to5BitInt!(s[2]) << 3 * 5
      | to5BitInt!(s[3]) << 2 * 5
      | to5BitInt!(s[4]) << 1 * 5
      | to5BitInt!(s[5]) << 0 * 5;
}

public template strID(string s)
if (s.length == 5)
{
   enum strID = strID!(" " ~ s);
}

public template strID(string s)
if (s.length == 4)
{
   enum strID = strID!("  " ~ s);
}

public template strID(string s)
if (s.length == 3)
{
   enum strID = strID!("   " ~ s);
}

public template strID(string s)
if (s.length == 2)
{
   enum strID = strID!("    " ~ s);
}

public template strID(string s)
if (s.length == 1)
{
   enum strID = strID!("     " ~ s);
}


unittest
{
   assert(strID!"a" == strID!"     a");
   assert(strID!"1-2" == strID!"   1-2");
   assert(strID!"xyz" == strID!"XYZ");
   assert(strID!"xyz" == strID!"   XYZ");

   assert(strID!"      " >= 0);
   assert(strID!"      " <= int.max);
   assert(strID!"------" >= 0);
   assert(strID!"------" <= int.max);
   assert(strID!"aaaaaa" >= 0);
   assert(strID!"aaaaaa" <= int.max);
   assert(strID!"zzzzzz" >= 0);
   assert(strID!"zzzzzz" <= int.max);
   assert(strID!"000000" >= 0);
   assert(strID!"000000" <= int.max);
   assert(strID!"111111" >= 0);
   assert(strID!"111111" <= int.max);
   assert(strID!"222222" >= 0);
   assert(strID!"222222" <= int.max);
   assert(strID!"333333" >= 0);
   assert(strID!"333333" <= int.max);
   assert(strID!"a" >= 0);
   assert(strID!"a" <= int.max);
   assert(strID!"z" >= 0);
   assert(strID!"z" <= int.max);
   assert(strID!"-" >= 0);
   assert(strID!"-" <= int.max);
   assert(strID!" " >= 0);
   assert(strID!" " <= int.max);
   assert(strID!"0" >= 0);
   assert(strID!"0" <= int.max);
   assert(strID!"1" >= 0);
   assert(strID!"1" <= int.max);
   assert(strID!"2" >= 0);
   assert(strID!"2" <= int.max);
   assert(strID!"3" >= 0);
   assert(strID!"3" <= int.max);
}
