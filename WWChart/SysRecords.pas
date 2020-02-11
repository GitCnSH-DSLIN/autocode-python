unit SysRecords;

interface

uses
     Types,Classes,Graphics;

type
     //������/�ؼ���
     TWWWord = packed record
          Mode      : SmallInt;         //����
          BegPos    : LongInt;          //��ʼλ��
          EndPos    : LongInt;          //����λ��
          LinkID    : LongInt;          //�������Wordλ��
     end;
     TWWWords = array of TWWWord;


     //�����
     TWWBlock = packed record
          Mode      : SmallInt;         //����
          BegPos    : LongInt;          //��ʼλ��
          EndPos    : LongInt;          //����λ��
          Parent    : Integer;          //���ڵ�ID
          ChildIDs  : TIntegerDynArray; //�ӿ�ID����
          Status    : Integer;          //״̬, 0:չ��,1:��£
          BegMode   : Integer;
          EndMode   : Integer;
          LastMode  : Integer;          //���һ����(��ע��)������
          //LostBeg   : Integer;
          //LostEnd   : integer;
     end;
     TWWBlocks = array of TWWBlock;

     //��ͼ�Ļ�������
     TWWConfig = record
          Language       : Byte;        //����
          Indent         : Byte;        //����
          RightMargin    : Word;
          //
          BaseWidth      : Integer;     //�������
          BaseHeight     : Integer;     //�����߶�
          AutoSize       : Boolean;     //�Ƿ��Զ�����
          MaxWidth       : Integer;     //�����
          MaxHeight      : Integer;     //���߶�
          SpaceVert      : Integer;     //������
          SpaceHorz      : Integer;     //������
          FontName       : String;
          FontSize       : Byte;
          FontColor      : TColor;
          LineColor      : TColor;
          FillColor      : TColor;
          IFColor        : TColor;
          TryColor       : TColor;
          SelectColor    : TColor;
          Scale          : Single;      //����,Ĭ��Ϊ-1
          ShowDetailCode : Boolean;     //��ʾ��ϸ����,Ĭ��ΪTrue
          //
          ChartType      : Byte;        //0:FlowChart, 1: NSChart
          AddCaption     : Boolean;     //���ɴ���ʱ�Զ���Caption����Ϊע��
          AddComment     : Boolean;     //���ɴ���ʱ�Զ�����ע��
     end;


     TWWCode = record
          Mode      : Integer;
          Exts      : String;           //��׺���б�,�ö��ŷֿ�,����:"c,cpp"

     end;
     //
     PBlockInfo = ^TBlockInfo;
     TBlockInfo = packed record
          FileName  : WideString;  //�ļ�����, ��Ҫ���ڽ�������
          //
          Text      : WideString;  //��ʾ�ı�
          ID        : Integer;     //����BlocksʱIndex
          BegEndID  : Integer;     //�������,Begin...end��ID,�����0,����Ϊ-1
          LastMode  : Integer;     //��β������(��ע��),����ճ��/�½��ṹ
          Mode      : SmallInt;    //�ڵ�����
          BegPos    : Integer;     //��ʼλ��
          EndPos    : Integer;     //����λ��
          ExtraBeg  : Integer;     //����������ʼλ��, ����ɾ������ʱʹ��
          ExtraEnd  : Integer;     //
          Status    : Byte;        //�ڵ�״̬, Ŀǰ������ʾչ������
          //����ͼ����
          X,Y,W,H,E : Single;      //X,Yλ��,W,H��С,E�������ı߾�
     end;
     TSearchOption = record
          Keyword             : String;
          AtOnce              : Boolean;
          Mode                : Integer;
          FindInFiles         : Boolean;
          ForwardDirection    : Boolean;
          FromCursor          : Boolean;
          CaseSensitivity     : Boolean;
          WholeWord           : Boolean;
          CaptionOnly         : Boolean;
          RegularExpression   : Boolean;
     end;
     TBlockCopyMode = record
          Source    : Byte;   //0:��ʾԭ������,1:���Ƶ�Block_Set
          AddMode   : Byte;   //0:��ʾNext, 1: Before,  2: LastChild, 3.Prev of LastChild
                              //4: RootAppend, 5: FunctionAppend
     end;


implementation

end.
 