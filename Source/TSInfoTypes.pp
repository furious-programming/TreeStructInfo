{

    TSInfoTypes.pp                    last modified: 23 July 2014

    Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Contains the types used for file processing, building a tree in memory,
    and to modify it. The following types are common for the entire library.
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


unit TSInfoTypes;

{$MODE OBJFPC} {$LONGSTRINGS ON} {$HINTS ON}


interface

uses
  SysUtils;


{ ----- elements lists types -------------------------------------------------------------------------------------- }


type
  TTSInfoElementsList = array [0 .. MaxInt shr 4] of TObject;
  PTSInfoElementsList = ^TTSInfoElementsList;


{ ----- common types ---------------------------------------------------------------------------------------------- }


type
  TCommentType = (ctDeclaration, ctDefinition);
  TComment     = array [TCommentType] of AnsiString;

type
  TFileFlag  = (ffLoadFile, ffBinaryFile, ffUpdatable, ffNoLinking);
  TFileFlags = set of TFileFlag;

type
  TExportFormat = (efTextFile, efBinaryFile);

type
  TLastMovedRefType = (lmrtAttribute, lmrtAttributeWithComment, lmrtNode);
  TReferenceType    = (rtAttribute, rtNode);

type
  TTaggingStyle = (tsFirst, tsAll);

type
  TCuttingMode   = (cmLeftSide, cmBothSides);
  TPathComponent = (pcAttributeName, pcAttributePath);

type
  TValueComponents = array of AnsiString;

type
  TFormatBoolean  = (fbLongTrueFalse, fbLongYesNo, fbLongOnOff, fbShortTrueFalse, fbShortYesNo, fbNumerical);
  TFormatInteger  = (fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary);
  TFormatFloat    = (ffUnsignedGeneral, ffSignedGeneral, ffUnsignedExponent, ffSignedExponent,
                     ffUnsignedNumber, ffSignedNumber);
  TFormatCurrency = (fcUnsignedPrice, fcSignedPrice, fcUnsignedExchangeRate, fcSignedExchangeRate);
  TFormatString   = (fsOriginal, fsLowerCase, fsUpperCase);
  TFormatPoint    = (fpUnsignedDecimal, fpSignedDecimal, fpHexadecimal, fpOctal, fpBinary);
  TFormatBuffer   = (fb8BytesPerLine, fb16BytesPerLine, fb32BytesPerLine, fb64BytesPerLine);

type
  ETSInfoFileException = class(Exception);


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

