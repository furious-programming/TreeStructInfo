![TreeStructInfo](http://treestruct.info/global/img/logo-small.png)<br/>
*Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014*

Latest API release: [TreeStructInfo 1.0 stable](https://github.com/furious-programming/TreeStructInfo/releases/tag/v1.0.0-stable)<br/><br/>

This document is highly abbreviated version of the format specification. Full form of [official **TreeStructInfo 1.0** format specification](http://treestruct.info/pl/format/1.0.htm) is available on the [project website](http://treestruct.info) (unfortunately, for now only in Polish).

[Detailed documentation of this API](http://treestruct.info/pl/api/official-1.0-objpas/index.htm) to handle the **TreeStructInfo** files and the [tutorial](http://treestruct.info/pl/api/official-1.0-objpas/tutorial/index.htm) are also available on the [project website](http://treestruct.info) (also only in Polish).<br/><br/>

**Be warned** - contents of this file will be longer.

# Introduction

**TreeStructInfo** is a project of the universal format for text and binary configuration files, for storing settings of applications and games in the form of data trees. Allows to create a single-file configurations and complex configuration systems, consisting of many interrelated files.

Format is human-friendly - text files syntax is based on a small set of keywords and linear structure. Text form gives the possibility to create an open configurations. Binary form provides faster files processing, maintaining compatibility of native data in memory with a text form.

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
&attr       - opens the referencing attribute declaration
&node       - opens the referencing node declaration
&end        - ends the referencing node body
```

Keywords can be made up only of lowercase letters. To describe the syntax of text configuration files used are also several strings:

```
"1.0"          - the value of the format version
"updatable"    - flag indicating inclusion of the file for read and write
"binary"       - flag indicating the inclusion of a binary file
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

# Identifiers

Identifiers are the names of the tree elements (the name of the tree is the identifier too). The minimum length of the identifier is one character, maximum length is not specified. Element names can not contain the following characters:

```
#0 .. #31    - set of control characters
\            - reserved for the paths to the elements
"            - quote character opens and closes the values
```

other characters are allowed (`0x20` too). Identifiers are case-sensitive.

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

# Basic tree elements

The basic elements are standard and referencing **attributes**, for storing specific data, standard and referencing **child nodes**, to group elements and create a tree structure, and **links to the linked files**, that allow for addition of trees from other (text or binary) configuration files.

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

## Data types

Attributes can store data in multiple types, written in many different ways. In addition to simple types, attributes can also contain binary data, written as a strings of hexadecimal characters.

### Booleans

Boolean values are determined using conventional strings:

```
"True"     "Yes"    "On"     "T"    "Y"    "1"    - true values
"False"    "No"     "Off"    "F"    "N"    "0"    - false values
```

Camel style for string values is not mandatory (uppercase for character values too). Digits `1` and `0` are the only permitted.

### Integers

Integers can be written in the four most popular numerical systems - decimal, hexadecimal, octal and binary, and can be positive and negative. Prefixes for the numbers in numerical systems other than decimal is `0x` for hexadecimal, `0o` for octal and `0b` for binary.

A positive, negative and zero numbers written in all systems:

```
"64206" (or "+64206")
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

### Floating-point numbers

Floating-point numbers can be written in universal or scientific form. May have a leading characters `+` or `-`. A positive, negative and zero numbers written in both forms:

```
"1009,1989" (or "+1009,1989")
"1 009,1989000000"
"1,00919890000000E+0003"

"-1009,1989"
"-1 009,1989000000"
"-1,00919890000000E+0003"

"0" (or "0,0000000000")
"0,00000000000000E+0000"
```

Decimal and thousand separators may be other, suitable according to your location.

There is also possibility to store special numbers as strings - positive or negative infinity and NaN:

```
"Inf" (or "+Inf")    - positive infinity
"-Inf"               - negative infinity
"Nan"                - not a number
```

Camel style for these strings is not mandatory.

### Currencies

Currency values have separate format - first, there is a number, followed by the currency string (is optional). Precision is arbitrary, but not more than four digits.

Format of sample numbers below:

```
5$
5,25$
5,2578$

-5$
-5,25$
-5,2578$

0$
0,00$
0,0000$
```

Of course, the currency string may be different.