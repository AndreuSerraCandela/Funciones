page 50009 "Saldo Interempresas det"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Saldo Interempresa";
    Permissions = tabledata 17 = rimd;

    layout
    {
        area(Content)
        {

            group(Filtros)
            {

                field("Filtro Fecha"; FiltroFecha)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    BEGIN
                        Rec.SetFilter("Filtro Fecha", FiltroFecha);
                        calcular(false, '', FiltroFecha);
                        CurrPage.UPDATE(FALSE);
                    END;
                }
                field(T; T)
                {
                    ApplicationArea = All;
                    ToolTip = 'Todos';
                    trigger OnValidate()
                    BEGIN
                        Rec.SETRANGE("Document Type");
                        CurrPage.UPDATE(FALSE);
                    END;
                }
                field("F-T"; "F-T")
                {
                    ApplicationArea = All;
                    ToolTip = 'Todos-Facturas';
                    trigger OnValidate()
                    BEGIN
                        Rec.SETFILTER("Document Type", '%1|%2|%3|%4|%5|%6', Rec."Document Type"::Albaran, Rec."Document Type"::Payment,
                        Rec."Document Type"::"Finance Charge Memo", Rec."Document Type"::Reminder, Rec."Document Type"::Refund, Rec."Document Type"::Bill);
                        CurrPage.UPDATE(FALSE);
                    END;
                }
                field(A; AL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Albaranes';
                    trigger OnValidate()
                    BEGIN
                        Rec.Setrange("Document Type", Rec."Document Type"::Albaran);
                        CurrPage.UPDATE(FALSE);
                    End;
                }
                field("F+A"; "F+A")
                {
                    ApplicationArea = All;
                    ToolTip = 'Facturas+Albaranes';
                    trigger OnValidate()
                    BEGIN
                        Rec.SETFILTER("Document Type", '%1|%2|%3', Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo", Rec."Document Type"::Albaran);
                        CurrPage.UPDATE(FALSE);
                    END;
                }
            }
            repeater(Detalle)
            {
                Editable = false;
                field("Tipo procedencia"; Rec."Source Type") { ApplicationArea = All; }
                field("Código"; Rec."Source No.") { ApplicationArea = All; }
                field(Nombre; Nom(Rec)) { ApplicationArea = All; }
                field("Saldo en otra empresa"; Rec."Saldo en otra empresa")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    BEGIN
                        if Rec."Source Type" = Rec."Source Type"::Vendor THEN BEGIN
                            r23.GET(Rec."Source No.");
                            DrillOtrEP(r23);

                        END ELSE BEGIN
                            r18.GET(Rec."Source No.");
                            DrillOtrEC(r18);
                        END;
                    END;
                }
                field(ColumnValues1; ColumnValues[1])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(1);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[1];
                    //StyleExpr = ColumnStyle1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;
                }
                field(ColumnValues2; ColumnValues[2])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(2);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[2];
                    //StyleExpr = ColumnStyle2;
                    Visible = NoOfColumns >= 2;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;
                }
                field(ColumnValues3; ColumnValues[3])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(3);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[3];
                    //StyleExpr = ColumnStyle3;
                    Visible = NoOfColumns >= 3;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;
                }
                field(ColumnValues4; ColumnValues[4])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(4);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[4];
                    //StyleExpr = ColumnStyle4;
                    Visible = NoOfColumns >= 4;

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;
                }
                field(ColumnValues5; ColumnValues[5])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(5);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[5];
                    //StyleExpr = ColumnStyle5;
                    Visible = NoOfColumns >= 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;
                }
                field(ColumnValues6; ColumnValues[6])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(6);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[6];
                    //StyleExpr = ColumnStyle6;
                    Visible = NoOfColumns >= 6;

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;
                }
                field(ColumnValues7; ColumnValues[7])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(7);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[7];
                    //StyleExpr = ColumnStyle7;
                    Visible = NoOfColumns >= 7;

                    trigger OnDrillDown()
                    begin
                        DrillDown(7);
                    end;
                }
                field(ColumnValues8; ColumnValues[8])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(8);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[8];
                    //StyleExpr = ColumnStyle8;
                    Visible = NoOfColumns >= 8;

                    trigger OnDrillDown()
                    begin
                        DrillDown(8);
                    end;
                }
                field(ColumnValues9; ColumnValues[9])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(9);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[9];
                    //StyleExpr = ColumnStyle9;
                    Visible = NoOfColumns >= 9;

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;
                }
                field(ColumnValues10; ColumnValues[10])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(10);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[10];
                    //StyleExpr = ColumnStyle10;
                    Visible = NoOfColumns >= 10;

                    trigger OnDrillDown()
                    begin
                        DrillDown(10);
                    end;
                }
                field(ColumnValues11; ColumnValues[11])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(11);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[11];
                    //StyleExpr = ColumnStyle11;
                    Visible = NoOfColumns >= 11;

                    trigger OnDrillDown()
                    begin
                        DrillDown(11);
                    end;
                }
                field(ColumnValues12; ColumnValues[12])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(12);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[12];
                    //StyleExpr = ColumnStyle12;
                    Visible = NoOfColumns >= 12;

                    trigger OnDrillDown()
                    begin
                        DrillDown(12);
                    end;
                }
                field(ColumnValues13; ColumnValues[13])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(13);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[13];
                    //StyleExpr = ColumnStyle13;
                    Visible = NoOfColumns >= 13;

                    trigger OnDrillDown()
                    begin
                        DrillDown(13);
                    end;
                }
                field(ColumnValues14; ColumnValues[14])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(14);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[14];
                    //StyleExpr = ColumnStyle14;
                    Visible = NoOfColumns >= 14;

                    trigger OnDrillDown()
                    begin
                        DrillDown(14);
                    end;
                }
                field(ColumnValues15; ColumnValues[15])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(15);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[15];
                    //StyleExpr = ColumnStyle15;
                    Visible = NoOfColumns >= 15;

                    trigger OnDrillDown()
                    begin
                        DrillDown(15);
                    end;
                }
                field(ColumnValues16; ColumnValues[16])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(16);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[16];
                    //StyleExpr = ColumnStyle16;
                    Visible = NoOfColumns >= 16;

                    trigger OnDrillDown()
                    begin
                        DrillDown(16);
                    end;
                }
                field(ColumnValues17; ColumnValues[17])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(17);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[17];
                    //StyleExpr = ColumnStyle17;
                    Visible = NoOfColumns >= 17;

                    trigger OnDrillDown()
                    begin
                        DrillDown(17);
                    end;
                }
                field(ColumnValues18; ColumnValues[18])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(18);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[18];
                    //StyleExpr = ColumnStyle18;
                    Visible = NoOfColumns >= 18;

                    trigger OnDrillDown()
                    begin
                        DrillDown(18);
                    end;
                }
                field(ColumnValues19; ColumnValues[19])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(19);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[19];
                    //StyleExpr = ColumnStyle19;
                    Visible = NoOfColumns >= 19;

                    trigger OnDrillDown()
                    begin
                        DrillDown(19);
                    end;
                }
                field(ColumnValues20; ColumnValues[20])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(20);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[20];
                    //StyleExpr = ColumnStyle14;
                    Visible = NoOfColumns >= 20;

                    trigger OnDrillDown()
                    begin
                        DrillDown(20);
                    end;
                }
                field(ColumnValues21; ColumnValues[21])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(21);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[21];
                    //StyleExpr = ColumnStyle1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(21);
                    end;
                }
                field(ColumnValues22; ColumnValues[22])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(22);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[22];
                    //StyleExpr = ColumnStyle22;
                    Visible = NoOfColumns >= 22;

                    trigger OnDrillDown()
                    begin
                        DrillDown(22);
                    end;
                }
                field(ColumnValues23; ColumnValues[23])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(23);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[23];
                    //StyleExpr = ColumnStyle23;
                    Visible = NoOfColumns >= 23;

                    trigger OnDrillDown()
                    begin
                        DrillDown(23);
                    end;
                }
                field(ColumnValues24; ColumnValues[24])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(24);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[24];
                    //StyleExpr = ColumnStyle24;
                    Visible = NoOfColumns >= 24;

                    trigger OnDrillDown()
                    begin
                        DrillDown(24);
                    end;
                }
                field(ColumnValues25; ColumnValues[25])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(25);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[25];
                    //StyleExpr = ColumnStyle25;
                    Visible = NoOfColumns >= 25;

                    trigger OnDrillDown()
                    begin
                        DrillDown(25);
                    end;
                }
                field(ColumnValues26; ColumnValues[26])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(26);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[26];
                    //StyleExpr = ColumnStyle26;
                    Visible = NoOfColumns >= 26;

                    trigger OnDrillDown()
                    begin
                        DrillDown(26);
                    end;
                }
                field(ColumnValues27; ColumnValues[27])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(27);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[27];
                    //StyleExpr = ColumnStyle27;
                    Visible = NoOfColumns >= 27;

                    trigger OnDrillDown()
                    begin
                        DrillDown(27);
                    end;
                }
                field(ColumnValues28; ColumnValues[28])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(28);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[28];
                    //StyleExpr = ColumnStyle28;
                    Visible = NoOfColumns >= 28;

                    trigger OnDrillDown()
                    begin
                        DrillDown(28);
                    end;
                }
                field(ColumnValues29; ColumnValues[29])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(29);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[29];
                    //StyleExpr = ColumnStyle29;
                    Visible = NoOfColumns >= 29;

                    trigger OnDrillDown()
                    begin
                        DrillDown(29);
                    end;
                }
                field(ColumnValues30; ColumnValues[30])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(30);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[30];
                    //StyleExpr = ColumnStyle30;
                    Visible = NoOfColumns >= 30;

                    trigger OnDrillDown()
                    begin
                        DrillDown(30);
                    end;
                }
                field(ColumnValues31; ColumnValues[31])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(31);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[31];
                    //StyleExpr = ColumnStyle31;
                    Visible = NoOfColumns >= 31;

                    trigger OnDrillDown()
                    begin
                        DrillDown(31);
                    end;
                }
                field(ColumnValues32; ColumnValues[32])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(32);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[32];
                    //StyleExpr = ColumnStyle32;
                    Visible = NoOfColumns >= 32;

                    trigger OnDrillDown()
                    begin
                        DrillDown(32);
                    end;
                }
                field(ColumnValues33; ColumnValues[33])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(33);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[33];
                    //StyleExpr = ColumnStyle33;
                    Visible = NoOfColumns >= 33;

                    trigger OnDrillDown()
                    begin
                        DrillDown(33);
                    end;
                }
                field(ColumnValues34; ColumnValues[34])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[34];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 34;

                    trigger OnDrillDown()
                    begin
                        DrillDown(34);
                    end;
                }
                field(ColumnValues35; ColumnValues[35])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[35];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 35;

                    trigger OnDrillDown()
                    begin
                        DrillDown(35);
                    end;
                }
                field(ColumnValues36; ColumnValues[36])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[36];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 36;

                    trigger OnDrillDown()
                    begin
                        DrillDown(36);
                    end;
                }
                field(ColumnValues37; ColumnValues[37])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[37];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 37;

                    trigger OnDrillDown()
                    begin
                        DrillDown(37);
                    end;
                }
                field(ColumnValues38; ColumnValues[38])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[38];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 38;

                    trigger OnDrillDown()
                    begin
                        DrillDown(38);
                    end;
                }
                field(ColumnValues39; ColumnValues[39])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[39];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 39;

                    trigger OnDrillDown()
                    begin
                        DrillDown(39);
                    end;
                }
                field(ColumnValues40; ColumnValues[40])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[40];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 40;

                    trigger OnDrillDown()
                    begin
                        DrillDown(40);
                    end;
                }
                field(ColumnValues41; ColumnValues[41])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[41];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 41;

                    trigger OnDrillDown()
                    begin
                        DrillDown(41);
                    end;
                }
                field(ColumnValues42; ColumnValues[42])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(32);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[42];
                    //StyleExpr = ColumnStyle32;
                    Visible = NoOfColumns >= 42;

                    trigger OnDrillDown()
                    begin
                        DrillDown(42);
                    end;
                }
                field(ColumnValues43; ColumnValues[43])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(33);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[43];
                    //StyleExpr = ColumnStyle33;
                    Visible = NoOfColumns >= 43;

                    trigger OnDrillDown()
                    begin
                        DrillDown(43);
                    end;
                }
                field(ColumnValues44; ColumnValues[44])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[44];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 44;

                    trigger OnDrillDown()
                    begin
                        DrillDown(44);
                    end;
                }
                field(ColumnValues45; ColumnValues[45])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[45];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 45;

                    trigger OnDrillDown()
                    begin
                        DrillDown(45);
                    end;
                }
                field(ColumnValues46; ColumnValues[46])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[46];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 46;

                    trigger OnDrillDown()
                    begin
                        DrillDown(46);
                    end;
                }
                field(ColumnValues47; ColumnValues[47])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[47];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 47;

                    trigger OnDrillDown()
                    begin
                        DrillDown(47);
                    end;
                }
                field(ColumnValues48; ColumnValues[48])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[48];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 48;

                    trigger OnDrillDown()
                    begin
                        DrillDown(48);
                    end;
                }
                field(ColumnValues49; ColumnValues[49])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[49];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 49;

                    trigger OnDrillDown()
                    begin
                        DrillDown(49);
                    end;
                }
                field(ColumnValues50; ColumnValues[50])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[50];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 50;

                    trigger OnDrillDown()
                    begin
                        DrillDown(50);
                    end;
                }
                field(ColumnValues51; ColumnValues[51])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[51];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 51;

                    trigger OnDrillDown()
                    begin
                        DrillDown(51);
                    end;
                }
                field(ColumnValues52; ColumnValues[52])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[52];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 52;

                    trigger OnDrillDown()
                    begin
                        DrillDown(52);
                    end;
                }
                field(ColumnValues53; ColumnValues[53])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[53];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 53;

                    trigger OnDrillDown()
                    begin
                        DrillDown(53);
                    end;
                }
                field(ColumnValues54; ColumnValues[54])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[54];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 54;

                    trigger OnDrillDown()
                    begin
                        DrillDown(54);
                    end;
                }
                field(ColumnValues55; ColumnValues[55])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[55];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 55;

                    trigger OnDrillDown()
                    begin
                        DrillDown(55);
                    end;
                }
                field(ColumnValues56; ColumnValues[56])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[56];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 56;

                    trigger OnDrillDown()
                    begin
                        DrillDown(56);
                    end;
                }
                field(ColumnValues57; ColumnValues[57])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[57];
                    //StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 57;

                    trigger OnDrillDown()
                    begin
                        DrillDown(57);
                    end;
                }
                // field("Saldo Contabilidad"; "Saldo en Contab" + "Saldo en Contab activos")
                // {
                //     ApplicationArea = All;

                // }
                // { 1000000006;Label  ;0    ;0    ;0    ;0    ;ParentControl=1000000005 }
                // { 1000000007;TextBox;7590 ;220  ;1700 ;440  ;ParentControl=1000000005;
                //                                              InMatrixHeading=Yes;
                //                                              field(CurrPage.MatrixBox.MatrixRec.Cuenta }
            }

        }
    }
    actions
    {
        area(Processing)
        {

            action("Generar Apuntes")
            {
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                VAR
                    r81: Record "Gen. Journal Line";
                    r152: Record 15;
                    r50889: Record "Saldo Interempresa";
                BEGIN
                    Ventana.OPEN('Generando Apuntes Cuenta #########1## Contrapartida ###########2##');
                    r152.SETRANGE(r152."Account Type", r152."Account Type"::Posting);
                    if r152.FINDFIRST THEN
                        REPEAT
                            Ventana.UPDATE(2, r152."No.");
                            Rec.COPYFILTER("Filtro Fecha", r50889."Filtro Fecha");
                            r50889.SETRANGE("Filtro Cuenta", r152."No.");
                            Rec.COPYFILTER("Document Type", r50889."Document Type");
                            if r50889.FINDFIRST THEN
                                REPEAT
                                    Ventana.UPDATE(1, r50889."Source No.");
                                    r50889.CALCFIELDS("Debe en Contab", "Haber en Contab");
                                    if r50889."Debe en Contab" <> 0 THEN BEGIN
                                        Apunte(CuentaCP(r50889), CuentaG(r152),
                                        r50889."Debe en Contab", 0, r50889.GETRANGEMAX("Filtro Fecha"), FORMAT(r50889.GETRANGEMAX("Filtro Fecha"), 0,
                                        '<Day,2><Month,2>'), COPYSTR(Nom(r50889), 1, 30));
                                    END;
                                    if r50889."Haber en Contab" <> 0 THEN BEGIN
                                        Apunte(CuentaCP(r50889), CuentaG(r152), 0,
                                        r50889."Haber en Contab", r50889.GETRANGEMAX("Filtro Fecha"), FORMAT(r50889.GETRANGEMAX("Filtro Fecha"), 0,
                                        '<Day,2><Month,2>'), COPYSTR(Nom(r50889), 1, 30));
                                    END;
                                UNTIL r50889.NEXT = 0;
                        UNTIL r152.NEXT = 0;
                    Ventana.CLOSE;
                END;
            }
            action(Calcula)
            {
                Caption = 'Calcular';
                Image = Calculate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                ApplicationArea = All;
                trigger Onaction()
                Begin
                    calcular(true, '', FiltroFecha);
                End;

            }
            // action("Generar Apuntes Cta Actúal")
            // {
            //     ApplicationArea = All;
            //     Image=Post;
            //         trigger OnAction() VAR
            //                 r81 : Record "Gen. Journal Line";
            //                 r152 : Record 15;
            //                 r50889 : Record "Saldo Interempresa";
            //               BEGIN
            //                   Ventana.OPEN('Generando Apuntes Cuenta #########1## Contrapartida ###########2##');
            //                   r152.SETRANGE(r152."Account Type",r152."Account Type"::Posting);
            //                   r152.SETRANGE(r152."No.",CurrPage.MatrixBox.MatrixRec.Cuenta);
            //                   if r152.FINDFIRST THEN REPEAT
            //                   Ventana.UPDATE(2,r152."No.");
            //                   COPYFILTER("Filtro Fecha",r50889."Filtro Fecha");
            //                   r50889.SETRANGE("Filtro Cuenta",r152."No.");
            //                   COPYFILTER("Document Type",r50889."Document Type");
            //                   r50889.SETRANGE(r50889."Source No.","Source No.");
            //                   if r50889.FINDFIRST THEN REPEAT
            //                     Ventana.UPDATE(1,r50889."Source No.");
            //                     r50889.CALCFIELDS("Debe en Contab","Haber en Contab");
            //                     if r50889."Debe en Contab"<>0 THEN BEGIN
            //                       Apunte(CuentaCP(r50889),CuentaG(r152),
            //                       r50889."Debe en Contab",0,r50889.GETRANGEMAX("Filtro Fecha"),FORMAT(r50889.GETRANGEMAX("Filtro Fecha"),0,
            //                       '<Day,2><Month,2>'),COPYSTR(Nombre(r50889),1,30));
            //                     END;
            //                     if r50889."Haber en Contab"<>0 THEN BEGIN
            //                       Apunte(CuentaCP(r50889),CuentaG(r152),0,
            //                       r50889."Haber en Contab",r50889.GETRANGEMAX("Filtro Fecha"),FORMAT(r50889.GETRANGEMAX("Filtro Fecha"),0,
            //                       '<Day,2><Month,2>'),COPYSTR(Nombre(r50889),1,30));
            //                     END;
            //                   UNTIL r50889.NEXT=0;
            //                 UNTIL r152.NEXT=0;
            //                 Ventana.CLOSE;
            //               END;
            // }
            action("Genera Eliminaciones")
            {
                ApplicationArea = All;
                Image = UnApply;
                trigger OnAction()
                VAR
                    rEmp: Record 2000000006;
                    rCom: Record "Company Information";
                    r18: Record Customer;
                    r23: Record Vendor;
                    rGrp: Record "Vendor Posting Group";
                    rGrc: Record 92;
                    r15: Record 15;
                    r50889: Record "Saldo Interempresa";
                    Ventana: Dialog;
                    a: Integer;
                    r17: Record "G/L Entry";
                    Control: Codeunit ControlProcesos;
                BEGIN
                    Ventana.OPEN('Buscando en #########1# Nº ##########2## Comprobando Cuenta #########3##.'
                              + '\ Empresa #############################################################4##');
                    //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
                    rEmp.SetRange("Evaluation Company", false);
                    if rEmp.FINDFIRST THEN
                        REPEAT
                            if Control.Permiso_Empresas(remp.Name) then begin
                                rCom.ChangeCompany(rEmp.Name);
                                rCom.Get();
                                if rCom.InterEmpresas Then Begin
                                    Ventana.UPDATE(4, rEmp.Name);
                                    r17.RESET;
                                    r17.CHANGECOMPANY(rEmp.Name);
                                    r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                                    , "Document Type", "Gen. Posting Type");
                                    Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
                                    r17.MODIFYALL(Eliminaciones, FALSE);
                                    rGrp.CHANGECOMPANY(rEmp.Name);
                                    rGrp.SETRANGE(rGrp."Payables Account", '402', '4039999999');
                                    Ventana.UPDATE(1, 'Proveedores');
                                    if rGrp.FINDFIRST THEN
                                        REPEAT
                                            r23.CHANGECOMPANY(rEmp.Name);
                                            r23.SETRANGE(r23."Vendor Posting Group", rGrp.Code);
                                            if r23.FINDFIRST THEN
                                                REPEAT
                                                    Ventana.UPDATE(2, r23."No.");
                                                    if r23.Blocked = r23.Blocked::" " THEN BEGIN
                                                        //
                                                        r15.CHANGECOMPANY(rEmp.Name);
                                                        r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
                                                        if r15.FINDFIRST THEN
                                                            REPEAT
                                                                Ventana.UPDATE(3, r15."No.");
                                                                r17.RESET;
                                                                r17.CHANGECOMPANY(rEmp.Name);
                                                                r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                                                                , "Document Type", "Gen. Posting Type");
                                                                r17.SETRANGE(r17."Source Type", r17."Source Type"::Vendor);
                                                                r17.SETRANGE(r17."Source No.", r23."No.");
                                                                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                                                r17.SETFILTER(r17."Document Type", '%1|%2|%3',
                                                                r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");
                                                                Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
                                                                r17.MODIFYALL(Eliminaciones, TRUE);
                                                            UNTIL r15.NEXT = 0;
                                                    END;
                                                UNTIL r23.NEXT = 0;
                                        UNTIL rGrp.NEXT = 0;
                                    rGrc.CHANGECOMPANY(rEmp.Name);
                                    Ventana.UPDATE(1, 'Clientes');
                                    rGrc.SETRANGE(rGrc."Receivables Account", '432', '4339999999');
                                    if rGrc.FINDFIRST THEN
                                        REPEAT
                                            r18.CHANGECOMPANY(rEmp.Name);
                                            r18.SETRANGE(r18."Customer Posting Group", rGrc.Code);
                                            if r18.FINDFIRST THEN
                                                REPEAT
                                                    if r18.Blocked = r18.Blocked::" " THEN BEGIN
                                                        Ventana.UPDATE(2, r18."No.");
                                                        r15.CHANGECOMPANY(rEmp.Name);
                                                        r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
                                                        if r15.FINDFIRST THEN
                                                            REPEAT
                                                                Ventana.UPDATE(3, r15."No.");
                                                                r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                                                                , "Document Type", "Gen. Posting Type");
                                                                r17.RESET;
                                                                r17.CHANGECOMPANY(rEmp.Name);
                                                                r17.SETRANGE(r17."Source Type", r17."Source Type"::Customer);
                                                                r17.SETRANGE(r17."Source No.", r18."No.");
                                                                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                                                Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
                                                                r17.SETFILTER(r17."Document Type", '%1|%2|%3',
                                                                r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");

                                                                r17.MODIFYALL(Eliminaciones, TRUE);
                                                            UNTIL r15.NEXT = 0;
                                                    END;
                                                UNTIL r18.NEXT = 0;
                                        UNTIL rGrc.NEXT = 0;
                                end;
                            end;
                        UNTIL rEmp.NEXT = 0;
                    Ventana.CLOSE;
                END;
            }
        }
    }


    Var
        T: Boolean;
        AL: Boolean;
        "F-T": Boolean;
        "F+A": Boolean;
        MatrixRec: Record "Cuentas temp";
        ColumnOffset: Integer;

    //OnAfterGetRecord=BEGIN
    //SETRANGE("Filtro Cuenta",CurrPage.MatrixBox.MatrixRec.Cuenta,CurrPage.MatrixBox.MatrixRec.Cuenta+'999999');
    //                                                                 SETFILTER("Source Type filter",'%1|%2',"Source Type","Source Type"::"Fixed Asset");
    //                                                                 CALCFIELDS("Saldo en Contab","Saldo en Contab activos");
    trigger OnAfterGetRecord()
    var
        ColumnNo: Integer;
    begin
        Clear(ColumnValues);
        ColumnOffset := 0;
        MatrixRec.Reset();
        ColumnNo := 0;
        if MatrixRec.FindFirst() Then
            repeat
                Rec.SETRANGE("Filtro Cuenta", MatrixRec.Cuenta, MatrixRec.Cuenta + '999999');
                Rec.SETFILTER("Source Type filter", '%1|%2', Rec."Source Type", Rec."Source Type"::"Fixed Asset");
                Rec.CALCFIELDS("Saldo en Contab", "Saldo en Contab activos");
                ColumnNo := ColumnNo + 1;
                if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                    ColumnValues[ColumnNo - ColumnOffset] := Rec."Saldo en Contab" + Rec."Saldo en Contab activos";
                    ColumnCaptions[ColumnNo - ColumnOffset] := MatrixRec."Cuenta";
                end;
            until MatrixRec.Next() = 0;
        //AccSchedManagement.ForceRecalculate(false);

    end;

    trigger OnOpenPage()
    VAR
        r152: Record 15;

    BEGIN
        Rec.DeleteAll();
    END;

    VAR
        r18: Record Customer;
        FiltroFecha: Text;
        r23: Record Vendor;
        rGrp: Record "Vendor Posting Group";
        rGrc: Record 92;
        r15: Record 15;
        r50889: Record "Saldo Interempresa";
        Ventana: Dialog;
        a: Integer;
        ColumnValues: array[100] of Decimal;
        ColumnCaptions: array[100] of Text[100];
        NoOfColumns: Integer;

    procedure calcular(Todo: Boolean; pEmpresa: Text[30]; pfiltrofecha: Text)
    VAR
        r152: Record 15;
        GlEntry: Record "G/L Entry";
        TieneMov: Boolean;
        TieneMovActivo: Boolean;
    BEGIN
        FiltroFecha := pfiltrofecha;
        if Todo then begin
            if Rec.GETFILTER("Filtro Fecha") = '' THEN Rec.SETRANGE("Filtro Fecha", CALCDATE('PA+1D-2A', TODAY), CALCDATE('PA-1A', TODAY));
            Rec.DELETEALL;
            Ventana.OPEN('Comprobando Proveedor #########1##');
            if pEmpresa <> '' Then rGrp.ChangeCompany(pEmpresa);
            rGrp.SETRANGE(rGrp."Payables Account", '402', '4039999999');
            if rGrp.FINDFIRST THEN
                REPEAT
                    if pEmpresa <> '' Then r23.ChangeCompany(pEmpresa);
                    r23.SETRANGE(r23."Vendor Posting Group", rGrp.Code);
                    if r23.FINDFIRST THEN
                        REPEAT
                            if r23.Blocked = r23.Blocked::" " THEN BEGIN
                                Rec.INIT;
                                r23.TESTFIELD(r23."IC Partner Code");
                                Ventana.UPDATE(1, r23."No.");
                                Rec."Source Type" := Rec."Source Type"::Vendor;
                                Rec."Source No." := r23."No.";
                                Rec."IC Partner" := r23."IC Partner Code";
                                Rec."Saldo en otra empresa" := SaldoOtrEP(r23, pEmpresa);
                                Rec.INSERT;
                            END;
                        UNTIL r23.NEXT = 0;
                UNTIL rGrp.NEXT = 0;
            Ventana.CLOSE;
            Ventana.OPEN('Comprobando Cliente #########1##');
            if pEmpresa <> '' Then rGrc.ChangeCompany(pEmpresa);
            rGrc.SETRANGE(rGrc."Receivables Account", '432', '4339999999');
            if rGrc.FINDFIRST THEN
                REPEAT
                    if pEmpresa <> '' Then r18.ChangeCompany(pEmpresa);
                    r18.SETRANGE(r18."Customer Posting Group", rGrc.Code);
                    if r18.FINDFIRST THEN
                        REPEAT
                            if r18.Blocked = r18.Blocked::" " THEN BEGIN
                                Ventana.UPDATE(1, r18."No.");
                                Rec.INIT;
                                Rec."Source Type" := Rec."Source Type"::Customer;
                                Rec."Source No." := r18."No.";
                                r18.TESTFIELD(r18."IC Partner Code");
                                Rec."IC Partner" := r18."IC Partner Code";
                                Rec."Saldo en otra empresa" := SaldoOtrEC(r18, pEmpresa);
                                Rec.INSERT;
                            END;
                        UNTIL r18.NEXT = 0;
                UNTIL rGrc.NEXT = 0;
            Ventana.CLOSE;
            MatrixRec.DELETEALL;
            COMMIT;
            Ventana.OPEN('Comprobando Cuenta #########1##');
            if pEmpresa <> '' Then r15.ChangeCompany(pEmpresa);
            if pEmpresa <> '' Then r152.ChangeCompany(pEmpresa);
            r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
            if r15.FINDFIRST THEN
                REPEAT
                    Ventana.UPDATE(1, r15."No.");
                    If Not MatrixRec.Get(r15."No.") THEN BEGIN

                        if Rec.FINDFIRST THEN
                            REPEAT
                                Rec.SETRANGE("Filtro Cuenta", r15."No.");
                                Rec.CALCFIELDS("Tiene Mov.", "Tiene Mov. Activo");
                                TieneMov := Rec."Tiene Mov.";
                                TieneMovActivo := Rec."Tiene Mov. Activo";
                                If pEmpresa <> '' Then begin
                                    GlEntry.ChangeCompany(pEmpresa);
                                    GlEntry.SETRANGE("G/L Account No.", r15."No.");
                                    GlEntry.SETRANGE("Source Type", Rec."Source Type");
                                    GlEntry.SetRange("Source No.", Rec."Source No.");
                                    Rec.CopyFilter("Filtro Fecha", GlEntry."Posting Date");
                                    TieneMov := GlEntry.FINDFIRST;
                                    GlEntry.Reset();
                                    GlEntry.ChangeCompany(pEmpresa);
                                    GlEntry.SETRANGE("G/L Account No.", r15."No.");
                                    Rec.CopyFilter("Filtro Fecha", GlEntry."Posting Date");
                                    GlEntry.SetRange("IC Partner Code", Rec."IC Partner");
                                    TieneMovActivo := GlEntry.FINDFIRST;
                                end;
                                if (TieneMov) OR (TieneMovActivo) THEN BEGIN
                                    MatrixRec.INIT;
                                    MatrixRec.Cuenta := r15."No.";
                                    if r152.GET(r15."No.") THEN
                                        MatrixRec.Nombre := r152.Name
                                    ELSE
                                        MatrixRec.Nombre := r15.Name;
                                    if MatrixRec.INSERT THEN NoOfColumns += 1;
                                    rec.FINDLAST;

                                END;
                            UNTIL Rec.NEXT = 0;
                    end;
                UNTIL r15.NEXT = 0;
            Ventana.CLOSE;
            ColumnOffset := NoOfColumns;
        end else begin
            Ventana.OPEN('Comprobando Proveedor y cliente #########1##');
            if Rec.GETFILTER("Filtro Fecha") = '' THEN Rec.SETRANGE("Filtro Fecha", CALCDATE('PA+1D-2A', TODAY), CALCDATE('PA-1A', TODAY));
            if Rec.FindFirst() then
                repeat
                    if Rec."Source Type" = Rec."Source Type"::Customer Then begin
                        if pEmpresa <> '' Then r18.ChangeCompany(pEmpresa);
                        R18.Get(Rec."Source No.");
                        Rec."Saldo en otra empresa" := SaldoOtrEC(r18, pEmpresa);
                        Rec.Modify();
                    end;
                    if Rec."Source Type" = Rec."Source Type"::Vendor Then begin
                        if pEmpresa <> '' Then r23.ChangeCompany(pEmpresa);
                        R23.Get(Rec."Source No.");
                        Rec."Saldo en otra empresa" := SaldoOtrEP(r23, pEmpresa);
                        Rec.Modify();
                    end;
                Until Rec.Next() = 0;
            Ventana.Close();
        end;

    END;

    procedure DetalleColumnasCaption(var ColumnCaptions: array[100] of Text[100]);
    var
        ColumnNo: Integer;
        GlEntry: Record "G/L Entry";
        GlEntryActivos: Record "G/L Entry";

    begin
        if MatrixRec.FindFirst() Then
            repeat

                ColumnNo := ColumnNo + 1;
                if (ColumnNo < 100) then
                    ColumnCaptions[ColumnNo] := MatrixRec."Cuenta";
            //end;
            until MatrixRec.Next() = 0;
        //AccSchedManagement.ForceRecalculate(false);

    end;

    procedure DetalleColumnas(var ColumnValues: array[100] of Decimal; var ColumnCaptions: array[100] of Text[100]; pempresa: Text[30]; var RecTemp: Record "Saldo Interempresa" temporary)
    var
        ColumnNo: Integer;
        GlEntry: Record "G/L Entry";
        GlEntryActivos: Record "G/L Entry";

    begin
        Clear(ColumnValues);
        ColumnOffset := 0;
        MatrixRec.Reset();
        ColumnNo := 0;
        Rec.Get(RecTemp."Source Type", RecTemp."Source No.");
        Rectemp := Rec;
        RecTemp.Modify();
        if MatrixRec.FindFirst() Then
            repeat

                GlEntry.ChangeCompany(pempresa);
                GlEntry.SETRANGE("G/L Account No.", MatrixRec.Cuenta, MatrixRec.Cuenta + '999999');
                Rec.COPYFILTER("Document Type", GlEntry."Document Type");
                Rec.COPYFILTER("Filtro Fecha", GlEntry."Posting Date");
                GlEntry.Setrange("Source No.", RecTemp."Source No.");
                GlEntry.SETFILTER("Source Type", '%1|%2', RecTemp."Source Type", RecTemp."Source Type"::"Fixed Asset");
                GlEntry.SetRange("IC Partner Code", '');
                if GlEntry.FindFirst() then
                    GlEntry.CalcSums("Amount")
                else
                    GlEntry.init;
                GlEntryActivos.ChangeCompany(pempresa);
                GlEntryActivos.SETRANGE("G/L Account No.", MatrixRec.Cuenta, MatrixRec.Cuenta + '999999');
                Rec.COPYFILTER("Document Type", GlEntryActivos."Document Type");
                Rec.COPYFILTER("Filtro Fecha", GlEntryActivos."Posting Date");
                GlEntryActivos.SetRange("IC Partner Code", RecTemp."IC Partner");
                GlEntryActivos.SETFILTER("Source Type", '%1|%2', RecTemp."Source Type", RecTemp."Source Type"::"Fixed Asset");
                if GlEntryActivos.FindFirst() then
                    GlEntryActivos.CalcSums("Amount")
                else
                    GlEntryActivos.init;
                ColumnNo := ColumnNo + 1;
                if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                    ColumnValues[ColumnNo - ColumnOffset] := GlEntry.Amount + GlEntryActivos.Amount;
                    ColumnCaptions[ColumnNo - ColumnOffset] := MatrixRec."Cuenta";
                end;
            until MatrixRec.Next() = 0;
        //AccSchedManagement.ForceRecalculate(false);

    end;

    PROCEDURE DrillDown(a: Integer)
    VAR
        r17: Record "G/L Entry";
        r17t: Record "G/L Entry" TEMPORARY;
    BEGIN
        // r17.SETCURRENTKEY(
        // "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
        r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
        r17.SETRANGE(r17."G/L Account No.", ColumnCaptions[a]);//, ColumnCaptions[a] + '999999');
        r17.SETFILTER("Source Type", '%1|%2', Rec."Source Type", Rec."Source Type"::"Fixed Asset");
        r17.SETRANGE(r17."IC Partner Code", '');
        r17.SETRANGE(r17."Source No.", Rec."Source No.");
        Rec.COPYFILTER("Document Type", r17."Document Type");
        Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
        if r17.FINDFIRST THEN
            REPEAT
                r17t := r17;
                if r17t.INSERT THEN;
            UNTIL r17.NEXT = 0;
        r17.SETRANGE(r17."IC Partner Code", Rec."IC Partner");
        r17.SETRANGE(r17."Source No.");
        if r17.FINDFIRST THEN
            REPEAT
                r17t := r17;
                if r17t.INSERT THEN;
            UNTIL r17.NEXT = 0;
        COMMIT;
        //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
        //if r17.FINDFIRST THEN BEGIN
        Page.RUNMODAL(0, r17t);
    END;

    PROCEDURE Nom(VAR r50889: Record "Saldo Interempresa"): Text[100];
    BEGIN
        if r50889."Source Type" = r50889."Source Type"::Vendor THEN
            if r23.GET(r50889."Source No.") THEN EXIT(r23.Name);
        if r50889."Source Type" = r50889."Source Type"::Customer THEN
            if r18.GET(r50889."Source No.") THEN EXIT(r18.Name);
    END;

    PROCEDURE Apunte(Cuenta: Text[30]; Contra: Text[30]; Debe: Decimal; Haber: Decimal; Fecha: Date; Doc: Text[30]; Des: Text[30]);
    VAR
        r81: Record "Gen. Journal Line";
        a: Integer;
        r81I: Record "Gen. Journal Line";
        rBis: Record 220;
    BEGIN
        if Contra = Cuenta THEN EXIT;
        rBis.CHANGECOMPANY('Consolidacion');
        rBis.SETRANGE(rBis."Company Name", COMPANYNAME);
        rBis.FINDFIRST;
        r81.SETRANGE(r81."Journal Template Name", 'GENERAL');
        r81.SETRANGE("Journal Batch Name", 'INTER');
        if r81.FINDLAST THEN
            a := r81."Line No." + 10000
        ELSE
            a := 10000;
        r81.VALIDATE(r81."Journal Template Name", 'GENERAL');
        r81.VALIDATE(r81."Journal Batch Name", 'GENERICO');
        r81.VALIDATE(r81."Line No.", a);
        r81.VALIDATE(r81."Account Type", r81."Account Type"::"G/L Account");
        r81."Account No." := Contra;
        r81.VALIDATE(r81."Posting Date", Fecha);
        r81.VALIDATE(r81."Document No.", Doc);
        r81.VALIDATE(r81.Description, Des);
        if Haber <> 0 THEN
            r81.VALIDATE(r81."Debit Amount", Haber);
        if Debe <> 0 THEN
            r81.VALIDATE(r81."Credit Amount", Debe);
        r81I.CHANGECOMPANY('Consolidacion');
        r81I.SETRANGE(r81I."Journal Template Name", 'GENERAL');
        r81I.SETRANGE("Journal Batch Name", 'GENERICO');
        if r81I.FINDLAST THEN
            a := r81I."Line No." + 10000
        ELSE
            a := 10000;
        r81I := r81;
        r81I."Line No." := a;
        r81I."Business Unit Code" := rBis.Code;
        r81I.Eliminaciones := TRUE;
        r81I.INSERT;

        r81.VALIDATE(r81."Journal Template Name", 'GENERAL');
        r81.VALIDATE(r81."Journal Batch Name", 'GENERICO');
        r81.VALIDATE(r81."Line No.", a + 10000);
        r81.VALIDATE(r81."Account Type", r81."Account Type"::"G/L Account");
        r81."Account No." := Cuenta;
        r81.VALIDATE(r81."Posting Date", Fecha);
        r81.VALIDATE(r81."Document No.", Doc);
        r81.VALIDATE(r81.Description, Des);
        if Haber <> 0 THEN
            r81.VALIDATE(r81."Credit Amount", Haber);
        if Debe <> 0 THEN
            r81.VALIDATE(r81."Debit Amount", Debe);
        r81I.CHANGECOMPANY('Consolidacion');
        r81I.SETRANGE(r81I."Journal Template Name", 'GENERAL');
        r81I.SETRANGE("Journal Batch Name", 'GENERICO');
        if r81I.FINDLAST THEN
            a := r81I."Line No." + 10000
        ELSE
            a := 10000;
        r81I := r81;
        r81I."Line No." := a;
        r81I."Business Unit Code" := rBis.Code;
        r81I.Eliminaciones := TRUE;
        r81I.INSERT;
    END;

    PROCEDURE CuentaCP(VAR r50889: Record "Saldo Interempresa"): Text[30];
    BEGIN
        if r50889."Source Type" = r50889."Source Type"::Vendor THEN BEGIN
            r23.GET(r50889."Source No.");
            rGrp.GET(r23."Vendor Posting Group");
            r15.GET(rGrp."Payables Account");
            EXIT(CuentaG(r15));
        END;
        if r50889."Source Type" = r50889."Source Type"::Customer THEN BEGIN
            r18.GET(r50889."Source No.");
            rGrc.GET(r18."Customer Posting Group");
            r15.GET(rGrc."Receivables Account");
            EXIT(CuentaG(r15));
        END;
    END;

    PROCEDURE CuentaG(VAR r15: Record 15): Text[30];
    BEGIN
        EXIT(r15."Consol. Debit Acc.");
    END;

    PROCEDURE SaldoOtrEP(r23: Record Vendor; pEmpresa: Text[30]): Decimal;
    VAR
        r17: Record "G/L Entry";
        r18: Record Customer;
        rIc: Record 413;
        rComp: Record "IC Setup";
        Importe: Decimal;
    BEGIN
        if pEmpresa <> '' Then rComp.ChangeCompany(pEmpresa);
        rComp.GET;
        if pEmpresa <> '' Then r17.ChangeCompany(pEmpresa);
        r17.SETCURRENTKEY(
        "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");

        if r23."IC Partner Code" = '' THEN
            ERROR('El Proveedor %1 no tiene código de partner', r23."No.");
        if pEmpresa <> '' Then rIc.ChangeCompany(pEmpresa);
        rIc.GET(r23."IC Partner Code");
        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
            r18.CHANGECOMPANY(rIc."Inbox Details");
            r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
            //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
            //rIc."Inbox Details",rComp."IC Partner Code");
            if r18.FINDFIRST THEN BEGIN
                r17.CHANGECOMPANY(rIc."Inbox Details");
                r17.Setfilter("Posting Date", FiltroFecha);
                r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
                r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
                r17.SETRANGE(r17."IC Partner Code", '');
                r17.SETRANGE(r17."Source No.", r18."No.");
                //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
                if r17.FINDFIRST THEN BEGIN
                    r17.CALCSUMS(r17.Amount);
                    Importe := (r17.Amount);
                END;
                r17.SETCURRENTKEY(
                "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
                r17.Setfilter("Posting Date", FiltroFecha);
                r17.SETRANGE(r17."Source No.");
                r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
                if r17.FINDFIRST THEN BEGIN
                    r17.CALCSUMS(r17.Amount);
                    Importe += (r17.Amount);
                END;
            END;
        END;
        EXIT(Importe);
    END;

    PROCEDURE SaldoOtrEC(r23: Record Customer; pEmpresa: Text[30]): Decimal;
    VAR
        r17: Record "G/L Entry";
        r18: Record Vendor;
        rIc: Record 413;
        rComp: Record "IC Setup";
        Importe: Decimal;
    BEGIN
        if pEmpresa <> '' Then rComp.ChangeCompany(pEmpresa);
        rComp.GET;
        if pEmpresa <> '' Then r17.ChangeCompany(pEmpresa);
        r17.SETCURRENTKEY(
        "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
        if r23."IC Partner Code" = '' THEN
            ERROR('El Cliente %1 no tiene código de partner', r23."No.");
        if pEmpresa <> '' Then rIc.ChangeCompany(pEmpresa);
        rIc.GET(r23."IC Partner Code");
        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
            r18.CHANGECOMPANY(rIc."Inbox Details");
            r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
            //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
            //rIc."Inbox Details",rComp."IC Partner Code");
            if r18.FINDFIRST THEN BEGIN
                r17.CHANGECOMPANY(rIc."Inbox Details");
                r17.Setfilter("Posting Date", FiltroFecha);
                r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
                //r17.SETRANGE(r17."Source Type",r17."Source Type"::Vendor);
                //r17.SETRANGE(r17."Source No.",r18."No.");
                r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Vendor, r17."Source Type"::"Fixed Asset");
                r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
                if r17.FINDFIRST THEN
                    REPEAT
                        Importe += r17.Amount;
                    UNTIL r17.NEXT = 0;
                r17.SETRANGE(r17."IC Partner Code", '');
                r17.SETRANGE(r17."Source No.", r18."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        Importe += r17.Amount;
                    UNTIL r17.NEXT = 0;
            END;
        END;
        EXIT(Importe);
    END;

    PROCEDURE DrillOtrEP(r23: Record 23);
    VAR
        r17: Record "G/L Entry";
        r18: Record Customer;
        rIc: Record 413;
        rComp: Record "IC Setup";
        r17t: Record "G/L Entry" TEMPORARY;
    BEGIN
        rComp.GET;
        r17.SETCURRENTKEY(
        "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
        if r23."IC Partner Code" = '' THEN
            ERROR('El Proveedor %1 no tiene código de partner', r23."No.");
        rIc.GET(r23."IC Partner Code");
        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
            r18.CHANGECOMPANY(rIc."Inbox Details");
            r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
            //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
            //rIc."Inbox Details",rComp."IC Partner Code");
            if r18.FINDFIRST THEN BEGIN
                r17.CHANGECOMPANY(rIc."Inbox Details");
                Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
                r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
                //r17.SETRANGE(r17."Source Type",r17."Source Type"::Customer);
                //r17.SETRANGE(r17."Source No.",r18."No.");
                r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
                r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
                if r17.FINDFIRST THEN
                    REPEAT
                        r17t := r17;
                        r17t.INSERT;
                    UNTIL r17.NEXT = 0;
                r17.SETRANGE(r17."IC Partner Code", '');
                r17.SETRANGE(r17."Source No.", r18."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        r17t := r17;
                        r17t.INSERT;
                    UNTIL r17.NEXT = 0;
                COMMIT;
                //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
                //if r17.FINDFIRST THEN BEGIN
                Page.RUNMODAL(0, r17t);
                //END;
            END;
        END;
    END;

    PROCEDURE DrillOtrEC(r23: Record 18);
    VAR
        r17: Record "G/L Entry";
        r18: Record Vendor;
        rIc: Record 413;
        rComp: Record "IC Setup";
        r17t: Record "G/L Entry" TEMPORARY;
    BEGIN
        rComp.GET;
        r17.SETCURRENTKEY(
        "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
        if r23."IC Partner Code" = '' THEN
            ERROR('El Cliente %1 no tiene código de partner', r23."No.");
        rIc.GET(r23."IC Partner Code");
        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
            r18.CHANGECOMPANY(rIc."Inbox Details");
            r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
            //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
            //rIc."Inbox Details",rComp."IC Partner Code");
            if r18.FINDFIRST THEN BEGIN
                r17.CHANGECOMPANY(rIc."Inbox Details");
                Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
                r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
                //r17.SETRANGE(r17."Source Type",r17."Source Type"::Vendor);
                //r17.SETRANGE(r17."Source No.",r18."No.");
                r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Vendor, r17."Source Type"::"Fixed Asset");
                r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
                if r17.FINDFIRST THEN
                    REPEAT
                        r17t := r17;
                        r17t.INSERT;
                    UNTIL r17.NEXT = 0;
                r17.SETRANGE(r17."IC Partner Code", '');
                r17.SETRANGE(r17."Source No.", r18."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        r17t := r17;
                        r17t.INSERT;
                    UNTIL r17.NEXT = 0;
                COMMIT;

                //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
                //if r17.FINDFIRST THEN BEGIN
                Page.RUNMODAL(0, r17t);
                //END;
            END;
        END;
    END;

}
// page 50071 "Matix Prestamos"
// {
//     PageType = List;
//     UsageCategory = Lists;
//     ApplicationArea = All;
//     SourceTable = "Cabecera Prestamo";
//     SourceTableView= SORTING(Empresa) WHERE(Empresa=FILTER(<>''),"Importe Prestamo"=FILTER(<>0));
//     Permissions = tabledata 17 = rimd;

//     layout
//     {
//         area(Content)
//         {

//             // { 1000000000;MatrixBox;0  ;770  ;13970;5500 ;Name=MatrixBox;
//             //                                              HorzGlue=Both;
//             //                                              VertGlue=Both;
//             //                                              MatrixSourceTable=Table50890;
//             //                                              OnAfterGetRecord=BEGIN
//             //                                                                 SETRANGE("Filtro Cuenta",CurrPage.MatrixBox.MatrixRec.Cuenta,CurrPage.MatrixBox.MatrixRec.Cuenta+'999999');
//             //                                                                 SETFILTER("Source Type filter",'%1|%2',"Source Type","Source Type"::"Fixed Asset");
//             //                                                                 CALCFIELDS("Saldo en Contab","Saldo en Contab activos");
//             //                                                               END;
//             // 
//             group(Filtros)
//             {
//                 field("Filtro Fecha Liquidación";Rec."Filtro Fecha Liquidación")
//                 {
//                     ApplicationArea = All;
//                     trigger OnValidate()
//                     BEGIN
//                        // SETRANGE("Document Type");
//                         CurrPage.UPDATE(FALSE);
//                     END;
//                 }

//                 field("Amortización"; Amortizacion)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Amortización';
//                     trigger OnValidate()
//                     BEGIN
//                        // SETRANGE("Document Type");
//                         CurrPage.UPDATE(FALSE);
//                     END;
//                 }
//                 field("Interese"; Inte)
//                 {
//                     Caption='Intereses';
//                     ApplicationArea = All;
//                     ToolTip = 'Intereses';
//                     trigger OnValidate()
//                     BEGIN
//                         CurrPage.UPDATE(FALSE);
//                     END;
//                 }
//                 field("Cuotas"; Cuota)
//                 {
//                     Caption  = 'Cuota';
//                     ApplicationArea = All;
//                     ToolTip = 'Cuota';
//                     trigger OnValidate()
//                     BEGIN
//                         CurrPage.UPDATE(FALSE);
//                     End;
//                 }

//             }
//             repeater(Detalle)
//             {
//                 Editable = false;
//                 field(Empresa;Rec.Empresa) { ApplicationArea = All; }
//                 field("Código del Prestamo"; Cab) { ApplicationArea = All; }
//                 field(Banco; Banc) { ApplicationArea = All; }
//                 field(Meses; Meses)
//                 {
//                   ApplicationArea=All;
//                 }
//                 field(ColumnValues1; ColumnValues[1])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(1);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[1];
//                     //StyleExpr = ColumnStyle1;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(1);
//                     end;
//                 }
//                 field(ColumnValues2; ColumnValues[2])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(2);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[2];
//                     //StyleExpr = ColumnStyle2;
//                     Visible = NoOfColumns >= 2;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(2);
//                     end;
//                 }
//                 field(ColumnValues3; ColumnValues[3])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(3);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[3];
//                     //StyleExpr = ColumnStyle3;
//                     Visible = NoOfColumns >= 3;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(3);
//                     end;
//                 }
//                 field(ColumnValues4; ColumnValues[4])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(4);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[4];
//                     //StyleExpr = ColumnStyle4;
//                     Visible = NoOfColumns >= 4;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(4);
//                     end;
//                 }
//                 field(ColumnValues5; ColumnValues[5])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(5);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[5];
//                     //StyleExpr = ColumnStyle5;
//                     Visible = NoOfColumns >= 5;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(5);
//                     end;
//                 }
//                 field(ColumnValues6; ColumnValues[6])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(6);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[6];
//                     //StyleExpr = ColumnStyle6;
//                     Visible = NoOfColumns >= 6;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(6);
//                     end;
//                 }
//                 field(ColumnValues7; ColumnValues[7])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(7);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[7];
//                     //StyleExpr = ColumnStyle7;
//                     Visible = NoOfColumns >= 7;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(7);
//                     end;
//                 }
//                 field(ColumnValues8; ColumnValues[8])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(8);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[8];
//                     //StyleExpr = ColumnStyle8;
//                     Visible = NoOfColumns >= 8;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(8);
//                     end;
//                 }
//                 field(ColumnValues9; ColumnValues[9])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(9);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[9];
//                     //StyleExpr = ColumnStyle9;
//                     Visible = NoOfColumns >= 9;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(9);
//                     end;
//                 }
//                 field(ColumnValues10; ColumnValues[10])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(10);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[10];
//                     //StyleExpr = ColumnStyle10;
//                     Visible = NoOfColumns >= 10;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(10);
//                     end;
//                 }
//                 field(ColumnValues11; ColumnValues[11])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(11);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[11];
//                     //StyleExpr = ColumnStyle11;
//                     Visible = NoOfColumns >= 11;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(11);
//                     end;
//                 }
//                 field(ColumnValues12; ColumnValues[12])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(12);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[12];
//                     //StyleExpr = ColumnStyle12;
//                     Visible = NoOfColumns >= 12;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(12);
//                     end;
//                 }
//                 field(ColumnValues13; ColumnValues[13])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(13);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[13];
//                     //StyleExpr = ColumnStyle13;
//                     Visible = NoOfColumns >= 13;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(13);
//                     end;
//                 }
//                 field(ColumnValues14; ColumnValues[14])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(14);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[14];
//                     //StyleExpr = ColumnStyle14;
//                     Visible = NoOfColumns >= 14;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(14);
//                     end;
//                 }
//                 field(ColumnValues15; ColumnValues[15])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(15);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[15];
//                     //StyleExpr = ColumnStyle15;
//                     Visible = NoOfColumns >= 15;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(15);
//                     end;
//                 }
//                 field(ColumnValues16; ColumnValues[16])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(16);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[16];
//                     //StyleExpr = ColumnStyle16;
//                     Visible = NoOfColumns >= 16;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(16);
//                     end;
//                 }
//                 field(ColumnValues17; ColumnValues[17])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(17);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[17];
//                     //StyleExpr = ColumnStyle17;
//                     Visible = NoOfColumns >= 17;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(17);
//                     end;
//                 }
//                 field(ColumnValues18; ColumnValues[18])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(18);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[18];
//                     //StyleExpr = ColumnStyle18;
//                     Visible = NoOfColumns >= 18;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(18);
//                     end;
//                 }
//                 field(ColumnValues19; ColumnValues[19])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(19);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[19];
//                     //StyleExpr = ColumnStyle19;
//                     Visible = NoOfColumns >= 19;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(19);
//                     end;
//                 }
//                 field(ColumnValues20; ColumnValues[20])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(20);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[20];
//                     //StyleExpr = ColumnStyle14;
//                     Visible = NoOfColumns >= 20;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(20);
//                     end;
//                 }
//                 field(ColumnValues21; ColumnValues[21])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(21);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[21];
//                     //StyleExpr = ColumnStyle1;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(21);
//                     end;
//                 }
//                 field(ColumnValues22; ColumnValues[22])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(22);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[22];
//                     //StyleExpr = ColumnStyle22;
//                     Visible = NoOfColumns >= 22;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(22);
//                     end;
//                 }
//                 field(ColumnValues23; ColumnValues[23])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(23);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[23];
//                     //StyleExpr = ColumnStyle23;
//                     Visible = NoOfColumns >= 23;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(23);
//                     end;
//                 }
//                 field(ColumnValues24; ColumnValues[24])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(24);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[24];
//                     //StyleExpr = ColumnStyle24;
//                     Visible = NoOfColumns >= 24;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(24);
//                     end;
//                 }
//                 field(ColumnValues25; ColumnValues[25])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(25);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[25];
//                     //StyleExpr = ColumnStyle25;
//                     Visible = NoOfColumns >= 25;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(25);
//                     end;
//                 }
//                 field(ColumnValues26; ColumnValues[26])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(26);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[26];
//                     //StyleExpr = ColumnStyle26;
//                     Visible = NoOfColumns >= 26;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(26);
//                     end;
//                 }
//                 field(ColumnValues27; ColumnValues[27])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(27);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[27];
//                     //StyleExpr = ColumnStyle27;
//                     Visible = NoOfColumns >= 27;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(27);
//                     end;
//                 }
//                 field(ColumnValues28; ColumnValues[28])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(28);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[28];
//                     //StyleExpr = ColumnStyle28;
//                     Visible = NoOfColumns >= 28;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(28);
//                     end;
//                 }
//                 field(ColumnValues29; ColumnValues[29])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(29);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[29];
//                     //StyleExpr = ColumnStyle29;
//                     Visible = NoOfColumns >= 29;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(29);
//                     end;
//                 }
//                 field(ColumnValues30; ColumnValues[30])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(30);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[30];
//                     //StyleExpr = ColumnStyle30;
//                     Visible = NoOfColumns >= 30;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(30);
//                     end;
//                 }
//                 field(ColumnValues31; ColumnValues[31])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(31);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[31];
//                     //StyleExpr = ColumnStyle31;
//                     Visible = NoOfColumns >= 31;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(31);
//                     end;
//                 }
//                 field(ColumnValues32; ColumnValues[32])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(32);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[32];
//                     //StyleExpr = ColumnStyle32;
//                     Visible = NoOfColumns >= 32;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(32);
//                     end;
//                 }
//                 field(ColumnValues33; ColumnValues[33])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(33);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[33];
//                     //StyleExpr = ColumnStyle33;
//                     Visible = NoOfColumns >= 33;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(33);
//                     end;
//                 }
//                 field(ColumnValues34; ColumnValues[34])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[34];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 34;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(34);
//                     end;
//                 }
//                 field(ColumnValues35; ColumnValues[35])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[35];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 35;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(35);
//                     end;
//                 }
//                 field(ColumnValues36; ColumnValues[36])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[36];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 36;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(36);
//                     end;
//                 }
//                 field(ColumnValues37; ColumnValues[37])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[37];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 37;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(37);
//                     end;
//                 }
//                 field(ColumnValues38; ColumnValues[38])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[38];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 38;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(38);
//                     end;
//                 }
//                 field(ColumnValues39; ColumnValues[39])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[39];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 39;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(39);
//                     end;
//                 }
//                 field(ColumnValues40; ColumnValues[40])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[40];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 40;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(40);
//                     end;
//                 }
//                 field(ColumnValues41; ColumnValues[41])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[41];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 41;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(41);
//                     end;
//                 }
//                 field(ColumnValues42; ColumnValues[42])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(32);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[42];
//                     //StyleExpr = ColumnStyle32;
//                     Visible = NoOfColumns >= 42;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(42);
//                     end;
//                 }
//                 field(ColumnValues43; ColumnValues[43])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(33);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[43];
//                     //StyleExpr = ColumnStyle33;
//                     Visible = NoOfColumns >= 43;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(43);
//                     end;
//                 }
//                 field(ColumnValues44; ColumnValues[44])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[44];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 44;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(44);
//                     end;
//                 }
//                 field(ColumnValues45; ColumnValues[45])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[45];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 45;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(45);
//                     end;
//                 }
//                 field(ColumnValues46; ColumnValues[46])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[46];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 46;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(46);
//                     end;
//                 }
//                 field(ColumnValues47; ColumnValues[47])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[47];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 47;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(47);
//                     end;
//                 }
//                 field(ColumnValues48; ColumnValues[48])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[48];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 48;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(48);
//                     end;
//                 }
//                 field(ColumnValues49; ColumnValues[49])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[49];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 49;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(49);
//                     end;
//                 }
//                 field(ColumnValues50; ColumnValues[50])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[50];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 50;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(50);
//                     end;
//                 }
//                 field(ColumnValues52; ColumnValues[52])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[52];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 52;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(52);
//                     end;
//                 }
//                 field(ColumnValues53; ColumnValues[53])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[53];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 53;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(53);
//                     end;
//                 }
//                 field(ColumnValues54; ColumnValues[54])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[54];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 54;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(54);
//                     end;
//                 }
//                 field(ColumnValues55; ColumnValues[55])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[55];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 55;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(55);
//                     end;
//                 }
//                 field(ColumnValues56; ColumnValues[56])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[56];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 56;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(56);
//                     end;
//                 }
//                 field(ColumnValues57; ColumnValues[57])
//                 {
//                     ApplicationArea = Basic, Suite;
//                     //AutoFormatExpression = FormatStr(34);
//                     AutoFormatType = 11;
//                     BlankZero = true;
//                     CaptionClass = '3,' + ColumnCaptions[57];
//                     //StyleExpr = ColumnStyle34;
//                     Visible = NoOfColumns >= 57;

//                     trigger OnDrillDown()
//                     begin
//                         DrillDown(57);
//                     end;
//                 }
//                 // field("Saldo Contabilidad"; "Saldo en Contab" + "Saldo en Contab activos")
//                 // {
//                 //     ApplicationArea = All;

//                 // }
//                 // { 1000000006;Label  ;0    ;0    ;0    ;0    ;ParentControl=1000000005 }
//                 // { 1000000007;TextBox;7590 ;220  ;1700 ;440  ;ParentControl=1000000005;
//                 //                                              InMatrixHeading=Yes;
//                 //                                              field(CurrPage.MatrixBox.MatrixRec.Cuenta }
//             }

//         }
//     }
//     // actions
//     // {
//     //     area(Processing)
//     //     {

//     //         action("Generar Apuntes")
//     //         {
//     //             ApplicationArea = All;
//     //             Image = Post;
//     //             trigger OnAction()
//     //             VAR
//     //                 r81: Record "Gen. Journal Line";
//     //                 r152: Record 15;
//     //                 r50889: Record "Saldo Interempresa";
//     //             BEGIN
//     //                 Ventana.OPEN('Generando Apuntes Cuenta #########1## Contrapartida ###########2##');
//     //                 r152.SETRANGE(r152."Account Type", r152."Account Type"::Posting);
//     //                 if r152.FINDFIRST THEN
//     //                     REPEAT
//     //                         Ventana.UPDATE(2, r152."No.");
//     //                         COPYFILTER("Filtro Fecha", r50889."Filtro Fecha");
//     //                         r50889.SETRANGE("Filtro Cuenta", r152."No.");
//     //                         COPYFILTER("Document Type", r50889."Document Type");
//     //                         if r50889.FINDFIRST THEN
//     //                             REPEAT
//     //                                 Ventana.UPDATE(1, r50889."Source No.");
//     //                                 r50889.CALCFIELDS("Debe en Contab", "Haber en Contab");
//     //                                 if r50889."Debe en Contab" <> 0 THEN BEGIN
//     //                                     Apunte(CuentaCP(r50889), CuentaG(r152),
//     //                                     r50889."Debe en Contab", 0, r50889.GETRANGEMAX("Filtro Fecha"), FORMAT(r50889.GETRANGEMAX("Filtro Fecha"), 0,
//     //                                     '<Day,2><Month,2>'), COPYSTR(Nombre(r50889), 1, 30));
//     //                                 END;
//     //                                 if r50889."Haber en Contab" <> 0 THEN BEGIN
//     //                                     Apunte(CuentaCP(r50889), CuentaG(r152), 0,
//     //                                     r50889."Haber en Contab", r50889.GETRANGEMAX("Filtro Fecha"), FORMAT(r50889.GETRANGEMAX("Filtro Fecha"), 0,
//     //                                     '<Day,2><Month,2>'), COPYSTR(Nombre(r50889), 1, 30));
//     //                                 END;
//     //                             UNTIL r50889.NEXT = 0;
//     //                     UNTIL r152.NEXT = 0;
//     //                 Ventana.CLOSE;
//     //             END;
//     //         }
//     //         action(Calcula)
//     //         {
//     //             Caption = 'Calcular';
//     //             Image = Calculate;
//     //             Promoted = true;
//     //             PromotedIsBig = true;
//     //             PromotedCategory = New;
//     //             ApplicationArea = All;
//     //             trigger Onaction()
//     //             Begin
//     //                 calcular(true);
//     //             End;

//     //         }
//     //         // action("Generar Apuntes Cta Actúal")
//     //         // {
//     //         //     ApplicationArea = All;
//     //         //     Image=Post;
//     //         //         trigger OnAction() VAR
//     //         //                 r81 : Record "Gen. Journal Line";
//     //         //                 r152 : Record 15;
//     //         //                 r50889 : Record "Saldo Interempresa";
//     //         //               BEGIN
//     //         //                   Ventana.OPEN('Generando Apuntes Cuenta #########1## Contrapartida ###########2##');
//     //         //                   r152.SETRANGE(r152."Account Type",r152."Account Type"::Posting);
//     //         //                   r152.SETRANGE(r152."No.",CurrPage.MatrixBox.MatrixRec.Cuenta);
//     //         //                   if r152.FINDFIRST THEN REPEAT
//     //         //                   Ventana.UPDATE(2,r152."No.");
//     //         //                   COPYFILTER("Filtro Fecha",r50889."Filtro Fecha");
//     //         //                   r50889.SETRANGE("Filtro Cuenta",r152."No.");
//     //         //                   COPYFILTER("Document Type",r50889."Document Type");
//     //         //                   r50889.SETRANGE(r50889."Source No.","Source No.");
//     //         //                   if r50889.FINDFIRST THEN REPEAT
//     //         //                     Ventana.UPDATE(1,r50889."Source No.");
//     //         //                     r50889.CALCFIELDS("Debe en Contab","Haber en Contab");
//     //         //                     if r50889."Debe en Contab"<>0 THEN BEGIN
//     //         //                       Apunte(CuentaCP(r50889),CuentaG(r152),
//     //         //                       r50889."Debe en Contab",0,r50889.GETRANGEMAX("Filtro Fecha"),FORMAT(r50889.GETRANGEMAX("Filtro Fecha"),0,
//     //         //                       '<Day,2><Month,2>'),COPYSTR(Nombre(r50889),1,30));
//     //         //                     END;
//     //         //                     if r50889."Haber en Contab"<>0 THEN BEGIN
//     //         //                       Apunte(CuentaCP(r50889),CuentaG(r152),0,
//     //         //                       r50889."Haber en Contab",r50889.GETRANGEMAX("Filtro Fecha"),FORMAT(r50889.GETRANGEMAX("Filtro Fecha"),0,
//     //         //                       '<Day,2><Month,2>'),COPYSTR(Nombre(r50889),1,30));
//     //         //                     END;
//     //         //                   UNTIL r50889.NEXT=0;
//     //         //                 UNTIL r152.NEXT=0;
//     //         //                 Ventana.CLOSE;
//     //         //               END;
//     //         // }
//     //         action("Genera Eliminaciones")
//     //         {
//     //             ApplicationArea = All;
//     //             Image = UnApply;
//     //             trigger OnAction()
//     //             VAR
//     //                 rEmp: Record 2000000006;
//     //                 rCom: Record "Company Information";
//     //                 r18: Record Customer;
//     //                 r23: Record Vendor;
//     //                 rGrp: Record "Vendor Posting Group";
//     //                 rGrc: Record 92;
//     //                 r15: Record 15;
//     //                 r50889: Record "Saldo Interempresa";
//     //                 Ventana: Dialog;
//     //                 a: Integer;
//     //                 r17: Record "G/L Entry";
//     //             BEGIN
//     //                 Ventana.OPEN('Buscando en #########1# Nº ##########2## Comprobando Cuenta #########3##.'
//     //                           + '\ Empresa #############################################################4##');
//     //                 //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
//     //                 if rEmp.FINDFIRST THEN
//     //                     REPEAT
//     //                         rCom.ChangeCompany(rEmp.Name);
//     //                         rCom.Get();
//     //                         if rCom.InterEmpresas Then Begin
//     //                             Ventana.UPDATE(4, rEmp.Name);
//     //                             r17.RESET;
//     //                             r17.CHANGECOMPANY(rEmp.Name);
//     //                             r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
//     //                             , "Document Type", "Gen. Posting Type");
//     //                             COPYFILTER("Filtro Fecha", r17."Posting Date");
//     //                             r17.MODIFYALL(Eliminaciones, FALSE);
//     //                             rGrp.CHANGECOMPANY(rEmp.Name);
//     //                             rGrp.SETRANGE(rGrp."Payables Account", '402', '4039999999');
//     //                             Ventana.UPDATE(1, 'Proveedores');
//     //                             if rGrp.FINDFIRST THEN
//     //                                 REPEAT
//     //                                     r23.CHANGECOMPANY(rEmp.Name);
//     //                                     r23.SETRANGE(r23."Vendor Posting Group", rGrp.Code);
//     //                                     if r23.FINDFIRST THEN
//     //                                         REPEAT
//     //                                             Ventana.UPDATE(2, r23."No.");
//     //                                             if r23.Blocked = r23.Blocked::" " THEN BEGIN
//     //                                                 //
//     //                                                 r15.CHANGECOMPANY(rEmp.Name);
//     //                                                 r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
//     //                                                 if r15.FINDFIRST THEN
//     //                                                     REPEAT
//     //                                                         Ventana.UPDATE(3, r15."No.");
//     //                                                         r17.RESET;
//     //                                                         r17.CHANGECOMPANY(rEmp.Name);
//     //                                                         r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
//     //                                                         , "Document Type", "Gen. Posting Type");
//     //                                                         r17.SETRANGE(r17."Source Type", r17."Source Type"::Vendor);
//     //                                                         r17.SETRANGE(r17."Source No.", r23."No.");
//     //                                                         r17.SETRANGE(r17."G/L Account No.", r15."No.");
//     //                                                         r17.SETFILTER(r17."Document Type", '%1|%2|%3',
//     //                                                         r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");
//     //                                                         COPYFILTER("Filtro Fecha", r17."Posting Date");
//     //                                                         r17.MODIFYALL(Eliminaciones, TRUE);
//     //                                                     UNTIL r15.NEXT = 0;
//     //                                             END;
//     //                                         UNTIL r23.NEXT = 0;
//     //                                 UNTIL rGrp.NEXT = 0;
//     //                             rGrc.CHANGECOMPANY(rEmp.Name);
//     //                             Ventana.UPDATE(1, 'Clientes');
//     //                             rGrc.SETRANGE(rGrc."Receivables Account", '432', '4339999999');
//     //                             if rGrc.FINDFIRST THEN
//     //                                 REPEAT
//     //                                     r18.CHANGECOMPANY(rEmp.Name);
//     //                                     r18.SETRANGE(r18."Customer Posting Group", rGrc.Code);
//     //                                     if r18.FINDFIRST THEN
//     //                                         REPEAT
//     //                                             if r18.Blocked = r18.Blocked::" " THEN BEGIN
//     //                                                 Ventana.UPDATE(2, r18."No.");
//     //                                                 r15.CHANGECOMPANY(rEmp.Name);
//     //                                                 r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
//     //                                                 if r15.FINDFIRST THEN
//     //                                                     REPEAT
//     //                                                         Ventana.UPDATE(3, r15."No.");
//     //                                                         r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
//     //                                                         , "Document Type", "Gen. Posting Type");
//     //                                                         r17.RESET;
//     //                                                         r17.CHANGECOMPANY(rEmp.Name);
//     //                                                         r17.SETRANGE(r17."Source Type", r17."Source Type"::Customer);
//     //                                                         r17.SETRANGE(r17."Source No.", r18."No.");
//     //                                                         r17.SETRANGE(r17."G/L Account No.", r15."No.");
//     //                                                         COPYFILTER("Filtro Fecha", r17."Posting Date");
//     //                                                         r17.SETFILTER(r17."Document Type", '%1|%2|%3',
//     //                                                         r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");

//     //                                                         r17.MODIFYALL(Eliminaciones, TRUE);
//     //                                                     UNTIL r15.NEXT = 0;
//     //                                             END;
//     //                                         UNTIL r18.NEXT = 0;
//     //                                 UNTIL rGrc.NEXT = 0;
//     //                         end;
//     //                     UNTIL rEmp.NEXT = 0;
//     //                 Ventana.CLOSE;
//     //             END;
//     //         }
//     //     }
//     // }


//     Var
//         Amortizacion: Boolean;
//         Inte: Boolean;
//         Cuota: Boolean;
//         "F+A": Boolean;
//         MatrixRec: Record Date;
//         ColumnOffset: Integer;

//     //OnAfterGetRecord=BEGIN
//     //SETRANGE("Filtro Cuenta",CurrPage.MatrixBox.MatrixRec.Cuenta,CurrPage.MatrixBox.MatrixRec.Cuenta+'999999');
//     //                                                                 SETFILTER("Source Type filter",'%1|%2',"Source Type","Source Type"::"Fixed Asset");
//     //                                                                 CALCFIELDS("Saldo en Contab","Saldo en Contab activos");
//     trigger OnAfterGetRecord()
//     var
//         ColumnNo: Integer;
//     begin
//         Clear(ColumnValues);
//         ColumnOffset := 0;
//         MatrixRec.Reset();
//         ColumnNo := 0;
//         if MatrixRec.FindFirst() Then
//             repeat
//                 Rec.SETRANGE("Filtro Fecha", MatrixRec."Period Start", MatrixRec."Period End");
//                 SETFILTER("Source Type filter", '%1|%2', "Source Type", "Source Type"::"Fixed Asset");
//                 CALCFIELDS("Saldo en Contab", "Saldo en Contab activos");
//                 ColumnNo := ColumnNo + 1;
//                 if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
//                     ColumnValues[ColumnNo - ColumnOffset] := "Saldo en Contab" + "Saldo en Contab activos";
//                     ColumnCaptions[ColumnNo - ColumnOffset] := MatrixRec."Cuenta";
//                 end;
//             until MatrixRec.Next() = 0;
//         //AccSchedManagement.ForceRecalculate(false);

//     end;

//     trigger OnOpenPage()
//     VAR
//         r152: Record 15;

//     BEGIN
//         Rec.DeleteAll();
//     END;

//     VAR
//         r18: Record Customer;
//         FiltroFecha: Text;
//         r23: Record Vendor;
//         rGrp: Record "Vendor Posting Group";
//         rGrc: Record 92;
//         r15: Record 15;
//         r50889: Record "Saldo Interempresa";
//         Ventana: Dialog;
//         a: Integer;
//         ColumnValues: array[100] of Decimal;
//         ColumnCaptions: array[100] of Text[100];
//         NoOfColumns: Integer;

//     procedure calcular(Todo: Boolean)
//     VAR
//         r152: Record 15;

//     BEGIN
//         if Todo then begin
//             if Rec.GETFILTER("Filtro Fecha") = '' THEN Rec.SETRANGE("Filtro Fecha", CALCDATE('PA+1D-2A', TODAY), CALCDATE('PA-1A', TODAY));
//             Rec.DELETEALL;
//             Ventana.OPEN('Comprobando Proveedor #########1##');
//             rGrp.SETRANGE(rGrp."Payables Account", '402', '4039999999');
//             if rGrp.FINDFIRST THEN
//                 REPEAT
//                     r23.SETRANGE(r23."Vendor Posting Group", rGrp.Code);
//                     if r23.FINDFIRST THEN
//                         REPEAT
//                             if r23.Blocked = r23.Blocked::" " THEN BEGIN
//                                 Rec.INIT;
//                                 r23.TESTFIELD(r23."IC Partner Code");
//                                 Ventana.UPDATE(1, r23."No.");
//                                 Rec."Source Type" := Rec."Source Type"::Vendor;
//                                 Rec."Source No." := r23."No.";
//                                 Rec."IC Partner" := r23."IC Partner Code";
//                                 Rec."Saldo en otra empresa" := SaldoOtrEP(r23);
//                                 Rec.INSERT;
//                             END;
//                         UNTIL r23.NEXT = 0;
//                 UNTIL rGrp.NEXT = 0;
//             Ventana.CLOSE;
//             Ventana.OPEN('Comprobando Cliente #########1##');
//             rGrc.SETRANGE(rGrc."Receivables Account", '432', '4339999999');
//             if rGrc.FINDFIRST THEN
//                 REPEAT
//                     r18.SETRANGE(r18."Customer Posting Group", rGrc.Code);
//                     if r18.FINDFIRST THEN
//                         REPEAT
//                             if r18.Blocked = r18.Blocked::" " THEN BEGIN
//                                 Ventana.UPDATE(1, r18."No.");
//                                 Rec.INIT;
//                                 Rec."Source Type" := "Source Type"::Customer;
//                                 Rec."Source No." := r18."No.";
//                                 r18.TESTFIELD(r18."IC Partner Code");
//                                 Rec."IC Partner" := r18."IC Partner Code";
//                                 Rec."Saldo en otra empresa" := SaldoOtrEC(r18);
//                                 Rec.INSERT;
//                             END;
//                         UNTIL r18.NEXT = 0;
//                 UNTIL rGrc.NEXT = 0;
//             Ventana.CLOSE;
//             MatrixRec.DELETEALL;
//             COMMIT;
//             Ventana.OPEN('Comprobando Cuenta #########1##');
//             r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
//             if r15.FINDFIRST THEN
//                 REPEAT
//                     Ventana.UPDATE(1, r15."No.");
//                     if FINDFIRST THEN
//                         REPEAT
//                             Rec.SETRANGE("Filtro Cuenta", r15."No.");
//                             Rec.CALCFIELDS("Tiene Mov.", "Tiene Mov. Activo");
//                             if (Rec."Tiene Mov.") OR (Rec."Tiene Mov. Activo") THEN BEGIN
//                                 MatrixRec.INIT;
//                                 MatrixRec.Cuenta := r15."No.";
//                                 if r152.GET(r15."No.") THEN
//                                     MatrixRec.Nombre := r152.Name
//                                 ELSE
//                                     MatrixRec.Nombre := r15.Name;
//                                 if MatrixRec.INSERT THEN NoOfColumns += 1;
//                                 r15.SETFILTER("No.", r15."No.");
//                                 r15.FINDLAST;
//                                 r15.SETRANGE("No.");
//                             END;
//                         UNTIL NEXT = 0;
//                 UNTIL r15.NEXT = 0;
//             Ventana.CLOSE;
//             ColumnOffset := NoOfColumns;
//         end else begin
//             Ventana.OPEN('Comprobando Proveedor y cliente #########1##');
//             if Rec.GETFILTER("Filtro Fecha") = '' THEN Rec.SETRANGE("Filtro Fecha", CALCDATE('PA+1D-2A', TODAY), CALCDATE('PA-1A', TODAY));
//             if Rec.FindFirst() then
//                 repeat
//                     if Rec."Source Type" = Rec."Source Type"::Customer Then begin
//                         R18.Get(Rec."Source No.");
//                         Rec."Saldo en otra empresa" := SaldoOtrEC(r18);
//                         Rec.Modify();
//                     end;
//                     if Rec."Source Type" = Rec."Source Type"::Vendor Then begin
//                         R23.Get(Rec."Source No.");
//                         Rec."Saldo en otra empresa" := SaldoOtrEP(r23);
//                         Rec.Modify();
//                     end;
//                 Until Rec.Next() = 0;
//             Ventana.Close();
//         end;

//     END;

//     PROCEDURE DrillDown(a: Integer)
//     VAR
//         r17: Record "G/L Entry";
//         r17t: Record "G/L Entry" TEMPORARY;
//     BEGIN
//         // r17.SETCURRENTKEY(
//         // "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
//         r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
//         r17.SETRANGE(r17."G/L Account No.", ColumnCaptions[a]);//, ColumnCaptions[a] + '999999');
//         r17.SETFILTER("Source Type", '%1|%2', Rec."Source Type", Rec."Source Type"::"Fixed Asset");
//         r17.SETRANGE(r17."IC Partner Code", '');
//         r17.SETRANGE(r17."Source No.", Rec."Source No.");
//         Rec.COPYFILTER("Document Type", r17."Document Type");
//         Rec.COPYFILTER("Filtro Fecha", r17."Posting Date");
//         if r17.FINDFIRST THEN
//             REPEAT
//                 r17t := r17;
//                 if r17t.INSERT THEN;
//             UNTIL r17.NEXT = 0;
//         r17.SETRANGE(r17."IC Partner Code", Rec."IC Partner");
//         r17.SETRANGE(r17."Source No.");
//         if r17.FINDFIRST THEN
//             REPEAT
//                 r17t := r17;
//                 if r17t.INSERT THEN;
//             UNTIL r17.NEXT = 0;
//         COMMIT;
//         //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
//         //if r17.FINDFIRST THEN BEGIN
//         Page.RUNMODAL(0, r17t);
//     END;

//     PROCEDURE Nombre(VAR r50889: Record "Saldo Interempresa"): Text[50];
//     BEGIN
//         if r50889."Source Type" = r50889."Source Type"::Vendor THEN
//             if r23.GET(r50889."Source No.") THEN EXIT(r23.Name);
//         if r50889."Source Type" = r50889."Source Type"::Customer THEN
//             if r18.GET(r50889."Source No.") THEN EXIT(r18.Name);
//     END;

//     PROCEDURE Apunte(Cuenta: Text[30]; Contra: Text[30]; Debe: Decimal; Haber: Decimal; Fecha: Date; Doc: Text[30]; Des: Text[30]);
//     VAR
//         r81: Record "Gen. Journal Line";
//         a: Integer;
//         r81I: Record "Gen. Journal Line";
//         rBis: Record 220;
//     BEGIN
//         if Contra = Cuenta THEN EXIT;
//         rBis.CHANGECOMPANY('Consolidacion');
//         rBis.SETRANGE(rBis."Company Name", COMPANYNAME);
//         rBis.FINDFIRST;
//         r81.SETRANGE(r81."Journal Template Name", 'GENERAL');
//         r81.SETRANGE("Journal Batch Name", 'INTER');
//         if r81.FINDLAST THEN
//             a := r81."Line No." + 10000
//         ELSE
//             a := 10000;
//         r81.VALIDATE(r81."Journal Template Name", 'GENERAL');
//         r81.VALIDATE(r81."Journal Batch Name", 'GENERICO');
//         r81.VALIDATE(r81."Line No.", a);
//         r81.VALIDATE(r81."Account Type", r81."Account Type"::"G/L Account");
//         r81."Account No." := Contra;
//         r81.VALIDATE(r81."Posting Date", Fecha);
//         r81.VALIDATE(r81."Document No.", Doc);
//         r81.VALIDATE(r81.Description, Des);
//         if Haber <> 0 THEN
//             r81.VALIDATE(r81."Debit Amount", Haber);
//         if Debe <> 0 THEN
//             r81.VALIDATE(r81."Credit Amount", Debe);
//         r81I.CHANGECOMPANY('Consolidacion');
//         r81I.SETRANGE(r81I."Journal Template Name", 'GENERAL');
//         r81I.SETRANGE("Journal Batch Name", 'GENERICO');
//         if r81I.FINDLAST THEN
//             a := r81I."Line No." + 10000
//         ELSE
//             a := 10000;
//         r81I := r81;
//         r81I."Line No." := a;
//         r81I."Business Unit Code" := rBis.Code;
//         r81I.Eliminaciones := TRUE;
//         r81I.INSERT;

//         r81.VALIDATE(r81."Journal Template Name", 'GENERAL');
//         r81.VALIDATE(r81."Journal Batch Name", 'GENERICO');
//         r81.VALIDATE(r81."Line No.", a + 10000);
//         r81.VALIDATE(r81."Account Type", r81."Account Type"::"G/L Account");
//         r81."Account No." := Cuenta;
//         r81.VALIDATE(r81."Posting Date", Fecha);
//         r81.VALIDATE(r81."Document No.", Doc);
//         r81.VALIDATE(r81.Description, Des);
//         if Haber <> 0 THEN
//             r81.VALIDATE(r81."Credit Amount", Haber);
//         if Debe <> 0 THEN
//             r81.VALIDATE(r81."Debit Amount", Debe);
//         r81I.CHANGECOMPANY('Consolidacion');
//         r81I.SETRANGE(r81I."Journal Template Name", 'GENERAL');
//         r81I.SETRANGE("Journal Batch Name", 'GENERICO');
//         if r81I.FINDLAST THEN
//             a := r81I."Line No." + 10000
//         ELSE
//             a := 10000;
//         r81I := r81;
//         r81I."Line No." := a;
//         r81I."Business Unit Code" := rBis.Code;
//         r81I.Eliminaciones := TRUE;
//         r81I.INSERT;
//     END;

//     PROCEDURE CuentaCP(VAR r50889: Record "Saldo Interempresa"): Text[30];
//     BEGIN
//         if r50889."Source Type" = r50889."Source Type"::Vendor THEN BEGIN
//             r23.GET(r50889."Source No.");
//             rGrp.GET(r23."Vendor Posting Group");
//             r15.GET(rGrp."Payables Account");
//             EXIT(CuentaG(r15));
//         END;
//         if r50889."Source Type" = r50889."Source Type"::Customer THEN BEGIN
//             r18.GET(r50889."Source No.");
//             rGrc.GET(r18."Customer Posting Group");
//             r15.GET(rGrc."Receivables Account");
//             EXIT(CuentaG(r15));
//         END;
//     END;

//     PROCEDURE CuentaG(VAR r15: Record 15): Text[30];
//     BEGIN
//         EXIT(r15."Consol. Debit Acc.");
//     END;

//     PROCEDURE SaldoOtrEP(r23: Record 23): Decimal;
//     VAR
//         r17: Record "G/L Entry";
//         r18: Record Customer;
//         rIc: Record 413;
//         rComp: Record 79;
//         Importe: Decimal;
//     BEGIN
//         rComp.GET;
//         r17.SETCURRENTKEY(
//         "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
//         if r23."IC Partner Code" = '' THEN
//             ERROR('El Proveedor %1 no tiene código de partner', r23."No.");
//         rIc.GET(r23."IC Partner Code");
//         if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
//             r18.CHANGECOMPANY(rIc."Inbox Details");
//             r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
//             //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
//             //rIc."Inbox Details",rComp."IC Partner Code");
//             if r18.FINDFIRST THEN BEGIN
//                 r17.CHANGECOMPANY(rIc."Inbox Details");
//                 r17.Setfilter("Posting Date", FiltroFecha);
//                 r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
//                 r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
//                 r17.SETRANGE(r17."IC Partner Code", '');
//                 r17.SETRANGE(r17."Source No.", r18."No.");
//                 //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
//                 if r17.FINDFIRST THEN BEGIN
//                     r17.CALCSUMS(r17.Amount);
//                     Importe := (r17.Amount);
//                 END;
//                 r17.SETCURRENTKEY(
//                 "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
//                 r17.Setfilter("Posting Date", FiltroFecha);
//                 r17.SETRANGE(r17."Source No.");
//                 r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
//                 if r17.FINDFIRST THEN BEGIN
//                     r17.CALCSUMS(r17.Amount);
//                     Importe += (r17.Amount);
//                 END;
//             END;
//         END;
//         EXIT(Importe);
//     END;

//     PROCEDURE SaldoOtrEC(r23: Record 18): Decimal;
//     VAR
//         r17: Record "G/L Entry";
//         r18: Record Vendor;
//         rIc: Record 413;
//         rComp: Record 79;
//         Importe: Decimal;
//     BEGIN
//         rComp.GET;
//         r17.SETCURRENTKEY(
//         "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
//         if r23."IC Partner Code" = '' THEN
//             ERROR('El Cliente %1 no tiene código de partner', r23."No.");
//         rIc.GET(r23."IC Partner Code");
//         if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
//             r18.CHANGECOMPANY(rIc."Inbox Details");
//             r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
//             //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
//             //rIc."Inbox Details",rComp."IC Partner Code");
//             if r18.FINDFIRST THEN BEGIN
//                 r17.CHANGECOMPANY(rIc."Inbox Details");
//                 r17.Setfilter("Posting Date", FiltroFecha);
//                 r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
//                 //r17.SETRANGE(r17."Source Type",r17."Source Type"::Vendor);
//                 //r17.SETRANGE(r17."Source No.",r18."No.");
//                 r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Vendor, r17."Source Type"::"Fixed Asset");
//                 r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         Importe += r17.Amount;
//                     UNTIL r17.NEXT = 0;
//                 r17.SETRANGE(r17."IC Partner Code", '');
//                 r17.SETRANGE(r17."Source No.", r18."No.");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         Importe += r17.Amount;
//                     UNTIL r17.NEXT = 0;
//             END;
//         END;
//         EXIT(Importe);
//     END;

//     PROCEDURE DrillOtrEP(r23: Record 23);
//     VAR
//         r17: Record "G/L Entry";
//         r18: Record Customer;
//         rIc: Record 413;
//         rComp: Record 79;
//         r17t: Record "G/L Entry" TEMPORARY;
//     BEGIN
//         rComp.GET;
//         r17.SETCURRENTKEY(
//         "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
//         if r23."IC Partner Code" = '' THEN
//             ERROR('El Proveedor %1 no tiene código de partner', r23."No.");
//         rIc.GET(r23."IC Partner Code");
//         if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
//             r18.CHANGECOMPANY(rIc."Inbox Details");
//             r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
//             //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
//             //rIc."Inbox Details",rComp."IC Partner Code");
//             if r18.FINDFIRST THEN BEGIN
//                 r17.CHANGECOMPANY(rIc."Inbox Details");
//                 COPYFILTER("Filtro Fecha", r17."Posting Date");
//                 r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
//                 //r17.SETRANGE(r17."Source Type",r17."Source Type"::Customer);
//                 //r17.SETRANGE(r17."Source No.",r18."No.");
//                 r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Customer, r17."Source Type"::"Fixed Asset");
//                 r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         r17t := r17;
//                         r17t.INSERT;
//                     UNTIL r17.NEXT = 0;
//                 r17.SETRANGE(r17."IC Partner Code", '');
//                 r17.SETRANGE(r17."Source No.", r18."No.");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         r17t := r17;
//                         r17t.INSERT;
//                     UNTIL r17.NEXT = 0;
//                 COMMIT;
//                 //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
//                 //if r17.FINDFIRST THEN BEGIN
//                 Page.RUNMODAL(0, r17t);
//                 //END;
//             END;
//         END;
//     END;

//     PROCEDURE DrillOtrEC(r23: Record 18);
//     VAR
//         r17: Record "G/L Entry";
//         r18: Record Vendor;
//         rIc: Record 413;
//         rComp: Record 79;
//         r17t: Record "G/L Entry" TEMPORARY;
//     BEGIN
//         rComp.GET;
//         r17.SETCURRENTKEY(
//         "G/L Account No.", "Source Type", "IC Partner Code", "Posting Date", "Document Type", "Gen. Posting Type");
//         if r23."IC Partner Code" = '' THEN
//             ERROR('El Cliente %1 no tiene código de partner', r23."No.");
//         rIc.GET(r23."IC Partner Code");
//         if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
//             r18.CHANGECOMPANY(rIc."Inbox Details");
//             r18.SETRANGE(r18."IC Partner Code", rComp."IC Partner Code");
//             //if NOT r18.FINDFIRST THEN MESSAGE('En la empresa %1 no hay ningún cliente con el Código de partner %2',
//             //rIc."Inbox Details",rComp."IC Partner Code");
//             if r18.FINDFIRST THEN BEGIN
//                 r17.CHANGECOMPANY(rIc."Inbox Details");
//                 COPYFILTER("Filtro Fecha", r17."Posting Date");
//                 r17.SETRANGE(r17."G/L Account No.", '6', '79999999999');
//                 //r17.SETRANGE(r17."Source Type",r17."Source Type"::Vendor);
//                 //r17.SETRANGE(r17."Source No.",r18."No.");
//                 r17.SETFILTER(r17."Source Type", '%1|%2', r17."Source Type"::Vendor, r17."Source Type"::"Fixed Asset");
//                 r17.SETRANGE(r17."IC Partner Code", r18."IC Partner Code");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         r17t := r17;
//                         r17t.INSERT;
//                     UNTIL r17.NEXT = 0;
//                 r17.SETRANGE(r17."IC Partner Code", '');
//                 r17.SETRANGE(r17."Source No.", r18."No.");
//                 if r17.FINDFIRST THEN
//                     REPEAT
//                         r17t := r17;
//                         r17t.INSERT;
//                     UNTIL r17.NEXT = 0;
//                 COMMIT;

//                 //r17.SETFILTER("Document Type",'%1|%2|%3',"Document Type"::Invoice,"Document Type"::"Credit Memo","Document Type"::Albarán);
//                 //if r17.FINDFIRST THEN BEGIN
//                 Page.RUNMODAL(0, r17t);
//                 //END;
//             END;
//         END;
//     END;

// }
page 50011 "Comprobación Clientes/Prov In"
{
    PageType = Card;
    UsageCategory = Tasks;
    ApplicationArea = All;
    SourceTable = Company;
    SourceTableView = SORTING(Name);
    SaveValues = true;
    //WHERE(InterEmpresas=CONST(Yes));
    SourceTableTemporary = true;


    layout
    {
        area(content)
        {
            group(Cabecera)
            {
                field("Filtro Fecha"; "Filtro Fecha")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    BEGIN
                        Calcula;
                    END;
                }

                // field(Empresa0; Copystr(Empresa(0),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa1; Copystr(Empresa(1),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa2; Copystr(Empresa(2),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa3; Copystr(Empresa(3),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa4; Copystr(Empresa(4),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa5; Copystr(Empresa(5),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa6; Copystr(Empresa(6),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa7; Copystr(Empresa(7),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa8; Copystr(Empresa(8),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa9; Copystr(Empresa(9),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa10; Copystr(Empresa(10),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa11; Copystr(Empresa(11),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa12; Copystr(Empresa(12),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa13; Copystr(Empresa(13),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa14; Copystr(Empresa(14),1,3)) { Caption = ''; ApplicationArea = All; }
                // field(Empresa15; Copystr(Empresa(15),1,3)) { Caption = ''; ApplicationArea = All; }

            }
            repeater(Detalle)
            {
                field(Nombre; Rec.Name) { ApplicationArea = All; }
                field(Reservas; Reserva(Rec.Name))
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        if not Control.Permiso_Empresas(Rec.Name) Then begin
                            Message('No tiene permiso en la empresa %1', Rec.name);
                            exit;
                        end;
                        r17.CHANGECOMPANY(Rec.Name);
                        r17.SETCURRENTKEY(r17."G/L Account No.");
                        r17.SETRANGE(r17."G/L Account No.", '113', '113999999');
                        PAGE.RUNMODAL(0, r17);
                    END;
                }
                field(Cliente0; Cliente(0))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(0), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(0);
                    END;
                }
                field(Proveedor0; Proveedor(0))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(0), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(0);
                    END;
                }
                field(Cuenta0; p5230(0))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(0);
                    END;
                }
                field(Cliente1; Cliente(1))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(1), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(1);
                    END;
                }
                field(Proveedor1; Proveedor(1))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(1), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(1);
                    END;
                }
                field(Cuenta1; p5230(1))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(1);
                    END;
                }
                field(Cliente2_; Cliente(2))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(2), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(2);
                    END;
                }
                field(Proveedor2_; Proveedor(2))
                {
                    ApplicationArea = All;
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(2), 1, 3);
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(2);
                    END;
                }
                field(Cuenta2; p5230(2))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(2);
                    END;
                }
                field(Cliente3; Cliente(3))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(3), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(3);
                    END;
                }
                field(Proveedor3; Proveedor(3))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(3), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(3);
                    END;
                }
                field(Cuenta3; p5230(3))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(3);
                    END;
                }
                field(Cliente4; Cliente(4))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(4), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(4);
                    END;
                }
                field(Proveedor4; Proveedor(4))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(4), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(4);
                    END;
                }
                field(Cuenta4; p5230(4))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(4);
                    END;
                }
                field(Cliente5; Cliente(5))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(5), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(5);
                    END;
                }
                field(Proveedor5; Proveedor(5))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(5), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(5);
                    END;
                }
                field(Cuenta5; p5230(5))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(5);
                    END;
                }
                field(Cliente6; Cliente(6))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(6), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(6);
                    END;
                }
                field(Proveedor6; Proveedor(6))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(6), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(6);
                    END;
                }
                field(Cuenta6; p5230(6))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(6);
                    END;
                }
                field(Cliente7; Cliente(7))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(7), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(7);
                    END;
                }
                field(Proveedor7; Proveedor(7))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(7), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(7);
                    END;
                }
                field(Cuenta7; p5230(7))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(7);
                    END;
                }
                field(Cliente8; Cliente(8))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(8), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(8);
                    END;
                }
                field(Proveedor8; Proveedor(8))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(8), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(8);
                    END;
                }
                field(Cuenta8; p5230(8))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(8);
                    END;
                }
                field(Cliente9; Cliente(9))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(9), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(9);
                    END;
                }
                field(Proveedor9; Proveedor(9))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(9), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(9);
                    END;
                }
                field(Cuenta9; p5230(9))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(9);
                    END;
                }
                field(Cliente10; Cliente(10))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(10), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(10);
                    END;
                }
                field(Proveedor10; Proveedor(10))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(10), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(10);
                    END;
                }
                field(Cuenta10; p5230(10))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(10);
                    END;
                }
                field(Cliente11; Cliente(11))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(11), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(11);
                    END;
                }
                field(Proveedor11; Proveedor(11))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(11), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(11);
                    END;
                }
                field(Cuenta11; p5230(11))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(11);
                    END;
                }
                field(Cliente12; Cliente(12))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(12), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(12);
                    END;
                }
                field(Proveedor12; Proveedor(12))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(12), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(12);
                    END;
                }
                field(Cuenta12; p5230(12))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(12);
                    END;
                }
                field(Cliente13; Cliente(13))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(13), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(13);
                    END;
                }
                field(Proveedor13; Proveedor(13))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(13), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(13);
                    END;
                }
                field(Cuenta13; p5230(13))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(13);
                    END;
                }
                field(Cliente14; Cliente(14))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(14), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(14);
                    END;
                }
                field(Proveedor14; Proveedor(14))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(14), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(14);
                    END;
                }
                field(Cuenta14; p5230(14))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(14);
                    END;
                }
                field(Cliente15; Cliente(15))
                {
                    Caption = 'Cliente';
                    CaptionClass = '3,' + 'Cliente ' + Copystr(Empresa(15), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCliente(14);
                    END;
                }
                field(Proveedor15; Proveedor(15))
                {
                    Caption = 'Proveedor';
                    CaptionClass = '3,' + 'Proveedor ' + Copystr(Empresa(15), 1, 3);
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaProvedor(14);
                    END;
                }
                field(Cuenta15; p5230(15))
                {
                    Caption = '5523 5113 5323';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    Begin
                        NavegaCuenta(14);
                    END;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Exportar a Excel")
            {
                ApplicationArea = All;
                Image = Excel;

                trigger OnAction()
                Var
                    RowNo: Integer;
                    ColumnNo: Integer;
                    rEmp: Record "Company Information";
                    //rEmp2 : Record 2000000006;
                    a: Integer;
                    Fichero: Text;
                    Temoblob: Codeunit "Temp Blob";
                    ExcelStream: OutStream;
                    Ints: InStream;
                BEGIN
                    Ventana.OPEN('Procesando Fase ###########1##');
                    EnterCell(1, 1, COMPANYNAME, FALSE, FALSE, TRUE);
                    EnterCell(
                        2,
                        1,
                        'Filtro Fecha: ' + "Filtro Fecha",
                        TRUE,
                        FALSE,
                        FALSE);
                    // {EnterCell(
                    //     2,
                    //     2,
                    //     'Filtro Fecha: '+GETFILTER("Filtro Fecha"),
                    //     TRUE,
                    //     FALSE,
                    //     FALSE); }
                    Ventana.UPDATE(1, 1);
                    RowNo := 3;
                    ColumnNo := 3;
                    EnterCell(
                        3,
                        2,
                        'Reservas',
                        TRUE,
                        FALSE,
                        FALSE);
                    rEmpInter.SetFilter(Name, '<>%1', '');
                    if rEmpInter.FINDFIRST THEN
                        REPEAT
                            EnterCell(
                                RowNo,
                                ColumnNo,
                                rEmpInter.Name,
                                TRUE,
                                FALSE,
                                FALSE);
                            EnterCell(
                                RowNo + 1,
                                ColumnNo,
                                'Cliente',
                                TRUE,
                                FALSE,
                                FALSE);
                            EnterCell(
                                RowNo + 1,
                                ColumnNo + 1,
                                'Proveedor',
                                TRUE,
                                FALSE,
                                FALSE);
                            EnterCell(
                                RowNo + 1,
                                ColumnNo + 2,
                                'Cuenta',
                                TRUE,
                                FALSE,
                                FALSE);

                            ColumnNo := ColumnNo + 3;
                        UNTIL rEmpInter.NEXT = 0;
                    RowNo := 5;
                    ColumnNo := 3;
                    Ventana.UPDATE(1, 2);
                    if rEmpInter.FINDFIRST THEN
                        REPEAT
                            EnterCell(
                                RowNo,
                                1,
                                rEmpInter.Name,
                                TRUE,
                                FALSE,
                                FALSE);
                            EnterCell(
                                RowNo,
                                2,
                                FORMAT(Reserva(rEmpInter.Name)),
                                FALSE,
                                FALSE,
                                FALSE);

                            //rEmp2.SETRANGE(rEmp2.InterEmpresas,TRUE);
                            ColumnNo := 3;
                            a := -1;
                            if rEmpInter2.FINDFIRST THEN
                                REPEAT
                                    a := a + 1;
                                    EnterCell(
                                        RowNo,
                                        ColumnNo,
                                        FORMAT(Clientec(rEmpInter.Name, a)),
                                        FALSE,
                                        FALSE,
                                        FALSE);
                                    EnterCell(
                                        RowNo,
                                        ColumnNo + 1,
                                        FORMAT(Proveedorc(rEmpInter.Name, a)),
                                        TRUE,
                                        FALSE,
                                        FALSE);
                                    EnterCell(
                                        RowNo,
                                        ColumnNo + 2,
                                        FORMAT(p5230c(rEmpInter.Name, a)),
                                        TRUE,
                                        FALSE,
                                        FALSE);

                                    ColumnNo := ColumnNo + 3;

                                UNTIL rEmpInter2.NEXT = 0;
                            RowNo := RowNo + 1;
                        UNTIL rEmpInter.NEXT = 0;
                    RowNo := 3;
                    ColumnNo := 3;
                    Ventana.CLOSE;

                    TempExcelBuffer.CreateNewBook('Saldos');
                    //TempExcelBuffer.CreateSheet('Saldos','Saldos',COMPANYNAME,USERID);
                    //TempExcelBuffer.GiveUserControl;
                    if rEmpInter.FINDFIRST THEN
                        REPEAT
                            TempExcelBuffer.SetCurrent(RowNo, ColumnNo);
                            TempExcelBuffer.StartRange;
                            TempExcelBuffer.SetCurrent(RowNo, ColumnNo + 2);
                            TempExcelBuffer.EndRange;
                            TempExcelBuffer.CreateRange('R' + CONVERTSTR(rEmp."Clave Recursos", ' ', '_'));
                            //TempExcelBuffer.AutoFit('R'+CONVERTSTR(rEmp."Clave Recursos",' ','_'));
                            //TempExcelBuffer.Merge('R'+CONVERTSTR(rEmp."Clave Recursos",' ','_'),Alinear::Centro);
                            //TempExcelBuffer.AutoFit('R'+CONVERTSTR(rEmp."Clave Recursos",' ','_'));
                            ColumnNo := ColumnNo + 3;
                        UNTIL rEmp.NEXT = 0;
                    Ventana.OPEN('Procesando Fase ###########1##');
                    Ventana.UPDATE(1, 1);
                    TempExcelBuffer.VALIDATE("Row No.", 3);
                    TempExcelBuffer.VALIDATE("Column No.", 100);
                    //TempExcelBuffer.AutoFitAll;
                    Ventana.CLOSE;
                    Temoblob.CreateOutStream(ExcelStream);
                    TempExcelBuffer.SetFriendlyFilename('Saldos.xls');
                    TempExcelBuffer.SaveToStream(ExcelStream, true);
                    Temoblob.CreateInStream(Ints);
                    DownloadFromStream(Ints, 'Guardar', 'C:\Temp', 'ALL Files (*.*)|*.*', Fichero);
                    //TempExcelBuffer.GiveUserControl;
                END;
            }
        }
    }
    VAR
        Control: Codeunit ControlProcesos;
        "Filtro Fecha": Text;
        rCli: Record Customer;
        rIc: Record 413 TEMPORARY;
        rMovCli: Record 379;
        rMovPro: Record 380;
        rPro: Record Vendor;
        r325: Record 325 TEMPORARY;
        r15: Record 15;
        r17: Record "G/L Entry";
        rMovCliC: Record 21;
        rMovProC: Record 25;
        TempExcelBuffer: Record 370 TEMPORARY;
        Alinear: Option Derecha,Centro,Izquierda;
        Ventana: Dialog;
        rIc2: Record 413;
        rEmpInter: Record 2000000006 temporary;
        rEmpInter2: Record 2000000006 temporary;
    // glUnion: Label 'UNION AGRICOLA Y TURISTICA, SL';
    // glUATI: Label 'UATI';

    trigger OnOpenPage()
    VAR
        rEmp: Record 2000000006;
        rEmp2: Record "Company Information";
    BEGIN
        if rEmp.Findfirst Then
            Repeat
                if Control.Permiso_Empresas(rEmp.Name) Then begin
                    rEmp2.ChangeCompany(rEmp.Name);
                    if rEmp2.Get() Then begin
                        if rEmp2.InterEmpresas Then begin
                            Rec := rEmp;
                            Rec.Insert;
                            rEmpInter := rEmp;
                            rEmpInter2 := rEmp;
                            rEmpInter.Insert();
                            rEmpInter2.Insert();
                        end;
                    end;
                end;
            Until rEmp.Next() = 0;
        rIc2.FINDFIRST;
        REPEAT
            rIc := rIc2;
            // if rIc.Code = 'UNION' THEN
            //     rIc."Inbox Details" := 'UNION AGRICOLA Y TURISTICA, SL';
            // if rIc.Code = 'UATI' THEN
            //     rIc."Inbox Details" := 'UATI';
            rIc.INSERT;
        UNTIL rIc2.NEXT = 0;
        rEmpInter.Init();

        Calcula;
    END;

    PROCEDURE Empresa(Nxt: Integer): Text[30];
    VAR

    BEGIN

        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInTer.NEXT(Nxt);
        EXIT(rEmpInter.Name);
    END;

    PROCEDURE Cliente2(PName: Text[30]; PName2: Text[30]): Decimal;
    VAR
        rEmp: Record 2000000006;
    BEGIN

        if PName2 <> PName THEN BEGIN
            if not Control.Permiso_Empresas(PName) Then exit(0);
            rIc.SETRANGE(rIc."Inbox Details", PName2);
            rIc.FINDFIRST;
            rCli.CHANGECOMPANY(PName);
            rCli.SETRANGE(rCli."IC Partner Code", rIc.Code);
            if rCli.FINDFIRST THEN BEGIN
                rMovCli.CHANGECOMPANY(PName);
                rMovCli.SETCURRENTKEY(rMovCli."Customer No.", "Posting Date");
                rMovCli.SETRANGE(rMovCli."Customer No.", rCli."No.");
                rMovCli.SETRANGE(rMovCli."Entry Type", rMovCli."Entry Type"::"Initial Entry");
                rMovCli.SETFILTER("Posting Date", "Filtro Fecha");
                if rMovCli.FINDFIRST THEN
                    rMovCli.CALCSUMS(rMovCli."Amount (LCY)")
                ELSE
                    EXIT(0);
                EXIT(rMovCli."Amount (LCY)");
            END;
        END;
        EXIT(0);
    END;

    PROCEDURE Proveedor2(PName: Text[30]; PName2: Text[30]): Decimal;
    VAR
    //rEmp: Record 2000000006;
    BEGIN
        if PName2 <> PName THEN BEGIN
            if not Control.Permiso_Empresas(PName) Then exit(0);
            rIc.SETRANGE(rIc."Inbox Details", PName2);
            rIc.FINDFIRST;
            rPro.CHANGECOMPANY(PName);
            rPro.SETRANGE(rPro."IC Partner Code", rIc.Code);
            if rPro.FINDFIRST THEN BEGIN
                rMovPro.CHANGECOMPANY(PName);
                rMovPro.SETCURRENTKEY(rMovPro."Vendor No.", "Posting Date");
                rMovPro.SETRANGE(rMovPro."Vendor No.", rPro."No.");
                rMovPro.SETRANGE(rMovPro."Entry Type", rMovPro."Entry Type"::"Initial Entry");
                rMovPro.SETFILTER("Posting Date", "Filtro Fecha");
                if rMovPro.FINDFIRST THEN
                    rMovPro.CALCSUMS(rMovPro."Amount (LCY)")
                ELSE
                    EXIT(0);
                EXIT(rMovPro."Amount (LCY)");
            END;
        END;
        EXIT(0);
    END;

    PROCEDURE p5230(Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(rec.Name) Then exit(0);
        rEmp.ChangeCompany(Rec.Name);
        rEmp.Get;
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        if not Control.Permiso_Empresas(rEmpInter.Name) Then exit(0);
        rEmp.CHANGECOMPANY(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."VAT %");
    END;

    PROCEDURE Reserva(PName: Text[30]): Decimal;
    BEGIN
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        r17.CHANGECOMPANY(PName);
        r17.SETCURRENTKEY(r17."G/L Account No.");
        r17.SETRANGE(r17."G/L Account No.", '113', '113999999');
        r17.SetFilter("Posting Date", "Filtro Fecha");
        //COPYFILTER("Filtro Fecha",r17."Posting Date");
        if r17.FINDFIRST THEN
            r17.CALCSUMS(r17.Amount)
        ELSE
            EXIT(0);
        EXIT(r17.Amount);
    END;

    PROCEDURE Cliente(Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        rEmp.ChangeCompany(Rec.Name);
        rEmp.Get;
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        if not Control.Permiso_Empresas(rEmpInter.Name) Then exit(0);
        rEmp.CHANGECOMPANY(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."VAT+EC %");
    END;

    PROCEDURE Proveedor(Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        rEmp.ChangeCompany(Rec.Name);
        rEmp.Get;
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        if not Control.Permiso_Empresas(rEmpInter.Name) Then exit(0);
        rEmp.CHANGECOMPANY(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."EC %");
    END;

    PROCEDURE p52302(PName: Text[30]; PName2: Text[30]): Decimal;
    VAR
        Importe: Decimal;
    BEGIN
        //No afecta solo a la 52302 Tambien a la 5133 y 5323
        Importe := 0;
        if PName2 <> PName THEN BEGIN
            if not Control.Permiso_Empresas(PName) Then exit(0);
            rIc.SETRANGE(rIc."Inbox Details", PName2);
            rIc.FINDFIRST;
            r15.CHANGECOMPANY(PName);
            r15.SETRANGE(r15."IC Partner Code", rIc.Code);
            if r15.FINDFIRST THEN
                REPEAT
                    r17.CHANGECOMPANY(PName);
                    r17.SETCURRENTKEY(r17."G/L Account No.");
                    r17.SETRANGE(r17."G/L Account No.", r15."No.");
                    r17.Setfilter("Posting Date", "Filtro Fecha");
                    if r17.FINDFIRST THEN BEGIN
                        r17.CALCSUMS(r17.Amount);
                        Importe := Importe + r17.Amount;
                    END;
                UNTIL r15.NEXT = 0;
        END;
        EXIT(Importe);
    END;

    PROCEDURE NavegaCliente(Nxt: Integer): Decimal;
    VAR
    //rEmp@1100217001 : Record 2000000006;
    BEGIN
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        rIc.SETRANGE(rIc."Inbox Details", rEmpInter.Name);
        rIc.FINDFIRST;
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        rCli.CHANGECOMPANY(Rec.Name);
        rCli.SETRANGE(rCli."IC Partner Code", rIc.Code);
        if rCli.FINDFIRST THEN BEGIN
            rMovCliC.CHANGECOMPANY(Rec.Name);
            rMovCliC.SETCURRENTKEY(rMovCliC."Customer No.");
            rMovCliC.SETRANGE(rMovCliC."Customer No.", rCli."No.");
            rMovClic.Setfilter("Posting Date", "Filtro Fecha");
            PAGE.RUNMODAL(0, rMovCliC);
        END;
    END;

    PROCEDURE NavegaProvedor(Nxt: Integer): Decimal;
    VAR
    //rEmp@1100217001 : Record 2000000006;
    BEGIN
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        rIc.SETRANGE(rIc."Inbox Details", rEmpInter.Name);
        rIc.FINDFIRST;
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        rPro.CHANGECOMPANY(Rec.Name);
        rPro.SETRANGE(rPro."IC Partner Code", rIc.Code);
        if rPro.FINDFIRST THEN BEGIN
            rMovProC.CHANGECOMPANY(Rec.Name);
            rMovProC.SETCURRENTKEY(rMovProC."Vendor No.");
            rMovProc.Setfilter("Posting Date", "Filtro Fecha");
            rMovProC.SETRANGE(rMovProC."Vendor No.", rPro."No.");
            PAGE.RUNMODAL(0, rMovProC);
        END;
    END;

    PROCEDURE NavegaCuenta(Nxt: Integer): Decimal;
    VAR
        r17t: Record "G/L Entry" Temporary;
    BEGIN
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        rIc.SETRANGE(rIc."Inbox Details", rEmpInter.Name);
        rIc.FINDFIRST;
        if not Control.Permiso_Empresas(Rec.Name) Then exit(0);
        r15.CHANGECOMPANY(Rec.Name);
        r15.SETRANGE(r15."IC Partner Code", rIc.Code);
        if r15.FINDFIRST THEN
            REPEAT
                r17.CHANGECOMPANY(Rec.Name);
                r17.SETCURRENTKEY(r17."G/L Account No.");
                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                r17.Setfilter("Posting Date", "Filtro Fecha");
                if r17.FINDFIRST THEN
                    REPEAT
                        r17t := r17;
                        if r17t.INSERT THEN;
                    UNTIL r17.NEXT = 0;
            UNTIL r15.NEXT = 0;

        PAGE.RUNMODAL(0, r17t);
    END;

    PROCEDURE Calcula();
    VAR
        rEmp: Record "Company Information";
    BEGIN
        r325.RESET;
        r325.DELETEALL;
        rEmpInter.FINDFIRST;
        REPEAT
            rEmpInter2.FINDFIRST;
            REPEAT
                if rEmpInter2.Name <> rEmpInter.Name THEN BEGIN
                    if Control.Permiso_Empresas(rEmpInter.Name) Then begin
                        r325.INIT;
                        rEmp.CHANGECOMPANY(rEmpInter.Name);
                        rEmp.Get();
                        r325."VAT Bus. Posting Group" := rEmp."Clave Recursos";
                        rEmp.CHANGECOMPANY(rEmpInter2.Name);
                        rEmp.Get();
                        r325."VAT Prod. Posting Group" := rEmp."Clave Recursos";
                        r325."VAT+EC %" := Cliente2(rEmpInter.Name, rEmpInter2.Name);
                        r325."EC %" := Proveedor2(rEmpInter.Name, rEmpInter2.Name);
                        r325."VAT %" := p52302(rEmpInter.Name, rEmpInter2.Name);
                        r325.INSERT;
                    end;
                END;
            UNTIL rEmpInter2.NEXT = 0;

        UNTIL rEmpInter.NEXT = 0;
    END;

    LOCAL PROCEDURE EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean);
    BEGIN
        TempExcelBuffer.INIT;
        TempExcelBuffer.VALIDATE("Row No.", RowNo);
        TempExcelBuffer.VALIDATE("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.INSERT;
    END;

    LOCAL PROCEDURE EnterCellFormula(RowNo: Integer; ColumnNo: Integer; Formula: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean);
    BEGIN
        TempExcelBuffer.INIT;
        TempExcelBuffer.VALIDATE("Row No.", RowNo);
        TempExcelBuffer.VALIDATE("Column No.", ColumnNo);
        TempExcelBuffer.SetFormula := Formula;
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.INSERT;
    END;

    PROCEDURE p5230c(PName: Text[30]; Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(PName) Then exit(0);
        rEmp.ChangeCompany(PName);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        rEmp.ChangeCompany(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."VAT %");
    END;

    PROCEDURE Clientec(Pname: Text[30]; Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(PName) Then exit(0);
        rEmp.ChangeCompany(Pname);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmpInter.NEXT(Nxt);
        rEmp.ChangeCompany(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."VAT+EC %");
    END;

    PROCEDURE Proveedorc(Pname: Text[30]; Nxt: Integer): Decimal;
    VAR
        rEmp: Record "Company Information";
    BEGIN
        if not Control.Permiso_Empresas(PName) Then exit(0);
        rEmp.ChangeCompany(Pname);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Bus. Posting Group", rEmp."Clave Recursos");
        rEmpInter.FINDFIRST;
        if Nxt > 0 THEN
            rEmp.NEXT(Nxt);
        rEmp.ChangeCompany(rEmpInter.Name);
        rEmp.Get();
        r325.SETRANGE(r325."VAT Prod. Posting Group", rEmp."Clave Recursos");
        if r325.FINDFIRST THEN EXIT(r325."EC %");
    END;


}


