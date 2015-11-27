![TreeStructInfo](http://treestruct.info/global/img/logo-small.png)<br/>
*Copyright © Jaroslaw Baran, furious programming 2011 - 2015*

Latest API release: [TreeStructInfo 2.0 beta](https://github.com/furious-programming/TreeStructInfo/releases/tag/v2.0.0-beta)<br/><br/>

This document is highly abbreviated version of the format specification. Full form of [official **TreeStructInfo 2.0** format specification](http://treestruct.info/pl/format/2.0.htm) is available on the [project website](http://treestruct.info) (unfortunately, for now only in Polish). [Detailed documentation of this API](http://treestruct.info/pl/api/official-2.0-freepas/index.htm) to handle the **TreeStructInfo** files and the [tutorial](http://treestruct.info/pl/api/official-2.0-freepas/tutorial/index.htm) are also available on the [project website](http://treestruct.info) (also only in Polish).

# Introduction

**TreeStructInfo** is a project of the universal format for text and binary configuration files, for storing settings of applications and games in the form of data trees. Allows to create a single-file configurations and complex configuration systems, consisting of many interrelated files.

Format is human-friendly - text files syntax is based on a small set of keywords and linear structure. Text form gives the possibility to create an open configurations. Binary form provides faster files processing, maintaining compatibility of native data in memory with a text form.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm)

# Sample file

I can not use my own syntax highlighting, so if you want to see the sample text file, go to the [**sample file** point in specification](http://treestruct.info/pl/format/1.0.htm#idSampleFile).

# Text files syntax

Text files are build in a linear manner - in every single line can be written only one information, such as the tree header or attribute declaration. Is allowed to insert any number of blank lines. Syntax is based on the following keywords:

```
tsinfo      - opens the header of the tree
version     - stands before the format version
name        - stands before the name of the tree
end tree    - closes the main body of the tree
attr        - opens the standard attribute declaration
node        - opens the standard node declaration
end         - ends the standard node body
link        - opens the link declaration
as          - stands before the virtual node name
flags       - stands before the set of linking flags
ref attr    - opens the referencing attribute declaration
ref node    - opens the referencing node declaration
end ref     - ends the referencing node body
```

Keywords can be made up only of lowercase letters. To describe the syntax of text configuration files used are also several strings:

```
"1.0"      - the value of the format version

"text"     - flag indicating the inclusion of a text file
"binary"   - flag indicating the inclusion of a binary file
"read"     - flag indication inclusion of the file for read only
"write"    - flag indicating inclusion of the file for read and write
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

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idTextFileSyntax)

# Identifiers

Identifiers are the names of the tree elements (the name of the tree is the identifier too). The minimum length of the identifier is one character, maximum length is not specified. Element names can not contain the following characters:

```
#0 .. #31    - set of control characters
\            - reserved for the paths to the elements
"            - quote character opens and closes the values
```

other characters are allowed (`0x20` too). Identifiers are case-sensitive.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idIdentifiers)

# Frame of tree

The body of the tree opens the line containing the specified header. The basic form of the header looks like this:

```
tsinfo version "1.0"
```

line must contain the keyword `tsinfo`, then the keyword `version`, and the value of the format version. Extended version of the header further includes a keyword `name` and value of the tree name:

```
tsinfo version "1.0" name "Tree Name"
```

Main body of the tree closes the line containing the following key phrase:

```
end tree
```

So text file content with empty tree should look like this:

```
tsinfo version "1.0"
end tree
```

or this:

```
tsinfo version "1.0" name "Tree Name"
end tree
```

All standard elements must be declared between these lines.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idFrameOfTree)

# Basic tree elements

The basic elements are standard and referencing **attributes**, for storing specific data, standard and referencing **child nodes**, to group elements and create a tree structure, and **links to the linked files**, that allow for addition of trees from other (text or binary) configuration files.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idBasicElements)

# Attributes

Attributes are used to store data. Divided into **standard attributes**, that have the declaration and definition in the same place in the tree, and **referencing attributes**, that are defined outside of the main body of the tree.

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

Attribute value con also contain blank lines at the beginning, in the middle or at the end:

```
attr Name ""
          "second line"
          ""
          "fourth line"
          ""
```

Attributes can store data in multiple types, written in many different ways. In addition to simple types, attributes can also contain binary data, written as a strings of hexadecimal characters.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idAttributes)

## Booleans

Boolean values are determined using conventional strings:

```
"True"     "Yes"    "On"     "T"    "Y"    "1"    - true values
"False"    "No"     "Off"    "F"    "N"    "0"    - false values
```

PascalCase for string values is not mandatory (uppercase for character values too). Digits `1` and `0` are the only permitted.

## Integers

Integers can be written in the four most popular numeral systems - decimal, hexadecimal, octal and binary, and can be positive and negative. Prefixes for the numbers in numeral systems other than decimal is `0x` for hexadecimal, `0o` for octal and `0b` for binary.

A positive, negative and zero numbers written in all systems:

```
"64206" or "+64206"
"0xFACE"
"0o175316"
"0b1111101011001110"

"-2989"
"0xFFFFF453"
"0o37777772123"
"0b11111111111111111111010001010011"

"0"
"0x00"
"0o00"
"0b0000"
```

## Floating-point numbers

Floating-point numbers can be written in universal or scientific form. May have a leading characters `+` or `-`. A positive, negative and zero numbers written in both forms:

```
"1009,1989" or "+1009,1989"
"1 009,1989000000"
"1,00919890000000E+0003"

"-1009,1989"
"-1 009,1989000000"
"-1,00919890000000E+0003"

"0" or "0,0000000000"
"0,00000000000000E+0000"
```

Decimal and thousand separators may be other, suitable according to your location.

There is also possibility to store special numbers as strings - positive or negative infinity and NaN:

```
"Inf" or "+Inf"    - positive infinity
"-Inf"             - negative infinity
"Nan"              - not a number
```

PascalCase for these strings is not mandatory.

## Currencies

Currency values have separate format - first, there is a number, followed by the currency string (is optional). Precision is arbitrary, but not more than four digits. Currency values also can contain leading character `+` or `-`.

Format of sample numbers below:

```
"5$"      or "+5$"
"5,25$"   or "+5,25$"
"5,2578$" or "+5,2578$"

"-5$"
"-5,25$"
"-5,2578$"

"0$"
"0,00$"
"0,0000$"
```

Of course, the currency string and the currency separator may be different.

## Strings

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

## Dates and times

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
"07:20 PM"
```

date and time together in one value:

```
"24-10-2011 19:20"
"24 October 2011, 19:20"
"October, 24-10-2011 (19:20)"
"October, 24 Oct 2011 (07:20 PM)"
```

and example with plain text substrings:

```
"today is Monday, 24-10-2011, time 19:20"
```

Text values of date and time components, such as the names of days and months, symbols and names of the seasons of the day (`am`, `pm`), as well as the date and time components separators are dependent on the location, so can take other characters or strings than those listed.

## Point coordinates

Rules for the transcription the coordinates of the points are the same as in the case of integers - coordinates can be written in one of the four numeral systems. Point coordinates separator is a comma.

Examples of writing positive, negative and zero coordinates below:

```
"72,114" or "+72,+114"
"0x48,0x72"
"0o110,0o162"
"0b1001000,0b1110010"

"-72,-114"
"0xFFFFFFB8,0xFFFFFF8E"
"0o37777777670,0o37777777616"
"0b11111111111111111111111110111000,0b11111111111111111111111110001110"

"0,0"
"0x00,0x00"
"0o00,0o00"
"0b0000,0b0000"
```

Both the coordinates should be written in the same numeral system (but is not a hard rule).

## Binary data

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

## Multiline values

Each multiline values have a one, universal form of writing. The issue of data types that can be written in the form of multiline values is open, depends mainly on programming languages. Thus, this type of values can be of any data, but written in a specific form, from which there are no exceptions.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idAttrValuesDataTypes)


# Child nodes

The nodes are used to group elements and creating tree structure. Also divided into **standard nodes**, that have the declaration and definition in the same place, and **referencing nodes**, that are defined outside of the tree body.

The body of the standard child node opens the line containing the keyword `node` and the name of the node:

```
node Name
```

and closes the line with only the keyword `end`:

```
end
```

The body of the empty child node looks like the following:

```
node Name
end
```

For a given node are those elements, that are defined between the header line and the end line.

# Links

Links are elements used for including trees from another files. Linked files can be text or binary. Line with link declaration can exist in two forms - basic and full. The basic link declaration line must contain the keyword `link`, then the name or path to linked file, keyword `as` and then the name of virtual node:

```
link "File.ext" as "Virtual Node Name"
```

File name/path and the virtual node name are the values, so they must be covered by quotation marks.

The full version of link declaration can also contain the keyword `flags`, and then the flag values. If the file must be included only for reading - no flags is required.

Example for linking the text file in read only mode:

```
link "C:\Linked.tsinfo" as "Linked"
link "C:\Linked.tsinfo" as "Linked" flags ""
link "C:\Linked.tsinfo" as "Linked" flags "text" "read"
```

linking the text file in read and write mode:
 
```
link "C:\Linked.tsinfo" as "Linked" flags "text" "write"
```

linking the binary file in read only mode:

```
link "C:\Linked.tsibin" as "Linked" flags "binary"
link "C:\Linked.tsibin" as "Linked" flags "binary" "read"
```

and linking the binary file in read and write mode:

```
link "C:\Linked.tsibin" as "Linked" flags "binary" "write"
```

Flags are the values too. If you want to type a path of linked file - you can use the relative or absolute path.

**Important:** the paths are used to locate the file based on the location of the executable file.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idLinks)

# Referencing elements

Referencing elements serve exactly the same purpose as standard elements. What makes them different is the method of writing - every such element has its own **declaration**, specifying its place in the tree, as well as its **definition**, including its proper body.

Referencing form may have attributes and child nodes.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idRefElements)

# Referencing attributes

The main advantage of using referencing attributes is to increase the readability of the configuration files in text form, by separating their definition beyond the main body of the tree.

The line with the declaration of referencing attribute must contain only the key phrase `ref attr` and the name of the attribute:

```
ref attr Name
```

The attribute declaration may be located inside the main body of the tree, as well as inside the body of the referencing child node.

The definition must contain the same key phrase `ref attr`, the same name as in the declaration and the value:

```
ref attr Name "Value"
```

The definition of the referencing attribute must be located outside the main body of the tree and outside the body of the referencing child node.

Example:

```
tsinfo version "1.0"
  ref attr Foo
end tree

ref attr Foo "Value"
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idRefAttributes)

# Referencing child nodes

Like the referencing attributes, referencing child nodes also have their **declarations** and **definitions**.

The line with referencing child node declaration must contain only the key phrase `ref node` and the name of the node:

```
ref node Name
```

The definition must contain a complete body of the node, terminated with the line with key phrase `end ref`:

```
ref node Name
end ref
```

Declaration of the referencing child node may be located inside the main body of the tree or inside the body of the referencing node, but the definition must be outside them.

Example:

```
tsinfo version "1.0"
  ref node Bald
end tree

ref node Bald
end ref
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idRefNodes)

## The order of referencing elements definitions

The order of writing the definition of referencing elements its recursive, regardless of whether the element is standard or referencing, the content is immediately considered.

Short example:

```
tsinfo version "1.0"
  ref attr Integer
  ref node First
  ref node Third
end tree

ref attr Integer "0xFACE"

ref node First
  ref attr Float
  ref attr Currency
  ref node Second
end ref

ref attr Float "3,14"
ref attr Currency "5,25$"

ref node Second
  ref attr Point
end ref

ref attr Point "0o00,0o00"

ref node Third
end ref
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idOrderOfDefRefElements)

# Comments

Comments are not elements of trees - are additional informations, always belonging to the elements. Each element of the tree (**attribute**, **child node** or **link**) may have a comment, single-line or multiline. The tree may also have a comment - in this case, it is always written at the beginning of the file, before the main body of the tree.

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

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idComments)

# Tree comment

If the tree has a main comment, it must be written before his body:

```
:: main tree comment

tsinfo version "1.0"
end tree
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idTreeComment)

# Attributes comments

Each attribute can have a comment. It must be written directly above his declaration:

```
tsinfo version "1.0"
  :: attribute comment
  attr Name "Value"
end tree
```

Referencing attributes can have two comments - declaration comment and definition comment:

```
tsinfo version "1.0"
  :: attribute declaration comment
  ref attr Name
end tree

:: attribute definition comment
ref attr Name "Value" 
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idAttrsComments)

# Child nodes comments

Standard child nodes can have one comment:

```
tsinfo version "1.0"
  :: child node comment
  node Name
  end
end tree
```

and the referencing nodes can have two:

```
tsinfo version "1.0"
  :: child node declaration comment
  ref node Name
end tree

:: child node definition comment
ref node Name
end ref
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idNodesComments)

# Links comments

Links can have only one comment:

```
tsinfo version "1.0"
  :: link comment
  link "File.ext" as "Virtual Node Name"
end tree
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idLinksComments)

# Binary form

The binary form of configuration files has been designed so that the loading and saving files were much faster than the loading and saving the files in text form. Binary files do not have additional data, such as keywords and key phrases, indents, blank lines and separated definitions of referencing elements. But just like text files, keep comments of elements.

Binary configuration files are intended for closed configurations, not giving the user to easy modification, putting to the foreground the speed of loading files and saving the trees to the files.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idBinaryForm)

# Data types

To binary files are stored are written data of four types - floating-point numbers and integers, logical values and strings:

```
data type     size     for writting

single        4        format version in file signature
uint32        4        elements count; values, comments and identifiers length
boolean       1        referencing states, flags existing state

string:
  uint32      4        length of string
  string      n        content of string
```

If the string is multiline, its individual substrings are separated by characters `0x0A`.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idDataTypesAndFormat)

# Static data

The static informations includes the file signature, comment and the name of the tree, as well as informations relating to the root node of the tree.

The structure schema of the binary file, containing the **empty tree**:

```
size     value     data type     component        description

6        tsinfo    string        file signature   format name
4        1.0       single        file signature   format version

4        0         uint32        tree             main comment length
4        0         uint32        tree             tree name length

4        0         uint32        root node        declaration comment length
4        0         uint32        root node        definition comment length
1        False     boolean       root node        referencing state
4        0         uint32        root node        identifier length
4        0         uint32        root node        attributes count
4        0         uint32        root node        child nodes count
4        0         uint32        root node        links count
```

Binary file containing empty configuration tree, should always take exactly `43 bytes`.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idStaticData)

# Dynamic data

For a set of dynamic informations includes descriptions of the tree elements, such as standard and referencing **attributes**, standard and referencing **child nodes** and **links**.

Each element is represented by another sequence of bytes, by virtue of having different and varying amounts of information.

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idDynamicData)

**The structure schema of writing a single attribute**:

```
size     value        data type     component             description

4        n            uint32        declaration comment   comment length
n        n chars      string        declaration comment   comment value

4        n            uint32        definition comment    comment length
n        n chars      string        definition comment    comment value

1        True/False   boolean       referencing state     state

4        n            uint32        identifier            identifier length
n        n chars      string        identifier            identifier value

4        n            uint32        value                 value length
n        n chars      string        value                 value content
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idDynamicAttributes)

**The structure schema of writing a single child node**:

```
size     value        data type     component             description

4        n            uint32        declaration comment   comment length
n        n chars      string        declaration comment   comment value

4        n            uint32        definition comment    comment length
n        n chars      string        definition comment    comment value

1        True/False   boolean       referencing state     state

4        n            uint32        identifier            identifier length
n        n chars      string        identifier            identifier value

4        n            uint32        attributes            attributes count
         ...          ...           attributes            attributes bodies

4        n            uint32        child nodes           child nodes count
         ...          ...           child nodes           child nodes bodies

4        n            uint32        links                 links bodies
         ...          ...           links                 links bodies
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idDynamicNodes)

**The structure schema of writing a single link**:

```
size     value        data type     component             description

4        n            uint32        declaration comment   comment length
n        n chars      string        declaration comment   comment value

4        n            uint32        linked file name      file name length
n        n chars      string        linked file name      file name value

4        n            uint32        virtual node name     name length
n        n chars      string        virtual node name     name value

1        True/False   boolean       "binary" flag         flag existing state
1        True/False   boolean       "write" flag          flag existing state
```

`pl` [read more...](http://treestruct.info/pl/format/1.0.htm#idDynamicLinks)

# Bindings

Below is a list of all available libraries to handle the **TreeStructInfo** configuration files:

- **Object Pascal** - in this repo are [source](https://github.com/furious-programming/TreeStructInfo/tree/master/Source) and [package](https://github.com/furious-programming/TreeStructInfo/tree/master/Package) for **Lazarus**
- [**C++**](https://github.com/spartanPAGE/TreeStructInfo) - [**Here**](https://github.com/spartanPAGE/TreeStructInfo.Test) you can track the formation process of Patryk Wertka's TSI api implementation

No API available in your favorite language? Create and publish your own!

## TreeStructInfo project support

- Bartosz Wójcik - [PELock Software Protection](http://www.pelock.com)

Thanks to the other, not mentioned persons in the above list.
