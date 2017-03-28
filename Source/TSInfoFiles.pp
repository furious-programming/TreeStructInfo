{

    TSInfoFiles.pp              last modified: 23 February 2017

    Copyright © Jarosław Baran, furious programming 2013 - 2017.
    All rights reserved.
   __________________________________________________________________________

    This unit is a part of the TreeStructInfo library.

    Contains a set of classes to handle TreeStructInfo files. The following
    classes are used to handle files and to make any changes, accordance
    with the documentation of the format in version '2.0'.
   __________________________________________________________________________

    For more informations about TreeStructInfo file format and the following
    library, see <http://treestruct.info>.

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

{$MODE OBJFPC}{$LONGSTRINGS ON}


interface

uses
  TSInfoConsts, TSInfoTypes, TSInfoUtils, LResources, LazUTF8, Classes, SysUtils, Types;


{ ----- basic elements classes ------------------------------------------------------------------------------------ }


type
  TTSInfoAttribute = class(TObject)
  private
    FReference: Boolean;
    FName: String;
    FValue: String;
    FComment: TComment;
  private
    procedure SetName(const AName: String);
    procedure SetValue(const AValue: String);
  private
    function GetComment(AType: TCommentType): String;
    procedure SetComment(AType: TCommentType; const AComment: String);
  public
    constructor Create(AReference: Boolean; const AName: String); overload;
    constructor Create(AReference: Boolean; const AName, AValue: String; const AComment: TComment); overload;
  public
    property Reference: Boolean read FReference write FReference;
    property Name: String read FName write SetName;
    property Value: String read FValue write SetValue;
    property Comment[AType: TCommentType]: String read GetComment write SetComment;
  end;


type
  TTSInfoAttributesList = class;
  TTSInfoNodesList = class;

type
  TTSInfoNode = class(TObject)
  private
    FParentNode: TTSInfoNode;
    FReference: Boolean;
    FName: String;
    FComment: TComment;
    FAttributesList: TTSInfoAttributesList;
    FChildNodesList: TTSInfoNodesList;
  private
    function GetComment(AType: TCommentType): String;
    procedure SetComment(AType: TCommentType; const AComment: String);
    procedure SetName(const AName: String);
  public
    function GetAttribute(const AName: String): TTSInfoAttribute; overload;
    function GetAttribute(AIndex: Integer): TTSInfoAttribute; overload;
    function GetChildNode(const AName: String): TTSInfoNode; overload;
    function GetChildNode(AIndex: Integer): TTSInfoNode; overload;
  public
    function GetAttributesCount(): Integer;
    function GetChildNodesCount(): Integer;
  public
    constructor Create(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment);
    destructor Destroy(); override;
  public
    function CreateAttribute(AReference: Boolean; const AName: String): TTSInfoAttribute; overload;
    function CreateAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute; overload;
    function CreateChildNode(AReference: Boolean; const AName: String): TTSInfoNode; overload;
    function CreateChildNode(AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode; overload;
  public
    procedure RemoveAttribute(const AName: String);
    procedure RemoveChildNode(const AName: String);
  public
    procedure RemoveAllAttributes();
    procedure RemoveAllChildNodes();
  public
    property ParentNode: TTSInfoNode read FParentNode;
    property Reference: Boolean read FReference write FReference;
    property Name: String read FName write SetName;
    property Comment[AType: TCommentType]: String read GetComment write SetComment;
    property AttributesCount: Integer read GetAttributesCount;
    property ChildNodesCount: Integer read GetChildNodesCount;
  end;


{ ----- token objects --------------------------------------------------------------------------------------------- }


type
  TTSInfoAttributeToken = object
  private
    FParentNode: TTSInfoNode;
    FAttribute: TTSInfoAttribute;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): String;
    procedure SetComment(AType: TCommentType; const AComment: String);
  public
    property Name: String read FAttribute.FName write FAttribute.FName;
    property Reference: Boolean read FAttribute.FReference write FAttribute.FReference;
    property Value: String read FAttribute.FValue write FAttribute.FValue;
    property Comment[AType: TCommentType]: String read GetComment write SetComment;
  end;


type
  TTSInfoChildNodeToken = object
  private
    FParentNode: TTSInfoNode;
    FChildNode: TTSInfoNode;
    FIndex: Integer;
  private
    function GetComment(AType: TCommentType): String;
    procedure SetComment(AType: TCommentType; const AComment: String);
  public
    property Name: String read FChildNode.FName write FChildNode.FName;
    property Reference: Boolean read FChildNode.FReference write FChildNode.FReference;
    property Comment[AType: TCommentType]: String read GetComment write SetComment;
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
    function InternalAddAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute;
  public
    constructor Create();
  public
    function GetAttribute(const AName: String): TTSInfoAttribute; overload;
    function GetAttribute(AIndex: Integer): TTSInfoAttribute; overload;
  public
    function AddAttribute(AReference: Boolean; const AName: String): TTSInfoAttribute; overload;
    function AddAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute; overload;
  public
    procedure RemoveAttribute(const AName: String);
    procedure RemoveAll();
  end;


type
  TTSInfoNodesList = class(TTSInfoElementsList)
  private
    function InternalAddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode;
  public
    constructor Create();
  public
    function GetChildNode(const AName: String): TTSInfoNode; overload;
    function GetChildNode(AIndex: Integer): TTSInfoNode; overload;
  public
    function AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String): TTSInfoNode; overload;
    function AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode; overload;
  public
    procedure RemoveChildNode(const AName: String);
    procedure RemoveAll();
  end;


{ ----- additional container classes ------------------------------------------------------------------------------ }


type
  TTSInfoRefElementsList = class(TTSInfoElementsList)
  public
    procedure InsertElement(AIndex: Integer; AElement: TObject);
  public
    function FirstElementIsAttribute(const AMandatoryName: String): Boolean;
    function FirstElementIsChildNode(const AMandatoryName: String): Boolean;
  public
    function PopFirstElement(): TObject;
  end;


{ ----- tree classes ---------------------------------------------------------------------------------------------- }


type
  TSimpleTSInfoTree = class(TObject)
  private
    FRootNode: TTSInfoNode;
    FCurrentNode: TTSInfoNode;
    FFileName: String;
    FTreeName: String;
    FTreeComment: String;
    FCurrentlyOpenNodePath: String;
    FTreeModes: TTreeModes;
  protected
    FModified: Boolean;
    FReadOnly: Boolean;
  private
    procedure InitFields();
    procedure DamageClear();
  private
    procedure InternalLoadTreeFromList(AList: TStrings; ATree: TSimpleTSInfoTree);
    procedure InternalLoadTreeFromStream(AStream: TStream; ATree: TSimpleTSInfoTree);
    procedure InternalSaveTreeToList(AList: TStrings; ATree: TSimpleTSInfoTree);
    procedure InternalSaveTreeToStream(AStream: TStream; ATree: TSimpleTSInfoTree);
  protected
    function FindElement(const AElementName: String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
    function FindAttribute(const AAttrPath: String; AForcePath: Boolean): TTSInfoAttribute;
    function FindNode(const ANodePath: String; AForcePath: Boolean): TTSInfoNode;
  private
    procedure SetTreeName(const ATreeName: String);
  public
    constructor Create();
    constructor Create(const AFileName: String; AModes: TTreeModes);
  public
    destructor Destroy(); override;
  public
    procedure LoadFromFile(const AFileName: String; AModes: TTreeModes = []);
    procedure LoadFromList(AList: TStrings; const AFileName: String = ''; AModes: TTreeModes = []);
    procedure LoadFromStream(AStream: TStream; const AFileName: String = ''; AModes: TTreeModes = []);
    procedure LoadFromResource(AInstance: TFPResourceHMODULE; const AResName: String; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []); overload;
    procedure LoadFromResource(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []); overload;
    procedure LoadFromLazarusResource(const AResName: String; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []);
  public
    function OpenChildNode(const ANodePath: String; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
    procedure GoToParentNode(AKeepReadOnlyMode: Boolean = True);
    procedure CloseChildNode();
  public
    procedure WriteBoolean(const AAttrPath: String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
    procedure WriteInteger(const AAttrPath: String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
    procedure WriteFloat(const AAttrPath: String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteFloat(const AAttrPath: String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral); overload;
    procedure WriteCurrency(const AAttrPath: String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteCurrency(const AAttrPath: String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice); overload;
    procedure WriteString(const AAttrPath, AString: String; AFormat: TFormatString = fsOriginal);
    procedure WriteDateTime(const AAttrPath, AMask: String; ADateTime: TDateTime); overload;
    procedure WriteDateTime(const AAttrPath, AMask: String; ADateTime: TDateTime; ASettings: TFormatSettings); overload;
    procedure WritePoint(const AAttrPath: String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
    procedure WriteList(const AAttrPath: String; AList: TStrings);
    procedure WriteBuffer(const AAttrPath: String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
    procedure WriteStream(const AAttrPath: String; AStream: TStream; ASize: UInt32; AFormat: TFormatStream = fs32BytesPerLine);
  public
    function ReadBoolean(const AAttrPath: String; ADefault: Boolean): Boolean;
    function ReadInteger(const AAttrPath: String; ADefault: Integer): Integer;
    function ReadFloat(const AAttrPath: String; ADefault: Double): Double; overload;
    function ReadFloat(const AAttrPath: String; ADefault: Double; ASettings: TFormatSettings): Double; overload;
    function ReadCurrency(const AAttrPath: String; ADefault: Currency): Currency; overload;
    function ReadCurrency(const AAttrPath: String; ADefault: Currency; ASettings: TFormatSettings): Currency; overload;
    function ReadString(const AAttrPath, ADefault: String; AFormat: TFormatString = fsOriginal): String;
    function ReadDateTime(const AAttrPath, AMask: String; ADefault: TDateTime): TDateTime; overload;
    function ReadDateTime(const AAttrPath, AMask: String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime; overload;
    function ReadPoint(const AAttrPath: String; ADefault: TPoint): TPoint;
    procedure ReadList(const AAttrPath: String; AList: TStrings);
    procedure ReadBuffer(const AAttrPath: String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
    procedure ReadStream(const AAttrPath: String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
  public
    function CreateAttribute(const ANodePath: String; AReference: Boolean; const AAttrName: String): Boolean;
    function CreateChildNode(const ANodePath: String; AReference: Boolean; const ANodeName: String; AOpen: Boolean = False): Boolean;
  public
    procedure ClearChildNode(const ANodePath: String = CURRENT_NODE_SYMBOL);
    procedure ClearTree();
  public
    function FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; const AParentNodePath: String = CURRENT_NODE_SYMBOL): Boolean;
    function FindNextAttribute(var AAttrToken: TTSInfoAttributeToken): Boolean;
    function FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; const AParentNodePath: String = CURRENT_NODE_SYMBOL): Boolean;
    function FindNextChildNode(var ANodeToken: TTSInfoChildNodeToken): Boolean;
  public
    procedure RenameAttributeTokens(const ANodePath, ATokenName: String; AStartIndex: Integer; ADirection: TRenamingDirection);
    procedure RenameChildNodeTokens(const ANodePath, ATokenName: String; AStartIndex: Integer; ADirection: TRenamingDirection);
  public
    procedure UpdateFile();
  public
    procedure SwitchTreeForm();
    procedure SwitchTreeAccess();
  public
    property FileName: String read FFileName;
    property TreeName: String read FTreeName write SetTreeName;
    property CurrentlyOpenNodeName: String read FCurrentNode.FName;
    property CurrentlyOpenNodePath: String read FCurrentlyOpenNodePath;
    property TreeModes: TTreeModes read FTreeModes write FTreeModes;
    property Modified: Boolean read FModified;
    property ReadOnly: Boolean read FReadOnly;
  end;


type
  TTSInfoTree = class(TSimpleTSInfoTree)
  public
    procedure RenameAttribute(const AAttrPath, ANewAttrName: String);
    procedure RenameChildNode(const ANodePath, ANewNodeName: String);
  public
    procedure WriteTreeComment(const AComment, ADelimiter: String);
    procedure WriteAttributeComment(const AAttrPath, AComment, ADelimiter: String; AType: TCommentType);
    procedure WriteChildNodeComment(const ANodePath, AComment, ADelimiter: String; AType: TCommentType);
  public
    function ReadTreeComment(const ADelimiter: String): String;
    function ReadAttributeComment(const AAttrPath, ADelimiter: String; AType: TCommentType): String;
    function ReadChildNodeComment(const ANodePath, ADelimiter: String; AType: TCommentType): String;
  public
    procedure SetAttributeReference(const AAttrPath: String; AReference: Boolean);
    procedure SetChildNodeReference(const ANodePath: String; AReference: Boolean);
  public
    function GetAttributeReference(const AAttrPath: String): Boolean;
    function GetChildNodeReference(const ANodePath: String = CURRENT_NODE_SYMBOL): Boolean;
  public
    procedure RemoveAttribute(const AAttrPath: String);
    procedure RemoveChildNode(const ANodePath: String);
  public
    procedure RemoveAllAttributes(const ANodePath: String = CURRENT_NODE_SYMBOL);
    procedure RemoveAllChildNodes(const ANodePath: String = CURRENT_NODE_SYMBOL);
  public
    function AttributeExists(const AAttrPath: String): Boolean;
    function ChildNodeExists(const ANodePath: String): Boolean;
  public
    function GetAttributesCount(const ANodePath: String = CURRENT_NODE_SYMBOL): Integer;
    function GetChildNodesCount(const ANodePath: String = CURRENT_NODE_SYMBOL): Integer;
  public
    procedure ReadAttributesNames(ANames: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
    procedure ReadAttributesValues(AValues: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
    procedure ReadChildNodesNames(ANames: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
  public
    procedure ExportTreeToFile(const AFileName: String; AFormat: TExportFormat = efTextTree);
    procedure ExportTreeToList(AList: TStrings);
    procedure ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryTree);
  end;


{ ----- text input reader and output writer classes --------------------------------------------------------------- }


type
  TTSInfoTextInputReader = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FInput: TStrings;
    FRefElements: TTSInfoRefElementsList;
    FComment: String;
  private
    FEndTreeLineIndex: Integer;
    FLineIndex: Integer;
    FNestedLevel: Integer;
    FNestedRefElementsCount: Integer;
  private
    FStoreRefElement: TStoreRefElementProc;
  private
    procedure RemoveBOMSignature();
    procedure RemoveWhitespace();
    procedure DetermineLineIndexes();
  private
    procedure ProcessMainTreeComment();
    procedure ProcessTreeHeader();
    procedure ProcessMainPart();
    procedure ProcessReferencingPart();
  private
    function IsCommentLine(const ALine: String): Boolean;
    function IsTreeHeaderLine(const ALine: String): Boolean;
    function IsFormatVersionValue(const AValue: String): Boolean;
    function IsAttributeNameAndValueLine(const ALine: String): Boolean;
    function IsStdAttributeLine(const ALine: String): Boolean;
    function IsStdChildNodeLine(const ALine: String): Boolean;
    function IsStdChildNodeEndLine(const ALine: String): Boolean;
    function IsRefAttributeDeclarationLine(const ALine: String): Boolean;
    function IsRefAttributeDefinitionLine(const ALine: String): Boolean;
    function IsRefChildNodeLine(const ALine: String): Boolean;
    function IsRefChildNodeEndLine(const ALine: String): Boolean;
    function IsValueLine(const ALine: String): Boolean;
  private
    procedure AddRefElement(AElement: TObject);
    procedure InsertRefElement(AElement: TObject);
  private
    procedure AddStdAttribute();
    procedure AddStdChildNode();
    procedure AddRefAttribute();
    procedure AddRefChildNode();
  private
    procedure CloseStdChildNode();
    procedure CloseRefChildNode();
  private
    procedure FillRefAttribute();
    procedure FillRefChildNode();
  private
    procedure ClearComment();
  private
    procedure ExtractComment();
    procedure ExtractLineComponents(const ALine: String; out AComponents: TLineComponents; var ACount: Integer);
    procedure ExtractAttribute(const ALine: String; out AReference: Boolean; out AName, AValue: String);
    procedure ExtractAttributeNextValue(const ALine: String; out ANextValue: String);
    procedure ExtractChildNode(const ALine: String; out AReference: Boolean; out AName: String);
  private
    procedure ExtractAttributeName(const ALine: String; out AName: String);
    procedure ExtractChildNodeName(const ALine: String; out AName: String);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStrings);
    destructor Destroy(); override;
  public
    procedure ProcessInput();
  end;


type
  TTSInfoTextOutputWriter = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FOutput: TStrings;
    FRefElements: TTSInfoRefElementsList;
  private
    FNestedRefElementsCount: Integer;
    FExtraSpaceNeeded: Boolean;
  private
    FIndentation: String;
    FIndentationSize: Integer;
  private
    FStoreRefElement: TStoreRefElementProc;
  private
    procedure ProcessMainPart();
    procedure ProcessReferencingPart();
  private
    procedure IncIndentation();
    procedure DecIndentation();
    procedure ResetIndentation();
  private
    procedure AddComment(const AComment: String);
    procedure AddTreeComment(const ATreeComment: String);
    procedure AddTreeHeader(const ATreeName: String);
    procedure AddTreeEnd();
    procedure AddStdAttribute(AAttribute: TTSInfoAttribute);
    procedure AddStdChildNode(AChildNode: TTSInfoNode);
    procedure AddRefAttributeDeclaration(AAttribute: TTSInfoAttribute);
    procedure AddRefAttributeDefinition(AAttribute: TTSInfoAttribute);
    procedure AddRefChildNodeDeclaration(AChildNode: TTSInfoNode);
    procedure AddRefChildNodeDefinition(AChildNode: TTSInfoNode);
    procedure AddEmptySpace();
  private
    procedure AddChildNodeAttributes(AParentNode: TTSInfoNode);
    procedure AddChildNodeChildNodes(AParentNode: TTSInfoNode);
  private
    procedure AddRefElement(AElement: TObject);
    procedure InsertRefElement(AElement: TObject);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStrings);
    destructor Destroy(); override;
  public
    procedure ProcessOutput();
  end;


{ ----- binary input reader and output writer classes ------------------------------------------------------------- }


type
  TTSInfoBinaryInputReader = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FInput: TStream;
  private
    procedure ReadStringBuffer(out ABuffer: String);
    procedure ReadBooleanBuffer(out ABuffer: Boolean);
    procedure ReadUInt8Buffer(out ABuffer: UInt8);
    procedure ReadUInt32Buffer(out ABuffer: UInt32);
  private
    procedure ReadHeader();
    procedure ReadElements(AParentNode: TTSInfoNode);
    procedure ReadAttribute(AAttribute: TTSInfoAttribute);
    procedure ReadChildNode(AChildNode: TTSInfoNode);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStream);
    destructor Destroy(); override;
  public
    procedure ProcessInput();
  end;


type
  TTSInfoBinaryOutputWriter = class(TObject)
  private
    FTSInfoTree: TSimpleTSInfoTree;
    FOutput: TStream;
  private
    procedure WriteStringBuffer(const ABuffer: String);
    procedure WriteBooleanBuffer(ABuffer: Boolean);
    procedure WriteUInt8Buffer(ABuffer: UInt8);
    procedure WriteUInt32Buffer(ABuffer: UInt32);
  private
    procedure WriteHeader();
    procedure WriteElements(AParentNode: TTSInfoNode);
    procedure WriteAttribute(AAttribute: TTSInfoAttribute);
    procedure WriteChildNode(AChildNode: TTSInfoNode);
  public
    constructor Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStream);
    destructor Destroy(); override;
  public
    procedure ProcessOutput();
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TTSInfoAttribute class ------------------------------------------------------------------------------------ }


constructor TTSInfoAttribute.Create(AReference: Boolean; const AName: String);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := '';
  FComment[ctDeclaration] := '';
  FComment[ctDefinition] := '';
end;


constructor TTSInfoAttribute.Create(AReference: Boolean; const AName, AValue: String; const AComment: TComment);
begin
  inherited Create();

  FReference := AReference;
  FName := AName;
  FValue := AValue;
  FComment := AComment;
end;


procedure TTSInfoAttribute.SetName(const AName: String);
begin
  FName := AName;
end;


procedure TTSInfoAttribute.SetValue(const AValue: String);
begin
  FValue := AValue;
end;


function TTSInfoAttribute.GetComment(AType: TCommentType): String;
begin
  Result := FComment[AType];
end;


procedure TTSInfoAttribute.SetComment(AType: TCommentType; const AComment: String);
begin
  FComment[AType] := AComment;
end;


{ ----- TTSInfoNode class ----------------------------------------------------------------------------------------- }


constructor TTSInfoNode.Create(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment);
begin
  inherited Create();

  FParentNode := AParentNode;
  FReference := AReference;
  FName := AName;
  FComment := AComment;

  FAttributesList := TTSInfoAttributesList.Create();
  FChildNodesList := TTSInfoNodesList.Create();
end;


destructor TTSInfoNode.Destroy();
begin
  FAttributesList.Free();
  FChildNodesList.Free();

  inherited Destroy();
end;


function TTSInfoNode.GetComment(AType: TCommentType): String;
begin
  Result := FComment[AType];
end;


procedure TTSInfoNode.SetComment(AType: TCommentType; const AComment: String);
begin
  FComment[AType] := AComment;
end;


procedure TTSInfoNode.SetName(const AName: String);
begin
  FName := AName;
end;


function TTSInfoNode.GetAttribute(const AName: String): TTSInfoAttribute;
begin
  Result := FAttributesList.GetAttribute(AName);
end;


function TTSInfoNode.GetAttribute(AIndex: Integer): TTSInfoAttribute;
begin
  Result := FAttributesList.GetAttribute(AIndex);
end;


function TTSInfoNode.GetChildNode(const AName: String): TTSInfoNode;
begin
  Result := FChildNodesList.GetChildNode(AName);
end;


function TTSInfoNode.GetChildNode(AIndex: Integer): TTSInfoNode;
begin
  Result := FChildNodesList.GetChildNode(AIndex);
end;


function TTSInfoNode.GetAttributesCount(): Integer;
begin
  Result := FAttributesList.Count;
end;


function TTSInfoNode.GetChildNodesCount(): Integer;
begin
  Result := FChildNodesList.Count;
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; const AName: String): TTSInfoAttribute;
begin
  Result := FAttributesList.AddAttribute(AReference, AName);
end;


function TTSInfoNode.CreateAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := FAttributesList.AddAttribute(AReference, AName, AValue, AComment);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; const AName: String): TTSInfoNode;
begin
  Result := FChildNodesList.AddChildNode(Self, AReference, AName);
end;


function TTSInfoNode.CreateChildNode(AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode;
begin
  Result := FChildNodesList.AddChildNode(Self, AReference, AName, AComment);
end;


procedure TTSInfoNode.RemoveAttribute(const AName: String);
begin
  FAttributesList.RemoveAttribute(AName);
end;


procedure TTSInfoNode.RemoveChildNode(const AName: String);
begin
  FChildNodesList.RemoveChildNode(AName);
end;


procedure TTSInfoNode.RemoveAllAttributes();
begin
  FAttributesList.RemoveAll();
end;

procedure TTSInfoNode.RemoveAllChildNodes();
begin
  FChildNodesList.RemoveAll();
end;


{ ----- TTSInfoAttributeToken object ------------------------------------------------------------------------------ }


function TTSInfoAttributeToken.GetComment(AType: TCommentType): String;
begin
  Result := FAttribute.Comment[AType];
end;


procedure TTSInfoAttributeToken.SetComment(AType: TCommentType; const AComment: String);
begin
  FAttribute.Comment[AType] := AComment;
end;


{ ----- TTSInfoChildNodeToken object ------------------------------------------------------------------------------ }


function TTSInfoChildNodeToken.GetComment(AType: TCommentType): String;
begin
  Result := FChildNode.Comment[AType];
end;


procedure TTSInfoChildNodeToken.SetComment(AType: TCommentType; const AComment: String);
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
  LNextNode, LNodeToDispose: PListNode;
begin
  if FOwnsElements then
    DisposeRemainingElements();

  LNodeToDispose := FFirstNode;

  while LNodeToDispose <> nil do
  begin
    LNextNode := LNodeToDispose^.NextNode;
    Dispose(LNodeToDispose);

    LNodeToDispose := LNextNode;
  end;

  FFirstNode := nil;
  FLastNode := nil;

  FLastUsedNode := nil;
  FLastUsedNodeIndex := -1;

  FCount := 0;
end;


procedure TTSInfoElementsList.DisposeRemainingElements();
var
  LCurrentNode: PListNode;
begin
  LCurrentNode := FFirstNode;

  while LCurrentNode <> nil do
  begin
    LCurrentNode^.Element.Free();
    LCurrentNode := LCurrentNode^.NextNode;
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
  LNewNode: PListNode;
begin
  LNewNode := CreateNode(AElement);

  if FCount = 0 then
  begin
    FFirstNode := LNewNode;
    FLastUsedNode := LNewNode;
    FLastUsedNodeIndex := 0;
  end
  else
  begin
    LNewNode^.PreviousNode := FLastNode;
    FLastNode^.NextNode := LNewNode;
  end;

  FLastNode := LNewNode;
  Inc(FCount);
end;


procedure TTSInfoElementsList.RemoveElement(AIndex: Integer);
var
  LNodeToDispose: PListNode;
begin
  LNodeToDispose := GetNodeAtIndex(AIndex);

  if FLastUsedNode = FLastNode then
  begin
    FLastUsedNode := FLastUsedNode^.PreviousNode;
    Dec(FLastUsedNodeIndex);
  end
  else
    FLastUsedNode := FLastUsedNode^.NextNode;

  if AIndex = 0 then
  begin
    LNodeToDispose := FFirstNode;
    FFirstNode := FFirstNode^.NextNode;

    if FFirstNode = nil then
      FLastNode := nil
    else
      FFirstNode^.PreviousNode := nil;
  end
  else
  begin
    LNodeToDispose^.PreviousNode^.NextNode := LNodeToDispose^.NextNode;

    if LNodeToDispose = FLastNode then
      FLastNode := LNodeToDispose^.PreviousNode
    else
      LNodeToDispose^.NextNode^.PreviousNode := LNodeToDispose^.PreviousNode;
  end;

  if FOwnsElements then
    LNodeToDispose^.Element.Free();

  Dispose(LNodeToDispose);
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


function TTSInfoAttributesList.InternalAddAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := TTSInfoAttribute.Create(AReference, AName, AValue, AComment);
  inherited AddElement(Result);
end;


function TTSInfoAttributesList.GetAttribute(const AName: String): TTSInfoAttribute;
var
  LAttribute: TTSInfoAttribute;
  LAttributeIdx: Integer;
begin
  for LAttributeIdx := 0 to FCount - 1 do
  begin
    LAttribute := inherited Element[LAttributeIdx] as TTSInfoAttribute;

    if SameIdentifiers(LAttribute.Name, AName) then
      Exit(LAttribute);
  end;

  Result := nil;
end;


function TTSInfoAttributesList.GetAttribute(AIndex: Integer): TTSInfoAttribute;
begin
  Result := inherited Element[AIndex] as TTSInfoAttribute;
end;


function TTSInfoAttributesList.AddAttribute(AReference: Boolean; const AName: String): TTSInfoAttribute;
begin
  Result := InternalAddAttribute(AReference, AName, '', Comment('', ''));
end;


function TTSInfoAttributesList.AddAttribute(AReference: Boolean; const AName, AValue: String; const AComment: TComment): TTSInfoAttribute;
begin
  Result := InternalAddAttribute(AReference, AName, AValue, AComment);
end;


procedure TTSInfoAttributesList.RemoveAttribute(const AName: String);
var
  LAttribute: TTSInfoAttribute;
  LAttributeIdx: Integer;
begin
  for LAttributeIdx := 0 to FCount - 1 do
  begin
    LAttribute := inherited Element[LAttributeIdx] as TTSInfoAttribute;

    if SameIdentifiers(LAttribute.Name, AName) then
    begin
      inherited RemoveElement(LAttributeIdx);
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


function TTSInfoNodesList.InternalAddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode;
begin
  Result := TTSInfoNode.Create(AParentNode, AReference, AName, AComment);
  inherited AddElement(Result);
end;


function TTSInfoNodesList.GetChildNode(const AName: String): TTSInfoNode;
var
  LNode: TTSInfoNode;
  LNodeIdx: Integer;
begin
  for LNodeIdx := 0 to FCount - 1 do
  begin
    LNode := inherited Element[LNodeIdx] as TTSInfoNode;

    if SameIdentifiers(LNode.Name, AName) then
      Exit(LNode);
  end;

  Result := nil;
end;


function TTSInfoNodesList.GetChildNode(AIndex: Integer): TTSInfoNode;
begin
  Result := inherited Element[AIndex] as TTSInfoNode;
end;


function TTSInfoNodesList.AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String): TTSInfoNode;
begin
  Result := InternalAddChildNode(AParentNode, AReference, AName, Comment('', ''));
end;


function TTSInfoNodesList.AddChildNode(AParentNode: TTSInfoNode; AReference: Boolean; const AName: String; const AComment: TComment): TTSInfoNode;
begin
  Result := InternalAddChildNode(AParentNode, AReference, AName, AComment);
end;


procedure TTSInfoNodesList.RemoveChildNode(const AName: String);
var
  LNode: TTSInfoNode;
  LNodeIdx: Integer;
begin
  for LNodeIdx := 0 to FCount - 1 do
  begin
    LNode := inherited Element[LNodeIdx] as TTSInfoNode;

    if SameIdentifiers(LNode.Name, AName) then
    begin
      inherited RemoveElement(LNodeIdx);
      Exit();
    end;
  end;
end;


procedure TTSInfoNodesList.RemoveAll();
begin
  inherited RemoveAllElements();
end;


{ ----- TTSInfoRefElementsList class ------------------------------------------------------------------------------ }


procedure TTSInfoRefElementsList.InsertElement(AIndex: Integer; AElement: TObject);
var
  LNewNode, LNodeAtIndex: PListNode;
begin
  if AIndex >= FCount then
    AddElement(AElement)
  else
  begin
    LNewNode := CreateNode(AElement);

    if AIndex = 0 then
    begin
      LNewNode^.NextNode := FFirstNode;
      FFirstNode^.PreviousNode := LNewNode;
      FFirstNode := LNewNode;
    end
    else
    begin
      LNodeAtIndex := GetNodeAtIndex(AIndex);

      LNewNode^.PreviousNode := LNodeAtIndex^.PreviousNode;
      LNewNode^.NextNode := LNodeAtIndex;

      LNodeAtIndex^.PreviousNode^.NextNode := LNewNode;
      LNodeAtIndex^.PreviousNode := LNewNode;
    end;

    FLastUsedNode := FLastUsedNode^.PreviousNode;
    Inc(FCount);
  end;
end;


function TTSInfoRefElementsList.FirstElementIsAttribute(const AMandatoryName: String): Boolean;
begin
  Result := (FFirstNode <> nil) and (FFirstNode^.Element is TTSInfoAttribute) and
            SameIdentifiers((Element[0] as TTSInfoAttribute).Name, AMandatoryName);
end;


function TTSInfoRefElementsList.FirstElementIsChildNode(const AMandatoryName: String): Boolean;
begin
  Result := (FFirstNode <> nil) and (FFirstNode^.Element is TTSInfoNode) and
            SameIdentifiers((Element[0] as TTSInfoNode).FName, AMandatoryName);
end;


function TTSInfoRefElementsList.PopFirstElement(): TObject;
begin
  Result := FFirstNode^.Element;
  RemoveElement(0);
end;


{ ----- TSimpleTSInfoTree class ----------------------------------------------------------------------------------- }


constructor TSimpleTSInfoTree.Create();
begin
  inherited Create();
  InitFields();
end;


constructor TSimpleTSInfoTree.Create(const AFileName: String; AModes: TTreeModes);
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

  FCurrentNode := FRootNode;
  FCurrentlyOpenNodePath := '';
end;


procedure TSimpleTSInfoTree.InternalLoadTreeFromList(AList: TStrings; ATree: TSimpleTSInfoTree);
begin
  with TTSInfoTextInputReader.Create(ATree, AList) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalLoadTreeFromStream(AStream: TStream; ATree: TSimpleTSInfoTree);
begin
  with TTSInfoBinaryInputReader.Create(ATree, AStream) do
  try
    ProcessInput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalSaveTreeToList(AList: TStrings; ATree: TSimpleTSInfoTree);
begin
  with TTSInfoTextOutputWriter.Create(ATree, AList) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


procedure TSimpleTSInfoTree.InternalSaveTreeToStream(AStream: TStream; ATree: TSimpleTSInfoTree);
begin
  with TTSInfoBinaryOutputWriter.Create(ATree, AStream) do
  try
    ProcessOutput();
  finally
    Free();
  end;
end;


function TSimpleTSInfoTree.FindElement(const AElementName: String; AForcePath: Boolean; AReturnAttribute: Boolean): TObject;
var
  LCurrentNode, LChildNode: TTSInfoNode;
  LNameBegin, LNameEnd, LLast: PChar;
  LPathLen: Integer;
  LName: String;
begin
  Result := nil;
  LPathLen := Length(AElementName);

  if LPathLen > 0 then
  begin
    LCurrentNode := FCurrentNode;

    SetLength(LName, 0);
    LNameBegin := @AElementName[1];
    LNameEnd := LNameBegin;
    LLast := @AElementName[LPathLen];

    while (LCurrentNode = nil) or (LNameEnd <= LLast) do
    begin
      while (LNameEnd < LLast) and (LNameEnd^ <> IDENTS_DELIMITER) do
        Inc(LNameEnd);

      if (LCurrentNode <> nil) and (LNameEnd^ = IDENTS_DELIMITER) then
      begin
        MoveString(LNameBegin^, LName, LNameEnd - LNameBegin);

        if not IsCurrentNodePath(LName) and ValidIdentifier(LName) then
        begin
          LChildNode := LCurrentNode.GetChildNode(LName);

          if (LChildNode = nil) and AForcePath then
            LChildNode := LCurrentNode.CreateChildNode(False, LName);

          LCurrentNode := LChildNode;
        end;

        Inc(LNameEnd);
        LNameBegin := LNameEnd;
      end
      else
        Break;
    end;

    if AReturnAttribute then
    begin
      if LCurrentNode <> nil then
      begin
        MoveString(LNameBegin^, LName, LNameEnd - LNameBegin + 1);

        if ValidIdentifier(LName) then
        begin
          Result := LCurrentNode.GetAttribute(LName);

          if (Result = nil) and AForcePath then
            Result := LCurrentNode.CreateAttribute(False, LName);
        end;
      end;
    end
    else
      Result := LCurrentNode;
  end;
end;


function TSimpleTSInfoTree.FindAttribute(const AAttrPath: String; AForcePath: Boolean): TTSInfoAttribute;
begin
  Result := FindElement(AAttrPath, AForcePath, True) as TTSInfoAttribute;
end;


function TSimpleTSInfoTree.FindNode(const ANodePath: String; AForcePath: Boolean): TTSInfoNode;
begin
  Result := FindElement(ANodePath, AForcePath, False) as TTSInfoNode;
end;


procedure TSimpleTSInfoTree.SetTreeName(const ATreeName: String);
begin
  if (ATreeName = '') or ValidIdentifier(ATreeName) then
  begin
    FTreeName := ATreeName;
    FModified := True;
  end;
end;


procedure TSimpleTSInfoTree.LoadFromFile(const AFileName: String; AModes: TTreeModes = []);
var
  LInputStream: TFileStream;
  LInputList: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  if tmBinaryTree in FTreeModes then
  begin
    LInputStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
    try
      InternalLoadTreeFromStream(LInputStream, Self);
    finally
      LInputStream.Free();
    end;
  end
  else
  begin
    LInputList := TStringList.Create();
    try
      LInputList.LoadFromFile(FFileName);
      InternalLoadTreeFromList(LInputList, Self);
    finally
      LInputList.Free();
    end;
  end;
end;


procedure TSimpleTSInfoTree.LoadFromList(AList: TStrings; const AFileName: String = ''; AModes: TTreeModes = []);
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();
  InternalLoadTreeFromList(AList, Self);
end;


procedure TSimpleTSInfoTree.LoadFromStream(AStream: TStream; const AFileName: String = ''; AModes: TTreeModes = []);
var
  LInputList: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  if tmBinaryTree in FTreeModes then
    InternalLoadTreeFromStream(AStream, Self)
  else
  begin
    LInputList := TStringList.Create();
    try
      LInputList.LoadFromStream(AStream);
      InternalLoadTreeFromList(LInputList, Self);
    finally
      LInputList.Free();
    end;
  end;
end;


procedure TSimpleTSInfoTree.LoadFromResource(AInstance: TFPResourceHMODULE; const AResName: String; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []);
var
  LInputStream: TResourceStream;
  LInputList: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  LInputStream := TResourceStream.Create(AInstance, AResName, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(LInputStream, Self)
    else
    begin
      LInputList := TStringList.Create();
      try
        LInputList.LoadFromStream(LInputStream);
        InternalLoadTreeFromList(LInputList, Self);
      finally
        LInputList.Free();
      end;
    end;
  finally
    LInputStream.Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadFromResource(AInstance: TFPResourceHMODULE; AResID: Integer; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []);
var
  LInputStream: TResourceStream;
  LInputList: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  LInputStream := TResourceStream.CreateFromID(AInstance, AResID, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(LInputStream, Self)
    else
    begin
      LInputList := TStringList.Create();
      try
        LInputList.LoadFromStream(LInputStream);
        InternalLoadTreeFromList(LInputList, Self);
      finally
        LInputList.Free();
      end;
    end;
  finally
    LInputStream.Free();
  end;
end;


procedure TSimpleTSInfoTree.LoadFromLazarusResource(const AResName: String; AResType: PChar; const AFileName: String = ''; AModes: TTreeModes = []);
var
  LInputStream: TLazarusResourceStream;
  LInputList: TStringList;
begin
  FFileName := AFileName;
  FTreeModes := AModes;

  ClearTree();

  LInputStream := TLazarusResourceStream.Create(AResName, AResType);
  try
    if tmBinaryTree in FTreeModes then
      InternalLoadTreeFromStream(LInputStream, Self)
    else
    begin
      LInputList := TStringList.Create();
      try
        LInputList.LoadFromStream(LInputStream);
        InternalLoadTreeFromList(LInputList, Self);
      finally
        LInputList.Free();
      end;
    end;
  finally
    LInputStream.Free();
  end;
end;


function TSimpleTSInfoTree.OpenChildNode(const ANodePath: String; AReadOnly: Boolean = False; ACanCreate: Boolean = False): Boolean;
var
  LNodeToOpen: TTSInfoNode;
  LNodePath: String;
begin
  LNodePath := IncludeTrailingIdentsDelimiter(ANodePath);

  LNodeToOpen := FindNode(LNodePath, ACanCreate and not AReadOnly);
  Result := LNodeToOpen <> nil;

  if LNodeToOpen = nil then
    ThrowException(EM_CANNOT_OPEN_NODE, [LNodePath])
  else
  begin
    if FCurrentNode <> FRootNode then
      FCurrentlyOpenNodePath += LNodePath
    else
      FCurrentlyOpenNodePath := LNodePath;

    FCurrentNode := LNodeToOpen;
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


procedure TSimpleTSInfoTree.WriteBoolean(const AAttrPath: String; ABoolean: Boolean; AFormat: TFormatBoolean = fbLongTrueFalse);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.BooleanToValue(ABoolean, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteInteger(const AAttrPath: String; AInteger: Integer; AFormat: TFormatInteger = fiUnsignedDecimal);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.IntegerToValue(AInteger, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteFloat(const AAttrPath: String; ADouble: Double; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.FloatToValue(ADouble, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteFloat(const AAttrPath: String; ADouble: Double; ASettings: TFormatSettings; AFormat: TFormatFloat = ffUnsignedGeneral);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.FloatToValue(ADouble, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteCurrency(const AAttrPath: String; ACurrency: Currency; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.CurrencyToValue(ACurrency, AFormat, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteCurrency(const AAttrPath: String; ACurrency: Currency; ASettings: TFormatSettings; AFormat: TFormatCurrency = fcUnsignedPrice);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.CurrencyToValue(ACurrency, AFormat, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteString(const AAttrPath, AString: String; AFormat: TFormatString = fsOriginal);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.StringToValue(AString, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteDateTime(const AAttrPath, AMask: String; ADateTime: TDateTime);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.DateTimeToValue(AMask, ADateTime, DefaultFormatSettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteDateTime(const AAttrPath, AMask: String; ADateTime: TDateTime; ASettings: TFormatSettings);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.DateTimeToValue(AMask, ADateTime, ASettings);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WritePoint(const AAttrPath: String; APoint: TPoint; AFormat: TFormatPoint = fpUnsignedDecimal);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      LAttribute.Value := TTSInfoDataConverter.PointToValue(APoint, AFormat);
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteList(const AAttrPath: String; AList: TStrings);
var
  LAttribute: TTSInfoAttribute;
  LValue: String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

    if LAttribute <> nil then
    begin
      TTSInfoDataConverter.ListToValue(AList, LValue);
      LAttribute.Value := LValue;
      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.WriteBuffer(const AAttrPath: String; const ABuffer; ASize: UInt32; AFormat: TFormatBuffer = fb32BytesPerLine);
var
  LAttribute: TTSInfoAttribute;
  LValue: String = '';
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
    if ASize > MAX_BUFFER_SIZE then
      ThrowException(EM_INVALID_BUFFER_SIZE, [MAX_BUFFER_SIZE])
    else
    begin
      LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

      if LAttribute <> nil then
      begin
        TTSInfoDataConverter.BufferToValue(ABuffer, ASize, LValue, AFormat);
        LAttribute.Value := LValue;
        FModified := True;
      end;
    end;
end;


procedure TSimpleTSInfoTree.WriteStream(const AAttrPath: String; AStream: TStream; ASize: UInt32; AFormat: TFormatStream = fs32BytesPerLine);
var
  LAttribute: TTSInfoAttribute;
  LBuffer: TByteDynArray;
  LValue: String = '';
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
    if AStream.Size > MAX_STREAM_SIZE then
      ThrowException(EM_INVALID_STREAM_SIZE, [MAX_STREAM_SIZE])
    else
    begin
      LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), True);

      if LAttribute <> nil then
      begin
        SetLength(LBuffer, ASize);
        AStream.Read(LBuffer[0], ASize);

        TTSInfoDataConverter.BufferToValue(LBuffer[0], ASize, LValue, TFormatBuffer(AFormat));
        LAttribute.Value := LValue;
        FModified := True;
      end;
    end;
end;


function TSimpleTSInfoTree.ReadBoolean(const AAttrPath: String; ADefault: Boolean): Boolean;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToBoolean(LAttribute.Value, ADefault);
end;


function TSimpleTSInfoTree.ReadInteger(const AAttrPath: String; ADefault: Integer): Integer;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToInteger(LAttribute.Value, ADefault);
end;


function TSimpleTSInfoTree.ReadFloat(const AAttrPath: String; ADefault: Double): Double;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToFloat(LAttribute.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadFloat(const AAttrPath: String; ADefault: Double; ASettings: TFormatSettings): Double;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToFloat(LAttribute.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadCurrency(const AAttrPath: String; ADefault: Currency): Currency;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToCurrency(LAttribute.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadCurrency(const AAttrPath: String; ADefault: Currency; ASettings: TFormatSettings): Currency;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToCurrency(LAttribute.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadString(const AAttrPath, ADefault: String; AFormat: TFormatString = fsOriginal): String;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToString(LAttribute.Value, AFormat);
end;


function TSimpleTSInfoTree.ReadDateTime(const AAttrPath, AMask: String; ADefault: TDateTime): TDateTime;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToDateTime(AMask, LAttribute.Value, DefaultFormatSettings, ADefault);
end;


function TSimpleTSInfoTree.ReadDateTime(const AAttrPath, AMask: String; ADefault: TDateTime; ASettings: TFormatSettings): TDateTime;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToDateTime(AMask, LAttribute.Value, ASettings, ADefault);
end;


function TSimpleTSInfoTree.ReadPoint(const AAttrPath: String; ADefault: TPoint): TPoint;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    Result := ADefault
  else
    Result := TTSInfoDataConverter.ValueToPoint(LAttribute.Value, ADefault);
end;


procedure TSimpleTSInfoTree.ReadList(const AAttrPath: String; AList: TStrings);
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute <> nil then
    TTSInfoDataConverter.ValueToList(LAttribute.Value, AList);
end;


procedure TSimpleTSInfoTree.ReadBuffer(const AAttrPath: String; var ABuffer; ASize: UInt32; AOffset: UInt32 = 0);
var
  LAttribute: TTSInfoAttribute;
begin
  if ASize > 0 then
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

    if LAttribute <> nil then
      TTSInfoDataConverter.ValueToBuffer(LAttribute.Value, ABuffer, ASize, AOffset);
  end;
end;


procedure TSimpleTSInfoTree.ReadStream(const AAttrPath: String; AStream: TStream; ASize: UInt32; AOffset: UInt32 = 0);
var
  LAttribute: TTSInfoAttribute;
  LBuffer: TByteDynArray;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute <> nil then
  begin
    SetLength(LBuffer, ASize);
    TTSInfoDataConverter.ValueToBuffer(LAttribute.Value, LBuffer[0], ASize, AOffset);

    AStream.Write(LBuffer[0], ASize);
  end;
end;


function TSimpleTSInfoTree.CreateAttribute(const ANodePath: String; AReference: Boolean; const AAttrName: String): Boolean;
var
  LParentNode: TTSInfoNode;
begin
  Result := ValidIdentifier(AAttrName);

  if Result then
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), True);

    Result := LParentNode <> nil;

    if Result then
    begin
      LParentNode.CreateAttribute(AReference, AAttrName);
      FModified := True;
    end;
  end;
end;


function TSimpleTSInfoTree.CreateChildNode(const ANodePath: String; AReference: Boolean; const ANodeName: String; AOpen: Boolean): Boolean;
var
  LParentNode, LNewNode: TTSInfoNode;
  strNodePath, strNodeNameAsPath: String;
  boolPathIsSymbol: Boolean;
begin
  Result := ValidIdentifier(ANodeName);

  if Result then
  begin
    strNodePath := ANodePath;
    boolPathIsSymbol := IsCurrentNodePath(strNodePath);

    if boolPathIsSymbol then
      LParentNode := FCurrentNode
    else
    begin
      strNodePath := IncludeTrailingIdentsDelimiter(ANodePath);
      LParentNode := FindNode(strNodePath, True);
    end;

    Result := LParentNode <> nil;

    if Result then
    begin
      LNewNode := LParentNode.CreateChildNode(AReference, ANodeName);

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

        FCurrentNode := LNewNode;
      end;

      FModified := True;
    end;
  end;
end;


procedure TSimpleTSInfoTree.ClearChildNode(const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LParentNode <> nil then
    begin
      LParentNode.RemoveAllAttributes();
      LParentNode.RemoveAllChildNodes();

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

    FCurrentNode := FRootNode;
    FCurrentlyOpenNodePath := '';

    FModified := True;
  end;
end;


function TSimpleTSInfoTree.FindFirstAttribute(out AAttrToken: TTSInfoAttributeToken; const AParentNodePath: String = CURRENT_NODE_SYMBOL): Boolean;
var
  LParentNode: TTSInfoNode;
begin
  if IsCurrentNodePath(AParentNodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(AParentNodePath), False);

  Result := (LParentNode <> nil) and (LParentNode.AttributesCount > 0);

  if Result then
  begin
    AAttrToken.FAttribute := LParentNode.GetAttribute(0);
    AAttrToken.FParentNode := LParentNode;
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


function TSimpleTSInfoTree.FindFirstChildNode(out ANodeToken: TTSInfoChildNodeToken; const AParentNodePath: String = CURRENT_NODE_SYMBOL): Boolean;
var
  LParentNode: TTSInfoNode;
begin
  if IsCurrentNodePath(AParentNodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(AParentNodePath), False);

  Result := (LParentNode <> nil) and (LParentNode.ChildNodesCount > 0);

  if Result then
  begin
    ANodeToken.FChildNode := LParentNode.GetChildNode(0);
    ANodeToken.FParentNode := LParentNode;
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


procedure TSimpleTSInfoTree.RenameAttributeTokens(const ANodePath, ATokenName: String; AStartIndex: Integer; ADirection: TRenamingDirection);
var
  LParentNode: TTSInfoNode;
  LAttributeToRename: TTSInfoAttribute;
  LAttributeIdx, LStep: Integer;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if (LParentNode <> nil) and ValidIdentifier(ATokenName) then
    begin
      LStep := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

      for LAttributeIdx := 0 to LParentNode.AttributesCount - 1 do
      begin
        LAttributeToRename := LParentNode.GetAttribute(LAttributeIdx);
        LAttributeToRename.Name := Format(ATokenName, [AStartIndex]);

        Inc(AStartIndex, LStep);
      end;
    end;
  end;
end;


procedure TSimpleTSInfoTree.RenameChildNodeTokens(const ANodePath, ATokenName: String; AStartIndex: Integer; ADirection: TRenamingDirection);
var
  LParentNode, LNodeToRename: TTSInfoNode;
  LNodeIdx, LStep: Integer;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if (LParentNode <> nil) and ValidIdentifier(ATokenName) then
    begin
      LStep := RENAMING_STEP_NUMERICAL_EQUIVALENTS[ADirection];

      for LNodeIdx := 0 to LParentNode.ChildNodesCount - 1 do
      begin
        LNodeToRename := LParentNode.GetChildNode(LNodeIdx);
        LNodeToRename.Name := Format(ATokenName, [AStartIndex]);

        Inc(AStartIndex, LStep);
      end;
    end;
  end;
end;


procedure TSimpleTSInfoTree.UpdateFile();
var
  LOutputStream: TFileStream;
  LOutputList: TStringList;
begin
  if tmBinaryTree in FTreeModes then
  begin
    LOutputStream := TFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
    try
      InternalSaveTreeToStream(LOutputStream, Self);
    finally
      LOutputStream.Free();
    end;
  end
  else
  begin
    LOutputList := TStringList.Create();
    try
      InternalSaveTreeToList(LOutputList, Self);
      LOutputList.SaveToFile(FFileName);
    finally
      LOutputList.Free();
    end;
  end;

  FModified := False;
end;


procedure TSimpleTSInfoTree.SwitchTreeForm();
begin
  if tmBinaryTree in FTreeModes then
    FTreeModes := FTreeModes - [tmBinaryTree] + [tmTextTree]
  else
    FTreeModes := FTreeModes + [tmBinaryTree] - [tmTextTree];
end;


procedure TSimpleTSInfoTree.SwitchTreeAccess();
begin
  if tmAccessWrite in FTreeModes then
    FTreeModes := FTreeModes - [tmAccessWrite] + [tmAccessRead]
  else
    FTreeModes := FTreeModes + [tmAccessWrite] - [tmAccessRead];
end;


{ ----- TTSInfoTree class ----------------------------------------------------------------------------------------- }


procedure TTSInfoTree.RenameAttribute(const AAttrPath, ANewAttrName: String);
var
  LParentNode: TTSInfoNode;
  LAttributeToRename: TTSInfoAttribute;
  LAttributeName, LAttributeNameOnly, LNodePath: String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttributeName := ExcludeTrailingIdentsDelimiter(AAttrPath);
    LNodePath := ExtractPathComponent(LAttributeName, pcAttributePath);

    if IsCurrentNodePath(LNodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(LNodePath, False);

    if LParentNode = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [LAttributeName])
    else
    begin
      LAttributeNameOnly := ExtractPathComponent(LAttributeName, pcAttributeName);
      LAttributeToRename := LParentNode.GetAttribute(LAttributeNameOnly);

      if LAttributeToRename = nil then
        ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [LAttributeName])
      else
        if ValidIdentifier(ANewAttrName) then
        begin
          LAttributeToRename.Name := ANewAttrName;
          FModified := True;
        end;
    end;
  end;
end;


procedure TTSInfoTree.RenameChildNode(const ANodePath, ANewNodeName: String);
var
  LNodeToRename: TTSInfoNode;
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
        LNodeToRename := FCurrentNode;
    end
    else
      LNodeToRename := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LNodeToRename = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if LNodeToRename.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_RENAME)
      else
        if ValidIdentifier(ANewNodeName) then
        begin
          LNodeToRename.Name := ANewNodeName;
          FModified := True;
        end;
  end;
end;


procedure TTSInfoTree.WriteTreeComment(const AComment, ADelimiter: String);
begin
  if ADelimiter = '' then
    FTreeComment := AComment
  else
    FTreeComment := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

  FModified := True;
end;


procedure TTSInfoTree.WriteAttributeComment(const AAttrPath, AComment, ADelimiter: String; AType: TCommentType);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

    if LAttribute = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrPath])
    else
    begin
      if ADelimiter = '' then
        LAttribute.Comment[AType] := AComment
      else
        LAttribute.Comment[AType] := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.WriteChildNodeComment(const ANodePath, AComment, ADelimiter: String; AType: TCommentType);
var
  LNode: TTSInfoNode;
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
        LNode := FCurrentNode;
    end
    else
      LNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LNode = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if LNode.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_COMMENT)
      else
      begin
        if ADelimiter = '' then
          LNode.Comment[AType] := AComment
        else
          LNode.Comment[AType] := ReplaceSubStrings(AComment, ADelimiter, VALUES_DELIMITER);

        FModified := True;
      end;
  end;
end;


function TTSInfoTree.ReadTreeComment(const ADelimiter: String): String;
begin
  Result := ReplaceSubStrings(FTreeComment, VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadAttributeComment(const AAttrPath, ADelimiter: String; AType: TCommentType): String;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrPath])
  else
    Result := ReplaceSubStrings(LAttribute.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


function TTSInfoTree.ReadChildNodeComment(const ANodePath, ADelimiter: String; AType: TCommentType): String;
var
  LNode: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_COMMENT)
    else
      LNode := FCurrentNode;
  end
  else
    LNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if LNode.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_COMMENT)
    else
      Result := ReplaceSubStrings(LNode.Comment[AType], VALUES_DELIMITER, ADelimiter);
end;


procedure TTSInfoTree.SetAttributeReference(const AAttrPath: String; AReference: Boolean);
var
  LAttribute: TTSInfoAttribute;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

    if LAttribute = nil then
      ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrPath])
    else
    begin
      LAttribute.Reference := AReference;
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.SetChildNodeReference(const ANodePath: String; AReference: Boolean);
var
  LNode: TTSInfoNode;
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
        LNode := FCurrentNode;
    end
    else
      LNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LNode = nil then
      ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
    else
      if LNode.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_SET_REFERENCE)
      else
      begin
        LNode.Reference := AReference;
        FModified := True;
      end;
  end;
end;


function TTSInfoTree.GetAttributeReference(const AAttrPath: String): Boolean;
var
  LAttribute: TTSInfoAttribute;
begin
  LAttribute := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False);

  if LAttribute = nil then
    ThrowException(EM_ATTRIBUTE_NOT_EXISTS, [AAttrPath])
  else
    Result := LAttribute.Reference;
end;


function TTSInfoTree.GetChildNodeReference(const ANodePath: String = CURRENT_NODE_SYMBOL): Boolean;
var
  LNode: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
  begin
    if FCurrentNode = FRootNode then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE)
    else
      LNode := FCurrentNode;
  end
  else
    LNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    if LNode.ParentNode = nil then
      ThrowException(EM_ROOT_NODE_GET_REFERENCE)
    else
      Result := LNode.Reference;
end;


procedure TTSInfoTree.RemoveAttribute(const AAttrPath: String);
var
  LParentNode: TTSInfoNode;
  LAttributeName, LAttributeNameOnly, LAttributePath: String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LAttributeName := ExcludeTrailingIdentsDelimiter(AAttrPath);
    LAttributePath := ExtractPathComponent(LAttributeName, pcAttributePath);

    if IsCurrentNodePath(LAttributePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(LAttributePath, False);

    if LParentNode <> nil then
    begin
      LAttributeNameOnly := ExtractPathComponent(LAttributeName, pcAttributeName);
      LParentNode.RemoveAttribute(LAttributeNameOnly);
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveChildNode(const ANodePath: String);
var
  LNodeToRemove: TTSInfoNode;
  LNodeNameOnly: String;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    LNodeToRemove := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LNodeToRemove <> nil then
      if LNodeToRemove.ParentNode = nil then
        ThrowException(EM_ROOT_NODE_REMOVE)
      else
      begin
        LNodeNameOnly := LNodeToRemove.Name;
        LNodeToRemove := LNodeToRemove.ParentNode;
        LNodeToRemove.RemoveChildNode(LNodeNameOnly);
        FModified := True;
      end;
  end;
end;


procedure TTSInfoTree.RemoveAllAttributes(const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LParentNode <> nil then
    begin
      LParentNode.RemoveAllAttributes();
      FModified := True;
    end;
  end;
end;


procedure TTSInfoTree.RemoveAllChildNodes(const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
begin
  if FReadOnly then
    ThrowException(EM_READ_ONLY_MODE_VIOLATION)
  else
  begin
    if IsCurrentNodePath(ANodePath) then
      LParentNode := FCurrentNode
    else
      LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

    if LParentNode <> nil then
    begin
      LParentNode.RemoveAllChildNodes();
      FModified := True;
    end;
  end;
end;


function TTSInfoTree.AttributeExists(const AAttrPath: String): Boolean;
begin
  Result := FindAttribute(ExcludeTrailingIdentsDelimiter(AAttrPath), False) <> nil;
end;


function TTSInfoTree.ChildNodeExists(const ANodePath: String): Boolean;
begin
  Result := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False) <> nil;
end;


function TTSInfoTree.GetAttributesCount(const ANodePath: String = CURRENT_NODE_SYMBOL): Integer;
var
  LParentNode: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LParentNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := LParentNode.GetAttributesCount();
end;


function TTSInfoTree.GetChildNodesCount(const ANodePath: String = CURRENT_NODE_SYMBOL): Integer;
var
  LParentNode: TTSInfoNode;
begin
  if IsCurrentNodePath(ANodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LParentNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    Result := LParentNode.GetChildNodesCount();
end;


procedure TTSInfoTree.ReadAttributesNames(ANames: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
  LAttributeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LParentNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for LAttributeIdx := 0 to LParentNode.AttributesCount - 1 do
      ANames.Add(LParentNode.GetAttribute(LAttributeIdx).Name);
end;


procedure TTSInfoTree.ReadAttributesValues(AValues: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
  LAttributeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LParentNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for LAttributeIdx := 0 to LParentNode.AttributesCount - 1 do
      AValues.Add(LParentNode.GetAttribute(LAttributeIdx).Value);
end;


procedure TTSInfoTree.ReadChildNodesNames(ANames: TStrings; const ANodePath: String = CURRENT_NODE_SYMBOL);
var
  LParentNode: TTSInfoNode;
  LNodeIdx: Integer;
begin
  if IsCurrentNodePath(ANodePath) then
    LParentNode := FCurrentNode
  else
    LParentNode := FindNode(IncludeTrailingIdentsDelimiter(ANodePath), False);

  if LParentNode = nil then
    ThrowException(EM_NODE_NOT_EXISTS, [ANodePath])
  else
    for LNodeIdx := 0 to LParentNode.ChildNodesCount - 1 do
      ANames.Add(LParentNode.GetChildNode(LNodeIdx).Name);
end;


procedure TTSInfoTree.ExportTreeToFile(const AFileName: String; AFormat: TExportFormat = efTextTree);
var
  LOutputStream: TStream;
  LOutputList: TStrings;
begin
  if AFormat = efBinaryTree then
  begin
    LOutputStream := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
    try
      InternalSaveTreeToStream(LOutputStream, Self);
    finally
      LOutputStream.Free();
    end;
  end
  else
  begin
    LOutputList := TStringList.Create();
    try
      InternalSaveTreeToList(LOutputList, Self);
      LOutputList.SaveToFile(AFileName);
    finally
      LOutputList.Free();
    end;
  end;
end;


procedure TTSInfoTree.ExportTreeToList(AList: TStrings);
begin
  InternalSaveTreeToList(AList, Self);
end;


procedure TTSInfoTree.ExportTreeToStream(AStream: TStream; AFormat: TExportFormat = efBinaryTree);
var
  LOutputList: TStrings;
begin
  if AFormat = efBinaryTree then
    InternalSaveTreeToStream(AStream, Self)
  else
  begin
    LOutputList := TStringList.Create();
    try
      InternalSaveTreeToList(LOutputList, Self);
      LOutputList.SaveToStream(AStream);
    finally
      LOutputList.Free();
    end;
  end;
end;


{ ----- TTSInfoTextInputReader class ------------------------------------------------------------------------------ }


constructor TTSInfoTextInputReader.Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStrings);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;

  FInput := TStringList.Create();
  FInput.Assign(AInput);

  FRefElements := TTSInfoRefElementsList.Create(False);

  FComment := '';
end;


destructor TTSInfoTextInputReader.Destroy();
begin
  FTSInfoTree := nil;

  FInput.Free();
  FRefElements.Free();

  inherited Destroy();
end;


procedure TTSInfoTextInputReader.RemoveBOMSignature();
const
  UTF8_BOM_SIGNATURE     = String(#239#187#191);
  UTF8_BOM_SIGNATURE_LEN = Length(UTF8_BOM_SIGNATURE);
var
  LFirstLine: String;
begin
  if FInput.Count > 0 then
  begin
    LFirstLine := FInput[0];

    if (LFirstLine <> '') and (CompareByte(LFirstLine[1], UTF8_BOM_SIGNATURE[1], UTF8_BOM_SIGNATURE_LEN) = 0) then
    begin
      Delete(LFirstLine, 1, UTF8_BOM_SIGNATURE_LEN);
      FInput[0] := LFirstLine;
    end;
  end;
end;


procedure TTSInfoTextInputReader.RemoveWhitespace();
var
  LLine: String;
  LLineIdx: Integer;
begin
  for LLineIdx := FInput.Count - 1 downto 0 do
  begin
    LLine := RemoveWhitespaceChars(FInput[LLineIdx]);

    if LLine = '' then
      FInput.Delete(LLineIdx)
    else
      FInput[LLineIdx] := LLine;
  end;
end;


procedure TTSInfoTextInputReader.DetermineLineIndexes();
begin
  FEndTreeLineIndex := FInput.IndexOf(KEYWORD_TREE_END);

  if FEndTreeLineIndex = -1 then
    ThrowException(EM_MISSING_END_TREE_LINE);

  FLineIndex := 0;
end;


procedure TTSInfoTextInputReader.ProcessMainTreeComment();
begin
  if (FLineIndex < FInput.Count) and IsCommentLine(FInput[FLineIndex]) then
  begin
    ExtractComment();

    FTSInfoTree.FTreeComment := FComment;
    ClearComment();
  end;
end;


procedure TTSInfoTextInputReader.ProcessTreeHeader();
const
  SHORT_TREE_HEADER_COMPONENT_COUNT = Integer(2);
  LONG_TREE_HEADER_COMPONENT_COUNT  = Integer(4);
const
  COMPONENT_INDEX_FORMAT_VERSION = Integer(1);
  COMPONENT_INDEX_KEYWORD_NAME   = Integer(2);
  COMPONENT_INDEX_TREE_NAME      = Integer(3);
var
  LComponents: TLineComponents;
  LComponentsCnt: Integer = 0;
begin
  if (FLineIndex < FInput.Count) and IsTreeHeaderLine(FInput[FLineIndex]) then
  begin
    ExtractLineComponents(FInput[FLineIndex], LComponents, LComponentsCnt);

    if LComponentsCnt in [SHORT_TREE_HEADER_COMPONENT_COUNT, LONG_TREE_HEADER_COMPONENT_COUNT] then
    begin
      if IsFormatVersionValue(LComponents[COMPONENT_INDEX_FORMAT_VERSION]) then
      begin
        if LComponentsCnt = LONG_TREE_HEADER_COMPONENT_COUNT then
          if SameIdentifiers(LComponents[COMPONENT_INDEX_KEYWORD_NAME], KEYWORD_TREE_NAME) then
          begin
            if (LComponentsCnt = LONG_TREE_HEADER_COMPONENT_COUNT) then
              if (LComponents[COMPONENT_INDEX_TREE_NAME] <> '') and ValidIdentifier(LComponents[COMPONENT_INDEX_TREE_NAME]) then
                FTSInfoTree.FTreeName := LComponents[COMPONENT_INDEX_TREE_NAME];
          end
          else
            ThrowException(EM_UNKNOWN_TREE_HEADER_COMPONENT, [LComponents[COMPONENT_INDEX_KEYWORD_NAME]]);
      end
      else
        ThrowException(EM_INVALID_FORMAT_VERSION, [LComponents[COMPONENT_INDEX_FORMAT_VERSION]]);
    end
    else
      ThrowException(EM_INVALID_TREE_HEADER_COMPONENT_COUNT, [LComponentsCnt]);

    Inc(FLineIndex);
  end
  else
    ThrowException(EM_MISSING_TREE_HEADER);
end;


procedure TTSInfoTextInputReader.ProcessMainPart();
begin
  FStoreRefElement := @AddRefElement;
  FNestedLevel := 0;

  while FLineIndex < FEndTreeLineIndex do
    if IsCommentLine(FInput[FLineIndex])                 then ExtractComment()    else
    if IsStdAttributeLine(FInput[FLineIndex])            then AddStdAttribute()   else
    if IsStdChildNodeLine(FInput[FLineIndex])            then AddStdChildNode()   else
    if IsStdChildNodeEndLine(FInput[FLineIndex])         then CloseStdChildNode() else
    if IsRefAttributeDeclarationLine(FInput[FLineIndex]) then AddRefAttribute()   else
    if IsRefChildNodeLine(FInput[FLineIndex])            then AddRefChildNode()
    else
      ThrowException(EM_INVALID_SOURCE_LINE, [FInput[FLineIndex]]);
end;


procedure TTSInfoTextInputReader.ProcessReferencingPart();
begin
  FStoreRefElement := @InsertRefElement;

  FLineIndex := FEndTreeLineIndex + 1;
  FNestedLevel := 0;

  while FLineIndex < FInput.Count do
    if IsCommentLine(FInput[FLineIndex])                then ExtractComment()   else
    if IsRefAttributeDefinitionLine(FInput[FLineIndex]) then FillRefAttribute() else
    if IsRefChildNodeLine(FInput[FLineIndex])           then FillRefChildNode()
    else
      ThrowException(EM_INVALID_SOURCE_LINE, [FInput[FLineIndex]]);
end;


function TTSInfoTextInputReader.IsCommentLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) >= COMMENT_PREFIX_LEN) and
            (CompareByte(ALine[1], COMMENT_PREFIX[1], COMMENT_PREFIX_LEN) = 0);
end;


function TTSInfoTextInputReader.IsTreeHeaderLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) >= MIN_TREE_HEADER_LINE_LEN) and
            (CompareByte(ALine[1], TREE_HEADER_FORMAT_NAME[1], TREE_HEADER_FORMAT_NAME_LEN) = 0);
end;


function TTSInfoTextInputReader.IsFormatVersionValue(const AValue: String): Boolean;
const
  FORMAT_VERSION_INDEX_MAJOR = Integer(1);
  FORMAT_VERSION_INDEX_MINOR = Integer(3);
var
  LVersionMajor, LVersionMinor: UInt8;
  LCodeMajor, LCodeMinor: Integer;
begin
  Result := Length(AValue) = TREE_HEADER_FORMAT_VERSION_LEN;

  if Result then
  begin
    Val(AValue[FORMAT_VERSION_INDEX_MAJOR], LVersionMajor, LCodeMajor);
    Val(AValue[FORMAT_VERSION_INDEX_MINOR], LVersionMinor, LCodeMinor);

    Result := (LCodeMajor = 0) and (LCodeMinor = 0);

    if Result then
    begin
      Result := (LVersionMajor = SUPPORTED_FORMAT_VERSION_MAJOR) and (LVersionMinor <= SUPPORTED_FORMAT_VERSION_MINOR);

      if not Result then
        ThrowException(EM_UNSUPPORTED_FORMAT_VERSION, [AValue]);
    end;
  end;
end;


function TTSInfoTextInputReader.IsAttributeNameAndValueLine(const ALine: String): Boolean;
var
  LToken, LLast: PChar;
begin
  LToken := @ALine[KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE[ALine[1] = KEYWORD_REF_ATTRIBUTE[1]]] + 1;
  LLast := @ALine[Length(ALine)];

  while (LToken < LLast) and (LToken^ in WHITESPACE_CHARS) do
    Inc(LToken);

  Result := LToken^ <> QUOTE_CHAR;

  if Result then
  begin
    while (LToken < LLast) and (LToken^ <> QUOTE_CHAR) do
      Inc(LToken);

    while (LLast > LToken) and (LLast^ <> QUOTE_CHAR) do
      Dec(LLast);

    Result := (LToken < LLast) and (LLast^ = QUOTE_CHAR);
  end;
end;


function TTSInfoTextInputReader.IsStdAttributeLine(const ALine: String): Boolean;
var
  LLineLen: Integer;
begin
  Result := False;
  LLineLen := Length(ALine);

  if LLineLen >= MIN_STD_ATTRIBUTE_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_STD_ATTRIBUTE[1], KEYWORD_STD_ATTRIBUTE_LEN) = 0 then
      Result := IsAttributeNameAndValueLine(ALine);
end;


function TTSInfoTextInputReader.IsStdChildNodeLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) >= MIN_STD_NODE_LINE_LEN) and
            (CompareByte(ALine[1], KEYWORD_STD_NODE[1], KEYWORD_STD_NODE_LEN) = 0);
end;


function TTSInfoTextInputReader.IsStdChildNodeEndLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) = KEYWORD_STD_NODE_END_LEN) and
            (CompareByte(ALine[1], KEYWORD_STD_NODE_END[1], KEYWORD_STD_NODE_END_LEN) = 0);
end;


function TTSInfoTextInputReader.IsRefAttributeDeclarationLine(const ALine: String): Boolean;
var
  LToken, LLast: PChar;
  LLineLen: Integer;
begin
  Result := False;
  LLineLen := Length(ALine);

  if LLineLen >= MIN_REF_ATTRIBUTE_DEC_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_REF_ATTRIBUTE[1], KEYWORD_REF_ATTRIBUTE_LEN) = 0 then
    begin
      LToken := @ALine[KEYWORD_REF_ATTRIBUTE_LEN] + 1;
      LLast := @ALine[LLineLen];

      while (LToken < LLast) and (LToken^ in WHITESPACE_CHARS) do
        Inc(LToken);

      while (LToken <= LLast) and (LToken^ <> QUOTE_CHAR) do
        Inc(LToken);

      Result := LToken > LLast;
    end;
end;


function TTSInfoTextInputReader.IsRefAttributeDefinitionLine(const ALine: String): Boolean;
var
  LLineLen: Integer;
begin
  Result := False;
  LLineLen := Length(ALine);

  if LLineLen >= MIN_REF_ATTRIBUTE_DEF_LINE_LEN then
    if CompareByte(ALine[1], KEYWORD_REF_ATTRIBUTE[1], KEYWORD_REF_ATTRIBUTE_LEN) = 0 then
      Result := IsAttributeNameAndValueLine(ALine);
end;


function TTSInfoTextInputReader.IsRefChildNodeLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) >= MIN_REF_NODE_LINE_LEN) and
            (CompareByte(ALine[1], KEYWORD_REF_NODE[1], KEYWORD_REF_NODE_LEN) = 0);
end;


function TTSInfoTextInputReader.IsRefChildNodeEndLine(const ALine: String): Boolean;
begin
  Result := (Length(ALine) = KEYWORD_REF_NODE_END_LEN) and
            (CompareByte(ALine[1], KEYWORD_REF_NODE_END[1], KEYWORD_REF_NODE_END_LEN) = 0);
end;


function TTSInfoTextInputReader.IsValueLine(const ALine: String): Boolean;
var
  LLineLen: Integer;
begin
  LLineLen := Length(ALine);

  Result := (LLineLen >= MIN_ATTRIBUTE_VALUE_LINE_LEN) and
            (ALine[1] = QUOTE_CHAR) and (ALine[LLineLen] = QUOTE_CHAR);
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


procedure TTSInfoTextInputReader.AddStdAttribute();
var
  LNewAttribute: TTSInfoAttribute;
  LName, LValue, LNextValue: String;
  LReference: Boolean;
begin
  ExtractAttribute(FInput[FLineIndex], LReference, LName, LValue);

  if ValidIdentifier(LName) then
  begin
    LNewAttribute := FTSInfoTree.FCurrentNode.CreateAttribute(LReference, LName, '', Comment(FComment, ''));
    Inc(FLineIndex);

    while (FLineIndex < FInput.Count) and IsValueLine(FInput[FLineIndex]) do
    begin
      ExtractAttributeNextValue(FInput[FLineIndex], LNextValue);
      LValue += VALUES_DELIMITER + LNextValue;
      Inc(FLineIndex);
    end;

    LNewAttribute.Value := LValue;
    ClearComment();
  end;
end;


procedure TTSInfoTextInputReader.AddStdChildNode();
var
  LNewNode: TTSInfoNode;
  LName: String;
  LReference: Boolean;
begin
  ExtractChildNode(FInput[FLineIndex], LReference, LName);

  if ValidIdentifier(LName) then
  begin
    LNewNode := FTSInfoTree.FCurrentNode.CreateChildNode(LReference, LName, Comment(FComment, ''));
    FTSInfoTree.FCurrentNode := LNewNode;
  end;

  ClearComment();

  Inc(FNestedLevel);
  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.AddRefAttribute();
var
  LNewAttribute: TTSInfoAttribute;
  LName: String;
begin
  ExtractAttributeName(FInput[FLineIndex], LName);

  if ValidIdentifier(LName) then
  begin
    LNewAttribute := FTSInfoTree.FCurrentNode.CreateAttribute(True, LName, '', Comment(FComment, ''));
    FStoreRefElement(LNewAttribute);

    ClearComment();
    Inc(FLineIndex);
  end;
end;


procedure TTSInfoTextInputReader.AddRefChildNode();
var
  LNewNode: TTSInfoNode;
  LName: String;
begin
  ExtractChildNodeName(FInput[FLineIndex], LName);

  if ValidIdentifier(LName) then
  begin
    LNewNode := FTSInfoTree.FCurrentNode.CreateChildNode(True, LName, Comment(FComment, ''));
    FStoreRefElement(LNewNode);

    ClearComment();
    Inc(FLineIndex);
  end;
end;


procedure TTSInfoTextInputReader.CloseStdChildNode();
begin
  if FNestedLevel > 0 then
  begin
    FTSInfoTree.FCurrentNode := FTSInfoTree.FCurrentNode.ParentNode;
    Dec(FNestedLevel);
  end;

  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.CloseRefChildNode();
begin
  FNestedLevel := 0;
  Inc(FLineIndex);
end;


procedure TTSInfoTextInputReader.FillRefAttribute();
var
  LName, LValue, LNextValue: String;
  LReference: Boolean;
begin
  ExtractAttribute(FInput[FLineIndex], LReference, LName, LValue);

  if FRefElements.FirstElementIsAttribute(LName) then
  begin
    Inc(FLineIndex);

    while (FLineIndex < FInput.Count) and IsValueLine(FInput[FLineIndex]) do
    begin
      ExtractAttributeNextValue(FInput[FLineIndex], LNextValue);
      LValue += VALUES_DELIMITER + LNextValue;
      Inc(FLineIndex);
    end;

    with FRefElements.PopFirstElement() as TTSInfoAttribute do
    begin
      Comment[ctDefinition] := Self.FComment;
      Value := LValue;
    end;

    ClearComment();
  end
  else
    ThrowException(EM_MISSING_REF_ATTR_DEFINITION, [LName]);
end;


procedure TTSInfoTextInputReader.FillRefChildNode();
var
  LName: String;
begin
  FNestedRefElementsCount := 0;
  ExtractChildNodeName(FInput[FLineIndex], LName);

  if FRefElements.FirstElementIsChildNode(LName) then
  begin
    FTSInfoTree.FCurrentNode := FRefElements.PopFirstElement() as TTSInfoNode;
    FTSInfoTree.FCurrentNode.Comment[ctDefinition] := FComment;

    ClearComment();
    Inc(FLineIndex);

    while FLineIndex < FInput.Count do
      if IsCommentLine(FInput[FLineIndex])                 then ExtractComment()    else
      if IsStdAttributeLine(FInput[FLineIndex])            then AddStdAttribute()   else
      if IsStdChildNodeLine(FInput[FLineIndex])            then AddStdChildNode()   else
      if IsStdChildNodeEndLine(FInput[FLineIndex])         then CloseStdChildNode() else
      if IsRefAttributeDeclarationLine(FInput[FLineIndex]) then AddRefAttribute()   else
      if IsRefChildNodeLine(FInput[FLineIndex])            then AddRefChildNode()   else
      if IsRefChildNodeEndLine(FInput[FLineIndex])         then
      begin
        CloseRefChildNode();
        Break;
      end
      else
        ThrowException(EM_INVALID_SOURCE_LINE, [FInput[FLineIndex]]);
  end
  else
    ThrowException(EM_MISSING_REF_NODE_DEFINITION, [LName]);
end;


procedure TTSInfoTextInputReader.ClearComment();
begin
  FComment := '';
end;


procedure TTSInfoTextInputReader.ExtractComment();
var
  LLine, LValue: String;
  LLineLen: Integer;
  LFirst, LLast: PChar;
begin
  ClearComment();

  repeat
    LLine := FInput[FLineIndex];
    LLineLen := Length(LLine);
    LValue := '';

    if LLineLen > COMMENT_PREFIX_LEN then
    begin
      LFirst := @LLine[COMMENT_PREFIX_LEN] + 1;
      LLast := @LLine[LLineLen];

      if LFirst^ in WHITESPACE_CHARS then
        Inc(LFirst);

      MoveString(LFirst^, LValue, LLast - LFirst + 1);
    end;

    FComment += LValue + VALUES_DELIMITER;
    Inc(FLineIndex);
  until (FLineIndex = FInput.Count) or not IsCommentLine(FInput[FLineIndex]);

  if FComment = VALUES_DELIMITER then
    FComment := ONE_BLANK_VALUE_LINE_CHAR
  else
    SetLength(FComment, Length(FComment) - 1);
end;


procedure TTSInfoTextInputReader.ExtractLineComponents(const ALine: String; out AComponents: TLineComponents; var ACount: Integer);
var
  LLine: String;
  LComponentBegin, LComponentEnd, LValueBegin, LValueEnd, LLast: PChar;
begin
  LLine := ALine + INDENT_CHAR;
  LComponentBegin := @LLine[1];
  LLast := @LLine[Length(LLine)];

  while LComponentBegin < LLast do
  begin
    while (LComponentBegin < LLast) and (LComponentBegin^ in WHITESPACE_CHARS) do
      Inc(LComponentBegin);

    if LComponentBegin < LLast then
    begin
      LComponentEnd := LComponentBegin;

      repeat
        Inc(LComponentEnd);
      until (LComponentEnd = LLast) or (LComponentEnd^ = QUOTE_CHAR);

      if (LComponentBegin^ <> QUOTE_CHAR) or (LComponentEnd < LLast) then
      begin
        LValueBegin := LComponentBegin;
        LValueEnd := LComponentEnd - 1;

        if LValueBegin^ = QUOTE_CHAR then
        begin
          Inc(LValueBegin);

          while (LValueBegin <= LValueEnd) and (LValueBegin^ in WHITESPACE_CHARS) do
            Inc(LValueBegin);
        end;

        while (LValueEnd >= LValueBegin) and (LValueEnd^ in WHITESPACE_CHARS) do
          Dec(LValueEnd);

        SetLength(AComponents, ACount + 1);
        MoveString(LValueBegin^, AComponents[ACount], LValueEnd - LValueBegin + 1);
        Inc(ACount);
      end;

      LComponentBegin := LComponentEnd + UInt8(LComponentBegin^ = QUOTE_CHAR);
    end
  end;
end;


procedure TTSInfoTextInputReader.ExtractAttribute(const ALine: String; out AReference: Boolean; out AName, AValue: String);
var
  LName, LValueBegin, LValueEnd: PChar;
begin
  AReference := ALine[1] = KEYWORD_REF_ATTRIBUTE[1];
  LName := @ALine[KEYWORD_ATTRIBUTE_LEN_BY_REFERENCE[AReference]] + 1;

  while LName^ in WHITESPACE_CHARS do
    Inc(LName);

  LValueBegin := LName + 1;
  LValueEnd := @ALine[Length(ALine)];

  while LValueBegin^ <> QUOTE_CHAR do
    Inc(LValueBegin);

  while LValueEnd^ <> QUOTE_CHAR do
    Dec(LValueEnd);

  MoveString(PChar(LValueBegin + 1)^, AValue, LValueEnd - LValueBegin - 1);

  repeat
    Dec(LValueBegin);
  until not (LValueBegin^ in WHITESPACE_CHARS);

  MoveString(LName^, AName, LValueBegin - LName + 1);
end;


procedure TTSInfoTextInputReader.ExtractAttributeNextValue(const ALine: String; out ANextValue: String);
begin
  MoveString(ALine[2], ANextValue, Length(ALine) - 2);
end;


procedure TTSInfoTextInputReader.ExtractChildNode(const ALine: String; out AReference: Boolean; out AName: String);
var
  LNameBegin, LNameEnd: PChar;
begin
  AReference := ALine[1] = KEYWORD_REF_NODE[1];

  LNameBegin := @ALine[KEYWORD_NODE_LEN_BY_REFERENCE[AReference]] + 1;
  LNameEnd := @ALine[Length(ALine)];

  while LNameBegin^ in WHITESPACE_CHARS do
    Inc(LNameBegin);

  MoveString(LNameBegin^, AName, LNameEnd - LNameBegin + 1);
end;


procedure TTSInfoTextInputReader.ExtractAttributeName(const ALine: String; out AName: String);
var
  LNameBegin, LNameEnd: PChar;
begin
  LNameBegin := @ALine[KEYWORD_REF_ATTRIBUTE_LEN] + 1;
  LNameEnd := @ALine[Length(ALine)];

  while LNameBegin^ in WHITESPACE_CHARS do
    Inc(LNameBegin);

  MoveString(LNameBegin^, AName, LNameEnd - LNameBegin + 1);
end;


procedure TTSInfoTextInputReader.ExtractChildNodeName(const ALine: String; out AName: String);
var
  pchrNameBegin, pchrNameEnd: PChar;
begin
  pchrNameBegin := @ALine[KEYWORD_REF_NODE_LEN] + 1;
  pchrNameEnd := @ALine[Length(ALine)];

  while pchrNameBegin^ in WHITESPACE_CHARS do
    Inc(pchrNameBegin);

  MoveString(pchrNameBegin^, AName, pchrNameEnd - pchrNameBegin + 1);
end;


procedure TTSInfoTextInputReader.ProcessInput();
begin
  FTSInfoTree.FCurrentNode := FTSInfoTree.FRootNode;
  try
    try
      RemoveBOMSignature();
      RemoveWhitespace();
      DetermineLineIndexes();

      ProcessMainTreeComment();
      ProcessTreeHeader();
      ProcessMainPart();
      ProcessReferencingPart();
    except
      FTSInfoTree.DamageClear();
      raise;
    end;
  finally
    FTSInfoTree.FCurrentNode := FTSInfoTree.FRootNode;
    FTSInfoTree.FModified := False;
  end;
end;


{ ----- TTSInfoTextOutputWriter class ----------------------------------------------------------------------------- }


constructor TTSInfoTextOutputWriter.Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStrings);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FOutput := AOutput;

  FRefElements := TTSInfoRefElementsList.Create(False);
end;


destructor TTSInfoTextOutputWriter.Destroy();
begin
  FTSInfoTree := nil;
  FOutput := nil;

  FRefElements.Free();
  inherited Destroy();
end;


procedure TTSInfoTextOutputWriter.ProcessMainPart();
begin
  FStoreRefElement := @AddRefElement;
  ResetIndentation();

  AddTreeComment(FTSInfoTree.FTreeComment);
  AddTreeHeader(FTSInfoTree.FTreeName);

  IncIndentation();

  AddChildNodeAttributes(FTSInfoTree.FRootNode);
  AddChildNodeChildNodes(FTSInfoTree.FRootNode);

  AddTreeEnd();
end;


procedure TTSInfoTextOutputWriter.ProcessReferencingPart();
var
  objElement: TObject;
begin
  FStoreRefElement := @InsertRefElement;
  FExtraSpaceNeeded := True;

  ResetIndentation();

  while FRefElements.Count > 0 do
  begin
    objElement := FRefElements.PopFirstElement();

    if objElement is TTSInfoAttribute then
      AddRefAttributeDefinition(objElement as TTSInfoAttribute)
    else
      AddRefChildNodeDefinition(objElement as TTSInfoNode);
  end;
end;


procedure TTSInfoTextOutputWriter.IncIndentation();
begin
  SetLength(FIndentation, FIndentationSize + INDENT_SIZE);
  FillChar(FIndentation[FIndentationSize + 1], INDENT_SIZE, INDENT_CHAR);
  Inc(FIndentationSize, INDENT_SIZE);
end;


procedure TTSInfoTextOutputWriter.DecIndentation();
begin
  Dec(FIndentationSize, INDENT_SIZE);
  SetLength(FIndentation, FIndentationSize);
end;


procedure TTSInfoTextOutputWriter.ResetIndentation();
begin
  FIndentation := '';
  FIndentationSize := 0;
end;


procedure TTSInfoTextOutputWriter.AddComment(const AComment: String);
var
  vcComment: TValueComponents;
  intCommentLinesCnt, intCommentLineIdx: Integer;
begin
  ExtractValueComponents(AComment, vcComment, intCommentLinesCnt);

  if (intCommentLinesCnt = 1) and (vcComment[0] = ONE_BLANK_VALUE_LINE_CHAR) then
    FOutput.Add(GlueStrings('%%', [FIndentation, COMMENT_PREFIX]))
  else
    for intCommentLineIdx := 0 to intCommentLinesCnt - 1 do
      if vcComment[intCommentLineIdx] = '' then
        FOutput.Add(GlueStrings('%%', [FIndentation, COMMENT_PREFIX]))
      else
        FOutput.Add(GlueStrings('%% %', [FIndentation, COMMENT_PREFIX, vcComment[intCommentLineIdx]]));
end;


procedure TTSInfoTextOutputWriter.AddTreeComment(const ATreeComment: String);
begin
  if ATreeComment <> '' then
  begin
    AddComment(ATreeComment);
    AddEmptySpace();
  end;
end;


procedure TTSInfoTextOutputWriter.AddTreeHeader(const ATreeName: String);
var
  strHeader: String;
begin
  strHeader := GlueStrings('% %%%', [TREE_HEADER_FORMAT_NAME, QUOTE_CHAR, TREE_HEADER_FORMAT_VERSION, QUOTE_CHAR]);

  if ATreeName <> '' then
    strHeader += GlueStrings(' % %%%', [KEYWORD_TREE_NAME, QUOTE_CHAR, ATreeName, QUOTE_CHAR]);

  FOutput.Add(strHeader);
end;


procedure TTSInfoTextOutputWriter.AddTreeEnd();
begin
  FOutput.Add(KEYWORD_TREE_END);
end;


procedure TTSInfoTextOutputWriter.AddStdAttribute(AAttribute: TTSInfoAttribute);
var
  vcAttrValue: TValueComponents;
  intValueLinesCnt, intValueLineIdx: Integer;
  strValue, strValuesIndent: String;
begin
  if AAttribute.Comment[ctDeclaration] <> '' then
    AddComment(AAttribute.Comment[ctDeclaration]);

  ExtractValueComponents(AAttribute.Value, vcAttrValue, intValueLinesCnt);

  if intValueLinesCnt > 0 then
    strValue := vcAttrValue[0]
  else
    strValue := '';

  FOutput.Add(GlueStrings('%%% %%%', [FIndentation, KEYWORD_STD_ATTRIBUTE, AAttribute.Name,
                                      QUOTE_CHAR, strValue, QUOTE_CHAR]));

  if intValueLinesCnt > 1 then
  begin
    strValuesIndent := FIndentation + StringOfChar(INDENT_CHAR, KEYWORD_STD_ATTRIBUTE_LEN + UTF8Length(AAttribute.Name));

    for intValueLineIdx := 1 to intValueLinesCnt - 1 do
      FOutput.Add(GlueStrings('% %%%', [strValuesIndent, QUOTE_CHAR, vcAttrValue[intValueLineIdx], QUOTE_CHAR]));
  end;
end;


procedure TTSInfoTextOutputWriter.AddStdChildNode(AChildNode: TTSInfoNode);
begin
  if AChildNode.Comment[ctDeclaration] <> '' then
    AddComment(AChildNode.Comment[ctDeclaration]);

  FOutput.Add(GlueStrings('%%%', [FIndentation, KEYWORD_STD_NODE, AChildNode.Name]));
  IncIndentation();

  AddChildNodeAttributes(AChildNode);
  AddChildNodeChildNodes(AChildNode);

  DecIndentation();
  FOutput.Add(GlueStrings('%%', [FIndentation, KEYWORD_STD_NODE_END]));
end;


procedure TTSInfoTextOutputWriter.AddRefAttributeDeclaration(AAttribute: TTSInfoAttribute);
begin
  if AAttribute.Comment[ctDeclaration] <> '' then
    AddComment(AAttribute.Comment[ctDeclaration]);

  FOutput.Add(GlueStrings('%%%', [FIndentation, KEYWORD_REF_ATTRIBUTE, AAttribute.Name]));
end;


procedure TTSInfoTextOutputWriter.AddRefAttributeDefinition(AAttribute: TTSInfoAttribute);
var
  vcAttrValue: TValueComponents;
  intValueLinesCnt, intValueLineIdx: Integer;
  strValue, strValuesIndent: String;
  boolAttrHasComment, boolMultilineValue: Boolean;
begin
  ExtractValueComponents(AAttribute.Value, vcAttrValue, intValueLinesCnt);

  boolAttrHasComment := AAttribute.Comment[ctDefinition] <> '';
  boolMultilineValue := intValueLinesCnt > 1;

  if FExtraSpaceNeeded or boolAttrHasComment or boolMultilineValue then
    AddEmptySpace();

  FExtraSpaceNeeded := boolAttrHasComment or boolMultilineValue;

  if boolAttrHasComment then
    AddComment(AAttribute.Comment[ctDefinition]);

  if intValueLinesCnt > 0 then
    strValue := vcAttrValue[0]
  else
    strValue := '';

  FOutput.Add(GlueStrings('%% %%%', [KEYWORD_REF_ATTRIBUTE, AAttribute.Name, QUOTE_CHAR, strValue, QUOTE_CHAR]));

  if boolMultilineValue then
  begin
    strValuesIndent := StringOfChar(INDENT_CHAR, KEYWORD_REF_ATTRIBUTE_LEN + UTF8Length(AAttribute.Name));

    for intValueLineIdx := 1 to intValueLinesCnt - 1 do
      FOutput.Add(GlueStrings('% %%%', [strValuesIndent, QUOTE_CHAR, vcAttrValue[intValueLineIdx], QUOTE_CHAR]));
  end;
end;


procedure TTSInfoTextOutputWriter.AddRefChildNodeDeclaration(AChildNode: TTSInfoNode);
begin
  if AChildNode.Comment[ctDeclaration] <> '' then
    AddComment(AChildNode.Comment[ctDeclaration]);

  FOutput.Add(GlueStrings('%%%', [FIndentation, KEYWORD_REF_NODE, AChildNode.Name]));
end;


procedure TTSInfoTextOutputWriter.AddRefChildNodeDefinition(AChildNode: TTSInfoNode);
begin
  FExtraSpaceNeeded := True;
  FNestedRefElementsCount := 0;

  AddEmptySpace();

  if AChildNode.Comment[ctDefinition] <> '' then
    AddComment(AChildNode.Comment[ctDefinition]);

  FOutput.Add(GlueStrings('%%', [KEYWORD_REF_NODE, AChildNode.Name]));
  IncIndentation();

  AddChildNodeAttributes(AChildNode);
  AddChildNodeChildNodes(AChildNode);

  ResetIndentation();
  FOutput.Add(KEYWORD_REF_NODE_END);
end;


procedure TTSInfoTextOutputWriter.AddEmptySpace();
begin
  FOutput.Add('');
end;


procedure TTSInfoTextOutputWriter.AddChildNodeAttributes(AParentNode: TTSInfoNode);
var
  attrAdd: TTSInfoAttribute;
  intAttributeIdx: Integer;
begin
  for intAttributeIdx := 0 to AParentNode.AttributesCount - 1 do
  begin
    attrAdd := AParentNode.GetAttribute(intAttributeIdx);

    if attrAdd.Reference then
    begin
      AddRefAttributeDeclaration(attrAdd);
      FStoreRefElement(attrAdd);
    end
    else
      AddStdAttribute(attrAdd);
  end;
end;


procedure TTSInfoTextOutputWriter.AddChildNodeChildNodes(AParentNode: TTSInfoNode);
var
  nodeAdd: TTSInfoNode;
  intChildNodeIdx: Integer;
begin
  for intChildNodeIdx := 0 to AParentNode.ChildNodesCount - 1 do
  begin
    nodeAdd := AParentNode.GetChildNode(intChildNodeIdx);

    if nodeAdd.Reference then
    begin
      AddRefChildNodeDeclaration(nodeAdd);
      FStoreRefElement(nodeAdd);
    end
    else
      AddStdChildNode(nodeAdd);
  end;
end;


procedure TTSInfoTextOutputWriter.AddRefElement(AElement: TObject);
begin
  FRefElements.AddElement(AElement);
end;


procedure TTSInfoTextOutputWriter.InsertRefElement(AElement: TObject);
begin
  FRefElements.InsertElement(FNestedRefElementsCount, AElement);
  Inc(FNestedRefElementsCount);
end;


procedure TTSInfoTextOutputWriter.ProcessOutput();
begin
  ProcessMainPart();
  ProcessReferencingPart();
end;


{ ----- TTSInfoBinaryInputReader class ---------------------------------------------------------------------------- }


constructor TTSInfoBinaryInputReader.Create(ATSInfoTree: TSimpleTSInfoTree; AInput: TStream);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FInput := AInput;
end;


destructor TTSInfoBinaryInputReader.Destroy();
begin
  FTSInfoTree := nil;
  FInput := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryInputReader.ReadStringBuffer(out ABuffer: String);
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


procedure TTSInfoBinaryInputReader.ReadHeader();
var
  strSignature: String;
  intVersionMajor, intVersionMinor: UInt8;
begin
  SetLength(strSignature, BINARY_FILE_SIGNATURE_LEN);
  FillChar(strSignature[1], BINARY_FILE_SIGNATURE_LEN, 0);
  FInput.Read(strSignature[1], BINARY_FILE_SIGNATURE_LEN);

  if CompareByte(strSignature[1], BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN) = 0 then
  begin
    ReadUInt8Buffer(intVersionMajor);
    ReadUInt8Buffer(intVersionMinor);

    if (intVersionMajor = SUPPORTED_FORMAT_VERSION_MAJOR) and (intVersionMinor <= SUPPORTED_FORMAT_VERSION_MINOR) then
    begin
      ReadStringBuffer(FTSInfoTree.FTreeName);
      ReadStringBuffer(FTSInfoTree.FTreeComment);
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
end;


procedure TTSInfoBinaryInputReader.ReadAttribute(AAttribute: TTSInfoAttribute);
begin
  ReadBooleanBuffer(AAttribute.FReference);

  ReadStringBuffer(AAttribute.FName);
  ReadStringBuffer(AAttribute.FValue);

  ReadStringBuffer(AAttribute.FComment[ctDeclaration]);
  ReadStringBuffer(AAttribute.FComment[ctDefinition]);
end;


procedure TTSInfoBinaryInputReader.ReadChildNode(AChildNode: TTSInfoNode);
begin
  ReadBooleanBuffer(AChildNode.FReference);

  ReadStringBuffer(AChildNode.FName);
  ReadStringBuffer(AChildNode.FComment[ctDeclaration]);
  ReadStringBuffer(AChildNode.FComment[ctDefinition]);

  ReadElements(AChildNode);
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


constructor TTSInfoBinaryOutputWriter.Create(ATSInfoTree: TSimpleTSInfoTree; AOutput: TStream);
begin
  inherited Create();

  FTSInfoTree := ATSInfoTree;
  FOutput := AOutput;
end;


destructor TTSInfoBinaryOutputWriter.Destroy();
begin
  FTSInfoTree := nil;
  FOutput := nil;

  inherited Destroy();
end;


procedure TTSInfoBinaryOutputWriter.WriteStringBuffer(const ABuffer: String);
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


procedure TTSInfoBinaryOutputWriter.WriteHeader();
begin
  FOutput.Write(BINARY_FILE_SIGNATURE[1], BINARY_FILE_SIGNATURE_LEN);

  WriteUInt8Buffer(SUPPORTED_FORMAT_VERSION_MAJOR);
  WriteUInt8Buffer(SUPPORTED_FORMAT_VERSION_MINOR);

  WriteStringBuffer(FTSInfoTree.FTreeName);
  WriteStringBuffer(FTSInfoTree.FTreeComment);
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
end;


procedure TTSInfoBinaryOutputWriter.WriteAttribute(AAttribute: TTSInfoAttribute);
begin
  WriteBooleanBuffer(AAttribute.FReference);

  WriteStringBuffer(AAttribute.FName);
  WriteStringBuffer(AAttribute.FValue);

  WriteStringBuffer(AAttribute.FComment[ctDeclaration]);
  WriteStringBuffer(AAttribute.FComment[ctDefinition]);
end;


procedure TTSInfoBinaryOutputWriter.WriteChildNode(AChildNode: TTSInfoNode);
begin
  WriteBooleanBuffer(AChildNode.FReference);

  WriteStringBuffer(AChildNode.FName);
  WriteStringBuffer(AChildNode.FComment[ctDeclaration]);
  WriteStringBuffer(AChildNode.FComment[ctDefinition]);

  WriteElements(AChildNode);
end;


procedure TTSInfoBinaryOutputWriter.ProcessOutput();
begin
  WriteHeader();
  WriteElements(FTSInfoTree.FRootNode);
end;


{ ----- end implementation ---------------------------------------------------------------------------------------- }


end.

