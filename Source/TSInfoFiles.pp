{

    TSInfoFiles.pp                last modified: 27 December 2014

    Copyright (C) Jaroslaw Baran, furious programming 2011 - 2014.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Contains a set of classes to handle TreeStructInfo files. The following
    classes are used to handle files and to make any changes, accordance
    with the documentation of the format in version '2.0'.
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
    procedure SetComment(AType: TCommentType; const AComment: UTF8String);
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
    procedure SetComment(AType: TCommentType; const AComment: UTF8String);
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
    procedure RemoveAllAttributes();
    procedure RemoveAllChildNodes();
    procedure RemoveAllLinks();
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


{ ----- token objects --------------------------------------------------------------------------------------------- }


type
  TTSInfoAttributeToken = object
  private
    FParentNode: TTSInfoNode;
    FAttribute: TTSInfoAttribute;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; const AComment: UTF8String);
  public
    property Name: UTF8String read FAttribute.FName write FAttribute.FName;
    property Reference: Boolean read FAttribute.FReference write FAttribute.FReference;
    property Value: UTF8String read FAttribute.FValue write FAttribute.FValue;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
  end;


type
  TTSInfoChildNodeToken = object
  private
    FParentNode: TTSInfoNode;
    FChildNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): UTF8String;
    procedure SetComment(AType: TCommentType; const AComment: UTF8String);
  public
    property Name: UTF8String read FChildNode.FName write FChildNode.FName;
    property Reference: Boolean read FChildNode.FReference write FChildNode.FReference;
    property Comment[AType: TCommentType]: UTF8String read GetComment write SetComment;
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
  public
    procedure RemoveChildNode(const AName: UTF8String);
    procedure RemoveAll();
  end;


type
  TTSInfoLinksList = class(TTSInfoElementsList)
  private
    function InternalAddLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    function GetLink(const AVirtualNodeName: UTF8String): TTSInfoLink; overload;
    function GetLink(AIndex: Integer): TTSInfoLink; overload;
    function GetVirtualNode(const AName: UTF8String): TTSInfoNode;
  public
    function AddLink(const AFileName, AVirtualNodeName: UTF8String): TTSInfoLink; overload;
    function AddLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink; overload;
  public
    procedure RemoveLink(const AVirtualNodeName: UTF8String);
    procedure RemoveAll();
  end;


{ ----- additional container classes ------------------------------------------------------------------------------ }


type
  TTSInfoRefElementsList = class(TTSInfoElementsList)
  public
    procedure InsertElement(AIndex: Integer; AElement: TObject);
  public
    function FirstElementIsAttribute(const AMandatoryName: UTF8String): Boolean;
    function FirstElementIsChildNode(const AMandatoryName: UTF8String): Boolean;
  public
    function PopFirstElement(): TObject;
  end;


type
  TTSInfoProcessedTreesList = class(TTSInfoElementsList)
  private
    function GetTreeAtIndex(AIndex: Integer): TSimpleTSInfoTree;
  public
    procedure AddTree(ATree: TSimpleTSInfoTree);
    function FileNotYetBeenProcessed(const AFileName: UTF8String): Boolean;
  public
    property Tree[AIndex: Integer]: TSimpleTSInfoTree read GetTreeAtIndex;
  end;


{ ----- tree classes ---------------------------------------------------------------------------------------------- }


type
  TSimpleTSInfoTree = class(TObject)
  private
    FRootNode: TTSInfoNode;
    FCurrentNode: TTSInfoNode;
    FFileName: UTF8String;
    FTreeName: UTF8String;
    FTreeComment: UTF8String;
    FCurrentlyOpenNodePath: UTF8String;
    FTreeModes: TTreeModes;
    FModified: Boolean;
    FReadOnly: Boolean;
  private
    procedure InitFields();
    procedure DamageClear();
  private
    procedure InternalLoadTreeFromList(AList: TStrings; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
    procedure InternalLoadTreeFromStream(AStream: TStream; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
    procedure InternalSaveTreeToList(AList: TStrings; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
    procedure InternalSaveTreeToStream(AStream: TStream; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
  private
    function FindElement(const AElementName: UTF8String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
    function FindAttribute(const AAttrName: UTF8String; AForcePath: Boolean): TTSInfoAttribute;
    function FindNode(const ANodePath: UTF8String; AForcePath: Boolean): TTSInfoNode;
  public
    constructor Create();
    constructor Create(const AFileName: UTF8String; AModes: TTreeModes);
  public
    destructor Destroy(); override;
  public
    procedure LoadFromFile(const AFileName: UTF8String; AModes: TTreeModes = []);
    procedure LoadFromList(AList: TStrings; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
    procedure LoadFromStream(AStream: TStream; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
    procedure LoadFromResource(AInstance: TFPResourceHMODULE; const AResName: String; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []); overload;
    procedure LoadFromResource(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []); overload;
    procedure LoadFromLazarusResource(const AResName: String; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
  public
    function OpenChildNode(const ANodePath: UTF8String; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
    procedure GoToParentNode(AKeepReadOnlyMode: Boolean = True);
    procedure CloseChildNode();
  public
    procedure WriteBoolean(const AAttrName: UTF8String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
    procedure WriteInteger(const AAttrName: UTF8String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
    procedure WriteFloat(const AAttrName: UTF8String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteFloat(const AAttrName: UTF8String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteCurrency(const AAttrName: UTF8String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteCurrency(const AAttrName: UTF8String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteString(const AAttrName, AString: UTF8String; AFormat: TFormatString = fsOriginal);
    procedure WriteDateTime(const AAttrName, AMask: UTF8String; ADateTime: TDateTime); overload;
    procedure WriteDateTime(const AAttrName, AMask: UTF8String; ADateTime: TDateTime; ASettings: TFormatSettings); overload;
    procedure WritePoint(const AAttrName: UTF8String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
    procedure WriteList(const AAttrName: UTF8String; AList: TStrings);
    procedure WriteBuffer(const AAttrName: UTF8String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
    procedure WriteStream(const AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
  public
    function ReadBoolean(const AAttrName: UTF8String; ADefault: Boolean): Boolean;
    function ReadInteger(const AAttrName: UTF8String; ADefault: Integer): Integer;
    function ReadFloat(const AAttrName: UTF8String; ADefault: Double): Double; overload;
    function ReadFloat(const AAttrName: UTF8String; ADefault: Double; ASettings: TFormatSettings): Double; overload;
    function ReadCurrency(const AAttrName: UTF8String; ADefault: Currency): Currency; overload;
    function ReadCurrency(const AAttrName: UTF8String; ADefault: Currency; ASettings: TFormatSettings): Currency; overload;
    function ReadString(const AAttrName, ADefault: UTF8String; AFormat: TFormatString = fsOriginal): UTF8String;
    function ReadDateTime(const AAttrName, AMask: UTF8String; ADefault: TDateTime): TDateTime; overload;
    function ReadDateTime(const AAttrName, AMask: UTF8String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime; overload;
    function ReadPoint(const AAttrName: UTF8String; ADefault: TPoint): TPoint;
    procedure ReadList(const AAttrName: UTF8String; AList: TStrings);
    procedure ReadBuffer(const AAttrName: UTF8String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
    procedure ReadStream(const AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
  public
    function CreateAttribute(const ANodePath: UTF8String; AReference: Boolean; const AAttrName: UTF8String): Boolean;
    function CreateChildNode(const ANodePath: UTF8String; AReference: Boolean; const ANodeName: UTF8String; AOpen: Boolean = False): Boolean;
    function CreateLink(const ANodePath, AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; AOpen: Boolean = False): Boolean;
  public
    procedure ClearChildNode(const ANodePath: UTF8String = '');
    procedure ClearTree();
  public
    function FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; const AParentNodePath: UTF8String = ''): Boolean;
    function FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
    function FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; const AParentNodePath: UTF8String = ''): Boolean;
    function FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
  public
    procedure RenameAttributeTokens(const ANodePath, ATokenName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
    procedure RenameChildNodeTokens(const ANodePath, ATokenName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
  public
    procedure UpdateFile();
  public
    property FileName: UTF8String read FFileName;
    property TreeName: UTF8String read FTreeName;
    property CurrentlyOpenNodeName: UTF8String read FCurrentNode.FName;
    property CurrentlyOpenNodePath: UTF8String read FCurrentlyOpenNodePath;
    property TreeModes: TTreeModes read FTreeModes write FTreeModes;
    property Modified: Boolean read FModified;
    property ReadOnly: Boolean read FReadOnly;
  end;


type
  TTSInfoTree = class(TSimpleTSInfoTree)
  public
    procedure RenameTree(const ANewTreeName: UTF8String);
    procedure RenameAttribute(const AAttrName, ANewAttrName: UTF8String);
    procedure RenameChildNode(const ANodePath, ANewNodeName: UTF8String);
    procedure RenameVirtualNode(const ANodePath, AVirtualNodeName, ANewVirtualNodeName: UTF8String);
  public
    procedure WriteTreeComment(const AComment, ADelimiter: UTF8String);
    procedure WriteAttributeComment(const AAttrName, AComment, ADelimiter: UTF8String; AType: TCommentType);
    procedure WriteChildNodeComment(const ANodePath, AComment, ADelimiter: UTF8String; AType: TCommentType);
    procedure WriteLinkComment(const ANodePath, AVirtualNodeName, AComment, ADelimiter: UTF8String);
  public
    function ReadTreeComment(const ADelimiter: UTF8String): UTF8String;
    function ReadAttributeComment(const AAttrName, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
    function ReadChildNodeComment(const ANodePath, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
    function ReadLinkComment(const ANodePath, AVirtualNodeName, ADelimiter: UTF8String): UTF8String;
  public
    procedure SetAttributeReference(const AAttrName: UTF8String; AReference: Boolean);
    procedure SetChildNodeReference(const ANodePath: UTF8String; AReference: Boolean);
  public
    function GetAttributeReference(const AAttrName: UTF8String): Boolean;
    function GetChildNodeReference(const ANodePath: UTF8String = ''): Boolean;
  public
    procedure RemoveAttribute(const AAttrName: UTF8String);
    procedure RemoveChildNode(const ANodePath: UTF8String);
    procedure RemoveLink(const ANodePath, AVirtualNodeName: UTF8String);
  public
    procedure RemoveAllAttributes(const ANodePath: UTF8String = '');
    procedure RemoveAllChildNodes(const ANodePath: UTF8String = '');
    procedure RemoveAllLinks(const ANodePath: UTF8String = '');
  public
    function AttributeExists(const AAttrName: UTF8String): Boolean;
    function ChildNodeExists(const ANodePath: UTF8String): Boolean;
    function LinkExists(const ANodePath, AVirtualNodeName: UTF8String): Boolean;
  public
    function GetAttributesCount(const ANodePath: UTF8String = ''): Integer;
    function GetChildNodesCount(const ANodePath: UTF8String = ''): Integer;
    function GetLinksCount(const ANodePath: UTF8String = ''): Integer;
  public
    procedure ReadAttributesNames(const ANodePath: UTF8String; ANames: TStrings);
    procedure ReadAttributesValues(const ANodePath: UTF8String; AValues: TStrings);
    procedure ReadChildNodesNames(const ANodePath: UTF8String; ANames: TStrings);
    procedure ReadVirtualNodesNames(const ANodePath: UTF8String; ANames: TStrings);
  public
    procedure ExportTreeToFile(const AFileName: UTF8String; AFormat: TExportFormat = efTextTree);
    procedure ExportTreeToList(AList: TStrings);
    procedure ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryTree);
  end;


{ ----- text input reader and output writer classes --------------------------------------------------------------- }


type
  TTSInfoTextInputReader = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FInput: TStrings;
    FProcessedTrees: TTSInfoProcessedTreesList;
    FRefElements: TTSInfoRefElementsList;
    FComment: UTF8String;
    FAllowLinking: Boolean;
  private
    FEndTreeLineIndex: Integer;
    FLineIndex: Integer;
    FNestedLevel: Integer;
    FNestedRefElementsCount: Integer;
  private
    FAddRefElement: TAddRefElementProc;
  private
    procedure RemoveBOMSignature();
    procedure RemoveWhitespace();
    procedure DetermineLineIndexes();
  private
    function IsCommentLine(const ALine: UTF8String): Boolean;
    function IsTreeHeaderLine(const ALine: UTF8String): Boolean;
    function IsFormatVersionValue(const AValue: UTF8String): Boolean;
    function IsTreeEndLine(const ALine: UTF8String): Boolean;
    function IsAttributeNameAndValueLine(const ALine: UTF8String): Boolean;
    function IsStdAttributeLine(const ALine: UTF8String): Boolean;
    function IsStdChildNodeLine(const ALine: UTF8String): Boolean;
    function IsStdChildNodeEndLine(const ALine: UTF8String): Boolean;
    function IsRefAttributeDeclarationLine(const ALine: UTF8String): Boolean;
    function IsRefAttributeDefinitionLine(const ALine: UTF8String): Boolean;
    function IsRefChildNodeLine(const ALine: UTF8String): Boolean;
    function IsRefChildNodeEndLine(const ALine: UTF8String): Boolean;
    function IsLinkLine(const ALine: UTF8String): Boolean;
    function IsValueLine(const ALine: UTF8String): Boolean;
  private
    procedure AddRefElement(AElement: TObject);
    procedure InsertRefElement(AElement: TObject);
  private
    procedure ExtractComment();
    procedure ExtractLineComponents(const ALine: UTF8String; out AComponents: TLineComponents; var ACount: Integer);
    procedure ExtractAttribute(const ALine: UTF8String; out AReference: Boolean; out AName, AValue: UTF8String);
    procedure ExtractAttributeNextValue(const ALine: UTF8String; out ANextValue: UTF8String);
    procedure ExtractChildNode(const ALine: UTF8String; out AReference: Boolean; out AName: UTF8String);
  private
    procedure ExtractAttributeNameFromDeclarationLine(const ALine: UTF8String; out AName: UTF8String);
    procedure ExtractAttributeNameFromDefinitionLine(const ALine: UTF8String; out AName: UTF8String);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStrings; AProcessedTrees: TTSInfoProcessedTreesList);
    destructor Destroy(); override;
  end;


type
  TTSInfoTextOutputWriter = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FOutput: TStrings;
    FProcessedTrees: TTSInfoProcessedTreesList;
    FRefElements: TTSInfoRefElementsList;
    FAllowLinking: Boolean;
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStrings; AProcessedTrees: TTSInfoProcessedTreesList);
    destructor Destroy(); override;
  end;


{ ----- binary input reader and output writer classes ------------------------------------------------------------- }


type
  TTSInfoBinaryInputReader = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FInput: TStream;
    FProcessedTrees: TTSInfoProcessedTreesList;
    FAllowLinking: Boolean;
  private
    procedure ReadUTF8StringBuffer(out ABuffer: UTF8String);
    procedure ReadBooleanBuffer(out ABuffer: Boolean);
    procedure ReadUInt8Buffer(out ABuffer: UInt8);
    procedure ReadUInt32Buffer(out ABuffer: UInt32);
    procedure ReadTreeMode(var AModes: TTreeModes; AModeOnValue, AModeOffValue: TTreeMode);
  private
    procedure ReadHeader();
    procedure ReadElements(AParentNode: TTSInfoNode);
    procedure ReadAttribute(AAttribute: TTSInfoAttribute);
    procedure ReadChildNode(AChildNode: TTSInfoNode);
    procedure ReadLink(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStream; AProcessedTrees: TTSInfoProcessedTreesList);
    destructor Destroy(); override;
  public
    procedure ProcessInput();
  end;


type
  TTSInfoBinaryOutputWriter = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FOutput: TStream;
    FProcessedTrees: TTSInfoProcessedTreesList;
    FAllowLinking: Boolean;
  private
    procedure WriteUTF8StringBuffer(const ABuffer: UTF8String);
    procedure WriteBooleanBuffer(ABuffer: Boolean);
    procedure WriteUInt8Buffer(ABuffer: UInt8);
    procedure WriteUInt32Buffer(ABuffer: UInt32);
    procedure WriteTreeMode(AModes: TTreeModes; AModeOnValue: TTreeMode);
  private
    procedure WriteHeader();
    procedure WriteElements(AParentNode: TTSInfoNode);
    procedure WriteAttribute(AAttribute: TTSInfoAttribute);
    procedure WriteChildNode(AChildNode: TTSInfoNode);
    procedure WriteLink(ALink: TTSInfoLink);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStream; AProcessedTrees: TTSInfoProcessedTreesList);
    destructor Destroy(); override;
  public
    procedure ProcessOutput();
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
  FComment := TSInfoUtils.Comment('', '');
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


procedure TTSInfoAttribute.SetComment(AType: TCommentType; const AComment: UTF8String);
begin
  FComment[AType] := AComment;
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


procedure TTSInfoNode.SetComment(AType: TCommentType; const AComment: UTF8String);
begin
  FComment[AType] := AComment;
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


procedure TTSInfoNode.RemoveAllAttributes();
begin
  FAttributesList.RemoveAll();
end;

procedure TTSInfoNode.RemoveAllChildNodes();
begin
  FChildNodesList.RemoveAll();
end;


procedure TTSInfoNode.RemoveAllLinks();
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


{ ----- TTSInfoAttributeToken object ------------------------------------------------------------------------------ }


function TTSInfoAttributeToken.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FAttribute.Comment[AType];
end;


procedure TTSInfoAttributeToken.SetComment(AType: TCommentType; const AComment: UTF8String);
begin
  FAttribute.Comment[AType] := AComment;
end;


{ ----- TTSInfoChildNodeToken object ------------------------------------------------------------------------------ }


function TTSInfoChildNodeToken.GetComment(AType: TCommentType): UTF8String;
begin
  Result := FChildNode.Comment[AType];
end;


procedure TTSInfoChildNodeToken.SetComment(AType: TCommentType; const AComment: UTF8String);
begin
  FChildNode.Comment[AType] := AComment;
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


procedure TTSInfoNodesList.RemoveChildNode(const AName: UTF8String);
var
  nodeRemove: TTSInfoNode;
  intChildNodeIdx: Integer;
begin
  for intChildNodeIdx := 0 to FCount - 1 do
  begin
    nodeRemove := inherited Element[intChildNodeIdx] as TTSInfoNode;

    if SameIdentifiers(nodeRemove.Name, AName) then
    begin
      inherited RemoveElement(intChildNodeIdx);
      Exit();
    end;
  end;
end;


procedure TTSInfoNodesList.RemoveAll();
begin
  inherited RemoveAllElements();
end;


{ ----- TTSInfoLinksList class ------------------------------------------------------------------------------------ }


constructor TTSInfoLinksList.Create();
begin
  inherited Create(True);
end;


destructor TTSInfoLinksList.Destroy();
begin
  inherited Destroy();
end;


function TTSInfoLinksList.InternalAddLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink;
begin
  Result := TTSInfoLink.Create(AFileName, AVirtualNodeName, AModes, AComment);
  inherited AddElement(Result);
end;


function TTSInfoLinksList.GetLink(const AVirtualNodeName: UTF8String): TTSInfoLink;
var
  linkGet: TTSInfoLink;
  intLinkIdx: Integer;
begin
  for intLinkIdx := 0 to FCount - 1 do
  begin
    linkGet := inherited Element[intLinkIdx] as TTSInfoLink;

    if SameIdentifiers(linkGet.VirtualNodeName, AVirtualNodeName) then
      Exit(linkGet);
  end;

  Result := nil;
end;


function TTSInfoLinksList.GetLink(AIndex: Integer): TTSInfoLink;
begin
  Result := inherited Element[AIndex] as TTSInfoLink;
end;


function TTSInfoLinksList.GetVirtualNode(const AName: UTF8String): TTSInfoNode;
var
  linkGet: TTSInfoLink;
begin
  linkGet := GetLink(AName);

  if linkGet = nil then
    Result := nil
  else
    Result := linkGet.VirtualNode;
end;


function TTSInfoLinksList.AddLink(const AFileName, AVirtualNodeName: UTF8String): TTSInfoLink;
begin
  Result := InternalAddLink(AFileName, AVirtualNodeName, [], '');
end;


function TTSInfoLinksList.AddLink(const AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; const AComment: UTF8String): TTSInfoLink;
begin
  Result := InternalAddLink(AFileName, AVirtualNodeName, AModes, AComment);
end;


procedure TTSInfoLinksList.RemoveLink(const AVirtualNodeName: UTF8String);
var
  linkRemove: TTSInfoLink;
  intLinkIdx: Integer;
begin
  for intLinkIdx := 0 to FCount - 1 do
  begin
    linkRemove := inherited Element[intLinkIdx] as TTSInfoLink;

    if SameIdentifiers(linkRemove.VirtualNodeName, AVirtualNodeName) then
    begin
      inherited RemoveElement(intLinkIdx);
      Exit();
    end;
  end;
end;


procedure TTSInfoLinksList.RemoveAll();
begin
  inherited RemoveAllElements();
end;


{ ----- TTSInfoRefElementsList class ------------------------------------------------------------------------------ }


procedure TTSInfoRefElementsList.InsertElement(AIndex: Integer; AElement: TObject);
var
  plnNew, plnAtIndex: PListNode;
begin
  if AIndex >= FCount then
    AddElement(AElement)
  else
  begin
    plnNew := CreateNode(AElement);

    if AIndex = 0 then
    begin
      plnNew^.NextNode := FFirstNode;
      FFirstNode^.PreviousNode := plnNew;
      FFirstNode := plnNew;
    end
    else
    begin
      plnAtIndex := GetNodeAtIndex(AIndex);

      plnNew^.PreviousNode := plnAtIndex^.PreviousNode;
      plnNew^.NextNode := plnAtIndex;

      plnAtIndex^.PreviousNode^.NextNode := plnNew;
      plnAtIndex^.PreviousNode := plnNew;
    end;

    FLastUsedNode := FLastUsedNode^.PreviousNode;
    Inc(FCount);
  end;
end;


function TTSInfoRefElementsList.FirstElementIsAttribute(const AMandatoryName: UTF8String): Boolean;
begin
  Result := (FFirstNode <> nil) and (FFirstNode^.Element is TTSInfoAttribute) and
            SameIdentifiers((Element[0] as TTSInfoAttribute).Name, AMandatoryName);
end;


function TTSInfoRefElementsList.FirstElementIsChildNode(const AMandatoryName: UTF8String): Boolean;
begin
  Result := (FFirstNode <> nil) and (FFirstNode^.Element is TTSInfoNode) and
            SameIdentifiers((Element[0] as TTSInfoNode).FName, AMandatoryName);
end;


function TTSInfoRefElementsList.PopFirstElement(): TObject;
begin
  Result := FFirstNode^.Element;
  RemoveElement(0);
end;


{ ----- TTSInfoProcessedTreesList class --------------------------------------------------------------------------- }


function TTSInfoProcessedTreesList.GetTreeAtIndex(AIndex: Integer): TSimpleTSInfoTree;
begin
  Result := inherited Element[AIndex] as TSimpleTSInfoTree;
end;


procedure TTSInfoProcessedTreesList.AddTree(ATree: TSimpleTSInfoTree);
begin
  inherited AddElement(ATree);
end;


function TTSInfoProcessedTreesList.FileNotYetBeenProcessed(const AFileName: UTF8String): Boolean;
var
  treeRead: TSimpleTSInfoTree;
  strFullInputFileName, strFullTreeFileName: UTF8String;
  intTreeIdx: Integer;
begin
  if FCount > 0 then
  begin
    strFullInputFileName := ExpandFileNameUTF8(AFileName);

    for intTreeIdx := 0 to FCount - 1 do
    begin
      treeRead := inherited Element[intTreeIdx] as TSimpleTSInfoTree;
      strFullTreeFileName := ExpandFileNameUTF8(treeRead.FileName);

      {$IFDEF WINDOWS}
      if UTF8CompareText(strFullInputFileName, strFullTreeFileName) = 0 then
      {$ELSE}
      if UTF8CompareStr(strFullInputFileName, strFullTreeFileName) = 0 then
      {$ENDIF}
        Exit(False);
    end;
  end;

  Result := True;
end;


{ ----- TSimpleTSInfoTree class ----------------------------------------------------------------------------------- }


constructor TSimpleTSInfoTree.Create();
begin
  inherited Create();
  InitFields();
end;


constructor TSimpleTSInfoTree.Create(const AFileName: UTF8String; AModes: TTreeModes);
begin
  inherited Create();
  InitFields();

  FFileName := AFileName;
  FTreeModes := AModes;
end;


destructor TSimpleTSInfoTree.Destroy();
begin
  if tmAccessWrite in FTreeModes then
    UpdateFile();

  FRootNode.Free();
  inherited Destroy();
end;


procedure TSimpleTSInfoTree.InitFields();
begin
  FFileName := '';
  FTreeName := '';
  FTreeComment := '';
  FCurrentlyOpenNodePath := '';

  FRootNode := TTSInfoNode.Create(nil, False, '', Comment('', ''));
  FCurrentNode := FRootNode;

  FTreeModes := [];
  FReadOnly := False;
end;


procedure TSimpleTSInfoTree.DamageClear();
begin
  FRootNode.RemoveAllAttributes();
  FRootNode.RemoveAllChildNodes();
  FRootNode.RemoveAllLinks();

  FCurrentNode := FRootNode;
  FCurrentlyOpenNodePath := '';
end;


procedure TSimpleTSInfoTree.InternalLoadTreeFromList(AList: TStrings; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  with TTSInfoTextInputReader.Create(ATree, AList, AProcessedTrees) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalLoadTreeFromStream(AStream: TStream; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  with TTSInfoBinaryInputReader.Create(ATree, AStream, AProcessedTrees) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalSaveTreeToList(AList: TStrings; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  with TTSInfoTextOutputWriter.Create(ATree, AList, AProcessedTrees) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalSaveTreeToStream(AStream: TStream; ATree: TSimpleTSInfoTree; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  with TTSInfoBinaryOutputWriter.Create(ATree, AStream, AProcessedTrees) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


function TSimpleTSInfoTree.FindElement(const AElementName: UTF8String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
var
  nodeRead, nodeTemp: TTSInfoNode;
  pchrNameBegin, pchrNameEnd, pchrLast: PUTF8Char;
  intPathLen: Integer;
  strName: UTF8String;
begin
  Result := nil;
  intPathLen := Length(AElementName);

  if intPathLen > 0 then
  begin
    nodeRead := FCurrentNode;

    SetLength(strName, 0);
    pchrNameBegin := @AElementName[1];
    pchrNameEnd := pchrNameBegin;
    pchrLast := @AElementName[intPathLen];

    while (nodeRead = nil) or (pchrNameEnd <= pchrLast) do
    begin
      while (pchrNameEnd < pchrLast) and (pchrNameEnd^ <> IDENTS_DELIMITER) do
        Inc(pchrNameEnd);

      if (nodeRead <> nil) and (pchrNameEnd^ = IDENTS_DELIMITER) then
      begin
        MoveString(pchrNameBegin^, strName, pchrNameEnd - pchrNameBegin);

        if not IsCurrentNodePath(strName) and ValidIdentifier(strName) then
        begin
          nodeTemp := nodeRead.GetChildNode(strName);

          if nodeTemp = nil then
            nodeTemp := nodeRead.GetVirtualNode(strName);

          if (nodeTemp = nil) and AForcePath then
            nodeTemp := nodeRead.CreateChildNode(False, strName);

          nodeRead := nodeTemp;
        end;

        Inc(pchrNameEnd);
        pchrNameBegin := pchrNameEnd;
      end
      else
        Break;
    end;

    if AReturnAttribute then
    begin
      if nodeRead <> nil then
      begin
        MoveString(pchrNameBegin^, strName, pchrNameEnd - pchrNameBegin + 1);

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


function TSimpleTSInfoTree.FindAttribute(const AAttrName: UTF8String; AForcePath: Boolean): TTSInfoAttribute;
begin
  Result := FindElement(AAttrName, AForcePath, True) as TTSInfoAttribute;
end;


function TSimpleTSInfoTree.FindNode(const ANodePath: UTF8String; AForcePath: Boolean): TTSInfoNode;
begin
  Result := FindElement(ANodePath, AForcePath, False) as TTSInfoNode;
end;


procedure TSimpleTSInfoTree.LoadFromFile(const AFileName: UTF8String; AModes: TTreeModes = []);
var
  fsInput: TFileStream;
  slInput: TStringList;
  ltlTrees: TTSInfoProcessedTreesList;
  treeLoad: TSimpleTSInfoTree;
  intTreeIdx: Integer = 0;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  ltlTrees := TTSInfoProcessedTreesList.Create(False);
  try
    ltlTrees.AddTree(Self);

    while intTreeIdx < ltlTrees.Count do
    begin
      treeLoad := ltlTrees.Tree[intTreeIdx];

      if tmBinaryTree in treeLoad.TreeModes then
      begin
        fsInput := TFileStream.Create(treeLoad.FileName, fmOpenRead or fmShareDenyWrite);
        try
          InternalLoadTreeFromStream(fsInput, treeLoad, ltlTrees);
        finally
          fsInput.Free();
        end;
      end
      else
      begin
        slInput := TStringList.Create();
        try
          slInput.LoadFromFile(treeLoad.FileName);
          InternalLoadTreeFromList(slInput, treeLoad, ltlTrees);
        finally
          slInput.Free();
        end;
      end;

      Inc(intTreeIdx);
    end;
  finally
    ltlTrees.Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadFromList(AList: TStrings; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
begin
  FFileName := AFileName;
  FTreeModes := AModes - [tmAllowLinking];

  ClearTree();
  InternalLoadTreeFromList(AList, Self, nil);
end;


procedure TSimpleTSInfoTree.LoadFromStream(AStream: TStream; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
var
  slInput: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes - [tmAllowLinking];

  ClearTree();

  if tmBinaryTree in FTreeModes then
    InternalLoadTreeFromStream(AStream, Self, nil)
  else
  begin
    slInput := TStringList.Create();
    try
      slInput.LoadFromStream(AStream);
      InternalLoadTreeFromList(slInput, Self, nil);
    finally
      slInput.Free();
    end;
  end;
end;


procedure TSimpleTSInfoTree.LoadFromResource(AInstance: TFPResourceHMODULE; const AResName: String; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
var
  rsInput: TResourceStream;
  slInput: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes - [tmAllowLinking];

  ClearTree();

  rsInput := TResourceStream.Create(AInstance, AResName, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(rsInput, Self, nil)
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromStream(rsInput);
        InternalLoadTreeFromList(slInput, Self, nil);
      finally
        slInput.Free();
      end;
    end;
  finally
    rsInput.Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadFromResource(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
var
  rsInput: TResourceStream;
  slInput: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes - [tmAllowLinking];

  ClearTree();

  rsInput := TResourceStream.CreateFromID(AInstance, AResID, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(rsInput, Self, nil)
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromStream(rsInput);
        InternalLoadTreeFromList(slInput, Self, nil);
      finally
        slInput.Free();
      end;
    end;
  finally
    rsInput.Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadFromLazarusResource(const AResName: String; AResType: PChar; const AFileName: UTF8String = ''; AModes: TTreeModes = []);
var
  lrsInput: TLazarusResourceStream;
  slInput: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes - [tmAllowLinking];

  ClearTree();

  lrsInput := TLazarusResourceStream.Create(AResName, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(lrsInput, Self, nil)
    else
    begin
      slInput := TStringList.Create();
      try
        slInput.LoadFromStream(lrsInput);
        InternalLoadTreeFromList(slInput, Self, nil);
      finally
        slInput.Free();
      end;
    end;
  finally
    lrsInput.Free();
  end;
end;


function TSimpleTSInfoTree.OpenChildNode(const ANodePath: UTF8String; AReadOnly: Boolean; ACanCreate: Boolean): Boolean;
var
  nodeOpen: TTSInfoNode;
  strNodePath: UTF8String;
begin
  strNodePath := IncludeTrailingIdentsDelimiter(ANodePath);

  nodeOpen := FindNode(strNodePath, ACanCreate and not AReadOnly);
  Result := nodeOpen <> nil;

  if nodeOpen = nil then
    ThrowException(EM_CANNOT_OPEN_NODE, [strNodePath])
  else
  begin
    if FCurrentNode <> FRootNode then
      FCurrentlyOpenNodePath += strNodePath
    else
      FCurrentlyOpenNodePath := strNodePath;

    FCurrentNode := nodeOpen;
    FReadOnly := AReadOnly;
  end;
end;


procedure TSimpleTSInfoTree.GoToParentNode(AKeepReadOnlyMode: Boolean = True);
begin
  if FCurrentNode = FRootNode then
    ThrowException(EM_ROOT_NODE_GO_TO_PARENT)
  else
    if FCurrentNode.FParentNode = FRootNode then
    begin
      FCurrentNode := FRootNode;
      FCurrentlyOpenNodePath := '';
      FReadOnly := False;
    end
    else
    begin
      FCurrentlyOpenNodePath := PathWithoutLastNodeName(FCurrentlyOpenNodePath);

      if FCurrentNode.FParentNode = nil then
      begin
        FCurrentNode := FRootNode;
        FCurrentNode := FindNode(FCurrentlyOpenNodePath, False);
      end
      else
        FCurrentNode := FCurrentNode.FParentNode;

      if not AKeepReadOnlyMode then
        FReadOnly := False;
    end;
end;


procedure TSimpleTSInfoTree.CloseChildNode();
begin
  FCurrentNode := FRootNode;
  FCurrentlyOpenNodePath := '';

  FReadOnly := False;
end;


procedure TSimpleTSInfoTree.WriteBoolean(const AAttrName: UTF8String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := BooleanToValue(ABoolean, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteInteger(const AAttrName: UTF8String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := IntegerToValue(AInteger, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteFloat(const AAttrName: UTF8String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := FloatToValue(ADouble, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteFloat(const AAttrName: UTF8String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := FloatToValue(ADouble, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteCurrency(const AAttrName: UTF8String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := CurrencyToValue(ACurrency, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteCurrency(const AAttrName: UTF8String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := CurrencyToValue(ACurrency, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteString(const AAttrName, AString: UTF8String; AFormat: TFormatString = fsOriginal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := StringToValue(AString, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteDateTime(const AAttrName, AMask: UTF8String; ADateTime: TDateTime);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := DateTimeToValue(AMask, ADateTime, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteDateTime(const AAttrName, AMask: UTF8String; ADateTime: TDateTime; ASettings: TFormatSettings);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := DateTimeToValue(AMask, ADateTime, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WritePoint(const AAttrName: UTF8String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      attrWrite.Value := PointToValue(APoint, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteList(const AAttrName: UTF8String; AList: TStrings);
var
  attrWrite: TTSInfoAttribute;
  strValue: UTF8String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

    if attrWrite <> nil then
    begin
      ListToValue(AList, strValue);
      attrWrite.Value := strValue;
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteBuffer(const AAttrName: UTF8String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  strValue: UTF8String = '';
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
    if ASize > MAX_BUFFER_SIZE then
      ThrowException(EM_INVALID_BUFFER_SIZE, [MAX_BUFFER_SIZE])
    else
    begin
      attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

      if attrWrite <> nil then
      begin
        BufferToValue(ABuffer, ASize, strValue, AFormat);
        attrWrite.Value := strValue;
        FModified := True;
      end;
    end;
end;


procedure TSimpleTSInfoTree.WriteStream(const AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  attrWrite: TTSInfoAttribute;
  arrBuffer: TByteDynArray;
  strValue: UTF8String = '';
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
    if AStream.Size > MAX_STREAM_SIZE then
      ThrowException(EM_INVALID_STREAM_SIZE, [MAX_STREAM_SIZE])
    else
    begin
      attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), True);

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


function TSimpleTSInfoTree.ReadBoolean(const AAttrName: UTF8String; ADefault: Boolean): Boolean;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToBoolean(attrRead.Value, ADefault);
end;


function TSimpleTSInfoTree.ReadInteger(const AAttrName: UTF8String; ADefault: Integer): Integer;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToInteger(attrRead.Value, ADefault);
end;


function TSimpleTSInfoTree.ReadFloat(const AAttrName: UTF8String; ADefault: Double): Double;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToFloat(attrRead.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadFloat(const AAttrName: UTF8String; ADefault: Double; ASettings: TFormatSettings): Double;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToFloat(attrRead.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadCurrency(const AAttrName: UTF8String; ADefault: Currency): Currency;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToCurrency(attrRead.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadCurrency(const AAttrName: UTF8String; ADefault: Currency; ASettings: TFormatSettings): Currency;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToCurrency(attrRead.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadString(const AAttrName, ADefault: UTF8String; AFormat: TFormatString = fsOriginal): UTF8String;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToString(attrRead.Value, AFormat);
end;


function TSimpleTSInfoTree.ReadDateTime(const AAttrName, AMask: UTF8String; ADefault: TDateTime): TDateTime;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToDateTime(AMask, attrRead.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadDateTime(const AAttrName, AMask: UTF8String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToDateTime(AMask, attrRead.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadPoint(const AAttrName: UTF8String; ADefault: TPoint): TPoint;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    Result := ADefault
  else
    Result := ValueToPoint(attrRead.Value, ADefault);
end;


procedure TSimpleTSInfoTree.ReadList(const AAttrName: UTF8String; AList: TStrings);
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead <> nil then
    ValueToList(attrRead.Value, AList);
end;


procedure TSimpleTSInfoTree.ReadBuffer(const AAttrName: UTF8String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
var
  attrRead: TTSInfoAttribute;
begin
  if ASize > 0 then
  begin
    attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

    if attrRead <> nil then
      ValueToBuffer(attrRead.Value, ABuffer, ASize, AOffset);
  end;
end;


procedure TSimpleTSInfoTree.ReadStream(const AAttrName: UTF8String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
var
  attrRead: TTSInfoAttribute;
  arrBuffer: TByteDynArray;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead <> nil then
  begin
    SetLength(arrBuffer, ASize);
    ValueToBuffer(attrRead.Value, arrBuffer[0], ASize, AOffset);

    AStream.Write(arrBuffer[0], ASize);
  end;
end;


function TSimpleTSInfoTree.CreateAttribute(const ANodePath: UTF8String; AReference: Boolean; const AAttrName: UTF8String): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  Result := ValidIdentifier(AAttrName);

  if Result then
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), True);

    Result := nodeParent <> nil;

    if Result then
    begin
      nodeParent.CreateAttribute(AReference, AAttrName, '', Comment('', ''));
      FModified := True;
    end;
  end;
end;


function TSimpleTSInfoTree.CreateChildNode(const ANodePath: UTF8String; AReference: Boolean; const ANodeName: UTF8String; AOpen: Boolean): Boolean;
var
  nodeParent, nodeCreate: TTSInfoNode;
  strNodePath, strNodeNameAsPath: UTF8String;
  boolPathIsSymbol: Boolean;
begin
  Result := ValidIdentifier(ANodeName);

  if Result then
  begin
    strNodePath := ANodePath;
    boolPathIsSymbol := IsCurrentNodePath(strNodePath);

    if boolPathIsSymbol then
      nodeParent := FCurrentNode
    else
    begin
      strNodePath := IncludeTrailingIdentsDelimiter(ANodePath);
      nodeParent := FindNode(strNodePath, True);
    end;

    Result := nodeParent <> nil;

    if Result then
    begin
      nodeCreate := nodeParent.CreateChildNode(AReference, ANodeName, Comment('', ''));

      if AOpen then
      begin
        strNodeNameAsPath := IncludeTrailingIdentsDelimiter(ANodeName);

        if FCurrentNode = FRootNode then
        begin
          if boolPathIsSymbol then
            FCurrentlyOpenNodePath := strNodeNameAsPath
          else
            FCurrentlyOpenNodePath := strNodePath + strNodeNameAsPath;
        end
        else
          if boolPathIsSymbol then
            FCurrentlyOpenNodePath += strNodeNameAsPath
          else
            FCurrentlyOpenNodePath += strNodePath + strNodeNameAsPath;

        FCurrentNode := nodeCreate;
      end;

      FModified := True;
    end;
  end;
end;


function TSimpleTSInfoTree.CreateLink(const ANodePath, AFileName, AVirtualNodeName: UTF8String; AModes: TTreeModes; AOpen: Boolean = False): Boolean;
var
  nodeParent: TTSInfoNode;
  linkCreate: TTSInfoLink;
  strNodePath, strVirtualNodeNameAsPath: UTF8String;
  boolPathIsSymbol: Boolean;
begin
  Result := False;

  if AFileName = '' then
    ThrowException(EM_EMPTY_LINK_FILE_NAME)
  else
    if ValidIdentifier(AVirtualNodeName) then
    begin
      strNodePath := ANodePath;
      boolPathIsSymbol := IsCurrentNodePath(ANodePath);

      if boolPathIsSymbol then
        nodeParent := FCurrentNode
      else
      begin
        strNodePath := IncludeTrailingIdentsDelimiter(strNodePath);
        nodeParent := FindNode(strNodePath, True);
      end;

      if nodeParent <> nil then
      begin
        linkCreate := nodeParent.CreateLink(AFileName, AVirtualNodeName, AModes + [tmAllowLinking], '');

        if AOpen then
        begin
          strVirtualNodeNameAsPath := IncludeTrailingIdentsDelimiter(AVirtualNodeName);

          if FCurrentNode = FRootNode then
          begin
            if boolPathIsSymbol then
              FCurrentlyOpenNodePath := strVirtualNodeNameAsPath
            else
              FCurrentlyOpenNodePath := strNodePath + strVirtualNodeNameAsPath;
          end
          else
            if boolPathIsSymbol then
              FCurrentlyOpenNodePath += strVirtualNodeNameAsPath
            else
              FCurrentlyOpenNodePath += strNodePath + strVirtualNodeNameAsPath;

          FCurrentNode := linkCreate.LinkedTree.FRootNode;
        end;

        FModified := True;
        Result := True;

        if (tmLoadFile in AModes) and FileExistsUTF8(AFileName) then
          linkCreate.LinkedTree.LoadFromFile(linkCreate.FileName, linkCreate.TreeModes);
      end;
    end;
end;


procedure TSimpleTSInfoTree.ClearChildNode(const ANodePath: UTF8String);
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent <> nil then
    begin
      nodeParent.RemoveAllAttributes();
      nodeParent.RemoveAllChildNodes();
      nodeParent.RemoveAllLinks();

      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.ClearTree();
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    FRootNode.RemoveAllAttributes();
    FRootNode.RemoveAllChildNodes();
    FRootNode.RemoveAllLinks();

    FCurrentNode := FRootNode;
    FCurrentlyOpenNodePath := '';

    FModified := True;
  end;
end;


function TSimpleTSInfoTree.FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; const AParentNodePath: UTF8String = ''): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodePath(AParentNodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(AParentNodePath), False);

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


function TSimpleTSInfoTree.FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; const AParentNodePath: UTF8String = ''): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodePath(AParentNodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(AParentNodePath), False);

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


procedure TSimpleTSInfoTree.RenameAttributeTokens(const ANodePath, ATokenName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
var
  nodeParent: TTSInfoNode;
  attrRename: TTSInfoAttribute;
  intToken, intDirection: Integer;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if (nodeParent <> nil) and ValidIdentifier(ATokenName) then
    begin
      intDirection := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

      for intToken := 0 to nodeParent.AttributesCount - 1 do
      begin
        attrRename := nodeParent.GetAttribute(intToken);
        attrRename.Name := Format(ATokenName, [AStartIndex]);

        Inc(AStartIndex, intDirection);
      end;
    end;
  end;
end;


procedure TSimpleTSInfoTree.RenameChildNodeTokens(const ANodePath, ATokenName: UTF8String; AStartIndex: Integer; ADirection: TRenamingDirection);
var
  nodeParent, nodeRename: TTSInfoNode;
  intToken, intStep: Integer;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if (nodeParent <> nil) and ValidIdentifier(ATokenName) then
    begin
      intStep := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

      for intToken := 0 to nodeParent.ChildNodesCount - 1 do
      begin
        nodeRename := nodeParent.GetChildNode(intToken);
        nodeRename.Name := Format(ATokenName, [AStartIndex]);

        Inc(AStartIndex, intStep);
      end;
    end;
  end;
end;


procedure TSimpleTSInfoTree.UpdateFile();
var
  fsOutput: TStream;
  slOutput: TStrings;
  ltlTrees: TTSInfoProcessedTreesList;
  treeSave: TSimpleTSInfoTree;
  intTreeIdx: Integer = 0;
  boolMainTreeIsNotWritable: Boolean;
begin
  boolMainTreeIsNotWritable := not (tmAccessWrite in FTreeModes);
  Include(FTreeModes, tmAccessWrite);

  ltlTrees := TTSInfoProcessedTreesList.Create(False);
  try
    ltlTrees.AddTree(Self);

    while intTreeIdx < ltlTrees.Count do
    begin
      treeSave := ltlTrees.Tree[intTreeIdx];

      if tmBinaryTree in treeSave.TreeModes then
      begin
        fsOutput := TFileStream.Create(treeSave.FileName, fmCreate or fmShareDenyWrite);
        try
          InternalSaveTreeToStream(fsOutput, treeSave, ltlTrees);
        finally
          fsOutput.Free();
        end;
      end
      else
      begin
        slOutput := TStringList.Create();
        try
          InternalSaveTreeToList(slOutput, treeSave, ltlTrees);
          slOutput.SaveToFile(treeSave.FileName);
        finally
          slOutput.Free();
        end;
      end;

      Inc(intTreeIdx);
    end;
  finally
    ltlTrees.Free();
  end;

  if boolMainTreeIsNotWritable then
    Exclude(FTreeModes, tmAccessWrite);

  FModified := False;
end;


{ ----- TTSInfoTree class ----------------------------------------------------------------------------------------- }


procedure TTSInfoTree.RenameTree(const ANewTreeName: UTF8String);
begin
  if (ANewTreeName = '') or ValidIdentifier(ANewTreeName) then
  begin
    FTreeName := ANewTreeName;
    FModified := True;
  end;
end;


procedure TTSInfoTree.RenameAttribute(const AAttrName, ANewAttrName: UTF8String);
var
  nodeParent: TTSInfoNode;
  attrRename: TTSInfoAttribute;
  strAttrName, strAttrNameOnly, strNodePath: UTF8String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    strAttrName := ExcludeTrailingIdentsDelimiter(AAttrName);
    strNodePath := ExtractPathComponent(strAttrName, pcAttributePath);

    if IsCurrentNodePath(strNodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(strNodePath, False);

    if nodeParent = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [strAttrName])
    else
    begin
      strAttrNameOnly := ExtractPathComponent(strAttrName, pcAttributeName);
      attrRename := nodeParent.GetAttribute(strAttrNameOnly);

      if attrRename = nil then
        ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [strAttrName])
      else
        if ValidIdentifier(ANewAttrName) then
        begin
          attrRename.Name := ANewAttrName;
          FModified := True;
        end;
    end;
  end;
end;


procedure TTSInfoTree.RenameChildNode(const ANodePath, ANewNodeName: UTF8String);
var
  nodeRename: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_RENAME)
      else
        nodeRename := FCurrentNode;
    end
    else
      nodeRename := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeRename = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeRename.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_RENAME)
      else
        if ValidIdentifier(ANewNodeName) then
        begin
          nodeRename.Name := ANewNodeName;
          FModified := True;
        end;
  end;
end;


procedure TTSInfoTree.RenameVirtualNode(const ANodePath, AVirtualNodeName, ANewVirtualNodeName: UTF8String);
var
  nodeParent: TTSInfoNode;
  linkRename: TTSInfoLink;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent = nil then
      ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
    begin
      linkRename := nodeParent.GetLink(AVirtualNodeName);

      if linkRename = nil then
        ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
      else
        if ValidIdentifier(ANewVirtualNodeName) then
        begin
          linkRename.VirtualNodeName := ANewVirtualNodeName;
          FModified := True;
        end;
    end;
  end;
end;


procedure TTSInfoTree.WriteTreeComment(const AComment, ADelimiter: UTF8String);
begin
  if ADelimiter = '' then
    FTreeComment := AComment
  else
    FTreeComment := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

  FModified := True;
end;


procedure TTSInfoTree.WriteAttributeComment(const AAttrName, AComment, ADelimiter: UTF8String; AType: TCommentType);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

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


procedure TTSInfoTree.WriteChildNodeComment(const ANodePath, AComment, ADelimiter: UTF8String; AType: TCommentType);
var
  nodeWrite: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_SET_COMMENT)
      else
        nodeWrite := FCurrentNode;
    end
    else
      nodeWrite := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeWrite = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeWrite.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_COMMENT)
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


procedure TTSInfoTree.WriteLinkComment(const ANodePath, AVirtualNodeName, AComment, ADelimiter: UTF8String);
var
  nodeParent: TTSInfoNode;
  linkWrite: TTSInfoLink;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent = nil then
      ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
    begin
      linkWrite := nodeParent.GetLink(AVirtualNodeName);

      if linkWrite = nil then
        ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
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


function TTSInfoTree.ReadTreeComment(const ADelimiter: UTF8String): UTF8String;
begin
  Result := ReplaceSubStrings(FTreeComment, VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadAttributeComment(const AAttrName, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
  else
    Result := ReplaceSubStrings(attrRead.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadChildNodeComment(const ANodePath, ADelimiter: UTF8String; AType: TCommentType): UTF8String;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_COMMENT)
    else
      nodeRead := FCurrentNode;
  end
  else
    nodeRead := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if nodeRead.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_COMMENT)
    else
      Result := ReplaceSubStrings(nodeRead.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadLinkComment(const ANodePath, AVirtualNodeName, ADelimiter: UTF8String): UTF8String;
var
  nodeParent: TTSInfoNode;
  linkRead: TTSInfoLink;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeParent = nil then
    ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
  else
  begin
    linkRead := nodeParent.GetLink(AVirtualNodeName);

    if linkRead = nil then
      ThrowException(EM_LINK_NOT_EXISTS, [ANodePath, AVirtualNodeName])
    else
      Result := ReplaceSubStrings(linkRead.Comment, VALUES_DELIMITER, ADelimiter);
  end;
end;


procedure TTSInfoTree.SetAttributeReference(const AAttrName: UTF8String; AReference: Boolean);
var
  attrWrite: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    attrWrite := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

    if attrWrite = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
    else
    begin
      attrWrite.Reference := AReference;
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.SetChildNodeReference(const ANodePath: UTF8String; AReference: Boolean);
var
  nodeWrite: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
    begin
      if FCurrentNode = FRootNode then
        ThrowException(EM_ROOT_NODE_SET_REFERENCE)
      else
        nodeWrite := FCurrentNode;
    end
    else
      nodeWrite := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeWrite = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if nodeWrite.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_REFERENCE)
      else
      begin
        nodeWrite.Reference := AReference;
        FModified := True;
      end;
  end;
end;


function TTSInfoTree.GetAttributeReference(const AAttrName: UTF8String): Boolean;
var
  attrRead: TTSInfoAttribute;
begin
  attrRead := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False);

  if attrRead = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrName])
  else
    Result := attrRead.Reference;
end;


function TTSInfoTree.GetChildNodeReference(const ANodePath: UTF8String = ''): Boolean;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE)
    else
      nodeRead := FCurrentNode;
  end
  else
    nodeRead := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if nodeRead.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE)
    else
      Result := nodeRead.Reference;
end;


procedure TTSInfoTree.RemoveAttribute(const AAttrName: UTF8String);
var
  nodeParent: TTSInfoNode;
  strAttrName, strAttrNameOnly, strAttrPath: UTF8String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    strAttrName := ExcludeTrailingIdentsDelimiter(AAttrName);
    strAttrPath := ExtractPathComponent(strAttrName, pcAttributePath);

    if IsCurrentNodePath(strAttrPath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(strAttrPath, False);

    if nodeParent <> nil then
    begin
      strAttrNameOnly := ExtractPathComponent(strAttrName, pcAttributeName);
      nodeParent.RemoveAttribute(strAttrNameOnly);
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveChildNode(const ANodePath: UTF8String);
var
  nodeRemove: TTSInfoNode;
  strNodeNameOnly: UTF8String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    nodeRemove := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeRemove <> nil then
      if nodeRemove.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_REMOVE)
      else
      begin
        strNodeNameOnly := nodeRemove.Name;
        nodeRemove := nodeRemove.ParentNode;
        nodeRemove.RemoveChildNode(strNodeNameOnly);
        FModified := True;
      end;
  end;
end;


procedure TTSInfoTree.RemoveLink(const ANodePath, AVirtualNodeName: UTF8String);
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent <> nil then
    begin
      nodeParent.RemoveLink(AVirtualNodeName);
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveAllAttributes(const ANodePath: UTF8String = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent <> nil then
    begin
      nodeParent.RemoveAllAttributes();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveAllChildNodes(const ANodePath: UTF8String = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent <> nil then
    begin
      nodeParent.RemoveAllChildNodes();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveAllLinks(const ANodePath: UTF8String = '');
var
  nodeParent: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      nodeParent := FCurrentNode
    else
      nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if nodeParent <> nil then
    begin
      nodeParent.RemoveAllLinks();
      FModified := True;
    end;
  end;
end;


function TTSInfoTree.AttributeExists(const AAttrName: UTF8String): Boolean;
begin
  Result := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrName), False) <> nil;
end;


function TTSInfoTree.ChildNodeExists(const ANodePath: UTF8String): Boolean;
begin
  Result := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False) <> nil;
end;


function TTSInfoTree.LinkExists(const ANodePath, AVirtualNodeName: UTF8String): Boolean;
var
  nodeParent: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  Result := (nodeParent <> nil) and (nodeParent.GetLink(AVirtualNodeName) <> nil);
end;


function TTSInfoTree.GetAttributesCount(const ANodePath: UTF8String = ''): Integer;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeRead := FCurrentNode
  else
    nodeRead := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetAttributesCount();
end;


function TTSInfoTree.GetChildNodesCount(const ANodePath: UTF8String = ''): Integer;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeRead := FCurrentNode
  else
    nodeRead := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetChildNodesCount();
end;


function TTSInfoTree.GetLinksCount(const ANodePath: UTF8String = ''): Integer;
var
  nodeRead: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeRead := FCurrentNode
  else
    nodeRead := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeRead = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := nodeRead.GetLinksCount();
end;


procedure TTSInfoTree.ReadAttributesNames(const ANodePath: UTF8String; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  intAttributeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for intAttributeIdx := 0 to nodeParent.AttributesCount - 1 do
      ANames.Add(nodeParent.GetAttribute(intAttributeIdx).Name);
end;


procedure TTSInfoTree.ReadAttributesValues(const ANodePath: UTF8String; AValues: TStrings);
var
  nodeParent: TTSInfoNode;
  intAttributeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for intAttributeIdx := 0 to nodeParent.AttributesCount - 1 do
      AValues.Add(nodeParent.GetAttribute(intAttributeIdx).Value);
end;


procedure TTSInfoTree.ReadChildNodesNames(const ANodePath: UTF8String; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  intNodeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for intNodeIdx := 0 to nodeParent.ChildNodesCount - 1 do
      ANames.Add(nodeParent.GetChildNode(intNodeIdx).Name);
end;


procedure TTSInfoTree.ReadVirtualNodesNames(const ANodePath: UTF8String; ANames: TStrings);
var
  nodeParent: TTSInfoNode;
  intLinkIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    nodeParent := FCurrentNode
  else
    nodeParent := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if nodeParent = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for intLinkIdx := 0 to nodeParent.LinksCount - 1 do
      ANames.Add(nodeParent.GetLink(intLinkIdx).VirtualNodeName);
end;


procedure TTSInfoTree.ExportTreeToFile(const AFileName: UTF8String; AFormat: TExportFormat = efTextTree);
var
  fsOutput: TStream;
  slOutput: TStrings;
begin
  if AFormat = efBinaryTree then
  begin
    fsOutput := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
    try
      InternalSaveTreeToStream(fsOutput, Self, nil);
    finally
      fsOutput.Free();
    end;
  end
  else
  begin
    slOutput := TStringList.Create();
    try
      InternalSaveTreeToList(slOutput, Self, nil);
      slOutput.SaveToFile(AFileName);
    finally
      slOutput.Free();
    end;
  end;
end;


procedure TTSInfoTree.ExportTreeToList(AList: TStrings);
begin
  InternalSaveTreeToList(AList, Self, nil);
end;


procedure TTSInfoTree.ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryTree);
var
  slOutput: TStrings;
begin
  if AFormat = efBinaryTree then
    InternalSaveTreeToStream(AStream, Self, nil)
  else
  begin
    slOutput := TStringList.Create();
    try
      InternalSaveTreeToList(slOutput, Self, nil);
      slOutput.SaveToStream(AStream);
    finally
      slOutput.Free();
    end;
  end;
end;


{ ----- TTSInfoTextInputReader class ------------------------------------------------------------------------------ }


constructor TTSInfoTextInputReader.Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStrings; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FInput := AInput;
  FProcessedTrees := AProcessedTrees;

  FRefElements := TTSInfoRefElementsList.Create(False);

  FComment := '';
  FAllowLinking := Assigned(FProcessedTrees) and (tmAllowLinking in FTSInfoTree.TreeModes);
end;


destructor TTSInfoTextInputReader.Destroy();
begin
  FTSInfoTree := nil;
  FInput := nil;
  FProcessedTrees := nil;

  FRefElements.Free();
  inherited Destroy();
end;


procedure TTSInfoTextInputReader.RemoveBOMSignature();
const
  UTF8_BOM_SIGNATURE     = UTF8String(#239#187#191);
  UTF8_BOM_SIGNATURE_LEN = Length(UTF8_BOM_SIGNATURE);
var
  strFirstLine: UTF8String;
begin
  if FInput.Count > 0 then
  begin
    strFirstLine := FInput[0];

    if (strFirstLine <> '') and (CompareByte(strFirstLine[1], UTF8_BOM_SIGNATURE[1], UTF8_BOM_SIGNATURE_LEN) = 0) then
    begin
      Delete(strFirstLine, 1, UTF8_BOM_SIGNATURE_LEN);
      FInput[0] := strFirstLine;
    end;
  end;
end;


procedure TTSInfoTextInputReader.RemoveWhitespace();
var
  strCurrentLine: UTF8String;
  intLineIdx: Integer;
begin
  for intLineIdx := FInput.Count - 1 downto 0 do
  begin
    strCurrentLine := RemoveWhitespaceChars(FInput[intLineIdx]);

    if strCurrentLine = '' then
      FInput.Delete(intLineIdx)
    else
      FInput[intLineIdx] := strCurrentLine;
  end;
end;


procedure TTSInfoTextInputReader.DetermineLineIndexes();
begin
  FEndTreeLineIndex := FInput.IndexOf(KEYWORD_TREE_END);

  if FEndTreeLineIndex = -1 then
    ThrowException(EM_MISSING_END_TREE_LINE);

  FLineIndex := 0;
end;


function TTSInfoTextInputReader.IsCommentLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) >= COMMENT_PREFIX_LEN) and
            (CompareByte(ALine[1], COMMENT_PREFIX[1], COMMENT_PREFIX_LEN) = 0);
end;


function TTSInfoTextInputReader.IsTreeHeaderLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) >= MIN_TREE_HEADER_LINE_LEN) and
            (CompareByte(ALine[1], TREE_HEADER_FORMAT_NAME[1], TREE_HEADER_FORMAT_NAME_LEN) = 0);
end;


function TTSInfoTextInputReader.IsFormatVersionValue(const AValue: UTF8String): Boolean;
const
  FORMAT_VERSION_INDEX_MAJOR = Integer(1);
  FORMAT_VERSION_INDEX_MINOR = Integer(3);
var
  intVersionMajor, intVersionMinor: UInt8;
  intCodeMajor, intCodeMinor: Integer;
begin
  Result := Length(AValue) = TREE_HEADER_FORMAT_VERSION_LEN;

  if Result then
  begin
    Val(AValue[FORMAT_VERSION_INDEX_MAJOR], intVersionMajor, intCodeMajor);
    Val(AValue[FORMAT_VERSION_INDEX_MINOR], intVersionMinor, intCodeMinor);

    Result := (intCodeMajor = 0) and (intCodeMinor = 0);

    if Result then
    begin
      Result := (intVersionMajor = SUPPORTED_FORMAT_VERSION_MAJOR) and (intVersionMinor >= SUPPORTED_FORMAT_VERSION_MINOR);

      if not Result then
        ThrowException(EM_UNSUPPORTED_FORMAT_VERSION, [AValue]);
    end;
  end;
end;


function TTSInfoTextInputReader.IsTreeEndLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) = KEYWORD_TREE_END_LEN) and
            (CompareByte(ALine[1], KEYWORD_TREE_END[1], KEYWORD_TREE_END_LEN) = 0);
end;


function TTSInfoTextInputReader.IsAttributeNameAndValueLine(const ALine: UTF8String): Boolean;
var
  pchrToken, pchrLast: PUTF8Char;
begin
  pchrToken := @ALine[KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE[ALine[1] = KEYWORD_REF_ATTRIBUTE[1]]] + 1;
  pchrLast := @ALine[Length(ALine)];

  while (pchrToken < pchrLast) and (pchrToken^ in WHITESPACE_CHARS) do
    Inc(pchrToken);

  Result := pchrToken^ <> QUOTE_CHAR;

  if Result then
  begin
    while (pchrToken < pchrLast) and (pchrToken^ <> QUOTE_CHAR) do
      Inc(pchrToken);

    while (pchrLast > pchrToken) and (pchrLast^ <> QUOTE_CHAR) do
      Dec(pchrLast);

    Result := (pchrToken < pchrLast) and (pchrLast^ = QUOTE_CHAR);
  end;
end;


function TTSInfoTextInputReader.IsStdAttributeLine(const ALine: UTF8String): Boolean;
var
  intLineLen: Integer;
begin
  Result := False;
  intLineLen := Length(ALine);

  if intLineLen >= MIN_STD_ATTRIBUTE_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_STD_ATTRIBUTE[1], KEYWORD_STD_ATTRIBUTE_LEN) = 0 then
      Result := IsAttributeNameAndValueLine(ALine);
end;


function TTSInfoTextInputReader.IsStdChildNodeLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) >= MIN_STD_NODE_LINE_LEN) and
            (CompareByte(ALine[1], KEYWORD_STD_NODE[1], KEYWORD_STD_NODE_LEN) = 0);
end;


function TTSInfoTextInputReader.IsStdChildNodeEndLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) = KEYWORD_STD_NODE_END_LEN) and
            (CompareByte(ALine[1], KEYWORD_STD_NODE_END[1], KEYWORD_STD_NODE_END_LEN) = 0);
end;


function TTSInfoTextInputReader.IsRefAttributeDeclarationLine(const ALine: UTF8String): Boolean;
var
  pchrToken, pchrLast: PUTF8Char;
  intLineLen: Integer;
begin
  Result := False;
  intLineLen := Length(ALine);

  if intLineLen >= MIN_REF_ATTRIBUTE_DEC_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_REF_ATTRIBUTE[1], KEYWORD_REF_ATTRIBUTE_LEN) = 0 then
    begin
      pchrToken := @ALine[KEYWORD_REF_ATTRIBUTE_LEN] + 1;
      pchrLast := @ALine[intLineLen];

      while (pchrToken < pchrLast) and (pchrToken^ in WHITESPACE_CHARS) do
        Inc(pchrToken);

      while (pchrToken <= pchrLast) and (pchrToken^ <> QUOTE_CHAR) do
        Inc(pchrToken);

      Result := pchrToken > pchrLast;
    end;
end;


function TTSInfoTextInputReader.IsRefAttributeDefinitionLine(const ALine: UTF8String): Boolean;
var
  intLineLen: Integer;
begin
  Result := False;
  intLineLen := Length(ALine);

  if intLineLen >= MIN_REF_ATTRIBUTE_DEF_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_REF_ATTRIBUTE[1], KEYWORD_REF_ATTRIBUTE_LEN) = 0 then
      Result := IsAttributeNameAndValueLine(ALine);
end;


function TTSInfoTextInputReader.IsRefChildNodeLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) >= MIN_REF_NODE_LINE_LEN) and
            (CompareByte(ALine[1], KEYWORD_REF_NODE[1], KEYWORD_REF_NODE_LEN) = 0);
end;


function TTSInfoTextInputReader.IsRefChildNodeEndLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) = KEYWORD_REF_NODE_END_LEN) and
            (CompareByte(ALine[1], KEYWORD_REF_NODE_END[1], KEYWORD_REF_NODE_END_LEN) = 0);
end;


function TTSInfoTextInputReader.IsLinkLine(const ALine: UTF8String): Boolean;
begin
  Result := (Length(ALine) >= MIN_LINK_LINE_LEN) and
            (CompareByte(ALine[1], KEYWORD_LINK[1], KEYWORD_LINK_LEN) = 0);
end;


function TTSInfoTextInputReader.IsValueLine(const ALine: UTF8String): Boolean;
var
  intLineLen: Integer;
begin
  intLineLen := Length(ALine);

  Result := (intLineLen >= MIN_ATTRIBUTE_VALUE_LINE_LEN) and
            (ALine[1] = QUOTE_CHAR) and (ALine[intLineLen] = QUOTE_CHAR);
end;


procedure TTSInfoTextInputReader.AddRefElement(AElement: TObject);
begin
  FRefElements.AddElement(AElement);
end;


procedure TTSInfoTextInputReader.InsertRefElement(AElement: TObject);
begin
  FRefElements.InsertElement(FNestedRefElementsCount, AElement);
  Inc(FNestedRefElementsCount);
end;


procedure TTSInfoTextInputReader.ExtractComment();
var
  strCurrentLine, strCurrentValue: UTF8String;
  intCurrentLineLen: Integer;
  pchrFirst, pchrLast: PUTF8Char;
begin
  ClearComment();

  repeat
    strCurrentLine := FInput[FLineIndex];
    intCurrentLineLen := Length(strCurrentLine);
    strCurrentValue := '';

    if intCurrentLineLen > COMMENT_PREFIX_LEN then
    begin
      pchrFirst := @strCurrentLine[COMMENT_PREFIX_LEN] + 1;
      pchrLast := @strCurrentLine[intCurrentLineLen];

      if pchrFirst^ in WHITESPACE_CHARS then
        Inc(pchrFirst);

      MoveString(pchrFirst^, strCurrentValue, pchrLast - pchrFirst + 1);
    end;

    FComment += strCurrentValue + VALUES_DELIMITER;
    Inc(FLineIndex);
  until (FLineIndex = FInput.Count) or not IsCommentLine(FInput[FLineIndex]);

  if FComment = VALUES_DELIMITER then
    FComment := ONE_BLANK_VALUE_LINE_CHAR
  else
    SetLength(FComment, Length(FComment) - 1);
end;


procedure TTSInfoTextInputReader.ExtractLineComponents(const ALine: UTF8String; out AComponents: TLineComponents; var ACount: Integer);
var
  strLine: UTF8String;
  pchrComponentBegin, pchrComponentEnd, pchrValueBegin, pchrValueEnd, pchrLast: PUTF8Char;
begin
  strLine := ALine + INDENT_CHAR;
  pchrComponentBegin := @strLine[1];
  pchrLast := @strLine[Length(strLine)];

  while pchrComponentBegin < pchrLast do
  begin
    while (pchrComponentBegin < pchrLast) and (pchrComponentBegin^ in WHITESPACE_CHARS) do
      Inc(pchrComponentBegin);

    if pchrComponentBegin < pchrLast then
    begin
      pchrComponentEnd := pchrComponentBegin;

      repeat
        Inc(pchrComponentEnd);
      until (pchrComponentEnd = pchrLast) or (pchrComponentEnd^ = QUOTE_CHAR);

      if (pchrComponentBegin^ <> QUOTE_CHAR) or (pchrComponentEnd < pchrLast) then
      begin
        pchrValueBegin := pchrComponentBegin;
        pchrValueEnd := pchrComponentEnd - 1;

        if pchrValueBegin^ = QUOTE_CHAR then
        begin
          Inc(pchrValueBegin);

          while (pchrValueBegin <= pchrValueEnd) and (pchrValueBegin^ in WHITESPACE_CHARS) do
            Inc(pchrValueBegin);
        end;

        while (pchrValueEnd >= pchrValueBegin) and (pchrValueEnd^ in WHITESPACE_CHARS) do
          Dec(pchrValueEnd);

        SetLength(AComponents, ACount + 1);
        MoveString(pchrValueBegin^, AComponents[ACount], pchrValueEnd - pchrValueBegin + 1);
        Inc(ACount);
      end;

      pchrComponentBegin := pchrComponentEnd + UInt8(pchrComponentBegin^ = QUOTE_CHAR);
    end
  end;
end;


procedure TTSInfoTextInputReader.ExtractAttribute(const ALine: UTF8String; out AReference: Boolean; out AName, AValue: UTF8String);
var
  pchrName, pchrValueBegin, pchrValueEnd: PUTF8Char;
begin
  AReference := ALine[1] = KEYWORD_REF_ATTRIBUTE[1];
  pchrName := @ALine[KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE[AReference]] + 1;

  while pchrName^ in WHITESPACE_CHARS do
    Inc(pchrName);

  pchrValueBegin := pchrName + 1;
  pchrValueEnd := @ALine[Length(ALine)];

  while pchrValueBegin^ <> QUOTE_CHAR do
    Inc(pchrValueBegin);

  while pchrValueEnd^ <> QUOTE_CHAR do
    Dec(pchrValueEnd);

  MoveString(PUTF8Char(pchrValueBegin + 1)^, AValue, pchrValueEnd - pchrValueBegin - 1);

  repeat
    Dec(pchrValueBegin);
  until not (pchrValueBegin^ in WHITESPACE_CHARS);

  MoveString(pchrName^, AName, pchrValueBegin - pchrName + 1);
end;


procedure TTSInfoTextInputReader.ExtractAttributeNextValue(const ALine: UTF8String; out ANextValue: UTF8String);
begin
  MoveString(ALine[2], ANextValue, Length(ALine) - 2);
end;


procedure TTSInfoTextInputReader.ExtractChildNode(const ALine: UTF8String; out AReference: Boolean; out AName: UTF8String);
var
  pchrNameBegin, pchrNameEnd: PUTF8Char;
begin
  AReference := ALine[1] = KEYWORD_REF_NODE[1];

  pchrNameBegin := @ALine[KEYWORD_NODE_LEN_BY_REFERENCE[AReference]] + 1;
  pchrNameEnd := @ALine[Length(ALine)];

  while pchrNameBegin^ in WHITESPACE_CHARS do
    Inc(pchrNameBegin);

  MoveString(pchrNameBegin^, AName, pchrNameEnd - pchrNameBegin + 1);
end;


procedure TTSInfoTextInputReader.ExtractAttributeNameFromDeclarationLine(const ALine: UTF8String; out AName: UTF8String);
var
  pchrNameBegin, pchrNameEnd: PUTF8Char;
begin
  pchrNameBegin := @ALine[KEYWORD_REF_ATTRIBUTE_LEN] + 1;
  pchrNameEnd := @ALine[Length(ALine)];

  while pchrNameBegin^ in WHITESPACE_CHARS do
    Inc(pchrNameBegin);

  MoveString(pchrNameBegin^, AName, pchrNameEnd - pchrNameBegin + 1);
end;


procedure TTSInfoTextInputReader.ExtractAttributeNameFromDefinitionLine(const ALine: UTF8String; out AName: UTF8String);
var
  pchrNameBegin, pchrNameEnd: PUTF8Char;
begin
  pchrNameBegin := @ALine[KEYWORD_REF_ATTRIBUTE_LEN] + 1;

  while pchrNameBegin^ in WHITESPACE_CHARS do
    Inc(pchrNameBegin);

  pchrNameEnd := pchrNameBegin + 1;

  while pchrNameEnd^ <> QUOTE_CHAR do
    Inc(pchrNameEnd);

  repeat
    Dec(pchrNameEnd);
  until not (pchrNameEnd^ in WHITESPACE_CHARS);

  MoveString(pchrNameBegin^, AName, pchrNameEnd - pchrNameBegin + 1);
end;


{ ----- TTSInfoTextOutputWriter class ----------------------------------------------------------------------------- }


constructor TTSInfoTextOutputWriter.Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStrings; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FOutput := AOutput;
  FProcessedTrees := AProcessedTrees;

  FRefElements := TTSInfoRefElementsList.Create(False);
  FAllowLinking := Assigned(FProcessedTrees) and (tmAllowLinking in FTSInfoTree.TreeModes);
end;


destructor TTSInfoTextOutputWriter.Destroy();
begin
  FTSInfoTree := nil;
  FOutput := nil;
  FProcessedTrees := nil;

  FRefElements.Free();
  inherited Destroy();
end;


{ ----- TTSInfoBinaryInputReader class ---------------------------------------------------------------------------- }


constructor TTSInfoBinaryInputReader.Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStream; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FInput := AInput;
  FProcessedTrees := AProcessedTrees;

  FAllowLinking := Assigned(FProcessedTrees) and (tmAllowLinking in FTSInfoTree.TreeModes);
end;


destructor TTSInfoBinaryInputReader.Destroy();
begin
  FTSInfoTree := nil;
  FInput := nil;
  FProcessedTrees := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryInputReader.ReadUTF8StringBuffer(out ABuffer: UTF8String);
var
  intBufferLen: UInt32;
begin
  ReadUInt32Buffer(intBufferLen);
  SetLength(ABuffer, intBufferLen);
  FInput.Read(ABuffer[1], intBufferLen);
end;


procedure TTSInfoBinaryInputReader.ReadBooleanBuffer(out ABuffer: Boolean);
var
  intBuffer: UInt8 = 0;
begin
  FInput.Read(intBuffer, SizeOf(intBuffer));
  ABuffer := intBuffer <> 0;
end;


procedure TTSInfoBinaryInputReader.ReadUInt8Buffer(out ABuffer: UInt8);
begin
  ABuffer := 0;
  FInput.Read(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryInputReader.ReadUInt32Buffer(out ABuffer: UInt32);
begin
  ABuffer := 0;
  FInput.Read(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryInputReader.ReadTreeMode(var AModes: TTreeModes; AModeOnValue, AModeOffValue: TTreeMode);
var
  boolFileModeOn: Boolean;
begin
  ReadBooleanBuffer(boolFileModeOn);

  if boolFileModeOn then
    Include(AModes, AModeOnValue)
  else
    Include(AModes, AModeOffValue);
end;


procedure TTSInfoBinaryInputReader.ReadHeader();
var
  strSignature: UTF8String;
  intVersionMajor, intVersionMinor: UInt8;
begin
  SetLength(strSignature, BINARY_FILE_SIGNATURE_LEN);
  FillChar(strSignature[1], BINARY_FILE_SIGNATURE_LEN, 0);
  FInput.Read(strSignature[1], BINARY_FILE_SIGNATURE_LEN);

  if CompareByte(strSignature[1], BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN) = 0 then
  begin
    ReadUInt8Buffer(intVersionMajor);
    ReadUInt8Buffer(intVersionMinor);

    if (intVersionMajor = SUPPORTED_FORMAT_VERSION_MAJOR) and (intVersionMinor >= SUPPORTED_FORMAT_VERSION_MINOR) then
    begin
      ReadUTF8StringBuffer(FTSInfoTree.FTreeName);
      ReadUTF8StringBuffer(FTSInfoTree.FTreeComment);
    end
    else
      ThrowException(EM_UNSUPPORTED_BINARY_FORMAT_VERSION, [intVersionMajor, intVersionMinor]);
  end
  else
    ThrowException(EM_INVALID_BINARY_FILE);
end;


procedure TTSInfoBinaryInputReader.ReadElements(AParentNode: TTSInfoNode);
var
  intElementsCnt: UInt32;
  intElementIdx: Integer;
begin
  ReadUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    ReadAttribute(AParentNode.CreateAttribute(False, ''));

  ReadUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    ReadChildNode(AParentNode.CreateChildNode(False, ''));

  ReadUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    ReadLink(AParentNode.CreateLink('', ''));
end;


procedure TTSInfoBinaryInputReader.ReadAttribute(AAttribute: TTSInfoAttribute);
begin
  ReadBooleanBuffer(AAttribute.FReference);

  ReadUTF8StringBuffer(AAttribute.FName);
  ReadUTF8StringBuffer(AAttribute.FValue);

  ReadUTF8StringBuffer(AAttribute.FComment[ctDeclaration]);
  ReadUTF8StringBuffer(AAttribute.FComment[ctDefinition]);
end;


procedure TTSInfoBinaryInputReader.ReadChildNode(AChildNode: TTSInfoNode);
begin
  ReadBooleanBuffer(AChildNode.FReference);

  ReadUTF8StringBuffer(AChildNode.FName);
  ReadUTF8StringBuffer(AChildNode.FComment[ctDeclaration]);
  ReadUTF8StringBuffer(AChildNode.FComment[ctDefinition]);

  ReadElements(AChildNode);
end;


procedure TTSInfoBinaryInputReader.ReadLink(ALink: TTSInfoLink);
begin
  ReadUTF8StringBuffer(ALink.LinkedTree.FFileName);
  ReadUTF8StringBuffer(ALink.FVirtualNodeName);

  ALink.LinkedTree.TreeModes := [tmAllowLinking];
  ReadTreeMode(ALink.LinkedTree.FTreeModes, tmBinaryTree, tmTextTree);
  ReadTreeMode(ALink.LinkedTree.FTreeModes, tmAccessWrite, tmAccessRead);

  ReadUTF8StringBuffer(ALink.FComment);

  if FAllowLinking and FProcessedTrees.FileNotYetBeenProcessed(ALink.FileName) then
    FProcessedTrees.AddElement(ALink.LinkedTree);
end;


procedure TTSInfoBinaryInputReader.ProcessInput();
begin
  try
    ReadHeader();
    ReadElements(FTSInfoTree.FRootNode);
  except
    FTSInfoTree.DamageClear();
    raise;
  end;
end;


{ ----- TTSInfoBinaryOutputWriter class --------------------------------------------------------------------------- }


constructor TTSInfoBinaryOutputWriter.Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStream; AProcessedTrees: TTSInfoProcessedTreesList);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FOutput := AOutput;
  FProcessedTrees := AProcessedTrees;

  FAllowLinking := Assigned(FProcessedTrees) and (tmAllowLinking in FTSInfoTree.TreeModes);
end;


destructor TTSInfoBinaryOutputWriter.Destroy();
begin
  FTSInfoTree := nil;
  FOutput := nil;
  FProcessedTrees := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryOutputWriter.WriteUTF8StringBuffer(const ABuffer: UTF8String);
var
  intBufferLen: UInt32;
begin
  intBufferLen := Length(ABuffer);
  WriteUInt32Buffer(intBufferLen);
  FOutput.Write(ABuffer[1], intBufferLen);
end;


procedure TTSInfoBinaryOutputWriter.WriteBooleanBuffer(ABuffer: Boolean);
var
  intBuffer: UInt8;
begin
  intBuffer := UInt8(ABuffer);
  FOutput.Write(intBuffer, SizeOf(intBuffer));
end;


procedure TTSInfoBinaryOutputWriter.WriteUInt8Buffer(ABuffer: UInt8);
begin
  FOutput.Write(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryOutputWriter.WriteUInt32Buffer(ABuffer: UInt32);
begin
  FOutput.Write(ABuffer, SizeOf(ABuffer));
end;


procedure TTSInfoBinaryOutputWriter.WriteTreeMode(AModes: TTreeModes; AModeOnValue: TTreeMode);
begin
  WriteBooleanBuffer(AModeOnValue in AModes);
end;


procedure TTSInfoBinaryOutputWriter.WriteHeader();
begin
  FOutput.Write(BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN);

  WriteUInt8Buffer(SUPPORTED_FORMAT_VERSION_MAJOR);
  WriteUInt8Buffer(SUPPORTED_FORMAT_VERSION_MINOR);

  WriteUTF8StringBuffer(FTSInfoTree.FTreeName);
  WriteUTF8StringBuffer(FTSInfoTree.FTreeComment);
end;


procedure TTSInfoBinaryOutputWriter.WriteElements(AParentNode: TTSInfoNode);
var
  intElementsCnt: UInt32;
  intElementIdx: Integer;
begin
  intElementsCnt := AParentNode.AttributesCount;
  WriteUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    WriteAttribute(AParentNode.GetAttribute(intElementIdx));

  intElementsCnt := AParentNode.ChildNodesCount;
  WriteUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    WriteChildNode(AParentNode.GetChildNode(intElementIdx));

  intElementsCnt := AParentNode.LinksCount;
  WriteUInt32Buffer(intElementsCnt);

  for intElementIdx := 0 to intElementsCnt - 1 do
    WriteLink(AParentNode.GetLink(intElementIdx));
end;


procedure TTSInfoBinaryOutputWriter.WriteAttribute(AAttribute: TTSInfoAttribute);
begin
  WriteBooleanBuffer(AAttribute.FReference);

  WriteUTF8StringBuffer(AAttribute.FName);
  WriteUTF8StringBuffer(AAttribute.FValue);

  WriteUTF8StringBuffer(AAttribute.FComment[ctDeclaration]);
  WriteUTF8StringBuffer(AAttribute.FComment[ctDefinition]);
end;


procedure TTSInfoBinaryOutputWriter.WriteChildNode(AChildNode: TTSInfoNode);
begin
  WriteBooleanBuffer(AChildNode.FReference);

  WriteUTF8StringBuffer(AChildNode.FName);
  WriteUTF8StringBuffer(AChildNode.FComment[ctDeclaration]);
  WriteUTF8StringBuffer(AChildNode.FComment[ctDefinition]);

  WriteElements(AChildNode);
end;


procedure TTSInfoBinaryOutputWriter.WriteLink(ALink: TTSInfoLink);
begin
  WriteUTF8StringBuffer(ALink.LinkedTree.FFileName);
  WriteUTF8StringBuffer(ALink.FVirtualNodeName);

  WriteTreeMode(ALink.LinkedTree.FTreeModes, tmBinaryTree);
  WriteTreeMode(ALink.LinkedTree.FTreeModes, tmAccessWrite);

  WriteUTF8StringBuffer(ALink.FComment);

  if tmAccessWrite in ALink.LinkedTree.TreeModes then
    if FAllowLinking and FProcessedTrees.FileNotYetBeenProcessed(ALink.FileName) then
      FProcessedTrees.AddElement(ALink.LinkedTree);
end;


procedure TTSInfoBinaryOutputWriter.ProcessOutput();
begin
  WriteHeader();
  WriteElements(FTSInfoTree.FRootNode);
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

