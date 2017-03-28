{

    TSInfoConsts.pp                last modified: 24 March 2017

    Copyright © Jarosław Baran, furious programming 2013 - 2017.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Includes the constants for files processing, functions and procedures
    to data converting and throwing the exceptions procedures. The following
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

{$MODE OBJFPC}{$LONGSTRINGS ON}


interface

uses
  TSInfoTypes, SysUtils;


{ ----- constants for files processing ---------------------------------------------------------------------------- }


const
  SUPPORTED_FORMAT_VERSION_MAJOR = UInt8(2);
  SUPPORTED_FORMAT_VERSION_MINOR = UInt8(0);

const
  INDENT_SIZE     = 2;
  MAX_STREAM_SIZE = 2048;
  MAX_BUFFER_SIZE = 2048;

const
  IDENTS_DELIMITER          = '\';
  VALUES_DELIMITER          = #10;
  QUOTE_CHAR                = '"';
  INDENT_CHAR               = #32;
  COORDS_DELIMITER          = ',';
  ONE_BLANK_VALUE_LINE_CHAR = #09;
  CURRENT_NODE_SYMBOL       = '~';

const
  BINARY_FILE_SIGNATURE      = 'TREESTRUCTINFO';
  TREE_HEADER_FORMAT_NAME    = 'treestructinfo';
  TREE_HEADER_FORMAT_VERSION = '2.0';
  KEYWORD_TREE_NAME          = 'name';
  KEYWORD_TREE_END           = 'end tree';
  KEYWORD_STD_ATTRIBUTE      = 'attr ';
  KEYWORD_STD_NODE           = 'node ';
  KEYWORD_STD_NODE_END       = 'end node';
  KEYWORD_REF_ATTRIBUTE      = 'ref attr ';
  KEYWORD_REF_NODE           = 'ref node ';
  KEYWORD_REF_NODE_END       = 'end ref node';
  COMMENT_PREFIX             = '::';

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

const
  MIN_TREE_HEADER_LINE_LEN       = TREE_HEADER_FORMAT_NAME_LEN + 1 + TREE_HEADER_FORMAT_VERSION_LEN + 1;
  MIN_STD_ATTRIBUTE_LINE_LEN     = KEYWORD_STD_ATTRIBUTE_LEN + 3;
  MIN_STD_NODE_LINE_LEN          = KEYWORD_STD_NODE_LEN + 1;
  MIN_REF_ATTRIBUTE_DEC_LINE_LEN = KEYWORD_REF_ATTRIBUTE_LEN + 1;
  MIN_REF_ATTRIBUTE_DEF_LINE_LEN = KEYWORD_REF_ATTRIBUTE_LEN + 3;
  MIN_REF_NODE_LINE_LEN          = KEYWORD_REF_NODE_LEN + 1;
  MIN_ATTRIBUTE_VALUE_LINE_LEN   = 2;
  MIN_POINT_VALUE_LEN            = 3;
  MIN_NO_DECIMAL_VALUE_LEN       = 3;

const
  INVALID_IDENT_CHARS: set of Char = [#0 .. #31, #127, #192, #193, #245 .. #255, IDENTS_DELIMITER, QUOTE_CHAR];
  WHITESPACE_CHARS:    set of Char = [#9, #32];

const
  NUMBER_CHARS:           set of Char = ['0' .. '9'];
  SMALL_LETTERS:          set of Char = ['a' .. 'z'];
  CAPITAL_LETTERS:        set of Char = ['A' .. 'Z'];
  HEX_LETTERS:            set of Char = ['A' .. 'F'];
  NUMERICAL_SYSTEM_CHARS: set of Char = ['x', 'o', 'b'];
  PLUS_MINUS_CHARS:       set of Char = ['+', '-'];

const
  KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE: array [Boolean] of Integer = (
    KEYWORD_STD_ATTRIBUTE_LEN, KEYWORD_REF_ATTRIBUTE_LEN
  );

const
  KEYWORD_NODE_LEN_BY_REFERENCE: array [Boolean] of Integer = (
    KEYWORD_STD_NODE_LEN, KEYWORD_REF_NODE_LEN
  );

const
  RENAMING_STEP_NUMERICAL_EQUIVALENTS: array [TRenamingDirection] of Integer = (1, -1);


{ ----- constants for data convertion ----------------------------------------------------------------------------- }


const
  BOOLEAN_VALUES: array [Boolean, TFormatBoolean] of String = (
    ('False', 'No', 'Off', 'F', 'N', '0'),
    ('True', 'Yes', 'On', 'T', 'Y', '1')
  );

const
  INTEGER_UNIVERSAL_SYSTEM_PREFIXES: array [TFormatInteger] of String = (#0, #0, '0x', '0o', '0b');
  INTEGER_PASCAL_SYSTEM_PREFIXES:    array [TFormatInteger] of Char   = (#0, #0, '$', '&', '%');
  INTEGER_MIN_LENGTHS:               array [TFormatInteger] of UInt32 = (0, 0, 2, 2, 4);

const
  FLOAT_FORMATS: array [TFormatFloat] of TFloatFormat = (
    TFloatFormat.ffGeneral, TFloatFormat.ffGeneral,
    TFloatFormat.ffExponent, TFloatFormat.ffExponent,
    TFloatFormat.ffNumber, TFloatFormat.ffNumber
  );

const
  UNSIGNED_INFINITY_VALUE = 'Inf';
  SIGNED_INFINITY_VALUE   = '+Inf';
  NEGATIVE_INFINITY_VALUE = '-Inf';
  NOT_A_NUMBER_VALUE      = 'Nan';

const
  DATE_TIME_FORMAT_CHARS:     set of Char = ['Y', 'M', 'D', 'H', 'N', 'S', 'Z', 'A'];
  DATE_TIME_SEPARATOR_CHARS:  set of Char = ['.', '-', '/', ':'];
  DATE_TIME_PLAIN_TEXT_CHARS: set of Char = ['''', '"'];

const
  POINT_SYSTEMS: array [TFormatPoint] of TFormatInteger = (
    fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary
  );


{ ----- exception messages ---------------------------------------------------------------------------------------- }


const
  EM_EMPTY_IDENTIFIER                    = 'identifier cannot be empty';
  EM_INCORRECT_IDENTIFIER_CHARACTER      = 'identifier contains incorrect character "%s", code "%d"';
  EM_MISSING_TREE_HEADER                 = 'tree header not found';
  EM_INVALID_TREE_HEADER_COMPONENT_COUNT = '"%d" is not a valid tree header component count';
  EM_UNKNOWN_TREE_HEADER_COMPONENT       = 'unknown tree header component "%s"';
  EM_INVALID_FORMAT_VERSION              = '"%s" is not a valid format version';
  EM_UNSUPPORTED_FORMAT_VERSION          = 'format in version "%s" is not supported';
  EM_ROOT_NODE_RENAME                    = 'cannot set a root node name';
  EM_ROOT_NODE_REMOVE                    = 'cannot remove a root node';
  EM_ROOT_NODE_SET_COMMENT               = 'cannot set a root node comment';
  EM_ROOT_NODE_GET_COMMENT               = 'root node cannot have a comment';
  EM_ROOT_NODE_SET_REFERENCE             = 'cannot set a root node reference state';
  EM_ROOT_NODE_GET_REFERENCE             = 'root node cannot have a reference state';
  EM_ROOT_NODE_GO_TO_PARENT              = 'cannot go to parent node of root node of main tree';
  EM_ATTRIBUTE_NOT_EXISTS                = 'attribute "%s" not exists';
  EM_NODE_NOT_EXISTS                     = 'node "%s" not exists';
  EM_CANNOT_OPEN_NODE                    = 'cannot open a node under "%s" path';
  EM_MISSING_END_TREE_LINE               = 'end tree line not found';
  EM_MISSING_REF_ATTR_DEFINITION         = 'definition of attribute "%s: not found';
  EM_MISSING_REF_NODE_DEFINITION         = 'definition of child node "%s" not found';
  EM_READ_ONLY_MODE_VIOLATION            = 'cannot make modifications in read-only mode';
  EM_INVALID_STREAM_SIZE                 = 'size of stream is too large (maximum acceptable: %d bytes)';
  EM_INVALID_BUFFER_SIZE                 = 'size of buffer is too large (maximum acceptable: %d bytes)';
  EM_INVALID_SOURCE_LINE                 = 'invalid source line: "%s"';
  EM_INVALID_BINARY_FILE                 = 'invalid TreeStructInfo binary file';
  EM_UNSUPPORTED_BINARY_FORMAT_VERSION   = 'format version "%d.%d" is not supported';


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

