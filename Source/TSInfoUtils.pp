{

    TSInfoUtils.pp                    last modified: 24 July 2014

    Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Includes a set of functions for two-way data conversion (type to string
    and vice versa) of all types supported by TreeStructInfo files. Also
    contains a common procedures and functions needed for correct handling
    of TreeStrictInfo files.
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


unit TSInfoUtils;

{$MODE OBJFPC}{$LONGSTRINGS ON}{$HINTS ON}


interface

uses
  TSInfoConsts, TSInfoTypes,
  SysUtils, DateUtils, LCLProc, Classes, Math, Types;


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


  procedure ThrowException(const AMessage: UTF8String); overload;
  procedure ThrowException(const AMessage: UTF8String; const AArgs: array of const); overload;

  function Comment(const ADeclaration, ADefinition: UTF8String): TComment;
  function RemoveWhitespaceChars(const AValue: UTF8String): UTF8String;

  function ReplaceSubStrings(const AValue, AOldPattern, ANewPattern: UTF8String): UTF8String;
  function GlueStrings(const AMask: UTF8String; const AStrings: array of UTF8String): UTF8String;

  procedure MoveString(const ASource; out ADest: UTF8String; ALength: UInt32);

  function ValidIdentifier(const AIdentifier: UTF8String): Boolean;
  function SameIdentifiers(const AFirst, ASecond: UTF8String): Boolean;

  function IncludeTrailingIdentsDelimiter(const APath: UTF8String): UTF8String;
  function ExcludeTrailingIdentsDelimiter(const APath: UTF8String): UTF8String;

  function ExtractPathComponent(const AAttrName: UTF8String; AComponent: TPathComponent): UTF8String;
  procedure ExtractValueComponents(const AValue: UTF8String; out AComponents: TValueComponents; out ACount: Integer);

  function IsCurrentNodePath(const APath: UTF8String): Boolean;
  function PathWithoutLastNodeName(const APath: UTF8String): UTF8String;


{ ----- data conversions ------------------------------------------------------------------------------------------ }


  function BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): UTF8String;
  function ValueToBoolean(const AValue: UTF8String; ADefault: Boolean): Boolean;

  function IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): UTF8String;
  function ValueToInteger(const AValue: UTF8String; ADefault: Integer): Integer;

  function FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): UTF8String;
  function ValueToFloat(const AValue: UTF8String; ASettings: TFormatSettings; ADefault: Double): Double;

  function CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): UTF8String;
  function ValueToCurrency(const AValue: UTF8String; ASettings: TFormatSettings; ADefault: Currency): Currency;

  function StringToValue(const AString: UTF8String; AFormat: TFormatString): UTF8String;
  function ValueToString(const AValue: UTF8String; AFormat: TFormatString): UTF8String;

  function DateTimeToValue(const AMask: UTF8String; ADateTime: TDateTime; ASettings: TFormatSettings): UTF8String;
  function ValueToDateTime(const AMask, AValue: UTF8String; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;

  function PointToValue(APoint: TPoint; AFormat: TFormatPoint): UTF8String;
  function ValueToPoint(const AValue: UTF8String; ADefault: TPoint): TPoint;

  procedure ListToValue(AList: TStrings; out AValue: UTF8String);
  procedure ValueToList(const AValue: UTF8String; AList: TStrings);

  procedure BufferToValue(const ABuffer; ASize: Integer; out AValue: UTF8String; AFormat: TFormatBuffer);
  procedure ValueToBuffer(const AValue: UTF8String; var ABuffer; ASize, AOffset: Integer);


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


procedure ThrowException(const AMessage: UTF8String); overload;
begin
  raise ETSInfoFileException.Create(AMessage);
end;


procedure ThrowException(const AMessage: UTF8String; const AArgs: array of const);
begin
  raise ETSInfoFileException.CreateFmt(AMessage, AArgs);
end;


function Comment(const ADeclaration, ADefinition: UTF8String): TComment;
begin
  Result[ctDeclaration] := ADeclaration;
  Result[ctDefinition] := ADefinition;
end;


function RemoveWhitespaceChars(const AValue: UTF8String): UTF8String;
var
  intValueLen: Integer;
  pchrLeft, pchrRight: PUTF8Char;
begin
  Result := '';
  intValueLen := Length(AValue);

  if intValueLen > 0 then
  begin
    pchrLeft := @AValue[1];
    pchrRight := @AValue[intValueLen];

    while (pchrLeft <= pchrRight) and (pchrLeft^ in WHITESPACE_CHARS) do
      Inc(pchrLeft);

    while (pchrRight > pchrLeft) and (pchrRight^ in WHITESPACE_CHARS) do
      Dec(pchrRight);

    MoveString(pchrLeft^, Result, pchrRight - pchrLeft + 1);
  end;
end;


function ReplaceSubStrings(const AValue, AOldPattern, ANewPattern: UTF8String): UTF8String;
var
  intValueLen, intOldPtrnLen, intNewPtrnLen,
  intPlainLen, intResultLen, intResultIdx: Integer;
  pchrPlainBegin, pchrPlainEnd, pchrLast, pchrResult: PUTF8Char;
begin
  intValueLen := Length(AValue);

  if intValueLen = 0 then Exit('');
  if AOldPattern = '' then Exit(AValue);

  SetLength(Result, 0);

  intOldPtrnLen := Length(AOldPattern);
  intNewPtrnLen := Length(ANewPattern);
  intResultLen := 0;

  pchrPlainBegin := @AValue[1];
  pchrPlainEnd := pchrPlainBegin;
  pchrLast := @AValue[intValueLen - intOldPtrnLen + 1];

  while pchrPlainEnd <= pchrLast do
    if (pchrPlainEnd^ = AOldPattern[1]) and (CompareByte(pchrPlainEnd^, AOldPattern[1], intOldPtrnLen) = 0) then
    begin
      intPlainLen := pchrPlainEnd - pchrPlainBegin;
      intResultIdx := intResultLen + 1;
      Inc(intResultLen, intPlainLen + intNewPtrnLen);

      SetLength(Result, intResultLen);
      pchrResult := @Result[intResultIdx];
      Move(pchrPlainBegin^, pchrResult^, intPlainLen);

      Inc(pchrResult, intPlainLen);
      Move(ANewPattern[1], pchrResult^, intNewPtrnLen);
      Inc(pchrResult, intNewPtrnLen);

      Inc(pchrPlainEnd, intOldPtrnLen);
      pchrPlainBegin := pchrPlainEnd;
    end
    else
      Inc(pchrPlainEnd);

  if pchrPlainBegin <= pchrPlainEnd then
    Result += UTF8String(pchrPlainBegin);
end;


function GlueStrings(const AMask: UTF8String; const AStrings: array of UTF8String): UTF8String;
const
  MASK_FORMAT_CHAR = UTF8Char('%');
var
  pchrToken, pchrLast: PUTF8Char;
  intStringIdx: Integer = 0;
  intResultLen: Integer = 0;
  intStringLen: Integer;
begin
  pchrToken := @AMask[1];
  pchrLast := @AMask[Length(AMask)];

  while pchrToken <= pchrLast do
  begin
    if pchrToken^ = MASK_FORMAT_CHAR then
    begin
      intStringLen := Length(AStrings[intStringIdx]);
      SetLength(Result, intResultLen + intStringLen);
      Move(AStrings[intStringIdx][1], Result[intResultLen + 1], intStringLen);

      Inc(intResultLen, intStringLen);
      Inc(intStringIdx);
    end
    else
    begin
      Result += INDENT_CHAR;
      Inc(intResultLen);
    end;

    Inc(pchrToken);
  end;
end;


procedure MoveString(const ASource; out ADest: UTF8String; ALength: UInt32);
begin
  SetLength(ADest, ALength);
  Move(ASource, ADest[1], ALength);
end;


function ValidIdentifier(const AIdentifier: UTF8String): Boolean;
var
  intIdentLen: Integer;
  pchrToken, pchrLast: PUTF8Char;
begin
  Result := False;
  intIdentLen := Length(AIdentifier);

  if intIdentLen = 0 then
    ThrowException(EM_EMPTY_IDENTIFIER)
  else
  begin
    pchrToken := @AIdentifier[1];
    pchrLast := @AIdentifier[intIdentLen];

    while pchrToken <= pchrLast do
      if pchrToken^ in INVALID_IDENT_CHARS then
        ThrowException(EM_INCORRECT_IDENTIFIER_CHARACTER, [pchrToken^, Ord(pchrToken^)])
      else
        Inc(pchrToken);

    Result := True;
  end;
end;


function SameIdentifiers(const AFirst, ASecond: UTF8String): Boolean;
var
  intFirstLen, intSecondLen: Integer;
begin
  intFirstLen := Length(AFirst);
  intSecondLen := Length(ASecond);

  Result := (intFirstLen > 0) and (intFirstLen = intSecondLen) and
            (CompareByte(AFirst[1], ASecond[1], intFirstLen) = 0);
end;


function IncludeTrailingIdentsDelimiter(const APath: UTF8String): UTF8String;
var
  intPathLen: Integer;
begin
  intPathLen := Length(APath);

  if (intPathLen > 0) and (APath[intPathLen] <> IDENTS_DELIMITER) then
    Result := APath + IDENTS_DELIMITER
  else
    Result := APath;
end;


function ExcludeTrailingIdentsDelimiter(const APath: UTF8String): UTF8String;
var
  intPathLen: Integer;
begin
  intPathLen := Length(APath);

  if (intPathLen > 0) and (APath[intPathLen] = IDENTS_DELIMITER) then
  begin
    SetLength(Result, intPathLen - 1);
    Move(APath[1], Result[1], intPathLen - 1);
  end
  else
    Result := APath;
end;


function ExtractPathComponent(const AAttrName: UTF8String; AComponent: TPathComponent): UTF8String;
var
  intValueLen: Integer;
  pchrFirst, pchrToken, pchrLast: PUTF8Char;
begin
  Result := '';
  intValueLen := Length(AAttrName);

  if intValueLen > 0 then
  begin
    pchrFirst := @AAttrName[1];
    pchrLast := @AAttrName[intValueLen];
    pchrToken := pchrLast;

    while (pchrToken > pchrFirst) and (pchrToken^ <> IDENTS_DELIMITER) do
      Dec(pchrToken);

    case AComponent of
      pcAttributeName:
          if pchrToken^ = IDENTS_DELIMITER then
            MoveString(PUTF8Char(pchrToken + 1)^, Result, pchrLast - pchrToken)
          else
            Result := AAttrName;
      pcAttributePath:
          if pchrToken^ = IDENTS_DELIMITER then
            MoveString(pchrFirst^, Result, pchrToken - pchrFirst + 1);
    end;
  end;
end;


procedure ExtractValueComponents(const AValue: UTF8String; out AComponents: TValueComponents; out ACount: Integer);

  procedure AddComponent(ASource: PUTF8Char; ALength: UInt32); inline;
  begin
    SetLength(AComponents, ACount + 1);
    MoveString(ASource^, AComponents[ACount], ALength);
    Inc(ACount);
  end;

var
  pchrBegin, pchrToken, pchrLast: PUTF8Char;
  strValue: UTF8String;
begin
  ACount := 0;
  SetLength(AComponents, 0);

  if AValue <> '' then
    if AValue = ONE_BLANK_VALUE_LINE_CHAR then
      AddComponent(PUTF8Char(ONE_BLANK_VALUE_LINE_CHAR), 1)
    else
    begin
      strValue := AValue + VALUES_DELIMITER;

      pchrBegin := @strValue[1];
      pchrToken := pchrBegin;
      pchrLast := @strValue[Length(strValue)];

      while pchrToken <= pchrLast do
        if pchrToken^ = VALUES_DELIMITER then
        begin
          AddComponent(pchrBegin, pchrToken - pchrBegin);
          Inc(pchrToken);
          pchrBegin := pchrToken;
        end
        else
          Inc(pchrToken);
    end;
end;


function IsCurrentNodePath(const APath: UTF8String): Boolean;
begin
  Result := (APath = '') or (APath = CURRENT_NODE_SYMBOL);
end;


function PathWithoutLastNodeName(const APath: UTF8String): UTF8String;
var
  pchrFirst, pchrToken: PUTF8Char;
begin
  Result := '';

  if APath <> '' then
  begin
    pchrFirst := @APath[1];
    pchrToken := @APath[Length(APath) - 2];

    while (pchrToken >= pchrFirst) and (pchrToken^ <> IDENTS_DELIMITER) do
      Dec(pchrToken);

    if pchrToken > pchrFirst then
      MoveString(pchrFirst^, Result, pchrToken - pchrFirst + 1);
  end;
end;


{ ----- boolean conversions --------------------------------------------------------------------------------------- }


function BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): UTF8String;
begin
  Result := BOOLEAN_VALUES[ABoolean, AFormat];
end;


function ValueToBoolean(const AValue: UTF8String; ADefault: Boolean): Boolean;
var
  pchrToken, pchrLast: PUTF8Char;
  fbToken: TFormatBoolean;
begin
  Result := ADefault;

  if AValue <> '' then
  begin
    pchrToken := @AValue[1];
    pchrLast := @AValue[Length(AValue)];

    if pchrToken^ in ['a' .. 'z'] then
      Dec(pchrToken^, 32);

    Inc(pchrToken);

    while pchrToken <= pchrLast do
    begin
      if pchrToken^ in ['A' .. 'Z'] then
        Inc(pchrToken^, 32);

      Inc(pchrToken);
    end;

    for fbToken in TFormatBoolean do
      if SameIdentifiers(AValue, BOOLEAN_VALUES[True, fbToken]) then
        Exit(True)
      else
        if SameIdentifiers(AValue, BOOLEAN_VALUES[False, fbToken]) then
          Exit(False);
  end;
end;


{ ----- integer conversions --------------------------------------------------------------------------------------- }


function IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): UTF8String;
var
  boolIsNegative: Boolean;
  strRawValue: UTF8String;
  intRawValueLen, intRawValueMinLen: Integer;
  pchrNonZeroDigit, pchrLast: PUTF8Char;
begin
  if AFormat in [fiUnsignedDecimal, fiSignedDecimal] then
  begin
    Str(AInteger, Result);

    if (AFormat = fiSignedDecimal) and (AInteger > 0) then
      Result := '+' + Result;
  end
  else
  begin
    boolIsNegative := AInteger < 0;
    AInteger := Abs(AInteger);

    case AFormat of
      fiHexadecimal: strRawValue := HexStr(AInteger, SizeOf(Integer) * 2);
      fiOctal:       strRawValue := OctStr(AInteger, SizeOf(Integer) * 3);
      fiBinary:      strRawValue := BinStr(AInteger, SizeOf(Integer) * 8);
    end;

    intRawValueLen := Length(strRawValue);
    intRawValueMinLen := INTEGER_MIN_LENGTHS[AFormat] - 1;

    pchrNonZeroDigit := @strRawValue[1];
    pchrLast := @strRawValue[intRawValueLen];

    while (pchrNonZeroDigit < pchrLast - intRawValueMinLen) and (pchrNonZeroDigit^ = '0') do
      Inc(pchrNonZeroDigit);

    intRawValueLen := pchrLast - pchrNonZeroDigit + 1;
    SetLength(Result, intRawValueLen + 2 + UInt8(boolIsNegative));
    Move(pchrNonZeroDigit^, Result[3 + UInt8(boolIsNegative)], intRawValueLen);
    Move(INTEGER_UNIVERSAL_SYSTEM_PREFIXES[AFormat][1], Result[1 + UInt8(boolIsNegative)], 2);

    if boolIsNegative then
      Result[1] := '-';
  end;
end;


function ValueToInteger(const AValue: UTF8String; ADefault: Integer): Integer;
var
  pchrToken, pchrLast: PUTF8Char;
  strValue: UTF8String;
  intValueLen, intCode: Integer;
  boolIsNegative: Boolean = False;
  fiNumericalFormat: TFormatInteger = fiUnsignedDecimal;
begin
  strValue := AValue;
  intValueLen := Length(strValue);

  if intValueLen > 2 then
  begin
    pchrToken := @AValue[1];
    pchrLast := @AValue[intValueLen];

    if pchrToken^ = '-' then
    begin
      boolIsNegative := True;
      Inc(pchrToken);
    end;

    if pchrToken^ = '0' then
    begin
      Inc(pchrToken);

      if pchrToken^ in ['A' .. 'Z'] then
        Inc(pchrToken^, 32);

      if pchrToken^ in ['x', 'o', 'b'] then
      begin
        case pchrToken^ of
          'x': fiNumericalFormat := fiHexadecimal;
          'o': fiNumericalFormat := fiOctal;
          'b': fiNumericalFormat := fiBinary;
        end;

        intValueLen := pchrLast - pchrToken;
        SetLength(strValue, intValueLen + 1);
        Move(PUTF8Char(pchrToken + 1)^, strValue[2], intValueLen);
        strValue[1] := INTEGER_PASCAL_SYSTEM_PREFIXES[fiNumericalFormat];
      end;
    end;
  end;

  Val(strValue, Result, intCode);

  if intCode <> 0 then
    Result := ADefault
  else
    if boolIsNegative and (fiNumericalFormat in [fiHexadecimal, fiOctal, fiBinary]) then
      Result := -Result;
end;


{ ----- float conversions ----------------------------------------------------------------------------------------- }


function FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): UTF8String;
var
  boolMustBeUnsigned: Boolean;
begin
  boolMustBeUnsigned := AFormat in [ffUnsignedGeneral, ffUnsignedExponent, ffUnsignedNumber];

  if IsInfinite(AFloat) then
  begin
    if AFloat = Infinity then
    begin
      if boolMustBeUnsigned then
        Exit(UNSIGNED_INFINITY_VALUE)
      else
        Exit(SIGNED_INFINITY_VALUE);
    end
    else
      Exit(NEGATIVE_INFINITY_VALUE);
  end
  else
    if IsNan(AFloat) then
      Exit(NOT_A_NUMBER_VALUE);

  Result := FloatToStrF(AFloat, FLOAT_FORMATS[AFormat], 15, 10, ASettings);

  if (not boolMustBeUnsigned) and (CompareValue(AFloat, 0) = GreaterThanValue) then
    Result := '+' + Result;
end;


function ValueToFloat(const AValue: UTF8String; ASettings: TFormatSettings; ADefault: Double): Double;
var
  pchrToken, pchrLast: PUTF8Char;
begin
  if not TryStrToFloat(AValue, Result, ASettings) then
  begin
    Result := ADefault;

    if Length(AValue) >= 3 then
    begin
      pchrToken := @AValue[1];
      pchrLast := @AValue[Length(AValue)];

      if pchrToken^ in ['+', '-'] then
        Inc(pchrToken);

      if pchrToken^ in ['a' .. 'z'] then
        Dec(pchrToken^, 32);

      Inc(pchrToken);

      while (pchrToken <= pchrLast) do
        if pchrToken^ in ['A' .. 'Z'] then
        begin
          Inc(pchrToken^, 32);
          Inc(pchrToken);
        end
        else
          Break;

      if (CompareStr(AValue, UNSIGNED_INFINITY_VALUE) = 0) or (CompareStr(AValue, SIGNED_INFINITY_VALUE) = 0) then
        Exit(Infinity);

      if CompareStr(AValue, NEGATIVE_INFINITY_VALUE) = 0 then
        Exit(NegInfinity);

      if CompareStr(AValue, NOT_A_NUMBER_VALUE) = 0 then
        Exit(NaN);
    end;
  end;
end;


{ ----- currency converions --------------------------------------------------------------------------------------- }


function CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): UTF8String;
begin
  case AFormat of
    fcUnsignedPrice, fcSignedPrice:               Result := CurrToStrF(ACurrency, ffCurrency, 2, ASettings);
    fcUnsignedExchangeRate, fcSignedExchangeRate: Result := CurrToStrF(ACurrency, ffCurrency, 4, ASettings);
  end;

  if (AFormat in [fcSignedPrice, fcSignedExchangeRate]) and (ACurrency > 0) then
    Result := '+' + Result;
end;


function ValueToCurrency(const AValue: UTF8String; ASettings: TFormatSettings; ADefault: Currency): Currency;
var
  intValueLen, intCurrStringLen: Integer;
  pchrFirst, pchrToken, pchrLast: PUTF8Char;
  strValue: UTF8String;
begin
  intValueLen := Length(AValue);

  if intValueLen = 0 then
    Result := ADefault
  else
  begin
    intCurrStringLen := Length(ASettings.CurrencyString);

    if (intCurrStringLen > 0) and (intValueLen > intCurrStringLen) then
    begin
      pchrFirst := @AValue[1];
      pchrLast := @AValue[intValueLen];
      pchrToken := pchrLast - intCurrStringLen + 1;

      MoveString(pchrToken^, strValue, pchrLast - pchrToken + 1);

      if CompareStr(strValue, ASettings.CurrencyString) = 0 then
      begin
        repeat
          Dec(pchrToken);
        until pchrToken^ in ['0' .. '9'];

        MoveString(pchrFirst^, strValue, pchrToken - pchrFirst + 1);
      end
      else
        strValue := AValue;
    end
    else
      strValue := AValue;

    if not TryStrToCurr(strValue, Result, ASettings) then
      Result := ADefault;
  end;
end;


{ ----- string conversion ----------------------------------------------------------------------------------------- }


function StringToValue(const AString: UTF8String; AFormat: TFormatString): UTF8String;
begin
  case AFormat of
    fsOriginal:  Result := AString;
    fsLowerCase: Result := UTF8LowerCase(AString);
    fsUpperCase: Result := UTF8UpperCase(AString);
  end;
end;


function ValueToString(const AValue: UTF8String; AFormat: TFormatString): UTF8String;
begin
  case AFormat of
    fsOriginal:  Result := AValue;
    fsLowerCase: Result := UTF8LowerCase(AValue);
    fsUpperCase: Result := UTF8UpperCase(AValue);
  end;
end;


{ ----- date & time conversions ----------------------------------------------------------------------------------- }


function DateTimeToValue(const AMask: UTF8String; ADateTime: TDateTime; ASettings: TFormatSettings): UTF8String;
var
  intMaskLen, intResultLen, intFormatLen: UInt32;
  pchrMaskToken, pchrMaskLast: PUTF8Char;
  chrFormat: UTF8Char;
  strMask: UTF8String;
  strResult: UTF8String = '';
  bool12HourClock: Boolean = False;

  procedure IncreaseMaskCharacters();
  begin
    while (pchrMaskToken < pchrMaskLast) do
    begin
      if pchrMaskToken^ in ['a' .. 'z'] then
        Dec(pchrMaskToken^, 32)
      else
        if pchrMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          chrFormat := pchrMaskToken^;

          repeat
            Inc(pchrMaskToken);
          until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ = chrFormat);
        end;

      Inc(pchrMaskToken);
    end;

    pchrMaskToken := @strMask[1];
  end;

  procedure GetClockInfo();
  begin
    while (pchrMaskToken < pchrMaskLast) do
      if pchrMaskToken^ = 'A' then
      begin
        bool12HourClock := True;
        Break;
      end
      else
        Inc(pchrMaskToken);

    pchrMaskToken := @strMask[1];
  end;

  procedure SaveString(const AString: UTF8String);
  var
    intStringLen: UInt32;
  begin
    intStringLen := Length(AString);
    SetLength(strResult, intResultLen + intStringLen);
    Move(AString[1], strResult[intResultLen + 1], intStringLen);
    Inc(intResultLen, intStringLen);
  end;

  procedure SaveNumber(const ANumber, ADigits: UInt16);
  var
    strNumber: UTF8String;
  begin
    Str(ANumber, strNumber);
    strNumber := StringOfChar('0', ADigits - Length(strNumber)) + strNumber;
    SaveString(strNumber);
  end;

  procedure GetFormatInfo();
  begin
    chrFormat := pchrMaskToken^;
    intFormatLen := 0;

    repeat
      Inc(intFormatLen);
      Inc(pchrMaskToken);
    until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ <> chrFormat);
  end;

var
  intYear, intMonth, intDay, intHour, intMinute, intSecond, intMilliSecond, intDayOfWeek: UInt16;
begin
  intMaskLen := Length(strMask);

  if intMaskLen > 0 then
  begin
    strMask := AMask + #32;
    Inc(intMaskLen);
    intResultLen := 0;
    pchrMaskToken := @strMask[1];
    pchrMaskLast := @strMask[intMaskLen];

    IncreaseMaskCharacters();
    GetClockInfo();

    DecodeDateTime(ADateTime, intYear, intMonth, intDay, intHour, intMinute, intSecond, intMilliSecond);
    intDayOfWeek := DayOfWeek(ADateTime);

    while pchrMaskToken < pchrMaskLast do
    begin
      if pchrMaskToken^ in DATE_TIME_FORMAT_CHARS then
      begin
        GetFormatInfo();

        case chrFormat of
          'Y': case intFormatLen of
                 2: SaveNumber(intYear mod 100, 2);
                 4: SaveNumber(intYear, 4);
               end;
          'M': case intFormatLen of
                 1, 2: SaveNumber(intMonth, intFormatLen);
                 3:    SaveString(ASettings.ShortMonthNames[intMonth]);
                 4:    SaveString(ASettings.LongMonthNames[intMonth]);
               end;
          'D': case intFormatLen of
                 1, 2: SaveNumber(intDay, intFormatLen);
                 3:    SaveString(ASettings.ShortDayNames[intDayOfWeek]);
                 4:    SaveString(ASettings.LongDayNames[intDayOfWeek]);
               end;
          'H': case intFormatLen of
                 1, 2: if bool12HourClock then
                       begin
                         if intHour < 12 then
                         begin
                           if intHour = 0 then
                             SaveNumber(12, intFormatLen)
                           else
                             SaveNumber(intHour, intFormatLen);
                         end
                         else
                           if intHour = 12 then
                             SaveNumber(intHour, intFormatLen)
                           else
                             SaveNumber(intHour - 12, intFormatLen);
                       end
                       else
                         SaveNumber(intHour, intFormatLen);
               end;
          'N': case intFormatLen of
                 1, 2: SaveNumber(intMinute, intFormatLen);
               end;
          'S': case intFormatLen of
                 1, 2: SaveNumber(intSecond, intFormatLen);
               end;
          'Z': case intFormatLen of
                 1, 3: SaveNumber(intMilliSecond, intFormatLen);
               end;
          'A': begin
                 if intHour < 12 then
                   SaveString(ASettings.TimeAMString)
                 else
                   SaveString(ASettings.TimePMString);

                 Inc(pchrMaskToken, 4);
               end;
        end;
      end
      else
        if pchrMaskToken^ in DATE_TIME_SEPARATOR_CHARS then
        begin
          case pchrMaskToken^ of
            '.', '-', '/': SaveString(ASettings.DateSeparator);
            ':':           SaveString(ASettings.TimeSeparator);
          end;

          Inc(pchrMaskToken);
        end
        else
          if pchrMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
          begin
            chrFormat := pchrMaskToken^;
            Inc(pchrMaskToken);

            repeat
              SaveString(pchrMaskToken^);
              Inc(pchrMaskToken);
            until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ = chrFormat);

            Inc(pchrMaskToken);
          end
          else
          begin
            SaveString(pchrMaskToken^);
            Inc(pchrMaskToken);
          end;
    end;
  end;

  Result := strResult;
end;


function ValueToDateTime(const AMask, AValue: UTF8String; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;
var
  intValueLen, intMaskLen: Integer;
  pchrMaskToken, pchrMaskLast: PUTF8Char;
  pchrValueBegin, pchrValueEnd, pchrValueLast: PUTF8Char;
  strValue, strMask: UTF8String;
  chrFormat: UTF8Char;

  procedure IncreaseMaskCharacters();
  begin
    while (pchrMaskToken < pchrMaskLast) do
    begin
      if pchrMaskToken^ in ['a' .. 'z'] then
        Dec(pchrMaskToken^, 32)
      else
        if pchrMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          chrFormat := pchrMaskToken^;

          repeat
            Inc(pchrMaskToken);
          until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ = chrFormat);
        end;

      Inc(pchrMaskToken);
    end;

    pchrMaskToken := @strMask[1];
  end;

var
  intYear, intMonth, intDay, intHour, intMinute, intSecond, intMilliSecond: UInt16;

  procedure InitDateTimeComponents();
  begin
    intYear := 1899;
    intMonth := 12;
    intDay := 30;
    intHour := 0;
    intMinute := 0;
    intSecond := 0;
    intMilliSecond := 0;
  end;

var
  chrFormatSep: UTF8Char;
  intFormatLen: UInt32 = 0;
  strFormatVal: UTF8String = '';

  procedure GetFormatInfo();
  begin
    chrFormat := pchrMaskToken^;

    if chrFormat = 'A' then
      Inc(pchrMaskToken, 5)
    else
    begin
      intFormatLen := 0;

      repeat
        Inc(intFormatLen);
        Inc(pchrMaskToken);
      until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ <> chrFormat);
    end;

    if pchrMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
      Inc(pchrMaskToken);

    chrFormatSep := pchrMaskToken^;
  end;

  procedure GetFormatValue();
  begin
    while pchrValueEnd^ <> chrFormatSep do
      Inc(pchrValueEnd);

    MoveString(pchrValueBegin^, strFormatVal, pchrValueEnd - pchrValueBegin);
    pchrValueBegin := pchrValueEnd;
  end;

  function StringToNumber(const AString: UTF8String): UInt16;
  var
    intCode: Integer;
  begin
    Val(AString, Result, intCode);

    if intCode <> 0 then
      Result := 0;
  end;

  function MonthNameToNumber(const AName: UTF8String; const AMonthNames: array of UTF8String): Integer;
  var
    intNameLen: Integer;
    I: Integer = 1;
  begin
    Result := 1;
    intNameLen := Length(AName);

    while I <= High(AMonthNames) do
      if (intNameLen = Length(AMonthNames[I])) and
         (CompareStr(AName, AMonthNames[I]) = 0) then
      begin
        Result := I + 1;
        Break;
      end
      else
        Inc(I);
  end;

  procedure IncrementMaskAndValueTokens();
  begin
    Inc(pchrMaskToken);
    Inc(pchrValueBegin);
    Inc(pchrValueEnd);
  end;

var
  bool12HourClock: Boolean = False;
  boolIsAMHour: Boolean = False;
  intPivot: UInt16;
begin
  strMask := AMask;
  strValue := AValue;

  if (strMask <> '') and (strValue <> '') then
  begin
    InitDateTimeComponents();

    strMask += #32;
    strValue += #32;
    intMaskLen := Length(strMask);
    intValueLen := Length(strValue);

    pchrMaskToken := @strMask[1];
    pchrMaskLast := @strMask[intMaskLen];
    pchrValueBegin := @strValue[1];
    pchrValueEnd := pchrValueBegin;
    pchrValueLast := @strValue[intValueLen];

    IncreaseMaskCharacters();

    while (pchrMaskToken < pchrMaskLast) and (pchrValueEnd < pchrValueLast) do
      if pchrMaskToken^ in DATE_TIME_FORMAT_CHARS then
      begin
        GetFormatInfo();
        GetFormatValue();

        case chrFormat of
          'Y': case intFormatLen of
                 2: begin
                      intYear := StringToNumber(strFormatVal);
                      intPivot := YearOf(Now()) - ASettings.TwoDigitYearCenturyWindow;
                      Inc(intYear, intPivot div 100 * 100);

                      if (ASettings.TwoDigitYearCenturyWindow > 0) and (intYear < intPivot) then
                        Inc(intYear, 100);
                    end;
                 4: intYear := StringToNumber(strFormatVal);
               end;
          'M': case intFormatLen of
                 1, 2: intMonth := StringToNumber(strFormatVal);
                 3:    intMonth := MonthNameToNumber(strFormatVal, ASettings.ShortMonthNames);
                 4:    intMonth := MonthNameToNumber(strFormatVal, ASettings.LongMonthNames);
               end;
          'D': case intFormatLen of
                 1, 2: intDay := StringToNumber(strFormatVal);
               end;
          'H': case intFormatLen of
                 1, 2: intHour := StringToNumber(strFormatVal);
               end;
          'N': case intFormatLen of
                 1, 2: intMinute := StringToNumber(strFormatVal);
               end;
          'S': case intFormatLen of
                 1, 2: intSecond := StringToNumber(strFormatVal);
               end;
          'Z': case intFormatLen of
                 1, 3: intMilliSecond := StringToNumber(strFormatVal);
               end;
          'A': begin
                 bool12HourClock := True;
                 boolIsAMHour := CompareStr(strFormatVal, ASettings.TimeAMString) = 0;
               end;
        end;
      end
      else
        if pchrMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          chrFormat := pchrMaskToken^;
          Inc(pchrMaskToken);

          repeat
            IncrementMaskAndValueTokens();
          until (pchrMaskToken = pchrMaskLast) or (pchrMaskToken^ = chrFormat);

          Inc(pchrMaskToken);
        end
        else
          IncrementMaskAndValueTokens();

    if bool12HourClock then
      if boolIsAMHour then
      begin
        if intHour = 12 then
          intHour := 0;
      end
      else
        if intHour < 12 then
          Inc(intHour, 12);

    if not TryEncodeDateTime(intYear, intMonth, intDay, intHour, intMinute, intSecond, intMilliSecond, Result) then
      Result := ADefault;
  end
  else
    Result := ADefault;
end;


{ ----- point conversions ----------------------------------------------------------------------------------------- }


function PointToValue(APoint: TPoint; AFormat: TFormatPoint): UTF8String;
var
  strCoordX, strCoordY: UTF8String;
begin
  strCoordX := IntegerToValue(APoint.X, POINT_SYSTEMS[AFormat]);
  strCoordY := IntegerToValue(APoint.Y, POINT_SYSTEMS[AFormat]);

  Result := GlueStrings('%%%', [strCoordX, COORDS_DELIMITER, strCoordY]);
end;


function ValueToPoint(const AValue: UTF8String; ADefault: TPoint): TPoint;

  procedure ExtractPointCoord(AFirst, ALast: PUTF8Char; out ACoord: UTF8String); inline;
  var
    intNegativeOffset: UInt8;
    pchrSystem: PUTF8Char;
    fiFormat: TFormatInteger;
  begin
    if ALast - AFirst + 1 >= MIN_NO_DECIMAL_VALUE_LEN then
    begin
      intNegativeOffset := UInt8(AFirst^ = '-');
      pchrSystem := AFirst + intNegativeOffset;

      if (pchrSystem^ = '0') and (PUTF8Char(pchrSystem + 1)^ in ['x', 'o', 'b']) then
      begin
        Inc(pchrSystem);

        case pchrSystem^ of
          'x': fiFormat := fiHexadecimal;
          'o': fiFormat := fiOctal;
          'b': fiFormat := fiBinary;
        end;

        SetLength(ACoord, ALast - pchrSystem + 1 + intNegativeOffset);
        Move(pchrSystem^, ACoord[1 + intNegativeOffset], ALast - pchrSystem + 1);
        ACoord[1 + intNegativeOffset] := INTEGER_PASCAL_SYSTEM_PREFIXES[fiFormat];

        if Boolean(intNegativeOffset) then
          ACoord[1] := '-';

        Exit();
      end;
    end;

    MoveString(AFirst^, ACoord, ALast - AFirst + 1);
  end;

var
  pchrFirst, pchrLast, pchrDelimiter: PUTF8Char;
  strCoordX, strCoordY: UTF8String;
  intValueLen, intCoordXCode, intCoordYCode: Integer;
begin
  intValueLen := Length(AValue);

  if intValueLen >= MIN_POINT_VALUE_LEN then
  begin
    pchrFirst := @AValue[1];
    pchrLast := @AValue[intValueLen];
    pchrDelimiter := pchrFirst + 1;

    while (pchrDelimiter < pchrLast) and (pchrDelimiter^ <> COORDS_DELIMITER) do
      Inc(pchrDelimiter);

    if pchrDelimiter < pchrLast then
    begin
      ExtractPointCoord(pchrFirst, pchrDelimiter - 1, strCoordX);
      ExtractPointCoord(pchrDelimiter + 1, pchrLast, strCoordY);

      Val(strCoordX, Result.X, intCoordXCode);
      Val(strCoordY, Result.Y, intCoordYCode);

      if (intCoordXCode = 0) and (intCoordYCode = 0) then
        Exit();
    end;
  end;

  Result := ADefault;
end;


{ ----- list conversions ------------------------------------------------------------------------------------------ }


procedure ListToValue(AList: TStrings; out AValue: UTF8String);
var
  intLineIdx: Integer;
begin
  if AList.Count = 0 then
    AValue := ''
  else
    if (AList.Count = 1) and (AList[0] = '') then
      AValue := ONE_BLANK_VALUE_LINE_CHAR
    else
    begin
      AValue := AList[0];

      for intLineIdx := 1 to AList.Count - 1 do
        AValue += VALUES_DELIMITER + AList[intLineIdx];
    end;
end;


procedure ValueToList(const AValue: UTF8String; AList: TStrings);
var
  vcList: TValueComponents;
  intLinesCnt, intLineIdx: Integer;
begin
  ExtractValueComponents(AValue, vcList, intLinesCnt);

  AList.BeginUpdate();
  try
    for intLineIdx := 0 to intLinesCnt - 1 do
      AList.Add(vcList[intLineIdx]);
  finally
    AList.EndUpdate();
  end;
end;


{ ----- buffer & stream conversions ------------------------------------------------------------------------------- }


procedure BufferToValue(const ABuffer; ASize: Integer; out AValue: UTF8String; AFormat: TFormatBuffer);
const
  HEX_CHARS: array [0 .. 15] of UTF8Char = '0123456789ABCDEF';
var
  bdaBuffer: TByteDynArray;
  intValueLen, intByteIdx: Integer;
  pintByte: PUInt8;
  pchrByte, pchrLast: PUTF8Char;
begin
  if ASize <= 0 then Exit();

  SetLength(bdaBuffer, ASize);
  Move(ABuffer, bdaBuffer[0], ASize);

  intValueLen := (ASize * 2) + ((ASize - 1) div UInt8(AFormat));
  SetLength(AValue, intValueLen);

  pintByte := @bdaBuffer[0];
  pchrByte := @AValue[1];
  pchrLast := @AValue[intValueLen];

  while pchrByte < pchrLast do
  begin
    intByteIdx := 0;

    while (intByteIdx < UInt8(AFormat)) and (pchrByte < pchrLast) do
    begin
      PUTF8Char(pchrByte + 0)^ := HEX_CHARS[pintByte^ shr 4 and 15];
      PUTF8Char(pchrByte + 1)^ := HEX_CHARS[pintByte^ and 15];

      Inc(pintByte);
      Inc(pchrByte, 2);
      Inc(intByteIdx);
    end;

    if pchrByte < pchrLast then
    begin
      pchrByte^ := VALUES_DELIMITER;
      Inc(pchrByte);
    end;
  end;
end;


procedure ValueToBuffer(const AValue: UTF8String; var ABuffer; ASize, AOffset: Integer);
var
  bdaBuffer: TByteDynArray;
  strValue: UTF8String;
  intValueLen: Integer;
  pintByte: PUInt8;
  pchrByte, pchrBufferLast, pchrValueLast: PUTF8Char;
begin
  if ASize <= 0 then Exit();

  strValue := ReplaceSubStrings(AValue, VALUES_DELIMITER, '');
  intValueLen := Length(strValue);

  if intValueLen > 0 then
  begin
    SetLength(bdaBuffer, ASize);
    FillChar(bdaBuffer[0], ASize, 0);

    pintByte := @bdaBuffer[0];
    pchrByte := @strValue[AOffset * 2 + 1];
    pchrBufferLast := pchrByte + ASize * 2;
    pchrValueLast := @strValue[intValueLen];

    while (pchrByte <= pchrBufferLast) and (pchrByte <= pchrValueLast) do
    begin
      if pchrByte^ in ['0' .. '9'] then
        Dec(pchrByte^, 48)
      else
        if pchrByte^ in ['A' .. 'F'] then
          Dec(pchrByte^, 55)
        else
          Exit();

      Inc(pchrByte);
    end;

    pchrByte := @strValue[AOffset * 2 + 1];

    while (pchrByte < pchrBufferLast) and (pchrByte < pchrValueLast) do
    begin
      pintByte^ := UInt8(pchrByte^) shl 4 or PUInt8(pchrByte + 1)^;
      Inc(pintByte);
      Inc(pchrByte, 2);
    end;

    Move(bdaBuffer[0], ABuffer, ASize);
  end;
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

