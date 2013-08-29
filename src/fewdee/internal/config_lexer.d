/**
 * A lexer (tokenizer) for configuration files/strings; works even at
 * compile-time and expects a Lua-like input syntax.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.internal.config_lexer;

import std.array;
import std.ascii;
import std.format;
import std.string;


/// The possible token types.
package enum TokenType
{
   INVALID,       /// The token is uninitialized.
   STRING,        /// A string.
   NUMBER,        /// A number (all numbers are floating point).
   BOOLEAN,       /// A Boolean value.
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

   /// Is this token a string?
   final @property bool isString() inout
   {
      return type == TokenType.STRING;
   }

   /// Is this token a number?
   final @property bool isNumber() inout
   {
      return type == TokenType.NUMBER;
   }

   /// Is this token a Boolean?
   final @property bool isBoolean() inout
   {
      return type == TokenType.BOOLEAN;
   }

   /// Is this token an identifier?
   final @property bool isIdentifier() inout
   {
      return type == TokenType.IDENTIFIER;
   }

   /// Is this token a "nil"?
   final @property bool isNil() inout
   {
      return type == TokenType.NIL;
   }

   /// Is this token a comma?
   final @property bool isComma() inout
   {
      return type == TokenType.COMMA;
   }

   /// Is this token an equals sign?
   final @property bool isEquals() inout
   {
      return type == TokenType.EQUALS;
   }

   /// Is this token an opening brace?
   final @property bool isOpeningBrace() inout
   {
      return type == TokenType.OPENING_BRACE;
   }

   /// Is this token a closing brace?
   final @property bool isClosingBrace() inout
   {
      return type == TokenType.CLOSING_BRACE;
   }

   /// Is this token an "EOF"?
   final @property bool isEOF() inout
   {
      return type == TokenType.EOF;
   }

   /// Is this token an "error token"?
   final @property bool isError() inout
   {
      return type == TokenType.ERROR;
   }

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
    * Returns the token value as a Boolean.
    *
    * $(D assert())s if $(D type) is not the expected one.
    */
   final @property bool asBoolean()
   in
   {
      assert(type == TokenType.BOOLEAN);
      assert(rawData == "true" || rawData == "false");
   }
   body
   {
      return rawData == "true";
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
      return rawData[1..$-1]     // removes quotes
         .replace("\\\\", "\\")  // backslashes
         .replace("\\n", "\n")   // newlines
         .replace("\\\'", "\'")  // single quotes
         .replace("\\\"", "\""); // double quotes
   }

   /**
    * Returns the token value as an identifier.
    *
    * This is the same thing as accessing the $(D rawData) member.
    *
    * $(D assert())s if $(D type) is not the expected one.
    */
   final @property string asIdentifier()
   in
   {
      assert(type == TokenType.IDENTIFIER);
   }
   body
   {
      return rawData;
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
public string nextToken(string data, out Token token)
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

      if (token.isError)
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
    * Reads an identifier, a "nil" or a Boolean value from $(D data), stores the
    * read data in ($D token).
    *
    * Returns: $(D true) if the data was successfully read. $(D false)
    *    otherwise, in which case, $(D token) will be an "error token".
    */
   bool readIdentifierOrNilOrBooean()
   in
   {
      assert(data.length > 0);
      assert(isAlphaNum(data[0]) || data[0] == '_');
   }
   body
   {
      /// Is the next token a given keyword?
      bool isKeyword(string which)
      {
         const len = which.length;

         return (data.length == len
                 && data[0..len] == which)
            || (data.length > len
                && data[0..len] == which
                && !isAlphaNum(data[len])
                && data[len] != '_');
      }

      auto originalData = data;
      size_t size = 0;

      // Check for "nil"
      if (isKeyword("nil"))
      {
         token.type = TokenType.NIL;
         token.rawData = originalData[0..3];
         data = data[3..$];
         return true;
      }

      // Check for "true"
      if (isKeyword("true"))
      {
         token.type = TokenType.BOOLEAN;
         token.rawData = originalData[0..4];
         data = data[4..$];
         return true;
      }

      // Check for "false"
      if (isKeyword("false"))
      {
         token.type = TokenType.BOOLEAN;
         token.rawData = originalData[0..5];
         data = data[5..$];
         return true;
      }

      // Not a reserved word; must be an identifier
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
         success = readIdentifierOrNilOrBooean();
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
   assert(success || token.isError);
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
   assert(simpleTest("true", TokenType.BOOLEAN));
   assert(simpleTest("false", TokenType.BOOLEAN));
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

   string gun()
   {
      Token token;
      auto data = "{8.11, foo=2.3,} -- blah";
      data = nextToken(data, token);
      data = nextToken(data, token);
      data = nextToken(data, token);
      data = nextToken(data, token);
      return token.asIdentifier;
   }

   enum value = fun();
   assert(value == -1.5893e+7);

   enum ident = gun();
   assert(ident == "foo");
}


// Some more demanding tests with strings.
unittest
{
   bool testString(string data, string expectedRemaining, string expectedString)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining
         && token.isString
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
   assert(testString(`   "blah"--`, "--", "blah"));
}


// Some tests with strings in which lexing shall fail.
unittest
{
   bool testStringFail(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return token.isError;
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
         && token.isNumber
         && token.asNumber == expectedNumber;
   }

   assert(testNumber("11.11, nil", ", nil", 11.11));
   assert(testNumber("+45E2, nilll", ", nilll", 45e2));
   assert(testNumber("-85e-3,a{}", ",a{}", -85e-3));
   assert(testNumber("-.1234e-9=", "=", -.1234e-9));
   assert(testNumber(".0", "", 0.0));
   assert(testNumber("-1--", "--", -1.0));
   assert(testNumber("  \t 3.14===", "===", 3.14));
}


// Some tests with numbers in which lexing shall fail.
unittest
{
   bool testNumberFail(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return token.isError;
   }

   assert(testNumberFail("..1"));
   assert(testNumberFail(".0."));
   assert(testNumberFail("123yyy"));
   assert(testNumberFail("1.5.7"));
   assert(testNumberFail("1.2ee3"));
   assert(testNumberFail("4.5E-2E1"));
}

// More tests with Booleans.
unittest
{
   bool testBoolean(string data, string expectedRemaining,
                    TokenType expectedTokenType = TokenType.BOOLEAN)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining && token.type == expectedTokenType;
   }

   assert(testBoolean("true,false", ",false"));
   assert(testBoolean("false,true", ",true"));
   assert(testBoolean("truee", "", TokenType.IDENTIFIER));
   assert(testBoolean("falsee", "", TokenType.IDENTIFIER));
   assert(testBoolean("true_", "", TokenType.IDENTIFIER));
   assert(testBoolean("_false", "", TokenType.IDENTIFIER));
   assert(testBoolean("'true'", "", TokenType.STRING));
   assert(testBoolean(`"false"`, "", TokenType.STRING));
   assert(testBoolean("--false", "", TokenType.EOF));
}


// Tests with nil.
unittest
{
   bool testNil(string data, string expectedRemaining,
                TokenType expectedTokenType = TokenType.NIL)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining && token.type == expectedTokenType;
   }

   assert(testNil("nil, 1.2", ", 1.2"));
   assert(testNil("   nil{}", "{}"));
   assert(testNil("nill", "", TokenType.IDENTIFIER));
   assert(testNil("funil", "", TokenType.IDENTIFIER));
}


// More demanding tests with identifiers.
unittest
{
   bool testIdent(string data, string expectedRemaining, string expectedIdent)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == expectedRemaining
         && token.isIdentifier
         && token.asIdentifier == expectedIdent;
   }

   assert(testIdent(" foo,bar", ",bar", "foo"));
   assert(testIdent("\t\ni", "", "i"));
   assert(testIdent("_____foo{{{}}}", "{{{}}}", "_____foo"));
   assert(testIdent("__foo_-", "-", "__foo_"));
   assert(testIdent("    _ ", " ", "_"));
   assert(testIdent("foo23, 123", ", 123", "foo23"));
}


// Some tests with things that are not identifiers but could conceivably be
// confused with them.
unittest
{
   bool testNotIdentifier(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return token.type != TokenType.IDENTIFIER || rem != "";
   }

   assert(testNotIdentifier("123baz"));  // cannot start with a digit
   assert(testNotIdentifier("fuu-bar")); // this isn't a single identifier
   assert(testNotIdentifier("foo,bar")); // this isn't a single identifier
   assert(testNotIdentifier("foo{bar")); // this isn't a single identifier
}


// Check if EOF is properly returned
unittest
{
   bool testEOF(string data)
   {
      Token token;
      auto rem = nextToken(data, token);
      return rem == "" && token.isEOF;
   }

   assert(testEOF(""));
   assert(testEOF("--"));
   assert(testEOF("   -- foo bar

                    --
                    --
                    --+__!!"));
}


// Tests if sequences of tokens are properly lexed.
unittest
{
   /**
    * Tests if $(D data) yields a given sequence of token types; there is no
    * need to pass and EOF in $(D expectedTokens), it is implicit.
    */
   bool testSequence(string data, TokenType[] expectedTokens)
   in
   {
      assert(expectedTokens.length > 0);
   }
   body
   {
      while(true)
      {
         Token token;
         data = nextToken(data, token);

         if (token.isEOF)
         {
            if (data != "" || expectedTokens.length != 0)
               return false;
            else
               return true;
         }

         if (token.type != expectedTokens[0])
            return false;

         expectedTokens = expectedTokens[1..$];
      }
   }

   with(TokenType)
   {
      assert(testSequence("{}", [OPENING_BRACE, CLOSING_BRACE]));

      assert(testSequence("foo bar 3.2e-8 }--}",
                          [ IDENTIFIER, IDENTIFIER, NUMBER, CLOSING_BRACE ]));

      assert(testSequence("foo = { false, 1.2, 9.4, 'bla' } -- some comment",
                          [ IDENTIFIER, EQUALS, OPENING_BRACE, BOOLEAN, COMMA,
                            NUMBER, COMMA, NUMBER, COMMA, STRING,
                            CLOSING_BRACE ]));

      assert(testSequence("foo = { -- a comment
                                   --- some more
                                   good =true,
                                   id = 'blah',
                                   foo = nil,\t
                                   baz = {}
                                 }      ",
                          [ IDENTIFIER, EQUALS, OPENING_BRACE,
                            IDENTIFIER, EQUALS, BOOLEAN, COMMA,
                            IDENTIFIER, EQUALS, STRING, COMMA,
                            IDENTIFIER, EQUALS, NIL, COMMA,
                            IDENTIFIER, EQUALS, OPENING_BRACE, CLOSING_BRACE,
                            CLOSING_BRACE ]));
   }
}
