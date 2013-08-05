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

   // Number
   enum aNumber = 171.171;
   auto numberValue = ConfigValue(aNumber);

   assert(numberValue.type == ConfigValueType.NUMBER);
   assert(numberValue.isNumber);
   assert(numberValue.asNumber == aNumber);

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
   assert(tableValue["foo"].asNumber == 1.1);

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
   assert(listValue[0].asNumber == -0.3);

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
      assert(stringData.asString == "hello");
      assert(tokensString == [ ]);

      // Simple case: number
      auto tokensNumber = [ Token(NUMBER, "-8.571") ];
      auto numberData = parseValue(tokensNumber);
      assert(numberData.isNumber);
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
      assert(listData[0].asNumber == 1.11);
      assert(listData[1].isString);
      assert(listData[1].asString == "abc");
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
      assert(aaData["one"].asNumber == 1);
      assert("two" in aaData.asAA);
      assert(aaData["two"].isNumber);
      assert(aaData["two"].asNumber == 2);
      assert("foobar" in aaData.asAA);
      assert(aaData["foobar"].isString);
      assert(aaData["foobar"].asString == "baz");
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

   // 
   // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   // xxxxxxxx for lists: { } { v, } { v } { v, v, } { v, v, v }
}

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// compile-time...
unittest
{
   double fun()
   {
      auto v = parseConfig("a = 2.2");
      assert(v.isAA);
      assert("a" in v.asAA);
      assert(v["a"].isNumber);
      return v["a"].asNumber;
   }

   //fun();

   enum val = fun();
   assert(val == 2.2);
}
