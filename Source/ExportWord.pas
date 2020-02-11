unit ExportWord;

interface

uses
     //�Ա�ģ��
     SysRecords,SysConsts,SysVars,SysUnits,

     //ϵͳ
     XMLDoc,XMLIntf,
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs,OleServer, WordXP,ActiveX,

     //�������ؼ�
     GDIPAPI,GDIPOBJ;

type
  TForm_ExportWord = class(TForm)
  private
     WD : TWordDocument;
     CurConfig : TWWConfig;
     Anchor : OleVariant;
     procedure SetLastText(Text:String);
     //1 ���ƶ������
     procedure DrawPoints(Pts:array of double);
     //2 ���Ƽ�ͷ
     procedure DrawArrow(iX,iY:Single;bDown:Boolean);
     //3 �������ο�,iX,iYΪ�϶�������
     procedure DrawDiamond(iX,iY:Single;Text:String);
     //4 ����һ���
     procedure DrawBlock(iX,iY:Single;Text:String;Collapsed:Boolean);
     //5 ���ư�Բ������
     procedure DrawRoundRect(iX,iY:Single;Text:String);
     //6 ����TRY�ĸ�����״ (iX,iYΪ�ϱ����ĵ����꣬TextΪ�ı�,ModeΪ����,0:TRY,1:EXCEPT/FINALLY,3.END)
     procedure DrawTry(iX,iY:Single;Text:String;Collapsed:Boolean;Mode:Integer);
     //7 ���ƴ����
     procedure DrawCodeBlock(iX,iY,iW,iH:Single;Text:String);

     //NS��
     procedure NSDrawBlock(iX,iY,iW,iH:Single;Text:String;Collapsed:Boolean);
     //�����ı�
     procedure DrawString(S:String;Rect:TGPRectF);
     //�����ı�
     procedure DrawText(S:String;X,Y,W,H:Single);

     //ȥ�����һ����״����ɫ
     procedure ClearLastColor;
  public
     procedure ExportToWord(  Node:IXMLNode;FileName:String;Config:TWWConfig);
     procedure ExportNSToWord(Node:IXMLNode;FileName:String;Config:TWWConfig);
  end;

var
     Form_ExportWord: TForm_ExportWord;

implementation

uses Main;

{$R *.dfm}


{ TForm_ExportWord }

procedure TForm_ExportWord.DrawArrow(iX, iY: Single; bDown: Boolean);
begin
    if bDown then begin
         iY   := iY+iDeltaY/2;
         DrawPoints([iX,iY,  iX-iDeltaX,iY-iDeltaY,  iX+iDeltaX,iY-iDeltaY,  iX,iY,  iX,iY-iDeltaY]);
    end else begin
         iY   := iY-iDeltaY/2;
         DrawPoints([iX,iY,  iX-iDeltaX,iY+iDeltaY,  iX+iDeltaX,iY+iDeltaY,  iX,iY,  iX,iY+iDeltaY]);
    end;

end;

procedure TForm_ExportWord.DrawBlock(iX, iY: Single; Text: String;
  Collapsed: Boolean);
var
     BW,BH     : Single;
     iID       : Integer;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     //
     if Collapsed then begin
          iID  := 65;
     end else begin
          iID  := 61;
     end;
     with WD.Shapes.AddShape(iID,iX-BW,iY,BW*2,BH,Anchor) do begin
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          //TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 0;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;
          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphCenter;
     end;

end;

procedure TForm_ExportWord.DrawDiamond(iX, iY: Single; Text: String);
var
     BW,BH     : Single;
     I         : Integer;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     //
     with WD.Shapes.AddShape(63,iX-BW,iY,BW*2,BH*2,Anchor) do begin
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          //TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 0;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;

          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphCenter;
     end;
end;

procedure TForm_ExportWord.DrawPoints(Pts: array of double);
var
     BW,BH     : Single;
     I,iCount  : Integer;
     sa        : PSafeArray;
     vPoint    : OleVariant;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     //
     //����PSafeArray
     iCount    := Length(Pts) div 2;
     vPoint    := VarArrayCreate([0,iCount-1,0,1],VT_R4);
     for I:=0 to iCount-1 do begin
          vPoint[I,0]    := Pts[I*2];
          vPoint[I,1]    := Pts[I*2+1];
     end;
     //sa   := PSafeArray(TVarData(vPoint).VArray);

     //��������
     WD.Shapes.AddPolyline(vPoint,Anchor);
     //DC.Document.Pages[1].DrawPolyline(sa);

end;

procedure TForm_ExportWord.DrawRoundRect(iX, iY: Single; Text: String);
var
     BW,BH     : Single;
     I         : Integer;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     //
     with WD.Shapes.AddShape(69,iX-BW/2,iY,BW,BH,Anchor) do begin
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 0;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;
          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphCenter;
     end;
     //   Selection.ParagraphFormat.Alignment = wdAlignParagraphCenter
end;

procedure TForm_ExportWord.DrawTry(iX, iY: Single; Text: String;
  Collapsed: Boolean; Mode: Integer);
var
     BW,BH     : Single;
     SH,SV     : Single;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     SV   := CurConfig.SpaceVert*CurConfig.Scale;
     SH   := CurConfig.SpaceHorz*CurConfig.Scale;
     //
     case mode of
          0 : begin
               //����Try
               DrawPoints([iX-BW,iY,  iX+BW,iY,  iX+BW-BH,iY+BH,  iX-BW,iY+BH,  iX-BW,iY]);
               //
               SetLastText(Text);
               //�½���
               DrawPoints([iX,iY+BH,  iX,iY+BH+SV]);
          end;
          1 : begin
               //����except/finally
               DrawPoints([iX-BW,iY,  iX+BW-BH,iY,  iX+BW-BH-BH/2,iY+BH/2,  iX+BW-BH,iY+BH,  iX-BW,iY+BH,  iX-BW,iY]);
               //
               SetLastText(Text);
               //
               if Collapsed then begin
                    //��������
                    DrawPoints([iX-BW+5,iY,  iX-BW+5,iY+BH]);
               end;
               //�½���
               DrawPoints([iX,iY+BH,  iX,iY+BH+SV]);
          end;
          2 : begin
               //����end of Try
               DrawPoints([iX-BW,iY,  iX+BW-BH,iY,  iX+BW,iY+BH,  iX-BW,iY+BH,  iX-BW,iY]);
               //
               SetLastText(Text);
               //�½���
               DrawPoints([iX,iY+BH,  iX,iY+BH+SV]);
          end;
     end;
end;

procedure TForm_ExportWord.ExportToWord(Node:IXMLNode;FileName:String;Config:TWWConfig);
type
     TNodeWHE = record
          W,H,E     : Integer;
     end;
var
     I,J            : Integer;
     BW,BH,SH,SV    : Single;
     X,Y,W,H,E      : Single;
     xnChild        : IXMLNode;
     xnExtra        : IXMLNode;
     bTmp           : Boolean;
     iTmp           : Single;
     vName          : OleVariant;
     //
     procedure DrawNodeFlowchart(Node:IXMLNode);
     var
          II,JJ     : Integer;
     begin
          //�����򵥱����Ա�����д
          X    := Node.Attributes['X'];
          Y    := Node.Attributes['Y'];
          E    := Node.Attributes['E'];
          W    := Node.Attributes['W'];
          H    := Node.Attributes['H'];

          //
          if Node.Attributes['W']=-1 then begin
               Exit;
          end;

          //<�����ӽڵ���Ϊ0�Ľڵ�ͺ�£�Ľڵ�
          if (Node.ChildNodes.Count=0) then begin
               //�������ӿ�ڵ�(��������ת����֧)
               if (Node.Attributes['Mode']=rtBlock_Code)
                         and((Node.Attributes['ShowDetailCode']=1)or(grConfig.ShowDetailCode and (Node.Attributes['ShowDetailCode']<>2))) then begin
                    //�ڵ�(����)
                    DrawCodeBlock(X,Y,W,H-SV,Node.Attributes['Text']);
                    //�½���
                    DrawPoints([X,Y+H-SV,  X,Y+H]);
                    //
                    Exit;
               end else if not InModes(Node.Attributes['Mode'],[rtCase_Item,rtCase_Default,rtTry_Except,rtTry_Finally]) then begin
                    if InModes(_M(Node),[rtIF_Else,rtIF_Elseif]) then begin

                         //�½���
                         DrawPoints([X,Y,  X,Y+BH+SV]);
                         //
                         Exit;
                    end else begin
                         //�ڵ�(����)
                         DrawBlock(X,Y,GetNodeText(Node),False);
                         //�½���
                         DrawPoints([X,Y+BH,  X,Y+BH+SV]);
                         //
                         Exit;
                    end;
               end;
          end else if (Node.Attributes['Expanded']=False) then begin
               //������£�Ľڵ�(��������֧)
               if not InModes(Node.Attributes['Mode'],[rtCase_Item,rtCase_Default,rtTry_Except,rtTry_Finally]) then begin
                    //��£�ڵ�(����)
                    DrawBlock(X,Y,RTtoStr(Node.Attributes['Mode']),False);
                    //�½���
                    DrawPoints([X,Y+BH,  X,Y+BH+SV]);
                    //
                    Exit;
               end;
          end;
          //>


          //
          case Node.Attributes['Mode'] of
               //
               rtIF : begin
                    //���ο�
                    DrawDiamond(X,Y,Format('%s',[GetNodeText(Node)]));
                    DrawPoints([X,Y+BH*2,  X,Y+BH*2+SV]); //������
                    //���ο�����������
                    xnChild   := Node.ChildNodes[0];
                    if _M(Node.ChildNodes[1]) = rtIF_ElseIf then begin
                         DrawPoints([_X(xnChild)+BW,Y+BH,  _EL(xnChild.NextSibling),Y+BH]);
                    end else begin
                         DrawPoints([_X(xnChild)+BW,Y+BH,  _X(xnChild.NextSibling),Y+BH]);
                    end;

                    //
                    for JJ:=1 to Node.ChildNodes.Count-1 do begin
                         xnChild   := Node.ChildNodes[JJ];
                         if _M(xnChild) = rtIF_ElseIf then begin
                              //���ο�
                              DrawDiamond(_X(xnChild),_Y(xnChild)-BH*2-SV,GetNodeText(xnChild));
                              DrawPoints([_X(xnChild),_Y(xnChild)-SV,_X(xnChild),_Y(xnChild)]); //���ο�������
                              DrawPoints([_X(xnChild)+BW,_Y(xnChild)-SV-BH,_EL(xnChild.NextSibling),_Y(xnChild)-SV-BH]);  //���ο�����������

                         end else begin
                              DrawPoints([_L(xnChild),_Y(xnChild)-SV-BH,_X(xnChild),_Y(xnChild)-SV-BH]);  //����ģ�����ο�����������
                              DrawPoints([_X(xnChild),_Y(xnChild)-SV-BH,_X(xnChild),_Y(xnChild)]); //�����ο�������
                         end;
                              DrawPoints([_X(xnChild),_B(xnChild),_X(xnChild),_EB(xnChild.ParentNode)]); //ģ��������½���
                    end;

                    //�����ģ���½���
                    DrawPoints([X,Y+H-SV,_X(Node.ChildNodes.Last),Y+H-SV]);
                    //YES����½���
                    DrawPoints([X,_B(Node.ChildNodes.First),  X,Y+H]);
               end;

               //
               rtFOR : begin
                    //���ο�
                    DrawPoints([X-BW,Y,  X+W-BW-Sh-BH,Y,  X+W-BW-Sh,Y+BH/2,  X+W-BW-Sh-BH,Y+BH,  X-BW,Y+BH,  X-BW,Y]);
                    DrawText(Format('for %s',[Node.Attributes['Caption']]),X-BW,Y,W-Sh-BH/2,BH);
                    DrawPoints([X,Y+BH,  X,Y+BH+SV]);
                    //�õ��ӿ�
                    xnChild   := Node.ChildNodes.First;
                    //�˳�ѭ����
                    DrawPoints([X+W-BW-Sh,Y+BH/2,  X+W-BW,Y+BH/2,  X+W-BW,Y+H-SV,  X,Y+H-SV,  X,Y+H]);
                    DrawArrow(X+W-BW,Y+H / 2, True);
                    //����ѭ����
                    DrawPoints([X,Y+H-SV*3,  X,Y+H-SV*2,  X-BW-E,Y+H-SV*2,  X-BW-E,Y+BH/2,  X-BW,Y+BH/2]);
                    DrawArrow(X-BW-E,Y+H / 2, False);
               end;

               //
               rtWhile : begin
                    //���ο�
                    DrawDiamond(X,Y+SV,Format('%s',[GetNodeText(Node)]));
                    DrawPoints([X,Y+BH*2+SV,  X,Y+BH*2+SV*2]);
                    //�õ��ӿ�
                    xnChild   := Node.ChildNodes.First;
                    //�˳�ѭ����
                    DrawPoints([X+BW,Y+BH+SV,  X+W-BW,Y+BH+SV,  X+W-BW,Y+H-SV,  X,Y+H-SV,  X,Y+H]);
                    DrawArrow(X+W-BW,Y+H / 2, True);
                    //����ѭ����
                    DrawPoints([X,StrToFloat(xnChild.Attributes['Y'])+xnChild.Attributes['H'],
                              X,Y+H-SV*2,  X-BW-E,Y+H-SV*2,  X-BW-E,Y,  X,Y,  X,Y+SV]);
                    DrawArrow(X-BW-E,Y+H / 2, False);
               end;

               //
               rtRepeat : begin
                    //�õ��ӿ�
                    xnChild   := Node.ChildNodes.First;
                    //���ο�
                    DrawDiamond(X,StrToFloat(xnChild.Attributes['Y'])+xnChild.Attributes['H'],
                              Format('%s',[Node.Attributes['Caption']])); 
                    DrawPoints([X,StrToFloat(xnChild.Attributes['Y'])+xnChild.Attributes['H']+BH*2,
                              X,StrToFloat(xnChild.Attributes['Y'])+xnChild.Attributes['H']+BH*2+SV]);
                    //�˳�ѭ����
                    DrawPoints([X+BW,Y+H-SV*3-BH,  X+W-BW,Y+H-SV*3-BH,  X+W-BW,Y+H-SV,  X,Y+H-SV,  X,Y+H]);
                    DrawArrow(X+W-BW,Y+H-SV*2-BH/2, True);
                    //����ѭ����
                    DrawPoints([X,Y+H-SV*3,  X,Y+H-SV*2,  X-BW-E,Y+H-SV*2,  X-BW-E,Y,  X,Y,  X,Y+SV]);
                    DrawArrow(X-BW-E,Y+(H-SV*2)/2, False);
               end;

               //
               rtCase : begin
                    //�����ӿ�
                    bTmp := False; //��¼�Ƿ��������ת����һ��֧����

                    //
                    for JJ:=0 to Node.ChildNodes.Count-1 do begin
                         //�õ���Ӧ�ӿ�
                         xnChild   := Node.ChildNodes[JJ];

                         //�õ��ӿ����Ϣ
                         X    := xnChild.Attributes['X'];
                         Y    := xnChild.Attributes['Y'];
                         E    := xnChild.Attributes['E'];
                         W    := xnChild.Attributes['W'];
                         H    := xnChild.Attributes['H'];

                         //���ο�
                         DrawDiamond(X,Y-BH*2-SV*2,xnChild.Attributes['Caption']);
                         //���ο��½���
                         DrawPoints([X,Y-SV*2,  X,Y]);

                         //�����һ����ת������, ����Ҫ������ת��
                         if bTmp then begin
                              DrawPoints([X,Y-SV,  X-BW-E,Y-SV]);
                         end;
                         //
                         bTmp := False; //��¼�Ƿ��������ת����һ��֧����

                         //����ǵ�һ��֦, ���������һ�������ߵı����ڲ���
                         if J>0 then begin
                              DrawPoints([X-BW,Y-BH-SV*2,  X-BW-E,Y-BH-SV*2]);
                         end;
                         
                         //����һ���ڵ����(��),���п�����ת����һ��֧����
                         if JJ<>Node.ChildNodes.Count-1 then begin
                              //����(ֻ���Ʊ����зֽ粿��)
                              DrawPoints([X+BW,Y-BH-SV*2,  X+W-BW+SH*2,Y-BH-SV*2]);

                              if InModes(Config.Language,[loC,loCpp]) then begin
                                   //������һ���ӿ鲻����ת, �����һ����ת����һ��֧����(����λ�ڱ����ڵĲ���)
                                   if Config.Language in [loC,loCpp] then begin
                                        if xnChild.HasChildNodes then begin
                                             xnChild   := xnChild.ChildNodes.Last;
                                             if not InModes(xnChild.Attributes['Mode'],[rtJUMP_Break,rtJUMP_Continue,rtJUMP_Exit,rtJUMP_Goto]) then begin
                                                  DrawPoints([X,Y+H,  X+W-BW+SH,Y+H,  X+W-BW+SH,Y-SV,  X+W-BW+SH*2,Y-SV]);
                                                  bTmp := True;
                                             end;
                                        end else begin
                                             //�����ǰ��֧û���ӿ�,��ֱ����ת����һ��
                                             DrawPoints([X,Y,  X+W-BW+SH,Y,  X+W-BW+SH,Y-SV,  X+W-BW+SH*2,Y-SV]);
                                             bTmp := True;
                                        end;
                                   end;
                              end;
                         end else begin     //�����һ���ӿ����SWITCH�Ķ��֧��ͳһ������
                              DrawPoints([X,StrToFloat(Node.Attributes['Y'])+Node.Attributes['H']-SV,
                                        Node.Attributes['X'], StrToFloat(Node.Attributes['Y'])+Node.Attributes['H']-SV,
                                        Node.Attributes['X'], StrToFloat(Node.Attributes['Y'])+Node.Attributes['H']]);
                         end;

                         //���û�л�������ת����һ��֧����,����Ƶ���ǰ��������������ӵ���
                         if not bTmp then begin
                              DrawPoints([X,Y+H,  X,StrToFloat(Node.Attributes['Y'])+Node.Attributes['H']-SV]);
                         end;

                         //����ײ�����һ�����¼�ͷ
                         DrawArrow(X,Y+H-iDeltaY/2,True);

                    end;

                    //
               end;

               rtCase_Item,rtCase_Default : begin
                    //�����ǰ�ӿ�δչ��,�����һ��
                    if (Node.Attributes['Expanded']=False) then begin
                         if Node.HasChildNodes then begin
                              iTmp := Y;
                              DrawBlock(x,iTmp,'... ...',True);
                              //�½���
                              DrawPoints([X,iTmp+BH,  X,iTmp+BH+SV]);

                         end;
                    end ;
               end;

                    rtTry : begin
                         //����Try
                         DrawTry(X,Y,RTtoStr(Node.Attributes['Mode']),True,0);

                         //����End of Try
                         //iTmp := Y+H-BH-SV;
                         //DrawTry(X,iTmp,'TRY END',True,2);
                    end;
                    //
                    rtTry_Except,rtTry_Finally,rtTry_Else : begin
                         //����
                         DrawTry(X,Y,RTtoStr(Node.Attributes['Mode']),not Node.Attributes['Expanded'],1);
                    end;

          else

          end;
          //�ݹ�������ӽڵ�
          if Node.Attributes['Expanded'] then begin
               for II:=0 to Node.ChildNodes.Count-1 do begin
                    DrawNodeFlowchart(Node.ChildNodes[II]);
               end;
          end;
     end;
     procedure ClearNodeWHE(Node:IXMLNode);
     var
          II   : Integer;
     begin
          Node.AttributeNodes.Delete('W');
          Node.AttributeNodes.Delete('H');
          Node.AttributeNodes.Delete('E');
          for II:=0 to Node.ChildNodes.Count-1 do begin
               ClearNodeWHE(Node.ChildNodes[II]);
          end;
     end;


     function GetNodeWHE(Node:IXMLNode):TNodeWHE;
     var
          iiCode    : Integer;
          KK        : Integer;
          xnFirst   : IXMLNode;
          xnNext    : IXMLNode;
          rChild    : TNodeWHE;
          rExtra    : TNodeWHE;
     begin
          //����Ѽ����,��ֱ�ӳ����
          if Node.HasAttribute('W') then begin
               Result.W  := Node.Attributes['W'];
               Result.H  := Node.Attributes['H'];
               Result.E  := Node.Attributes['E'];
               //
               Exit;
          end else begin
               ShowMessage('Export to Visio Error when GetNodeWHE !'#13+Node.NodeName);
          end;
     end;
begin
     //<�õ�����ͼ����
     CurConfig := Config;
     BW   := Config.BaseWidth*Config.Scale;
     BH   := Config.BaseHeight*Config.Scale;
     SH   := Config.SpaceHorz*Config.Scale;
     SV   := Config.SpaceVert*Config.Scale;
     if BW=0 then begin
          BW   := 80;
     end;
     if BH=0 then begin
          BH   := 30;
     end;
     if SH=0 then begin
          SH   := 20;
     end;
     if SV=0 then begin
          SV   := 20;
     end;
     //>


     //
     WD   := TWordDocument.Create(self);
     WD.Activate;
     WD.Range.Font.Size := Round(Config.FontSize*Config.Scale);
     //WD.Range.Text := 'AutoFlowChart:Auto generate flowchart from sourcecode!' ;
     //WD.Range.InsertParagraphAfter;
     //WD.Paragraphs.Last.Range.Text := 'website: www.ezprog.com';
     //WD.Range.InsertParagraphAfter;
     //WD.Paragraphs.Last.Range.Text := 'email: support@ezprog.com';
     //WD.Range.InsertParagraphAfter;
     Anchor    := WD.Paragraphs.Last.Range;


     //--------------------------���λ�������ͼ(�˺�Ĵ���Ӧ�ܹ���)---------------------------------------------------//
     //�ݹ��������ͼ
     DrawNodeFlowchart(Node);


     //<���ƿ�ʼ�ͽ�����־
     //��ʼ��־
     X    := Node.Attributes['X'];
     Y    := SV;
     DrawRoundRect(X,Y,'START');
     //�½���
     DrawPoints([X,Y+BH,  X,Y+BH+SV]);
     //������־
     X    := Node.Attributes['X'];
     Y    := Round(StrToFloat(Node.Attributes['Y']))+Round(StrToFloat(Node.Attributes['H']));
     DrawRoundRect(X,Y,'END');
     //>

     //>��������


     //ȫѡ�У�Ȼ�����
     //WD.Shapes.SelectAll;
     //WD.Shapes.Application.Selection.ShapeRange.Group;



     //
     vName     := FileName;
     WD.SaveAs2000(vName);
     WD.Close;
     WD.Destroy;
     MessageDlg(#13#13'   ---   Export Word successfully!   ---   '#13#13,mtInformation,[mbOK],0);

end;


procedure TForm_ExportWord.ExportNSToWord(Node:IXMLNode;FileName:String;Config:TWWConfig);
type
     TNodeWHE = record
          W,H,E     : Integer;
     end;
var
     I,J            : Integer;
     BW,BH,SH,SV    : Single;
     X,Y,W,H,E      : Single;
     xnChild        : IXMLNode;
     xnExtra        : IXMLNode;
     bTmp           : Boolean;
     iTmp           : Single;
     vName          : OleVariant;
     sTxt           : String;
     function GetNodeWHE(Node:IXMLNode):TNodeWHE;
     var
          iiCode    : Integer;
          KK        : Integer;
          xnFirst   : IXMLNode;
          xnNext    : IXMLNode;
          rChild    : TNodeWHE;
          rExtra    : TNodeWHE;
     begin
          //����Ѽ����,��ֱ�ӳ����
          if Node.HasAttribute('W') then begin
               Result.W  := Node.Attributes['W'];
               Result.H  := Node.Attributes['H'];
               Result.E  := Node.Attributes['E'];
               //
               Exit;
          end else begin
               ShowMessage('Export to Visio Error when GetNodeWHE !'#13+Node.NodeName);
          end;
     end;
     //
     procedure DrawNodeNSchart(Node:IXMLNode);
     var
          II,JJ     : Integer;
          rChild    : TNodeWHE;
          rExtra    : TNodeWHE;
     begin
          //�����򵥱����Ա�����д
          X    := Node.Attributes['X'];
          Y    := Node.Attributes['Y'];
          E    := 0;//Node.Attributes['E'];
          W    := Node.Attributes['W'];
          H    := Node.Attributes['H'];

          //
          if Node.Attributes['W']=-1 then begin
               Exit;
          end;

          //
          if Node.Attributes['Mode']=rtCase_Item then begin
               sTxt := Node.Attributes['Caption'];
          end else begin
               sTxt := RTtoStr(Node.Attributes['Mode']);
          end;

          //<�����ӽڵ���Ϊ0�Ľڵ�ͺ�£�Ľڵ�
          if (Node.ChildNodes.Count=0) then begin
               //�������ӿ�ڵ�(��������ת����֧)
               if (Node.Attributes['Mode']=rtBlock_Code)
                         and((Node.Attributes['ShowDetailCode']=1)or(grConfig.ShowDetailCode and (Node.Attributes['ShowDetailCode']<>2))) then begin
                    //�ڵ�(����)
                    NSDrawBlock(X,Y,W,H,Node.Attributes['Text'],False);
                    //
                    Exit;
               end else begin
                    if not InModes(Node.Attributes['Mode'],[rtCase_Item,rtCase_Default,rtTry_Except,rtTry_Finally]) then begin
                         //�ڵ�(����)
                         NSDrawBlock(X,Y,W,H,sTxt,False);
                         //
                         Exit;
                    end;
               end;
          end else if (not Node.Attributes['Expanded']) then begin
               //������£�Ľڵ�(��������֧)
               if not InModes(Node.Attributes['Mode'],[rtCase_Item,rtCase_Default,rtTry_Except,rtTry_Finally]) then begin
                    //��£�ڵ�(����)
                    NSDrawBlock(X,Y,W,H,sTxt,False);
                    //
                    Exit;
               end;
          end;
          //>

          //
          case Node.Attributes['Mode'] of
               //
               rtIF : begin
                    xnChild   := Node.ChildNodes[0];
                    rChild    := GetNodeWHE(xnChild);
                    //�������
                    DrawPoints([X,Y,  X+W,Y,  X+W,Y+BH,  X,Y+BH,  X,Y, X+rChild.W,Y+BH, X+W,Y]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y,rChild.W*2,BH),oFormat,oFontBrh);
               end;

               //
               rtFOR : begin
                    //�������
                    DrawPoints([X,Y+H,  X,Y,  X+W,Y,  X+W,Y+H,  X+W-SH,Y+H]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;

               //
               rtWhile : begin
                    //�������
                    DrawPoints([X+SH,Y+H,  X,Y+H,  X,Y,  X+W,Y,  X+W,Y+BH]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;

               //
               rtRepeat : begin
                    //�������
                    DrawPoints([X+W-SH,Y,  X+W,Y,  X+W,Y+H,  X,Y+H,  X,Y+H-H]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y+H-BH,W,BH),oFormat,oFontBrh);
               end;

               //
               rtCase : begin
                    //����
                    DrawPoints([X,Y,  X+W,Y,  X+W,Y+BH,  X,Y+BH,  X,Y]);
                    //д����
                    SetLastText(sTxt);
                    //����б��
                    DrawPoints([X,Y,  X+BH,Y+BH]);
                    DrawPoints([X+W,Y,  X+W-BH,Y+BH]);
                    //oGraph.DrawString(sTxt+' '+Node.Attributes['Caption'],-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;

               rtCase_Item,rtCase_Default : begin
                    //�������
                    DrawPoints([X,Y,  X+W,Y,  X+W,Y+BH,  X,Y+BH,  X,Y]);
                    //���ӿ�Ŀ�
                    DrawPoints([X,Y,  X+W,Y,  X+W,Y+H,  X,Y+H,  X,Y]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(Node.Attributes['Caption'],-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;

               //
               rtTry : begin
                    //�������
                    DrawPoints([X,Y,  X+W,Y,  X+W,Y+H,  X,Y+H,  X,Y]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;
               //
               rtTry_Except,rtTry_Finally : begin
                    //�������
                    DrawPoints([X+W,Y,  X+W,Y+BH]);
                    //���ӿ�Ŀ�
                    DrawPoints([X,Y+BH,  X+W,Y+BH,  X+W,Y+H,  X,Y+H,  X,Y+BH]);
                    //д����
                    SetLastText(sTxt);
                    //oGraph.DrawString(sTxt,-1,oFontB,MakeRect(X,Y,W,BH),oFormat,oFontBrh);
               end;
          else

          end;
          //>

          //�ݹ�������ӽڵ�
          if Node.Attributes['Expanded'] then begin
               for II:=0 to Node.ChildNodes.Count-1 do begin
                    DrawNodeNSchart(Node.ChildNodes[II]);
               end;
          end;
     end;

begin

     //<�õ�����ͼ����
     CurConfig := Config;
     BW   := Config.BaseWidth*Config.Scale;
     BH   := Config.BaseHeight*Config.Scale;
     SH   := Config.SpaceHorz*Config.Scale;
     SV   := Config.SpaceVert*Config.Scale;
     if BW=0 then begin
          BW   := 80;
     end;
     if BH=0 then begin
          BH   := 30;
     end;
     if SH=0 then begin
          SH   := 20;
     end;
     if SV=0 then begin
          SV   := 20;
     end;
     //>

     //
     WD   := TWordDocument.Create(self);

     WD.Activate;
     WD.Range.Font.Size := Round(Config.FontSize*Config.Scale);
     //WD.Range.Text := 'AutoFlowChart:Auto generate flowchart from sourcecode!' ;
     //WD.Range.InsertParagraphAfter;
     //WD.Paragraphs.Last.Range.Text := 'website: www.ezprog.com';
     //WD.Range.InsertParagraphAfter;
     //WD.Paragraphs.Last.Range.Text := 'email: support@ezprog.com';
     //WD.Range.InsertParagraphAfter;
     Anchor    := WD.Paragraphs.Last.Range;



     //---------------------------------��������--------------------------------------------------//
     //<���ƿ�ʼ�ͽ�����־
     //��ʼ��־
     X    := Node.Attributes['X']+0+Node.Attributes['W'] / 2;
     Y    := SV;
     DrawRoundRect(X,Y,'START');
     //�½���
     DrawPoints([X,Y+BH,  X,Y+BH+SV]);
     //������־
     X    := Node.Attributes['X']+0+Node.Attributes['W'] / 2;
     Y    := Node.Attributes['Y']+0+Node.Attributes['H']+SV;
     //�½���
     DrawPoints([X,Y-SV,  X,Y]);
     DrawRoundRect(X,Y,'END');
     //>

     //�ݹ��������ͼ
     DrawNodeNSchart(Node);
     //��������

     //
     vName     := FileName;

     //ȫ�����
     WD.Shapes.SelectAll;
     WD.Shapes.Application.Selection.ShapeRange.Group;

     //
     WD.SaveAs2000(vName);
     WD.Close;
     WD.Destroy;
     MessageDlg(#13#13'   ---   Export Word successfully!   ---   '#13#13,mtInformation,[mbOK],0);

end;

procedure TForm_ExportWord.SetLastText(Text: String);
var
     iCount    : OleVariant;
     iX,iY     : Single;
     iW,iH     : Single;
begin
     //
     iCount    := WD.Shapes.Count;
     iX   := WD.Shapes.Item(iCount).Left;
     iY   := WD.Shapes.Item(iCount).Top;
     iW   := WD.Shapes.Item(iCount).Width;
     iH   := WD.Shapes.Item(iCount).Height;

     //
     //with WD.Shapes.AddLabel(1,iX,iY,iW,iH,Anchor) do begin
     with WD.Shapes.AddShape(61,iX+1,iY+1,iW-2,iH-2,Anchor) do begin
          Line.Visible   := 0;
          Fill.Transparency   := 0.6;
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 0;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;
          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphCenter;
     end;

end;

procedure TForm_ExportWord.NSDrawBlock(iX, iY, iW, iH: Single;Text:String;Collapsed:Boolean);
var
     BW,BH     : Single;
     iID       : Integer;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     //
     iID  := 61;
     with WD.Shapes.AddShape(iID,iX,iY,iW,iH,Anchor) do begin
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          //TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 0;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;
          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphCenter;
     end;
end;

procedure TForm_ExportWord.DrawString(S: String; Rect: TGPRectF);
begin
     NSDrawBlock(Rect.X,Rect.Y,Rect.Width,Rect.Height,S,False);
     ClearLastColor;
end;

procedure TForm_ExportWord.ClearLastColor;
var
     iCount    : OleVariant;
begin
     //
     iCount    := WD.Shapes.Count;

     //with WD.Shapes.AddLabel(1,iX,iY,iW,iH,Anchor) do begin
     with WD.Shapes.Item(iCount) do begin
          Line.Visible   := 0;
          Fill.Visible   := 0;
     end;
end;

procedure TForm_ExportWord.DrawText(S: String; X, Y, W, H: Single);
begin
     NSDrawBlock(X,Y,W,H,S,False);
     ClearLastColor;
end;

procedure TForm_ExportWord.DrawCodeBlock(iX, iY, iW, iH: Single; Text: String);
var
     BW,BH,SV  : Single;
     iID       : Integer;
begin
     BW   := CurConfig.BaseWidth*CurConfig.Scale;
     BH   := CurConfig.BaseHeight*CurConfig.Scale;
     SV   := CurConfig.SpaceVert*CurConfig.Scale;
     //
     iID  := 61;
     with WD.Shapes.AddShape(iID,iX-BW,iY,iW,iH,Anchor) do begin
          TextFrame.TextRange.Font.Color     := CurConfig.FontColor;
          TextFrame.TextRange.Font.Size      := CurConfig.FontSize*CurConfig.Scale*0.8;
          TextFrame.TextRange.Font.Name      := CurConfig.FontName;
          //TextFrame.TextRange.Font.Bold      := 1;
          TextFrame.TextRange.Text           := Text;
          TextFrame.MarginLeft               := 5;
          TextFrame.MarginTop                := 0;
          TextFrame.MarginRight              := 0;
          TextFrame.MarginBottom             := 0;
          TextFrame.TextRange.Paragraphs.Format.Alignment   := wdAlignParagraphLeft;
     end;
end;

end.