/// <summary>
/// Page Ficha conciliacion cuentas (ID 7001192).
/// </summary>
page 50059 "Ficha conciliacion cuentas"
{
    //Version List=FH3.70;
    PageType = List;
    UsageCategory = Lists;
    Permissions = TableData 17 = rm;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = 17;
    DataCaptionExpression = Rec."G/L Account No.";
    SourceTableView = SORTING("G/L Account No.", "Posting Date");

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("Nombre Cuenta"; Nom_Cuenta(Rec."G/L Account No.")) { ApplicationArea = All; }
            }
            repeater(Detalle)
            {
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; StyleExpr = Color; }
                // OnFormat=VAR
                //    ImpCon : Decimal;
                //  BEGIN
                //    FontBold := "Usuario conciliacion" = UPPERCASE(USERID);
                //    CurrPage."Posting Date".UPDATEFONTBOLD(FontBold);
                //    Color := 0;
                //    if "Importe pendiente" = 0 THEN
                //      Color := 35840
                //    ELSE if "Importe pendiente" <> Amount THEN
                //      Color := 16711680
                //    ELSE if NOT ("Usuario conciliacion" IN [UPPERCASE(USERID), '']) THEN
                //      Color := 255;
                //    if Color <> 0 THEN
                //      CurrPage."Posting Date".UPDATEFORECOLOR(Color);
                //    if Marca<>'' THEN
                //      CurrPage."Posting Date".UPDATEFONTBOLD:=(FALSE);
                //  END;
                //   }
                field("Document Type"; Rec."Document Type") { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("External Document No."; Rec."External Document No.") { ApplicationArea = All; StyleExpr = Color; }
                field("Tax Area Code"; Rec."Tax Area Code") { ApplicationArea = All; Caption = 'Nº Albarán'; }


                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code") { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field(Pendiente; Rec.Pendiente) { ApplicationArea = All; ShowCaption = false; }

                field(Descriptio; Rec.Description) { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field("Debit Amount"; Rec."Debit Amount") { ApplicationArea = All; StyleExpr = Color; }
                field("Credit Amount"; Rec."Credit Amount") { ApplicationArea = All; StyleExpr = Color; }
                field("Importe pendiente"; Rec."Importe pendiente")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                    trigger OnDrillDown()
                    VAR
                        rMovCon: Record "Mov. Conciliacion cuenta";
                    BEGIN
                        if Rec.GETFILTER("Filtro fecha conciliación") <> '' THEN BEGIN
                            rMovCon.SETCURRENTKEY("Fecha conciliacion");
                            Rec.COPYFILTER("Filtro fecha conciliación", rMovCon."Fecha conciliacion");
                        END;
                        rMovCon.SETRANGE(rMovCon."Nº Mov.", Rec."Entry No.");
                        if rMovCon.FINDFIRST THEN BEGIN
                            rMovCon.SETRANGE("Nº Conciliacion", rMovCon."Nº Conciliacion");
                            rMovCon.SETRANGE(rMovCon."Nº Mov.");
                        END;
                        PAGE.RUNMODAL(Page::"Movs. Conciliacion cuenta", rMovCon);
                    END;
                }
                field("Importe a conciliar"; Rec."Importe a conciliar")
                {
                    Caption = 'Importe a conciliar';
                    ApplicationArea = All;
                    StyleExpr = Color;
                    trigger OnValidate()
                    VAR
                        rMovCon: Record "Mov. Conciliacion cuenta";
                    BEGIN
                        if Rec."Usuario conciliacion" <> UPPERCASE(USERID) THEN
                            ERROR('Antes de cambiar %1 debe marcar el %1 para conciliar.', Rec.FIELDNAME("Importe a conciliar"), Rec.TABLENAME);
                        if cFun.Conciliado(Rec."Entry No.", Rec.Amount) THEN
                            ERROR('El movimiento ya está conciliado.');
                        if ((Rec."Importe a conciliar" > 0) AND (Rec.Amount < 0)) OR
                           ((Rec."Importe a conciliar" < 0) AND (Rec.Amount > 0)) THEN
                            ERROR('%1 y %2 deben ser del mismo signo.', Rec.FIELDNAME("Importe a conciliar"), Rec.FIELDNAME(Amount));
                        if ABS(Rec."Importe a conciliar") > ABS(Rec."Importe pendiente") THEN
                            ERROR('El %1 no puede ser mayor que el %2.', Rec.FIELDNAME("Importe a conciliar"), Rec.FIELDNAME("Importe pendiente"));
                        if xRec."Importe a conciliar" <> Rec."Importe a conciliar" THEN
                            SaldoLiq := SaldoLiq + Rec."Importe a conciliar" - xRec."Importe a conciliar";
                    END;
                }
                field(MostrarSald; MostrarSaldo())
                {
                    ApplicationArea = All;
                    Visible = false;
                    StyleExpr = Color;
                    Editable = false;
                    Caption = 'Saldo';

                    AutoFormatType = 1;
                }
                field(Amoun; Rec.Amount) { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field("Add.-Currency Debit Amount"; Rec."Add.-Currency Debit Amount") { ApplicationArea = All; Editable = false; StyleExpr = Color; }

                field("Add.-Currency Credit Amount"; Rec."Add.-Currency Credit Amount") { ApplicationArea = All; Editable = false; StyleExpr = Color; }
                field("Usuario conciliacion"; Rec."Usuario conciliacion") { ApplicationArea = All; Editable = false; StyleExpr = Color; }
                field("Document Date"; Rec."Document Date") { ApplicationArea = All; Editable = false; StyleExpr = Color; }
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; StyleExpr = Color; }
                field("Source Type"; Rec."Source Type") { ApplicationArea = All; Editable = false; StyleExpr = Color; }
                field("Source No."; Rec."Source No.") { ApplicationArea = All; Editable = false; StyleExpr = Color; }
                field(Liq_por_Num_Do; Liq_por_Num_Doc())
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                    StyleExpr = Color;
                    trigger OnLookup(var Text: Text): Boolean
                    VAR
                        rHisCabAlbComp: Record "Purch. Rcpt. Header";
                        rHisCabFacComp: Record "Purch. Inv. Header";
                        rHisCabAboComp: Record "Purch. Cr. Memo Hdr.";
                        rMovProv: Record 25;
                    BEGIN
                        if rHisCabAlbComp.GET(Rec."Document No.") THEN
                            CASE rHisCabAlbComp."Applies-to Doc. Type" OF
                                rHisCabAlbComp."Applies-to Doc. Type"::Invoice:
                                    BEGIN
                                        if rHisCabFacComp.GET(rHisCabAlbComp."Applies-to Doc. No.") THEN
                                            PAGE.RUNMODAL(PAGE::"Posted Purchase Invoice", rHisCabFacComp)
                                        ELSE BEGIN
                                            rHisCabFacComp.SETCURRENTKEY("Pre-Assigned No.");
                                            rHisCabFacComp.SETRANGE("Pre-Assigned No.", rHisCabAlbComp."Applies-to Doc. No.");
                                            if rHisCabFacComp.FIND('-') THEN
                                                PAGE.RUNMODAL(PAGE::"Posted Purchase Invoice", rHisCabFacComp)
                                            ELSE BEGIN
                                                rMovProv.SETCURRENTKEY("Document Type", "Document No.", "Vendor No.");
                                                rMovProv.SETRANGE("Document Type", rMovProv."Document Type"::Invoice);
                                                rMovProv.SETRANGE("Document No.", rHisCabAlbComp."Applies-to Doc. No.");
                                                rMovProv.SETRANGE("Vendor No.", rHisCabAlbComp."Buy-from Vendor No.");
                                                if rMovProv.FIND('-') THEN
                                                    PAGE.RUNMODAL(0, rMovProv)
                                                ELSE
                                                    ERROR(Text050, rHisCabFacComp.TABLECAPTION, rMovProv.TABLECAPTION, rHisCabAlbComp."Applies-to Doc. Type",
                                                      rHisCabAlbComp."Applies-to Doc. No.");
                                            END;
                                        END;
                                    END;
                                rHisCabAlbComp."Applies-to Doc. Type"::"Credit Memo":
                                    BEGIN
                                        if rHisCabAboComp.GET(rHisCabAlbComp."Applies-to Doc. No.") THEN
                                            PAGE.RUNMODAL(PAGE::"Posted Purchase Credit Memo", rHisCabAboComp)
                                        ELSE BEGIN
                                            rHisCabAboComp.SETCURRENTKEY("Pre-Assigned No.");
                                            rHisCabAboComp.SETRANGE("Pre-Assigned No.", rHisCabAlbComp."Applies-to Doc. No.");
                                            if rHisCabAboComp.FIND('-') THEN
                                                PAGE.RUNMODAL(PAGE::"Posted Purchase Credit Memo", rHisCabAboComp)
                                            ELSE BEGIN
                                                rMovProv.SETCURRENTKEY("Document Type", "Document No.", "Vendor No.");
                                                rMovProv.SETRANGE("Document Type", rMovProv."Document Type"::"Credit Memo");
                                                rMovProv.SETRANGE("Document No.", rHisCabAlbComp."Applies-to Doc. No.");
                                                rMovProv.SETRANGE("Vendor No.", rHisCabAlbComp."Buy-from Vendor No.");
                                                if rMovProv.FIND('-') THEN
                                                    PAGE.RUNMODAL(0, rMovProv)
                                                ELSE
                                                    ERROR(Text050, rHisCabAboComp.TABLECAPTION, rMovProv.TABLECAPTION, rHisCabAlbComp."Applies-to Doc. Type",
                                              rHisCabAlbComp."Applies-to Doc. No.");
                                            END;
                                        END;
                                    END;
                            END;
                    END;
                }


                field(SaldoCta; SaldoCta)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Saldo Cuenta';
                }
                field(SaldoLiq; SaldoLiq)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Saldo Marcado';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&Conciliación")
            {

                Caption = '&Conciliación';

                action(Marcar)
                {
                    ApplicationArea = All;
                    Image = Select;
                    ShortCutKey = F9;
                    Caption = 'Marcar';
                    trigger OnAction()
                    BEGIN
                        Marcar_Registros(Rec);
                    END;
                }
                action("Marcar Principal")
                {
                    ApplicationArea = All;
                    ShortCutKey = 'Ctrl+F9';
                    Caption = 'Marcar Principal';
                    trigger OnAction()
                    BEGIN
                        if Rec.Marca <> 'E' THEN Rec.Marca := 'E' ELSE Rec.Marca := '';
                        Rec.MODIFY;
                    END;
                }
                action("Conciliate")
                {
                    ApplicationArea = All;
                    ShortCutKey = F5;
                    Caption = 'Conciliar';
                    trigger OnAction()
                    VAR
                        rMov: Record "G/L Entry";
                        rMovTMP: Record "G/L Entry" TEMPORARY;
                    BEGIN
                        // PLB 15/02/2007
                        //cFun.Conciliar_Registros('', Rec, TRUE);
                        rMov.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion", Pendiente, "Document Type", "Document No.");
                        rMov.SETRANGE(rMov."G/L Account No.", Rec."G/L Account No.");
                        rMov.SETRANGE(rMov."Usuario conciliacion", Rec."Usuario conciliacion");
                        rMov.SETFILTER(rMov.Marca, '<>%1', '');
                        if rMov.COUNT <> 1 THEN ERROR('Debe Marcar un Mov y solo 1 como principal');
                        cFun.Conciliar_Manual(Rec);
                        Actualizar_Saldos;
                    END;
                }
                action("undo conciliation")
                {
                    ApplicationArea = All;
                    ShortCutKey = 'Ctrl+F5';
                    Caption = 'Desconciliar';
                    trigger OnAction()
                    BEGIN
                        cFun.Desconciliar_Registros(Rec);
                        Actualizar_Saldos;
                    END;
                }
                action("automatic conciliation")
                {
                    ApplicationArea = All;
                    ShortCutKey = F11;
                    Caption = 'Conciliacion automatica';
                    trigger OnAction()
                    BEGIN
                        cFun.Conciliacion_Automatica(Rec."G/L Account No.");
                        Actualizar_Saldos;
                    END;
                }
                action("mark ledger entry related")
                {
                    ApplicationArea = All;
                    ShortCutKey = F6;
                    Caption = 'Marcar movs. Relacionados';
                    trigger OnAction()
                    BEGIN
                        Marcar_Relacionados;
                    END;
                }
                // action("Extracto movimientos")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Extracto movimientos';
                //     trigger OnAction()
                //     BEGIN
                //         REPORT.RUN(REPORT::"Order per", TRUE, FALSE, Rec);
                //     END;
                // }
                group("Ver")
                {
                    Caption = 'Ver';
                    action("Todos")
                    {
                        ApplicationArea = All;
                        ShortCutKey = 'Ctrl+T';
                        Caption = 'Todos';
                        trigger OnAction()
                        BEGIN
                            wVerRegistros := wVerRegistros::Todos;
                            ActualizaVista;
                        END;
                    }
                    action("No pendientes")
                    {
                        ApplicationArea = All;
                        ShortCutKey = 'Ctrl+N';
                        Caption = 'No pendientes';
                        trigger OnAction()
                        BEGIN
                            wVerRegistros := wVerRegistros::"No Pendientes";
                            ActualizaVista;
                        END;
                    }
                    action("Pendientes")
                    {
                        ApplicationArea = All;
                        ShortCutKey = 'Ctrl+P';
                        Caption = 'Pendientes';
                        trigger OnAction()
                        BEGIN
                            wVerRegistros := wVerRegistros::Pendientes;
                            ActualizaVista;
                        END;
                    }
                }
                action("Forzar Desconciliar")
                {
                    ApplicationArea = All;
                    Caption = 'Forzar Desconciliar';
                    trigger OnAction()
                    VAR
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        if r17.FINDFIRST THEN
                            REPEAT
                                r17.Pendiente := TRUE;
                                r17."Importe pendiente" := r17.Amount;
                                r17.MODIFY;
                            UNTIL r17.NEXT = 0;
                    END;
                }
                action("Conciliar Poveedor")
                {
                    ApplicationArea = All;
                    Caption = 'Conciliar Poveedor';
                    trigger OnAction()
                    BEGIN
                        // PLB 15/02/2007
                        //cFun.Conciliar_Registros('', Rec, TRUE);
                        cFun.Conciliacion_Proveedor(Rec."G/L Account No.", Rec."Source No.");
                        Actualizar_Saldos;
                    END;
                }
                action("Marcar Seleccionados")
                {
                    ApplicationArea = All;
                    Caption = 'Marcar Seleccionados';
                    trigger OnAction()
                    VAR
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        if r17.FINDFIRST THEN
                            REPEAT
                                Marcar_Registros(r17);
                            UNTIL r17.NEXT = 0;
                    END;
                }
                action("Buscar Proveedores a 0")
                {
                    ApplicationArea = All;
                    Caption = 'Buscar Proveedores a 0';
                    trigger OnAction()
                    VAR
                        rMov: Record "G/L Entry";
                    BEGIN
                        rMov.RESET;
                        rMov.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.");
                        rMov.SETRANGE("G/L Account No.", Rec."G/L Account No.");
                        rMov.SETRANGE(rMov."Source Type", rMov."Source Type"::Vendor);
                        REPEAT
                            if (Rec.Pendiente = TRUE) AND (Rec.Amount <> 0) THEN BEGIN
                                rMov.SETRANGE(rMov."Source No.", Rec."Source No.");
                                if rMov.FIND('-') THEN BEGIN
                                    rMov.CALCSUMS(Amount);
                                    if rMov.Amount = 0 THEN cFun.Conciliacion_Proveedor(rMov."G/L Account No.", rMov."Source No.");
                                    COMMIT;
                                END;
                            END;
                        UNTIL Rec.NEXT = 0;
                        Actualizar_Saldos;
                    END;
                }
                action("Marcar Albaranes")

                {
                    ApplicationArea = All;
                    Caption = 'Marcar Albaranes';
                    trigger OnAction()
                    VAR
                        r123: Record 123;
                        r17: Record "G/L Entry";
                    BEGIN
                        r123.SETRANGE(r123."Document No.", Rec."Document No.");
                        if r123.FINDFIRST THEN
                            REPEAT
                                //Nº albarán AL11-2069: - Pedido: PC11-01290
                                //12345678901
                                //   12345678
                                if COPYSTR(r123.Description, 4, 7) = 'albarán' THEN BEGIN
                                    r17.SETCURRENTKEY(r17."Document No.");
                                    r17.SETRANGE(r17."Document Type", r17."Document Type"::Receipt);
                                    r17.SETRANGE(r17."Document No.", COPYSTR(r123.Description, 12, 9));
                                    r17.SETRANGE(r17."G/L Account No.", Rec."G/L Account No.");
                                    if r17.FINDFIRST THEN
                                        Marcar_Registros(r17);
                                END;
                            UNTIL r123.NEXT = 0;
                    END;
                }
            }
        }
        area(Navigation)
        {
            action("&Navigate")
            {
                ApplicationArea = All;
                Image = Navigate;
                Caption = '&Navegar';
                trigger OnAction()
                BEGIN
                    Navegar.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navegar.RUN;
                END;
            }
            //     { 54  ;OptionButton ;770  ;8800 ;550  ;550  ;
            // FocusOnClick=No;
            // HorzAlign=Center;
            // Border=Yes;
            // FontBold=Yes;
            // BitmapPos=None;
            // CaptionML=ENU='N',
            //         ESP='N';
            // ToolTipML=ENU='display not pendings',
            //         ESP='Ver no pendientes';
            // wVerRegistro;Rec.wVerRegistro
            // OptionValue=No Pendientes;
            // trigger OnAction() BEGIN
            //         ActualizaVista;
            //     END;
            //         }
            //     { 56  ;OptionButton ;1320 ;8800 ;550  ;550  ;
            // FocusOnClick=No;
            // HorzAlign=Center;
            // Border=Yes;
            // FontBold=Yes;
            // BitmapPos=None;
            // CaptionML=ENU='P',
            //         ESP='P';
            // ToolTipML=ENU='display pendigns',
            //         ESP='Ver pendientes';
            // wVerRegistro;Rec.wVerRegistro
            // OptionValue=Pendientes;
            // trigger OnAction() BEGIN
            //         ActualizaVista;
            //     END;
            //         }
            //     { 57  ;OptionButton ;220  ;8800 ;550  ;550  ;
            // FocusOnClick=No;
            // HorzAlign=Center;
            // Border=Yes;
            // FontBold=Yes;
            // BitmapPos=None;
            // CaptionML=ENU='T',
            //         ESP='T';
            // ToolTipML=ENU='display all',
            //         ESP='Ver todos';
            // wVerRegistro;Rec.wVerRegistro
            // OptionValue=Todos;
            // trigger OnAction() BEGIN
            //         ActualizaVista;
            //     END;
            //         }
            // }
        }
    }
    VAR
        Navegar: Page 344;
        SaldoCta: Decimal;
        SaldoLiq: Decimal;
        cFun: Codeunit "Funciones conciliacion cuenta";
        Color: Text;
        FontBold: Boolean;
        "Importe a conciliar": Decimal;
        Text050: Label 'No existe %1 ni %2 para %3 %4.';
        wVerRegistros: option Todos,"No Pendientes",Pendientes;

    trigger OnInit()
    VAR
        rUsr: Record "User Setup";
    BEGIN
        if NOT rUsr.GET(USERID) THEN
            ERROR('El usuario no está registrado en el sistema.');
    END;

    trigger OnOpenPage()
    VAR
        FiltroCuenta: Text[20];
    BEGIN
        FiltroCuenta := Rec.GETRANGEMIN("G/L Account No.");
        Rec.FILTERGROUP(2);
        Rec.SETRANGE("G/L Account No.", FiltroCuenta);
        Rec.FILTERGROUP(0);
        Rec.SETRANGE("G/L Account No.");
    END;

    trigger OnAfterGetRecord()
    BEGIN
        // INC-23651
        // este CALCFIELDS ya no es necesario, estaba para cuando se empezo con la conciliación contable
        //CALCFIELDS("Importe conciliado");
        Rec."Importe pendiente" := Rec.Amount - Rec."Importe conciliado";
        Color := '';
        if Rec."Importe pendiente" = 0 THEN
            Color := 'Favorabe'
        ELSE
            if Rec."Importe pendiente" <> Rec.Amount THEN
                Color := 'Unfavorable'
            ELSE
                if NOT (Rec."Usuario conciliacion" IN [UPPERCASE(USERID), '']) THEN
                    Color := 'Strong';

    END;

    trigger OnAfterGetCurrRecord()
    BEGIN
        if Rec."G/L Account No." <> xRec."G/L Account No." THEN
            Actualizar_Saldos;
    END;

    PROCEDURE Actualizar_Saldos();
    VAR
        rMov: Record "G/L Entry";
        rMovCon: Record "Mov. Conciliacion cuenta";
    BEGIN
        // Actualizar_Saldos
        //
        SaldoCta := 0;
        SaldoLiq := 0;
        rMov.RESET;
        rMov.SETCURRENTKEY("G/L Account No.");
        rMov.SETRANGE("G/L Account No.", Rec."G/L Account No.");
        if rMov.FIND('-') THEN BEGIN
            rMov.CALCSUMS(Amount);
            SaldoCta := rMov.Amount;
        END;
        rMov.RESET;
        rMov.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion");
        rMov.SETRANGE("G/L Account No.", Rec."G/L Account No.");
        rMov.SETRANGE("Usuario conciliacion", UPPERCASE(USERID));
        if rMov.FIND('-') THEN BEGIN
            rMov.CALCSUMS("Importe a conciliar");
            SaldoLiq := rMov."Importe a conciliar";
        END;
    END;

    PROCEDURE Nom_Cuenta(par_Cta: Code[20]): Text[100];
    VAR
        rCta: Record 15;
    BEGIN
        if rCta.GET(par_Cta) THEN
            EXIT(rCta.Name)
        ELSE
            EXIT('');
    END;

    PROCEDURE Marcar_Registros(Var r17: Record "G/L Entry");
    VAR
        rMovCon: Record "Mov. Conciliacion cuenta";
    BEGIN
        // INC-23651
        // PLB 23/05/2007
        WITH r17 DO BEGIN
            rMovCon.RESET;
            rMovCon.SETRANGE("Nº Mov.", "Entry No.");
            rMovCon.CALCSUMS("Importe conciliado");
            if rMovCon."Importe conciliado" <> Amount THEN
                CASE "Usuario conciliacion" OF
                    UPPERCASE(USERID):
                        BEGIN
                            "Usuario conciliacion" := '';
                            "Importe a conciliar" := 0;
                            MODIFY;
                        END;
                    '':
                        BEGIN
                            "Usuario conciliacion" := USERID;
                            // PLB 21/03/2005
                            // teoricamente no haria falta redondear, pero algunos clientes han creado en contabilidad
                            // mas decimales de los que toca, y, al volver a poner los decimales como debe ser, no pueden
                            // conciliar por problemas de redondeo
                            "Importe a conciliar" := ROUND(Amount - rMovCon."Importe conciliado");
                            MODIFY;
                        END;
                END
            // PLB 01/06/2006
            // INC-15885
            //
            ELSE
                if "Usuario conciliacion" <> '' THEN BEGIN
                    "Usuario conciliacion" := '';
                    "Importe a conciliar" := 0;
                    Pendiente := FALSE;
                    MODIFY;
                END;
            // fin PLB
        END;
        Actualizar_Saldos;
        // INC-23651
        // fin PLB
    END;

    PROCEDURE MostrarSaldo(): Decimal;
    VAR
        rCta: Record 15;
        rMov: Record "G/L Entry";
        Saldo: Decimal;
    BEGIN
        // MostrarSaldo
        //
        Saldo := 0;
        rMov.RESET;
        rMov.SETCURRENTKEY("G/L Account No.", "Posting Date");
        rMov.SETRANGE("G/L Account No.", Rec."G/L Account No.");
        rMov.SETFILTER("Posting Date", '<%1', Rec."Posting Date");
        if rMov.FIND('-') THEN BEGIN
            rMov.CALCSUMS(Amount);
            Saldo := rMov.Amount;
        END;
        rMov.RESET;
        rMov.SETCURRENTKEY("G/L Account No.", "Posting Date");
        rMov.SETRANGE("G/L Account No.", Rec."G/L Account No.");
        rMov.SETRANGE("Posting Date", Rec."Posting Date");
        if rMov.FIND('-') THEN
            REPEAT
                if rMov."Entry No." <= Rec."Entry No." THEN BEGIN
                    Saldo := Saldo + rMov.Amount;
                END;
            UNTIL rMov.NEXT = 0;
        EXIT(Saldo);
    END;

    PROCEDURE Marcar_Relacionados();
    VAR
        rMov: Record "G/L Entry";
        rMovCon: Record "Mov. Conciliacion cuenta";
        rMovCon2: Record "Mov. Conciliacion cuenta";
    BEGIN
        // Marcar_Relacionados
        //
        if Rec.MARK = TRUE THEN BEGIN
            Rec.CLEARMARKS;
            EXIT;
        END;
        if Rec."Importe pendiente" <> Rec.Amount THEN BEGIN
            Rec.CLEARMARKS;
            rMov := Rec;
            rMovCon.SETRANGE("Nº Mov.", Rec."Entry No.");
            if rMovCon.FIND('-') THEN
                REPEAT
                    rMovCon2.SETRANGE("Nº Conciliacion", rMovCon."Nº Conciliacion");
                    if rMovCon2.FIND('-') THEN
                        REPEAT
                            Rec.GET(rMovCon2."Nº Mov.");
                            Rec.MARK(TRUE);
                        UNTIL rMovCon2.NEXT = 0;
                UNTIL rMovCon.NEXT = 0;
            Rec := rMov;
        END;
    END;

    PROCEDURE Liq_por_Num_Doc(): Code[20];
    VAR
        rHisCabAlbComp: Record "Purch. Rcpt. Header";
    BEGIN
        if rHisCabAlbComp.GET(Rec."Document No.") THEN
            EXIT(rHisCabAlbComp."Applies-to Doc. No.");
    END;

    PROCEDURE ActualizaVista();
    BEGIN
        CASE wVerRegistros OF
            wVerRegistros::Todos:
                BEGIN
                    // PLB 27/06/2007
                    // INC-23651
                    //SETCURRENTKEY("G/L Account No.", "Posting Date");
                    Rec.SETRANGE(Pendiente);
                END;
            wVerRegistros::"No Pendientes":
                BEGIN
                    // PLB 27/06/2007
                    // INC-23651
                    //SETCURRENTKEY("Posting Date", "G/L Account No.", Pendiente);
                    Rec.SETRANGE(Pendiente, FALSE);
                END;
            wVerRegistros::Pendientes:
                BEGIN
                    // PLB 27/06/2007
                    // INC-23651
                    //SETCURRENTKEY("Posting Date", "G/L Account No.", Pendiente);
                    Rec.SETRANGE(Pendiente, TRUE);
                END;
        END;
        CurrPage.UPDATE(FALSE);
    END;
    //     BEGIN
    //     {
    //       // PLB 21/04/2004
    //       Modificaciones Barcelo:
    //         - Añadidos controles "... procedencia mov."
    //       // PLB 19/07/2004
    //       Modificaciones Barcelo:
    //         - Suprimidos controles duplicados "... procedencia mov."
    //         - Añadidos controles "... divisa-adicional"
    //       // PLB 21/03/2005
    //       // Redondear al marcar movimiento para conciliar
    //       Teoricamente no haria falta redondear, pero algunos clientes han creado en contabilidad
    //       mas decimales de los que toca, y, al volver a poner los decimales como debe ser, no pueden
    //       conciliar por problemas de redondeo
    //       // PLB 01/06/2006
    //       INC-15885
    //       En algunas situaciones al conciliar movimientos (no se ha podido reproducir el error) queda
    //       un movimiento totalmente conciliado pero no elimina la marca "Usuario conciliación" y no deja
    //       a 0 el "Importe a conciliar".
    //       SOLUCION: Se modifica la acción "F9 Marcar" para que si el movimiento está conciliado y marcado
    //       lo desmarque.
    //       // PLB 15/02/2007
    //       INC-18469
    //       =========
    //       Se ha modificado la llamada a la conciliación manual ya que la función ha cambiado de nombre y se
    //       han eliminado dos parámetros
    //       // PLB 21/02/2007
    //       INC-21572
    //       =========
    //       Revisadas claves utilizadas por problema de rendimiento. El problema de rendimiento puede venir
    //       por la visualización del campo "Saldo". Se soluciona ocultando dicho campo.
    //       Se ha aprovechado para realizar cierta limpieza:
    //        - Se han eliminado los campos "Saldo conciliado" y "Saldo pendiente" ya que uno es siempre 0 y el otro
    //          siempre es el mismo que el saldo
    //        - Se formatean correctamente campos que se añadieron hace tiempo
    //        - No se permite modificar el contenido de los campos añadidos
    //        - Se han puesto una gran parte de los campos como no visibles por defecto
    //       // INC-23651
    //       // PLB 23/05/2007
    //        Se ha detectado un problema de rendimiento al marcar con F9 los registros a conciliar manualmente. Parece,
    //       por las pruebas realizadas, que el problema de rendimiento lo ocasiona el SETSELECTIONFILTER ya que, después
    //       de analizar el CLIENT MONITOR que el sistema necesita recorrer toda la tabla para averiguar qué registros
    //       están marcados. La única opción viable para eliminar este problema es eliminar el SETSELECIONFILTER (se ha
    //       probado con el MARKEDONLY, pero tiene el mismo problema) y sólo poder marcar el registro activo.
    //       // PLB 27/06/2007
    //       Para mejorar el rendimiento en los filtros de pendientes, se utilizará siempre la clave
    //       "G/L Account No.","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code","Pendiente"
    //       Se ha verificado que esta clave es mucho más efectiva que la antigua "Posting date","G/L Account No.","Pendiente"
    //     }
    //     END.
    //   }
}
page 50060 "Ficha Conciliaciones cuenta"
{
    //Version List=FH3.70,FINTIS,COC,ES;
    PageType = Card;
    InsertAllowed = false;

    DeleteAllowed = false;
    SourceTable = "Conciliacion cuenta";
    layout
    {
        area(Content)
        {
            group(General)
            {
                // PageNamesML =ENU='General,Creation',
                //  ESP='General,Creación]';
                field("Nº"; Rec."Nº") { ApplicationArea = All; }
                field("Comentario"; Rec.Comentario) { ApplicationArea = All; }
            }
            group("Creación")
            {
                field("Usuario"; Rec.Usuario) { ApplicationArea = All; }
                field("Fecha_Hora"; STRSUBSTNO(Text100, Rec.Fecha, Rec.Hora))
                {

                    ApplicationArea = All;
                    Caption = 'Fecha y hora';

                }
            }
            part(SubForm; "Subf. Conciliacion cuenta")
            {
                SubPageLink = "Nº Conciliacion" = FIELD("Nº");
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Tabla")
            {
                ApplicationArea = All;
                ShortCutKey = F5;
                Caption = '&Tabla';
            }
        }
    }
    VAR
        Text100: Label '%1 a las %2';
}
page 50061 "Tabla conciliacion cuenta"
{
    //Version List=FH3.70,FINTIS,COC,ES;
    InsertAllowed = false;
    DeleteAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Conciliacion cuenta";
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("Nº"; Rec."Nº") { ApplicationArea = All; }
                field("Comentario"; Rec.Comentario) { ApplicationArea = All; }
            }
        }
    }

}
page 50062 "Subf. Conciliacion cuenta"
{
    //Version List=FH3.70,FINTIS,COC,ES;
    Editable = false;
    PageType = ListPart;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Mov. Conciliacion cuenta";
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("Nº Mov."; Rec."Nº Mov.") { ApplicationArea = All; }
                field("Nº Conciliacion"; Rec."Nº Conciliacion") { ApplicationArea = All; }
                field("Importe conciliado"; Rec."Importe conciliado") { ApplicationArea = All; }
                field("Nº cuenta"; Rec."Nº cuenta") { ApplicationArea = All; }
            }
        }
    }
}
page 50063 "Movs. Conciliacion cuenta"
{
    //Version List=FH3.70,FINTIS,COC,ES;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Mov. Conciliacion cuenta";
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("Nº Mov."; Rec."Nº Mov.") { ApplicationArea = All; }
                field("Nº Conciliacion"; Rec."Nº Conciliacion") { ApplicationArea = All; }
                field("Importe conciliado"; Rec."Importe conciliado") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("&Conciliación")
            {
                ApplicationArea = ALL;
                Caption = '&Conciliación';
                RunObject = Page "Ficha Conciliaciones cuenta";
                RunPageLink = Nº = FIELD("Nº Conciliacion");
            }
        }
    }
    PROCEDURE DevolverSeleccionados(Var par_MovCon: Record "Mov. Conciliacion cuenta");
    BEGIN
        // DevolverSeleccionados
        //
        CurrPage.SETSELECTIONFILTER(par_MovCon);
    END;

}