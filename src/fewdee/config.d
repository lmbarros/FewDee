/**
 * Configuration files/strings, which work even at compile-time and use a
 * Lua-like syntax.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.config;

import fewdee.internal.config_lexer;


/// The possible values a $(D ConfigValue) can have.
public enum ConfigValueType
{
   /// Nil; kind of a non-value.
   NIL,

   /// A number; always floating point.
   NUMBER,

   /// A string.
   STRING,

   /// An associative array of $(D ConfigValue)s, indexed by $(D string)s.
   AA,

   /// A sequential collection of $(D ConfigValue)s.
   LIST,
}


/**
 * A value from a configuration file.
 *
 * This can represent a subset of the values of the Lua programming
 * language. Specifically, this can contain "nil", strings, numbers (which are
 * always floating point) and a subset of what tables can
 * represent.
 *
 * Concerning the supported subset of Lua tables, a $(D ConfigValue) can only
 * represent tables in which all values are indexed by string keys, or tables
 * that are used as lists. These two cases are internally represented as
 * separate types (respectively, $(D ConfigValueType.AA) and $(D
 * ConfigValueType.LIST)).
 *
 * By the way, this brings an interesting question, which doesn't exist in the
 * real Lua world: is $(D { }) considered a $(D ConfigValueType.AA) or a $(D
 * ConfigValueType.LIST)? Well, based on the fact that $(D { }) doesn't have any
 * string key, we use the convention that it is a $(D ConfigValueType.LIST). You
 * may want to use $(D isEmptyTable()) to check if something is either an empty
 * associative array or an empty list.
 */
public struct ConfigValue
{
   /// Constructs a $(D ConfigValue) with a "string" type.
   public this(string data)
   {
      _type = ConfigValueType.STRING;
      _string = data;
   }

   /// Constructs a $(D ConfigValue) with a "number" type.
   public this(double data)
   {
      _type = ConfigValueType.NUMBER;
      _number = data;
   }

   /// Constructs a $(D ConfigValue) with an "associative array" type.
   public this(const ConfigValue[string] data)
   {
      _type = ConfigValueType.AA;
      _table = data;
   }

   /// Constructs a $(D ConfigValue) with a "list" type.
   public this(const ConfigValue[] data)
   {
      _type = ConfigValueType.LIST;
      _list = data;
   }

   /// Returns the type of this $(D ConfigValue).
   public @property ConfigValueType type() inout { return _type; }

   /// Gets the value assuming it is a string.
   public @property string asString() inout
   in
   {
      assert(_type == ConfigValueType.STRING);
   }
   body
   {
      return _string;
   }

   /// Gets the value assuming it is a number.
   public @property double asNumber() inout
   in
   {
      assert(_type == ConfigValueType.NUMBER);
   }
   body
   {
      return _number;
   }

   /// Gets the value assuming it is a table of values indexed by strings.
   public @property const(ConfigValue[string]) asAA() inout
   in
   {
      assert(_type == ConfigValueType.AA);
   }
   body
   {
      return _table;
   }

   /// Gets the value assuming it is a list of values.
   public @property const(ConfigValue[]) asList() inout
   in
   {
      assert(_type == ConfigValueType.LIST);
   }
   body
   {
      return _list;
   }

   /// Checks whether this is an empty table or list.
   public @property bool isEmptyTable() inout
   {
      return (_type == ConfigValueType.LIST && asList.length == 0)
         || (_type == ConfigValueType.AA && asAA.length == 0);
   }


   /// The type of this $(D ConfigValue); "nil" by default.
   private ConfigValueType _type;

   /**
    * The value stored in this $(D ConfigValue).
    *
    * TODO: This should be a $(D union), but as of DMD 2.063.2, the compiler
    *    doesn't support $(D union) in CTFE, so we'll keep this as a $(D struct)
    *    for now. When the compiler gets smarter, we'll just have to change this
    *    to $(D union) and everything should work.
    */
   private struct
   {
      string _string;
      double _number;
      const(ConfigValue[string]) _table;
      const(ConfigValue[]) _list;
   }
}

// Some simple minded tests for ConfigValue.
unittest
{
   // Nil
   ConfigValue nilValue;
   assert(nilValue.type == ConfigValueType.NIL);

   // String
   enum aString = "I am a string!";
   auto stringValue = ConfigValue(aString);

   assert(stringValue.type == ConfigValueType.STRING);
   assert(stringValue.asString == aString);

   // Number
   enum aNumber = 171.171;
   auto numberValue = ConfigValue(aNumber);

   assert(numberValue.type == ConfigValueType.NUMBER);
   assert(numberValue.asNumber == aNumber);

   // AA
   const ConfigValue[string] aTable = [
      "foo": ConfigValue(1.1),
      "bar": ConfigValue("baz")
   ];
   auto tableValue = ConfigValue(aTable);

   assert(tableValue.type == ConfigValueType.AA);

   assert("foo" in tableValue.asAA);
   assert(tableValue.asAA["foo"].type == ConfigValueType.NUMBER);
   assert(tableValue.asAA["foo"].asNumber == 1.1);

   assert("bar" in tableValue.asAA);
   assert(tableValue.asAA["bar"].type == ConfigValueType.STRING);
   assert(tableValue.asAA["bar"].asString == "baz");

   // List
   const aList = [ ConfigValue(-0.3), ConfigValue("blah") ];
   auto listValue = ConfigValue(aList);

   assert(listValue.type == ConfigValueType.LIST);

   assert(listValue.asList.length == aList.length);
   assert(listValue.asList.length == 2);

   assert(listValue.asList[0].type == ConfigValueType.NUMBER);
   assert(listValue.asList[0].asNumber == -0.3);

   assert(listValue.asList[1].type == ConfigValueType.STRING);
   assert(listValue.asList[1].asString == "blah");
}

// Tests ConfigValue.isEmptyTable
unittest
{
   // Non-empty list
   auto fullListValue = ConfigValue([ ConfigValue(-0.3), ConfigValue("blah") ]);
   assert(!fullListValue.isEmptyTable);

   // Empty list
   const ConfigValue[] aList;
   auto emptyListValue = ConfigValue(aList);
   assert(emptyListValue.isEmptyTable);

   // Non-empty AA
   const ConfigValue[string] aTable = [
      "foo": ConfigValue(1.1),
      "bar": ConfigValue("baz")
   ];
   auto fullAAValue = ConfigValue(aTable);
   assert(!fullAAValue.isEmptyTable);

   // Empty AA
   const ConfigValue[string] anEmptyTable;
   auto emptyAAValue = ConfigValue(anEmptyTable);
   assert(emptyAAValue.isEmptyTable);
}


/**
 * Parses and returns one value from a list of tokens; removes the parsed
 * elements from this list of tokens.
 */
private ConfigValue parseValue(ref Token[] tokens)
in
{
   assert(tokens.length > 0);
}
body
{
   switch (tokens[0].type)
   {
      case TokenType.NIL:
         tokens = tokens[1..$];
         return ConfigValue();

      case TokenType.STRING:
      {
         auto res = ConfigValue(tokens[0].asString);
         tokens = tokens[1..$];
         return res;
      }

      case TokenType.NUMBER:
      {
         auto res = ConfigValue(tokens[0].asNumber);
         tokens = tokens[1..$];
         return res;
      }

      case TokenType.OPENING_BRACE:
         if (tokens.length < 2)
            throw new Exception("Table not closed near " ~ tokens[0].rawData);
         else if (tokens[1].type == TokenType.IDENTIFIER)
            return parseAA(tokens);
         else
            return parseList(tokens);

      default:
         throw new Exception("Error parsing near " ~ tokens[0].rawData);
   }
}

// Tests for parseValue(). This is also indirectly tested by whatever tests
// parseConfig().
unittest
{
   with (TokenType)
   {
      // Simple case: nil
      auto tokensNil = [ Token(NIL, "nil") ];
      assert(parseValue(tokensNil).type == ConfigValueType.NIL);
      assert(tokensNil == [ ]);

      // Simple case: string
      auto tokensString = [ Token(STRING, "'hello'") ];
      auto stringData = parseValue(tokensString);
      assert(stringData.type == ConfigValueType.STRING);
      assert(stringData.asString == "hello");
      assert(tokensString == [ ]);

      // Simple case: number
      auto tokensNumber = [ Token(NUMBER, "-8.571") ];
      auto numberData = parseValue(tokensNumber);
      assert(numberData.type == ConfigValueType.NUMBER);
      assert(numberData.asNumber == -8.571);
      assert(tokensNumber == [ ]);

      // Some shortcuts for the next few tests
      auto openingBrace = Token(OPENING_BRACE, "{");
      auto closingBrace = Token(CLOSING_BRACE, "}");
      auto comma = Token(COMMA, ",");
      auto equals = Token(EQUALS, "=");

      // Empty list
      auto tokensEmptyList = [ openingBrace, closingBrace ];
      auto emptyListData = parseValue(tokensEmptyList);
      assert(emptyListData.type == ConfigValueType.LIST);
      assert(emptyListData.asList.length == 0);
      assert(tokensEmptyList == [ ]);

      // List (with members)
      auto tokensList = [
         openingBrace,
         Token(NUMBER, "1.11"), comma, Token(STRING, "'abc'"), comma,
         closingBrace ];
      auto listData = parseValue(tokensList);
      assert(listData.type == ConfigValueType.LIST);
      assert(listData.asList.length == 2);
      assert(listData.asList[0].type == ConfigValueType.NUMBER);
      assert(listData.asList[0].asNumber == 1.11);
      assert(listData.asList[1].type == ConfigValueType.STRING);
      assert(listData.asList[1].asString == "abc");
      assert(tokensList == [ ]);

      // Associative array
      auto tokensAA = [
         openingBrace,
         Token(IDENTIFIER, "one"), equals, Token(NUMBER, "1"), comma,
         Token(IDENTIFIER, "two"), equals, Token(NUMBER, "2"), comma,
         Token(IDENTIFIER, "foobar"), equals, Token(STRING, "'baz'"), comma,
         closingBrace ];
      auto aaData = parseValue(tokensAA);
      assert(aaData.type == ConfigValueType.AA);
      assert(aaData.asAA.length == 3);
      assert("one" in aaData.asAA);
      assert(aaData.asAA["one"].type == ConfigValueType.NUMBER);
      assert(aaData.asAA["one"].asNumber == 1);
      assert("two" in aaData.asAA);
      assert(aaData.asAA["two"].type == ConfigValueType.NUMBER);
      assert(aaData.asAA["two"].asNumber == 2);
      assert("foobar" in aaData.asAA);
      assert(aaData.asAA["foobar"].type == ConfigValueType.STRING);
      assert(aaData.asAA["foobar"].asString == "baz");
      assert(tokensAA == [ ]);
   }
}

/// Like $(D parseValue), but specific for associative arrays.
private ConfigValue parseAA(ref Token[] tokens)
in
{
   assert(tokens.length > 0);
   assert(tokens[0].type == TokenType.OPENING_BRACE);
}
body
{
   ConfigValue[string] result;

   tokens = tokens[1..$]; // skip opening brace

   while (true)
   {
      // Check for the end of the table
      if (tokens.length == 0)
         throw new Exception("List not closed.");

      if (tokens[0].type == TokenType.CLOSING_BRACE)
      {
         tokens = tokens[1..$];
         return ConfigValue(result);
      }

      // Read the key/value pair
      if (tokens.length < 3)
      {
         throw new Exception(
            "Incomplete key/value pair near " ~ tokens[0].rawData);
      }

      if (tokens[0].type != TokenType.IDENTIFIER)
         throw new Exception("Not a valid table key: " ~ tokens[0].rawData);

      if (tokens[1].type != TokenType.EQUALS)
         throw new Exception("Expected =, got " ~ tokens[0].rawData);

      auto key = tokens[0].asIdentifier;
      tokens = tokens[2..$];
      auto value = parseValue(tokens);

      result[key] = value;

      // After the key/value pair, we need either a comma or a closing brace
      if (tokens[0].type == TokenType.COMMA)
      {
         tokens = tokens[1..$];
      }
      else if (tokens[0].type != TokenType.CLOSING_BRACE)
      {
         throw new Exception("Error parsing table near " ~ tokens[0].rawData);
      }
   }
}

/// Like $(D parseValue), but specific for lists.
private ConfigValue parseList(ref Token[] tokens)
in
{
   assert(tokens.length > 0);
   assert(tokens[0].type == TokenType.OPENING_BRACE);
}
body
{
   ConfigValue[] result;

   tokens = tokens[1..$]; // skip opening brace

   while (true)
   {
      // Check for the end of the table
      if (tokens.length == 0)
         throw new Exception("List not closed.");

      if (tokens[0].type == TokenType.CLOSING_BRACE)
      {
         tokens = tokens[1..$];
         return ConfigValue(result);
      }

      // Read the value
      result ~= parseValue(tokens);

      // After the value, we need either a comma or a closing brace
      if (tokens[0].type == TokenType.COMMA)
      {
         tokens = tokens[1..$];
      }
      else if (tokens[0].type != TokenType.CLOSING_BRACE)
      {
         throw new Exception("Error parsing list near " ~ tokens[0].rawData);
      }
   }
}

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
public ConfigValue parseConfig(string data)
{
   /// Lexes $(D data), returns the list of tokens. Throws on error.
   Token[] tokenize(string data)
   {
      Token[] res;

      while(true)
      {
         Token token;
         data = nextToken(data, token);

         if (token.type == TokenType.ERROR)
            throw new Exception(token.rawData);

         if (token.type == TokenType.EOF)
            return res;

         res ~= token;
      }
   }

   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // Tokenize all input data
   Token[] tokens = tokenize(data);

   // Assume it is a list of IDENTIFIER = VALUE
   // Return

   ConfigValue cv;
   cv._number = 2.3;

   if (data == "...")
      throw new Exception("Augh!");
   return cv;
}


// Tests parseConfig(), which is the main thing we have in this module.
unittest
{
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // xxxxxxxx for lists: { } { v, } { v } { v, v, } { v, v, v }
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

enum altInput = "
   type = foo
   params = { 'a', 'b', 'c' }
   extra = {
      one = 1,
      two = 2,
      three = 3,
   }
";


// {} --> a table or a list? a list, I'd say... no indexes there...




unittest
{
   enum val = parseConfig("throw")._number;
   assert(val == 2.3);
   //...
}
