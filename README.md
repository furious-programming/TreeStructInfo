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

The default size of a single indentation is two space characters (`0x20`).
