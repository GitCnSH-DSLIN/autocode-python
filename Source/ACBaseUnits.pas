unit ACBaseUnits;

interface

uses
     //
     SysConsts,

     //
     XMLDoc,XMLIntf,SysUtils,ComCtrls;

function  GetXMLNodeFromTreeNode(XML:TXMLDocument;Node:TTreeNode):IXMLNode;       //�����ڵ㣬�õ���Ӧ��XML�ڵ�
function  InModes(Source:Integer;Ints:array of Integer):Boolean;
function  GetTreeNodeFromXMLNode(TV:TTreeView;Node:IXMLNode):TTreeNode;


implementation

function  InModes(Source:Integer;Ints:array of Integer):Boolean;
var
     I    : Integer;
begin
     Result    := False;
     for I:=0 to High(Ints) do begin
          if Source=Ints[I] then begin
               Result    := True;
               break;
          end;
     end;
end;





function  GetTreeNodeFromXMLNode(TV:TTreeView;Node:IXMLNode):TTreeNode;
var
     iIDs      : array of Integer; //���ڱ���Index����
     //
     I,J,iHigh : Integer;
     xnPar     : IXMLNode;
     iIndex    : Integer;
begin
     try
          //Ĭ��
          Result    := nil;

          //�õ�Index����
          SetLength(iIDs,0);
          while Node.ParentNode<>nil do begin
               //
               xnPar     := Node.ParentNode;

               //
               if xnPar = nil then begin
                    Break;
               end;

               //�õ���ǰ�ڵ��ڸ��ڵ��Index
               iIndex    := 0;
               for I:=0 to xnPar.ChildNodes.Count-1 do begin
                    if xnPar.ChildNodes[I]=Node then begin
                         iIndex    := I;
                         Break;
                    end;
               end;

               //���浽����
               SetLength(iIDs,Length(iIDs)+1);
               iIDs[High(iIDs)]    := iIndex;

               //
               Node := Node.ParentNode;
          end;

          //�õ��ڵ�
          Result    := TV.Items[0];
          for I:=High(iIDs)-1 downto 0 do begin
               Result    := Result.Item[iIDs[I]];
          end;
     except

     end;
end;

function  GetXMLNodeFromTreeNode(XML:TXMLDocument;Node:TTreeNode):IXMLNode;
var
     iIDs      : array of Integer; //���ڱ���Index����
     //
     I,J,iHigh : Integer;
begin
     //Ĭ��
     Result    := nil;

     //�õ�Index����
     SetLength(iIDs,0);
     while Node.Level>0 do begin
          SetLength(iIDs,Length(iIDs)+1);
          iIDs[High(iIDs)]    := Node.Index;
          //
          Node := Node.Parent;
     end;

     //�õ��ڵ�
     Result    := XML.DocumentElement;
     for I:=High(iIDs) downto 0 do begin
          Result    := Result.ChildNodes[iIDs[I]];
     end;
end;


end.
