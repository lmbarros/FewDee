/**
 * A lexer (tokenizer) for configuration files/strings; works even at
 * compile-time and expects a Lua-like input syntax.
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


/// The possible token types.
package enum TokenType
{
   INVALID,       /// The token is uninitialized.
   STRING,        /// A string.
   NUMBER,        /// A number (all numbers are floating point).
   NIL,           /// Nil, which represents a non-value or something like this.
   IDENTIFIER,    /// An identifier (think of the keys used to index tables).
   COMMA,         /// A comma (",").
   EQUALS,        /// An equals sign ("=").
   OPENING_BRACE, /// An opening curly brace ("{").
   CLOSING_BRACE, /// A closing curly brace ("}").
   EOF,           /// Used to indicate an end-of-input.
   ERROR,         /// Used to indicate that an error occurred.
}


/// A token.
package struct Token
{
   /// The type of token, that is, what kind of information it contains.
   TokenType type;

   /**
    * Normally, this is a slice of the input string containing only the part
    * relevant for this token. However, if $(D type == TokenType.ERROR), this
    * will contain an error message.
    */
   string rawData;

   /**
    * Returns the token value as a number.
    *
    * $(D assert())s if $(D type) is not the expected one.
    */
   final @property double asNumber()
   in
   {
      assert(type == TokenType.NUMBER);
   }
   body
   {
      auto dataCopy = rawData;
      double value;
      const numMatches = formattedRead(dataCopy, "%s", &value);
      assert(numMatches == 1);
      return value;
   }

   /**
    * Returns the token value as a string.
    *
    * This is not the same thing as accessing the $(D rawData) member because
    * this method removes the quotes and handles escaped characters.
    *
    * $(D assert())s if $(D type) is not the expected one.
    */
   final @property string asString()
   in
   {
      assert(type == TokenType.STRING);
   }
   body
   {
      auto data = rawData[1..$-1]; // removes quotes
      string result;

      while (data.length > 0)
      {
         result ~= munch(data, "^\\");
         if (data.length > 0)
            data = data[1..$]; // skip backslash
      }

      return result;
   }
}


/**
 * Reads and returns the next token from the input string.
 *
 * Parameters:
 *    data = The string from where the token will be read.
 *    token = The token will be returned here.
 *
 * Returns:
 *    The remaining of $(D data), after the token has been removed from it.
 */
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
         data = data[1..$];
         ++size;

         if (data.length == 0)
         {
            token.type = TokenType.ERROR;
            token.rawData = "String not closed: " ~ originalData;
            return false;
         }

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
               data = data[1..$];
               ++size;
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

      void setError()
      {
         token.type = TokenType.ERROR;
         token.rawData = "Error reading number: " ~ originalData[0..size];
      }

      bool gotPoint = false;
      bool gotE = false;
      bool gotSignal = false;

      // Read while the input looks like something that could be a number; we'll
      // get things that are not numbers, too, but we'll take care of these
      // shortly.
      while (true)
      {
         if (data.length == 0)
            break;

         if (isDigit(data[0]) || data[0] == 'e'  || data[0] == 'E'
             || data[0] == '+' || data[0] == '-' || data[0] == '.')
         {
            if (data.length >= 2 && data[0..2] == "--")
               break;

            if (data[0] == '.')
            {
               if (gotPoint)
               {
                  setError();
                  break;
               }
               else
               {
                  gotPoint = true;
               }
            }

            if (data[0] == '+' || data[0] == '-')
            {
               if (gotSignal)
               {
                  setError();
                  break;
               }
               else
               {
                  gotSignal = true;
               }
            }

            if (data[0] == 'e' || data[0] == 'E')
            {
               if (gotE)
               {
                  setError();
                  break;
               }
               else
               {
                  gotE = true;
                  gotPoint = false;
                  gotSignal = false;
               }
            }

            data = data[1..$];
            ++size;
         }
         else
         {
            if (!isWhite(data[0]) && data[0] != ',' && data[0] != '='
                && data[0] != '{' && data[0] != '}')
            {
               token.type = TokenType.ERROR;
               token.rawData = "Malformed number starting from here: "
                  ~ originalData[0..$];
            }

            break;
         }
      }

      if (token.type == TokenType.ERROR)
      {
         return false;
      }
      else
      {
         token.type = TokenType.NUMBER;
         token.rawData = originalData[0..size];
         return true;
      }
   }

   /**
    * Reads an identifier or a "nil" from $(D data), stores the read data in ($D
    * token).
    *
    * Returns: $(D true) if the data was successfully read. $(D false)
    *    otherwise, in which case, $(D token) will be an "error token".
    */
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

   /**
    * Reads a "special character" (comma, equals, braces...) from $(D data),
    * stores the read data in ($D token).
    *
    * Returns: $(D true) if the data was successfully read. $(D false)
    *    otherwise, in which case, $(D token) will be an "error token".
    */
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

   // First, skip blanks
   skipBlanks();
   if (data.length == 0)
      return data;

   // Peek at the first character, and use it to infer what type of token is
   // coming.
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

   // And we are done. Do a sanity check and return.
   assert(success || token.type == TokenType.ERROR);

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   if (!__ctfe)
      writefln("READ: type = %s, rawData = |%s|", token.type, token.rawData);

   return data;
}


// Basic test, just to ensure that the lexer is doing the right thing for some
// very simple cases.
unittest
{
   bool simpleTest(string inputData, TokenType expectedTokenType)
   {
      Token token;
      auto rem = nextToken(inputData, token);
      return rem == "" && token.type == expectedTokenType;
   }

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
   assert(simpleTest("", TokenType.EOF));
}


// Ensure this works at compile-time.
unittest
{
   double fun()
   {
      Token token;
      auto rem = nextToken("-1.5893e+7", token);
      return token.asNumber;
   }
   enum value = fun();
   assert(value == -1.5893e+7);
}


// Some more demanding tests with strings.
unittest
{
   bool testString(string data, string expectedRemaining, string expectedString)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining
         && token.type == TokenType.STRING
         && token.asString == expectedString;
   }

   assert(testString(`"", 123`, ", 123", ""));
   assert(testString(`"foobar" = {}`, " = {}", "foobar"));
   assert(testString(`"fú"`, "", "fú"));
   assert(testString(`'foo\"bar'`, "", `foo"bar`));
   assert(testString(`'foo\'bar'xxx`, "xxx", `foo'bar`));
   assert(testString(`"foo\"bar"`, "", `foo"bar`));
   assert(testString(`"some \"quote\"" --`, " --", `some "quote"`));
   assert(testString(`'some \'quote\''`, "", `some 'quote'`));
}


// Some tests with strings in which lexing shall fail.
unittest
{
   bool testStringFail(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return token.type == TokenType.ERROR;
   }

   assert(testStringFail("'"));
   assert(testStringFail("\""));
   assert(testStringFail("\"This is not closed"));
   assert(testStringFail("\'Neither is this"));
   assert(testStringFail("\"backslash at the end\\"));
   assert(testStringFail("'backslash at the end\\"));
}


// More demanding tests with numbers.
unittest
{
   bool testNumber(string data, string expectedRemaining, double expectedNumber)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining
         && token.type == TokenType.NUMBER
         && token.asNumber == expectedNumber;
   }

   assert(testNumber("11.11, nil", ", nil", 11.11));
   assert(testNumber("+45E2, nilll", ", nilll", 45e2));
   assert(testNumber("-85e-3,a{}", ",a{}", -85e-3));
   assert(testNumber("-.1234e-9=", "=", -.1234e-9));
   assert(testNumber(".0", "", 0.0));
   assert(testNumber("-1--", "--", -1.0));
}


// Some tests with numbers in which lexing shall fail.
unittest
{
   bool testNumberFail(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return token.type == TokenType.ERROR;
   }

   assert(testNumberFail("..1"));
   assert(testNumberFail(".0."));
   assert(testNumberFail("123yyy"));
   assert(testNumberFail("1.5.7"));
   assert(testNumberFail("1.2ee3"));
   assert(testNumberFail("4.5E-2E1"));
}


// nil

// identifier

// identifier failing

// eof (including comments)

// sequences of tokens


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
