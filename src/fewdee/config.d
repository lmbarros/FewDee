/**
 * Configuration files/strings, which work even at compile-time and use a
 * Lua-like syntax.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.config;


import fewdee.internal.config_lexer;



// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

enum input = "
{
   type = foo,
   params = { 'a', 'b', 'c' },
   extra = {
      one = 1,
      two = 2,
      three = 3,
   }
}
";

public struct LuaLikeValue
{
   public this(string data)
   {
      _data = data;
   }

   int len() { return _data.length; }

   string _data;
}


int fun()
{
   auto v = LuaLikeValue(input);
   return v.len();
}

string gun()
{
   Token token;
   nextToken("'foo'", token);
   return token.rawData;
}


void main()
{
   enum i = fun();
   enum j = gun();
   writefln("%s", i);
   writefln("%s", j);
}
