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

{$MODE OBJFPC} {$LONGSTRINGS ON} {$HINTS ON}


interface

uses
  TSInfoTypes, TSInfoConsts, SysUtils, DateUtils, LCLProc, Classes, Math, Types;


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


  procedure ThrowException(const AMessage: AnsiString; const AArgs: array of const);
  function Comment(ADeclaration, ADefinition: AnsiString): TComment;

  procedure MoveString(const ASource; out ADest: AnsiString; ALength: UInt32);

  function CutControlChars(const AValue: AnsiString; AMode: TCuttingMode): AnsiString;
  function ReplaceSubStrings(AValue, AOldPattern, ANewPattern: AnsiString): AnsiString;
  function GlueStrings(const AMask: AnsiString; const AStrings: array of AnsiString): AnsiString;

  function ValidIdentifier(AIdentifier: AnsiString): Boolean;
  function SameIdentifiers(AFirst, ASecond: AnsiString): Boolean;

  procedure IncludeTrailingIdentsDelimiter(var APath: AnsiString);
  procedure ExcludeTrailingIdentsDelimiter(var APath: AnsiString);

  function ExtractPathComponent(AAttrName: AnsiString; AComponent: TPathComponent): AnsiString;
  procedure ExtractValueComponents(AValue: AnsiString; var AComponents: TValueComponents; out ACount: UInt32);

  function IsCurrentNodeSymbol(APath: AnsiString): Boolean;


{ ----- data conversions ------------------------------------------------------------------------------------------ }


  function BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): AnsiString;
  function ValueToBoolean(AValue: AnsiString; ADefault: Boolean): Boolean;

  function IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): AnsiString;
  function ValueToInteger(AValue: AnsiString; ADefault: Integer): Integer;

  function FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): AnsiString;
  function ValueToFloat(AValue: AnsiString; ASettings: TFormatSettings; ADefault: Double): Double;

  function CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): AnsiString;
  function ValueToCurrency(AValue: AnsiString; ASettings: TFormatSettings; ADefault: Currency): Currency;

  function StringToValue(AString: AnsiString; AFormat: TFormatString): AnsiString;
  function ValueToString(AValue: AnsiString; AFormat: TFormatString): AnsiString;

  function DateTimeToValue(ADateTime: TDateTime; AMask: AnsiString; ASettings: TFormatSettings): AnsiString;
  function ValueToDateTime(AValue: AnsiString; AMask: AnsiString; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;

  function PointToValue(APoint: TPoint; AFormat: TFormatPoint): AnsiString;
  function ValueToPoint(AValue: AnsiString; ADefault: TPoint): TPoint;

  procedure ListToValue(AList: TStrings; out AValue: AnsiString);
  procedure ValueToList(AValue: AnsiString; AList: TStrings);

  procedure BufferToValue(const ABuffer; ASize: UInt32; out AValue: AnsiString; AFormat: TFormatBuffer);
  procedure ValueToBuffer(AValue: AnsiString; var ABuffer; ASize, AOffset: UInt32);


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


procedure ThrowException(const AMessage: AnsiString; const AArgs: array of const);
begin
  if Length(AArgs) = 0 then
    raise ETSInfoFileException.Create(AMessage)
  else
    raise ETSInfoFileException.CreateFmt(AMessage, AArgs);
end;


function Comment(ADeclaration, ADefinition: AnsiString): TComment;
begin
  Result[ctDeclaration] := ADeclaration;
  Result[ctDefinition] := ADefinition;
end;


procedure MoveString(const ASource; out ADest: AnsiString; ALength: UInt32);
begin
  SetLength(ADest, ALength);
  Move(ASource, ADest[1], ALength);
end;


function CutControlChars(const AValue: AnsiString; AMode: TCuttingMode): AnsiString;
var
  intValueLen: UInt32;
  pchrLeft, pchrRight: PAnsiChar;
begin
  Result := '';
  intValueLen := Length(AValue);

  if intValueLen > 0 then
  begin
    pchrLeft := @AValue[1];
    pchrRight := @AValue[intValueLen];

    while (pchrLeft <= pchrRight) and (pchrLeft^ in CONTROL_CHARS) do
      Inc(pchrLeft);

    if AMode = cmBothSides then
      while (pchrRight > pchrLeft) and (pchrRight^ in CONTROL_CHARS) do
        Dec(pchrRight);

    MoveString(pchrLeft^, Result, pchrRight - pchrLeft + 1);
  end;
end;


function ReplaceSubStrings(AValue, AOldPattern, ANewPattern: AnsiString): AnsiString;
var
  intValueLen, intOldPtrnLen, intNewPtrnLen,
  intPlainLen, intResultLen, intResultIdx: UInt32;
  pchrPlainBegin, pchrPlainEnd, pchrLast, pchrResult: PAnsiChar;
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
    if (pchrPlainEnd^ = AOldPattern[1]) and
       (CompareByte(pchrPlainEnd^, AOldPattern[1], intOldPtrnLen) = 0) then
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
    Result += AnsiString(pchrPlainBegin);
end;


function GlueStrings(const AMask: AnsiString; const AStrings: array of AnsiString): AnsiString;
const
  MASK_FORMAT_CHAR = AnsiChar('%');
var
  pchrToken, pchrLast: PAnsiChar;
  intStringIdx: UInt32 = 0;
  intResultLen: UInt32 = 0;
  intStringLen: UInt32;
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


function ValidIdentifier(AIdentifier: AnsiString): Boolean;
var
  intIdentLen: UInt32;
  pchrToken, pchrLast: PAnsiChar;
begin
  Result := False;
  intIdentLen := Length(AIdentifier);

  if intIdentLen = 0 then
    ThrowException(EM_EMPTY_IDENTIFIER, [])
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


function SameIdentifiers(AFirst, ASecond: AnsiString): Boolean;
var
  intFirstLen, intSecondLen: UInt32;
begin
  intFirstLen := Length(AFirst);
  intSecondLen := Length(ASecond);

  Result := (intFirstLen > 0) and (intFirstLen = intSecondLen) and
            (CompareByte(AFirst[1], ASecond[1], intFirstLen) = 0);
end;


procedure IncludeTrailingIdentsDelimiter(var APath: AnsiString);
var
  intPathLen: UInt32;
begin
  intPathLen := Length(APath);

  if (intPathLen > 0) and (APath[intPathLen] <> IDENTS_DELIMITER) then
    APath += IDENTS_DELIMITER;
end;


procedure ExcludeTrailingIdentsDelimiter(var APath: AnsiString);
var
  intPathLen: UInt32;
begin
  intPathLen := Length(APath);

  if (intPathLen > 0) and (APath[intPathLen] = IDENTS_DELIMITER) then
    SetLength(APath, intPathLen - 1);
end;


function ExtractPathComponent(AAttrName: AnsiString; AComponent: TPathComponent): AnsiString;
var
  intValueLen: UInt32;
  pchrFirst, pchrToken, pchrLast: PAnsiChar;
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
            MoveString(PAnsiChar(pchrToken + 1)^, Result, pchrLast - pchrToken)
          else
            Result := AAttrName;
      pcAttributePath:
          if pchrToken^ = IDENTS_DELIMITER then
            MoveString(pchrFirst^, Result, pchrToken - pchrFirst + 1);
    end;
  end;
end;


procedure ExtractValueComponents(AValue: AnsiString; var AComponents: TValueComponents; out ACount: UInt32);
var
  intCompCnt: UInt32 = 0;

  procedure AddComponent(ASource: PAnsiChar; ALength: UInt32);
  begin
    SetLength(AComponents, intCompCnt + 1);
    MoveString(ASource^, AComponents[intCompCnt], ALength);
    Inc(intCompCnt);
  end;

var
  pchrBegin, pchrToken, pchrLast: PAnsiChar;
begin
  if AValue <> '' then
    if AValue = ONE_BLANK_VALUE_LINE_CHAR then
      AddComponent(PAnsiChar(ONE_BLANK_VALUE_LINE_CHAR), 1)
    else
    begin
      AValue += VALUES_DELIMITER;

      pchrBegin := @AValue[1];
      pchrToken := pchrBegin;
      pchrLast := @AValue[Length(AValue)];

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

  ACount := intCompCnt;
end;


{ ----- boolean conversions --------------------------------------------------------------------------------------- }


function BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): AnsiString;
begin
  Result := BOOLEAN_VALUES[ABoolean, AFormat];
end;


function ValueToBoolean(AValue: AnsiString; ADefault: Boolean): Boolean;

  procedure SetValueCamelCaseStyle();
  var
    pchrToken, pchrLast: PAnsiChar;
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
  end;

var
  boolValue: Boolean = False;

  function MatchValue(AType: TFormatBoolean): Boolean;
  begin
    Result := True;

    if SameIdentifiers(BOOLEAN_VALUES[True, AType], AValue) then
      boolValue := True
    else
      if SameIdentifiers(BOOLEAN_VALUES[False, AType], AValue) then
        boolValue := False
      else
        Exit(False);
  end;

var
  fbToken: TFormatBoolean;
begin
  Result := ADefault;

  if AValue <> '' then
  begin
    SetValueCamelCaseStyle();

    for fbToken in TFormatBoolean do
      if MatchValue(fbToken) then
        Exit(boolValue);
  end;
end;


{ ----- integer conversions --------------------------------------------------------------------------------------- }


function IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): AnsiString;
var
  strValue: AnsiString;
  intValueLen, intMinLen: UInt32;
  pchrToken, pchrLast: PAnsiChar;
begin
  if AFormat in [fiUnsignedDecimal, fiSignedDecimal] then
  begin
    Str(AInteger, strValue);

    if (AFormat = fiSignedDecimal) and (AInteger > 0) then
      Result := '+';

    Result += strValue;
  end
  else
  begin
    case AFormat of
      fiHexadecimal: strValue := HexStr(AInteger, SizeOf(Integer) * 2);
      fiOctal:       strValue := OctStr(AInteger, SizeOf(Integer) * 3);
      fiBinary:      strValue := BinStr(AInteger, SizeOf(Integer) * 8);
    end;

    intValueLen := Length(strValue);
    intMinLen := INTEGER_MIN_LENGTHS[AFormat] - 1;

    pchrToken := @strValue[1];
    pchrLast := @strValue[intValueLen];

    while (pchrToken < pchrLast - intMinLen) and (pchrToken^ = '0') do
      Inc(pchrToken);

    intValueLen := pchrLast - pchrToken + 2;
    SetLength(Result, intValueLen + 1);
    Move(pchrToken^, Result[3], intValueLen);
    Move(INTEGER_UNIVERSAL_SYSTEM_PREFIXES[AFormat][1], Result[1], 2);
  end;
end;


function ValueToInteger(AValue: AnsiString; ADefault: Integer): Integer;
var
  strValue: AnsiString;
  intValueLen: UInt32;
  fiFormat: TFormatInteger = fiUnsignedDecimal;

  procedure LocalizeAndChangeValueSystemPrefix();
  var
    pchrToken, pchrLast, pchrSystem: PAnsiChar;
  begin
    pchrToken := @AValue[1];
    pchrLast := @AValue[intValueLen];

    while (pchrToken < pchrLast) and (pchrToken^ in CONTROL_CHARS) do
      Inc(pchrToken);

    if pchrToken < pchrLast - 1 then
    begin
      pchrSystem := pchrToken + 1;

      if pchrSystem^ in ['A' .. 'Z'] then
        Inc(pchrSystem^, 32);

      case pchrSystem^ of
        'x': fiFormat := fiHexadecimal;
        'o': fiFormat := fiOctal;
        'b': fiFormat := fiBinary;
      end;

      if fiFormat <> fiUnsignedDecimal then
      begin
        intValueLen := pchrLast - pchrSystem;
        SetLength(strValue, intValueLen + 1);
        Move(PAnsiChar(pchrSystem + 1)^, strValue[2], intValueLen);
        strValue[1] := INTEGER_PASCAL_SYSTEM_PREFIXES[fiFormat];
      end;
    end;
  end;

var
  intCode: Integer;
begin
  strValue := AValue;
  intValueLen := Length(strValue);

  if intValueLen > 2 then
    LocalizeAndChangeValueSystemPrefix();

  Val(strValue, Result, intCode);

  if intCode <> 0 then
    Result := ADefault;
end;


{ ----- float conversions ----------------------------------------------------------------------------------------- }


function FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): AnsiString;
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


function ValueToFloat(AValue: AnsiString; ASettings: TFormatSettings; ADefault: Double): Double;

  procedure SetValueCamelCaseStyle();
  var
    pchrToken, pchrLast: PAnsiChar;
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
        Exit;
  end;

begin
  if not TryStrToFloat(AValue, Result, ASettings) then
  begin
    Result := ADefault;

    if Length(AValue) >= 3 then
    begin
      SetValueCamelCaseStyle();

      if (CompareStr(AValue, UNSIGNED_INFINITY_VALUE) = 0) or
         (CompareStr(AValue, SIGNED_INFINITY_VALUE) = 0) then
        Exit(Infinity);

      if CompareStr(AValue, NEGATIVE_INFINITY_VALUE) = 0 then
        Exit(NegInfinity);

      if CompareStr(AValue, NOT_A_NUMBER_VALUE) = 0 then
        Exit(NaN);
    end;
  end;
end;


{ ----- currency converions --------------------------------------------------------------------------------------- }


function CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): AnsiString;
begin
  case AFormat of
    fcUnsignedPrice, fcSignedPrice:
        Result := CurrToStrF(ACurrency, ffCurrency, 2, ASettings);
    fcUnsignedExchangeRate, fcSignedExchangeRate:
        Result := CurrToStrF(ACurrency, ffCurrency, 4, ASettings);
  end;

  if (AFormat in [fcSignedPrice, fcSignedExchangeRate]) and (ACurrency > 0) then
    Exit('+' + Result);
end;


function ValueToCurrency(AValue: AnsiString; ASettings: TFormatSettings; ADefault: Currency): Currency;
var
  intValueLen, intCurrStringLen: UInt32;
  pchrFirst, pchrToken, pchrLast: PAnsiChar;
  strValue: AnsiString;
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


function StringToValue(AString: AnsiString; AFormat: TFormatString): AnsiString;
begin
  case AFormat of
    fsOriginal:  Result := AString;
    fsLowerCase: Result := UTF8LowerCase(AString);
    fsUpperCase: Result := UTF8UpperCase(AString);
  end;
end;


function ValueToString(AValue: AnsiString; AFormat: TFormatString): AnsiString;
begin
  case AFormat of
    fsOriginal:  Result := AValue;
    fsLowerCase: Result := UTF8LowerCase(AValue);
    fsUpperCase: Result := UTF8UpperCase(AValue);
  end;
end;


{ ----- date & time conversions ----------------------------------------------------------------------------------- }


function DateTimeToValue(ADateTime: TDateTime; AMask: AnsiString; ASettings: TFormatSettings): AnsiString;
var
  intMaskLen, intResultLen, intFormatLen: UInt32;
  pchrMaskToken, pchrMaskLast: PAnsiChar;
  chrFormat: AnsiChar;
  strResult: AnsiString = '';
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

    pchrMaskToken := @AMask[1];
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

    pchrMaskToken := @AMask[1];
  end;

  procedure SaveString(const AString: AnsiString);
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
    strNumber: AnsiString;
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
  intMaskLen := Length(AMask);

  if intMaskLen > 0 then
  begin
    AMask += #32;
    Inc(intMaskLen);
    intResultLen := 0;
    pchrMaskToken := @AMask[1];
    pchrMaskLast := @AMask[intMaskLen];

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
                 3: SaveString(ASettings.ShortMonthNames[intMonth]);
                 4: SaveString(ASettings.LongMonthNames[intMonth]);
               end;
          'D': case intFormatLen of
                 1, 2: SaveNumber(intDay, intFormatLen);
                 3: SaveString(ASettings.ShortDayNames[intDayOfWeek]);
                 4: SaveString(ASettings.LongDayNames[intDayOfWeek]);
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


function ValueToDateTime(AValue: AnsiString; AMask: AnsiString; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;
var
  intValueLen, intMaskLen: UInt32;
  pchrMaskToken, pchrMaskLast: PAnsiChar;
  pchrValueBegin, pchrValueEnd, pchrValueLast: PAnsiChar;
  chrFormat: AnsiChar;

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

    pchrMaskToken := @AMask[1];
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
  chrFormatSep: AnsiChar;
  intFormatLen: UInt32 = 0;
  strFormatVal: AnsiString = '';

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

  function StringToNumber(const AString: AnsiString): UInt16;
  var
    intCode: Integer;
  begin
    Val(AString, Result, intCode);

    if intCode <> 0 then
      Result := 0;
  end;

  function MonthNameToNumber(const AName: AnsiString; const AMonthNames: array of AnsiString): Integer;
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
  intValueLen := Length(AValue);
  intMaskLen := Length(AMask);

  if (intValueLen > 0) and (intMaskLen > 0) then
  begin
    InitDateTimeComponents();

    AMask += #32;
    AValue += #32;
    Inc(intMaskLen);
    Inc(intValueLen);

    pchrMaskToken := @AMask[1];
    pchrMaskLast := @AMask[intMaskLen];
    pchrValueBegin := @AValue[1];
    pchrValueEnd := pchrValueBegin;
    pchrValueLast := @AValue[intValueLen];

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
                 3: intMonth := MonthNameToNumber(strFormatVal, ASettings.ShortMonthNames);
                 4: intMonth := MonthNameToNumber(strFormatVal, ASettings.LongMonthNames);
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
      begin
        if intHour < 12 then
          Inc(intHour, 12);
      end;

    if not TryEncodeDateTime(intYear, intMonth, intDay, intHour, intMinute, intSecond, intMilliSecond, Result) then
      Result := ADefault;
  end
  else
    Result := ADefault;
end;


{ ----- point conversions ----------------------------------------------------------------------------------------- }


function PointToValue(APoint: TPoint; AFormat: TFormatPoint): AnsiString;
var
  strX, strY: AnsiString;
begin
  strX := IntegerToValue(APoint.X, POINT_SYSTEMS[AFormat]);
  strY := IntegerToValue(APoint.Y, POINT_SYSTEMS[AFormat]);

  Result := GlueStrings('%%%', [strX, COORDS_DELIMITER, strY]);
end;


function ValueToPoint(AValue: AnsiString; ADefault: TPoint): TPoint;

  function ExtractPointCoords(const AValue: AnsiString; out ACoordX, ACoordY: AnsiString): Boolean;
  var
    intValueLen: UInt32;
    pchrCoordXBegin, pchrCoordXEnd, pchrCoordYBegin, pchrCoordYEnd: PAnsiChar;
  begin
    Result := False;
    intValueLen := Length(AValue);

    if intValueLen >= MIN_POINT_LINE_LEN then
    begin
      pchrCoordXBegin := @AValue[1];
      pchrCoordXEnd := pchrCoordXBegin;
      pchrCoordYEnd := @AValue[intValueLen];

      while (pchrCoordXEnd < pchrCoordYEnd - 1) and (pchrCoordXEnd^ <> COORDS_DELIMITER) do
        Inc(pchrCoordXEnd);

      if (pchrCoordXEnd > pchrCoordXBegin) and (pchrCoordXEnd < pchrCoordYEnd) and
         (pchrCoordXEnd^ = COORDS_DELIMITER) then
      begin
        pchrCoordYBegin := pchrCoordXEnd;
        Dec(pchrCoordXEnd);
        Inc(pchrCoordYBegin);

        while (pchrCoordXBegin < pchrCoordXEnd) and (pchrCoordXBegin^ in CONTROL_CHARS) do
          Inc(pchrCoordXBegin);

        while (pchrCoordXEnd > pchrCoordXBegin) and (pchrCoordXEnd^ in CONTROL_CHARS) do
          Dec(pchrCoordXEnd);

        while (pchrCoordYBegin < pchrCoordYEnd) and (pchrCoordYBegin^ in CONTROL_CHARS) do
          Inc(pchrCoordYBegin);

        while (pchrCoordYEnd > pchrCoordYBegin) and (pchrCoordYEnd^ in CONTROL_CHARS) do
          Dec(pchrCoordYEnd);

        if (pchrCoordXBegin < pchrCoordXEnd - 1) and (pchrCoordXBegin^ = '0') then
          Inc(pchrCoordXBegin);

        if (pchrCoordYBegin < pchrCoordYEnd - 1) and (pchrCoordYBegin^ = '0') then
          Inc(pchrCoordYBegin);

        MoveString(pchrCoordXBegin^, ACoordX, pchrCoordXEnd - pchrCoordXBegin + 1);
        MoveString(pchrCoordYBegin^, ACoordY, pchrCoordYEnd - pchrCoordYBegin + 1);

        Result := True;
      end;
    end;
  end;

  procedure ChangeSystemPrefix(var ACoord: AnsiString);
  var
    pchrSystem: PAnsiChar;
    fiFormat: TFormatInteger = fiUnsignedDecimal;
  begin
    if Length(ACoord) > 2 then
    begin
      pchrSystem := @ACoord[1];

      if pchrSystem^ in ['A' .. 'Z'] then
        Inc(pchrSystem^, 32);

      case pchrSystem^ of
        'x': fiFormat := fiHexadecimal;
        'o': fiFormat := fiOctal;
        'b': fiFormat := fiBinary;
      end;

      if fiFormat <> fiUnsignedDecimal then
        pchrSystem^ := INTEGER_PASCAL_SYSTEM_PREFIXES[fiFormat];
    end;
  end;

var
  intCoordXCode, intCoordYCode: Integer;
  strCoordX, strCoordY: AnsiString;
begin
  if ExtractPointCoords(AValue, strCoordX, strCoordY) then
  begin
    ChangeSystemPrefix(strCoordX);
    ChangeSystemPrefix(strCoordY);

    Val(strCoordX, Result.X, intCoordXCode);
    Val(strCoordY, Result.Y, intCoordYCode);

    if (intCoordXCode <> 0) or (intCoordYCode <> 0) then
      Result := ADefault;
  end
  else
    Result := ADefault;
end;


{ ----- list conversions ------------------------------------------------------------------------------------------ }


procedure ListToValue(AList: TStrings; out AValue: AnsiString);
var
  strValue: AnsiString = '';
  I: UInt32;
begin
  if AList.Count > 0 then
  begin
    strValue := AList[0];

    for I := 1 to AList.Count - 1 do
      strValue += VALUES_DELIMITER + AList[I];

    if strValue = '' then
      strValue := ONE_BLANK_VALUE_LINE_CHAR;
  end;

  AValue := strValue;
end;


procedure ValueToList(AValue: AnsiString; AList: TStrings);
var
  vcValue: TValueComponents;
  intCompCnt: UInt32;
  I: Integer;
begin
  SetLength(vcValue, 0);
  ExtractValueComponents(AValue, vcValue, intCompCnt);

  AList.BeginUpdate();

  try
    for I := 0 to intCompCnt - 1 do
      AList.Add(vcValue[I]);
  finally
    AList.EndUpdate();
  end;
end;


{ ----- buffer & stream conversions ------------------------------------------------------------------------------- }


procedure BufferToValue(const ABuffer; ASize: UInt32; out AValue: AnsiString; AFormat: TFormatBuffer);
var
  arrBuffer: TByteDynArray;
  intValueLen, intWholePiecesCnt, I: UInt32;
  pintToken: PByte;
  pchrToken, pchrLast: PAnsiChar;
  strHexByte: AnsiString;
begin
  if ASize = 0 then Exit;

  intWholePiecesCnt := ASize div BUFFER_SIZES[AFormat];

  if intWholePiecesCnt * BUFFER_SIZES[AFormat] < ASize then
    intValueLen := ASize * 2 + intWholePiecesCnt
  else
    if intWholePiecesCnt = 0 then
      intValueLen := ASize * 2
    else
      {$HINTS OFF}
      intValueLen := ASize * 2 + intWholePiecesCnt - 1;
      {$HINTS ON}

  SetLength(AValue, intValueLen);
  SetLength(arrBuffer, ASize);
  Move(ABuffer, arrBuffer[0], ASize);

  pintToken := @arrBuffer[0];
  pchrToken := @AValue[1];
  pchrLast := @AValue[intValueLen];

  while pchrToken < pchrLast do
  begin
    I := 0;

    while (I < BUFFER_SIZES[AFormat]) and (pchrToken < pchrLast) do
    begin
      strHexByte := HexStr(pintToken^, 2);
      Move(strHexByte[1], pchrToken^, 2);
      Inc(pintToken);
      Inc(pchrToken, 2);
      Inc(I);
    end;

    if pchrToken < pchrLast then
    begin
      Move(PAnsiChar(VALUES_DELIMITER)^, pchrToken^, 1);
      Inc(pchrToken);
    end;
  end;
end;


procedure ValueToBuffer(AValue: AnsiString; var ABuffer; ASize, AOffset: UInt32);
var
  arrBuffer: TByteDynArray;
  pintToken: PByte;
  pchrToken, pchrBufferLast, pchrValueLast: PAnsiChar;
  strHexByte: AnsiString = '$00';
  intValueLen: UInt32;
  intCode: Integer;
begin
  if ASize = 0 then Exit;

  AValue := ReplaceSubStrings(AValue, VALUES_DELIMITER, '');
  intValueLen := Length(AValue);

  if intValueLen > 0 then
  begin
    SetLength(arrBuffer, ASize);
    FillChar(arrBuffer[0], ASize, 0);

    pintToken := @arrBuffer[0];
    pchrToken := @AValue[AOffset * 2 + 1];
    pchrBufferLast := pchrToken + ASize * 2;
    pchrValueLast := @AValue[intValueLen];

    while (pchrToken < pchrBufferLast) and (pchrToken < pchrValueLast) do
    begin
      Move(pchrToken^, strHexByte[2], 2);
      Val(strHexByte, pintToken^, intCode);
      Inc(pintToken);
      Inc(pchrToken, 2);
    end;

    Move(arrBuffer[0], ABuffer, ASize);
  end;
end;


function IsCurrentNodeSymbol(APath: AnsiString): Boolean;
begin
  Result := (APath = '') or (APath = CURRENT_NODE_SYMBOL);
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

