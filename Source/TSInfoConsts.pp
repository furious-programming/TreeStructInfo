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
  HIGHEST_SUPPORTED_FORMAT_VERSION  = Single(1.0);
  INDENT_SIZE                       = Integer(2);
  MAX_STREAM_SIZE                   = Integer(2048);
  MAX_BUFFER_SIZE                   = Integer(2048);
  END_TREE_REF_INDEX                = Integer($BADFACE);
  DECLARATION_COMMENT_MARKER        = Integer($DEC);
  DEFINITION_COMMENT_MARKER         = Integer($DEF);

const
  IDENTS_DELIMITER          = UTF8Char('\');
  VALUES_DELIMITER          = UTF8Char(#10);
  QUOTE_CHAR                = UTF8Char('"');
  INDENT_CHAR               = UTF8Char(#32);
  COORDS_DELIMITER          = UTF8Char(',');
  ONE_BLANK_VALUE_LINE_CHAR = UTF8Char(#9);
  CURRENT_NODE_SYMBOL       = UTF8Char('~');

const
  BINARY_FILE_SIGNATURE       = UTF8String('tsinfo');
  TREE_HEADER_SIGNATURE       = UTF8String('tsinfo ');
  TREE_HEADER_VERSION_KEYWORD = UTF8String('version');
  TREE_HEADER_VERSION         = UTF8String('1.0');
  TREE_HEADER_NAME_KEYWORD    = UTF8String('name');
  END_TREE_KEYWORD            = UTF8String('end tree');
  ATTRIBUTE_KEYWORD           = UTF8String('attr ');
  NODE_KEYWORD                = UTF8String('node ');
  END_NODE_KEYWORD            = UTF8String('end');
  REF_KEYWORD                 = UTF8String('ref');
  REF_ATTRIBUTE_KEYWORD       = UTF8String(REF_KEYWORD + #32 + ATTRIBUTE_KEYWORD);
  REF_NODE_KEYWORD            = UTF8String(REF_KEYWORD + #32 + NODE_KEYWORD);
  END_REF_NODE_KEYWORD        = UTF8String(END_NODE_KEYWORD + #32 + REF_KEYWORD);
  LINK_KEYWORD                = UTF8String('link ');
  LINK_AS_KEYWORD             = UTF8String('as');
  LINK_FLAGS_KEYWORD          = UTF8String('flags');
  COMMENT_PREFIX              = UTF8String('::');

const
  FLAG_TEXT_FILE   = UTF8String('text');
  FLAG_BINARY_FILE = UTF8String('binary');
  FLAG_READ        = UTF8String('read');
  FLAG_WRITE       = UTF8String('write');

const
  BINARY_FILE_SIGNATURE_LEN       = Length(BINARY_FILE_SIGNATURE);
  TREE_HEADER_SIGNATURE_LEN       = Length(TREE_HEADER_SIGNATURE);
  TREE_HEADER_VERSION_KEYWORD_LEN = Length(TREE_HEADER_VERSION_KEYWORD);
  ATTRIBUTE_KEYWORD_LEN           = Length(ATTRIBUTE_KEYWORD);
  NODE_KEYWORD_LEN                = Length(NODE_KEYWORD);
  REF_ATTRIBUTE_KEYWORD_LEN       = Length(REF_ATTRIBUTE_KEYWORD);
  REF_NODE_KEYWORD_LEN            = Length(REF_NODE_KEYWORD);
  LINK_KEYWORD_LEN                = Length(LINK_KEYWORD);
  LINK_AS_KEYWORD_LEN             = Length(LINK_AS_KEYWORD);
  COMMENT_PREFIX_LEN              = Length(COMMENT_PREFIX);

const
  MIN_TREE_HEADER_LINE_LEN       = Integer(TREE_HEADER_SIGNATURE_LEN + TREE_HEADER_VERSION_KEYWORD_LEN + 3);
  MIN_ATTRIBUTE_LINE_LEN         = Integer(ATTRIBUTE_KEYWORD_LEN + 3);
  MIN_ATTRIBUTE_VALUE_LINE_LEN   = Integer(2);
  MIN_NODE_LINE_LEN              = Integer(NODE_KEYWORD_LEN + 1);
  MIN_REF_ATTRIBUTE_DEC_LINE_LEN = Integer(REF_ATTRIBUTE_KEYWORD_LEN + 1);
  MIN_REF_ATTRIBUTE_DEF_LINE_LEN = Integer(REF_ATTRIBUTE_KEYWORD_LEN + 3);
  MIN_REF_NODE_LINE_LEN          = Integer(REF_NODE_KEYWORD_LEN + 1);
  MIN_LINK_LINE_LEN              = Integer(LINK_KEYWORD_LEN + LINK_AS_KEYWORD_LEN + 6);
  MIN_POINT_LINE_LEN             = Integer(3);

const
  RENAMING_STEP_NUMERICAL_EQUIVALENTS: array [TRenamingDirection] of Integer = (1, -1);

const
  INVALID_IDENT_CHARS: set of UTF8Char = [#0 .. #31, #127, #192, #193, #245 .. #255, IDENTS_DELIMITER, QUOTE_CHAR];
  CONTROL_CHARS:       set of UTF8Char = [#0 .. #32];
  UNSAFE_CHARS:        set of UTF8Char = [#0 .. #31, #127, #192, #193, #245 .. #255];


{ ----- constants for data converting ----------------------------------------------------------------------------- }


const
  BOOLEAN_VALUES: array [Boolean, TFormatBoolean] of UTF8String =
    (('False', 'No', 'Off', 'F', 'N', '0'), ('True', 'Yes', 'On', 'T', 'Y', '1'));

const
  INTEGER_UNIVERSAL_SYSTEM_PREFIXES: array [TFormatInteger] of UTF8String = ('', '', '0x', '0o', '0b');
  INTEGER_PASCAL_SYSTEM_PREFIXES:    array [TFormatInteger] of UTF8Char = (#0, #0, '$', '&', '%');
  INTEGER_MIN_LENGTHS:               array [TFormatInteger] of UInt32 = (0, 0, 2, 2, 4);

const
  FLOAT_FORMATS: array [TFormatFloat] of TFloatFormat =
    (TFloatFormat.ffGeneral, TFloatFormat.ffGeneral, TFloatFormat.ffExponent, TFloatFormat.ffExponent,
     TFloatFormat.ffNumber, TFloatFormat.ffNumber);

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
  POINT_SYSTEMS: array [TFormatPoint] of TFormatInteger =
    (fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary);

const
  BUFFER_SIZES: array [TFormatBuffer] of UInt32 = (8, 16, 32, 64);


{ ----- exception messages ---------------------------------------------------------------------------------------- }


const
  EM_EMPTY_IDENTIFIER                  = UTF8String('identifier cannot be empty');
  EM_INCORRECT_IDENTIFIER_CHARACTER    = UTF8String('identifier contains incorrect character "%s", code "%d"');
  EM_MISSING_TREE_HEADER               = UTF8String('tree header not found');
  EM_INVALID_TREE_HEADER               = UTF8String('"%s" is not a valid tree header');
  EM_UNKNOWN_TREE_HEADER_COMPONENT     = UTF8String('unknown tree header component "%s"');
  EM_INVALID_FORMAT_VERSION            = UTF8String('"%s" is not a valid format version');
  EM_UNSUPPORTED_FORMAT_VERSION        = UTF8String('format in version "%s" is not supported');
  EM_ROOT_NODE_RENAME                  = UTF8String('cannot set a root node name');
  EM_ROOT_NODE_REMOVE                  = UTF8String('cannot remove a root node');
  EM_ROOT_NODE_SET_COMMENT             = UTF8String('cannot set a root node comment');
  EM_ROOT_NODE_GET_COMMENT             = UTF8String('root node cannot have a comment');
  EM_ROOT_NODE_SET_REFERENCE           = UTF8String('cannot set a root node reference state');
  EM_ROOT_NODE_GET_REFERENCE           = UTF8String('root node cannot have a reference state');
  EM_ATTRIBUTE_NOT_EXISTS              = UTF8String('attribute "%s" not exists');
  EM_NODE_NOT_EXISTS                   = UTF8String('node "%s" not exists');
  EM_CANNOT_OPEN_NODE                  = UTF8String('cannot open a node under "%s" path');
  EM_MISSING_END_TREE_LINE             = UTF8String('end tree line not found');
  EM_READ_ONLY_MODE_VIOLATION          = UTF8String('cannot make modifications in read-only mode');
  EM_INVALID_STREAM_SIZE               = UTF8String('size of stream is too large (maximum acceptable: %d bytes)');
  EM_INVALID_BUFFER_SIZE               = UTF8String('size of buffer is too large (maximum acceptable: %d bytes)');
  EM_INVALID_SOURCE_LINE               = UTF8String('invalid source line: "%s"');
  EM_INVALID_BINARY_FILE               = UTF8String('invalid TreeStructInfo binary file');
  EM_UNSUPPORTED_BINARY_FORMAT_VERSION = UTF8String('format version "%.1f" is not supported');
  EM_INVALID_LINK_LINE                 = UTF8String('"%s" is not a valid link line');
  EM_EMPTY_LINK_FILE_NAME              = UTF8String('name of linked file cannot be an empty string');
  EM_UNKNOWN_LINK_COMPONENT            = UTF8String('unknown link component - expected "%s" but "%s" found');
  EM_UNKNOWN_LINK_FLAG                 = UTF8String('unknown link flag "%s"');
  EM_LINKED_FILE_NOT_EXISTS            = UTF8String('link under path "%s" with virtual node name "%s" not exists');
  EM_ELEMENTS_LIST_MEMORY_ALLOCATION   = UTF8String('cannot allocate memory for new elements list');


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

