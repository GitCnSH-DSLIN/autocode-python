unit XMLPhython;

interface

uses
     XMLGenCodeRecords,
     SysConsts,
     //
     XMLDoc,XMLIntf,
     Classes,SysUtils;


//����XML�ڵ�����C/Cpp����
function GenXMLToPhython(xdXML:TXMLDocument;Option:TGenOption):string;

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
     //�����ǰ�ڵ㲻ʹ�ܣ������ɴ���
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
               slDM.Add('# '+sCaption);
          end;
     end;
     //���ע��
     if Option.AddComment then begin
          if Node.HasAttribute('Comment') then begin
               if Node.Attributes['Comment']<>'' then begin
                    slDM.Add('# '+Node.Attributes['Comment']);
               end;
          end;
     end;

     //���ɴ���
     case Node.Attributes['Mode'] of
          rtFile : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('');

               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
          end;
          rtFunc : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('def '+Node.Attributes['Caption']+':');

               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithIndent(I);
               end;
               //
               if slDM[slDM.Count-1]<>'' then begin
                    slDM.Add('');
               end;
          end;

          rtBlock_Code,rtJump_Break,rtJump_Continue,rtJump_Exit : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add(Node.Attributes['Source']);

               //
               AddSpaceLine;
          end;

          rtBlock_Set,rtBlock_Body : begin
               //����Ӵ���
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithoutIndent(I);
               end;
               //
               AddSpaceLine;
          end;

          rtIF : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('if ('+Node.Attributes['Source']+')');
               slDM.Add('{');

               //���YES�ӽڵ����
               AddChildCodeWithIndent(0);

               //����м䴦�����
               slDM.Add('}');
               slDM.Add('else');
               slDM.Add('{');

               //���ELSE�ӽڵ����
               AddChildCodeWithIndent(1);

               //��ӽ�������
               slDM.Add('};  //end of IF ['+sCaption+']');

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
               slDM.Add('for ('+Node.Attributes['Source']+')');
               slDM.Add('{');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('};  //end of FOR ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtWhile : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('while ('+Node.Attributes['Source']+')');
               slDM.Add('{');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('};  //end of WHILE ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtREPEAT : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('do');
               slDM.Add('{');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //��ӽ�������
               slDM.Add('} while ('+Node.Attributes['Source']+');');

               //
               AddSpaceLine;
          end;

          rtCASE : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('switch ('+Node.Attributes['Source']+')');
               slDM.Add('{');

               //����ӽڵ����(��default����)
               for I:=0 to Node.ChildNodes.Count-2 do begin
                    AddChildCodeWithIndent(I);
               end;

               //
               slDM.Add(sIndent+'default :');

               //���default�ڵ�
               AddChildCodeWithIndent(Node.ChildNodes.Count-1);

               //��ӽ�������
               slDM.Add('};  //end of switch ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtCase_Item : begin
               //��ӵ�ǰ�ڵ����
               slDM.Add('case '+Node.Attributes['Source']+' : ');
               slDM.Add('{');

               //����ӽڵ����
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithIndent(I);
               end;

               //��ӽ�������
               slDM.Add('};  //end of CASE ITEM ['+sCaption+']');

               //
               AddSpaceLine;
          end;

          rtCase_Default : begin

               //����ӽڵ����
               for I:=0 to Node.ChildNodes.Count-1 do begin
                    AddChildCodeWithIndent(I);
               end;

               //
               AddSpaceLine;
          end;

          rtTRY : begin

               //��ӵ�ǰ�ڵ����
               slDM.Add('TRY ');
               slDM.Add('{');

               //����ӽڵ����
               AddChildCodeWithIndent(0);

               //Catch
               slDM.Add('CATCH ('+Node.ChildNodes[1].Attributes['Source']+')');
               slDM.Add('{');

               //
               AddChildCodeWithIndent(1);

               //��ӽ�������
               slDM.Add('};  //end of TRY ['+sCaption+']');

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

function GenXMLToPhython(xdXML:TXMLDocument;Option:TGenOption):string;
begin
     //������Σ����ڵ��ǿ��е�
     xdXML.DocumentElement.Attributes['Enabled']  := True;
     Result    := GenNodeToCode(xdXML.DocumentElement,Option);
end;

end.
