{

    TSInfoConsts.pp                   last modified: 16 July 2014

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

{$MODE OBJFPC} {$LONGSTRINGS ON} {$HINTS ON}


interface

uses
  TSInfoTypes, SysUtils;


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
  IDENTS_DELIMITER          = AnsiChar('\');
  VALUES_DELIMITER          = AnsiChar(#10);
  QUOTE_CHAR                = AnsiChar('"');
  INDENT_CHAR               = AnsiChar(#32);
  REFERENCE_CHAR            = AnsiChar('&');
  CHAR_PREFIX               = AnsiChar('#');
  COORDS_DELIMITER          = AnsiChar(',');
  ONE_BLANK_VALUE_LINE_CHAR = AnsiChar(#9);

const
  BINARY_FILE_SIGNATURE       = AnsiString('tsinfo');
  TREE_HEADER_SIGNATURE       = AnsiString('tsinfo ');
  TREE_HEADER_VERSION_KEYWORD = AnsiString('version');
  TREE_HEADER_VERSION         = AnsiString('1.0');
  TREE_HEADER_NAME_KEYWORD    = AnsiString('name');
  END_TREE_KEYWORD            = AnsiString('end tree');
  ATTRIBUTE_KEYWORD           = AnsiString('attr ');
  NODE_KEYWORD                = AnsiString('node ');
  END_NODE_KEYWORD            = AnsiString('end');
  REF_ATTRIBUTE_KEYWORD       = AnsiString(REFERENCE_CHAR + ATTRIBUTE_KEYWORD);
  REF_NODE_KEYWORD            = AnsiString(REFERENCE_CHAR + NODE_KEYWORD);
  END_REF_NODE_KEYWORD        = AnsiString(REFERENCE_CHAR + END_NODE_KEYWORD);
  LINK_KEYWORD                = AnsiString('link ');
  LINK_AS_KEYWORD             = AnsiString('as');
  LINK_FLAGS_KEYWORD          = AnsiString('flags');
  COMMENT_PREFIX              = AnsiString('::');

const
  FLAG_BINARY_FILE = AnsiString('binary');
  FLAG_UPDATABLE   = AnsiString('updatable');

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
  INVALID_IDENT_CHARS: set of AnsiChar = [#0 .. #31, #127, IDENTS_DELIMITER, QUOTE_CHAR];
  CONTROL_CHARS:       set of AnsiChar = [#0 .. #32];
  UNSAFE_CHARS:        set of AnsiChar = [#0 .. #31, #127, #255];


{ ----- constants for data converting ----------------------------------------------------------------------------- }


const
  BOOLEAN_VALUES: array [Boolean, TFormatBoolean] of AnsiString =
    (('False', 'No', 'Off', 'F', 'N', '0'), ('True', 'Yes', 'On', 'T', 'Y', '1'));

const
  INTEGER_UNIVERSAL_SYSTEM_PREFIXES: array [TFormatInteger] of AnsiString = ('', '', '0x', '0o', '0b');
  INTEGER_PASCAL_SYSTEM_PREFIXES:    array [TFormatInteger] of AnsiChar = (#0, #0, '$', '&', '%');
  INTEGER_MIN_LENGTHS:               array [TFormatInteger] of UInt32 = (0, 0, 2, 2, 4);

const
  FLOAT_FORMATS: array [TFormatFloat] of TFloatFormat =
    (TFloatFormat.ffGeneral, TFloatFormat.ffGeneral, TFloatFormat.ffExponent, TFloatFormat.ffExponent,
     TFloatFormat.ffNumber, TFloatFormat.ffNumber);

const
  UNSIGNED_INFINITY_VALUE = AnsiString('Inf');
  SIGNED_INFINITY_VALUE   = AnsiString('+Inf');
  NEGATIVE_INFINITY_VALUE = AnsiString('-Inf');
  NOT_A_NUMBER_VALUE      = AnsiString('Nan');

const
  CHARACTER_SYSTEMS: array [TFormatChar] of TFormatInteger =
    (fiUnsignedDecimal, fiUnsignedDecimal, fiHexadecimal, fiOctal, fiBinary);

const
  DATE_TIME_FORMAT_CHARS:     set of AnsiChar = ['Y', 'M', 'D', 'H', 'N', 'S', 'Z', 'A'];
  DATE_TIME_SEPARATOR_CHARS:  set of AnsiChar = ['.', '-', '/', ':'];
  DATE_TIME_PLAIN_TEXT_CHARS: set of AnsiChar = ['''', '"'];

const
  POINT_SYSTEMS: array [TFormatPoint] of TFormatInteger =
    (fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary);

const
  BUFFER_SIZES: array [TFormatBuffer] of UInt32 = (8, 16, 32, 64);


{ ----- exception messages ---------------------------------------------------------------------------------------- }


const
  EM_EMPTY_IDENTIFIER                  = AnsiString('identifier cannot be empty');
  EM_INCORRECT_IDENTIFIER_CHARACTER    = AnsiString('identifier contains incorrect character "%s", code "%d"');
  EM_MISSING_TREE_HEADER               = AnsiString('tree header not found');
  EM_INVALID_TREE_HEADER               = AnsiString('"%s" is not a valid tree header');
  EM_UNKNOWN_TREE_HEADER_COMPONENT     = AnsiString('unknown tree header component "%s"');
  EM_INVALID_FORMAT_VERSION            = AnsiString('"%s" is not a valid format version');
  EM_UNSUPPORTED_FORMAT_VERSION        = AnsiString('format in version "%s" is not supported');
  EM_ROOT_NODE_RENAME                  = AnsiString('cannot set a root node name');
  EM_ROOT_NODE_REMOVE                  = AnsiString('cannot remove a root node');
  EM_ROOT_NODE_SET_COMMENT             = AnsiString('cannot set a root node comment');
  EM_ROOT_NODE_GET_COMMENT             = AnsiString('root node cannot have a comment');
  EM_ROOT_NODE_SET_REFERENCE           = AnsiString('cannot set a root node reference state');
  EM_ROOT_NODE_GET_REFERENCE           = AnsiString('root node cannot have a reference state');
  EM_ATTRIBUTE_NOT_EXISTS              = AnsiString('attribute "%s" not exists');
  EM_NODE_NOT_EXISTS                   = AnsiString('node "%s" not exists');
  EM_CANNOT_OPEN_NODE                  = AnsiString('cannot open a node under "%s" path');
  EM_MISSING_END_TREE_LINE             = AnsiString('end tree line not found');
  EM_READ_ONLY_MODE_VIOLATION          = AnsiString('cannot make modifications in read-only mode');
  EM_INVALID_STREAM_SIZE               = AnsiString('size of stream is too large (maximum acceptable: %d bytes)');
  EM_INVALID_BUFFER_SIZE               = AnsiString('size of buffer is too large (maximum acceptable: %d bytes)');
  EM_INVALID_SOURCE_LINE               = AnsiString('invalid source line: "%s"');
  EM_INVALID_BINARY_FILE               = AnsiString('invalid TreeStructInfo binary file');
  EM_UNSUPPORTED_BINARY_FORMAT_VERSION = AnsiString('format version "%.1f" is not supported');
  EM_INVALID_LINK_LINE                 = AnsiString('"%s" is not a valid link line');
  EM_EMPTY_LINK_FILE_NAME              = AnsiString('name of linked file cannot be an empty string');
  EM_UNKNOWN_LINK_COMPONENT            = AnsiString('unknown link component - expected "%s" but "%s" found');
  EM_UNKNOWN_LINK_FLAG                 = AnsiString('unknown link flag "%s"');
  EM_LINKED_FILE_NOT_EXISTS            = AnsiString('link under path "%s" with virtual node name "%s" not exists');


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

