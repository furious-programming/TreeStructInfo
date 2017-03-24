{

    TSInfoUtils.pp                  last modified: 27 June 2016

    Copyright © Jarosław Baran, furious programming 2013 - 2016.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Includes a set of functions for two-way data conversion (type to string
    and vice versa) of all types supported by TreeStructInfo files. Also
    contains a common procedures and functions needed for correct handling
    of TreeStructInfo files.
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

{$MODE OBJFPC}{$LONGSTRINGS ON}


interface

uses
  TSInfoConsts, TSInfoTypes, LazUTF8, SysUtils, DateUtils, Classes, Math, Types;


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


  procedure ThrowException(const AMessage: String);
  procedure ThrowException(const AMessage: String; const AArgs: array of const);

  function Comment(const ADeclaration, ADefinition: String): TComment;
  function RemoveWhitespaceChars(const AValue: String): String;

  function ReplaceSubStrings(const AValue, AOldPattern, ANewPattern: String): String;
  function GlueStrings(const AMask: String; const AStrings: array of String): String;

  procedure MoveString(const ASource; out ADest: String; ALength: Integer);

  function ValidIdentifier(const AIdentifier: String): Boolean;
  function SameIdentifiers(const AFirst, ASecond: String): Boolean;

  function IncludeTrailingIdentsDelimiter(const APath: String): String;
  function ExcludeTrailingIdentsDelimiter(const APath: String): String;

  function ExtractPathComponent(const AAttrName: String; AComponent: TPathComponent): String;
  procedure ExtractValueComponents(const AValue: String; out AComponents: TValueComponents; out ACount: Integer);

  function IsCurrentNodePath(const APath: String): Boolean;
  function PathWithoutLastNodeName(const APath: String): String;


{ ----- class for data convertion --------------------------------------------------------------------------------- }


type
  TTSInfoDataConverter = class(TObject)
  public
    class function BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): String;
    class function ValueToBoolean(const AValue: String; ADefault: Boolean): Boolean;
  public
    class function IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): String;
    class function ValueToInteger(const AValue: String; ADefault: Integer): Integer;
  public
    class function FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): String;
    class function ValueToFloat(const AValue: String; ASettings: TFormatSettings; ADefault: Double): Double;
  public
    class function CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): String;
    class function ValueToCurrency(const AValue: String; ASettings: TFormatSettings; ADefault: Currency): Currency;
  public
    class function StringToValue(const AString: String; AFormat: TFormatString): String;
    class function ValueToString(const AValue: String; AFormat: TFormatString): String;
  public
    class function DateTimeToValue(const AMask: String; ADateTime: TDateTime; ASettings: TFormatSettings): String;
    class function ValueToDateTime(const AMask, AValue: String; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;
  public
    class function PointToValue(APoint: TPoint; AFormat: TFormatPoint): String;
    class function ValueToPoint(const AValue: String; ADefault: TPoint): TPoint;
  public
    class procedure ListToValue(AList: TStrings; out AValue: String);
    class procedure ValueToList(const AValue: String; AList: TStrings);
  public
    class procedure BufferToValue(const ABuffer; ASize: Integer; out AValue: String; AFormat: TFormatBuffer);
    class procedure ValueToBuffer(const AValue: String; var ABuffer; ASize, AOffset: Integer);
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- common procedures & functions ----------------------------------------------------------------------------- }


procedure ThrowException(const AMessage: String);
begin
  raise ETSInfoFileException.Create(AMessage);
end;


procedure ThrowException(const AMessage: String; const AArgs: array of const);
begin
  raise ETSInfoFileException.CreateFmt(AMessage, AArgs);
end;


function Comment(const ADeclaration, ADefinition: String): TComment;
begin
  Result[ctDeclaration] := ADeclaration;
  Result[ctDefinition] := ADefinition;
end;


function RemoveWhitespaceChars(const AValue: String): String;
var
  LValueLen: Integer;
  LLeft, LRight: PChar;
begin
  Result := '';
  LValueLen := Length(AValue);

  if LValueLen > 0 then
  begin
    LLeft := @AValue[1];
    LRight := @AValue[LValueLen];

    while (LLeft <= LRight) and (LLeft^ in WHITESPACE_CHARS) do
      LLeft += 1;

    while (LRight > LLeft) and (LRight^ in WHITESPACE_CHARS) do
      LRight -= 1;

    MoveString(LLeft^, Result, LRight - LLeft + 1);
  end;
end;


function ReplaceSubStrings(const AValue, AOldPattern, ANewPattern: String): String;
var
  LValueLen, LOldPtrnLen, LNewPtrnLen, LPlainLen, LResultLen, LResultIdx: Integer;
  LPlainBegin, LPlainEnd, LLast, LResult: PChar;
begin
  LValueLen := Length(AValue);

  if LValueLen = 0 then Exit('');
  if AOldPattern = '' then Exit(AValue);

  SetLength(Result, 0);

  LOldPtrnLen := Length(AOldPattern);
  LNewPtrnLen := Length(ANewPattern);
  LResultLen := 0;

  LPlainBegin := @AValue[1];
  LPlainEnd := LPlainBegin;
  LLast := @AValue[LValueLen - LOldPtrnLen + 1];

  while LPlainEnd <= LLast do
    if (LPlainEnd^ = AOldPattern[1]) and (CompareByte(LPlainEnd^, AOldPattern[1], LOldPtrnLen) = 0) then
    begin
      LPlainLen := LPlainEnd - LPlainBegin;
      LResultIdx := LResultLen + 1;
      LResultLen += LPlainLen + LNewPtrnLen;

      SetLength(Result, LResultLen);
      LResult := @Result[LResultIdx];
      Move(LPlainBegin^, LResult^, LPlainLen);

      LResult += LPlainLen;
      Move(ANewPattern[1], LResult^, LNewPtrnLen);
      LResult += LNewPtrnLen;

      LPlainEnd += LOldPtrnLen;
      LPlainBegin := LPlainEnd;
    end
    else
      LPlainEnd += 1;

  if LPlainBegin <= LPlainEnd then
    Result += String(LPlainBegin);
end;


function GlueStrings(const AMask: String; const AStrings: array of String): String;
const
  MASK_FORMAT_CHAR = '%';
var
  LToken, LLast: PChar;
  LStringIdx: Integer = 0;
  LResultLen: Integer = 0;
  LStringLen: Integer;
begin
  LToken := @AMask[1];
  LLast := @AMask[Length(AMask)];

  while LToken <= LLast do
  begin
    if LToken^ = MASK_FORMAT_CHAR then
    begin
      LStringLen := Length(AStrings[LStringIdx]);
      SetLength(Result, LResultLen + LStringLen);
      Move(AStrings[LStringIdx][1], Result[LResultLen + 1], LStringLen);

      LResultLen += LStringLen;
      LStringIdx += 1;
    end
    else
    begin
      Result += INDENT_CHAR;
      LResultLen += 1;
    end;

    LToken += 1;
  end;
end;


procedure MoveString(const ASource; out ADest: String; ALength: Integer);
begin
  SetLength(ADest, ALength);
  Move(ASource, ADest[1], ALength);
end;


function ValidIdentifier(const AIdentifier: String): Boolean;
var
  LToken: Char;
begin
  Result := False;

  if AIdentifier = '' then
    ThrowException(EM_EMPTY_IDENTIFIER)
  else
  begin
    for LToken in AIdentifier do
      if LToken in INVALID_IDENT_CHARS then
        ThrowException(EM_INCORRECT_IDENTIFIER_CHARACTER, [LToken, Ord(LToken)]);

    Result := True;
  end;
end;


function SameIdentifiers(const AFirst, ASecond: String): Boolean;
begin
  Result := AFirst = ASecond;
end;


function IncludeTrailingIdentsDelimiter(const APath: String): String;
begin
  Result := APath;

  if (APath <> '') and (APath[Length(APath)] <> IDENTS_DELIMITER) then
    Result += IDENTS_DELIMITER;
end;


function ExcludeTrailingIdentsDelimiter(const APath: String): String;
begin
  if (APath <> '') and (APath[Length(APath)] = IDENTS_DELIMITER) then
    MoveString(APath[1], Result, Length(APath) - 1)
  else
    Result := APath;
end;


function ExtractPathComponent(const AAttrName: String; AComponent: TPathComponent): String;
var
  LValueLen: Integer;
  LFirst, LToken, LLast: PChar;
begin
  Result := '';
  LValueLen := Length(AAttrName);

  if LValueLen > 0 then
  begin
    LFirst := @AAttrName[1];
    LLast := @AAttrName[LValueLen];
    LToken := LLast;

    while (LToken > LFirst) and (LToken^ <> IDENTS_DELIMITER) do
      LToken -= 1;

    case AComponent of
      pcAttributeName:
        if LToken^ = IDENTS_DELIMITER then
          MoveString(PChar(LToken + 1)^, Result, LLast - LToken)
        else
          Result := AAttrName;
      pcAttributePath:
        if LToken^ = IDENTS_DELIMITER then
          MoveString(LFirst^, Result, LToken - LFirst + 1);
    end;
  end;
end;


procedure ExtractValueComponents(const AValue: String; out AComponents: TValueComponents; out ACount: Integer);
var
  LBegin, LToken, LLast: PChar;
  LValue: String;
begin
  ACount := 0;
  SetLength(AComponents, 0);

  if AValue <> '' then
    if AValue = ONE_BLANK_VALUE_LINE_CHAR then
    begin
      SetLength(AComponents, 1);
      AComponents[0] := ONE_BLANK_VALUE_LINE_CHAR;
      ACount := 1;
    end
    else
    begin
      LValue := AValue + VALUES_DELIMITER;

      LBegin := @LValue[1];
      LToken := LBegin;
      LLast := @LValue[Length(LValue)];

      while LToken <= LLast do
        if LToken^ = VALUES_DELIMITER then
        begin
          SetLength(AComponents, ACount + 1);
          MoveString(LBegin^, AComponents[ACount], LToken - LBegin);

          ACount += 1;
          LToken += 1;
          LBegin := LToken;
        end
        else
          LToken += 1;
    end;
end;


function IsCurrentNodePath(const APath: String): Boolean;
begin
  Result := (APath = '') or (APath = CURRENT_NODE_SYMBOL);
end;


function PathWithoutLastNodeName(const APath: String): String;
var
  LFirst, LToken: PChar;
begin
  Result := '';

  if APath <> '' then
  begin
    LFirst := @APath[1];
    LToken := @APath[Length(APath) - 2];

    while (LToken >= LFirst) and (LToken^ <> IDENTS_DELIMITER) do
      LToken -= 1;

    if LToken > LFirst then
      MoveString(LFirst^, Result, LToken - LFirst + 1);
  end;
end;


{ ----- TTSInfoDataConverter class -------------------------------------------------------------------------------- }


{ ----- boolean convertions ------------------------------- }


class function TTSInfoDataConverter.BooleanToValue(ABoolean: Boolean; AFormat: TFormatBoolean): String;
begin
  Result := BOOLEAN_VALUES[ABoolean, AFormat];
end;


class function TTSInfoDataConverter.ValueToBoolean(const AValue: String; ADefault: Boolean): Boolean;
var
  LToken, LLast: PChar;
  LFormat: TFormatBoolean;
begin
  Result := ADefault;

  if AValue <> '' then
  begin
    LToken := @AValue[1];
    LLast := @AValue[Length(AValue)];

    if LToken^ in SMALL_LETTERS then
      Dec(LToken^, 32);

    LToken += 1;

    while LToken <= LLast do
    begin
      if LToken^ in CAPITAL_LETTERS then
        Inc(LToken^, 32);

      LToken += 1;
    end;

    for LFormat in TFormatBoolean do
      if SameIdentifiers(AValue, BOOLEAN_VALUES[True, LFormat]) then
        Exit(True)
      else
        if SameIdentifiers(AValue, BOOLEAN_VALUES[False, LFormat]) then
          Exit(False);
  end;
end;


{ ----- integer conversions ------------------------------- }


class function TTSInfoDataConverter.IntegerToValue(AInteger: Integer; AFormat: TFormatInteger): String;
var
  LIsNegative: Boolean;
  LRawValue: String;
  LRawValueLen, LRawValueMinLen: Integer;
  LNonZeroDigit, LLast: PChar;
begin
  if AFormat in [fiUnsignedDecimal, fiSignedDecimal] then
  begin
    Str(AInteger, Result);

    if (AFormat = fiSignedDecimal) and (AInteger > 0) then
      Result := '+' + Result;
  end
  else
  begin
    LIsNegative := AInteger < 0;
    AInteger := Abs(AInteger);

    case AFormat of
      fiHexadecimal: LRawValue := HexStr(AInteger, SizeOf(Integer) * 2);
      fiOctal:       LRawValue := OctStr(AInteger, SizeOf(Integer) * 3);
      fiBinary:      LRawValue := BinStr(AInteger, SizeOf(Integer) * 8);
    end;

    LRawValueLen := Length(LRawValue);
    LRawValueMinLen := INTEGER_MIN_LENGTHS[AFormat] - 1;

    LNonZeroDigit := @LRawValue[1];
    LLast := @LRawValue[LRawValueLen];

    while (LNonZeroDigit < LLast - LRawValueMinLen) and (LNonZeroDigit^ = '0') do
      LNonZeroDigit += 1;

    LRawValueLen := LLast - LNonZeroDigit + 1;
    SetLength(Result, LRawValueLen + 2 + Ord(LIsNegative));
    Move(LNonZeroDigit^, Result[3 + Ord(LIsNegative)], LRawValueLen);
    Move(INTEGER_UNIVERSAL_SYSTEM_PREFIXES[AFormat][1], Result[1 + Ord(LIsNegative)], 2);

    if LIsNegative then
      Result[1] := '-';
  end;
end;


class function TTSInfoDataConverter.ValueToInteger(const AValue: String; ADefault: Integer): Integer;
var
  LToken, LLast: PChar;
  LValue: String;
  LValueLen, LCode: Integer;
  LIsNegative: Boolean = False;
  LFormat: TFormatInteger = fiUnsignedDecimal;
begin
  LValue := AValue;
  LValueLen := Length(LValue);

  if LValueLen > 2 then
  begin
    LToken := @AValue[1];
    LLast := @AValue[LValueLen];

    if LToken^ = '-' then
    begin
      LIsNegative := True;
      LToken += 1;
    end;

    if LToken^ = '0' then
    begin
      LToken += 1;

      if LToken^ in CAPITAL_LETTERS then
        Inc(LToken^, 32);

      if LToken^ in NUMERICAL_SYSTEM_CHARS then
      begin
        case LToken^ of
          'x': LFormat := fiHexadecimal;
          'o': LFormat := fiOctal;
          'b': LFormat := fiBinary;
        end;

        LValueLen := LLast - LToken;
        SetLength(LValue, LValueLen + 1);
        Move(PChar(LToken + 1)^, LValue[2], LValueLen);
        LValue[1] := INTEGER_PASCAL_SYSTEM_PREFIXES[LFormat];
      end;
    end;
  end;

  Val(LValue, Result, LCode);

  if LCode <> 0 then
    Result := ADefault
  else
    if LIsNegative and (LFormat in [fiHexadecimal, fiOctal, fiBinary]) then
      Result := -Result;
end;


{ ----- float conversions --------------------------------- }


class function TTSInfoDataConverter.FloatToValue(AFloat: Double; AFormat: TFormatFloat; ASettings: TFormatSettings): String;
var
  LMustBeSigned: Boolean;
begin
  LMustBeSigned := AFormat in [ffSignedGeneral, ffSignedExponent, ffSignedNumber];

  if IsInfinite(AFloat) then
  begin
    if AFloat = Infinity then
    begin
      if LMustBeSigned then
        Exit(SIGNED_INFINITY_VALUE)
      else
        Exit(UNSIGNED_INFINITY_VALUE);
    end
    else
      Exit(NEGATIVE_INFINITY_VALUE);
  end
  else
    if IsNan(AFloat) then
      Exit(NOT_A_NUMBER_VALUE);

  Result := FloatToStrF(AFloat, FLOAT_FORMATS[AFormat], 15, 10, ASettings);

  if LMustBeSigned and (CompareValue(AFloat, 0) = GreaterThanValue) then
    Result := '+' + Result;
end;


class function TTSInfoDataConverter.ValueToFloat(const AValue: String; ASettings: TFormatSettings; ADefault: Double): Double;
var
  LToken, LLast: PChar;
begin
  if not TryStrToFloat(AValue, Result, ASettings) then
  begin
    Result := ADefault;

    if Length(AValue) >= 3 then
    begin
      LToken := @AValue[1];
      LLast := @AValue[Length(AValue)];

      if LToken^ in PLUS_MINUS_CHARS then
        LToken += 1;

      if LToken^ in SMALL_LETTERS then
        Dec(LToken^, 32);

      LToken += 1;

      while (LToken <= LLast) do
        if LToken^ in CAPITAL_LETTERS then
        begin
          Inc(LToken^, 32);
          LToken += 1;
        end
        else
          Break;

      if (AValue = UNSIGNED_INFINITY_VALUE) or (AValue = SIGNED_INFINITY_VALUE) then
        Exit(Infinity);

      if AValue = NEGATIVE_INFINITY_VALUE then
        Exit(NegInfinity);

      if AValue = NOT_A_NUMBER_VALUE then
        Exit(NaN);
    end;
  end;
end;


{ ----- currency converions ------------------------------- }


class function TTSInfoDataConverter.CurrencyToValue(ACurrency: Currency; AFormat: TFormatCurrency; ASettings: TFormatSettings): String;
begin
  case AFormat of
    fcUnsignedPrice, fcSignedPrice:
      Result := CurrToStrF(ACurrency, ffCurrency, 2, ASettings);
    fcUnsignedExchangeRate, fcSignedExchangeRate:
      Result := CurrToStrF(ACurrency, ffCurrency, 4, ASettings);
  end;

  if (AFormat in [fcSignedPrice, fcSignedExchangeRate]) and (ACurrency > 0) then
    Result := '+' + Result;
end;


class function TTSInfoDataConverter.ValueToCurrency(const AValue: String; ASettings: TFormatSettings; ADefault: Currency): Currency;
var
  LValueLen, LCurrStringLen: Integer;
  LFirst, LToken, LLast: PChar;
  LValue: String;
begin
  LValueLen := Length(AValue);

  if LValueLen = 0 then
    Result := ADefault
  else
  begin
    LCurrStringLen := Length(ASettings.CurrencyString);

    if (LCurrStringLen > 0) and (LValueLen > LCurrStringLen) then
    begin
      LFirst := @AValue[1];
      LLast := @AValue[LValueLen];
      LToken := LLast - LCurrStringLen + 1;

      MoveString(LToken^, LValue, LLast - LToken + 1);

      if CompareStr(LValue, ASettings.CurrencyString) = 0 then
      begin
        repeat
          LToken -= 1;
        until LToken^ in NUMBER_CHARS;

        MoveString(LFirst^, LValue, LToken - LFirst + 1);
      end
      else
        LValue := AValue;
    end
    else
      LValue := AValue;

    if not TryStrToCurr(LValue, Result, ASettings) then
      Result := ADefault;
  end;
end;


{ ----- string conversion --------------------------------- }


class function TTSInfoDataConverter.StringToValue(const AString: String; AFormat: TFormatString): String;
begin
  case AFormat of
    fsOriginal:  Result := AString;
    fsLowerCase: Result := UTF8LowerCase(AString);
    fsUpperCase: Result := UTF8UpperCase(AString);
  end;
end;


class function TTSInfoDataConverter.ValueToString(const AValue: String; AFormat: TFormatString): String;
begin
  case AFormat of
    fsOriginal:  Result := AValue;
    fsLowerCase: Result := UTF8LowerCase(AValue);
    fsUpperCase: Result := UTF8UpperCase(AValue);
  end;
end;


{ ----- date & time conversions --------------------------- }


class function TTSInfoDataConverter.DateTimeToValue(const AMask: String; ADateTime: TDateTime; ASettings: TFormatSettings): String;
var
  LMaskLen, LResultLen, LFormatLen: UInt32;
  LMaskToken, LMaskLast: PChar;
  LFormat: Char;
  LMask: String;
  LResult: String = '';
  L12HourClock: Boolean = False;

  procedure IncreaseMaskCharacters();
  begin
    while (LMaskToken < LMaskLast) do
    begin
      if LMaskToken^ in SMALL_LETTERS then
        Dec(LMaskToken^, 32)
      else
        if LMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          LFormat := LMaskToken^;

          repeat
            LMaskToken += 1;
          until (LMaskToken = LMaskLast) or (LMaskToken^ = LFormat);
        end;

      LMaskToken += 1;
    end;

    LMaskToken := @LMask[1];
  end;

  procedure GetClockInfo();
  begin
    while (LMaskToken < LMaskLast) do
      if LMaskToken^ = 'A' then
      begin
        L12HourClock := True;
        Break;
      end
      else
        LMaskToken += 1;

    LMaskToken := @LMask[1];
  end;

  procedure SaveString(const AString: String);
  var
    LStringLen: UInt32;
  begin
    LStringLen := Length(AString);
    SetLength(LResult, LResultLen + LStringLen);
    Move(AString[1], LResult[LResultLen + 1], LStringLen);
    LResultLen += LStringLen;
  end;

  procedure SaveNumber(const ANumber, ADigits: UInt16);
  var
    LNumber: String;
  begin
    Str(ANumber, LNumber);
    LNumber := StringOfChar('0', ADigits - Length(LNumber)) + LNumber;
    SaveString(LNumber);
  end;

  procedure GetFormatInfo();
  begin
    LFormat := LMaskToken^;
    LFormatLen := 0;

    repeat
      LFormatLen += 1;
      LMaskToken += 1;
    until (LMaskToken = LMaskLast) or (LMaskToken^ <> LFormat);
  end;

var
  LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond, LDayOfWeek: UInt16;
begin
  LMaskLen := Length(AMask);

  if LMaskLen > 0 then
  begin
    LMask := AMask + #32;
    LMaskLen += 1;
    LResultLen := 0;
    LMaskToken := @LMask[1];
    LMaskLast := @LMask[LMaskLen];

    IncreaseMaskCharacters();
    GetClockInfo();

    DecodeDateTime(ADateTime, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond);
    LDayOfWeek := DayOfWeek(ADateTime);

    while LMaskToken < LMaskLast do
    begin
      if LMaskToken^ in DATE_TIME_FORMAT_CHARS then
      begin
        GetFormatInfo();

        case LFormat of
          'Y': case LFormatLen of
                 2: SaveNumber(LYear mod 100, 2);
                 4: SaveNumber(LYear, 4);
               end;
          'M': case LFormatLen of
                 1, 2: SaveNumber(LMonth, LFormatLen);
                 3:    SaveString(ASettings.ShortMonthNames[LMonth]);
                 4:    SaveString(ASettings.LongMonthNames[LMonth]);
               end;
          'D': case LFormatLen of
                 1, 2: SaveNumber(LDay, LFormatLen);
                 3:    SaveString(ASettings.ShortDayNames[LDayOfWeek]);
                 4:    SaveString(ASettings.LongDayNames[LDayOfWeek]);
               end;
          'H': case LFormatLen of
                 1, 2: if L12HourClock then
                       begin
                         if LHour < 12 then
                           SaveNumber(IfThen(LHour = 0, 12, LHour), LFormatLen)
                         else
                           SaveNumber(IfThen(LHour = 12, LHour, LHour - 12), LFormatLen);
                       end
                       else
                         SaveNumber(LHour, LFormatLen);
               end;
          'N': case LFormatLen of
                 1, 2: SaveNumber(LMinute, LFormatLen);
               end;
          'S': case LFormatLen of
                 1, 2: SaveNumber(LSecond, LFormatLen);
               end;
          'Z': case LFormatLen of
                 1, 3: SaveNumber(LMillisecond, LFormatLen);
               end;
          'A': begin
                 if LHour < 12 then
                   SaveString(ASettings.TimeAMString)
                 else
                   SaveString(ASettings.TimePMString);

                 LMaskToken += 4;
               end;
        end;
      end
      else
        if LMaskToken^ in DATE_TIME_SEPARATOR_CHARS then
        begin
          case LMaskToken^ of
            '.', '-', '/': SaveString(ASettings.DateSeparator);
            ':':           SaveString(ASettings.TimeSeparator);
          end;

          LMaskToken += 1;
        end
        else
          if LMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
          begin
            LFormat := LMaskToken^;
            LMaskToken += 1;

            repeat
              SaveString(LMaskToken^);
              LMaskToken += 1;
            until (LMaskToken = LMaskLast) or (LMaskToken^ = LFormat);

            LMaskToken += 1;
          end
          else
          begin
            SaveString(LMaskToken^);
            LMaskToken += 1;
          end;
    end;
  end;

  Result := LResult;
end;


class function TTSInfoDataConverter.ValueToDateTime(const AMask, AValue: String; ASettings: TFormatSettings; ADefault: TDateTime): TDateTime;
var
  LValueLen, LMaskLen: Integer;
  LMaskToken, LMaskLast: PChar;
  LValueBegin, LValueEnd, LValueLast: PChar;
  LValue, LMask: String;
  LFormat: Char;

  procedure IncreaseMaskCharacters();
  begin
    while (LMaskToken < LMaskLast) do
    begin
      if LMaskToken^ in SMALL_LETTERS then
        Dec(LMaskToken^, 32)
      else
        if LMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          LFormat := LMaskToken^;

          repeat
            LMaskToken += 1;
          until (LMaskToken = LMaskLast) or (LMaskToken^ = LFormat);
        end;

      LMaskToken += 1;
    end;

    LMaskToken := @LMask[1];
  end;

var
  LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond: UInt16;

  procedure InitDateTimeComponents();
  begin
    DecodeDateTime(0, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond);
  end;

var
  LFormatSep: Char;
  LFormatLen: UInt32 = 0;
  LFormatVal: String = '';

  procedure GetFormatInfo();
  begin
    LFormat := LMaskToken^;

    if LFormat = 'A' then
      LMaskToken += 5
    else
    begin
      LFormatLen := 0;

      repeat
        LFormatLen += 1;
        LMaskToken += 1;
      until (LMaskToken = LMaskLast) or (LMaskToken^ <> LFormat);
    end;

    if LMaskToken^ in DATE_TIME_SEPARATOR_CHARS then
    begin
      case LMaskToken^ of
        '.', '-', '/': LFormatSep := ASettings.DateSeparator;
        ':':           LFormatSep := ASettings.TimeSeparator;
      end;

      Exit();
    end;

    if LMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
      LMaskToken += 1;

    LFormatSep := LMaskToken^;
  end;

  procedure GetFormatValue();
  begin
    while LValueEnd^ <> LFormatSep do
      LValueEnd += 1;

    MoveString(LValueBegin^, LFormatVal, LValueEnd - LValueBegin);
    LValueBegin := LValueEnd;
  end;

  function StringToNumber(const AString: String): UInt16;
  var
    LCode: Integer;
  begin
    Val(AString, Result, LCode);

    if LCode <> 0 then
      Result := 0;
  end;

  function MonthNameToNumber(const AName: String; const AMonthNames: TMonthNameArray): Integer;
  var
    LNameLen: Integer;
    LMonthIdx: Integer = 1;
  begin
    Result := 1;
    LNameLen := Length(AName);

    while LMonthIdx <= High(AMonthNames) do
      if (LNameLen = Length(AMonthNames[LMonthIdx])) and
         (CompareStr(AName, AMonthNames[LMonthIdx]) = 0) then
      begin
        Result := LMonthIdx + 1;
        Break;
      end
      else
        LMonthIdx += 1;
  end;

  procedure IncrementMaskAndValueTokens();
  begin
    LMaskToken += 1;
    LValueBegin += 1;
    LValueEnd += 1;
  end;

var
  L12HourClock: Boolean = False;
  LIsAMHour: Boolean = False;
  LPivot: UInt16;
begin
  LMask := AMask;
  LValue := AValue;

  if (LMask <> '') and (LValue <> '') then
  begin
    InitDateTimeComponents();

    LMask += #32;
    LValue += #32;
    LMaskLen := Length(LMask);
    LValueLen := Length(LValue);

    LMaskToken := @LMask[1];
    LMaskLast := @LMask[LMaskLen];
    LValueBegin := @LValue[1];
    LValueEnd := LValueBegin;
    LValueLast := @LValue[LValueLen];

    IncreaseMaskCharacters();

    while (LMaskToken < LMaskLast) and (LValueEnd < LValueLast) do
      if LMaskToken^ in DATE_TIME_FORMAT_CHARS then
      begin
        GetFormatInfo();
        GetFormatValue();

        case LFormat of
          'Y': case LFormatLen of
                 2: begin
                      LYear := StringToNumber(LFormatVal);
                      LPivot := YearOf(Now()) - ASettings.TwoDigitYearCenturyWindow;
                      LYear += LPivot div 100 * 100;

                      if (ASettings.TwoDigitYearCenturyWindow > 0) and (LYear < LPivot) then
                        LYear += 100;
                    end;
                 4: LYear := StringToNumber(LFormatVal);
               end;
          'M': case LFormatLen of
                 1, 2: LMonth := StringToNumber(LFormatVal);
                 3:    LMonth := MonthNameToNumber(LFormatVal, ASettings.ShortMonthNames);
                 4:    LMonth := MonthNameToNumber(LFormatVal, ASettings.LongMonthNames);
               end;
          'D': case LFormatLen of
                 1, 2: LDay := StringToNumber(LFormatVal);
               end;
          'H': case LFormatLen of
                 1, 2: LHour := StringToNumber(LFormatVal);
               end;
          'N': case LFormatLen of
                 1, 2: LMinute := StringToNumber(LFormatVal);
               end;
          'S': case LFormatLen of
                 1, 2: LSecond := StringToNumber(LFormatVal);
               end;
          'Z': case LFormatLen of
                 1, 3: LMillisecond := StringToNumber(LFormatVal);
               end;
          'A': begin
                 L12HourClock := True;
                 LIsAMHour := LFormatVal = ASettings.TimeAMString;
               end;
        end;
      end
      else
        if LMaskToken^ in DATE_TIME_PLAIN_TEXT_CHARS then
        begin
          LFormat := LMaskToken^;
          LMaskToken += 1;

          repeat
            IncrementMaskAndValueTokens();
          until (LMaskToken = LMaskLast) or (LMaskToken^ = LFormat);

          LMaskToken += 1;
        end
        else
          IncrementMaskAndValueTokens();

    if L12HourClock then
      if LIsAMHour then
      begin
        if LHour = 12 then
          LHour := 0;
      end
      else
        if LHour < 12 then
          LHour += 12;

    if not TryEncodeDateTime(LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond, Result) then
      Result := ADefault;
  end
  else
    Result := ADefault;
end;


{ ----- point conversions --------------------------------- }


class function TTSInfoDataConverter.PointToValue(APoint: TPoint; AFormat: TFormatPoint): String;
var
  LCoordX, LCoordY: String;
begin
  LCoordX := IntegerToValue(APoint.X, POINT_SYSTEMS[AFormat]);
  LCoordY := IntegerToValue(APoint.Y, POINT_SYSTEMS[AFormat]);

  Result := LCoordX + COORDS_DELIMITER + LCoordY;
end;


class function TTSInfoDataConverter.ValueToPoint(const AValue: String; ADefault: TPoint): TPoint;

  procedure ExtractPointCoord(AFirst, ALast: PChar; out ACoord: String); inline;
  var
    LNegOffset: UInt8;
    LSystem: PChar;
    LFormat: TFormatInteger;
  begin
    if ALast - AFirst + 1 >= MIN_NO_DECIMAL_VALUE_LEN then
    begin
      LNegOffset := Ord(AFirst^ = '-');
      LSystem := AFirst + LNegOffset;

      if (LSystem^ = '0') and (PChar(LSystem + 1)^ in NUMERICAL_SYSTEM_CHARS) then
      begin
        LSystem += 1;

        case LSystem^ of
          'x': LFormat := fiHexadecimal;
          'o': LFormat := fiOctal;
          'b': LFormat := fiBinary;
        end;

        SetLength(ACoord, ALast - LSystem + 1 + LNegOffset);
        Move(LSystem^, ACoord[1 + LNegOffset], ALast - LSystem + 1);
        ACoord[1 + LNegOffset] := INTEGER_PASCAL_SYSTEM_PREFIXES[LFormat];

        if Boolean(LNegOffset) then
          ACoord[1] := '-';

        Exit();
      end;
    end;

    MoveString(AFirst^, ACoord, ALast - AFirst + 1);
  end;

var
  LFirst, LLast, LDelimiter: PChar;
  LCoordX, LCoordY: String;
  LValueLen, LCoordXCode, LCoordYCode: Integer;
begin
  LValueLen := Length(AValue);

  if LValueLen >= MIN_POINT_VALUE_LEN then
  begin
    LFirst := @AValue[1];
    LLast := @AValue[LValueLen];
    LDelimiter := LFirst + 1;

    while (LDelimiter < LLast) and (LDelimiter^ <> COORDS_DELIMITER) do
      LDelimiter += 1;

    if LDelimiter < LLast then
    begin
      ExtractPointCoord(LFirst, LDelimiter - 1, LCoordX);
      ExtractPointCoord(LDelimiter + 1, LLast, LCoordY);

      Val(LCoordX, Result.X, LCoordXCode);
      Val(LCoordY, Result.Y, LCoordYCode);

      if (LCoordXCode = 0) and (LCoordYCode = 0) then
        Exit();
    end;
  end;

  Result := ADefault;
end;


{ ----- list conversions ---------------------------------- }


class procedure TTSInfoDataConverter.ListToValue(AList: TStrings; out AValue: String);
var
  LLineIdx: Integer;
begin
  if AList.Count = 0 then
    AValue := ''
  else
    if (AList.Count = 1) and (AList[0] = '') then
      AValue := ONE_BLANK_VALUE_LINE_CHAR
    else
    begin
      AValue := AList[0];

      for LLineIdx := 1 to AList.Count - 1 do
        AValue += VALUES_DELIMITER + AList[LLineIdx];
    end;
end;


class procedure TTSInfoDataConverter.ValueToList(const AValue: String; AList: TStrings);
var
  LComponents: TValueComponents;
  LCompCnt, LCompIdx: Integer;
begin
  ExtractValueComponents(AValue, LComponents, LCompCnt);

  AList.BeginUpdate();
  try
    for LCompIdx := 0 to LCompCnt - 1 do
      AList.Add(LComponents[LCompIdx]);
  finally
    AList.EndUpdate();
  end;
end;


{ ----- buffer & stream conversions ----------------------- }


class procedure TTSInfoDataConverter.BufferToValue(const ABuffer; ASize: Integer; out AValue: String; AFormat: TFormatBuffer);
const
  HEX_CHARS: array [0 .. 15] of Char = '0123456789ABCDEF';
var
  LBuffer: TByteDynArray;
  LValueLen, LByteIdx: Integer;
  LByte: PUInt8;
  LToken, LLast: PChar;
begin
  if ASize <= 0 then Exit();

  SetLength(LBuffer, ASize);
  Move(ABuffer, LBuffer[0], ASize);

  LValueLen := (ASize * 2) + ((ASize - 1) div UInt8(AFormat));
  SetLength(AValue, LValueLen);

  LByte := @LBuffer[0];
  LToken := @AValue[1];
  LLast := @AValue[LValueLen];

  while LToken < LLast do
  begin
    LByteIdx := 0;

    while (LByteIdx < UInt8(AFormat)) and (LToken < LLast) do
    begin
      PChar(LToken + 0)^ := HEX_CHARS[LByte^ shr 4 and 15];
      PChar(LToken + 1)^ := HEX_CHARS[LByte^ and 15];

      LByte += 1;
      LByteIdx += 1;
      LToken += 2;
    end;

    if LToken < LLast then
    begin
      LToken^ := VALUES_DELIMITER;
      LToken += 1;
    end;
  end;
end;


class procedure TTSInfoDataConverter.ValueToBuffer(const AValue: String; var ABuffer; ASize, AOffset: Integer);
var
  LBuffer: TByteDynArray;
  LValue: String;
  LValueLen: Integer;
  LByte: PUInt8;
  LToken, LBufferLast, LValueLast: PChar;
begin
  if ASize <= 0 then Exit();

  LValue := ReplaceSubStrings(AValue, VALUES_DELIMITER, '');
  LValueLen := Length(LValue);

  if LValueLen > 0 then
  begin
    SetLength(LBuffer, ASize);
    FillChar(LBuffer[0], ASize, 0);

    LByte := @LBuffer[0];
    LToken := @LValue[AOffset * 2 + 1];
    LBufferLast := LToken + ASize * 2;
    LValueLast := @LValue[LValueLen];

    while (LToken <= LBufferLast) and (LToken <= LValueLast) do
    begin
      if LToken^ in NUMBER_CHARS then
        Dec(LToken^, 48)
      else
        if LToken^ in HEX_LETTERS then
          Dec(LToken^, 55)
        else
          Exit();

      LToken += 1;
    end;

    LToken := @LValue[AOffset * 2 + 1];

    while (LToken < LBufferLast) and (LToken < LValueLast) do
    begin
      LByte^ := UInt8(LToken^) shl 4 or PUInt8(LToken + 1)^;
      LByte += 1;
      LToken += 2;
    end;

    Move(LBuffer[0], ABuffer, ASize);
  end;
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

