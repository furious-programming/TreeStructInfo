{

    TSInfoConsts.pp               last modified: 27 December 2014

    Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Includes the constants for files processing, functions and procedures
    to data converting and throwing the exceptions procedure. The following
    constants are common for the entire library.
   __________________________________________________________________________

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
   __________________________________________________________________________

}


unit TSInfoConsts;

{$MODE OBJFPC}{$LONGSTRINGS ON}{$HINTS ON}


interface

uses
  TSInfoTypes,
  SysUtils;


{ ----- constants for files processing ---------------------------------------------------------------------------- }


const
  SUPPORTED_FORMAT_VERSION_MAJOR = UInt8(2);
  SUPPORTED_FORMAT_VERSION_MINOR = UInt8(0);

const
  INDENT_SIZE     = Integer(2);
  MAX_STREAM_SIZE = Integer(2048);
  MAX_BUFFER_SIZE = Integer(2048);

const
  IDENTS_DELIMITER          = UTF8Char('\');
  VALUES_DELIMITER          = UTF8Char(#10);
  QUOTE_CHAR                = UTF8Char('"');
  INDENT_CHAR               = UTF8Char(#32);
  COORDS_DELIMITER          = UTF8Char(',');
  ONE_BLANK_VALUE_LINE_CHAR = UTF8Char(#9);
  CURRENT_NODE_SYMBOL       = UTF8Char('~');

const
  BINARY_FILE_SIGNATURE      = UTF8String('TREESTRUCTINFO');
  TREE_HEADER_FORMAT_NAME    = UTF8String('treestructinfo');
  TREE_HEADER_FORMAT_VERSION = UTF8String('2.0');
  KEYWORD_TREE_NAME          = UTF8String('name');
  KEYWORD_TREE_END           = UTF8String('end tree');
  KEYWORD_STD_ATTRIBUTE      = UTF8String('attr ');
  KEYWORD_STD_NODE           = UTF8String('node ');
  KEYWORD_STD_NODE_END       = UTF8String('end node');
  KEYWORD_REF_ATTRIBUTE      = UTF8String('ref attr ');
  KEYWORD_REF_NODE           = UTF8String('ref node ');
  KEYWORD_REF_NODE_END       = UTF8String('end ref node');
  KEYWORD_LINK               = UTF8String('tree');
  KEYWORD_LINK_AS_NODE       = UTF8String('as node');
  KEYWORD_LINK_IN_MODE       = UTF8String('in mode');
  COMMENT_PREFIX             = UTF8String('::');

const
  LINKING_MODE_TEXT_TREE    = UTF8String('text');
  LINKING_MODE_BINARY_TREE  = UTF8String('binary');
  LINKING_MODE_ACCESS_READ  = UTF8String('read');
  LINKING_MODE_ACCESS_WRITE = UTF8String('write');

const
  BINARY_FILE_SIGNATURE_LEN      = Length(BINARY_FILE_SIGNATURE);
  TREE_HEADER_FORMAT_NAME_LEN    = Length(TREE_HEADER_FORMAT_NAME);
  TREE_HEADER_FORMAT_VERSION_LEN = Length(TREE_HEADER_FORMAT_VERSION);
  COMMENT_PREFIX_LEN             = Length(COMMENT_PREFIX);
  KEYWORD_TREE_END_LEN           = Length(KEYWORD_TREE_END);
  KEYWORD_STD_ATTRIBUTE_LEN      = Length(KEYWORD_STD_ATTRIBUTE);
  KEYWORD_STD_NODE_LEN           = Length(KEYWORD_STD_NODE);
  KEYWORD_STD_NODE_END_LEN       = Length(KEYWORD_STD_NODE_END);
  KEYWORD_REF_ATTRIBUTE_LEN      = Length(KEYWORD_REF_ATTRIBUTE);
  KEYWORD_REF_NODE_LEN           = Length(KEYWORD_REF_NODE);
  KEYWORD_REF_NODE_END_LEN       = Length(KEYWORD_REF_NODE_END);
  KEYWORD_LINK_LEN               = Length(KEYWORD_LINK);
  KEYWORD_LINK_AS_NODE_LEN       = Length(KEYWORD_LINK_AS_NODE);

const
  MIN_TREE_HEADER_LINE_LEN       = TREE_HEADER_FORMAT_NAME_LEN + 1 + TREE_HEADER_FORMAT_VERSION_LEN + 1;
  MIN_STD_ATTRIBUTE_LINE_LEN     = KEYWORD_STD_ATTRIBUTE_LEN + 3;
  MIN_STD_NODE_LINE_LEN          = KEYWORD_STD_NODE_LEN + 1;
  MIN_REF_ATTRIBUTE_DEC_LINE_LEN = KEYWORD_REF_ATTRIBUTE_LEN + 1;
  MIN_REF_ATTRIBUTE_DEF_LINE_LEN = KEYWORD_REF_ATTRIBUTE_LEN + 3;
  MIN_REF_NODE_LINE_LEN          = KEYWORD_REF_NODE_LEN + 1;
  MIN_LINK_LINE_LEN              = KEYWORD_LINK_LEN + 3 + KEYWORD_LINK_AS_NODE_LEN + 3;
  MIN_ATTRIBUTE_VALUE_LINE_LEN   = Integer(2);
  MIN_POINT_VALUE_LEN            = Integer(3);
  MIN_NO_DECIMAL_VALUE_LEN       = Integer(3);

const
  LINK_COMPONENTS_COUNT_SHORT = Integer(4);
  LINK_COMPONENTS_COUNT_FULL  = Integer(6);

const
  LINK_COMPONENT_INDEX_FILE_NAME         = Integer(1);
  LINK_COMPONENT_INDEX_AS_NODE_KEYWORD   = Integer(2);
  LINK_COMPONENT_INDEX_VIRTUAL_NODE_NAME = Integer(3);
  LINK_COMPONENT_INDEX_IN_MODE_KEYWORD   = Integer(4);

const
  INVALID_IDENT_CHARS: set of UTF8Char = [#0 .. #31, #127, #192, #193, #245 .. #255, IDENTS_DELIMITER, QUOTE_CHAR];
  WHITESPACE_CHARS:    set of UTF8Char = [#9, #32];

const
  KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE: array [Boolean] of Integer = (
    KEYWORD_STD_ATTRIBUTE_LEN, KEYWORD_REF_ATTRIBUTE_LEN
  );

const
  KEYWORD_NODE_LEN_BY_REFERENCE: array [Boolean] of Integer = (
    KEYWORD_STD_NODE_LEN, KEYWORD_REF_NODE_LEN
  );

const
  LINKING_MODE_COMPONENTS: array [TLinkingMode] of UTF8String = (
    LINKING_MODE_TEXT_TREE, LINKING_MODE_BINARY_TREE, LINKING_MODE_ACCESS_READ, LINKING_MODE_ACCESS_WRITE
  );

const
  LINKING_MODE_TREE_MODES: array [TLinkingMode] of TTreeMode = (
    tmTextTree, tmBinaryTree, tmAccessRead, tmAccessWrite
  );

const
  RENAMING_STEP_NUMERICAL_EQUIVALENTS: array [TRenamingDirection] of Integer = (1, -1);


{ ----- constants for data convertion ----------------------------------------------------------------------------- }


const
  BOOLEAN_VALUES: array [Boolean, TFormatBoolean] of UTF8String = (
    ('False', 'No', 'Off', 'F', 'N', '0'),
    ('True', 'Yes', 'On', 'T', 'Y', '1')
  );

const
  INTEGER_UNIVERSAL_SYSTEM_PREFIXES: array [TFormatInteger] of UTF8String = (#0, #0, '0x', '0o', '0b');
  INTEGER_PASCAL_SYSTEM_PREFIXES:    array [TFormatInteger] of UTF8Char = (#0, #0, '$', '&', '%');
  INTEGER_MIN_LENGTHS:               array [TFormatInteger] of UInt32 = (0, 0, 2, 2, 4);

const
  FLOAT_FORMATS: array [TFormatFloat] of TFloatFormat = (
    TFloatFormat.ffGeneral, TFloatFormat.ffGeneral,
    TFloatFormat.ffExponent, TFloatFormat.ffExponent,
    TFloatFormat.ffNumber, TFloatFormat.ffNumber
  );

const
  UNSIGNED_INFINITY_VALUE = UTF8String('Inf');
  SIGNED_INFINITY_VALUE   = UTF8String('+Inf');
  NEGATIVE_INFINITY_VALUE = UTF8String('-Inf');
  NOT_A_NUMBER_VALUE      = UTF8String('Nan');

const
  DATE_TIME_FORMAT_CHARS:     set of UTF8Char = ['Y', 'M', 'D', 'H', 'N', 'S', 'Z', 'A'];
  DATE_TIME_SEPARATOR_CHARS:  set of UTF8Char = ['.', '-', '/', ':'];
  DATE_TIME_PLAIN_TEXT_CHARS: set of UTF8Char = ['''', '"'];

const
  POINT_SYSTEMS: array [TFormatPoint] of TFormatInteger = (
    fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary
  );


{ ----- exception messages ---------------------------------------------------------------------------------------- }


const
  EM_EMPTY_IDENTIFIER                    = UTF8String('identifier cannot be empty');
  EM_INCORRECT_IDENTIFIER_CHARACTER      = UTF8String('identifier contains incorrect character "%s", code "%d"');
  EM_MISSING_TREE_HEADER                 = UTF8String('tree header not found');
  EM_INVALID_TREE_HEADER_COMPONENT_COUNT = UTF8String('"%d" is not a valid tree header component count');
  EM_UNKNOWN_TREE_HEADER_COMPONENT       = UTF8String('unknown tree header component "%s"');
  EM_INVALID_FORMAT_VERSION              = UTF8String('"%s" is not a valid format version');
  EM_UNSUPPORTED_FORMAT_VERSION          = UTF8String('format in version "%s" is not supported');
  EM_ROOT_NODE_RENAME                    = UTF8String('cannot set a root node name');
  EM_ROOT_NODE_REMOVE                    = UTF8String('cannot remove a root node');
  EM_ROOT_NODE_SET_COMMENT               = UTF8String('cannot set a root node comment');
  EM_ROOT_NODE_GET_COMMENT               = UTF8String('root node cannot have a comment');
  EM_ROOT_NODE_SET_REFERENCE             = UTF8String('cannot set a root node reference state');
  EM_ROOT_NODE_GET_REFERENCE             = UTF8String('root node cannot have a reference state');
  EM_ROOT_NODE_GO_TO_PARENT              = UTF8String('cannot go to parent node of root node of main tree');
  EM_ATTRIBUTE_NOT_EXISTS                = UTF8String('attribute "%s" not exists');
  EM_NODE_NOT_EXISTS                     = UTF8String('node "%s" not exists');
  EM_LINK_NOT_EXISTS                     = UTF8String('link under path "%s" with virtual node name "%s" not exists');
  EM_CANNOT_OPEN_NODE                    = UTF8String('cannot open a node under "%s" path');
  EM_MISSING_END_TREE_LINE               = UTF8String('end tree line not found');
  EM_MISSING_REF_ATTR_DEFINITION         = UTF8String('definition of attribute "%s: not found');
  EM_MISSING_REF_NODE_DEFINITION         = UTF8String('definition of child node "%s" not found');
  EM_READ_ONLY_MODE_VIOLATION            = UTF8String('cannot make modifications in read-only mode');
  EM_INVALID_STREAM_SIZE                 = UTF8String('size of stream is too large (maximum acceptable: %d bytes)');
  EM_INVALID_BUFFER_SIZE                 = UTF8String('size of buffer is too large (maximum acceptable: %d bytes)');
  EM_INVALID_SOURCE_LINE                 = UTF8String('invalid source line: "%s"');
  EM_INVALID_BINARY_FILE                 = UTF8String('invalid TreeStructInfo binary file');
  EM_UNSUPPORTED_BINARY_FORMAT_VERSION   = UTF8String('format version "%d.%d" is not supported');
  EM_INVALID_LINK_LINE                   = UTF8String('"%s" is not a valid link line');
  EM_MISSING_LINKED_FILE_NAME            = UTF8String('missing linked file name in link declaration');
  EM_INVALID_LINK_COMPONENT              = UTF8String('invalid link component - expected "%s" but "%s" found');
  EM_EMPTY_LINK_FILE_NAME                = UTF8String('name of linked file is empty');
  EM_UNKNOWN_LINKING_MODE                = UTF8String('unknown linking mode "%s"');
  EM_LINKING_MODES_MUTUALLY_EXCLUSIVE    = UTF8String('linking file cannot be both text and binary');


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

