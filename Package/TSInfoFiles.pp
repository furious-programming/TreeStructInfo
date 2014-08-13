{

    TSInfoFiles.pp                  last modified: 13 August 2014

    Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Contains a set of classes to handle TreeStructInfo files. The following
    classes are used to handle files and to make any changes, accordance
    with the documentation of the format in version '1.0'.
   __________________________________________________________________________

    For more informations about TreeStructInfo file format and the following
    library, see <http://www.treestruct.info>.

    You can write to <support@treestruct.info> if you have any questions,
    or to <bugs@treestruct.info> if you find a bugs in this library.

    Write to <join@treestruct.info> if you use this library and want to it
    announce publicly.
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


unit TSInfoFiles;

{$MODE OBJFPC} {$LONGSTRINGS ON} {$PACKENUM 1} {$HINTS ON}


interface

uses
  TSInfoUtils, TSInfoTypes, TSInfoConsts, SysUtils, Classes, Types, Math, FileUtil;


type
  TBaseTSInfoElementsList = class(TObject)
  private
    FElementsList: PTSInfoElementsList;
    FSize: Integer;
    FCount: Integer;
  private
    procedure SetNewListSize(ANewSize: Integer);
  public
    constructor Create();
    destructor Destroy(); override;
  public
    procedure AddElement(AInstance: TObject);
    procedure RemoveElement(AIndex: Integer);
    procedure ClearElementsList();
  public
    property Count: Integer read FCount;
  end;


type
  TTSInfoAttribute = class(TObject)
  private
    FReference: Boolean;
    FName: AnsiString;
    FValue: AnsiString;
    FComment: TComment;
  private
    function GetComment(AType: TCommentType): AnsiString;
    procedure SetComment(AType: TCommentType; AValue: AnsiString);
  public
    constructor Create(AReference: Boolean; AName: AnsiString); overload;
    constructor Create(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment); overload;
  public
    property Reference: Boolean read FReference write FReference;
    property Name: AnsiString read FName write FName;
    property Value: AnsiString read FValue write FValue;
    property Comment[AType: TCommentType]: AnsiString read GetComment write SetComment;
  end;


type
  TTSInfoAttributesList = class(TBaseTSInfoElementsList)
  private
    function InternalAddItem(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetItemByName(AName: AnsiString): TTSInfoAttribute;
    function GetItemByIndex(AIndex: UInt32): TTSInfoAttribute;
  public
    function AddItem(AReference: Boolean; AName: AnsiString): TTSInfoAttribute; overload;
    function AddItem(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute; overload;
  public
    procedure RemoveItem(AName: AnsiString);
    procedure ClearList();
  end;


type
  TTSInfoNodesList = class;
  TTSInfoLink      = class;
  TTSInfoLinksList = class;

type
  TTSInfoNode = class(TObject)
  private
    FParentNode: TTSInfoNode;
    FReference: Boolean;
    FName: AnsiString;
    FComment: TComment;
    FAttributesList: TTSInfoAttributesList;
    FChildNodesList: TTSInfoNodesList;
    FLinksList: TTSInfoLinksList;
  private
    function GetComment(AType: TCommentType): AnsiString;
    procedure SetComment(AType: TCommentType; AValue: AnsiString);
  public
    function GetAttributeByName(AName: AnsiString): TTSInfoAttribute;
    function GetAttributeByIndex(AIndex: UInt32): TTSInfoAttribute;
    function GetChildNodeByName(AName: AnsiString): TTSInfoNode;
    function GetChildNodeByIndex(AIndex: UInt32): TTSInfoNode;
    function GetLinkByIndex(AIndex: UInt32): TTSInfoLink;
    function GetLinkByVirtualNodeName(AVirtualNodeName: AnsiString): TTSInfoLink;
    function GetVirtualNodeByName(AName: AnsiString): TTSInfoNode;
  public
    function GetAttributesCount(): UInt32;
    function GetChildNodesCount(): UInt32;
    function GetLinksCount(): UInt32;
  public
    constructor Create(AParentNode: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment);
    destructor Destroy(); override;
  public
    function CreateAttribute(AReference: Boolean; AName: AnsiString): TTSInfoAttribute; overload;
    function CreateAttribute(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute; overload;
    function CreateChildNode(AReference: Boolean; AName: AnsiString): TTSInfoNode; overload;
    function CreateChildNode(AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode; overload;
    function CreateLink(AFileName: TFileName; AVirtualNodeName: AnsiString): TTSInfoLink; overload;
    function CreateLink(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink; overload;
  public
    procedure RemoveAttribute(AName: AnsiString);
    procedure RemoveChildNode(AName: AnsiString);
    procedure RemoveLink(AVirtualNodeName: AnsiString);
  public
    procedure ClearAttributes();
    procedure ClearChildNodes();
    procedure ClearLinks();
  public
    property ParentNode: TTSInfoNode read FParentNode;
    property Reference: Boolean read FReference write FReference;
    property Name: AnsiString read FName write FName;
    property Comment[AType: TCommentType]: AnsiString read GetComment write SetComment;
    property AttributesCount: UInt32 read GetAttributesCount;
    property ChildNodesCount: UInt32 read GetChildNodesCount;
    property LinksCount: UInt32 read GetLinksCount;
  end;


type
  TTSInfoNodesList = class(TBaseTSInfoElementsList)
  private
    function InternalAddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetItemByName(AName: AnsiString): TTSInfoNode;
    function GetItemByIndex(AIndex: UInt32): TTSInfoNode;
  public
    function AddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString): TTSInfoNode; overload;
    function AddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode; overload;
  public
    procedure RemoveItem(AName: AnsiString);
    procedure ClearList();
  end;


type
  TSimpleTSInfoFile = class;

type
  TTSInfoLink = class(TObject)
  private
    FLinkedFile: TSimpleTSInfoFile;
    FVirtualNode: TTSInfoNode;
    FVirtualNodeName: AnsiString;
    FComment: AnsiString;
  private
    procedure SetLinkedFileFlags(AFlags: TFileFlags);
  private
    function GetLinkedFileName(): TFileName;
    function GetLinkedFileFlags(): TFileFlags;
  public
    constructor Create(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString);
    destructor Destroy(); override;
  public
    property LinkedFile: TSimpleTSInfoFile read FLinkedFile;
    property VirtualNode: TTSInfoNode read FVirtualNode;
    property VirtualNodeName: AnsiString read FVirtualNodeName write FVirtualNodeName;
    property Comment: AnsiString read FComment write FComment;
    property FileName: TFileName read GetLinkedFileName;
    property FileFlags: TFileFlags read GetLinkedFileFlags write SetLinkedFileFlags;
  end;


type
  TTSInfoLinksList = class(TBaseTSInfoElementsList)
  private
    function InternalAddItem(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetItemByIndex(AIndex: UInt32): TTSInfoLink;
    function GetItemByVirtualNodeName(AVirtualNodeName: AnsiString): TTSInfoLink;
    function GetVirtualNodeByName(AName: AnsiString): TTSInfoNode;
  public
    function AddItem(AFileName: TFileName; AVirtualNodeName: AnsiString): TTSInfoLink; overload;
    function AddItem(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink; overload;
  public
    procedure RemoveItemByVirtualNodeName(AVirtualNodeName: AnsiString);
    procedure ClearList();
  end;


type
  TTSInfoAttributeToken = object
  private
    FAttribute: TTSInfoAttribute;
    FParentNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): AnsiString;
    procedure SetComment(AType: TCommentType; AValue: AnsiString);
  public
    property Name: AnsiString read FAttribute.FName;
    property Reference: Boolean read FAttribute.FReference write FAttribute.FReference;
    property Value: AnsiString read FAttribute.FValue write FAttribute.FValue;
    property Comment[AType: TCommentType]: AnsiString read GetComment write SetComment;
  end;


type
  TTSInfoChildNodeToken = object
  private
    FChildNode: TTSInfoNode;
    FParentNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): AnsiString;
    procedure SetComment(AType: TCommentType; AValue: AnsiString);
  public
    property Name: AnsiString read FChildNode.FName;
    property Reference: Boolean read FChildNode.FReference write FChildNode.FReference;
    property Comment[AType: TCommentType]: AnsiString read GetComment write SetComment;
  end;


type
  TSimpleTSInfoFile = class(TObject)
  private
    FRootNode: TTSInfoNode;
    FCurrentNode: TTSInfoNode;
    FFileName: TFileName;
    FTreeName: AnsiString;
    FTreeComment: AnsiString;
    FCurrentlyOpenNodePath: AnsiString;
    FFileFlags: TFileFlags;
    FModified: Boolean;
    FReadOnlyMode: Boolean;
  protected
    procedure InitFields(AFileName: TFileName; AFlags: TFileFlags);
    procedure DamageClear();
  protected
    procedure LoadTreeFromList(AList: TStrings);
    procedure LoadTreeFromStream(AStream: TStream);
    procedure SaveTreeToList(AList: TStrings);
    procedure SaveTreeToStream(AStream: TStream);
  protected
    function FindElement(AElementName: AnsiString; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
    function FindAttribute(AAttrName: AnsiString; AForcePath: Boolean): TTSInfoAttribute;
    function FindNode(ANodePath: AnsiString; AForcePath: Boolean): TTSInfoNode;
  public
    constructor Create(AFileName: TFileName; AFlags: TFileFlags = [ffLoadFile, ffUpdatable]); overload;
    constructor Create(AInput: TStrings; AFileName: TFileName = ''; AFlags: TFileFlags = []); overload;
    constructor Create(AInput: TStream; AFileName: TFileName = ''; AFlags: TFileFlags = []); overload;
    constructor Create(AInstance: TFPResourceHMODULE; AResName: String; AResType: PAnsiChar; AFlags: TFileFlags = []); overload;
    constructor Create(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PAnsiChar; AFlags: TFileFlags = []); overload;
    destructor Destroy(); override;
  public
    function OpenChildNode(ANodePath: AnsiString; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
    procedure CloseChildNode();
  public
    procedure WriteBoolean(AAttrName: AnsiString; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
    procedure WriteInteger(AAttrName: AnsiString; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
    procedure WriteFloat(AAttrName: AnsiString; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteFloat(AAttrName: AnsiString; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteCurrency(AAttrName: AnsiString; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteCurrency(AAttrName: AnsiString; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteString(AAttrName: AnsiString; AString: AnsiString; AFormat: TFormatString = fsOriginal);
    procedure WriteDateTime(AAttrName: AnsiString; ADateTime: TDateTime; AMask: AnsiString); overload;
    procedure WriteDateTime(AAttrName: AnsiString; ADateTime: TDateTime; AMask: AnsiString; ASettings: TFormatSettings); overload;
    procedure WritePoint(AAttrName: AnsiString; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
    procedure WriteList(AAttrName: AnsiString; AList: TStrings);
    procedure WriteBuffer(AAttrName: AnsiString; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
    procedure WriteStream(AAttrName: AnsiString; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
  public
    function ReadBoolean(AAttrName: AnsiString; ADefault: Boolean): Boolean;
    function ReadInteger(AAttrName: AnsiString; ADefault: Integer): Integer;
    function ReadFloat(AAttrName: AnsiString; ADefault: Double): Double; overload;
    function ReadFloat(AAttrName: AnsiString; ADefault: Double; ASettings: TFormatSettings): Double; overload;
    function ReadCurrency(AAttrName: AnsiString; ADefault: Currency): Currency; overload;
    function ReadCurrency(AAttrName: AnsiString; ADefault: Currency; ASettings: TFormatSettings): Currency; overload;
    function ReadString(AAttrName: AnsiString; ADefault: AnsiString; AFormat: TFormatString = fsOriginal): AnsiString;
    function ReadDateTime(AAttrName, AMask: AnsiString; ADefault: TDateTime): TDateTime; overload;
    function ReadDateTime(AAttrName, AMask: AnsiString; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime; overload;
    function ReadPoint(AAttrName: AnsiString; ADefault: TPoint): TPoint;
    procedure ReadList(AAttrName: AnsiString; AList: TStrings);
    procedure ReadBuffer(AAttrName: AnsiString; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
    procedure ReadStream(AAttrName: AnsiString; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
  public
    function CreateAttribute(ANodePath: AnsiString; AReference: Boolean; AAttrName: AnsiString): Boolean;
    function CreateChildNode(ANodePath: AnsiString; AReference: Boolean; ANodeName: AnsiString; AOpen: Boolean = False): Boolean;
    function CreateLink(ANodePath: AnsiString; AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AOpen: Boolean = False): Boolean;
  public
    function FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; AParentNodePath: AnsiString = ''): Boolean;
    function FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
    function FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; AParentNodePath: AnsiString = ''): Boolean;
    function FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
  public
    procedure UpdateFile();
  public
    property FileName: TFileName read FFileName;
    property TreeName: AnsiString read FTreeName;
    property CurrentlyOpenNodeName: AnsiString read FCurrentNode.FName;
    property CurrentlyOpenNodePath: AnsiString read FCurrentlyOpenNodePath;
    property FileFlags: TFileFlags read FFileFlags write FFileFlags;
    property Modified: Boolean read FModified;
    property ReadOnlyMode: Boolean read FReadOnlyMode;
  end;


type
  TTSInfoFile = class(TSimpleTSInfoFile)
  public
    procedure RenameTree(ANewTreeName: AnsiString);
    procedure RenameAttribute(AAttrName, ANewAttrName: AnsiString);
    procedure RenameChildNode(ANodePath, ANewNodeName: AnsiString);
    procedure RenameVirtualNode(ANodePath, AVirtualNodeName, ANewVirtualNodeName: AnsiString);
  public
    procedure WriteTreeComment(AComment, ADelimiter: AnsiString);
    procedure WriteAttributeComment(AAttrName, AComment, ADelimiter: AnsiString; AType: TCommentType);
    procedure WriteChildNodeComment(ANodePath, AComment, ADelimiter: AnsiString; AType: TCommentType);
    procedure WriteLinkComment(ANodePath, AVirtualNodeName, AComment, ADelimiter: AnsiString);
  public
    function ReadTreeComment(ADelimiter: AnsiString): AnsiString;
    function ReadAttributeComment(AAttrName, ADelimiter: AnsiString; AType: TCommentType): AnsiString;
    function ReadChildNodeComment(ANodePath, ADelimiter: AnsiString; AType: TCommentType): AnsiString;
    function ReadLinkComment(ANodePath, AVirtualNodeName, ADelimiter: AnsiString): AnsiString;
  public
    procedure WriteAttributeReference(AAttrName: AnsiString; AReference: Boolean);
    procedure WriteChildNodeReference(ANodePath: AnsiString; AReference: Boolean);
  public
    function ReadAttributeReference(AAttrName: AnsiString): Boolean;
    function ReadChildNodeReference(ANodePath: AnsiString = ''): Boolean;
  public
    procedure RemoveAttribute(AAttrName: AnsiString);
    procedure RemoveChildNode(ANodePath: AnsiString);
    procedure RemoveLink(ANodePath, AVirtualNodeName: AnsiString);
  public
    procedure RemoveAllAttributes(ANodePath: AnsiString = '');
    procedure RemoveAllChildNodes(ANodePath: AnsiString = '');
    procedure RemoveAllLinks(ANodePath: AnsiString = '');
  public
    procedure ClearChildNode(ANodePath: AnsiString = '');
    procedure ClearTree();
  public
    function AttributeExists(AAttrName: AnsiString): Boolean;
    function ChildNodeExists(ANodePath: AnsiString): Boolean;
    function LinkExists(ANodePath, AVirtualNodeName: AnsiString): Boolean;
  public
    function GetAttributesCount(ANodePath: AnsiString = ''): UInt32;
    function GetChildNodesCount(ANodePath: AnsiString = ''): UInt32;
    function GetLinksCount(ANodePath: AnsiString = ''): UInt32;
  public
    procedure ReadAttributesNames(ANodePath: AnsiString; ANames: TStrings);
    procedure ReadAttributesValues(ANodePath: AnsiString; AValues: TStrings);
    procedure ReadChildNodesNames(ANodePath: AnsiString; ANames: TStrings);
    procedure ReadVirtualNodesNames(ANodePath: AnsiString; ANames: TStrings);
  public
    procedure ExportTreeToFile(AFileName: TFileName; AFormat: TExportFormat = efTextFile);
    procedure ExportTreeToList(AList: TStrings);
    procedure ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryFile);
  end;


type
  TCustomTSInfoInputReader = class(TObject)
  private
    FTSInfoFile: TSimpleTSInfoFile;
  public
    procedure ProcessInput(); virtual; abstract;
  end;


type
  TCustomTSInfoOutputWriter = class(TObject)
  private
    FTSInfoFile: TSimpleTSInfoFile;
  public
    procedure ProcessOutput(); virtual; abstract;
  end;


type
  TTSInfoTextInputReader = class(TCustomTSInfoInputReader)
  private
    FInput: TStrings;
    FLineIndex: Integer;
    FEndTreeLineIndex: Integer;
    FComment: TComment;
  private
    procedure PrepareSourceLines();
    procedure MarkComments();
    procedure MoveRefAttributeDefLines();
    procedure MoveRefNodeDefLines();
  private
    function FormatVersionSupported(AFormatVersion: AnsiString): Boolean;
    function FindRefAttributeDefLine(AName: AnsiString): Integer;
    function FindRefNodeDefLine(AName: AnsiString): Integer;
  private
    function ExtractRefAttrNameFromDecLine(ALine: AnsiString): AnsiString;
    function ExtractRefAttrNameFromDefLine(ALine: AnsiString): AnsiString;
    function ExtractNextAttributeValue(ALine: AnsiString): AnsiString;
    function ExtractRefNodeName(ALine: AnsiString): AnsiString;
  private
    procedure ClearComment();
    procedure ExtractComment();
    procedure ExtractLineComponents(ALine: AnsiString; var AComponents: TValueComponents; out ACount: UInt32);
    procedure ExtractAttributeComponents(ALine: AnsiString; out AReference: Boolean; out AName, AValue: AnsiString);
    procedure ExtractNodeComponents(ALine: AnsiString; out AReference: Boolean; out AName: AnsiString);
  private
    procedure ComponentsToFlagsSet(AComponents: TValueComponents; var AFlags: TFileFlags);
  private
    function IsTreeHeaderLine(ALine: AnsiString): Boolean;
    function IsAttributeLine(ALine: AnsiString): Boolean;
    function IsAttributeValueLine(ALine: AnsiString): Boolean;
    function IsRefAttributeDecLine(ALine: AnsiString): Boolean;
    function IsRefAttributeDefLine(ALine: AnsiString): Boolean;
    function IsNodeLine(ALine: AnsiString): Boolean;
    function IsRefNodeLine(ALine: AnsiString): Boolean;
    function IsEndRefNodeLine(ALine: AnsiString): Boolean;
    function IsEndNodeLine(ALine: AnsiString): Boolean;
    function IsLinkLine(ALine: AnsiString): Boolean;
    function IsEndTreeLine(ALine: AnsiString): Boolean;
    function IsCommentLine(ALine: AnsiString): Boolean;
    function IsCommentMarkerLine(AMarker: TObject): Boolean;
  private
    procedure AnalyzeTreeHeader();
    procedure AddTreeComment();
    procedure AddAttribute();
    procedure AddNode();
    procedure AddLink();
    procedure CloseNode();
  private
    procedure ProcessLink(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoFile: TSimpleTSInfoFile; AInput: TStrings);
    destructor Destroy(); override;
  public
    procedure ProcessInput(); override;
  end;


type
  TTSInfoTextOutputWriter = class(TCustomTSInfoOutputWriter)
  private
    FOutput: TStrings;
    FRefCount: UInt32;
    FLastMovedRefType: TLastMovedRefType;
  private
    function MakeRefTag(ARefType: TReferenceType; AIndex: Integer): Integer;
    function ExtractRefType(ARefTag: Integer): TReferenceType;
    function ExtractRefIndex(ARefTag: Integer): Integer;
    function GetNextRefIndex(): Integer;
  private
    function GetSingleIndent(): AnsiString;
    function IncIndent(AIndent: AnsiString): AnsiString;
  private
    procedure MoveRefAttributeDefinition(ALineIndex, ARefIndex: Integer);
    procedure MoveRefNodeDefinition(ALineIndex, AEndRefIndex: Integer; out ANewNodeIndex: Integer);
  private
    procedure ScanLinesToFindRefs(ALineIndex, AEndRefIndex: Integer);
    procedure AnalyzeNode(AParentNode: TTSInfoNode; AIndent: AnsiString);
  private
    procedure AddTreeHeaderLines();
    procedure AddAttributeLines(AAttr: TTSInfoAttribute; AIndent: AnsiString; ARefIndex: Integer);
    procedure AddNodeHeaderLines(ANode: TTSInfoNode; AIndent: AnsiString; ARefIndex: Integer);
    procedure AddEndNodeLine(ANode: TTSInfoNode; AIndent: AnsiString; ARefIndex: Integer);
    procedure AddLinkLines(ALink: TTSInfoLink; AIndent: AnsiString);
    procedure AddEndTreeLine();
    procedure AddCommentLines(AComment, AIndent: AnsiString); overload;
    procedure AddCommentLines(AComment, AIndent: AnsiString; ARefTag: Integer; AStyle: TTaggingStyle); overload;
  private
    procedure ProcessLink(ALink: TTSInfoLink);
    procedure LocateAndProcessLinks(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoFile: TSimpleTSInfoFile; AOutput: TStrings);
    destructor Destroy(); override;
  public
    procedure ProcessOutput(); override;
  end;


type
  TTSInfoBinaryInputReader = class(TCustomTSInfoInputReader)
  private
    FInput: TStream;
  protected
    procedure ReadStringBuffer(out ABuffer: AnsiString);
    procedure ReadBooleanBuffer(out ABuffer: Boolean);
    procedure ReadUInt32Buffer(out ABuffer: UInt32);
  private
    procedure ReadStaticHeader();
    procedure ReadAttribute(AAttribute: TTSInfoAttribute);
    procedure ReadNode(ANode: TTSInfoNode);
    procedure ReadLink(ALink: TTSInfoLink);
  private
    procedure ProcessLink(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoFile: TSimpleTSInfoFile; AInput: TStream);
    destructor Destroy(); override;
  public
    procedure ProcessInput(); override;
  end;


type
  TTSInfoBinaryOutputWriter = class(TCustomTSInfoOutputWriter)
  private
    FOutput: TStream;
  protected
    procedure WriteStringBuffer(ABuffer: AnsiString);
    procedure WriteBooleanBuffer(ABuffer: Boolean);
    procedure WriteUInt32Buffer(ABuffer: UInt32);
  private
    procedure WriteStaticHeader();
    procedure WriteAttribute(AAttribute: TTSInfoAttribute);
    procedure WriteNode(ANode: TTSInfoNode);
    procedure WriteLink(ALink: TTSInfoLink);
  private
    procedure ProcessLink(ALink: TTSInfoLink);
    procedure LocateAndProcessLinks(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoFile: TSimpleTSInfoFile; AOutput: TStream);
    destructor Destroy(); override;
  public
    procedure ProcessOutput(); override;
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TBaseTSInfoElementsList class ----------------------------------------------------------------------------- }


constructor TBaseTSInfoElementsList.Create();
begin
  inherited Create();

  FElementsList := nil;
  FSize := 0;
  FCount := 0;
end;


destructor TBaseTSInfoElementsList.Destroy();
begin
  ClearElementsList();
  inherited Destroy();
end;


procedure TBaseTSInfoElementsList.SetNewListSize(ANewSize: Integer);
var
  ptrNewList: PTSInfoElementsList;
  intMoveSize: SizeInt;
begin
  if ANewSize > 0 then
  begin
    GetMem(ptrNewList, ANewSize * SizeOf(TObject));

    intMoveSize := FSize * SizeOf(TObject);
    Move(FElementsList^, ptrNewList^, intMoveSize);
    FillChar(ptrNewList^[intMoveSize], (ANewSize - FSize) * SizeOf(TObject), 0);
    FreeMem(FElementsList, intMoveSize);

    FElementsList := ptrNewList;
    FSize := ANewSize;
  end
  else
  begin
    FreeMem(FElementsList, FSize * SizeOf(TObject));
    FElementsList := nil;
    FSize := 0;
  end;
end;


procedure TBaseTSInfoElementsList.AddElement(AInstance: TObject);
begin
  if FCount = FSize then
    SetNewListSize(FSize + 16);

  FElementsList^[FCount] := AInstance;
  Inc(FCount);
end;


procedure TBaseTSInfoElementsList.RemoveElement(AIndex: Integer);
begin
  FreeAndNil(FElementsList^[AIndex]);
  Dec(FCount);

  if AIndex < FCount then
    Move(FElementsList^[AIndex + 1], FElementsList^[AIndex], (FCount - AIndex) * SizeOf(TObject));
end;


procedure TBaseTSInfoElementsList.ClearElementsList();
var
  I: Integer = 0;
begin
  if FElementsList <> nil then
  begin
    while I < FCount do
    begin
      FreeAndNil(FElementsList^[I]);
      Inc(I);
    end;

    FCount := 0;
    SetNewListSize(0);
  end;
end;


{ ----- TTSInfoAttribute class ------------------------------------------------------------------------------------ }


constructor TTSInfoAttribute.Create(AReference: Boolean; AName: AnsiString);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := '';
  FComment[ctDeclaration] := '';
  FComment[ctDefinition] := '';
end;


constructor TTSInfoAttribute.Create(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := AValue;
  FComment := AComment;
end;


function TTSInfoAttribute.GetComment(AType: TCommentType): AnsiString;
begin
  Result := FComment[AType];
end;


procedure TTSInfoAttribute.SetComment(AType: TCommentType; AValue: AnsiString);
begin
  FComment[AType] := AValue;
end;


{ ----- TTSInfoAttributeList class -------------------------------------------------------------------------------- }


constructor TTSInfoAttributesList.Create();
begin
  inherited Create();
end;


destructor TTSInfoAttributesList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoAttributesList.InternalAddItem(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute;
begin
  Result := TTSInfoAttribute.Create(AReference, AName, AValue, AComment);
  AddElement(Result);
end;


function TTSInfoAttributesList.GetItemByName(AName: AnsiString): TTSInfoAttribute;
var
  attrItem: TTSInfoAttribute;
  I: Integer = 0;
begin
  Result := nil;

  while I < FCount do
  begin
    attrItem := TTSInfoAttribute(FElementsList^[I]);

    if SameIdentifiers(attrItem.FName, AName) then
      Exit(attrItem);

    Inc(I);
  end;
end;


function TTSInfoAttributesList.GetItemByIndex(AIndex: UInt32): TTSInfoAttribute;
begin
  Result := TTSInfoAttribute(FElementsList^[AIndex]);
end;


function TTSInfoAttributesList.AddItem(AReference: Boolean; AName: AnsiString): TTSInfoAttribute;
begin
  Result := InternalAddItem(AReference, AName, '', Comment('', ''));
end;


function TTSInfoAttributesList.AddItem(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute;
begin
  Result := InternalAddItem(AReference, AName, AValue, AComment);
end;


procedure TTSInfoAttributesList.RemoveItem(AName: AnsiString);
var
  attrItem: TTSInfoAttribute;
  I: Integer = 0;
begin
  while I < FCount do
  begin
    attrItem := TTSInfoAttribute(FElementsList^[I]);

    if SameIdentifiers(attrItem.FName, AName) then
    begin
      RemoveElement(I);
      Exit;
    end;

    Inc(I);
  end;
end;


procedure TTSInfoAttributesList.ClearList();
begin
  ClearElementsList();
end;


{ ----- TTSInfoNode class ----------------------------------------------------------------------------------------- }


constructor TTSInfoNode.Create(AParentNode: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment);
begin
  inherited Create();

  FParentNode := AParentNode;
  FReference := AReference;
  FName := AName;
  FComment := AComment;

  FAttributesList := TTSInfoAttributesList.Create();
  FChildNodesList := TTSInfoNodesList.Create();
  FLinksList := TTSInfoLinksList.Create();
end;


destructor TTSInfoNode.Destroy();
begin
  FAttributesList.Free();
  FChildNodesList.Free();
  FLinksList.Free();

  inherited Destroy();
end;


function TTSInfoNode.GetComment(AType: TCommentType): AnsiString;
begin
  Result := FComment[AType];
end;


procedure TTSInfoNode.SetComment(AType: TCommentType; AValue: AnsiString);
begin
  FComment[AType] := AValue;
end;


function TTSInfoNode.GetAttributeByName(AName: AnsiString): TTSInfoAttribute;
begin
  Result := FAttributesList.GetItemByName(AName);
end;


function TTSInfoNode.GetAttributeByIndex(AIndex: UInt32): TTSInfoAttribute;
begin
  Result := FAttributesList.GetItemByIndex(AIndex);
end;


function TTSInfoNode.GetChildNodeByName(AName: AnsiString): TTSInfoNode;
begin
  Result := FChildNodesList.GetItemByName(AName);
end;


function TTSInfoNode.GetChildNodeByIndex(AIndex: UInt32): TTSInfoNode;
begin
  Result := FChildNodesList.GetItemByIndex(AIndex);
end;


function TTSInfoNode.GetLinkByIndex(AIndex: UInt32): TTSInfoLink;
begin
  Result := FLinksList.GetItemByIndex(AIndex);
end;


function TTSInfoNode.GetLinkByVirtualNodeName(AVirtualNodeName: AnsiString): TTSInfoLink;
begin
  Result := FLinksList.GetItemByVirtualNodeName(AVirtualNodeName);
end;


function TTSInfoNode.GetVirtualNodeByName(AName: AnsiString): TTSInfoNode;
begin
  Result := FLinksList.GetVirtualNodeByName(AName);
end;


function TTSInfoNode.GetAttributesCount(): UInt32;
begin
  Result := FAttributesList.Count;
end;


function TTSInfoNode.GetChildNodesCount(): UInt32;
begin
  Result := FChildNodesList.Count;
end;


function TTSInfoNode.GetLinksCount(): UInt32;
begin
  Result := FLinksList.Count;
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; AName: AnsiString): TTSInfoAttribute;
begin
  Result := FAttributesList.AddItem(AReference, AName);
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; AName, AValue: AnsiString; AComment: TComment): TTSInfoAttribute;
begin
  Result := FAttributesList.AddItem(AReference, AName, AValue, AComment);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; AName: AnsiString): TTSInfoNode;
begin
  Result := FChildNodesList.AddItem(Self, AReference, AName);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode;
begin
  Result := FChildNodesList.AddItem(Self, AReference, AName, AComment);
end;


function TTSInfoNode.CreateLink(AFileName: TFileName; AVirtualNodeName: AnsiString): TTSInfoLink;
begin
  Result := FLinksList.AddItem(AFileName, AVirtualNodeName, [], '');
end;


function TTSInfoNode.CreateLink(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink;
begin
  Result := FLinksList.AddItem(AFileName, AVirtualNodeName, AFlags, AComment);
end;


procedure TTSInfoNode.RemoveAttribute(AName: AnsiString);
begin
  FAttributesList.RemoveItem(AName);
end;


procedure TTSInfoNode.RemoveChildNode(AName: AnsiString);
begin
  FChildNodesList.RemoveItem(AName);
end;


procedure TTSInfoNode.RemoveLink(AVirtualNodeName: AnsiString);
begin
  FLinksList.RemoveItemByVirtualNodeName(AVirtualNodeName);
end;


procedure TTSInfoNode.ClearAttributes();
begin
  FAttributesList.ClearList();
end;

procedure TTSInfoNode.ClearChildNodes();
begin
  FChildNodesList.ClearList();
end;


procedure TTSInfoNode.ClearLinks();
begin
  FLinksList.ClearList();
end;


{ ----- TTSInfoNodesList class ------------------------------------------------------------------------------------ }


constructor TTSInfoNodesList.Create();
begin
  inherited Create();
end;


destructor TTSInfoNodesList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoNodesList.InternalAddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode;
begin
  Result := TTSInfoNode.Create(AParent, AReference, AName, AComment);
  AddElement(Result);
end;


function TTSInfoNodesList.GetItemByName(AName: AnsiString): TTSInfoNode;
var
  nodeItem: TTSInfoNode;
  I: Integer = 0;
begin
  Result := nil;

  while I < FCount do
  begin
    nodeItem := TTSInfoNode(FElementsList^[I]);

    if SameIdentifiers(nodeItem.FName, AName) then
      Exit(nodeItem);

    Inc(I);
  end;
end;


function TTSInfoNodesList.GetItemByIndex(AIndex: UInt32): TTSInfoNode;
begin
  Result := TTSInfoNode(FElementsList^[AIndex]);
end;


function TTSInfoNodesList.AddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString): TTSInfoNode;
begin
  Result := InternalAddItem(AParent, AReference, AName, Comment('', ''));
end;


function TTSInfoNodesList.AddItem(AParent: TTSInfoNode; AReference: Boolean; AName: AnsiString; AComment: TComment): TTSInfoNode;
begin
  Result := InternalAddItem(AParent, AReference, AName, AComment);
end;


procedure TTSInfoNodesList.RemoveItem(AName: AnsiString);
var
  nodeItem: TTSInfoNode;
  I: Integer = 0;
begin
  while I < FCount do
  begin
    nodeItem := TTSInfoNode(FElementsList^[I]);

    if SameIdentifiers(nodeItem.FName, AName) then
    begin
      RemoveElement(I);
      Exit;
    end;

    Inc(I);
  end;
end;


procedure TTSInfoNodesList.ClearList();
begin
  ClearElementsList();
end;


{ ----- TTSInfoLink class ----------------------------------------------------------------------------------------- }


constructor TTSInfoLink.Create(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString);
begin
  inherited Create();

  FLinkedFile := TSimpleTSInfoFile.Create(AFileName, []);
  FLinkedFile.FFileFlags := AFlags;
  FVirtualNode := FLinkedFile.FRootNode;
  FVirtualNodeName := AVirtualNodeName;
  FComment := AComment;
end;


destructor TTSInfoLink.Destroy();
begin
  FLinkedFile.FileFlags := [];
  FLinkedFile.Free();
  FVirtualNode := nil;

  inherited Destroy();
end;


procedure TTSInfoLink.SetLinkedFileFlags(AFlags: TFileFlags);
begin
  FLinkedFile.FFileFlags := AFlags;
end;


function TTSInfoLink.GetLinkedFileName(): TFileName;
begin
  Result := FLinkedFile.FFileName;
end;


function TTSInfoLink.GetLinkedFileFlags(): TFileFlags;
begin
  Result := FLinkedFile.FFileFlags;
end;


{ ----- TTSInfoLinksList class ------------------------------------------------------------------------------------ }


constructor TTSInfoLinksList.Create();
begin
  inherited Create();
end;


destructor TTSInfoLinksList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoLinksList.InternalAddItem(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink;
begin
  Result := TTSInfoLink.Create(AFileName, AVirtualNodeName, AFlags, AComment);
  AddElement(Result);
end;


function TTSInfoLinksList.GetItemByIndex(AIndex: UInt32): TTSInfoLink;
begin
  Result := TTSInfoLink(FElementsList^[AIndex]);
end;


function TTSInfoLinksList.GetItemByVirtualNodeName(AVirtualNodeName: AnsiString): TTSInfoLink;
var
  linkItem: TTSInfoLink;
  I: Integer = 0;
begin
  Result := nil;

  while I < FCount do
  begin
    linkItem := TTSInfoLink(FElementsList^[I]);

    if SameIdentifiers(linkItem.FVirtualNodeName, AVirtualNodeName) then
      Exit(linkItem);

    Inc(I);
  end;
end;


function TTSInfoLinksList.GetVirtualNodeByName(AName: AnsiString): TTSInfoNode;
var
  linkItem: TTSInfoLink;
begin
  Result := nil;
  linkItem := GetItemByVirtualNodeName(AName);

  if linkItem <> nil then
    Result := linkItem.VirtualNode;
end;


function TTSInfoLinksList.AddItem(AFileName: TFileName; AVirtualNodeName: AnsiString): TTSInfoLink;
begin
  Result := InternalAddItem(AFileName, AVirtualNodeName, [], '');
end;


function TTSInfoLinksList.AddItem(AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AComment: AnsiString): TTSInfoLink;
begin
  Result := InternalAddItem(AFileName, AVirtualNodeName, AFlags, AComment);
end;


procedure TTSInfoLinksList.RemoveItemByVirtualNodeName(AVirtualNodeName: AnsiString);
var
  linkItem: TTSInfoLink;
  I: Integer = 0;
begin
  while I < FCount do
  begin
    linkItem := TTSInfoLink(FElementsList^[I]);

    if SameIdentifiers(linkItem.FVirtualNodeName, AVirtualNodeName) then
    begin
      RemoveElement(I);
      Exit;
    end;

    Inc(I);
  end;
end;


procedure TTSInfoLinksList.ClearList();
begin
  ClearElementsList();
end;


{ ----- TTSInfoAttributeToken object ------------------------------------------------------------------------------ }


function TTSInfoAttributeToken.GetComment(AType: TCommentType): AnsiString;
begin
  Result := FAttribute.FComment[AType];
end;


procedure TTSInfoAttributeToken.SetComment(AType: TCommentType; AValue: AnsiString);
begin
  FAttribute.FComment[AType] := AValue;
end;


{ ----- TTSInfoChildNodeToken object ------------------------------------------------------------------------------ }


function TTSInfoChildNodeToken.GetComment(AType: TCommentType): AnsiString;
begin
  Result := FChildNode.FComment[AType];
end;


procedure TTSInfoChildNodeToken.SetComment(AType: TCommentType; AValue: AnsiString);
begin
  FChildNode.FComment[AType] := AValue;
end;


{ ----- TSimpleTSInfoFile class ----------------------------------------------------------------------------------- }


constructor TSimpleTSInfoFile.Create(AFileName: TFileName; AFlags: TFileFlags = [ffLoadFile, ffUpdatable]);
var
  fsInput: TStream;
  slInput: TStrings;
begin
  inherited Create();
  InitFields(AFileName, AFlags);

  if ffLoadFile in FFileFlags then
    if ffBinaryFile in FFileFlags then
    begin
      fsInput := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
      try
        LoadTreeFromStream(fsInput);
      finally
        fsInput.Free();
      end;
    end
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromFile(FFileName);
        LoadTreeFromList(slInput);
      finally
        slInput.Free();
      end;
    end;
end;


constructor TSimpleTSInfoFile.Create(AInput: TStrings; AFileName: TFileName = ''; AFlags: TFileFlags = []);
begin
  inherited Create();

  InitFields(AFileName, AFlags);
  LoadTreeFromList(AInput);
end;


constructor TSimpleTSInfoFile.Create(AInput: TStream; AFileName: TFileName = ''; AFlags: TFileFlags = []);
var
  slInput: TStrings;
begin
  inherited Create();
  InitFields(AFileName, AFlags);

  if ffBinaryFile in FFileFlags then
    LoadTreeFromStream(AInput)
  else
  begin
    slInput := TStringList.Create();
    try
      slInput.LoadFromStream(AInput);
      LoadTreeFromList(slInput);
    finally
      slInput.Free();
    end;
  end;
end;


constructor TSimpleTSInfoFile.Create(AInstance: TFPResourceHMODULE; AResName: String; AResType: PAnsiChar; AFlags: TFileFlags = []);
var
  rsInput: TStream;
  slInput: TStrings;
begin
  inherited Create();
  InitFields('', AFlags);

  rsInput := TResourceStream.Create(AInstance, AResName, AResType);
  try
    if ffBinaryFile in FFileFlags then
      LoadTreeFromStream(rsInput)
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromStream(rsInput);
        LoadTreeFromList(slInput);
      finally
        slInput.Free();
      end;
    end;
  finally
    rsInput.Free();
  end;
end;


constructor TSimpleTSInfoFile.Create(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PAnsiChar; AFlags: TFileFlags = []);
var
  rsInput: TStream;
  slInput: TStrings;
begin
  inherited Create();
  InitFields('', AFlags);

  rsInput := TResourceStream.CreateFromID(AInstance, AResID, AResType);
  try
    if ffBinaryFile in FFileFlags then
      LoadTreeFromStream(rsInput)
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromStream(rsInput);
        LoadTreeFromList(slInput);
      finally
        slInput.Free();
      end;
    end;
  finally
    rsInput.Free();
  end;
end;


destructor TSimpleTSInfoFile.Destroy();
begin
  if ffUpdatable in FFileFlags then
    UpdateFile();

  FRootNode.Free();
  inherited Destroy();
end;


procedure TSimpleTSInfoFile.InitFields(AFileName: TFileName; AFlags: TFileFlags);
begin
  FFileName := AFileName;
  FTreeName := '';
  FTreeComment := '';
  FCurrentlyOpenNodePath := '';

  FRootNode := TTSInfoNode.Create(nil, False, '', Comment('', ''));
  FCurrentNode := FRootNode;

  FFileFlags := AFlags;
  FReadOnlyMode := False;
end;


procedure TSimpleTSInfoFile.DamageClear();
begin
  FRootNode.ClearAttributes();
  FRootNode.ClearChildNodes();
  FRootNode.ClearLinks();

  FCurrentNode := FRootNode;
  FFileFlags := [];
end;


procedure TSimpleTSInfoFile.LoadTreeFromList(AList: TStrings);
begin
  with TTSInfoTextInputReader.Create(Self, AList) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoFile.LoadTreeFromStream(AStream: TStream);
begin
  with TTSInfoBinaryInputReader.Create(Self, AStream) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoFile.SaveTreeToList(AList: TStrings);
begin
  with TTSInfoTextOutputWriter.Create(Self, AList) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoFile.SaveTreeToStream(AStream: TStream);
begin
  with TTSInfoBinaryOutputWriter.Create(Self, AStream) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


function TSimpleTSInfoFile.FindElement(AElementName: AnsiString; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
var
  nodeRead, nodeTemp: TTSInfoNode;
  intPathLen: UInt32;
  pchrNameBgn, pchrNameEnd, pchrLast: PAnsiChar;
  strName: AnsiString;
begin
  Result := nil;
  intPathLen := Length(AElementName);

  if intPathLen > 0 then
  begin
    nodeRead := FCurrentNode;

    SetLength(strName, 0);
    pchrNameBgn := @AElementName[1];
    pchrNameEnd := pchrNameBgn;
    pchrLast := @AElementName[intPathLen];

    while (nodeRead = nil) or (pchrNameEnd <= pchrLast) do
    begin
      while (pchrNameEnd < pchrLast) and (pchrNameEnd^ <> IDENTS_DELIMITER) do
        Inc(pchrNameEnd);

      if (nodeRead <> nil) and (pchrNameEnd^ = IDENTS_DELIMITER) then
      begin
        MoveString(pchrNameBgn^, strName, pchrNameEnd - pchrNameBgn);

        if not IsCurrentNodeSymbol(strName) and ValidIdentifier(strName) then
        begin
          nodeTemp := nodeRead.GetChildNodeByName(strName);

          if nodeTemp = nil then
            nodeTemp := nodeRead.GetVirtualNodeByName(strName);

          if (nodeTemp = nil) and AForcePath then
            nodeTemp := nodeRead.CreateChildNode(False, strName);

          nodeRead := nodeTemp;
        end;

        Inc(pchrNameEnd);
        pchrNameBgn := pchrNameEnd;
      end
      else
        Break;
    end;

    if AReturnAttribute then
    begin
      if nodeRead <> nil then
      begin
        MoveString(pchrNameBgn^, strName, pchrNameEnd - pchrNameBgn + 1);

        if ValidIdentifier(strName) then
        begin
          Result := nodeRead.GetAttributeByName(strName);

          if (Result = nil) and AForcePath then
            Result := nodeRead.CreateAttribute(False, strName);
        end;
      end;
    end
    else
      Result := nodeRead;
  end;
end;


function TSimpleTSInfoFile.FindAttribute(AAttrName: AnsiString; AForcePath: Boolean): TTSInfoAttribute;
begin
  Result := FindElement(AAttrName, AForcePath, True) as TTSInfoAttribute;
end;


function TSimpleTSInfoFile.FindNode(ANodePath: AnsiString; AForcePath: Boolean): TTSInfoNode;
begin
  Result := FindElement(ANodePath, AForcePath, False) as TTSInfoNode;
end;


function TSimpleTSInfoFile.OpenChildNode(ANodePath: AnsiString; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
var
  nodeOpen: TTSInfoNode;
begin
  IncludeTrailingIdentsDelimiter(ANodePath);

  nodeOpen := FindNode(ANodePath, ACanCreate and not AReadOnly);
  Result := nodeOpen <> nil;

  if nodeOpen = nil then
    ThrowException(EM_CANNOT_OPEN_NODE, [ANodePath])
  else
  begin
    FCurrentNode := nodeOpen;
    FCurrentlyOpenNodePath := ANodePath;
    FReadOnlyMode := AReadOnly;
  end;
end;


procedure TSimpleTSInfoFile.CloseChildNode();
begin
  FCurrentNode := FRootNode;
  FCurrentlyOpenNodePath := '';
  FReadOnlyMode := False;
end;


procedure TSimpleTSInfoFile.WriteBoolean(AAttrName: AnsiString; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := BooleanToValue(ABoolean, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteInteger(AAttrName: AnsiString; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := IntegerToValue(AInteger, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteFloat(AAttrName: AnsiString; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := FloatToValue(ADouble, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteFloat(AAttrName: AnsiString; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := FloatToValue(ADouble, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteCurrency(AAttrName: AnsiString; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := CurrencyToValue(ACurrency, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteCurrency(AAttrName: AnsiString; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := CurrencyToValue(ACurrency, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteString(AAttrName: AnsiString; AString: AnsiString; AFormat: TFormatString = fsOriginal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := StringToValue(AString, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteDateTime(AAttrName: AnsiString; ADateTime: TDateTime; AMask: AnsiString);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := DateTimeToValue(ADateTime, AMask, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteDateTime(AAttrName: AnsiString; ADateTime: TDateTime; AMask: AnsiString; ASettings: TFormatSettings);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := DateTimeToValue(ADateTime, AMask, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WritePoint(AAttrName: AnsiString; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := PointToValue(APoint, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteList(AAttrName: AnsiString; AList: TStrings);
var
  attrWrite: TTSInfoAttribute;
  strValue: AnsiString;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, True);

    if attrWrite <> nil then
    begin
      ListToValue(AList, strValue);
      attrWrite.Value := strValue;
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoFile.WriteBuffer(AAttrName: AnsiString; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  strValue: AnsiString = '';
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
    if ASize > MAX_BUFFER_SIZE then
      ThrowException(EM_INVALID_BUFFER_SIZE, [MAX_BUFFER_SIZE])
    else
    begin
      ExcludeTrailingIdentsDelimiter(AAttrName);
      attrWrite := FindAttribute(AAttrName, True);

      if attrWrite <> nil then
      begin
        BufferToValue(ABuffer, ASize, strValue, AFormat);
        attrWrite.Value := strValue;
        FModified := True;
      end;
    end;
end;


procedure TSimpleTSInfoFile.WriteStream(AAttrName: AnsiString; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  arrBuffer: TByteDynArray;
  strValue: AnsiString = '';
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
    if AStream.Size > MAX_STREAM_SIZE then
      ThrowException(EM_INVALID_STREAM_SIZE, [MAX_STREAM_SIZE])
    else
    begin
      ExcludeTrailingIdentsDelimiter(AAttrName);
      attrWrite := FindAttribute(AAttrName, True);

      if attrWrite <> nil then
      begin
        SetLength(arrBuffer, ASize);
        AStream.Read(arrBuffer[0], ASize);

        BufferToValue(arrBuffer[0], ASize, strValue, AFormat);
        attrWrite.Value := strValue;
        FModified := True;
      end;
    end;
end;


function TSimpleTSInfoFile.ReadBoolean(AAttrName: AnsiString; ADefault: Boolean): Boolean;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToBoolean(attrRead.Value, ADefault);
end;


function TSimpleTSInfoFile.ReadInteger(AAttrName: AnsiString; ADefault: Integer): Integer;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToInteger(attrRead.Value, ADefault);
end;


function TSimpleTSInfoFile.ReadFloat(AAttrName: AnsiString; ADefault: Double): Double;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToFloat(attrRead.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoFile.ReadFloat(AAttrName: AnsiString; ADefault: Double; ASettings: TFormatSettings): Double;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToFloat(attrRead.Value, ASettings, ADefault);
end;


function TSimpleTSInfoFile.ReadCurrency(AAttrName: AnsiString; ADefault: Currency): Currency;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToCurrency(attrRead.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoFile.ReadCurrency(AAttrName: AnsiString; ADefault: Currency; ASettings: TFormatSettings): Currency;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToCurrency(attrRead.Value, ASettings, ADefault);
end;


function TSimpleTSInfoFile.ReadString(AAttrName: AnsiString; ADefault: AnsiString; AFormat: TFormatString = fsOriginal): AnsiString;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToString(attrRead.Value, AFormat);
end;


function TSimpleTSInfoFile.ReadDateTime(AAttrName, AMask: AnsiString; ADefault: TDateTime): TDateTime;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToDateTime(attrRead.Value, AMask, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoFile.ReadDateTime(AAttrName, AMask: AnsiString; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToDateTime(attrRead.Value, AMask, ASettings, ADefault);
end;


function TSimpleTSInfoFile.ReadPoint(AAttrName: AnsiString; ADefault: TPoint): TPoint;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToPoint(attrRead.Value, ADefault);
end;


procedure TSimpleTSInfoFile.ReadList(AAttrName: AnsiString; AList: TStrings);
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead <> nil then
    ValueToList(attrRead.Value, AList);
end;


procedure TSimpleTSInfoFile.ReadBuffer(AAttrName: AnsiString; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
var
  attrRead: TTSInfoAttribute;
begin
  if ASize > 0 then
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrRead := FindAttribute(AAttrName, False);

    if attrRead <> nil then
      ValueToBuffer(attrRead.Value, ABuffer, ASize, AOffset);
  end;
end;


procedure TSimpleTSInfoFile.ReadStream(AAttrName: AnsiString; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
var
  attrRead: TTSInfoAttribute;
  arrBuffer: TByteDynArray;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead <> nil then
  begin
    SetLength(arrBuffer, ASize);
    ValueToBuffer(attrRead.Value, arrBuffer[0], ASize, AOffset);

    AStream.Write(arrBuffer[0], ASize);
    AStream.Position := AStream.Position - ASize;
  end;
end;


function TSimpleTSInfoFile.CreateAttribute(ANodePath: AnsiString; AReference: Boolean; AAttrName: AnsiString): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  Result := False;

  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, True);
  end;

  if nodeParent <> nil then
    if ValidIdentifier(AAttrName) then
    begin
      nodeParent.CreateAttribute(AReference, AAttrName, '', Comment('', ''));
      FModified := True;
      Result := True;
    end;
end;


function TSimpleTSInfoFile.CreateChildNode(ANodePath: AnsiString; AReference: Boolean; ANodeName: AnsiString; AOpen: Boolean = False): Boolean;
var
  nodeParent, nodeCreate: TTSInfoNode;
begin
  Result := False;

  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, True);
  end;

  if nodeParent <> nil then
    if ValidIdentifier(ANodeName) then
    begin
      nodeCreate := nodeParent.CreateChildNode(AReference, ANodeName, Comment('', ''));

      if AOpen then
        FCurrentNode := nodeCreate;

      FModified := True;
      Result := True;
    end;
end;


function TSimpleTSInfoFile.CreateLink(ANodePath: AnsiString; AFileName: TFileName; AVirtualNodeName: AnsiString; AFlags: TFileFlags; AOpen: Boolean = False): Boolean;
var
  nodeParent: TTSInfoNode;
  linkCreate: TTSInfoLink;
  fsInput: TStream;
  slInput: TStrings;
begin
  Result := False;

  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, True);
  end;

  if nodeParent <> nil then
    if AFileName = '' then
      ThrowException(EM_EMPTY_LINK_FILE_NAME, [])
    else
      if ValidIdentifier(AVirtualNodeName) then
      begin
        linkCreate := nodeParent.CreateLink(AFileName, AVirtualNodeName, AFlags, '');

        if AOpen then
          FCurrentNode := linkCreate.FLinkedFile.FCurrentNode;

        FModified := True;
        Result := True;

        if (ffLoadFile in AFlags) and FileExistsUTF8(AFileName) then
          if ffBinaryFile in AFlags then
          begin
            fsInput := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
            try
              linkCreate.FLinkedFile.LoadTreeFromStream(fsInput);
            finally
              fsInput.Free();
            end;
          end
          else
          begin
            slInput := TStringList.Create();
            try
              slInput.LoadFromFile(AFileName);
              linkCreate.FLinkedFile.LoadTreeFromList(slInput);
            finally
              slInput.Free();
            end;
          end;
      end;
end;


function TSimpleTSInfoFile.FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; AParentNodePath: AnsiString = ''): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(AParentNodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(AParentNodePath);
    nodeParent := FindNode(AParentNodePath, False);
  end;

  Result := (nodeParent <> nil) and (nodeParent.AttributesCount > 0);

  if Result then
  begin
    AAttrToken.FAttribute := nodeParent.GetAttributeByIndex(0);
    AAttrToken.FParentNode := nodeParent;
    AAttrToken.FIndex := 0;
  end;
end;


function TSimpleTSInfoFile.FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
begin
  Result := AAttrToken.FIndex < AAttrToken.FParentNode.AttributesCount - 1;

  if Result then
  begin
    Inc(AAttrToken.FIndex);
    AAttrToken.FAttribute := AAttrToken.FParentNode.GetAttributeByIndex(AAttrToken.FIndex);
  end;
end;


function TSimpleTSInfoFile.FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; AParentNodePath: AnsiString = ''): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(AParentNodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(AParentNodePath);
    nodeParent := FindNode(AParentNodePath, False);
  end;

  Result := (nodeParent <> nil) and (nodeParent.ChildNodesCount > 0);

  if Result then
  begin
    ANodeToken.FChildNode := nodeParent.GetChildNodeByIndex(0);
    ANodeToken.FParentNode := nodeParent;
    ANodeToken.FIndex := 0;
  end;
end;


function TSimpleTSInfoFile.FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
begin
  Result := ANodeToken.FIndex < ANodeToken.FParentNode.ChildNodesCount - 1;

  if Result then
  begin
    Inc(ANodeToken.FIndex);
    ANodeToken.FChildNode := ANodeToken.FParentNode.GetChildNodeByIndex(ANodeToken.FIndex);
  end;
end;


procedure TSimpleTSInfoFile.UpdateFile();
var
  fsOutput: TStream;
  slOutput: TStrings;
begin
  if ffBinaryFile in FFileFlags then
  begin
    fsOutput := TFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
    try
      SaveTreeToStream(fsOutput);
    finally
      fsOutput.Free();
    end;
  end
  else
  begin
    slOutput := TStringList.Create();
    try
      SaveTreeToList(slOutput);
      slOutput.SaveToFile(FFileName);
    finally
      slOutput.Free();
    end;
  end;

  FModified := False;
end;


{ ----- TTSInfoFiles class ---------------------------------------------------------------------------------------- }


procedure TTSInfoFile.RenameTree(ANewTreeName: AnsiString);
begin
  if ANewTreeName <> '' then
    if not ValidIdentifier(ANewTreeName) then
      Exit;

  FTreeName := ANewTreeName;
  FModified := True;
end;


procedure TTSInfoFile.RenameAttribute(AAttrName, ANewAttrName: AnsiString);
var
  nodeParent: TTSInfoNode;
  attrRename: TTSInfoAttribute;
  strNodePath, strAttrName: AnsiString;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    strNodePath := ExtractPathComponent(AAttrName, pcAttributePath);

    if IsCurrentNodeSymbol(strNodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(strNodePath, False);

    if nodeParent = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
    else
    begin
      strAttrName := ExtractPathComponent(AAttrName, pcAttributeName);
      attrRename := nodeParent.GetAttributeByName(strAttrName);

      if attrRename = nil then
        ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
      else
        if ValidIdentifier(ANewAttrName) then
        begin
          attrRename.Name := ANewAttrName;
          FModified := True;
        end;
    end;
  end;
end;


procedure TTSInfoFile.RenameChildNode(ANodePath, ANewNodeName: AnsiString);
var
  nodeRename: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_RENAME, [])
      else
        nodeRename := FCurrentNode;
    end
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeRename := FindNode(ANodePath, False);
    end;

    if nodeRename = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeRename.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_RENAME, [])
      else
        if ValidIdentifier(ANewNodeName) then
        begin
          nodeRename.Name := ANewNodeName;
          FModified := True;
        end;
  end;
end;


procedure TTSInfoFile.RenameVirtualNode(ANodePath, AVirtualNodeName, ANewVirtualNodeName: AnsiString);
var
  nodeParent: TTSInfoNode;
  linkRename: TTSInfoLink;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent = nil then
      ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
    begin
      linkRename := nodeParent.GetLinkByVirtualNodeName(AVirtualNodeName);

      if linkRename = nil then
        ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
      else
        if ValidIdentifier(ANewVirtualNodeName) then
        begin
          linkRename.VirtualNodeName := ANewVirtualNodeName;
          FModified := True;
        end;
    end;
  end;
end;


procedure TTSInfoFile.WriteTreeComment(AComment, ADelimiter: AnsiString);
begin
  if ADelimiter = '' then
    FTreeComment := AComment
  else
    FTreeComment := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

  FModified := True;
end;


procedure TTSInfoFile.WriteAttributeComment(AAttrName, AComment, ADelimiter: AnsiString; AType: TCommentType);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, False);

    if attrWrite = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
    else
    begin
      if ADelimiter = '' then
        attrWrite.Comment[AType] := AComment
      else
        attrWrite.Comment[AType] := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.WriteChildNodeComment(ANodePath, AComment, ADelimiter: AnsiString; AType: TCommentType);
var
  nodeWrite: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_SET_COMMENT, [])
      else
        nodeWrite := FCurrentNode;
    end
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeWrite := FindNode(ANodePath, False);
    end;

    if nodeWrite = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeWrite.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_COMMENT, [])
      else
      begin
        if ADelimiter = '' then
          nodeWrite.Comment[AType] := AComment
        else
          nodeWrite.Comment[AType] := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

        FModified := True;
      end;
  end;
end;


procedure TTSInfoFile.WriteLinkComment(ANodePath, AVirtualNodeName, AComment, ADelimiter: AnsiString);
var
  nodeParent: TTSInfoNode;
  linkWrite: TTSInfoLink;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent = nil then
      ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
    begin
      linkWrite := nodeParent.GetLinkByVirtualNodeName(AVirtualNodeName);

      if linkWrite = nil then
        ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
      else
      begin
        if ADelimiter = '' then
          linkWrite.Comment := AComment
        else
          linkWrite.Comment := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

        FModified := True;
      end;
    end;
  end;
end;


function TTSInfoFile.ReadTreeComment(ADelimiter: AnsiString): AnsiString;
begin
  Result := ReplaceSubStrings(FTreeComment, VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoFile.ReadAttributeComment(AAttrName, ADelimiter: AnsiString; AType: TCommentType): AnsiString;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
  else
    Result := ReplaceSubStrings(attrRead.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoFile.ReadChildNodeComment(ANodePath, ADelimiter: AnsiString; AType: TCommentType): AnsiString;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_COMMENT, [])
    else
      nodeRead := FCurrentNode;
  end
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRead := FindNode(ANodePath, False);
  end;

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if nodeRead.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_COMMENT, [])
    else
      Result := ReplaceSubStrings(nodeRead.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoFile.ReadLinkComment(ANodePath, AVirtualNodeName, ADelimiter: AnsiString): AnsiString;
var
  nodeParent: TTSInfoNode;
  linkRead: TTSInfoLink;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  if nodeParent = nil then
    ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
  else
  begin
    linkRead := nodeParent.GetLinkByVirtualNodeName(AVirtualNodeName);

    if linkRead = nil then
      ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
      Result := ReplaceSubStrings(linkRead.Comment, VALUES_DELIMITER, ADelimiter);
  end;
end;


procedure TTSInfoFile.WriteAttributeReference(AAttrName: AnsiString; AReference: Boolean);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    attrWrite := FindAttribute(AAttrName, False);

    if attrWrite = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
    else
    begin
      attrWrite.Reference := AReference;
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.WriteChildNodeReference(ANodePath: AnsiString; AReference: Boolean);
var
  nodeWrite: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_SET_REFERENCE, [])
      else
        nodeWrite := FCurrentNode;
    end
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeWrite := FindNode(ANodePath, False);
    end;

    if nodeWrite = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeWrite.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_REFERENCE, [])
      else
      begin
        nodeWrite.Reference := AReference;
        FModified := True;
      end;
  end;
end;


function TTSInfoFile.ReadAttributeReference(AAttrName: AnsiString): Boolean;
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
  else
    Result := attrRead.Reference;
end;


function TTSInfoFile.ReadChildNodeReference(ANodePath: AnsiString = ''): Boolean;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE, [])
    else
      nodeRead := FCurrentNode;
  end
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRead := FindNode(ANodePath, False);
  end;

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if nodeRead.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE, [])
    else
      Result := nodeRead.Reference;
end;


procedure TTSInfoFile.RemoveAttribute(AAttrName: AnsiString);
var
  nodeParent: TTSInfoNode;
  strPath, strName: AnsiString;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    ExcludeTrailingIdentsDelimiter(AAttrName);
    strPath := ExtractPathComponent(AAttrName, pcAttributePath);

    if IsCurrentNodeSymbol(strPath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(strPath, False);

    if nodeParent <> nil then
    begin
      strName := ExtractPathComponent(AAttrName, pcAttributeName);
      nodeParent.RemoveAttribute(strName);
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.RemoveChildNode(ANodePath: AnsiString);
var
  nodeRemove: TTSInfoNode;
  strName: AnsiString;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRemove := FindNode(ANodePath, False);

    if nodeRemove <> nil then
      if nodeRemove.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_REMOVE, [])
      else
      begin
        strName := nodeRemove.Name;
        nodeRemove := nodeRemove.ParentNode;
        nodeRemove.RemoveChildNode(strName);
        FModified := True;
      end;
  end;
end;


procedure TTSInfoFile.RemoveLink(ANodePath, AVirtualNodeName: AnsiString);
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent <> nil then
    begin
      nodeParent.RemoveLink(AVirtualNodeName);
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.RemoveAllAttributes(ANodePath: AnsiString = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent <> nil then
    begin
      nodeParent.ClearAttributes();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.RemoveAllChildNodes(ANodePath: AnsiString = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent <> nil then
    begin
      nodeParent.ClearChildNodes();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.RemoveAllLinks(ANodePath: AnsiString = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent <> nil then
    begin
      nodeParent.ClearLinks();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.ClearChildNode(ANodePath: AnsiString = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    if IsCurrentNodeSymbol(ANodePath) then
      nodeParent := FCurrentNode
    else
    begin
      IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(ANodePath, False);
    end;

    if nodeParent <> nil then
    begin
      nodeParent.ClearAttributes();
      nodeParent.ClearChildNodes();
      nodeParent.ClearLinks();

      FModified := True;
    end;
  end;
end;


procedure TTSInfoFile.ClearTree();
begin
  if FReadOnlyMode then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION, [])
  else
  begin
    FRootNode.ClearAttributes();
    FRootNode.ClearChildNodes();
    FRootNode.ClearLinks();

    FCurrentNode := FRootNode;
    FModified := True;
  end;
end;


function TTSInfoFile.AttributeExists(AAttrName: AnsiString): Boolean;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  Result := FindAttribute(AAttrName, False) <> nil;
end;


function TTSInfoFile.ChildNodeExists(ANodePath: AnsiString): Boolean;
begin
  IncludeTrailingIdentsDelimiter(ANodePath);
  Result := FindNode(ANodePath, False) <> nil;
end;


function TTSInfoFile.LinkExists(ANodePath, AVirtualNodeName: AnsiString): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  Result := (nodeParent <> nil) and (nodeParent.GetLinkByVirtualNodeName(AVirtualNodeName) <> nil);
end;


function TTSInfoFile.GetAttributesCount(ANodePath: AnsiString = ''): UInt32;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeRead := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRead := FindNode(ANodePath, False);
  end;

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetAttributesCount();
end;


function TTSInfoFile.GetChildNodesCount(ANodePath: AnsiString = ''): UInt32;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeRead := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRead := FindNode(ANodePath, False);
  end;

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetChildNodesCount();
end;


function TTSInfoFile.GetLinksCount(ANodePath: AnsiString = ''): UInt32;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeRead := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeRead := FindNode(ANodePath, False);
  end;

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetLinksCount();
end;


procedure TTSInfoFile.ReadAttributesNames(ANodePath: AnsiString; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  I: Integer;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for I := 0 to nodeParent.AttributesCount - 1 do
      ANames.Add(nodeParent.GetAttributeByIndex(I).Name);
end;


procedure TTSInfoFile.ReadAttributesValues(ANodePath: AnsiString; AValues: TStrings);
var
  nodeParent: TTSInfoNode;
  I: Integer;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for I := 0 to nodeParent.AttributesCount - 1 do
      AValues.Add(nodeParent.GetAttributeByIndex(I).Value);
end;


procedure TTSInfoFile.ReadChildNodesNames(ANodePath: AnsiString; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  I: Integer;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for I := 0 to nodeParent.ChildNodesCount - 1 do
      ANames.Add(nodeParent.GetChildNodeByIndex(I).Name);
end;


procedure TTSInfoFile.ReadVirtualNodesNames(ANodePath: AnsiString; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  I: Integer;
begin
  if IsCurrentNodeSymbol(ANodePath) then
    nodeParent := FCurrentNode
  else
  begin
    IncludeTrailingIdentsDelimiter(ANodePath);
    nodeParent := FindNode(ANodePath, False);
  end;

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for I := 0 to nodeParent.LinksCount - 1 do
      ANames.Add(nodeParent.GetLinkByIndex(I).VirtualNodeName);
end;


procedure TTSInfoFile.ExportTreeToFile(AFileName: TFileName; AFormat: TExportFormat = efTextFile);
var
  fsOutput: TStream;
  slOutput: TStrings;
begin
  if AFormat = efBinaryFile then
  begin
    fsOutput := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
    try
      SaveTreeToStream(fsOutput);
    finally
      fsOutput.Free();
    end;
  end
  else
  begin
    slOutput := TStringList.Create();
    try
      SaveTreeToList(slOutput);
      slOutput.SaveToFile(AFileName);
    finally
      slOutput.Free();
    end;
  end;
end;


procedure TTSInfoFile.ExportTreeToList(AList: TStrings);
begin
  SaveTreeToList(AList);
end;


procedure TTSInfoFile.ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryFile);
var
  slOutput: TStrings;
begin
  if AFormat = efBinaryFile then
    SaveTreeToStream(AStream)
  else
  begin
    slOutput := TStringList.Create();
    try
      SaveTreeToList(slOutput);
      slOutput.SaveToStream(AStream);
    finally
      slOutput.Free();
    end;
  end;
end;


{ ----- TTSInfoTextInputReader class ------------------------------------------------------------------------------ }


constructor TTSInfoTextInputReader.Create(ATSInfoFile: TSimpleTSInfoFile; AInput: TStrings);
begin
  inherited Create();

  FTSInfoFile := ATSInfoFile;
  FInput := AInput;
  FInput.BeginUpdate();

  FLineIndex := 0;
  FEndTreeLineIndex := 0;
end;


destructor TTSInfoTextInputReader.Destroy();
begin
  FTSInfoFile := nil;

  FInput.EndUpdate();
  FInput := nil;

  inherited Destroy();
end;


procedure TTSInfoTextInputReader.PrepareSourceLines();
const
  UTF8_BOM_SIGNATURE     = AnsiString(#239#187#191);
  UTF8_BOM_SIGNATURE_LEN = UInt8(3);
var
  strLine: AnsiString;
  I: Integer;
begin
  if FInput.Count > 0 then
  begin
    strLine := FInput[0];

    if CompareByte(strLine[1], UTF8_BOM_SIGNATURE[1], UTF8_BOM_SIGNATURE_LEN) = 0 then
    begin
      Delete(strLine, 1, UTF8_BOM_SIGNATURE_LEN);
      FInput[0] := strLine;
    end;
  end;

  I := FInput.Count - 1;

  while I >= 0 do
  begin
    strLine := CutControlChars(FInput[I], cmBothSides);

    if strLine = '' then
      FInput.Delete(I)
    else
      FInput[I] := strLine;

    Dec(I);
  end;

  FEndTreeLineIndex := FInput.IndexOf(END_TREE_KEYWORD);

  if FEndTreeLineIndex = -1 then
    ThrowException(EM_MISSING_END_TREE_LINE, [])
  else
  begin
    MarkComments();

    while FLineIndex < FEndTreeLineIndex do
      if IsRefAttributeDecLine(FInput[FLineIndex]) then
        MoveRefAttributeDefLines()
      else
        if IsRefNodeLine(FInput[FLineIndex]) then
          MoveRefNodeDefLines()
        else
          Inc(FLineIndex);

    FEndTreeLineIndex := 0;
    FLineIndex := 0;
  end;
end;


procedure TTSInfoTextInputReader.MarkComments();
var
  I: Integer = 0;
begin
  while I < FInput.Count do
    if IsCommentLine(FInput[I]) then
    begin
      FInput.Objects[I] := TObject(DECLARATION_COMMENT_MARKER);
      Inc(I);

      while (I < FInput.Count) and IsCommentLine(FInput[I]) do
        Inc(I);
    end
    else
      Inc(I);
end;


procedure TTSInfoTextInputReader.MoveRefAttributeDefLines();
var
  strAttrDecName: AnsiString;
  intBeginIdx, intEndIdx, intJumpSize, I: Integer;
begin
  strAttrDecName := ExtractRefAttrNameFromDecLine(FInput[FLineIndex]);
  intBeginIdx := FindRefAttributeDefLine(strAttrDecName);

  if intBeginIdx = -1 then
  begin
    FInput[FLineIndex] := GlueStrings('% %%', [FInput[FLineIndex], QUOTE_CHAR, QUOTE_CHAR]);
    Inc(FLineIndex);
  end
  else
  begin
    intEndIdx := intBeginIdx;

    if (intBeginIdx > FEndTreeLineIndex + 1) and IsCommentLine(FInput[intBeginIdx - 1]) then
    begin
      repeat
        Dec(intBeginIdx);
      until IsCommentMarkerLine(FInput.Objects[intBeginIdx]);

      FInput.Objects[intBeginIdx] := TObject(DEFINITION_COMMENT_MARKER);
    end;

    while (intEndIdx < FInput.Count - 1) and IsAttributeValueLine(FInput[intEndIdx + 1]) do
      Inc(intEndIdx);

    intJumpSize := intEndIdx - intBeginIdx + 1;

    for I := intEndIdx downto intBeginIdx do
      FInput.Move(intEndIdx, FLineIndex);

    Inc(FLineIndex, intJumpSize);
    FInput.Delete(FLineIndex);
    Inc(FEndTreeLineIndex, intJumpSize - 1);
  end;
end;


procedure TTSInfoTextInputReader.MoveRefNodeDefLines();
var
  strNodeDecName: AnsiString;
  intBeginIdx, intEndIdx, intJumpSize, intMovedLinesCnt, I: Integer;
begin
  strNodeDecName := ExtractRefNodeName(FInput[FLineIndex]);
  intBeginIdx := FindRefNodeDefLine(strNodeDecName);

  if intBeginIdx = -1 then
  begin
    FInput.Insert(FLineIndex + 1, END_REF_NODE_KEYWORD);
    Inc(FLineIndex, 2);
  end
  else
  begin
    intEndIdx := intBeginIdx;
    intJumpSize := intBeginIdx;

    if (intBeginIdx > FEndTreeLineIndex + 1) and IsCommentLine(FInput[intBeginIdx - 1]) then
    begin
      repeat
        Dec(intBeginIdx);
      until IsCommentMarkerLine(FInput.Objects[intBeginIdx]);

      FInput.Objects[intBeginIdx] := TObject(DEFINITION_COMMENT_MARKER);
    end;

    while (intEndIdx < FInput.Count - 1) and (not IsEndRefNodeLine(FInput[intEndIdx + 1])) do
      Inc(intEndIdx);

    Inc(intEndIdx);
    Dec(intJumpSize, intBeginIdx - 1);
    intMovedLinesCnt := intEndIdx - intBeginIdx + 1;

    for I := intEndIdx downto intBeginIdx do
      FInput.Move(intEndIdx, FLineIndex);

    FInput.Delete(FLineIndex + intMovedLinesCnt);
    Inc(FLineIndex, intJumpSize);
    Inc(FEndTreeLineIndex, intMovedLinesCnt - 1);
  end;
end;


function TTSInfoTextInputReader.FormatVersionSupported(AFormatVersion: AnsiString): Boolean;
var
  snFormatVer: Single;
  intCode: Integer;
begin
  Val(AFormatVersion, snFormatVer, intCode);
  Result := intCode = 0;

  if Result then
  begin
    Result := CompareValue(snFormatVer, HIGHEST_SUPPORTED_FORMAT_VERSION) <> GreaterThanValue;

    if not Result then
      ThrowException(EM_UNSUPPORTED_FORMAT_VERSION, [AFormatVersion]);
  end
  else
    ThrowException(EM_INVALID_FORMAT_VERSION, [AFormatVersion]);
end;


function TTSInfoTextInputReader.FindRefAttributeDefLine(AName: AnsiString): Integer;
var
  strAttrDefName: AnsiString;
  I: Integer;
begin
  Result := -1;
  I := FEndTreeLineIndex + 1;

  while I < FInput.Count do
    if IsRefAttributeDefLine(FInput[I]) then
    begin
      strAttrDefName := ExtractRefAttrNameFromDefLine(FInput[I]);

      if SameIdentifiers(AName, strAttrDefName) then
        Exit(I);
    end
    else
      Inc(I);
end;


function TTSInfoTextInputReader.FindRefNodeDefLine(AName: AnsiString): Integer;
var
  strNodeDefName: AnsiString;
  I: Integer;
begin
  Result := -1;
  I := FEndTreeLineIndex + 1;

  while I < FInput.Count do
    if IsRefNodeLine(FInput[I]) then
    begin
      strNodeDefName := ExtractRefNodeName(FInput[I]);

      if SameIdentifiers(AName, strNodeDefName) then
        Exit(I);
    end
    else
      Inc(I);
end;


function TTSInfoTextInputReader.ExtractRefAttrNameFromDecLine(ALine: AnsiString): AnsiString;
var
  pchrName, pchrLast: PAnsiChar;
begin
  pchrName := @ALine[REF_ATTRIBUTE_KEYWORD_LEN + 1];
  pchrLast := @ALine[Length(ALine)];

  while pchrName^ in CONTROL_CHARS do
    Inc(pchrName);

  MoveString(pchrName^, Result, pchrLast - pchrName + 1);
end;


function TTSInfoTextInputReader.ExtractRefAttrNameFromDefLine(ALine: AnsiString): AnsiString;
var
  pchrName, pchrQuote: PAnsiChar;
begin
  pchrName := @ALine[REF_ATTRIBUTE_KEYWORD_LEN + 1];

  while pchrName^ in CONTROL_CHARS do
    Inc(pchrName);

  pchrQuote := pchrName;

  while pchrQuote^ <> QUOTE_CHAR do
    Inc(pchrQuote);

  Dec(pchrQuote);

  while pchrQuote^ in CONTROL_CHARS do
    Dec(pchrQuote);

  MoveString(pchrName^, Result, pchrQuote - pchrName + 1);
end;


function TTSInfoTextInputReader.ExtractNextAttributeValue(ALine: AnsiString): AnsiString;
begin
  MoveString(ALine[2], Result, Length(ALine) - 2);
end;


function TTSInfoTextInputReader.ExtractRefNodeName(ALine: AnsiString): AnsiString;
var
  pchrName, pchrLast: PAnsiChar;
begin
  pchrName := @ALine[REF_NODE_KEYWORD_LEN + 1];
  pchrLast := @ALine[Length(ALine)];

  while pchrName^ in CONTROL_CHARS do
    Inc(pchrName);

  MoveString(pchrName^, Result, pchrLast - pchrName + 1);
end;


procedure TTSInfoTextInputReader.ClearComment();
begin
  FComment[ctDeclaration] := '';
  FComment[ctDefinition] := '';
end;


procedure TTSInfoTextInputReader.ExtractComment();

  procedure ExtractCommentValue(var AComment: AnsiString);
  var
    intLineLen: UInt32;
    pchrValue, pchrLast: PAnsiChar;
    strLine, strValue: AnsiString;
  begin
    repeat
      strLine := FInput[FLineIndex];
      intLineLen := Length(strLine);
      SetLength(strValue, 0);

      if intLineLen > COMMENT_PREFIX_LEN then
      begin
        pchrValue := @strLine[COMMENT_PREFIX_LEN + 1];
        pchrLast := @strLine[intLineLen];

        if pchrValue^ in CONTROL_CHARS then
          Inc(pchrValue);

        MoveString(pchrValue^, strValue, pchrLast - pchrValue + 1);
      end;

      AComment += strValue + VALUES_DELIMITER;
      Inc(FLineIndex);
    until (not IsCommentLine(FInput[FLineIndex])) or IsCommentMarkerLine(FInput.Objects[FLineIndex]);

    if AComment = VALUES_DELIMITER then
      AComment := ONE_BLANK_VALUE_LINE_CHAR
    else
      SetLength(AComment, Length(AComment) - 1);
  end;

begin
  ClearComment();

  if Integer(FInput.Objects[FLineIndex]) = DECLARATION_COMMENT_MARKER then
    ExtractCommentValue(FComment[ctDeclaration]);

  if Integer(FInput.Objects[FLineIndex]) = DEFINITION_COMMENT_MARKER then
    ExtractCommentValue(FComment[ctDefinition]);
end;


procedure TTSInfoTextInputReader.ExtractLineComponents(ALine: AnsiString; var AComponents: TValueComponents; out ACount: UInt32);
var
  intCompCnt: UInt32 = 0;

  procedure AddComponent(ASource: PAnsiChar; ALength: UInt32);
  begin
    SetLength(AComponents, intCompCnt + 1);
    MoveString(ASource^, AComponents[intCompCnt], ALength);
    Inc(intCompCnt);
  end;

var
  pchrBeginCmp, pchrEndCmp, pchrLast: PAnsiChar;
begin
  ALine += #32;
  pchrEndCmp := @ALine[1];
  pchrBeginCmp := pchrEndCmp;
  pchrLast := @ALine[Length(ALine)];

  while pchrEndCmp < pchrLast do
  begin
    if pchrBeginCmp^ = QUOTE_CHAR then
    begin
      Inc(pchrBeginCmp);
      Inc(pchrEndCmp);

      while (pchrEndCmp^ <> QUOTE_CHAR) and (pchrEndCmp < pchrLast) do
        Inc(pchrEndCmp);

      AddComponent(pchrBeginCmp, pchrEndCmp - pchrBeginCmp);

      if pchrEndCmp^ = QUOTE_CHAR then
        Inc(pchrEndCmp);
    end
    else
    begin
      while (pchrEndCmp^ <> QUOTE_CHAR) and not (pchrEndCmp^ in CONTROL_CHARS) do
        Inc(pchrEndCmp);

      AddComponent(pchrBeginCmp, pchrEndCmp - pchrBeginCmp);
    end;

    while pchrEndCmp^ in CONTROL_CHARS do
      Inc(pchrEndCmp);

    pchrBeginCmp := pchrEndCmp;
  end;

  ACount := intCompCnt;
end;


procedure TTSInfoTextInputReader.ExtractAttributeComponents(ALine: AnsiString; out AReference: Boolean; out AName, AValue: AnsiString);
var
  pchrName, pchrValue, pchrLast: PAnsiChar;
begin
  AReference := ALine[1] = REF_KEYWORD[1];

  if AReference then
    pchrName := @ALine[REF_ATTRIBUTE_KEYWORD_LEN + 1]
  else
    pchrName := @ALine[ATTRIBUTE_KEYWORD_LEN + 1];

  pchrLast := @ALine[Length(ALine)];

  while pchrName^ in CONTROL_CHARS do
    Inc(pchrName);

  pchrValue := pchrName + 1;

  while pchrValue^ <> QUOTE_CHAR do
    Inc(pchrValue);

  while pchrLast^ <> QUOTE_CHAR do
    Dec(pchrLast);

  MoveString(PAnsiChar(pchrValue + 1)^, AValue, pchrLast - pchrValue - 1);
  Dec(pchrValue);

  while pchrValue^ in CONTROL_CHARS do
    Dec(pchrValue);

  MoveString(pchrName^, AName, pchrValue - pchrName + 1);
end;


procedure TTSInfoTextInputReader.ExtractNodeComponents(ALine: AnsiString; out AReference: Boolean; out AName: AnsiString);
var
  pchrName, pchrLast: PAnsiChar;
begin
  AReference := ALine[1] = REF_KEYWORD[1];

  if AReference then
    pchrName := @ALine[REF_NODE_KEYWORD_LEN + 1]
  else
    pchrName := @ALine[NODE_KEYWORD_LEN + 1];

  pchrLast := @ALine[Length(ALine)];

  while pchrName^ in CONTROL_CHARS do
    Inc(pchrName);

  MoveString(pchrName^, AName, pchrLast - pchrName + 1);
end;


procedure TTSInfoTextInputReader.ComponentsToFlagsSet(AComponents: TValueComponents; var AFlags: TFileFlags);
const
  FIRST_FLAG_IDX = UInt32(5);
var
  I: UInt32;
begin
  I := High(AComponents);

  while I >= FIRST_FLAG_IDX do
  begin
    if SameIdentifiers(AComponents[I], FLAG_BINARY_FILE) then
      Include(AFlags, ffBinaryFile)
    else
      if SameIdentifiers(AComponents[I], FLAG_UPDATABLE) then
        Include(AFlags, ffUpdatable)
      else
        if AComponents[I] <> '' then
          ThrowException(EM_UNKNOWN_LINK_FLAG, [AComponents[I]]);

    Dec(I);
  end;
end;


function TTSInfoTextInputReader.IsTreeHeaderLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= MIN_TREE_HEADER_LINE_LEN) and
            (CompareByte(ALine[1], TREE_HEADER_SIGNATURE[1], TREE_HEADER_SIGNATURE_LEN) = 0);
end;


function TTSInfoTextInputReader.IsAttributeLine(ALine: AnsiString): Boolean;
var
  intLineLen: UInt32;
  pchrToken, pchrLast: PAnsiChar;
begin
  Result := False;
  intLineLen := Length(ALine);

  if intLineLen >= MIN_ATTRIBUTE_LINE_LEN then
    if CompareByte(ALine[1], ATTRIBUTE_KEYWORD[1], ATTRIBUTE_KEYWORD_LEN) = 0 then
    begin
      pchrToken := @ALine[ATTRIBUTE_KEYWORD_LEN + 1];
      pchrLast := @ALine[intLineLen];

      while (pchrToken < pchrLast) and (pchrToken^ in CONTROL_CHARS) do
        Inc(pchrToken);

      if pchrToken^ <> QUOTE_CHAR then
      begin
        while (pchrToken < pchrLast) and (pchrToken^ <> QUOTE_CHAR) do
          Inc(pchrToken);

        while (pchrLast > pchrToken) and (pchrLast^ <> QUOTE_CHAR) do
          Dec(pchrLast);

        Result := (pchrToken < pchrLast) and (pchrLast^ = QUOTE_CHAR);
      end;
    end;

  if not Result then
    Result := IsRefAttributeDecLine(ALine);
end;


function TTSInfoTextInputReader.IsAttributeValueLine(ALine: AnsiString): Boolean;
var
  intLineLen: UInt32;
begin
  intLineLen := Length(ALine);

  Result := (intLineLen >= MIN_ATTRIBUTE_VALUE_LINE_LEN) and (ALine[1] = QUOTE_CHAR) and
            (ALine[intLineLen] = QUOTE_CHAR);
end;


function TTSInfoTextInputReader.IsRefAttributeDecLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= MIN_REF_ATTRIBUTE_DEC_LINE_LEN) and
            (CompareByte(ALine[1], REF_ATTRIBUTE_KEYWORD[1], REF_ATTRIBUTE_KEYWORD_LEN) = 0);
end;


function TTSInfoTextInputReader.IsRefAttributeDefLine(ALine: AnsiString): Boolean;
var
  intLineLen: UInt32;
  pchrToken, pchrLast: PAnsiChar;
begin
  Result := False;
  intLineLen := Length(ALine);

  if intLineLen >= MIN_REF_ATTRIBUTE_DEF_LINE_LEN then
    if CompareByte(ALine[1], REF_ATTRIBUTE_KEYWORD[1], REF_ATTRIBUTE_KEYWORD_LEN) = 0 then
    begin
      pchrToken := @ALine[REF_ATTRIBUTE_KEYWORD_LEN + 1];
      pchrLast := @ALine[intLineLen];

      while (pchrToken < pchrLast) and (pchrToken^ in CONTROL_CHARS) do
        Inc(pchrToken);

      if pchrToken^ <> QUOTE_CHAR then
      begin
        while (pchrToken < pchrLast) and (pchrToken^ <> QUOTE_CHAR) do
          Inc(pchrToken);

        while (pchrLast > pchrToken) and (pchrLast^ <> QUOTE_CHAR) do
          Dec(pchrLast);

        Result := (pchrToken < pchrLast) and (pchrLast^ = QUOTE_CHAR);
      end;
    end;
end;


function TTSInfoTextInputReader.IsNodeLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= MIN_NODE_LINE_LEN) and
            (CompareByte(ALine[1], NODE_KEYWORD[1], NODE_KEYWORD_LEN) = 0);

  if not Result then
    Result := IsRefNodeLine(ALine);
end;


function TTSInfoTextInputReader.IsRefNodeLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= MIN_REF_NODE_LINE_LEN) and
            (CompareByte(ALine[1], REF_NODE_KEYWORD[1], REF_NODE_KEYWORD_LEN) = 0);
end;


function TTSInfoTextInputReader.IsEndRefNodeLine(ALine: AnsiString): Boolean;
begin
  Result := SameIdentifiers(ALine, END_REF_NODE_KEYWORD);
end;


function TTSInfoTextInputReader.IsEndNodeLine(ALine: AnsiString): Boolean;
begin
  Result := SameIdentifiers(ALine, END_NODE_KEYWORD);

  if not Result then
    Result := IsEndRefNodeLine(ALine);
end;


function TTSInfoTextInputReader.IsLinkLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= MIN_LINK_LINE_LEN) and
            (CompareByte(ALine[1], LINK_KEYWORD[1], LINK_KEYWORD_LEN) = 0);
end;


function TTSInfoTextInputReader.IsEndTreeLine(ALine: AnsiString): Boolean;
begin
  Result := SameIdentifiers(ALine, END_TREE_KEYWORD);
end;


function TTSInfoTextInputReader.IsCommentLine(ALine: AnsiString): Boolean;
begin
  Result := (Length(ALine) >= COMMENT_PREFIX_LEN) and
            (CompareByte(ALine[1], COMMENT_PREFIX[1], COMMENT_PREFIX_LEN) = 0);
end;


function TTSInfoTextInputReader.IsCommentMarkerLine(AMarker: TObject): Boolean;
begin
  Result := (Integer(AMarker) = DECLARATION_COMMENT_MARKER) or
            (Integer(AMarker) = DEFINITION_COMMENT_MARKER);
end;


procedure TTSInfoTextInputReader.AnalyzeTreeHeader();
const
  SHORT_HEADER_COMP_CNT   = UInt32(3);
  AVERAGE_HEADER_COMP_CNT = UInt32(4);
  LONG_HEADER_COMP_CNT    = UInt32(5);
const
  ID_VERSION_KEYWORD = UInt32(1);
  ID_VERSION         = UInt32(2);
  ID_NAME_KEYWORD    = UInt32(3);
  ID_TREE_NAME       = UInt32(4);
var
  vcHeader: TValueComponents;
  strLine: AnsiString;
  intCompCnt: UInt32;
begin
  SetLength(vcHeader, 0);
  strLine := FInput[FLineIndex];
  ExtractLineComponents(strLine, vcHeader, intCompCnt);

  if intCompCnt < SHORT_HEADER_COMP_CNT then
    ThrowException(EM_INVALID_TREE_HEADER, [strLine])
  else
    if SameIdentifiers(vcHeader[ID_VERSION_KEYWORD], TREE_HEADER_VERSION_KEYWORD) then
    begin
      if FormatVersionSupported(vcHeader[ID_VERSION]) and (intCompCnt >= AVERAGE_HEADER_COMP_CNT) then
        if SameIdentifiers(vcHeader[ID_NAME_KEYWORD], TREE_HEADER_NAME_KEYWORD) then
        begin
          if intCompCnt >= LONG_HEADER_COMP_CNT then
          begin
            vcHeader[ID_TREE_NAME] := CutControlChars(vcHeader[ID_TREE_NAME], cmBothSides);

            if ValidIdentifier(vcHeader[ID_TREE_NAME]) then
              FTSInfoFile.FTreeName := vcHeader[ID_TREE_NAME];
          end;
        end
        else
          ThrowException(EM_UNKNOWN_TREE_HEADER_COMPONENT, [vcHeader[ID_NAME_KEYWORD]]);
    end
    else
      ThrowException(EM_UNKNOWN_TREE_HEADER_COMPONENT, [vcHeader[ID_VERSION_KEYWORD]]);

  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.AddTreeComment();
begin
  FTSInfoFile.FTreeComment := FComment[ctDeclaration];
  ClearComment();
end;


procedure TTSInfoTextInputReader.AddAttribute();
var
  strLine, strName, strValue: AnsiString;
  boolRef: Boolean;
begin
  ExtractAttributeComponents(FInput[FLineIndex], boolRef, strName, strValue);

  if ValidIdentifier(strName) then
  begin
    Inc(FLineIndex);
    strLine := FInput[FLineIndex];

    while IsAttributeValueLine(strLine) do
    begin
      strValue += VALUES_DELIMITER + ExtractNextAttributeValue(strLine);
      Inc(FLineIndex);
      strLine := FInput[FLineIndex];
    end;

    FTSInfoFile.FCurrentNode.CreateAttribute(boolRef, strName, strValue, FComment);
    ClearComment();
  end;
end;


procedure TTSInfoTextInputReader.AddNode();
var
  strLine, strName: AnsiString;
  boolRef: Boolean;
begin
  strLine := FInput[FLineIndex];
  ExtractNodeComponents(strLine, boolRef, strName);

  if ValidIdentifier(strName) then
    with FTSInfoFile do
      FCurrentNode := FCurrentNode.CreateChildNode(boolRef, strName, FComment);

  ClearComment();
  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.AddLink();
const
  SHORT_LINKED_FILE_COMP_CNT   = UInt32(4);
  AVERAGE_LINKED_FILE_COMP_CNT = UInt32(5);
  LONG_LINKED_FILE_COMP_CNT    = UInt32(6);
const
  ID_LINKED_FILE_NAME  = UInt32(1);
  ID_AS_KEYWORD        = UInt32(2);
  ID_VIRTUAL_NODE_NAME = UInt32(3);
  ID_FLAGS_KEYWORD     = UInt32(4);
var
  vcLinkedFile: TValueComponents;
  strLine: AnsiString;
  intCompCnt: UInt32;
  flFlags: TFileFlags = [];
  lnkFile: TTSInfoLink;
begin
  SetLength(vcLinkedFile, 0);
  strLine := FInput[FLineIndex];
  ExtractLineComponents(strLine, vcLinkedFile, intCompCnt);

  if intCompCnt < SHORT_LINKED_FILE_COMP_CNT then
    ThrowException(EM_INVALID_LINK_LINE, [strLine])
  else
    if vcLinkedFile[ID_LINKED_FILE_NAME] <> '' then
    begin
      if SameIdentifiers(vcLinkedFile[ID_AS_KEYWORD], LINK_AS_KEYWORD) then
      begin
        if ValidIdentifier(vcLinkedFile[ID_VIRTUAL_NODE_NAME]) then
        begin
          if intCompCnt >= AVERAGE_LINKED_FILE_COMP_CNT then
            if SameIdentifiers(vcLinkedFile[ID_FLAGS_KEYWORD], LINK_FLAGS_KEYWORD) then
            begin
              if intCompCnt >= LONG_LINKED_FILE_COMP_CNT then
                ComponentsToFlagsSet(vcLinkedFile, flFlags);
            end
            else
              ThrowException(EM_UNKNOWN_LINK_COMPONENT, [LINK_FLAGS_KEYWORD, vcLinkedFile[ID_FLAGS_KEYWORD]]);

          lnkFile := FTSInfoFile.FCurrentNode.FLinksList.AddItem(vcLinkedFile[ID_LINKED_FILE_NAME],
                     vcLinkedFile[ID_VIRTUAL_NODE_NAME], flFlags, FComment[ctDeclaration]);

          if not (ffNoLinking in FTSInfoFile.FFileFlags) then
            ProcessLink(lnkFile);
        end;
      end
      else
        ThrowException(EM_UNKNOWN_LINK_COMPONENT, [LINK_AS_KEYWORD, vcLinkedFile[ID_AS_KEYWORD]]);
    end
    else
      ThrowException(EM_EMPTY_LINK_FILE_NAME, [vcLinkedFile[ID_LINKED_FILE_NAME]]);

  ClearComment();
  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.CloseNode();
begin
  with FTSInfoFile do
    if FCurrentNode.ParentNode <> nil then
      FCurrentNode := FCurrentNode.ParentNode;

  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.ProcessLink(ALink: TTSInfoLink);
var
  fsInput: TStream;
  slInput: TStrings;
begin
  with ALink.FLinkedFile do
    if FileExistsUTF8(FFileName) then
    begin
      if ffBinaryFile in FFileFlags then
      begin
        fsInput := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
        try
          LoadTreeFromStream(fsInput);
        finally
          fsInput.Free();
        end;
      end
      else
      begin
        slInput := TStringList.Create();
        try
          slInput.LoadFromFile(FFileName);
          LoadTreeFromList(slInput);
        finally
          slInput.Free();
        end;
      end;
    end;
end;


procedure TTSInfoTextInputReader.ProcessInput();
var
  strLine: AnsiString;
begin
  try
    try
      FTSInfoFile.FCurrentNode := FTSInfoFile.FRootNode;
      PrepareSourceLines();

      if IsCommentMarkerLine(FInput.Objects[FLineIndex]) then
      begin
        ExtractComment();
        AddTreeComment();
      end;

      if IsTreeHeaderLine(FInput[FLineIndex]) then
        AnalyzeTreeHeader()
      else
        ThrowException(EM_MISSING_TREE_HEADER, []);

      while FLineIndex < FInput.Count do
      begin
        strLine := FInput[FLineIndex];

        if IsCommentMarkerLine(FInput.Objects[FLineIndex]) then
          ExtractComment()
        else
          if IsAttributeLine(strLine) then AddAttribute() else
          if IsNodeLine(strLine)      then AddNode()      else
          if IsEndNodeLine(strLine)   then CloseNode()    else
          if IsLinkLine(strLine)      then AddLink()      else
          if IsEndTreeLine(strLine)   then Break
          else
            ThrowException(EM_INVALID_SOURCE_LINE, [strLine]);
      end;
    except
      FTSInfoFile.DamageClear();
    end;
  finally
    FTSInfoFile.FCurrentNode := FTSInfoFile.FRootNode;
    FTSInfoFile.FModified := False;
  end;
end;


{ ----- TTSInfoTextOutputWriter class ----------------------------------------------------------------------------- }


constructor TTSInfoTextOutputWriter.Create(ATSInfoFile: TSimpleTSInfoFile; AOutput: TStrings);
begin
  inherited Create();

  FTSInfoFile := ATSInfoFile;
  FOutput := AOutput;
  FOutput.BeginUpdate();

  FRefCount := 0;
  FLastMovedRefType := lmrtNode;
end;


destructor TTSInfoTextOutputWriter.Destroy();
begin
  FTSInfoFile := nil;

  FOutput.EndUpdate();
  FOutput := nil;

  inherited Destroy();
end;


function TTSInfoTextOutputWriter.MakeRefTag(ARefType: TReferenceType; AIndex: Integer): Integer;
begin
  Result := Integer(ARefType) shl (SizeOf(Integer) * 8 - 1) or AIndex;
end;


function TTSInfoTextOutputWriter.ExtractRefType(ARefTag: Integer): TReferenceType;
begin
  Result := TReferenceType(ARefTag shr (SizeOf(Integer) * 8 - 1));
end;


function TTSInfoTextOutputWriter.ExtractRefIndex(ARefTag: Integer): Integer;
begin
  Result := (ARefTag shl 1) shr 1;
end;


function TTSInfoTextOutputWriter.GetNextRefIndex(): Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;


function TTSInfoTextOutputWriter.GetSingleIndent(): AnsiString;
begin
  SetLength(Result, INDENT_SIZE);
  FillChar(Result[1], INDENT_SIZE, INDENT_CHAR);
end;


function TTSInfoTextOutputWriter.IncIndent(AIndent: AnsiString): AnsiString;
begin
  Result := AIndent + GetSingleIndent();
end;


procedure TTSInfoTextOutputWriter.MoveRefAttributeDefinition(ALineIndex, ARefIndex: Integer);
const
  REF_ATTR_TYPE: array [Boolean] of TLastMovedRefType = (lmrtAttribute, lmrtAttributeWithComment);
var
  intLastLineIdx, intRefIdx: Integer;
  boolExtraSpace: Boolean;
begin
  boolExtraSpace := FOutput[ALineIndex][1] = COMMENT_PREFIX[1];

  if (FLastMovedRefType <> lmrtAttribute) or boolExtraSpace then
    FOutput.Add('');

  intLastLineIdx := FOutput.Count - 1;

  repeat
    FOutput.Move(ALineIndex, intLastLineIdx);
    intRefIdx := Integer(FOutput.Objects[ALineIndex]);
  until intRefIdx <> ARefIndex;

  FLastMovedRefType := REF_ATTR_TYPE[boolExtraSpace];
end;


procedure TTSInfoTextOutputWriter.MoveRefNodeDefinition(ALineIndex, AEndRefIndex: Integer; out ANewNodeIndex: Integer);
var
  intLastLineIdx, intRefIdx: Integer;
  intMovedLinesCnt: Integer = 0;
begin
  FOutput.Add('');
  intLastLineIdx := FOutput.Count - 1;

  repeat
    FOutput.Move(ALineIndex, intLastLineIdx);
    Inc(intMovedLinesCnt);
    intRefIdx := Integer(FOutput.Objects[ALineIndex]);
  until intRefIdx = AEndRefIndex;

  FOutput.Move(ALineIndex, intLastLineIdx);
  ANewNodeIndex := intLastLineIdx - intMovedLinesCnt + 1;
  FLastMovedRefType := lmrtNode;
end;


procedure TTSInfoTextOutputWriter.ScanLinesToFindRefs(ALineIndex, AEndRefIndex: Integer);
var
  intRefTag, intRefIdx, intNewNodeIdx: Integer;
begin
  intRefTag := Integer(FOutput.Objects[ALineIndex]);

  while intRefTag <> AEndRefIndex do
  begin
    if intRefTag = 0 then
      Inc(ALineIndex)
    else
    begin
      intRefIdx := ExtractRefIndex(intRefTag);

      case ExtractRefType(intRefTag) of
        rtAttribute:
            MoveRefAttributeDefinition(ALineIndex, intRefIdx);
        rtNode:
            begin
              MoveRefNodeDefinition(ALineIndex, intRefIdx, intNewNodeIdx);
              ScanLinesToFindRefs(intNewNodeIdx, intRefIdx);
            end;
      end;
    end;

    intRefTag := Integer(FOutput.Objects[ALineIndex]);
  end;
end;


procedure TTSInfoTextOutputWriter.AnalyzeNode(AParentNode: TTSInfoNode; AIndent: AnsiString);
var
  attrItem: TTSInfoAttribute;
  nodeItem: TTSInfoNode;
  linkItem: TTSInfoLink;
  strIndent: AnsiString;
  intRefIdx, I: Integer;
begin
  for I := 0 to AParentNode.AttributesCount - 1 do
  begin
    attrItem := AParentNode.GetAttributeByIndex(I);

    if attrItem.Reference then
      intRefIdx := GetNextRefIndex()
    else
      intRefIdx := 0;

    AddAttributeLines(attrItem, AIndent, intRefIdx);
  end;

  for I := 0 to AParentNode.ChildNodesCount - 1 do
  begin
    nodeItem := AParentNode.GetChildNodeByIndex(I);

    if nodeItem.Reference then
    begin
      intRefIdx := GetNextRefIndex();
      strIndent := GetSingleIndent();
    end
    else
    begin
      intRefIdx := 0;
      strIndent := IncIndent(AIndent);
    end;

    AddNodeHeaderLines(nodeItem, AIndent, intRefIdx);
    AnalyzeNode(nodeItem, strIndent);
    AddEndNodeLine(nodeItem, AIndent, intRefIdx);
  end;

  for I := 0 to AParentNode.LinksCount - 1 do
  begin
    linkItem := AParentNode.GetLinkByIndex(I);
    AddLinkLines(linkItem, AIndent);

    if not (ffNoLinking in FTSInfoFile.FFileFlags) then
      ProcessLink(linkItem);
  end;
end;


procedure TTSInfoTextOutputWriter.AddTreeHeaderLines();
var
  strHeader: AnsiString;
begin
  if FTSInfoFile.FTreeComment <> '' then
  begin
    AddCommentLines(FTSInfoFile.FTreeComment, '');
    FOutput.Add('');
  end;

  strHeader := GlueStrings('%% %%%', [TREE_HEADER_SIGNATURE, TREE_HEADER_VERSION_KEYWORD, QUOTE_CHAR,
                                      TREE_HEADER_VERSION, QUOTE_CHAR]);

  if FTSInfoFile.FTreeName <> '' then
    strHeader := GlueStrings('% % %%%', [strHeader, TREE_HEADER_NAME_KEYWORD, QUOTE_CHAR,
                                         FTSInfoFile.FTreeName, QUOTE_CHAR]);

  FOutput.Add(strHeader);
end;


procedure TTSInfoTextOutputWriter.AddAttributeLines(AAttr: TTSInfoAttribute; AIndent: AnsiString; ARefIndex: Integer);
var
  vcValue: TValueComponents;
  strValue: AnsiString = '';
  intCompCnt, I: UInt32;
  intRefTag: Integer;
begin
  if AAttr.FComment[ctDeclaration] <> '' then
    AddCommentLines(AAttr.FComment[ctDeclaration], AIndent);

  SetLength(vcValue, 0);
  ExtractValueComponents(AAttr.FValue, vcValue, intCompCnt);

  if intCompCnt > 0 then
    strValue := vcValue[0];

  if AAttr.FReference then
  begin
    FOutput.Add(GlueStrings('%%%', [AIndent, REF_ATTRIBUTE_KEYWORD, AAttr.FName]));
    intRefTag := MakeRefTag(rtAttribute, ARefIndex);

    if AAttr.FComment[ctDefinition] <> '' then
      AddCommentLines(AAttr.FComment[ctDefinition], '', intRefTag, tsAll);

    FOutput.AddObject(GlueStrings('%% %%%', [REF_ATTRIBUTE_KEYWORD, AAttr.FName, QUOTE_CHAR, strValue, QUOTE_CHAR]),
                      TObject(intRefTag));
  end
  else
    FOutput.Add(GlueStrings('%%% %%%', [AIndent, ATTRIBUTE_KEYWORD, AAttr.FName, QUOTE_CHAR, strValue, QUOTE_CHAR]));

  if intCompCnt > 1 then
  begin
    if AAttr.FReference then
      AIndent := StringOfChar(INDENT_CHAR, REF_ATTRIBUTE_KEYWORD_LEN + Length(AAttr.FName))
    else
      AIndent += StringOfChar(INDENT_CHAR, ATTRIBUTE_KEYWORD_LEN + Length(AAttr.FName));

    for I := 1 to intCompCnt - 1 do
      FOutput.AddObject(GlueStrings('% %%%', [AIndent, QUOTE_CHAR, vcValue[I], QUOTE_CHAR]), TObject(ARefIndex));
  end;
end;


procedure TTSInfoTextOutputWriter.AddNodeHeaderLines(ANode: TTSInfoNode; AIndent: AnsiString; ARefIndex: Integer);
var
  intRefTag: Integer;
begin
  if ANode.FComment[ctDeclaration] <> '' then
    AddCommentLines(ANode.FComment[ctDeclaration], AIndent);

  if ANode.FReference then
  begin
    FOutput.Add(GlueStrings('%%%', [AIndent, REF_NODE_KEYWORD, ANode.FName]));
    intRefTag := MakeRefTag(rtNode, ARefIndex);

    if ANode.FComment[ctDefinition] <> '' then
    begin
      AddCommentLines(ANode.FComment[ctDefinition], '', intRefTag, tsFirst);
      FOutput.Add(GlueStrings('%%', [REF_NODE_KEYWORD, ANode.FName]));
    end
    else
      FOutput.AddObject(GlueStrings('%%', [REF_NODE_KEYWORD, ANode.FName]), TObject(intRefTag));
  end
  else
    FOutput.Add(GlueStrings('%%%', [AIndent, NODE_KEYWORD, ANode.FName]));
end;


procedure TTSInfoTextOutputWriter.AddEndNodeLine(ANode: TTSInfoNode; AIndent: AnsiString; ARefIndex: Integer);
begin
  if ANode.FReference then
    FOutput.AddObject(END_REF_NODE_KEYWORD, TObject(ARefIndex))
  else
    FOutput.Add(GlueStrings('%%', [AIndent, END_NODE_KEYWORD]));
end;


procedure TTSInfoTextOutputWriter.AddLinkLines(ALink: TTSInfoLink; AIndent: AnsiString);
var
  strLinkedFile: AnsiString;
begin
  if ALink.FComment <> '' then
    AddCommentLines(ALink.FComment, AIndent);

  strLinkedFile := GlueStrings('%%%%% % %%%', [AIndent, LINK_KEYWORD, QUOTE_CHAR,
                                               ALink.FileName, QUOTE_CHAR, LINK_AS_KEYWORD,
                                               QUOTE_CHAR, ALink.FVirtualNodeName, QUOTE_CHAR]);

  if ALink.FileFlags <> [] then
  begin
    strLinkedFile += GlueStrings(' %', [LINK_FLAGS_KEYWORD]);

    if ffBinaryFile in ALink.FileFlags then
      strLinkedFile += GlueStrings(' %%%', [QUOTE_CHAR, FLAG_BINARY_FILE, QUOTE_CHAR]);

    if ffUpdatable in ALink.FileFlags then
      strLinkedFile += GlueStrings(' %%%', [QUOTE_CHAR, FLAG_UPDATABLE, QUOTE_CHAR]);
  end;

  FOutput.Add(strLinkedFile);
end;


procedure TTSInfoTextOutputWriter.AddEndTreeLine();
begin
  FOutput.AddObject(END_TREE_KEYWORD, TObject(END_TREE_REF_INDEX));
end;


procedure TTSInfoTextOutputWriter.AddCommentLines(AComment, AIndent: AnsiString);

  procedure AddEmptyCommentLine();
  begin
    FOutput.Add(GlueStrings('%%', [AIndent, COMMENT_PREFIX]));
  end;

var
  vcValue: TValueComponents;
  intCompCnt: UInt32;
  I: Integer;
begin
  SetLength(vcValue, 0);
  ExtractValueComponents(AComment, vcValue, intCompCnt);

  if (intCompCnt = 1) and (vcValue[0] = ONE_BLANK_VALUE_LINE_CHAR) then
    AddEmptyCommentLine()
  else
    for I := 0 to intCompCnt - 1 do
      if vcValue[I] = '' then
        AddEmptyCommentLine()
      else
        FOutput.Add(GlueStrings('%% %', [AIndent, COMMENT_PREFIX, vcValue[I]]));
end;


procedure TTSInfoTextOutputWriter.AddCommentLines(AComment, AIndent: AnsiString; ARefTag: Integer; AStyle: TTaggingStyle);

  procedure AddEmptyCommentLine();
  begin
    FOutput.AddObject(GlueStrings('%%', [AIndent, COMMENT_PREFIX]), TObject(ARefTag));
  end;

var
  vcValue: TValueComponents;
  intCompCnt: UInt32;
  I: Integer;
begin
  SetLength(vcValue, 0);
  ExtractValueComponents(AComment, vcValue, intCompCnt);

  if vcValue[0] = ONE_BLANK_VALUE_LINE_CHAR then
    AddEmptyCommentLine()
  else
  begin
    if vcValue[0] = '' then
      AddEmptyCommentLine()
    else
      FOutput.AddObject(GlueStrings('%% %', [AIndent, COMMENT_PREFIX, vcValue[0]]), TObject(ARefTag));

    if AStyle = tsFirst then
      ARefTag := 0;

    for I := 1 to intCompCnt - 1 do
      if vcValue[I] = '' then
        AddEmptyCommentLine()
      else
        FOutput.AddObject(GlueStrings('%% %', [AIndent, COMMENT_PREFIX, vcValue[I]]), TObject(ARefTag));
  end;
end;


procedure TTSInfoTextOutputWriter.ProcessLink(ALink: TTSInfoLink);
var
  fsOutput: TStream;
  slOutput: TStrings;
begin
  with ALink.FLinkedFile do
    if ffUpdatable in FFileFlags then
    begin
      if ffBinaryFile in FFileFlags then
      begin
        fsOutput := TFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
        try
          SaveTreeToStream(fsOutput);
        finally
          fsOutput.Free();
        end;
      end
      else
      begin
        slOutput := TStringList.Create();
        try
          SaveTreeToList(slOutput);
          slOutput.SaveToFile(FFileName);
        finally
          slOutput.Free();
        end;
      end;
    end
    else
      LocateAndProcessLinks(ALink);
end;


procedure TTSInfoTextOutputWriter.LocateAndProcessLinks(ALink: TTSInfoLink);

  procedure SearchNode(ANode: TTSInfoNode);
  var
    linkSearch: TTSInfoLink;
    nodeSearch: TTSInfoNode;
    I: Integer;
  begin
    for I := 0 to ANode.LinksCount - 1 do
    begin
      linkSearch := ANode.GetLinkByIndex(I);
      ProcessLink(linkSearch);
    end;

    for I := 0 to ANode.ChildNodesCount - 1 do
    begin
      nodeSearch := ANode.GetChildNodeByIndex(I);
      SearchNode(nodeSearch);
    end;
  end;

begin
  SearchNode(ALink.FLinkedFile.FRootNode);
end;


procedure TTSInfoTextOutputWriter.ProcessOutput();
begin
  AddTreeHeaderLines();
  AnalyzeNode(FTSInfoFile.FRootNode, GetSingleIndent());
  AddEndTreeLine();

  if FRefCount > 0 then
    ScanLinesToFindRefs(1, END_TREE_REF_INDEX);
end;


{ ----- TTSInfoBinaryInputReader class ---------------------------------------------------------------------------- }


constructor TTSInfoBinaryInputReader.Create(ATSInfoFile: TSimpleTSInfoFile; AInput: TStream);
begin
  inherited Create();

  FTSInfoFile := ATSInfoFile;
  FInput := AInput;
end;


destructor TTSInfoBinaryInputReader.Destroy();
begin
  FTSInfoFile := nil;
  FInput := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryInputReader.ReadStringBuffer(out ABuffer: AnsiString);
var
  intBufferLen: UInt32 = 0;
begin
  FInput.Read(intBufferLen, SizeOf(intBufferLen));
  SetLength(ABuffer, intBufferLen);
  FInput.Read(ABuffer[1], intBufferLen);
end;


procedure TTSInfoBinaryInputReader.ReadBooleanBuffer(out ABuffer: Boolean);
begin
  ABuffer := False;
  FInput.Read(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryInputReader.ReadUInt32Buffer(out ABuffer: UInt32);
begin
  ABuffer := 0;
  FInput.Read(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryInputReader.ReadStaticHeader();
var
  strBuffer: AnsiString;
  sngVersion: Single = 0;
begin
  SetLength(strBuffer, BINARY_FILE_SIGNATURE_LEN);
  FillChar(strBuffer[1], BINARY_FILE_SIGNATURE_LEN, 0);
  FInput.Read(strBuffer[1], BINARY_FILE_SIGNATURE_LEN);

  if CompareByte(strBuffer[1], BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN) <> 0 then
    ThrowException(EM_INVALID_BINARY_FILE, [])
  else
  begin
    FInput.Read(sngVersion, SizeOf(sngVersion));

    if CompareValue(sngVersion, HIGHEST_SUPPORTED_FORMAT_VERSION) = GreaterThanValue then
      ThrowException(EM_UNSUPPORTED_BINARY_FORMAT_VERSION, [sngVersion])
    else
    begin
      ReadStringBuffer(FTSInfoFile.FTreeComment);
      ReadStringBuffer(FTSInfoFile.FTreeName);
    end;
  end;
end;


procedure TTSInfoBinaryInputReader.ReadAttribute(AAttribute: TTSInfoAttribute);
begin
  ReadStringBuffer(AAttribute.FComment[ctDeclaration]);
  ReadStringBuffer(AAttribute.FComment[ctDefinition]);

  ReadBooleanBuffer(AAttribute.FReference);

  ReadStringBuffer(AAttribute.FName);
  ReadStringBuffer(AAttribute.FValue);
end;


procedure TTSInfoBinaryInputReader.ReadNode(ANode: TTSInfoNode);
var
  intElementsCnt: UInt32;
  I: Integer;
begin
  ReadStringBuffer(ANode.FComment[ctDeclaration]);
  ReadStringBuffer(ANode.FComment[ctDefinition]);

  ReadBooleanBuffer(ANode.FReference);
  ReadStringBuffer(ANode.FName);

  ReadUInt32Buffer(intElementsCnt);

  for I := 0 to intElementsCnt - 1 do
    ReadAttribute(ANode.CreateAttribute(False, ''));

  ReadUInt32Buffer(intElementsCnt);

  for I := 0 to intElementsCnt - 1 do
    ReadNode(ANode.CreateChildNode(False, ''));

  ReadUInt32Buffer(intElementsCnt);

  for I := 0 to intElementsCnt - 1 do
    ReadLink(ANode.CreateLink('', ''));
end;


procedure TTSInfoBinaryInputReader.ReadLink(ALink: TTSInfoLink);
var
  boolIncludeFlag: Boolean;
begin
  ReadStringBuffer(ALink.FComment);
  ReadStringBuffer(ALink.FLinkedFile.FFileName);
  ReadStringBuffer(ALink.FVirtualNodeName);

  ReadBooleanBuffer(boolIncludeFlag);

  if boolIncludeFlag then
    Include(ALink.FLinkedFile.FFileFlags, ffBinaryFile);

  ReadBooleanBuffer(boolIncludeFlag);

  if boolIncludeFlag then
    Include(ALink.FLinkedFile.FFileFlags, ffUpdatable);

  if not (ffNoLinking in FTSInfoFile.FFileFlags) then
    ProcessLink(ALink);
end;


procedure TTSInfoBinaryInputReader.ProcessLink(ALink: TTSInfoLink);
var
  fsInput: TStream;
  slInput: TStrings;
begin
  with ALink.FLinkedFile do
    if FileExistsUTF8(FFileName) then
    begin
      if ffBinaryFile in FFileFlags then
      begin
        fsInput := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
        try
          LoadTreeFromStream(fsInput);
        finally
          fsInput.Free();
        end;
      end
      else
      begin
        slInput := TStringList.Create();
        try
          slInput.LoadFromFile(FFileName);
          LoadTreeFromList(slInput);
        finally
          slInput.Free();
        end;
      end;
    end;
end;


procedure TTSInfoBinaryInputReader.ProcessInput();
begin
  try
    ReadStaticHeader();
    ReadNode(FTSInfoFile.FRootNode);
  except
    FTSInfoFile.DamageClear();
  end;
end;


{ ----- TTSInfoBinaryOutputWriter --------------------------------------------------------------------------------- }


constructor TTSInfoBinaryOutputWriter.Create(ATSInfoFile: TSimpleTSInfoFile; AOutput: TStream);
begin
  inherited Create();

  FTSInfoFile := ATSInfoFile;
  FOutput := AOutput;
end;


destructor TTSInfoBinaryOutputWriter.Destroy();
begin
  FTSInfoFile := nil;
  FOutput := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryOutputWriter.WriteStringBuffer(ABuffer: AnsiString);
var
  intBufferLen: UInt32 = 0;
begin
  intBufferLen := Length(ABuffer);
  FOutput.Write(intBufferLen, SizeOf(intBufferLen));
  FOutput.Write(ABuffer[1], intBufferLen);
end;


procedure TTSInfoBinaryOutputWriter.WriteBooleanBuffer(ABuffer: Boolean);
begin
  FOutput.Write(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryOutputWriter.WriteUInt32Buffer(ABuffer: UInt32);
begin
  FOutput.Write(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryOutputWriter.WriteStaticHeader();
var
  sngVersion: Single;
begin
  FOutput.Write(BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN);

  sngVersion := HIGHEST_SUPPORTED_FORMAT_VERSION;
  FOutput.Write(sngVersion, SizeOf(sngVersion));

  WriteStringBuffer(FTSInfoFile.FTreeComment);
  WriteStringBuffer(FTSInfoFile.FTreeName);
end;


procedure TTSInfoBinaryOutputWriter.WriteAttribute(AAttribute: TTSInfoAttribute);
begin
  WriteStringBuffer(AAttribute.FComment[ctDeclaration]);
  WriteStringBuffer(AAttribute.FComment[ctDefinition]);

  WriteBooleanBuffer(AAttribute.FReference);

  WriteStringBuffer(AAttribute.FName);
  WriteStringBuffer(AAttribute.FValue);
end;


procedure TTSInfoBinaryOutputWriter.WriteNode(ANode: TTSInfoNode);
var
  linkItem: TTSInfoLink;
  I: Integer;
begin
  WriteStringBuffer(ANode.FComment[ctDeclaration]);
  WriteStringBuffer(ANode.FComment[ctDefinition]);

  WriteBooleanBuffer(ANode.FReference);
  WriteStringBuffer(ANode.FName);

  WriteUInt32Buffer(ANode.AttributesCount);

  for I := 0 to ANode.AttributesCount - 1 do
    WriteAttribute(ANode.GetAttributeByIndex(I));

  WriteUInt32Buffer(ANode.ChildNodesCount);

  for I := 0 to ANode.ChildNodesCount - 1 do
    WriteNode(ANode.GetChildNodeByIndex(I));

  WriteUInt32Buffer(ANode.LinksCount);

  for I := 0 to ANode.LinksCount - 1 do
  begin
    linkItem := ANode.GetLinkByIndex(I);
    WriteLink(linkItem);

    if not (ffNoLinking in FTSInfoFile.FFileFlags) then
      ProcessLink(linkItem);
  end;
end;


procedure TTSInfoBinaryOutputWriter.WriteLink(ALink: TTSInfoLink);
begin
  WriteStringBuffer(ALink.FComment);
  WriteStringBuffer(ALink.FLinkedFile.FFileName);
  WriteStringBuffer(ALink.FVirtualNodeName);

  WriteBooleanBuffer(ffBinaryFile in ALink.FLinkedFile.FFileFlags);
  WriteBooleanBuffer(ffUpdatable in ALink.FLinkedFile.FFileFlags);
end;


procedure TTSInfoBinaryOutputWriter.ProcessLink(ALink: TTSInfoLink);
var
  fsOutput: TStream;
  slOutput: TStrings;
begin
  with ALink.FLinkedFile do
    if ffUpdatable in FFileFlags then
    begin
      if ffBinaryFile in FFileFlags then
      begin
        fsOutput := TFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
        try
          SaveTreeToStream(fsOutput);
        finally
          fsOutput.Free();
        end;
      end
      else
      begin
        slOutput := TStringList.Create();
        try
          SaveTreeToList(slOutput);
          slOutput.SaveToFile(FFileName);
        finally
          slOutput.Free();
        end;
      end;
    end
    else
      LocateAndProcessLinks(ALink);
end;


procedure TTSInfoBinaryOutputWriter.LocateAndProcessLinks(ALink: TTSInfoLink);

  procedure SearchNode(ANode: TTSInfoNode);
  var
    I: Integer;
  begin
    for I := 0 to ANode.LinksCount - 1 do
      ProcessLink(ANode.GetLinkByIndex(I));

    for I := 0 to ANode.ChildNodesCount - 1 do
      SearchNode(ANode.GetChildNodeByIndex(I));
  end;

begin
  SearchNode(ALink.FLinkedFile.FRootNode);
end;


procedure TTSInfoBinaryOutputWriter.ProcessOutput();
begin
  WriteStaticHeader();
  WriteNode(FTSInfoFile.FRootNode);
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

