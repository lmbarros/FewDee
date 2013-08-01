/**
 * Configuration files/strings, which work even at compile-time and use a
 * Lua-like syntax.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.config;

import std.ascii;
import std.format;
import std.string;
// import std.exception;
// import std.string;
// import allegro5.allegro_font;
// import fewdee.allegro_manager;
// import fewdee.engine;
// import fewdee.low_level_resource;

import std.stdio; // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

//
// The Lexer
//


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
private enum TokenType
{
   STRING,
   NUMBER,
   NIL,
   IDENTIFIER,
   COMMA,
   EQUALS,
   OPENING_BRACE,
   CLOSING_BRACE,
   EOF,
   ERROR,
}

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
private struct Token
{
   TokenType type;
   string rawData; // error message if type == ERROR
}


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
private string nextToken(string data, out Token token)
{
   /**
    * Skips blanks (including comments) in $(D data). If nothing remains in $(D
    * data) (that is, it becomes an empty string), sets $(D token.type) to $(D
    * TokenType.EOF).
    */
   void skipBlanks()
   {
      munch(data, " \t\n\r");
      if (data.length == 0)
         token.type = TokenType.EOF;

      // Skip comments
      if (data.length >= 2 && data[0..2] == "--")
      {
         munch(data, "^\n"); // skip to the end of line...
         skipBlanks();       // ...and skip eventual blanks in the new line
      }
   }

   /**
    * Reads a string from $(D data), stores the read data in ($D token).
    *
    * Returns: $(D true) if the data was successfully read. $(D false)
    *    otherwise, in which case, $(D token) will be an "error token".
    */
   bool readString()
   in
   {
      assert(data.length > 0);
   }
   body
   {
      auto originalData = data;
      size_t size = 0;
      auto delimiter = data[0];

      while (true)
      {
         if (data.length == 0)
         {
            token.type = TokenType.ERROR;
            token.rawData = "String not closed: " ~ originalData;
            return false;
         }

         data = data[1..$];
         ++size;

         if (data[0] == delimiter)
         {
            data = data[1..$];
            ++size;
            token.type = TokenType.STRING;
            token.rawData = originalData[0..size];
            return true;
         }

         if (data[0] == '\\')
         {
            if (data.length == 1)
            {
               token.type = TokenType.ERROR;
               token.rawData = "String not closed: " ~ originalData;
               return false;
            }
            else
            {
               data = data[2..$];
               size += 2;
            }
         }
      }
   }

   /**
    * Reads a number from $(D data), stores the read data in ($D token).
    *
    * Returns: $(D true) if the data was successfully read. $(D false)
    *    otherwise, in which case, $(D token) will be an "error token".
    */
   bool readNumber()
   in
   {
      assert(data.length > 0);
   }
   body
   {
      auto originalData = data;
      size_t size = 0;

      // Read while the input looks like something that could be a number. We
      // include all alphabetic characters, so that we get things like "1.0e2"
      // and "0xdeadbeef"; we'll get things that are not numbers, too, but we'll
      // take care of these shortly.
      while (true)
      {
         if (data.length == 0)
            break;

         if (isAlphaNum(data[0])
             || data[0] == '+' || data[0] == '-' || data[0] == '.')
         {
            data = data[1..$];
            ++size;
         }
         else
         {
            // No way this a number anymore, get out
            break;
         }
      }

      // Now, take the characters read so far and check if they are indeed a
      // number.
      string dataCopy = originalData[0..size];
      double d;
      const numMatches = formattedRead(dataCopy, "%s", &d);

      if (numMatches == 1)
      {
         token.type = TokenType.NUMBER;
         token.rawData = originalData[0..size];
         return true;
      }
      else
      {
         token.type = TokenType.ERROR;
         token.rawData = "Error reading number: " ~ originalData[0..size];
         return false;
      }
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   bool readIdentifierOrNil()
   in
   {
      assert(data.length > 0);
      assert(isAlphaNum(data[0]) || data[0] == '_');
   }
   body
   {
      auto originalData = data;
      size_t size = 0;

      // Check for nil
      if ((data.length == 3 && data[0..3] == "nil")
         || (data.length > 3 && data[0..3] == "nil" && !isAlphaNum(data[3])
             && data[3] != '_'))
      {
         token.type = TokenType.NIL;
         token.rawData = originalData[0..3];

         data = data[3..$];
         return true;
      }

      // Not nil, assume it is an identifier
      while (true)
      {
         if (data.length == 0)
            break;

         if (isAlphaNum(data[0]) || data[0] == '_')
         {
            data = data[1..$];
            ++size;
         }
         else
         {
            // No way this an identifier anymore, get out
            break;
         }
      }

      token.type = TokenType.IDENTIFIER;
      token.rawData = originalData[0..size];
      return true;
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   bool readSpecialCharacter()
   in
   {
      assert(data.length > 0);
   }
   body
   {
      switch (data[0])
      {
         case ',':
            token.type = TokenType.COMMA;
            break;

         case '=':
            token.type = TokenType.EQUALS;
            break;

         case '{':
            token.type = TokenType.OPENING_BRACE;
            break;

         case '}':
            token.type = TokenType.CLOSING_BRACE;
            break;

         default:
            assert(false); // Can't happen
      }

      token.rawData = data[0..1];
      data = data[1..$];
      return true;
   }

   skipBlanks();
   if (data.length == 0)
      return data;

   bool success;
   switch(data[0])
   {
      case '\'': case '"':
         success = readString();
         break;

      case '0': .. case '9': case '+': case '-': case '.':
         success = readNumber();
         break;

      case 'a': .. case 'z': case 'A': .. case 'Z': case '_':
         success = readIdentifierOrNil();
         break;

      case ',': case '=': case '{': case '}':
         success = readSpecialCharacter();
         break;

      default:
         success = false;
         token.type = TokenType.ERROR;
         token.rawData = "Unrecognized data from here: " ~ data;
         break;
   }

   assert(success || token.type == TokenType.ERROR);

   if (!__ctfe)
      writefln("READ: type = %s, rawData = |%s|", token.type, token.rawData);

   return data;
}


version(unittest)
{
   bool simpleTest(string inputData, TokenType expectedTokenType)
   {
      Token token;
      auto rest = nextToken(inputData, token);
      return rest == "" && token.type == expectedTokenType;
   }
}

// Basic test, just to ensure that the lexer is doing the right thing for the
// simpler cases.
unittest
{
   assert(simpleTest("'foo'", TokenType.STRING));
   assert(simpleTest(`"foo"`, TokenType.STRING));
   assert(simpleTest("123", TokenType.NUMBER));
   assert(simpleTest("+582", TokenType.NUMBER));
   assert(simpleTest("-974", TokenType.NUMBER));
   assert(simpleTest("+1.234", TokenType.NUMBER));
   assert(simpleTest("-1.234", TokenType.NUMBER));
   assert(simpleTest(".123", TokenType.NUMBER));
   assert(simpleTest("0", TokenType.NUMBER));
   assert(simpleTest("0.0", TokenType.NUMBER));
   assert(simpleTest("1e6", TokenType.NUMBER));
   assert(simpleTest("1e-6", TokenType.NUMBER));
   assert(simpleTest("-1e+3", TokenType.NUMBER));
   assert(simpleTest("-1.01E-6", TokenType.NUMBER));
   assert(simpleTest("nil", TokenType.NIL));
   assert(simpleTest("foo", TokenType.IDENTIFIER));
   assert(simpleTest(",", TokenType.COMMA));
   assert(simpleTest("=", TokenType.EQUALS));
   assert(simpleTest("{", TokenType.OPENING_BRACE));
   assert(simpleTest("}", TokenType.CLOSING_BRACE));
   assert(simpleTest("", TokenType.EOF));
   assert(simpleTest(" \t \n ", TokenType.EOF));
   assert(simpleTest("--", TokenType.EOF));
}


// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// maybe check rawData for these...
unittest
{
   assert(simpleTest(`"fú"`, TokenType.STRING));
   assert(simpleTest(`'foo\"bar'`, TokenType.STRING));
   assert(simpleTest(`'foo\'bar'`, TokenType.STRING));
   assert(simpleTest(`"foo\"bar"`, TokenType.STRING));
   assert(simpleTest(`""`, TokenType.STRING));
}

unittest
{
   assert(simpleTest("--12345", TokenType.EOF)); // comment
}

unittest
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // string: "something \"quoted\" here"
   // string: 'something \'quoted\' here'

   // string: "aaaaaa\"  // escape at the end of the string
}





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
