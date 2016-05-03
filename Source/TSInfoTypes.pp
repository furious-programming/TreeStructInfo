{

    TSInfoTypes.pp                    last modified: 3 May 2016

    Copyright © Jarosław Baran, furious programming 2013 - 2016.
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

{$MODE OBJFPC}{$LONGSTRINGS ON}{$HINTS ON}


interface

uses
  SysUtils;


{ ----- common types ---------------------------------------------------------------------------------------------- }


type
  TCommentType = (ctDeclaration, ctDefinition);
  TComment     = array [TCommentType] of String;

type
  TTreeMode  = (tmTextTree, tmBinaryTree, tmAccessRead, tmAccessWrite);
  TTreeModes = set of TTreeMode;

type
  TLinkingMode = (lmTextTree, lmBinaryTree, lmAccessRead, lmAccessWrite);

type
  TExportFormat = (efTextTree, efBinaryTree);

type
  TPathComponent = (pcAttributeName, pcAttributePath);

type
  TValueComponents = array of String;
  TLineComponents  = TValueComponents;

type
  TRenamingDirection = (rdAscending, rdDescending);


{ ----- data convertion types ------------------------------------------------------------------------------------- }


type
  TFormatBoolean  = (fbLongTrueFalse, fbLongYesNo, fbLongOnOff, fbShortTrueFalse, fbShortYesNo, fbNumerical);
  TFormatInteger  = (fiUnsignedDecimal, fiSignedDecimal, fiHexadecimal, fiOctal, fiBinary);
  TFormatFloat    = (ffUnsignedGeneral, ffSignedGeneral, ffUnsignedExponent, ffSignedExponent,
                     ffUnsignedNumber, ffSignedNumber);
  TFormatCurrency = (fcUnsignedPrice, fcSignedPrice, fcUnsignedExchangeRate, fcSignedExchangeRate);
  TFormatString   = (fsOriginal, fsLowerCase, fsUpperCase);
  TFormatPoint    = (fpUnsignedDecimal, fpSignedDecimal, fpHexadecimal, fpOctal, fpBinary);
  TFormatBuffer   = (fb8BytesPerLine = 8, fb16BytesPerLine = 16, fb32BytesPerLine = 32, fb64BytesPerLine = 64);
  TFormatStream   = (fs8BytesPerLine = 8, fs16BytesPerLine = 16, fs32BytesPerLine = 32, fs64BytesPerLine = 64);


{ ----- procedural types ------------------------------------------------------------------------------------------ }


type
  TStoreRefElementProc = procedure(AElement: TObject) of object;


{ ----- class types ----------------------------------------------------------------------------------------------- }


type
  ETSInfoFileException = class(Exception);


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


end.

