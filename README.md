![TreeStructInfo](http://treestruct.info/global/img/logo-small.png)<br/>
*Copyright © Jarosław Baran, furious programming 2013 - 2016*

Latest API release: [TreeStructInfo 2.0 RC1](https://github.com/furious-programming/TreeStructInfo/releases/tag/v2.0.0.-rc.1)

This document is highly abbreviated version of the format specification. Full form of [official **TreeStructInfo 2.0** format specification](http://treestruct.info/pl/format/2.0.htm) is available on the [project website](http://treestruct.info) (unfortunately, for now only in Polish). [Detailed documentation of this API](http://treestruct.info/pl/api/official-2.0-freepas/index.htm) to handle the **TreeStructInfo** files and the [tutorial](http://treestruct.info/pl/api/official-2.0-freepas/tutorial/index.htm) are also available on the [project website](http://treestruct.info) (also only in Polish).

- [Introduction](#)
- [Sample file](#)
- [Text files syntax](#)
- [Identifiers](#)
- [Frame of tree](#)
- [Basic tree elements](#)
	- [Attributes](#)
		- [Booleans](#)
		- [Integers](#)
		- [Floating-point numbers](#)
		- [Currencies](#)
		- [Strings](#)
		- [Dates and times](#)
		- [Point coordinates](#)
		- [Binary data](#)
		- [Other data types](#)
	- [Child nodes](#)
- [Referenced elements](#)
	- [Referenced attributes](#)
	- [Referenced child nodes](#)
	- [The order of referenced elements definitions](#)
- [Comments](#)
	- [Tree comment](#)
	- [Attributes comments](#)
	- [Child nodes comments](#)
- [Binary form](#)
	- [Data types](#)
	- [Static data](#)
	- [Dynamic data](#)
- [Bindings](#)
- [TreeStructInfo project support](#)

# Introduction

**TreeStructInfo** is a project of the universal format for text and binary configuration files, for storing settings of applications and games in the form of data trees.

Format is human-friendly - text files syntax is based on a small set of keywords, key phrases and linear structure. Text form gives the possibility to create an open configurations. Binary form provides faster files processing, maintaining compatibility of native data in memory with a text form.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm)

# Sample file

I can not use my own syntax highlighting, so if you want to see the sample text file, go to the [**sample file** point in specification](http://treestruct.info/pl/format/2.0.htm#idSampleFile).

# Text files syntax

Text files are build in a linear manner - in every single line can be written only one information, such as the tree header or the header of attribute declaration. Is allowed to insert any number of blank lines. Syntax is based on the following keywords and key phrases:

```
treestructinfo    - opens the header of the tree
name              - stands before the name of the tree
end tree          - closes the main body of the tree

attr              - opens the header of standard attribute declaration
node              - opens the header of standard node declaration
end node          - ends the standard node body

ref attr          - opens the header of referenced attribute declaration
ref node          - opens the headers of referenced node declaration and definition
end ref node      - ends the referenced node body
```

Keywords and key phrases can be made up only of lowercase letters. To describe the syntax of text configuration files used is also one value-string:

```
"2.0"      - the value of the format version
```

a small number of special characters:

```
"      - opens and closes any values
,      - point coordinates separator
#9     - reserved for a single blank line as a multiline attribute value
```

and a single string, acting as a keyword, but consisting only of special characters:

```
::    - prefix of comments
```

The default size of a single indentation is two space characters (`0x20`), but indentation are not mandatory.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idTextFileSyntax)

# Identifiers

Identifiers are the names of the tree elements (the name of the tree is the identifier too). The minimum length of the identifier is one character, maximum length is not specified. Element names can not contain the following characters:

```
#0 .. #31    - set of control characters
\            - reserved for the paths to the elements
"            - quote character opens and closes the values

~            - character specifying (in the path) a reference to the current node
```

other characters are allowed (`0x20` too). Identifiers are case-sensitive.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idIdentifiers)

# Frame of tree

The body of the tree opens the line containing the specified header. The basic form of the header looks like this:

```
treestructinfo "2.0"
```

line must contain the keyword `treestructinfo`, then the value of the format version. Extended version of the header further includes a keyword `name` and value of the tree name:

```
treestructinfo "2.0" name "Tree Name"
```

Main body of the tree closes the line containing the following key phrase:

```
end tree
```

So text file content with empty tree should look like this:

```
treestructinfo "2.0"
end tree
```

or this:

```
treestructinfo "2.0" name "Tree Name"
end tree
```

All standard elements must be declared between these lines.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idFrameOfTree)

# Basic tree elements

The basic elements are standard and referenced **attributes**, for storing specific data, standard and referenced **child nodes**, to group elements and create a tree structure.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idBasicElements)

## Attributes

Attributes are used to store data. Divided into **standard attributes**, that have the declaration and definition in the same place in the tree, and **referenced attributes**, that are defined outside of the main body of the tree.

Standard attribute declaration must contain the keyword `attr`, then the identifier and the attribute value:

```
attr Name "Value"
```

The attribute value can be multiline. Each next value line or next value must be contained in quotation marks, without any terminator characters:

```
attr Name "first line"
          "second line"
          "third line"
```

Attribute value can also contain blank lines at the beginning, in the middle or at the end:

```
attr Name ""
          "second line"
          ""
          "fourth line"
          ""
```

Attributes can store data in multiple types, written in many different ways. In addition to simple types, attributes can also contain binary data, written as a strings of hexadecimal characters.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttributes)

### Booleans

Boolean values are determined using conventional strings:

```
"True"     "Yes"    "On"     "T"    "Y"    "1"    - true values
"False"    "No"     "Off"    "F"    "N"    "0"    - false values
```

PascalCase for string values is not mandatory (uppercase for character values too). Digits `1` and `0` are the only permitted.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeBoolean)

### Integers

Integers can be written in the four most popular numeral systems - decimal, hexadecimal, octal and binary, and can be positive and negative. Prefixes for the numbers in numeral systems other than decimal is `0x` for hexadecimal, `0o` for octal and `0b` for binary. May have a leading characters `+` or `-`.

A positive, negative and zero numbers written in all systems:

```
"64206"              or "+64206"
"0xFACE"             or "+OxFACE"
"0o175316"           or "+0o175316"
"0b1111101011001110" or "+0b1111101011001110"

"-2989"
"-0xBAD"
"-0o5655"
"-0b101110101101"

"0"
"0x00"
"0o00"
"0b0000"
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeInteger)

### Floating-point numbers

Floating-point numbers can be written in universal or scientific form. May have a leading characters `+` or `-`. A positive, negative and zero numbers written in both forms:

```
"1009,1989"   or "+1009,1989"
"1,0091989E3" or "+1,0091989E+03"

"-1009,1989"
"-1,0091989E3" or "-1,0091989E+03"

"0"   or "0,0000"
"0E0" or "0,0E0" or "0,00E+00"
```

Decimal and thousand separators may be other, suitable according to your location.

There is also possibility to store special numbers as strings - positive or negative infinity and NaN:

```
"Inf" or "+Inf"    - positive infinity
"-Inf"             - negative infinity
"Nan"              - not a number
```

PascalCase for these strings is not mandatory.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeFloat)

### Currencies

Currency values have separate format - first, there is a number, followed by the currency string. Precision is arbitrary, but not more than four digits. Currency values also can contain leading character `+` or `-`.

Format of sample numbers below:

```
"4 zł"      or "+4 zł"
"4,18 zł"   or "+4,18 zł"
"4,1784 zł" or "+4,1784 zł"

"-3 $"
"-3,04 $"
"-3,0350 $"

"0 ¥"
"0,00 ¥"
"0,0000 ¥"
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeCurrency)

### Strings

Strings can be single-line or multiline and can contain almost all the characters. Example of single-line string:

```
"single line value"
```

Because of this, the attributes values extend from the first quotation mark until the end of the line, the strings may also contain the quotes:

```
" "first" "second" "third" "
```

Strings can be multiline - each line of the string must be on a separate line:

```
"first line"
"second line"
"third line"
```

and may also contain any number of blank lines.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeString)

### Dates and times

The date and time values can be written in any form - the order of date and/or time constituents is arbitrary. Twelve-hour clock format is permitted. Such values may also contain plaint text substrings.

Date examples:

```
"24-10-11"
"24-10-2011"
"24 Oct 2011"
"24 October 2011"
```

time examples:

```
"19:20"
"19:20:04"
"19:20:04:127"
"07:20 pm"
```

date and time together in one value:

```
"24.10.2011 19:20"
"24 October 2011, 19:20"
"Monday, 24.10.2011 (19:20)"
"Monday, 24 Oct 2011 (07:20 PM)"
```

and example with plain text substrings:

```
"today is Monday, 24-10-2011, time 19:20"
```

Text values of date and time components, such as the names of days and months, symbols and names of the seasons of the day (`am`, `pm`), as well as the date and time components separators are dependent on the location, so can take other characters or strings than those listed.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeDateTime)

### Point coordinates

Rules for the transcription the coordinates of the points are the same as in the case of integers - coordinates can be written in one of the four numeral systems. Point coordinates separator is a comma.

Examples of writing positive, negative and zero coordinates below:

```
"163,141"               or "+163,+141"
"0xA3,0x8D"             or "+0xA3,+0x8D"
"0o243,0o215"           or "+0o243,+0o215"
"0b10100011,0b10001101" or "+0b10100011,+0b10001101"

"-94,-75"
"-0x5E,-0x4B"
"-0o136,-0o113"
"-0b1011110,-0b1001011"

"0,0"
"0x00,0x00"
"0o00,0o00"
"0b0000,0b0000"
```

Both the coordinates should be written in the same numeral system (but is not a hard rule).

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypePointCoords)

### Binary data

Any binary data can be written in the form of strings, consisting of hexadecimal characters. The maximum size of the binary data is `2KiB`. Each byte is described by a pair of hexadecimal characters. Examples below.

Empty buffer:

```
""
```

`16` bytes, single-line value:

```
"54726565537472756374496E666F202D"
```

`47` bytes, multiline value:

```
"5472656553747275"
"6374496E666F202D"
"20666F726D617420"
"706C696BF377206B"
"6F6E666967757261"
"63796A6E796368"
```

`7` bytes, multiline value:

```
"5472656"
"5537472"
```

Number of **characters** per value line is not specified (may also be odd), but the total number of characters must be even. The basic and recommended lengths of single line binary values are:

- `8` bytes - `16` characters
- `16` bytes - `32` characters
- `32` bytes - `64` characters
- `64` bytes - `128` characters

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeBinary)

### Other data types

The issue of data storage in attributes of the not listed types is open and unlimited. Because of this, the serialization and deserialization native data to and from strings in different programming languages are different, the attribute values may store almost any data, with the proviso that stored in a precise way, without affecting the linear construction of the file and the tree structure information.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrValueDataTypeOther)


## Child nodes

The nodes are used to group elements and creating tree structure. Also divided into **standard nodes**, that have the declaration and definition in the same place, and **referenced nodes**, that are defined outside of the tree body.

The body of the standard child node opens the line containing the keyword `node` and the name of the node:

```
node Name
```

and closes the line with only the key phrase `end node`:

```
end node
```

The body of the empty standard child node looks like the following:

```
node Name
end node
```

For a given node are those elements, that are defined between the header line and the end line.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idNodes)

# Referenced elements

Referenced elements serve exactly the same purpose as standard elements. What makes them different is the method of writing - every such element has its own **declaration**, specifying its place in the tree, as well as its **definition**, including its proper body.

Referenced form may have attributes and child nodes.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idRefElements)

## Referenced attributes

The main advantage of using referenced attributes is to increase the readability of the configuration files in text form, by separating their definition beyond the main body of the tree.

The line with the declaration of referenced attribute must contain only the key phrase `ref attr` and the name of the attribute:

```
ref attr Name
```

The attribute declaration may be located inside the main body of the tree, as well as inside the body of the referenced child node.

The definition must contain the same key phrase `ref attr`, the same name as in the declaration and the value:

```
ref attr Name "Value"
```

The definition of the referenced attribute must be located outside the main body of the tree and outside the body of the referenced child node.

Example:

```
treestructinfo "2.0"
  ref attr Foo
end tree

ref attr Foo "Value"
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idRefAttributes)

## Referenced child nodes

Like the referenced attributes, referenced child nodes also have their **declarations** and **definitions**.

The line with referenced child node declaration must contain only the key phrase `ref node` and the name of the node:

```
ref node Name
```

The definition must contain a complete body of the node, terminated with the line with key phrase `end ref node`:

```
ref node Name
end ref node
```

Declaration of the referenced child node may be located inside the main body of the tree or inside the body of the referenced node, but the definition must be outside them.

Example:

```
treestructinfo "2.0"
  ref node Bald
end tree

ref node Bald
end ref node
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idRefNodes)

## The order of referenced elements definitions

The order of writing the definition of referenced elements is recursive, regardless of whether the element is standard or referenced, the content is immediately considered.

Short example:

```
treestructinfo "2.0"
  ref attr Integer
  ref node First
  ref node Third
end tree

ref attr Integer "0xFACE"

ref node First
  ref attr Float
  ref attr Currency
  ref node Second
end ref node

ref attr Float "3,14"
ref attr Currency "5,25 $"

ref node Second
  ref attr Point
end ref node

ref attr Point "0o00,0o00"

ref node Third
end ref node
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idOrderOfDefRefElements)

# Comments

Comments are not elements of trees - are additional informations, always belonging to the elements. Each element of the tree (**attributes** and **child nodes**) may have a comment, single-line or multiline. The tree may also have a comment - in this case, it is always written at the beginning of the file, before the main body of the tree.

Comment is simple the line, which has a prefix `::`:

```
:: comment line
```

If a comment is multiline, each line must contain the specified prefix:

```
:: first comment line
:: second comment line
:: last comment line
```

Multiline comments may also contain empty lines:

```
::
:: multiline comment
::
:: its fourth line
:: its fifth line
::
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idComments)

## Tree comment

If the tree has a main comment, it must be written before his body:

```
:: main tree comment

treestructinfo "2.0"
end tree
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idTreeComment)

## Attributes comments

Each attribute can have a comment. It must be written directly above his declaration:

```
treestructinfo "2.0"
  :: attribute comment
  attr Name "Value"
end tree
```

Referenced attributes can have two comments - declaration comment and definition comment:

```
treestructinfo "2.0"
  :: attribute declaration comment
  ref attr Name
end tree

:: attribute definition comment
ref attr Name "Value" 
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idAttrsComments)

## Child nodes comments

Standard child nodes can have one comment:

```
treestructinfo "2.0"
  :: child node comment
  node Name
  end node
end tree
```

and the referenced nodes can have two:

```
treestructinfo "2.0"
  :: child node declaration comment
  ref node Name
end tree

:: child node definition comment
ref node Name
end ref node
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idNodesComments)

# Binary form

The binary form of configuration files has been designed so that the loading and saving files were much faster than the loading and saving the files in text form. Binary files do not have additional data, such as keywords and key phrases, indentations, blank lines and separated definitions of referenced elements. But just like text files, keep comments of elements.

Binary configuration files are intended for closed configurations, not giving the user to easy modification, putting to the foreground the speed of loading files and saving the trees to the files.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idBinaryForm)

## Data types

In binary files are stored data of four types - 1-byte and 4-bytes unsigned integers, logical values and strings:

```
data type    size    for writing

uint8        1       format version components
uint32       4       elements count, length of values, comments and identifiers
boolean      1       reference states

string:
  uint32     4       length of string
  string     n       content of string
```

If the string is multiline, its individual substrings are separated by characters `0x0A`.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idDataTypesAndFormat)

## Static data

The static informations includes the file signature, name of the tree and main comment, as well as the count of elements, included in the root node.

The structure schema of the binary file, containing the **empty tree** (without any elements):

```
size    value             data type    component         description

14      TREESTRUCTINFO    string       file signature    format name

1       2                 uint8        format version    major version
1       0                 uint8        format version    minor version

4       0                 uint32       tree name         tree name length
4       0                 uint32       tree comment      tree comment length

4       0                 uint32       root node         attributes count
4       0                 uint32       root node         chlid nodes count
```

Binary file containing empty configuration tree, should always take exactly `32 bytes`.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idStaticData)

## Dynamic data

For a set of dynamic informations includes descriptions of the tree elements, such as standard and referenced **attributes**, and standard and referenced **child nodes**.

Each element is represented by another sequence of bytes, by virtue of having different and varying amounts of information.

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idDynamicData)

**The structure schema of writing a single attribute**:

```
size    value         data type    component              description

1       True/False    boolean      reference state        state

4       n             uint32       identifier             identifier length
n       n bytes       string       identifier             identifier value

4       n             uint32       value                  value length
n       n bytes       string       value                  value content

4       n             uint32       declaration comment    comment length
n       n bytes       string       declaration comment    comment value

4       n             uint32       definition comment     comment length
n       n bytes       string       definition comment     comment value
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idDynamicAttributes)

**The structure schema of writing a single child node**:

```
size     value        data type     component             description

1        True/False   boolean       reference state       state

4        n            uint32        identifier            identifier length
n        n bytes      string        identifier            identifier value

4        n            uint32        declaration comment   comment length
n        n bytes      string        declaration comment   comment value

4        n            uint32        definition comment    comment length
n        n bytes      string        definition comment    comment value

4        n            uint32        attributes            attributes count
         ...          ...           attributes            attributes bodies

4        n            uint32        child nodes           child nodes count
         ...          ...           child nodes           child nodes bodies
```

`pl` [read more...](http://treestruct.info/pl/format/2.0.htm#idDynamicNodes)

# Bindings

Below is a list of all available libraries to handle the **TreeStructInfo** configuration files:

- **Free Pascal** - from latest release, [source](https://github.com/furious-programming/TreeStructInfo/releases/download/v2.0.0.-rc.1/Source.zip) for **FPC** and [package](https://github.com/furious-programming/TreeStructInfo/releases/download/v2.0.0.-rc.1/Package.zip) for **Lazarus**
- [**C++**](https://github.com/spartanPAGE/spartsi) - here you can track the formation process of Patryk Wertka's TSI api implementation

No API available in your favorite language? Create and publish your own!

# TreeStructInfo project support

- Bartosz Wójcik - [PELock Software Protection](http://www.pelock.com)

Thanks to the other, not mentioned persons in the above list.
