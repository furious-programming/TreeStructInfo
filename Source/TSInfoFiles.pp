{

    TSInfoFiles.pp                last modified: 27 December 2014

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

{$MODE OBJFPC}{$LONGSTRINGS ON}{$HINTS ON}{$PACKENUM 1}


interface

uses
  TSInfoConsts, TSInfoTypes, TSInfoUtils,
  SysUtils, Classes, Types, Math, FileUtil;


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
  TTSInfoElementsList = class(TObject)
  end;


type
  TTSInfoAttributesList = class(TTSInfoElementsList)
  end;


type
  TTSInfoNodesList = class(TTSInfoElementsList)
  end;


type
  TTSInfoLinksList = class(TTSInfoElementsList)
  end;


type
  TTSInfoRefElementsList = class(TTSInfoElementsList)
  end;


type
  TTSInfoLoadedTreesList = class(TTSInfoElementsList)
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
    constructor Create(AFileName: TFileName; AFlags: TFileFlags = [ffLoadFile, ffWrite]); overload;
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
    procedure RenameAttributeTokens(ANodePath, AAttrName: AnsiString; AStartIndex: Integer; ADirection: TRenamingDirection);
    procedure RenameChildNodeTokens(ANodePath, ANodeName: AnsiString; AStartIndex: Integer; ADirection: TRenamingDirection);
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
  TTSInfoTextInputReader = class(TObject)
  end;


type
  TTSInfoTextOutputWriter = class(TObject)
  end;


type
  TTSInfoBinaryInputReader = class(TObject)
  end;


type
  TTSInfoBinaryOutputWriter = class(TCustomTSInfoOutputWriter)
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


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


constructor TSimpleTSInfoFile.Create(AFileName: TFileName; AFlags: TFileFlags = [ffLoadFile, ffWrite]);
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
  if ffWrite in FFileFlags then
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


procedure TSimpleTSInfoFile.RenameAttributeTokens(ANodePath, AAttrName: AnsiString; AStartIndex: Integer; ADirection: TRenamingDirection); {}
var
  nodeParent: TTSInfoNode;
  attrRename: TTSInfoAttribute;
  intToken, intStep: Integer;
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
      if ValidIdentifier(AAttrName) then
      begin
        intStep := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

        for intToken := 0 to nodeParent.AttributesCount - 1 do
        begin
          attrRename := nodeParent.GetAttributeByIndex(intToken);
          attrRename.Name := Format(AAttrName, [AStartIndex]);

          Inc(AStartIndex, intStep);
        end;
      end;
  end;
end;


procedure TSimpleTSInfoFile.RenameChildNodeTokens(ANodePath, ANodeName: AnsiString; AStartIndex: Integer; ADirection: TRenamingDirection); {}
var
  nodeParent, nodeRename: TTSInfoNode;
  intToken, intStep: Integer;
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
      if ValidIdentifier(ANodeName) then
      begin
        intStep := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

        for intToken := 0 to nodeParent.ChildNodesCount - 1 do
        begin
          nodeRename := nodeParent.GetChildNodeByIndex(intToken);
          nodeRename.Name := Format(ANodeName, [AStartIndex]);

          Inc(AStartIndex, intStep);
        end;
      end;
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


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

