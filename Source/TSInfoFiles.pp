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
  LResources, LazUTF8, Classes, SysUtils, FileUtil, Types;


{ ----- basic elements classes ------------------------------------------------------------------------------------ }


type
  TTSInfoAttribute = class(TObject)
  private
    FReference: Boolean;
    FName: UTF8String;
    FValue: UTF8String;
    FComment: TComment;
  private
    procedure SetName(const AName: UTF8String);
    procedure SetValue(const AValue: UTF8String);
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; const AValue: UTF8String);
  public
    constructor Create(AReference: Boolean; const AName: UTF8String); overload;
    constructor Create(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment); overload;
  public
    property Reference: Boolean read FReference write FReference;
    property Name: UTF8String read FName write SetName;
    property Value: UTF8String read FValue write SetValue;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
  end;


type
  TTSInfoLink = class;

type
  TTSInfoAttributesList = class;
  TTSInfoNodesList = class;
  TTSInfoLinksList = class;

type
  TTSInfoNode = class(TObject)
  private
    FParentNode: TTSInfoNode;
    FReference: Boolean;
    FName: UTF8String;
    FComment: TComment;
    FAttributesList: TTSInfoAttributesList;
    FChildNodesList: TTSInfoNodesList;
    FLinksList: TTSInfoLinksList;
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; const AValue: UTF8String);
    procedure SetName(const AName: UTF8String);
  public
    function GetAttribute(const AName: UTF8String): TTSInfoAttribute; overload;
    function GetAttribute(AIndex: Integer): TTSInfoAttribute; overload;
    function GetChildNode(const AName: UTF8String): TTSInfoNode; overload;
    function GetChildNode(AIndex: Integer): TTSInfoNode; overload;
    function GetLink(const AVirtualNodeName: UTF8String): TTSInfoLink; overload;
    function GetLink(AIndex: Integer): TTSInfoLink; overload;
    function GetVirtualNode(const AName: UTF8String): TTSInfoNode;
  public
    function GetAttributesCount(): Integer;
    function GetChildNodesCount(): Integer;
    function GetLinksCount(): Integer;
  public
    constructor Create(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment);
    destructor Destroy(); override;
  public
    function CreateAttribute(AReference: Boolean; const AName: UTF8String): TTSInfoAttribute; overload;
    function CreateAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute; overload;
    function CreateChildNode(AReference: Boolean; const AName: UTF8String): TTSInfoNode; overload;
    function CreateChildNode(AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode; overload;
    function CreateLink(const AFileName, AVirtualNodeName: UTF8String): TTSInfoLink; overload;
    function CreateLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink; overload;
  public
    procedure RemoveAttribute(const AName: UTF8String);
    procedure RemoveChildNode(const AName: UTF8String);
    procedure RemoveLink(const AVirtualNodeName: UTF8String);
  public
    procedure ClearAttributes();
    procedure ClearChildNodes();
    procedure ClearLinks();
  public
    property ParentNode: TTSInfoNode read FParentNode;
    property Reference: Boolean read FReference write FReference;
    property Name: UTF8String read FName write SetName;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
    property AttributesCount: UInt32 read GetAttributesCount;
    property ChildNodesCount: UInt32 read GetChildNodesCount;
    property LinksCount: UInt32 read GetLinksCount;
  end;


type
  TSimpleTSInfoTree = class;

type
  TTSInfoLink = class(TObject)
  private
    FLinkedTree: TSimpleTSInfoTree;
    FVirtualNode: TTSInfoNode;
    FVirtualNodeName: UTF8String;
    FComment: UTF8String;
  private
    procedure SetVirtualNodeName(const AVirtualNodeName: UTF8String);
    procedure SetLinkedTreeModes(AModes: TTreeModes);
    procedure SetComment(const AComment: UTF8String);
  private
    function GetLinkedFileName(): UTF8String;
    function GetLinkedTreeModes(): TTreeModes;
  public
    constructor Create(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String);
    destructor Destroy(); override;
  public
    property LinkedTree: TSimpleTSInfoTree read FLinkedTree;
    property VirtualNode: TTSInfoNode read FVirtualNode;
    property VirtualNodeName: UTF8String read FVirtualNodeName write SetVirtualNodeName;
    property Comment: UTF8String read FComment write SetComment;
    property FileName: UTF8String read GetLinkedFileName;
    property TreeModes: TTreeModes read GetLinkedTreeModes write SetLinkedTreeModes;
  end;


{ ----- elements container classes -------------------------------------------------------------------------------- }


type
  TTSInfoElementsList = class(TObject)
  private type
    PListNode = ^TListNode;
    TListNode = record
      PreviousNode: PListNode;
      NextNode: PListNode;
      Element: TObject;
    end;
  private
    FFirstNode: PListNode;
    FLastNode: PListNode;
    FLastUsedNode: PListNode;
    FLastUsedNodeIndex: Integer;
    FCount: Integer;
    FOwnsElements: Boolean;
  private
    procedure DisposeRemainingNodes();
    procedure DisposeRemainingElements();
  private
    function CreateNode(AElement: TObject): PListNode;
  private
    function GetNodeAtIndex(AIndex: Integer): PListNode;
    function GetElementAtIndex(AIndex: Integer): TObject;
  public
    constructor Create(AOwnsElements: Boolean);
    destructor Destroy(); override;
  public
    procedure AddElement(AElement: TObject);
    procedure RemoveElement(AIndex: Integer);
    procedure RemoveAllElements();
  public
    property Count: Integer read FCount;
    property OwnsElements: Boolean read FOwnsElements;
  public
    property Element[AIndex: Integer]: TObject read GetElementAtIndex;
  end;


type
  TTSInfoAttributesList = class(TTSInfoElementsList)
  private
    function InternalAddAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetAttribute(const AName: UTF8String): TTSInfoAttribute; overload;
    function GetAttribute(AIndex: Integer): TTSInfoAttribute; overload;
  public
    function AddAttribute(AReference: Boolean; const AName: UTF8String): TTSInfoAttribute; overload;
    function AddAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute; overload;
  public
    procedure RemoveAttribute(const AName: UTF8String);
    procedure RemoveAll();
  end;


type
  TTSInfoNodesList = class(TTSInfoElementsList)
  private
    function InternalAddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetChildNode(const AName: UTF8String): TTSInfoNode; overload;
    function GetChildNode(AIndex: Integer): TTSInfoNode; overload;
  public
    function AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String): TTSInfoNode; overload;
    function AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode; overload;
  end;


type
  TTSInfoLinksList = class(TTSInfoElementsList)
  end;


{ ----- additional container classes ------------------------------------------------------------------------------ }


type
  TTSInfoRefElementsList = class(TTSInfoElementsList)
  end;


type
  TTSInfoLoadedTreesList = class(TTSInfoElementsList)
  end;


{ ----- token objects --------------------------------------------------------------------------------------------- }


type
  TTSInfoAttributeToken = object
  private
    FAttribute: TTSInfoAttribute;
    FParentNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; AValue: UTF8String);
  public
    property Name: UTF8String read FAttribute.FName;
    property Reference: Boolean read FAttribute.FReference write FAttribute.FReference;
    property Value: UTF8String read FAttribute.FValue write FAttribute.FValue;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
  end;


type
  TTSInfoChildNodeToken = object
  private
    FChildNode: TTSInfoNode;
    FParentNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; AValue: UTF8String);
  public
    property Name: UTF8String read FChildNode.FName;
    property Reference: Boolean read FChildNode.FReference write FChildNode.FReference;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
  end;


{ ----- tree classes ---------------------------------------------------------------------------------------------- }


type
  TSimpleTSInfoTree = class(TObject)
  private
    FRootNode: TTSInfoNode;
    FCurrentNode: TTSInfoNode;
    FFileName: TFileName;
    FTreeName: UTF8String;
    FTreeComment: UTF8String;
    FCurrentlyOpenNodePath: UTF8String;
    FFileFlags: TTreeModes;
    FModified: Boolean;
    FReadOnlyMode: Boolean;
  protected
    procedure InitFields(AFileName: TFileName; AFlags: TTreeModes);
    procedure DamageClear();
  protected
    procedure LoadTreeFromList(AList: TStrings);
    procedure LoadTreeFromStream(AStream: TStream);
    procedure SaveTreeToList(AList: TStrings);
    procedure SaveTreeToStream(AStream: TStream);
  protected
    function FindElement(AElementName: UTF8String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
    function FindAttribute(AAttrName: UTF8String; AForcePath: Boolean): TTSInfoAttribute;
    function FindNode(ANodePath: UTF8String; AForcePath: Boolean): TTSInfoNode;
  public
    constructor Create(AFileName: TFileName; AFlags: TTreeModes = [ffLoadFile, ffWrite]); overload;
    constructor Create(AInput: TStrings; AFileName: TFileName = ''; AFlags: TTreeModes = []); overload;
    constructor Create(AInput: TStream; AFileName: TFileName = ''; AFlags: TTreeModes = []); overload;
    constructor Create(AInstance: TFPResourceHMODULE; AResName: String; AResType: PUTF8Char; AFlags: TTreeModes = []); overload;
    constructor Create(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PUTF8Char; AFlags: TTreeModes = []); overload;
    destructor Destroy(); override;
  public
    function OpenChildNode(ANodePath: UTF8String; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
    procedure CloseChildNode();
  public
    procedure WriteBoolean(AAttrName: UTF8String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
    procedure WriteInteger(AAttrName: UTF8String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
    procedure WriteFloat(AAttrName: UTF8String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteFloat(AAttrName: UTF8String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteCurrency(AAttrName: UTF8String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteCurrency(AAttrName: UTF8String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteString(AAttrName: UTF8String; AString: UTF8String; AFormat: TFormatString = fsOriginal);
    procedure WriteDateTime(AAttrName: UTF8String; ADateTime: TDateTime; AMask: UTF8String); overload;
    procedure WriteDateTime(AAttrName: UTF8String; ADateTime: TDateTime; AMask: UTF8String; ASettings: TFormatSettings); overload;
    procedure WritePoint(AAttrName: UTF8String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
    procedure WriteList(AAttrName: UTF8String; AList: TStrings);
    procedure WriteBuffer(AAttrName: UTF8String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
    procedure WriteStream(AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
  public
    function ReadBoolean(AAttrName: UTF8String; ADefault: Boolean): Boolean;
    function ReadInteger(AAttrName: UTF8String; ADefault: Integer): Integer;
    function ReadFloat(AAttrName: UTF8String; ADefault: Double): Double; overload;
    function ReadFloat(AAttrName: UTF8String; ADefault: Double; ASettings: TFormatSettings): Double; overload;
    function ReadCurrency(AAttrName: UTF8String; ADefault: Currency): Currency; overload;
    function ReadCurrency(AAttrName: UTF8String; ADefault: Currency; ASettings: TFormatSettings): Currency; overload;
    function ReadString(AAttrName: UTF8String; ADefault: UTF8String; AFormat: TFormatString = fsOriginal): UTF8String;
    function ReadDateTime(AAttrName, AMask: UTF8String; ADefault: TDateTime): TDateTime; overload;
    function ReadDateTime(AAttrName, AMask: UTF8String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime; overload;
    function ReadPoint(AAttrName: UTF8String; ADefault: TPoint): TPoint;
    procedure ReadList(AAttrName: UTF8String; AList: TStrings);
    procedure ReadBuffer(AAttrName: UTF8String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
    procedure ReadStream(AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
  public
    function CreateAttribute(ANodePath: UTF8String; AReference: Boolean; AAttrName: UTF8String): Boolean;
    function CreateChildNode(ANodePath: UTF8String; AReference: Boolean; ANodeName: UTF8String; AOpen: Boolean = False): Boolean;
    function CreateLink(ANodePath: UTF8String; AFileName: TFileName; AVirtualNodeName: UTF8String; AFlags: TTreeModes; AOpen: Boolean = False): Boolean;
  public
    function FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; AParentNodePath: UTF8String = ''): Boolean;
    function FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
    function FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; AParentNodePath: UTF8String = ''): Boolean;
    function FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
  public
    procedure RenameAttributeTokens(ANodePath, AAttrName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
    procedure RenameChildNodeTokens(ANodePath, ANodeName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
  public
    procedure UpdateFile();
  public
    property FileName: TFileName read FFileName;
    property TreeName: UTF8String read FTreeName;
    property CurrentlyOpenNodeName: UTF8String read FCurrentNode.FName;
    property CurrentlyOpenNodePath: UTF8String read FCurrentlyOpenNodePath;
    property FileFlags: TTreeModes read FFileFlags write FFileFlags;
    property Modified: Boolean read FModified;
    property ReadOnlyMode: Boolean read FReadOnlyMode;
  end;


type
  TTSInfoTree = class(TSimpleTSInfoTree)
  public
    procedure RenameTree(ANewTreeName: UTF8String);
    procedure RenameAttribute(AAttrName, ANewAttrName: UTF8String);
    procedure RenameChildNode(ANodePath, ANewNodeName: UTF8String);
    procedure RenameVirtualNode(ANodePath, AVirtualNodeName, ANewVirtualNodeName: UTF8String);
  public
    procedure WriteTreeComment(AComment, ADelimiter: UTF8String);
    procedure WriteAttributeComment(AAttrName, AComment, ADelimiter: UTF8String; AType: TCommentType);
    procedure WriteChildNodeComment(ANodePath, AComment, ADelimiter: UTF8String; AType: TCommentType);
    procedure WriteLinkComment(ANodePath, AVirtualNodeName, AComment, ADelimiter: UTF8String);
  public
    function ReadTreeComment(ADelimiter: UTF8String): UTF8String;
    function ReadAttributeComment(AAttrName, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
    function ReadChildNodeComment(ANodePath, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
    function ReadLinkComment(ANodePath, AVirtualNodeName, ADelimiter: UTF8String): UTF8String;
  public
    procedure WriteAttributeReference(AAttrName: UTF8String; AReference: Boolean);
    procedure WriteChildNodeReference(ANodePath: UTF8String; AReference: Boolean);
  public
    function ReadAttributeReference(AAttrName: UTF8String): Boolean;
    function ReadChildNodeReference(ANodePath: UTF8String = ''): Boolean;
  public
    procedure RemoveAttribute(AAttrName: UTF8String);
    procedure RemoveChildNode(ANodePath: UTF8String);
    procedure RemoveLink(ANodePath, AVirtualNodeName: UTF8String);
  public
    procedure RemoveAllAttributes(ANodePath: UTF8String = '');
    procedure RemoveAllChildNodes(ANodePath: UTF8String = '');
    procedure RemoveAllLinks(ANodePath: UTF8String = '');
  public
    procedure ClearChildNode(ANodePath: UTF8String = '');
    procedure ClearTree();
  public
    function AttributeExists(AAttrName: UTF8String): Boolean;
    function ChildNodeExists(ANodePath: UTF8String): Boolean;
    function LinkExists(ANodePath, AVirtualNodeName: UTF8String): Boolean;
  public
    function GetAttributesCount(ANodePath: UTF8String = ''): UInt32;
    function GetChildNodesCount(ANodePath: UTF8String = ''): UInt32;
    function GetLinksCount(ANodePath: UTF8String = ''): UInt32;
  public
    procedure ReadAttributesNames(ANodePath: UTF8String; ANames: TStrings);
    procedure ReadAttributesValues(ANodePath: UTF8String; AValues: TStrings);
    procedure ReadChildNodesNames(ANodePath: UTF8String; ANames: TStrings);
    procedure ReadVirtualNodesNames(ANodePath: UTF8String; ANames: TStrings);
  public
    procedure ExportTreeToFile(AFileName: TFileName; AFormat: TExportFormat = efTextFile);
    procedure ExportTreeToList(AList: TStrings);
    procedure ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryFile);
  end;


{ ----- text input reader and output writer classes --------------------------------------------------------------- }


type
  TTSInfoTextInputReader = class(TObject)
  end;


type
  TTSInfoTextOutputWriter = class(TObject)
  end;


{ ----- binary input reader and output writer classes ------------------------------------------------------------- }


type
  TTSInfoBinaryInputReader = class(TObject)
  end;


type
  TTSInfoBinaryOutputWriter = class(TCustomTSInfoOutputWriter)
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TTSInfoAttribute class ------------------------------------------------------------------------------------ }


constructor TTSInfoAttribute.Create(AReference: Boolean; const AName: UTF8String);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := '';
  FComment[ctDeclaration] := '';
  FComment[ctDefinition] := '';
end;


constructor TTSInfoAttribute.Create(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := AValue;
  FComment := AComment;
end;


procedure TTSInfoAttribute.SetName(const AName: UTF8String);
begin
  FName := AName;
end;


procedure TTSInfoAttribute.SetValue(const AValue: UTF8String);
begin
  FValue := AValue;
end;


function TTSInfoAttribute.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FComment[AType];
end;


procedure TTSInfoAttribute.SetComment(AType: TCommentType; const AValue: UTF8String);
begin
  FComment[AType] := AValue;
end;


{ ----- TTSInfoNode class ----------------------------------------------------------------------------------------- }


constructor TTSInfoNode.Create(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment);
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


function TTSInfoNode.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FComment[AType];
end;


procedure TTSInfoNode.SetComment(AType: TCommentType; const AValue: UTF8String);
begin
  FComment[AType] := AValue;
end;


procedure TTSInfoNode.SetName(const AName: UTF8String);
begin
  FName := AName;
end;


function TTSInfoNode.GetAttribute(const AName: UTF8String): TTSInfoAttribute;
begin
  Result := FAttributesList.GetAttribute(AName);
end;


function TTSInfoNode.GetAttribute(AIndex: Integer): TTSInfoAttribute;
begin
  Result := FAttributesList.GetAttribute(AIndex);
end;


function TTSInfoNode.GetChildNode(const AName: UTF8String): TTSInfoNode;
begin
  Result := FChildNodesList.GetChildNode(AName);
end;


function TTSInfoNode.GetChildNode(AIndex: Integer): TTSInfoNode;
begin
  Result := FChildNodesList.GetChildNode(AIndex);
end;


function TTSInfoNode.GetLink(const AVirtualNodeName: UTF8String): TTSInfoLink;
begin
  Result := FLinksList.GetLink(AVirtualNodeName);
end;


function TTSInfoNode.GetLink(AIndex: Integer): TTSInfoLink;
begin
  Result := FLinksList.GetLink(AIndex);
end;


function TTSInfoNode.GetVirtualNode(const AName: UTF8String): TTSInfoNode;
begin
  Result := FLinksList.GetVirtualNode(AName);
end;


function TTSInfoNode.GetAttributesCount(): Integer;
begin
  Result := FAttributesList.Count;
end;


function TTSInfoNode.GetChildNodesCount(): Integer;
begin
  Result := FChildNodesList.Count;
end;


function TTSInfoNode.GetLinksCount(): Integer;
begin
  Result := FLinksList.Count;
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; const AName: UTF8String): TTSInfoAttribute;
begin
  Result := FAttributesList.AddAttribute(AReference, AName);
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := FAttributesList.AddAttribute(AReference, AName, AValue, AComment);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; const AName: UTF8String): TTSInfoNode;
begin
  Result := FChildNodesList.AddChildNode(Self, AReference, AName);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode;
begin
  Result := FChildNodesList.AddChildNode(Self, AReference, AName, AComment);
end;


function TTSInfoNode.CreateLink(const AFileName, AVirtualNodeName: UTF8String): TTSInfoLink;
begin
  Result := FLinksList.AddLink(AFileName, AVirtualNodeName);
end;


function TTSInfoNode.CreateLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink;
begin
  Result := FLinksList.AddLink(AFileName, AVirtualNodeName, AModes, AComment);
end;


procedure TTSInfoNode.RemoveAttribute(const AName: UTF8String);
begin
  FAttributesList.RemoveAttribute(AName);
end;


procedure TTSInfoNode.RemoveChildNode(const AName: UTF8String);
begin
  FChildNodesList.RemoveChildNode(AName);
end;


procedure TTSInfoNode.RemoveLink(const AVirtualNodeName: UTF8String);
begin
  FLinksList.RemoveLink(AVirtualNodeName);
end;


procedure TTSInfoNode.ClearAttributes();
begin
  FAttributesList.RemoveAll();
end;

procedure TTSInfoNode.ClearChildNodes();
begin
  FChildNodesList.RemoveAll();
end;


procedure TTSInfoNode.ClearLinks();
begin
  FLinksList.RemoveAll();
end;


{ ----- TTSInfoLink class ----------------------------------------------------------------------------------------- }


constructor TTSInfoLink.Create(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String);
begin
  inherited Create();

  FLinkedTree := TSimpleTSInfoTree.Create(AFileName, AModes);
  FVirtualNode := FLinkedTree.FRootNode;
  FVirtualNodeName := AVirtualNodeName;

  FComment := AComment;
end;


destructor TTSInfoLink.Destroy();
begin
  FLinkedTree.TreeModes := [];
  FLinkedTree.Free();
  FVirtualNode := nil;

  inherited Destroy();
end;


procedure TTSInfoLink.SetVirtualNodeName(const AVirtualNodeName: UTF8String);
begin
  FVirtualNodeName := AVirtualNodeName;
end;


procedure TTSInfoLink.SetLinkedTreeModes(AModes: TTreeModes);
begin
  FLinkedTree.FTreeModes := AModes;
end;


procedure TTSInfoLink.SetComment(const AComment: UTF8String);
begin
  FComment := AComment;
end;


function TTSInfoLink.GetLinkedFileName(): UTF8String;
begin
  Result := FLinkedTree.FileName;
end;


function TTSInfoLink.GetLinkedTreeModes(): TTreeModes;
begin
  Result := FLinkedTree.TreeModes;
end;


{ ----- TTSInfoElementsList class --------------------------------------------------------------------------------- }


constructor TTSInfoElementsList.Create(AOwnsElements: Boolean);
begin
  inherited Create();

  FFirstNode := nil;
  FLastNode := nil;

  FLastUsedNode := nil;
  FLastUsedNodeIndex := -1;

  FCount := 0;
  FOwnsElements := AOwnsElements;
end;


destructor TTSInfoElementsList.Destroy();
begin
  if FCount > 0 then
    DisposeRemainingNodes();

  inherited Destroy();
end;


procedure TTSInfoElementsList.DisposeRemainingNodes();
var
  plnNext, plnDispose: PListNode;
begin
  if FOwnsElements then
    DisposeRemainingElements();

  plnDispose := FFirstNode;

  while plnDispose <> nil do
  begin
    plnNext := plnDispose^.NextNode;
    Dispose(plnDispose);

    plnDispose := plnNext;
  end;

  FFirstNode := nil;
  FLastNode := nil;

  FLastUsedNode := nil;
  FLastUsedNodeIndex := -1;

  FCount := 0;
end;


procedure TTSInfoElementsList.DisposeRemainingElements();
var
  plnElement: PListNode;
begin
  plnElement := FFirstNode;

  while plnElement <> nil do
  begin
    plnElement^.Element.Free();
    plnElement := plnElement^.NextNode;
  end;
end;


function TTSInfoElementsList.CreateNode(AElement: TObject): PListNode;
begin
  New(Result);

  Result^.PreviousNode := nil;
  Result^.NextNode := nil;
  Result^.Element := AElement;
end;


function TTSInfoElementsList.GetNodeAtIndex(AIndex: Integer): PListNode;
begin
  if FLastUsedNodeIndex - AIndex > FLastUsedNodeIndex shr 1 then
  begin
    FLastUsedNode := FFirstNode;
    FLastUsedNodeIndex := 0;
  end
  else
    if AIndex - FLastUsedNodeIndex > FCount - 1 - AIndex then
    begin
      FLastUsedNode := FLastNode;
      FLastUsedNodeIndex := FCount - 1;
    end;

  if FLastUsedNodeIndex < AIndex then
    while FLastUsedNodeIndex < AIndex do
    begin
      FLastUsedNode := FLastUsedNode^.NextNode;
      Inc(FLastUsedNodeIndex);
    end
  else
    while FLastUsedNodeIndex > AIndex do
    begin
      FLastUsedNode := FLastUsedNode^.PreviousNode;
      Dec(FLastUsedNodeIndex);
    end;

  Result := FLastUsedNode;
end;


function TTSInfoElementsList.GetElementAtIndex(AIndex: Integer): TObject;
begin
  Result := GetNodeAtIndex(AIndex)^.Element;
end;


procedure TTSInfoElementsList.AddElement(AElement: TObject);
var
  plnNew: PListNode;
begin
  plnNew := CreateNode(AElement);

  if FCount = 0 then
  begin
    FFirstNode := plnNew;
    FLastUsedNode := plnNew;
    FLastUsedNodeIndex := 0;
  end
  else
  begin
    plnNew^.PreviousNode := FLastNode;
    FLastNode^.NextNode := plnNew;
  end;

  FLastNode := plnNew;
  Inc(FCount);
end;


procedure TTSInfoElementsList.RemoveElement(AIndex: Integer);
var
  plnDispose: PListNode;
begin
  plnDispose := GetNodeAtIndex(AIndex);

  if FLastUsedNode = FLastNode then
  begin
    FLastUsedNode := FLastUsedNode^.PreviousNode;
    Dec(FLastUsedNodeIndex);
  end
  else
    FLastUsedNode := FLastUsedNode^.NextNode;

  if AIndex = 0 then
  begin
    plnDispose := FFirstNode;
    FFirstNode := FFirstNode^.NextNode;

    if FFirstNode = nil then
      FLastNode := nil
    else
      FFirstNode^.PreviousNode := nil;
  end
  else
  begin
    plnDispose^.PreviousNode^.NextNode := plnDispose^.NextNode;

    if plnDispose = FLastNode then
      FLastNode := plnDispose^.PreviousNode
    else
      plnDispose^.NextNode^.PreviousNode := plnDispose^.PreviousNode;
  end;

  if FOwnsElements then
    plnDispose^.Element.Free();

  Dispose(plnDispose);
  Dec(FCount);
end;


procedure TTSInfoElementsList.RemoveAllElements();
begin
  DisposeRemainingNodes();
end;


{ ----- TTSInfoAttributeList class -------------------------------------------------------------------------------- }


constructor TTSInfoAttributesList.Create();
begin
  inherited Create(True);
end;


destructor TTSInfoAttributesList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoAttributesList.InternalAddAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := TTSInfoAttribute.Create(AReference, AName, AValue, AComment);
  inherited AddElement(Result);
end;


function TTSInfoAttributesList.GetAttribute(const AName: UTF8String): TTSInfoAttribute;
var
  attrGet: TTSInfoAttribute;
  intAttributeIdx: Integer;
begin
  for intAttributeIdx := 0 to FCount - 1 do
  begin
    attrGet := inherited Element[intAttributeIdx] as TTSInfoAttribute;

    if SameIdentifiers(attrGet.Name, AName) then
      Exit(attrGet);
  end;

  Result := nil;
end;


function TTSInfoAttributesList.GetAttribute(AIndex: Integer): TTSInfoAttribute;
begin
  Result := inherited Element[AIndex] as TTSInfoAttribute;
end;


function TTSInfoAttributesList.AddAttribute(AReference: Boolean; const AName: UTF8String): TTSInfoAttribute;
begin
  Result := InternalAddAttribute(AReference, AName, '', Comment('', ''));
end;


function TTSInfoAttributesList.AddAttribute(AReference: Boolean; const AName, AValue: UTF8String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := InternalAddAttribute(AReference, AName, AValue, AComment);
end;


procedure TTSInfoAttributesList.RemoveAttribute(const AName: UTF8String);
var
  attrRemove: TTSInfoAttribute;
  intAttributeIdx: Integer;
begin
  for intAttributeIdx := 0 to FCount - 1 do
  begin
    attrRemove := inherited Element[intAttributeIdx] as TTSInfoAttribute;

    if SameIdentifiers(attrRemove.Name, AName) then
    begin
      inherited RemoveElement(intAttributeIdx);
      Exit();
    end;
  end;
end;


procedure TTSInfoAttributesList.RemoveAll();
begin
  inherited RemoveAllElements();
end;


{ ----- TTSInfoNodesList class ------------------------------------------------------------------------------------ }


constructor TTSInfoNodesList.Create();
begin
  inherited Create(True);
end;


destructor TTSInfoNodesList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoNodesList.InternalAddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode;
begin
  Result := TTSInfoNode.Create(AParentNode, AReference, AName, AComment);
  inherited AddElement(Result);
end;


function TTSInfoNodesList.GetChildNode(const AName: UTF8String): TTSInfoNode;
var
  nodeGet: TTSInfoNode;
  intChildNodeIdx: Integer;
begin
  for intChildNodeIdx := 0 to FCount - 1 do
  begin
    nodeGet := inherited Element[intChildNodeIdx] as TTSInfoNode;

    if SameIdentifiers(nodeGet.Name, AName) then
      Exit(nodeGet);
  end;

  Result := nil;
end;


function TTSInfoNodesList.GetChildNode(AIndex: Integer): TTSInfoNode;
begin
  Result := inherited Element[AIndex] as TTSInfoNode;
end;


function TTSInfoNodesList.AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String): TTSInfoNode;
begin
  Result := InternalAddChildNode(AParentNode, AReference, AName, Comment('', ''));
end;


function TTSInfoNodesList.AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: UTF8String; const AComment: TComment): TTSInfoNode;
begin
  Result := InternalAddChildNode(AParentNode, AReference, AName, AComment);
end;


{ ----- TTSInfoLinksList class ------------------------------------------------------------------------------------ }


{ ----- TTSInfoRefElementsList class ------------------------------------------------------------------------------ }


{ ----- TTSInfoLoadedTreesList class ------------------------------------------------------------------------------ }


{ ----- TTSInfoAttributeToken object ------------------------------------------------------------------------------ }


function TTSInfoAttributeToken.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FAttribute.FComment[AType];
end;


procedure TTSInfoAttributeToken.SetComment(AType: TCommentType; AValue: UTF8String);
begin
  FAttribute.FComment[AType] := AValue;
end;


{ ----- TTSInfoChildNodeToken object ------------------------------------------------------------------------------ }


function TTSInfoChildNodeToken.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FChildNode.FComment[AType];
end;


procedure TTSInfoChildNodeToken.SetComment(AType: TCommentType; AValue: UTF8String);
begin
  FChildNode.FComment[AType] := AValue;
end;


{ ----- TSimpleTSInfoTree class ----------------------------------------------------------------------------------- }


constructor TSimpleTSInfoTree.Create(AFileName: TFileName; AFlags: TTreeModes = [ffLoadFile, ffWrite]);
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


constructor TSimpleTSInfoTree.Create(AInput: TStrings; AFileName: TFileName = ''; AFlags: TTreeModes = []);
begin
  inherited Create();

  InitFields(AFileName, AFlags);
  LoadTreeFromList(AInput);
end;


constructor TSimpleTSInfoTree.Create(AInput: TStream; AFileName: TFileName = ''; AFlags: TTreeModes = []);
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


constructor TSimpleTSInfoTree.Create(AInstance: TFPResourceHMODULE; AResName: String; AResType: PUTF8Char; AFlags: TTreeModes = []);
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


constructor TSimpleTSInfoTree.Create(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PUTF8Char; AFlags: TTreeModes = []);
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


destructor TSimpleTSInfoTree.Destroy();
begin
  if ffWrite in FFileFlags then
    UpdateFile();

  FRootNode.Free();
  inherited Destroy();
end;


procedure TSimpleTSInfoTree.InitFields(AFileName: TFileName; AFlags: TTreeModes);
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


procedure TSimpleTSInfoTree.DamageClear();
begin
  FRootNode.ClearAttributes();
  FRootNode.ClearChildNodes();
  FRootNode.ClearLinks();

  FCurrentNode := FRootNode;
  FFileFlags := [];
end;


procedure TSimpleTSInfoTree.LoadTreeFromList(AList: TStrings);
begin
  with TTSInfoTextInputReader.Create(Self, AList) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadTreeFromStream(AStream: TStream);
begin
  with TTSInfoBinaryInputReader.Create(Self, AStream) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.SaveTreeToList(AList: TStrings);
begin
  with TTSInfoTextOutputWriter.Create(Self, AList) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.SaveTreeToStream(AStream: TStream);
begin
  with TTSInfoBinaryOutputWriter.Create(Self, AStream) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


function TSimpleTSInfoTree.FindElement(AElementName: UTF8String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
var
  nodeRead, nodeTemp: TTSInfoNode;
  intPathLen: UInt32;
  pchrNameBgn, pchrNameEnd, pchrLast: PUTF8Char;
  strName: UTF8String;
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
          nodeTemp := nodeRead.GetChildNode(strName);

          if nodeTemp = nil then
            nodeTemp := nodeRead.GetVirtualNode(strName);

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
          Result := nodeRead.GetAttribute(strName);

          if (Result = nil) and AForcePath then
            Result := nodeRead.CreateAttribute(False, strName);
        end;
      end;
    end
    else
      Result := nodeRead;
  end;
end;


function TSimpleTSInfoTree.FindAttribute(AAttrName: UTF8String; AForcePath: Boolean): TTSInfoAttribute;
begin
  Result := FindElement(AAttrName, AForcePath, True) as TTSInfoAttribute;
end;


function TSimpleTSInfoTree.FindNode(ANodePath: UTF8String; AForcePath: Boolean): TTSInfoNode;
begin
  Result := FindElement(ANodePath, AForcePath, False) as TTSInfoNode;
end;


function TSimpleTSInfoTree.OpenChildNode(ANodePath: UTF8String; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
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


procedure TSimpleTSInfoTree.CloseChildNode();
begin
  FCurrentNode := FRootNode;
  FCurrentlyOpenNodePath := '';
  FReadOnlyMode := False;
end;


procedure TSimpleTSInfoTree.WriteBoolean(AAttrName: UTF8String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
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


procedure TSimpleTSInfoTree.WriteInteger(AAttrName: UTF8String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
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


procedure TSimpleTSInfoTree.WriteFloat(AAttrName: UTF8String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral);
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


procedure TSimpleTSInfoTree.WriteFloat(AAttrName: UTF8String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral);
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


procedure TSimpleTSInfoTree.WriteCurrency(AAttrName: UTF8String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice);
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


procedure TSimpleTSInfoTree.WriteCurrency(AAttrName: UTF8String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice);
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


procedure TSimpleTSInfoTree.WriteString(AAttrName: UTF8String; AString: UTF8String; AFormat: TFormatString = fsOriginal);
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


procedure TSimpleTSInfoTree.WriteDateTime(AAttrName: UTF8String; ADateTime: TDateTime; AMask: UTF8String);
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


procedure TSimpleTSInfoTree.WriteDateTime(AAttrName: UTF8String; ADateTime: TDateTime; AMask: UTF8String; ASettings: TFormatSettings);
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


procedure TSimpleTSInfoTree.WritePoint(AAttrName: UTF8String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
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


procedure TSimpleTSInfoTree.WriteList(AAttrName: UTF8String; AList: TStrings);
var
  attrWrite: TTSInfoAttribute;
  strValue: UTF8String;
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


procedure TSimpleTSInfoTree.WriteBuffer(AAttrName: UTF8String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  strValue: UTF8String = '';
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


procedure TSimpleTSInfoTree.WriteStream(AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  arrBuffer: TByteDynArray;
  strValue: UTF8String = '';
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


function TSimpleTSInfoTree.ReadBoolean(AAttrName: UTF8String; ADefault: Boolean): Boolean;
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


function TSimpleTSInfoTree.ReadInteger(AAttrName: UTF8String; ADefault: Integer): Integer;
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


function TSimpleTSInfoTree.ReadFloat(AAttrName: UTF8String; ADefault: Double): Double;
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


function TSimpleTSInfoTree.ReadFloat(AAttrName: UTF8String; ADefault: Double; ASettings: TFormatSettings): Double;
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


function TSimpleTSInfoTree.ReadCurrency(AAttrName: UTF8String; ADefault: Currency): Currency;
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


function TSimpleTSInfoTree.ReadCurrency(AAttrName: UTF8String; ADefault: Currency; ASettings: TFormatSettings): Currency;
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


function TSimpleTSInfoTree.ReadString(AAttrName: UTF8String; ADefault: UTF8String; AFormat: TFormatString = fsOriginal): UTF8String;
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


function TSimpleTSInfoTree.ReadDateTime(AAttrName, AMask: UTF8String; ADefault: TDateTime): TDateTime;
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


function TSimpleTSInfoTree.ReadDateTime(AAttrName, AMask: UTF8String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime;
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


function TSimpleTSInfoTree.ReadPoint(AAttrName: UTF8String; ADefault: TPoint): TPoint;
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


procedure TSimpleTSInfoTree.ReadList(AAttrName: UTF8String; AList: TStrings);
var
  attrRead: TTSInfoAttribute;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  attrRead := FindAttribute(AAttrName, False);

  if attrRead <> nil then
    ValueToList(attrRead.Value, AList);
end;


procedure TSimpleTSInfoTree.ReadBuffer(AAttrName: UTF8String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
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


procedure TSimpleTSInfoTree.ReadStream(AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
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


function TSimpleTSInfoTree.CreateAttribute(ANodePath: UTF8String; AReference: Boolean; AAttrName: UTF8String): Boolean;
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


function TSimpleTSInfoTree.CreateChildNode(ANodePath: UTF8String; AReference: Boolean; ANodeName: UTF8String; AOpen: Boolean = False): Boolean;
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


function TSimpleTSInfoTree.CreateLink(ANodePath: UTF8String; AFileName: TFileName; AVirtualNodeName: UTF8String; AFlags: TTreeModes; AOpen: Boolean = False): Boolean;
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
          FCurrentNode := linkCreate.FLinkedTree.FCurrentNode;

        FModified := True;
        Result := True;

        if (ffLoadFile in AFlags) and FileExistsUTF8(AFileName) then
          if ffBinaryFile in AFlags then
          begin
            fsInput := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
            try
              linkCreate.FLinkedTree.LoadTreeFromStream(fsInput);
            finally
              fsInput.Free();
            end;
          end
          else
          begin
            slInput := TStringList.Create();
            try
              slInput.LoadFromFile(AFileName);
              linkCreate.FLinkedTree.LoadTreeFromList(slInput);
            finally
              slInput.Free();
            end;
          end;
      end;
end;


function TSimpleTSInfoTree.FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; AParentNodePath: UTF8String = ''): Boolean;
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
    AAttrToken.FAttribute := nodeParent.GetAttribute(0);
    AAttrToken.FParentNode := nodeParent;
    AAttrToken.FIndex := 0;
  end;
end;


function TSimpleTSInfoTree.FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
begin
  Result := AAttrToken.FIndex < AAttrToken.FParentNode.AttributesCount - 1;

  if Result then
  begin
    Inc(AAttrToken.FIndex);
    AAttrToken.FAttribute := AAttrToken.FParentNode.GetAttribute(AAttrToken.FIndex);
  end;
end;


function TSimpleTSInfoTree.FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; AParentNodePath: UTF8String = ''): Boolean;
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
    ANodeToken.FChildNode := nodeParent.GetChildNode(0);
    ANodeToken.FParentNode := nodeParent;
    ANodeToken.FIndex := 0;
  end;
end;


function TSimpleTSInfoTree.FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
begin
  Result := ANodeToken.FIndex < ANodeToken.FParentNode.ChildNodesCount - 1;

  if Result then
  begin
    Inc(ANodeToken.FIndex);
    ANodeToken.FChildNode := ANodeToken.FParentNode.GetChildNode(ANodeToken.FIndex);
  end;
end;


procedure TSimpleTSInfoTree.RenameAttributeTokens(ANodePath, AAttrName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection); {}
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
          attrRename := nodeParent.GetAttribute(intToken);
          attrRename.Name := Format(AAttrName, [AStartIndex]);

          Inc(AStartIndex, intStep);
        end;
      end;
  end;
end;


procedure TSimpleTSInfoTree.RenameChildNodeTokens(ANodePath, ANodeName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection); {}
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
          nodeRename := nodeParent.GetChildNode(intToken);
          nodeRename.Name := Format(ANodeName, [AStartIndex]);

          Inc(AStartIndex, intStep);
        end;
      end;
  end;
end;


procedure TSimpleTSInfoTree.UpdateFile();
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


{ ----- TTSInfoTree class ----------------------------------------------------------------------------------------- }


procedure TTSInfoTree.RenameTree(ANewTreeName: UTF8String);
begin
  if ANewTreeName <> '' then
    if not ValidIdentifier(ANewTreeName) then
      Exit;

  FTreeName := ANewTreeName;
  FModified := True;
end;


procedure TTSInfoTree.RenameAttribute(AAttrName, ANewAttrName: UTF8String);
var
  nodeParent: TTSInfoNode;
  attrRename: TTSInfoAttribute;
  strNodePath, strAttrName: UTF8String;
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
      attrRename := nodeParent.GetAttribute(strAttrName);

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


procedure TTSInfoTree.RenameChildNode(ANodePath, ANewNodeName: UTF8String);
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


procedure TTSInfoTree.RenameVirtualNode(ANodePath, AVirtualNodeName, ANewVirtualNodeName: UTF8String);
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
      linkRename := nodeParent.GetLink(AVirtualNodeName);

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


procedure TTSInfoTree.WriteTreeComment(AComment, ADelimiter: UTF8String);
begin
  if ADelimiter = '' then
    FTreeComment := AComment
  else
    FTreeComment := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

  FModified := True;
end;


procedure TTSInfoTree.WriteAttributeComment(AAttrName, AComment, ADelimiter: UTF8String; AType: TCommentType);
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


procedure TTSInfoTree.WriteChildNodeComment(ANodePath, AComment, ADelimiter: UTF8String; AType: TCommentType);
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


procedure TTSInfoTree.WriteLinkComment(ANodePath, AVirtualNodeName, AComment, ADelimiter: UTF8String);
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
      linkWrite := nodeParent.GetLink(AVirtualNodeName);

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


function TTSInfoTree.ReadTreeComment(ADelimiter: UTF8String): UTF8String;
begin
  Result := ReplaceSubStrings(FTreeComment, VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadAttributeComment(AAttrName, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
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


function TTSInfoTree.ReadChildNodeComment(ANodePath, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
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


function TTSInfoTree.ReadLinkComment(ANodePath, AVirtualNodeName, ADelimiter: UTF8String): UTF8String;
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
    linkRead := nodeParent.GetLink(AVirtualNodeName);

    if linkRead = nil then
      ThrowException(EM_LINKED_FILE_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
      Result := ReplaceSubStrings(linkRead.Comment, VALUES_DELIMITER, ADelimiter);
  end;
end;


procedure TTSInfoTree.WriteAttributeReference(AAttrName: UTF8String; AReference: Boolean);
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


procedure TTSInfoTree.WriteChildNodeReference(ANodePath: UTF8String; AReference: Boolean);
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


function TTSInfoTree.ReadAttributeReference(AAttrName: UTF8String): Boolean;
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


function TTSInfoTree.ReadChildNodeReference(ANodePath: UTF8String = ''): Boolean;
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


procedure TTSInfoTree.RemoveAttribute(AAttrName: UTF8String);
var
  nodeParent: TTSInfoNode;
  strPath, strName: UTF8String;
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


procedure TTSInfoTree.RemoveChildNode(ANodePath: UTF8String);
var
  nodeRemove: TTSInfoNode;
  strName: UTF8String;
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


procedure TTSInfoTree.RemoveLink(ANodePath, AVirtualNodeName: UTF8String);
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


procedure TTSInfoTree.RemoveAllAttributes(ANodePath: UTF8String = '');
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


procedure TTSInfoTree.RemoveAllChildNodes(ANodePath: UTF8String = '');
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


procedure TTSInfoTree.RemoveAllLinks(ANodePath: UTF8String = '');
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


procedure TTSInfoTree.ClearChildNode(ANodePath: UTF8String = '');
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


procedure TTSInfoTree.ClearTree();
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


function TTSInfoTree.AttributeExists(AAttrName: UTF8String): Boolean;
begin
  ExcludeTrailingIdentsDelimiter(AAttrName);
  Result := FindAttribute(AAttrName, False) <> nil;
end;


function TTSInfoTree.ChildNodeExists(ANodePath: UTF8String): Boolean;
begin
  IncludeTrailingIdentsDelimiter(ANodePath);
  Result := FindNode(ANodePath, False) <> nil;
end;


function TTSInfoTree.LinkExists(ANodePath, AVirtualNodeName: UTF8String): Boolean;
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

  Result := (nodeParent <> nil) and (nodeParent.GetLink(AVirtualNodeName) <> nil);
end;


function TTSInfoTree.GetAttributesCount(ANodePath: UTF8String = ''): UInt32;
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


function TTSInfoTree.GetChildNodesCount(ANodePath: UTF8String = ''): UInt32;
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


function TTSInfoTree.GetLinksCount(ANodePath: UTF8String = ''): UInt32;
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


procedure TTSInfoTree.ReadAttributesNames(ANodePath: UTF8String; ANames: TStrings);
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
      ANames.Add(nodeParent.GetAttribute(I).Name);
end;


procedure TTSInfoTree.ReadAttributesValues(ANodePath: UTF8String; AValues: TStrings);
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
      AValues.Add(nodeParent.GetAttribute(I).Value);
end;


procedure TTSInfoTree.ReadChildNodesNames(ANodePath: UTF8String; ANames: TStrings);
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
      ANames.Add(nodeParent.GetChildNode(I).Name);
end;


procedure TTSInfoTree.ReadVirtualNodesNames(ANodePath: UTF8String; ANames: TStrings);
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
      ANames.Add(nodeParent.GetLink(I).VirtualNodeName);
end;


procedure TTSInfoTree.ExportTreeToFile(AFileName: TFileName; AFormat: TExportFormat = efTextFile);
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


procedure TTSInfoTree.ExportTreeToList(AList: TStrings);
begin
  SaveTreeToList(AList);
end;


procedure TTSInfoTree.ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryFile);
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


{ ----- TTSInfoTextOutputWriter class ----------------------------------------------------------------------------- }


{ ----- TTSInfoBinaryInputReader class ---------------------------------------------------------------------------- }


{ ----- TTSInfoBinaryOutputWriter class --------------------------------------------------------------------------- }


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

