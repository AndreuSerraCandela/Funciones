/// <summary>
/// PageExtension PostedPurchaseInvoice (ID 80242) extends Record Posted Purchase Invoice.
/// </summary>
pageextension 80216 PostedPurchaseInvoice extends "Posted Purchase Invoice"
{
    actions
    {
        addlast("&Invoice")
        {
            action("Reenviar SII")
            {
                ApplicationArea = All;
                Image = SendElectronicDocument;
                trigger OnAction()
                Var
                    GestiónSII: Report "Gestión SII";
                    SalesInv: Record "Purch. Inv. Header";
                    DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                    r114: Record "Purch. Cr. Memo Hdr.";
                BEGIN

                    //-SII1
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    if SalesInv.FINDFIRST THEN
                        REPEAT
                            r114.INIT;
                            GestiónSII.CreateOrUpdateFilePurch(SalesInv, r114, TRUE);
                        //GestiónSII.SetRegeneracion(2,SalesInv."No.",DocType::Invoice,SalesInv."Posting Date",SalesInv."Currency Code",TRUE);
                        //GestiónSII.USEREQUESTFORM:=FALSE;
                        //GestiónSII.RUN;
                        UNTIL SalesInv.NEXT = 0;
                    //+SII1
                END;
            }
            action("Reenviar Modificacion SII")
            {
                ApplicationArea = All;
                Image = SendElectronicDocument;
                Caption = 'Reenviar Modificacion SII';
                trigger OnAction()
                Var
                    GestiónSII: Report "Gestión SII";
                    SalesInv: Record "Purch. Inv. Header";
                    r114: Record "Purch. Cr. Memo Hdr.";
                    DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                BEGIN

                    //-SII1
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    if SalesInv.FINDFIRST THEN
                        REPEAT
                            r114.INIT;
                            GestiónSII.CreateOrUpdateFilePurchA1(SalesInv, r114, TRUE);
                        UNTIL SalesInv.NEXT = 0;
                    //+SII1
                END;
            }
            action("Actualiza Situacion SII")
            {
                ApplicationArea = All;
                Image = Refresh;
                Caption = 'Actualiza Situacion SII';
                trigger OnAction()
                Var
                    rGes: Codeunit "Gestion Proyecto";
                BEGIN
                    CLEAR(rGes);
                    rGes.SiiMensajes;
                END;
            }


        }
        addlast("Actions")
        {
            action("Traspasa Dimensiones")
            {
                ApplicationArea = All;
                Image = CopyDimensions;
                trigger OnAction()
                var
                    ControldeProcesos: Codeunit ControlProcesos;
                begin
                    ControldeProcesos.TraspasaDimensiones(Rec);
                end;

            }

            action("Cambiar Doc. Externo")
            {
                ApplicationArea = All;
                Image = Document;
                trigger OnAction()
                VAR
                    Ventana: Page "Petición datos Agrupación";
                    r38: Record 38;
                    r39: Record 39;
                    r120: Record "Purch. Rcpt. Header";
                    r121: Record "Purch. Rcpt. Line";
                    r122: Record "Purch. Inv. Header";
                    r123: Record 123;
                    r17: Record "G/L Entry";
                    r25: Record 25;
                    r380: Record 380;
                    Vend2: Record Vendor;
                    r254: Record 254;
                    r70002: Record 7000002;
                    r70003: Record 7000003;
                    r70004: Record 7000004;
                    Fac: Text;
                    ControldeProcesos: Codeunit ControlProcesos;
                BEGIN
                    Message('Introduzca Nuevo Num.');
                    Ventana.RunModal();
                    Ventana.Recoge_Des(Fac);
                    // Vend.INPUT(1,Fac);
                    // Vend.CLOSE;
                    if Fac <> '' THEN BEGIN
                        ControldeProcesos.CambiarDocExterno(Rec."No.", Fac);
                    END;
                END;
            }

            //                                                    { ID=1000000004;
            //                                                      CaptionML=ESP=Desglosar;
            //     trigger OnAction()VAR
            //                                                               r113: TEMPORARY Record 123;
            //                                                               rRes: Record 80176;
            //                                                               r113t: TEMPORARY Record 123;
            //                                                               a: Integer;
            //                                                               r111: Record 5110;
            //                                                               r112: Record "Purch. Inv. Header";
            //                                                               r110: Record 5109;
            //                                                               b: Integer;
            //                                                               rDes: Record 7000721;
            //                                                               rRec: Record 156;
            //                                                               r113t2: TEMPORARY Record 123;
            //                                                               c: Integer;
            //                                                               d: Integer;
            //                                                               FI: Date;
            //                                                               FF: Date;
            //                                                               e: Integer;
            //                                                               I: Decimal;
            //                                                               II: Decimal;
            //                                                               Gps: Record 252;
            //                                                               r113O: Record 123;
            //                                                               rJob: Record 167;
            //                                                               Proy: Code[20];
            //                                                               Emp: Text[30];
            //                                                               rDim: Record 349;
            //                                                               GlSetup: Record "General Ledger Setup";
            //                                                               Lin: Integer;
            //                                                             BEGIN
            //                                                               if "Order No."='' THEN EXIT;
            //                                                               r111.SETRANGE(r111."Document Type",r111."Document Type"::Invoice);
            //                                                               r111.SETRANGE(r111."Document No.","No.");
            //                                                               r111.DELETEALL;
            //                                                               if r110.GET(r110."Document Type"::Invoice,"No.") THEN r110.DELETE;
            //                                                               r113O.SETRANGE(r113O."Document No.","No.");
            //                                                               if r113O.FINDFIRST THEN REPEAT
            //                                                                r113:=r113O;
            //                                                                r113.Recurso:=r113O."No.";
            //                                                                if (r113O.Type=r113O.Type::Resource) OR (r113O.Recurso<>'') THEN BEGIN
            //                                                                 if r113O.Recurso<>'' THEN BEGIN
            //                                                                  r113.Type:=r113.Type::Resource;
            //                                                                  r113."No.":=r113O.Recurso;
            //                                                                  r113O.Type:=r113.Type::Resource;
            //                                                                  r113O."No.":=r113O.Recurso;
            //                                                                 END;
            //                                                                 if r113O."Empresa Origen"<>'' THEN
            //                                                                 rRec.CHANGECOMPANY(r113O."Empresa Origen");
            //                                                                 if rRec.GET(r113O."No.") THEN BEGIN
            //                                                                  if (rRec."Empresa Origen"<>COMPANYNAME) AND (rRec."Empresa Origen"<>'') THEN BEGIN
            //                                                                   r113."No.":=rRec."Nº En Empresa origen";
            //                                                                   r113."Empresa Origen":=rRec."Empresa Origen";
            //                                                                   rJob.CHANGECOMPANY(rRec."Empresa Origen");
            //                                                                   rJob.SETRANGE(rJob."Empresa Origen",COMPANYNAME);
            //                                                                   rJob.SETRANGE("Proyecto en empresa Origen",r113O."Job No.");
            //                                                                   rJob.FINDFIRST;
            //                                                                   r113."Proyecto Origen":=rJob."No.";
            //                                                                  END;
            //                                                                  END;
            //                                                                 r113.INSERT;
            //                                                                END;
            //                                                               UNTIL r113O.NEXT=0;
            //                                                               if r113.FINDFIRST THEN REPEAT
            //                                                                if r113."Empresa Origen"<>'' THEN BEGIN
            //                                                                 rRes.CHANGECOMPANY(r113."Empresa Origen");
            //                                                                 Proy:=r113."Proyecto Origen";
            //                                                                END ELSE BEGIN
            //                                                                 rRes.CHANGECOMPANY(COMPANYNAME);
            //                                                                 Proy:="Nº Proyecto";
            //                                                                END;
            //                                                                rRes.SETCURRENTKEY(rRes."Nº Proyecto",rRes."Recurso Agrupado");
            //                                                                rRes.SETRANGE(rRes."Recurso Agrupado",r113."No.");
            //                                                                rRes.SETRANGE(rRes."Nº Proyecto",Proy);
            //                                                                rRes.SETFILTER(rRes."Fecha inicio",'<=%1',r113."Fecha final recurso");
            //                                                                rRes.SETFILTER(rRes."Fecha fin",'>=%1',r113."Fecha inicial recurso");
            //                                                                a:=0;
            //                                                                if rRes.FINDFIRST THEN
            //                                                                 REPEAT
            //                                                                 b:=b+1;
            //                                                                 FI:=rRes."Fecha inicio";
            //                                                                 FF:=rRes."Fecha fin";
            //                                                                 if FI<=r113."Fecha inicial recurso" THEN
            //                                                                    FI:=r113."Fecha inicial recurso";
            //                                                                 FF:=rRes."Fecha fin";
            //                                                                 if FF>=r113."Fecha final recurso" THEN
            //                                                                    FF:=r113."Fecha final recurso";
            //                                                                 d:=FF-FI;
            //                                                                 a:=a+d;
            //                                                                UNTIL rRes.NEXT=0;
            //                                                                b:=0;
            //                                                                if a=0 THEN a:=1;
            //                                                                if rRes.FINDFIRST THEN BEGIN
            //                                                                 REPEAT
            //                                                                 b:=b+1;
            //                                                                 FI:=rRes."Fecha inicio";
            //                                                                 FF:=rRes."Fecha fin";
            //                                                                 if FI<=r113."Fecha inicial recurso" THEN
            //                                                                    FI:=r113."Fecha inicial recurso";
            //                                                                 FF:=rRes."Fecha fin";
            //                                                                 if FF>=r113."Fecha final recurso" THEN
            //                                                                    FF:=r113."Fecha final recurso";
            //                                                                 d:=FF-FI;
            //                                                                 r113t:=r113;
            //                                                                 r113t."Line No.":=r113t."Line No."+b;
            //                                                                 r113t."No.":=rRes."Nº Recurso";
            //                                                                 r113t.Quantity:=r113.Quantity;
            //                                                                 r113t."Direct Unit Cost":=r113."Direct Unit Cost"/a*d;
            //                                                                 r113t."Unit Cost":=r113."Unit Cost"/a*d;
            //                                                                 r113t."Unit Cost (LCY)":=r113."Unit Cost (LCY)"/a*d;
            //                                                                 r113t."Line Discount Amount":=r113."Line Discount Amount"/a*d;
            //                                                                 r113t.Amount:=r113.Amount/a*d;
            //                                                                 r113t."Amount Including VAT":=r113."Amount Including VAT"/a*d;
            //                                                                 r113t."Line Amount":=r113."Line Amount"/a*d;
            //                                                                 if r113."Empresa Origen"<>'' THEN BEGIN
            //                                                                  rRec.CHANGECOMPANY(r113."Empresa Origen");
            //                                                                 END ELSE BEGIN
            //                                                                  rRec.CHANGECOMPANY(COMPANYNAME);
            //                                                                 END;
            //                                                                 rRec.GET(rRes."Nº Recurso");
            //                                                                 r113t."Shortcut Dimension 1 Code":=rRec."Global Dimension 1 Code";
            //                                                                 r113t."Shortcut Dimension 2 Code":=rRec."Global Dimension 2 Code";
            //                                                                 r113t."Shortcut Dimension 3 Code":=rRec."Global Dimension 3 Code";
            //                                                                 r113t."Shortcut Dimension 4 Code":=rRec."Global Dimension 4 Code";
            //                                                                 r113t."Shortcut Dimension 5 Code":=rRec."Global Dimension 5 Code";
            //                                                                 r113t.INSERT;
            //                                                                 UNTIL rRes.NEXT=0;
            //                                                                END ELSE BEGIN
            //                                                                 r113t:=r113;
            //                                                                 r113t.INSERT;
            //                                                                END;
            //                                                               UNTIL r113.NEXT=0;
            //                                                               if r113t.FINDFIRST THEN
            //                                                               REPEAT
            //                                                                 Proy:=r113t."Job No.";
            //                                                                 Lin:=r113t."Linea de proyecto";
            //                                                                 if r113t."Empresa Origen"<>'' THEN BEGIN
            //                                                                  rDes.CHANGECOMPANY(r113t."Empresa Origen");
            //                                                                  Proy:=r113t."Proyecto Origen";
            //                                                                  Lin:=r113t."Linea de proyecto";
            //                                                                 END;
            //                                                                 rDes.SETRANGE(rDes."Job No.",Proy);
            //                                                                 rDes.SETRANGE(rDes."Line No.",Lin);
            //                                                                 a:=rDes.COUNT;
            //                                                                 b:=0;
            //                                                                 if rDes.FINDFIRST THEN
            //                                                                 BEGIN
            //                                                                  REPEAT
            //                                                                   b:=b+1;
            //                                                                   // miro si el recurso destino es agrupado
            //                                                                   if r113t."Empresa Origen"<>'' THEN BEGIN
            //                                                                    rRes.CHANGECOMPANY(r113t."Empresa Origen");
            //                                                                    rRec.CHANGECOMPANY(r113t."Empresa Origen");
            //                                                                    Proy:=r113t."Proyecto Origen";
            //                                                                    Emp:=r113t."Empresa Origen";
            //                                                                   END ELSE BEGIN
            //                                                                    rRes.CHANGECOMPANY(COMPANYNAME);
            //                                                                    Proy:=rDes."Job No.2";
            //                                                                    rRec.CHANGECOMPANY(COMPANYNAME);
            //                                                                    Emp:=COMPANYNAME;
            //                                                                   END;
            //                                                                   if rRec.GET(rDes."No.2") THEN BEGIN
            //                                                                   if (rRec."Empresa Origen"<>COMPANYNAME) AND (rRec."Empresa Origen"<>'') THEN BEGIN
            //                                                                    rDes."No.2":=rRec."Nº En Empresa origen";
            //                                                                    rRes.CHANGECOMPANY(rRec."Empresa Origen");
            //                                                                    rJob.CHANGECOMPANY(rRec."Empresa Origen");
            //                                                                    rJob.SETRANGE(rJob."Empresa Origen",COMPANYNAME);
            //                                                                    rJob.SETRANGE("Proyecto en empresa Origen",rDes."Job No.2");
            //                                                                    rJob.FINDFIRST;
            //                                                                    Proy:=rJob."No.";
            //                                                                    rRec.CHANGECOMPANY(rRec."Empresa Origen");
            //                                                                    Emp:=rRec."Empresa Origen";
            //                                                                   END;
            //                                                                   END;
            //                                                                   rRes.SETCURRENTKEY(rRes."Nº Proyecto",rRes."Recurso Agrupado");
            //                                                                   rRes.SETRANGE(rRes."Recurso Agrupado",rDes."No.2");
            //                                                                   rRes.SETRANGE(rRes."Nº Proyecto",Proy);
            //                                                                   rRes.SETFILTER(rRes."Fecha inicio",'<=%1',r113t."Fecha final recurso");
            //                                                                   rRes.SETFILTER(rRes."Fecha fin",'>=%1',r113t."Fecha inicial recurso");
            //                                                                   c:=0;
            //                                                                   if rRes.FINDFIRST THEN
            //                                                                    REPEAT
            //                                                                    FI:=rRes."Fecha inicio";
            //                                                                    FF:=rRes."Fecha fin";
            //                                                                    if FI<=r113t."Fecha inicial recurso" THEN
            //                                                                     FI:=r113t."Fecha inicial recurso";
            //                                                                    FF:=rRes."Fecha fin";
            //                                                                    if FF>=r113t."Fecha final recurso" THEN
            //                                                                     FF:=r113t."Fecha final recurso";
            //                                                                    e:=FF-FI;
            //                                                                    a:=a+e;
            //                                                                  UNTIL rRes.NEXT=0;
            //                                                                  if c=0 THEN c:=1;
            //                                                                   if rRes.FINDFIRST THEN
            //                                                                   BEGIN
            //                                                                    REPEAT
            //                                                                    FI:=rRes."Fecha inicio";
            //                                                                    FF:=rRes."Fecha fin";
            //                                                                    if FI<=r113t."Fecha inicial recurso" THEN
            //                                                                     FI:=r113t."Fecha inicial recurso";
            //                                                                    FF:=rRes."Fecha fin";
            //                                                                    if FF>=r113t."Fecha final recurso" THEN
            //                                                                     FF:=r113t."Fecha final recurso";
            //                                                                    e:=FF-FI;
            //                                                                     b:=b+1;
            //                                                                     r113t2:=r113t;
            //                                                                     r113t2."Line No.":=r113t."Line No."+b;
            //                                                                     r113t2.Quantity:=r113t.Quantity;
            //                                                                     r113t2."Direct Unit Cost":=r113t."Direct Unit Cost"/a/c*e;
            //                                                                     r113t2."Unit Cost":=r113t."Unit Cost"/a/c*e;
            //                                                                     r113t2."Unit Cost (LCY)":=r113t."Unit Cost (LCY)"/a/c*e;
            //                                                                     r113t2."Line Discount Amount":=r113t."Line Discount Amount"/a/c*e;
            //                                                                     r113t2.Amount:=r113t.Amount/a/c*e;
            //                                                                     r113t2."Amount Including VAT":=r113t."Amount Including VAT"/a/c*e;
            //                                                                     r113t2."Line Amount":=r113t."Line Amount"/a/c*e;
            //                                                                     rRec.GET(rDes."No.2");
            //                                                                     r113t2."Empresa Origen":=Emp;
            //                                                                     r113t2."Shortcut Dimension 1 Code":=rRec."Global Dimension 1 Code";
            //                                                                     r113t2."Shortcut Dimension 2 Code":=rRec."Global Dimension 2 Code";
            //                                                                     r113t2."Shortcut Dimension 3 Code":=rRec."Global Dimension 3 Code";
            //                                                                     r113t2."Shortcut Dimension 4 Code":=rRec."Global Dimension 4 Code";
            //                                                                     r113t2."Shortcut Dimension 5 Code":=rRec."Global Dimension 5 Code";
            //                                                                     if NOT r113t2.INSERT THEN
            //                                                                     REPEAT
            //                                                                      b:=b+1;
            //                                                                      r113t2."Line No.":=r113t."Line No."+b;
            //                                                                     UNTIL r113t2.INSERT;
            //                                                                    UNTIL rRes.NEXT=0;
            //                                                                   END ELSE BEGIN
            //                                                                     // si no es agrupado
            //                                                                     r113t2:=r113t;
            //                                                                     r113t2."Line No.":=r113t."Line No."+b;
            //                                                                     r113t2.Quantity:=r113t.Quantity;
            //                                                                     r113t2."Direct Unit Cost":=r113t."Direct Unit Cost"/a;
            //                                                                     r113t2."Unit Cost":=r113t."Unit Cost"/a;
            //                                                                     r113t2."Unit Cost (LCY)":=r113t."Unit Cost (LCY)"/a;
            //                                                                     r113t2."Line Discount Amount":=r113t."Line Discount Amount"/a;
            //                                                                     r113t2.Amount:=r113.Amount/a;
            //                                                                     r113t2."Amount Including VAT":=r113t."Amount Including VAT"/a;
            //                                                                     r113t2."Line Amount":=r113t."Line Amount"/a;
            //                                                                     rRec.GET(rDes."No.2");
            //                                                                     r113t2."Empresa Origen":=Emp;
            //                                                                     r113t2."Shortcut Dimension 1 Code":=rRec."Global Dimension 1 Code";
            //                                                                     r113t2."Shortcut Dimension 2 Code":=rRec."Global Dimension 2 Code";
            //                                                                     r113t2."Shortcut Dimension 3 Code":=rRec."Global Dimension 3 Code";
            //                                                                     r113t2."Shortcut Dimension 4 Code":=rRec."Global Dimension 4 Code";
            //                                                                     r113t2."Shortcut Dimension 5 Code":=rRec."Global Dimension 5 Code";
            //                                                                     if NOT r113t2.INSERT THEN
            //                                                                     REPEAT
            //                                                                      b:=b+1;
            //                                                                      r113t2."Line No.":=r113t."Line No."+b;
            //                                                                     UNTIL r113t2.INSERT;
            //                                                                   END;
            //                                                                  UNTIL rDes.NEXT=0;
            //                                                                 END ELSE BEGIN
            //                                                                  r113t2:=r113t;
            //                                                                  if NOT r113t2.INSERT THEN
            //                                                                  REPEAT
            //                                                                   b:=b+1;
            //                                                                   r113t2."Empresa Origen":=Emp;
            //                                                                   r113t2."Line No.":=r113t."Line No."+b;
            //                                                                  UNTIL r113t2.INSERT;
            //                                                                 END;
            //                                                               UNTIL r113t.NEXT=0;
            //                                                               if r112.GET("No.") THEN
            //                                                               BEGIN
            //                                                                r110.TRANSFERFIELDS(r112);
            //                                                                r110."Document Type":=r110."Document Type"::Invoice;
            //                                                                r110.INSERT;
            //                                                               END;
            //                                                               if r113t2.FINDFIRST THEN
            //                                                               REPEAT
            //                                                                r111.TRANSFERFIELDS(r113t2);
            //                                                                r111."No.":=r113t2.Recurso;
            //                                                                r111."Document Type":=r111."Document Type"::Invoice;
            //                                                                r111."Line Amount":=r113t2."Line Amount";
            //                                                                r111."Line Discount Amount":=r113t2."Line Discount Amount";
            //                                                                r111.Amount:=r113t2.Amount;
            //                                                                r111."Inv. Discount Amount":=r113t2."Inv. Discount Amount";
            //                                                                r111."Amount Including VAT":=r113t2."Amount Including VAT";
            //                                                                r111.INSERT;
            //                                                                     GlSetup.GET;
            //                                                                     if NOT rDim.GET(GlSetup."Shortcut Dimension 1 Code",r111."Shortcut Dimension 1 Code") THEN BEGIN
            //                                                                      rDim.INIT;
            //                                                                      rDim."Dimension Code":=GlSetup."Shortcut Dimension 1 Code";
            //                                                                      rDim.Code:=r111."Shortcut Dimension 1 Code";
            //                                                                      rDim."Global Dimension No.":=1;
            //                                                                      rDim.INSERT;
            //                                                                     END;
            //                                                                     if NOT rDim.GET(GlSetup."Shortcut Dimension 2 Code",r111."Shortcut Dimension 2 Code") THEN BEGIN
            //                                                                      rDim.INIT;
            //                                                                      rDim."Dimension Code":=GlSetup."Shortcut Dimension 2 Code";
            //                                                                      rDim.Code:=r111."Shortcut Dimension 2 Code";
            //                                                                      rDim."Global Dimension No.":=2;
            //                                                                      rDim.INSERT;
            //                                                                     END;
            //                                                                     if NOT rDim.GET(GlSetup."Shortcut Dimension 3 Code",r111."Shortcut Dimension 3 Code") THEN BEGIN
            //                                                                      rDim.INIT;
            //                                                                      rDim."Dimension Code":=GlSetup."Shortcut Dimension 3 Code";
            //                                                                      rDim.Code:=r111."Shortcut Dimension 3 Code";
            //                                                                      rDim."Global Dimension No.":=3;
            //                                                                      rDim.INSERT;
            //                                                                     END;
            //                                                                     if NOT rDim.GET(GlSetup."Shortcut Dimension 4 Code",r111."Shortcut Dimension 4 Code") THEN BEGIN
            //                                                                      rDim.INIT;
            //                                                                      rDim."Dimension Code":=GlSetup."Shortcut Dimension 4 Code";
            //                                                                      rDim.Code:=r111."Shortcut Dimension 4 Code";
            //                                                                      rDim."Global Dimension No.":=4;
            //                                                                      rDim.INSERT;
            //                                                                     END;
            //                                                                     if NOT rDim.GET(GlSetup."Shortcut Dimension 5 Code",r111."Shortcut Dimension 5 Code") THEN BEGIN
            //                                                                      rDim.INIT;
            //                                                                      rDim."Dimension Code":=GlSetup."Shortcut Dimension 5 Code";
            //                                                                      rDim.Code:=r111."Shortcut Dimension 5 Code";
            //                                                                      rDim."Global Dimension No.":=5;
            //                                                                      rDim.INSERT;
            //                                                                     END;
            //                                                                r111.VALIDATE("Shortcut Dimension 1 Code",r111."Shortcut Dimension 1 Code");
            //                                                                r111.VALIDATE("Shortcut Dimension 2 Code",r111."Shortcut Dimension 2 Code");
            //                                                                r111.VALIDATE("Shortcut Dimension 3 Code",r111."Shortcut Dimension 3 Code");
            //                                                                r111.VALIDATE("Shortcut Dimension 4 Code",r111."Shortcut Dimension 4 Code");
            //                                                                r111.VALIDATE("Shortcut Dimension 5 Code",r111."Shortcut Dimension 5 Code");
            //                                                                r111.MODIFY;
            //                                                               UNTIL r113t2.NEXT=0;
            //                                                               if r110.GET(r110."Document Type"::Invoice,"No.") THEN BEGIN
            //                                                                r110.Calcfields(r110.Amount,r110."Amount Including VAT");
            //                                                                Calcfields(Amount,"Amount Including VAT");
            //                                                                I:=Amount-r110.Amount;
            //                                                                II:="Amount Including VAT"-r110."Amount Including VAT";
            //                                                                r113O.SETRANGE(r113O."Document No.","No.");
            //                                                                r113O.SETRANGE(r113O.Type,r113O.Type::Resource);
            //                                                                if NOT r113O.FINDFIRST THEN
            //                                                                 r113O.SETFILTER(r113O.Type,'<>%1',r113O.Type::" ");
            //                                                                r113O.FINDFIRST;
            //                                                                if (I<>0) OR (II<>0) THEN BEGIN
            //                                                                 r111.SETRANGE("Document Type",r111."Document Type"::Invoice);
            //                                                                 r111.SETRANGE(r111."Document No.","No.");
            //                                                                 r111.FINDLAST;
            //                                                                 a:=r111."Line No.";
            //                                                                 rRec.RESET;
            //                                                                 rRec.CHANGECOMPANY(COMPANYNAME);
            //                                                                 rRec.GET(r113O."No.");
            //                                                                 Gps.GET("Gen. Bus. Posting Group",rRec."Gen. Prod. Posting Group");
            //                                                                 r111:=r111;
            //                                                                 r111."Document Type":=r111."Document Type"::Invoice;
            //                                                                 r111."Line No.":=a+1;
            //                                                                 r111.Type:=r111.Type::"G/L Account";
            //                                                                 r111."No.":=Gps."Sales Account";
            //                                                                 r111.Description:='Redondeo factura';
            //                                                                 r111.Quantity:=1;
            //                                                                 r111."Direct Unit Cost":=I;
            //                                                                 r111."Line Discount %":=0;
            //                                                                 r111."VAT Base Amount":=I;
            //                                                                 r111.Amount:=I;
            //                                                                 r111."Amount Including VAT":=II;
            //                                                                 r111."Inv. Discount Amount":=0;
            //                                                                 r111.INSERT;
            //                                                                END;
            //                                                               END;
            //                                                               COMMIT;
            //                                                               r110.SETRANGE(r110."No.","No.");
            //                                                               Page.RUNMODAL(5167,r110);
            //                                                             END;
            //                                                              }
            //                                                    { ID=1000000005;
            action("Asigna Datos Factura")
            {
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                VAR
                    rLinVta: Record 113;
                    rLin2: Record 123;
                    wEmpresa: Text[30];
                    rIc: Record 413;
                    rVend: Record Vendor;
                    Linea: Integer;
                    rLinPed: Record 39;
                    rLinAlb: Record "Purch. Rcpt. Line";
                    rCabPed: Record 38;
                    r1003: Record 1003;
                BEGIN
                    rVend.GET(Rec."Pay-to Vendor No.");
                    if rIc.GET(rVend."IC Partner Code") THEN BEGIN
                        wEmpresa := rIc."Inbox Details";
                        rLin2.SETRANGE(rLin2."Document No.", Rec."No.");
                        rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                        if rLin2.FINDFIRST THEN
                            REPEAT
                                if rLin2."Receipt No." <> '' THEN BEGIN
                                    rLinAlb.GET(rLin2."Receipt No.", rLin2."Receipt Line No.");
                                    rLinPed.GET(rLinPed."Document Type"::Order, rLinAlb."Order No.", rLinAlb."Order Line No.");
                                END ELSE
                                    rLinPed.GET(rLinPed."Document Type"::Order, Rec."Order No.", rLin2."Line No.");
                                rLinVta.CHANGECOMPANY(wEmpresa);
                                rLinVta.SETRANGE(rLinVta."Document No.", Rec."Vendor Invoice No.");
                                rLinVta.SETRANGE(rLinVta."No linea proyecto", rLinPed."Linea de proyecto");
                                if rLinVta.FINDFIRST THEN BEGIN
                                    REPEAT
                                        if rLinVta.Type = rLinVta.Type::Resource THEN BEGIN
                                            rLin2."Fecha inicial recurso" := rLinVta."Fecha inicial recurso";
                                            rLin2."Fecha final recurso" := rLinVta."Fecha final recurso";
                                            rLin2.Recurso := rLinVta."No.";
                                        END;
                                        rLin2."Empresa Origen" := wEmpresa;
                                        rLin2."Proyecto Origen" := rLinVta."Job No.";
                                        rLin2."Linea de proyecto" := rLinVta."No linea proyecto";
                                        rLin2.MODIFY;
                                    UNTIL rLinVta.NEXT = 0;
                                END;
                            UNTIL rLin2.NEXT = 0;
                    END ELSE BEGIN
                        rLin2.SETRANGE(rLin2."Document No.", Rec."No.");
                        rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                        if rLin2.FINDFIRST THEN
                            REPEAT
                                if rLin2."Receipt No." <> '' THEN BEGIN
                                    rLinAlb.GET(rLin2."Receipt No.", rLin2."Receipt Line No.");
                                    rLinPed.GET(rLinPed."Document Type"::Order, rLinAlb."Order No.", rLinAlb."Order Line No.");
                                END ELSE
                                    rLinPed.GET(rLinPed."Document Type"::Order, Rec."Order No.", rLin2."Line No.");
                                rLin2."Job No." := rLinPed."Job No.";
                                rLin2."Linea de proyecto" := rLinPed."Linea de proyecto";
                                if rLin2."Job No." = '' THEN BEGIN
                                    rCabPed.GET(rCabPed."Document Type"::Order, rLinPed."Document No.");
                                    rLin2."Job No." := rCabPed."Nº Proyecto";
                                END;
                                if rLin2."Linea de proyecto" = 0 THEN BEGIN
                                    r1003.SETRANGE(r1003."Job No.", rLin2."Job No.");
                                    r1003.SETRANGE(r1003."No.", rLin2."No.");
                                    if r1003.FINDFIRST THEN BEGIN
                                        rLin2."Linea de proyecto" := r1003."Line No.";
                                    END;
                                END;
                                rLin2.MODIFY;
                            UNTIL rLin2.NEXT = 0;
                    END;
                END;
            }
        }
    }
}
pageextension 80217 PostedPurchaseCr extends "Posted Purchase Credit Memo"
{
    actions
    {
        addlast("&Cr. Memo")
        {
            action("Reenviar SII")
            {
                ApplicationArea = All;
                Image = SendElectronicDocument;
                trigger OnAction()
                Var
                    GestiónSII: Report "Gestión SII";
                    SalesInv: Record "Purch. Cr. Memo Hdr.";
                    DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                    r114: Record "Purch. Inv. Header";
                BEGIN

                    //-SII1
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    if SalesInv.FINDFIRST THEN
                        REPEAT
                            r114.INIT;
                            GestiónSII.CreateOrUpdateFilePurch(r114, SalesInv, TRUE);
                        //GestiónSII.SetRegeneracion(2,SalesInv."No.",DocType::Invoice,SalesInv."Posting Date",SalesInv."Currency Code",TRUE);
                        //GestiónSII.USEREQUESTFORM:=FALSE;
                        //GestiónSII.RUN;
                        UNTIL SalesInv.NEXT = 0;
                    //+SII1
                END;
            }
            action("Reenviar Modificacion SII")
            {
                ApplicationArea = All;
                Image = SendElectronicDocument;
                Caption = 'Reenviar Modificacion SII';
                trigger OnAction()
                Var
                    GestiónSII: Report "Gestión SII";
                    SalesInv: Record "Purch. Cr. Memo Hdr.";
                    r114: Record "Purch. Inv. Header";
                    DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                BEGIN

                    //-SII1
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    CurrPage.SETSELECTIONFILTER(SalesInv);
                    if SalesInv.FINDFIRST THEN
                        REPEAT
                            r114.INIT;
                            GestiónSII.CreateOrUpdateFilePurchA1(r114, SalesInv, TRUE);
                        UNTIL SalesInv.NEXT = 0;
                    //+SII1
                END;
            }
            action("Actualiza Situacion SII")
            {
                ApplicationArea = All;
                Image = Refresh;
                Caption = 'Actualiza Situacion SII';
                trigger OnAction()
                Var
                    rGes: Codeunit "Gestion Proyecto";
                BEGIN
                    CLEAR(rGes);
                    rGes.SiiMensajes;
                END;
            }

        }

    }
}
pageextension 80218 PostedPurcReceiptLines extends "Posted Purchase Receipt Lines"
{
    layout
    {
        addafter("Buy-from Vendor No.")
        {
            field(Nombre; Name())
            {
                ApplicationArea = all;
            }
        }
    }
    /// <summary>
    /// Name.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure Name(): Text
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(Rec."Buy-from Vendor No.") Then exit(Vendor.Name);
    end;
}