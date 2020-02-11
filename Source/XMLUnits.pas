unit XMLUnits;

interface

uses
     XMLDoc,XMLIntf,Classes,
     Dialogs,Variants;

procedure CopyXMLNode(Source,Dest:IXMLNode); //�ݹ鸴��XML�ڵ�

procedure CopyXMLNodeFromText(Dest:IXMLNode;Text:WideString);   //��Դ�ڵ��Text�еõ�Ŀ��ڵ�����Ժ��ӽڵ�

function  GetXMLNodeIndex(Node:IXMLNode):Integer; //ȡ�ýڵ�Index

implementation

procedure CopyXMLNodeFromText(Dest:IXMLNode;Text:WideString);   //��Դ�ڵ��Text�еõ�Ŀ��ڵ�����Ժ��ӽڵ�
var
     xdXML     : IXMLDocument;
     ssText    : TStringStream;
begin
     //����XML
     ssText    := TStringStream.Create(Text);
     xdXML     := TXMLDocument.Create(nil);
     xdXML.Active   := True;
     xdXML.LoadFromStream(ssText);
     ssText.Destroy;

     //���ƽڵ�
     CopyXMLNode(xdXML.DocumentElement,Dest);

     //
     xdXML     := nil;

end;

function  GetXMLNodeIndex(Node:IXMLNode):Integer; //ȡ�ýڵ�Index
var
     I    : Integer;
begin
     Result    := -1;
     for I:=0 to Node.ParentNode.ChildNodes.Count-1 do begin
          if Node.ParentNode.ChildNodes[I]=Node then begin
               Result    := I;
               Break;
          end;
     end;
end;


procedure CopyXMLNode(Source,Dest:IXMLNode); //�ݹ鸴��XML�ڵ�
var
     I,J       : Integer;
     xnNew     : IXMLNode;
     sName     : string;
     sValue    : string;
begin

     //��������
     for I:=0 to Source.AttributeNodes.Count-1 do begin
          sName     := Source.AttributeNodes[I].NodeName;
          if Source.AttributeNodes[I].NodeValue=null then begin
               sValue    := '';
          end else begin
               sValue    := Source.AttributeNodes[I].NodeValue;
          end;
          Dest.Attributes[sName]   := sValue;
     end;


     //�����ӽڵ�
     for I:=0 to Source.ChildNodes.Count-1 do begin
          xnNew     := Dest.AddChild(Source.ChildNodes[I].NodeName);
          CopyXMLNode(Source.ChildNodes[I],Dest.ChildNodes[I]);
     end;
end;

end.
