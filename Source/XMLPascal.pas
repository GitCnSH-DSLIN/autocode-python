unit XMLPascal;

interface

uses
     XMLGenCodeRecords,
     SysConsts,
     //
     XMLDoc,XMLIntf,
     Classes,SysUtils;


//����XML�ڵ�����PASCAL����
function GenXMLToPascal(xdXML:TXMLDocument;Option:TGenOption):string;

implementation

function GenNodeToCode(Node:IXMLNode;Option:TGenOption):string;
var
     slDM      : TStringList;
     slChild   : TStringList;
     I,J       : Integer;
     sIndent   : string;
     sCaption  : string;      //�ڵ��Caption���ԣ���ȥ�������еĻ�����Ϣ
     procedure AddChildCodeWithIndent(II:Integer);
     var
          JJ   : Integer;
     begin
          //����Ӵ���
          slChild   := TStringList.Create;
          slChild.Text   := GenNodeToCode(Node.ChildNodes[II],Option);
          //
          for JJ:=0 to slChild.Count-1 do begin
               slDM.Add(sIndent+slChild[JJ]);
          end;
          //
          slChild.Destroy;
     end;
     procedure AddChildCodeWithoutIndent(II:Integer);
     var
          JJ   : Integer;
     begin
          //����Ӵ���
          slChild   := TStringList.Create;
          slChild.Text   := GenNodeToCode(Node.ChildNodes[II],Option);
          //
          for JJ:=0 to slChild.Count-1 do begin
               slDM.Add(slChild[JJ]);
          end;
          //
          slChild.Destroy;
     end;
     procedure AddSpaceLine;
     begin
          if (slDM.Count>10)and(slDM[slDM.Count-1]<>'') then begin
               slDM.Add('');
          end;
     end;
begin
     if Node.HasAttribute('Enabled') then begin
          if not Node.Attributes['Enabled'] then begin
               Result    := '';
               Exit;
          end;
     end;

     //�õ������ַ���
     if (Option.Indent=0)or(Option.Indent>12) then begin
          Option.Indent  := 5;
     end;
     sIndent   := '';
     for I:=0 to Option.Indent-1 do begin
          sIndent   := sIndent+' ';
     end;

     //�����������
     slDM := TStringList.Create;

     //�õ�sCaption
     sCaption  := Node.Attributes['Caption'];
     sCaption  := StringReplace(sCaption,#10,'',[rfReplaceAll]);
     sCaption  := Trim(StringReplace(sCaption,#13,'',[rfReplaceAll]));



     //���������Ϊע�͵�һ����
     if Option.AddCaption then begin
          if sCaption<>'' then begin
               slDM.Add('//'+sCaption);
          end;
     end;
     //���ע��
     if Option.AddComment then begin
          if Node.HasAttribute('Comment') then begin
               if Node.Attributes['Comment']<>'' then begin
                    slDM.Add('//'+Node.Attributes['Comment']);
               end;
          end;
     end;

     //���ɴ���
     case Node.Attributes['Mode'] of
          rtFile : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add(Node.Attributes['Source']);
               slDM.Add('');

               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
          end;
          rtFunc : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add(Node.Attributes['Source']);
               slDM.Add('begin');

               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithIndent(I);
               end;
               slDM.Add('end;');
               //
               if slDM[slDM.Count-1]<>'' then begin
                    slDM.Add('');
               end;
          end;

          rtBlock_Code,rtJump_Break,rtJump_Continue,rtJump_Exit : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add(Trim(Node.Attributes['Source']));

               //
               AddSpaceLine;
          end;

          rtBlock_Set : begin
               slDM.Add('//[SET_BEGIN]'+Trim(Node.Attributes['Caption'])+'--------------------');
               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
               //
               slDM.Add('//[SET_END]  '+Trim(Node.Attributes['Caption'])+'--------------------');
               AddSpaceLine;
          end;
          rtBlock_Body : begin
               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
               //
               AddSpaceLine;
          end;

          rtIF : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('if '+trim(Node.Attributes['Source'])+' then begin');

               //���YES�ӽڵ����
               AddChildCodeWithIndent(0);

               //����м䴦�����
               slDM.Add('end else begin');

               //���ELSE�ӽڵ����
               AddChildCodeWithIndent(1);

               //��ӽ�������
               slDM.Add('end;  //end of IF ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtIF_Yes,rtIF_Else : begin
               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
          end;

          rtFOR : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('for '+Trim(Node.Attributes['Source'])+' do begin');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('end;  //end of FOR ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtWhile : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('while '+Trim(Node.Attributes['Source'])+' do begin');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('end;  //end of WHILE ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtREPEAT : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('repeat');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('until '+Trim(Node.Attributes['Source']));

               //
               AddSpaceLine;
          end;

          rtCASE : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('case '+Trim(Node.Attributes['Source'])+' of');

               //����ӽڵ����(��default����)
               for I:=0 to Node.ChildNodes.Count-2 do begin
                    AddChildCodeWithIndent(I);
               end;

               //
               slDM.Add('else');

               //���default�ڵ�
               AddChildCodeWithIndent(Node.ChildNodes.Count-1);

               //��ӽ�������
               slDM.Add('end;  //end of CASE ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtCase_Item : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add(Trim(Node.Attributes['Source'])+' : begin');

               //����ӽڵ����
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithIndent(I);
               end;

               //��ӽ�������
               slDM.Add('end;  //end of CASE ITEM ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtCase_Default : begin

               //����ӽڵ����
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;

               //
               AddSpaceLine;
          end;

          rtTRY : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('try ');

               //����ӽڵ����
               AddChildCodeWithIndent(0);
               slDM.Add(Node.ChildNodes[1].Attributes['Source']);
               AddChildCodeWithIndent(1);

               //��ӽ�������
               slDM.Add('end;  //end of TRY ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtTRY_Except : begin

               //����ӽڵ����
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
               //
               AddSpaceLine;
          end;
     end;
     //slDM.Add('');  //��һ��
     //
     Result    := slDM.Text;
     //
     slDM.Destroy;
end;

function GenXMLToPascal(xdXML:TXMLDocument;Option:TGenOption):string;
begin
     //������Σ����ڵ��ǿ��е�
     xdXML.DocumentElement.Attributes['Enabled']  := True;
     Result    := GenNodeToCode(xdXML.DocumentElement,Option);
end;

end.
