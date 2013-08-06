/**
 * Configuration files/strings, which work even at compile-time and use a
 * Lua-like syntax.
 *
 * Authors: Leandro Motta Barros
 */

module fewdee.config;

import std.traits;
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
      _aa = data;
   }

   /// Constructs a $(D ConfigValue) with a "list" type.
   public this(const ConfigValue[] data)
   {
      _type = ConfigValueType.LIST;
      _list = data;
   }

   /**
    * Assuming a $(D ConfigValue) of type $(D ConfigValueType.LIST), returns the
    * value at a given index.
    *
    * Using this yields code like $(D value[0]), which is more readable than $(D
    * value.asList[0]).
    */
   public const(ConfigValue) opIndex(size_t index) inout
   in
   {
      assert(
         _type == ConfigValueType.LIST,
         "Trying to index with an integer a ConfigValue that is not a list");
      assert(
         index < _list.length,
         "Out-of-bounds index for ConfigValue");
   }
   body
   {
      return _list[index];
   }

   /**
    * Assuming a $(D ConfigValue) of type $(D ConfigValueType.AA), returns the
    * value associated with a given key.
    *
    * Using this yields code like $(D value["key"]), which is more readable than
    * $(D value.asAA["key"]).
    */
   public const(ConfigValue) opIndex(string key) inout
   in
   {
      assert(_type == ConfigValueType.AA,
             "Trying to index with a string a ConfigValue that is not an "
             "associative array");
      assert(key in _aa, "Key not found in ConfigValue");
   }
   body
   {
      return _aa[key];
   }

   /**
    * Assuming a $(D ConfigValue) of type $(D ConfigValueType.AA) or $(D
    * ConfigValueType.LIST), returns the number of elements stored in the
    * associative array or list.
    *
    * Using this yields code like $(D value.length), which is more readable than
    * $(D value.asAA.length).
    */
   public @property size_t length() inout
   in
   {
      assert(_type == ConfigValueType.AA || _type == ConfigValueType.LIST,
             "Can only take length of associative arrays and lists.");
   }
   body
   {
      if (isAA)
         return _aa.length;
      else if (isList)
         return _list.length;
      else
         assert(false, "Only AAs and lists are accepted here");
   }

   /**
    * Equality operator. Comparing with the "wrong" type is not an error -- it
    * simply returns $(D false) in this case.
    */
   public bool opEquals(T)(T value) const
   {
      static if(is(T == string))
      {
         return isString && _string == value;
      }
      else if (isNumeric!T)
      {
         return isNumber && _number == value;
      }
   }

   ///
   unittest
   {
      auto stringValue = ConfigValue("xyz");
      auto numberValue = ConfigValue(123);

      assert(stringValue == "xyz");
      assert(stringValue != "abc");

      assert(numberValue == 123);
      assert(numberValue != 999);

      assert(stringValue != 123);
      assert(numberValue != "xyz");
   }

   /// Returns the type of this $(D ConfigValue).
   public @property ConfigValueType type() inout { return _type; }

   // Is this value a string?
   public @property bool isString() inout
   {
      return _type == ConfigValueType.STRING;
   }

   // Is this value a number?
   public @property bool isNumber() inout
   {
      return _type == ConfigValueType.NUMBER;
   }

   // Is this value nil?
   public @property bool isNil() inout
   {
      return _type == ConfigValueType.NIL;
   }

   // Is this value a list?
   public @property bool isList() inout
   {
      return _type == ConfigValueType.LIST;
   }

   // Is this value an associative array?
   public @property bool isAA() inout
   {
      return _type == ConfigValueType.AA;
   }

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
      return _aa;
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
      const(ConfigValue[string]) _aa;
      const(ConfigValue[]) _list;
   }
}

// Some simple minded tests for ConfigValue.
unittest
{
   // Nil
   ConfigValue nilValue;
   assert(nilValue.type == ConfigValueType.NIL);
   assert(nilValue.isNil);

   // String
   enum aString = "I am a string!";
   auto stringValue = ConfigValue(aString);

   assert(stringValue.type == ConfigValueType.STRING);
   assert(stringValue.isString);
   assert(stringValue.asString == aString);
   assert(stringValue == aString);

   // Number
   enum aNumber = 171.171;
   auto numberValue = ConfigValue(aNumber);

   assert(numberValue.type == ConfigValueType.NUMBER);
   assert(numberValue.isNumber);
   assert(numberValue.asNumber == aNumber);
   assert(numberValue == aNumber);

   // AA
   const ConfigValue[string] aTable = [
      "foo": ConfigValue(1.1),
      "bar": ConfigValue("baz")
   ];
   auto tableValue = ConfigValue(aTable);

   assert(tableValue.type == ConfigValueType.AA);
   assert(tableValue.isAA);

   assert("foo" in tableValue.asAA);
   assert(tableValue["foo"].isNumber);
   assert(tableValue["foo"] == 1.1);

   assert("bar" in tableValue.asAA);
   assert(tableValue["bar"].isString);
   assert(tableValue["bar"].asString == "baz");

   // List
   const aList = [ ConfigValue(-0.3), ConfigValue("blah") ];
   auto listValue = ConfigValue(aList);

   assert(listValue.type == ConfigValueType.LIST);
   assert(listValue.isList);

   assert(listValue.length == aList.length);
   assert(listValue.length == 2);

   assert(listValue[0].isNumber);
   assert(listValue[0] == -0.3);

   assert(listValue[1].isString);
   assert(listValue[1].asString == "blah");
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
         else if (tokens[1].isIdentifier)
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
      assert(parseValue(tokensNil).isNil);
      assert(tokensNil == [ ]);

      // Simple case: string
      auto tokensString = [ Token(STRING, "'hello'") ];
      auto stringData = parseValue(tokensString);
      assert(stringData.isString);
      assert(stringData == "hello");
      assert(tokensString == [ ]);

      // Simple case: number
      auto tokensNumber = [ Token(NUMBER, "-8.571") ];
      auto numberData = parseValue(tokensNumber);
      assert(numberData.isNumber);
      assert(numberData == -8.571);
      assert(tokensNumber == [ ]);

      // Some shortcuts for the next few tests
      auto openingBrace = Token(OPENING_BRACE, "{");
      auto closingBrace = Token(CLOSING_BRACE, "}");
      auto comma = Token(COMMA, ",");
      auto equals = Token(EQUALS, "=");

      // Empty list
      auto tokensEmptyList = [ openingBrace, closingBrace ];
      auto emptyListData = parseValue(tokensEmptyList);
      assert(emptyListData.isList);
      assert(emptyListData.length == 0);
      assert(tokensEmptyList == [ ]);

      // List (with members)
      auto tokensList = [
         openingBrace,
         Token(NUMBER, "1.11"), comma, Token(STRING, "'abc'"), comma,
         closingBrace ];
      auto listData = parseValue(tokensList);
      assert(listData.isList);
      assert(listData.length == 2);
      assert(listData[0].isNumber);
      assert(listData[0] == 1.11);
      assert(listData[1].isString);
      assert(listData[1] == "abc");
      assert(tokensList == [ ]);

      // Associative array
      auto tokensAA = [
         openingBrace,
         Token(IDENTIFIER, "one"), equals, Token(NUMBER, "1"), comma,
         Token(IDENTIFIER, "two"), equals, Token(NUMBER, "2"), comma,
         Token(IDENTIFIER, "foobar"), equals, Token(STRING, "'baz'"), comma,
         closingBrace ];
      auto aaData = parseValue(tokensAA);
      assert(aaData.isAA);
      assert(aaData.length == 3);
      assert("one" in aaData.asAA);
      assert(aaData["one"].isNumber);
      assert(aaData["one"] == 1);
      assert("two" in aaData.asAA);
      assert(aaData["two"].isNumber);
      assert(aaData["two"] == 2);
      assert("foobar" in aaData.asAA);
      assert(aaData["foobar"].isString);
      assert(aaData["foobar"] == "baz");
      assert(tokensAA == [ ]);
   }
}

/// Like $(D parseValue), but specific for associative arrays.
private ConfigValue parseAA(ref Token[] tokens)
in
{
   assert(tokens.length > 0);
   assert(tokens[0].isOpeningBrace);
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

      if (tokens[0].isClosingBrace)
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
      if (tokens[0].isComma)
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
   assert(tokens[0].isOpeningBrace);
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

      if (tokens[0].isClosingBrace)
      {
         tokens = tokens[1..$];
         return ConfigValue(result);
      }

      // Read the value
      result ~= parseValue(tokens);

      // After the value, we need either a comma or a closing brace
      if (tokens[0].isComma)
      {
         tokens = tokens[1..$];
      }
      else if (tokens[0].type != TokenType.CLOSING_BRACE)
      {
         throw new Exception("Error parsing list near " ~ tokens[0].rawData);
      }
   }
}


/**
 * Parses a given configuration string, and returns the data read.
 *
 * xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 * xxxxxx Doc the format!
 *
 * Parameters:
 *    data = The configuration data string. The configuration format is a subset
 *       of what Lua supports, and is described above.
 *
 * Returns: A $(ConfigValue) of type $(D ConfigValueType.AA) with all the
 *    key/value pairs found in $(D data).
 *
 * Throws:
 *    Throws an $(D Exception) if parsing fails.
 */
public ConfigValue parseConfig(string data)
out(result)
{
   assert(result.isAA);
}
body
{
   /// Lexes $(D data), returns the list of tokens. Throws on error.
   Token[] tokenize(string data)
   {
      Token[] res;

      while(true)
      {
         Token token;
         data = nextToken(data, token);

         if (token.isError)
            throw new Exception(token.rawData);

         if (token.isEOF)
            return res;

         res ~= token;
      }
   }

   ConfigValue[string] result;

   // Tokenize all input data
   Token[] tokens = tokenize(data);

   // Parse a sequence of 'key = value' entries
   while (true)
   {
      // Check for the end of the input stream.
      if (tokens.length == 0)
         return ConfigValue(result);

      // Read the key = value entry
      if (tokens.length < 3)
      {
         throw new Exception(
            "Incomplete key = value entry near " ~ tokens[0].rawData);
      }

      if (tokens[0].type != TokenType.IDENTIFIER)
         throw new Exception("Not a valid table key: " ~ tokens[0].rawData);

      if (tokens[1].type != TokenType.EQUALS)
         throw new Exception("Expected =, got " ~ tokens[0].rawData);

      auto key = tokens[0].asIdentifier;
      tokens = tokens[2..$];
      auto value = parseValue(tokens);

      result[key] = value;
   }

   assert(false);
}


// Very basic parseConfig() tests.
unittest
{
   // An empty input string yields an empty associative array
   auto v1 = parseConfig("");
   assert(v1.isAA);
   assert(v1.length == 0);

   // An empty pair of braces yields an empty list
   auto v2 = parseConfig("list = {}");
   assert(v2.isAA);
   assert(v2.length == 1);
   assert("list" in v2.asAA);
   assert(v2["list"].isList);
   assert(v2["list"].length == 0);

   // A string value
   auto v3 = parseConfig("x = 'asdf'");
   assert(v3.isAA);
   assert(v3.length == 1);
   assert("x" in v3.asAA);
   assert(v3["x"] == "asdf");

   // A numeric value
   auto v4 = parseConfig("_v = 1.3e-6");
   assert(v4.isAA);
   assert(v4.length == 1);
   assert("_v" in v4.asAA);
   assert(v4["_v"] == 1.3e-6);

   // A nil value
   auto v5 = parseConfig("sigh = nil");
   assert(v5.isAA);
   assert(v5.length == 1);
   assert("sigh" in v5.asAA);
   assert(v5["sigh"].isNil);

   // A list
   auto v6 = parseConfig("myList = { +1.2, nil, 'foobar' }");
   assert(v6.isAA);
   assert(v6.length == 1);
   assert("myList" in v6.asAA);
   assert(v6["myList"][0] == 1.2);
   assert(v6["myList"][1].isNil);
   assert(v6["myList"][2] == "foobar");

   // An associative array
   auto v7 = parseConfig("myAA = { first = 1, second = 2, third = 'three' }");
   assert(v7.isAA);
   assert(v7.length == 1);
   assert("myAA" in v7.asAA);
   assert(v7["myAA"]["first"] == 1);
   assert(v7["myAA"]["second"] == 2);
   assert(v7["myAA"]["third"] == "three");
}

/// A few more tests with strings
unittest
{
   assert(parseConfig(`s = "aaa"`)["s"] == "aaa");
   assert(parseConfig(`s = 'aaa'`)["s"] == "aaa");
   assert(parseConfig(`s = '\''`)["s"] == "'");
   assert(parseConfig(`s = ''`)["s"] == "");
   assert(parseConfig(`s=""`)["s"] == "");
}

/// A few more tests with numbers
unittest
{
   assert(parseConfig(`n = 1.111`)["n"] == 1.111);
   assert(parseConfig(`n = -4.11`)["n"] == -4.11);
   assert(parseConfig(`n = .01`)["n"] == .01);
   assert(parseConfig(`n= .01`)["n"] == .01);
   assert(parseConfig(`n =.01e5`)["n"] == .01e5);
   assert(parseConfig(`n =-.01E5`)["n"] == -.01e5);
}

/// More tests with lists
unittest
{
   // No trailing comma, one element
   auto v1 = parseConfig("x = { 'abc' } ");
   assert(v1["x"].isList);
   assert(v1["x"].length == 1);
   assert(v1["x"][0] == "abc");

   // Trailing comma, one element
   auto v2 = parseConfig("x = { 'abc', } ");
   assert(v2["x"].isList);
   assert(v2["x"].length == 1);
   assert(v2["x"][0] == "abc");

   // No trailing comma, multiple elements
   auto v3 = parseConfig("x = { 'abc', 123.4 } ");
   assert(v3["x"].isList);
   assert(v3["x"].length == 2);
   assert(v3["x"][0] == "abc");
   assert(v3["x"][1] == 123.4);

   // Trailing comma, multiple elements
   auto v4 = parseConfig("x = { 'abc', 123.4, } ");
   assert(v4["x"].isList);
   assert(v4["x"].length == 2);
   assert(v4["x"][0] == "abc");
   assert(v4["x"][1] == 123.4);

   // Unorthodox formatting
   auto v5 = parseConfig("
     x
     = {     'abc'
       ,123.4,
       --1.5,
       5.1--howdy!}
     }--} ");
   assert(v5["x"].isList);
   assert(v5["x"].length == 3);
   assert(v5["x"][0] == "abc");
   assert(v5["x"][1] == 123.4);
   assert(v5["x"][2] == 5.1);
}

/// More tests with associative arrays
unittest
{
   // No trailing comma, one element
   auto v1 = parseConfig("aa = { x = 'abc' } ");
   assert(v1["aa"].isAA);
   assert(v1["aa"].length == 1);
   assert(v1["aa"]["x"] == "abc");

   // Trailing comma, one element
   auto v2 = parseConfig("aa = { x = 'abc', } ");
   assert(v2["aa"].isAA);
   assert(v2["aa"].length == 1);
   assert(v2["aa"]["x"] == "abc");

   // No trailing comma, multiple elements
   auto v3 = parseConfig("aa = { x = 'abc', y = 123.4 } ");
   assert(v3["aa"].isAA);
   assert(v3["aa"].length == 2);
   assert(v3["aa"]["x"] == "abc");
   assert(v3["aa"]["y"] == 123.4);

   // Trailing comma, multiple elements
   auto v4 = parseConfig("aa = { x = 'abc', y = 123.4, } ");
   assert(v4["aa"].isAA);
   assert(v4["aa"].length == 2);
   assert(v4["aa"]["x"] == "abc");
   assert(v4["aa"]["y"] == 123.4);

   // Unorthodox formatting
   auto v5 = parseConfig("
     aa
     = {     x = --\"xxx'
       'abc'
       ,y=123.4,
       --1.5,
       z             =
       5.1--howdy!}
     }--} ");
   assert(v5["aa"].isAA);
   assert(v5["aa"].length == 3);
   assert(v5["aa"]["x"] == "abc");
   assert(v5["aa"]["y"] == 123.4);
   assert(v5["aa"]["z"] == 5.1);
}

/// Try some comments and blanks
unittest
{
   auto value = parseConfig(`
      -- This is a comment
      -- This is still a comment
      a = 9.8 -- a comment
      b =          8.7

      c = 7.6--more comment...--
      -- d = 6.5
   `);

   assert(value.isAA);
   assert(value.length == 3);
   assert("a" in value.asAA);
   assert("b" in value.asAA);
   assert("c" in value.asAA);
   assert("d" !in value.asAA);
   assert(value["a"] == 9.8);
   assert(value["b"] == 8.7);
   assert(value["c"] == 7.6);
}

/// Nested data structures, simple case
unittest
{
   auto v = parseConfig(
      "aa = {
          seq = {1,2,3},
          nestedAA = { foo = 'bar' }} ");

   assert(v["aa"].isAA);
   assert(v["aa"].length == 2);

   assert(v["aa"]["seq"].isList);
   assert(v["aa"]["seq"].length == 3);
   assert(v["aa"]["seq"][0] == 1);
   assert(v["aa"]["seq"][1] == 2);
   assert(v["aa"]["seq"][2] == 3);

   assert(v["aa"]["nestedAA"].isAA);
   assert(v["aa"]["nestedAA"].length == 1);
   assert("foo" in v["aa"]["nestedAA"].asAA);
   assert(v["aa"]["nestedAA"]["foo"] == "bar");
}

/// Nested data structures, more complex case
unittest
{
   auto v = parseConfig(
      "aa = {
          seq = {1, { 2, 'two' } ,3},
          nestedAA = { foo = 'bar', baz = { oneMore = 'enough' } }
      }

      list = { nil, { 'a', 'b', -11.1, }, { x = '0', y = 0, z = { 0 }, } }
 ");

   assert(v["aa"].isAA);
   assert(v["aa"].length == 2);

   assert(v["aa"]["seq"].isList);
   assert(v["aa"]["seq"].length == 3);
   assert(v["aa"]["seq"][0] == 1);
   assert(v["aa"]["seq"][2] == 3);
   assert(v["aa"]["seq"][1].isList);
   assert(v["aa"]["seq"][1].length == 2);
   assert(v["aa"]["seq"][1][0] == 2);
   assert(v["aa"]["seq"][1][1] == "two");

   assert(v["aa"]["nestedAA"].isAA);
   assert(v["aa"]["nestedAA"].length == 2);
   assert("foo" in v["aa"]["nestedAA"].asAA);
   assert(v["aa"]["nestedAA"]["foo"] == "bar");
   assert("baz" in v["aa"]["nestedAA"].asAA);
   assert(v["aa"]["nestedAA"]["baz"].isAA);
   assert(v["aa"]["nestedAA"]["baz"].length == 1);
   assert("oneMore" in v["aa"]["nestedAA"]["baz"].asAA);
   assert(v["aa"]["nestedAA"]["baz"]["oneMore"] == "enough");

   assert(v["list"].isList);
   assert(v["list"].length == 3);

   assert(v["list"][0].isNil);

   assert(v["list"][1].isList);
   assert(v["list"][1].length == 3);
   assert(v["list"][1][0] == "a");
   assert(v["list"][1][1] == "b");
   assert(v["list"][1][2] == -11.1);

   assert(v["list"][2].isAA);
   assert(v["list"][2].length == 3);
   assert(v["list"][2]["x"] == "0");
   assert(v["list"][2]["y"] == 0);
   assert(v["list"][2]["z"].isList);
   assert(v["list"][2]["z"].length == 1);
   assert(v["list"][2]["z"][0] == 0);
}

// Test if this really works at compile-time.
unittest
{
   double fun(string data)
   {
      auto v = parseConfig(data);
      return v["u_u"]["foo"][1].asNumber;
   }

   enum val = fun("u_u = { foo = { nil, 4, 'foo', -3e-2}, bar = 627.478} ----");
   assert(val == 4);
}
