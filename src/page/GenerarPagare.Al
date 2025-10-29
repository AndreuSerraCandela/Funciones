/// <summary>
/// Page Generar pagares (ID 50054).
/// </summary>
page 50054 "Generar pagares"
{
    //Version List=FH3.70,FINTIS,PAG,ES;
    PageType = StandardDialog;
    layout
    {
        area(Content)
        {

            field(wBanc; wBanco)
            {
                ApplicationArea = All;

                Caption = 'Banco';

                TableRelation = "Bank Account";
            }
            //    { 1103350004;Label  ;440  ;990  ;3300 ;440  ;
            group("Agrupar por")
            {

                Caption = 'Agrupar por';
                field(wDimensione; wDimensiones)
                {
                    ApplicationArea = All;


                    Caption = 'Dimensiones';

                    trigger OnAssistEdit()
                    VAR
                        DimSeleccio: Page 562;
                        Dim: Record 348;
                        TheDimSelectionBuf: Record 368 TEMPORARY;
                    BEGIN
                        if Dim.FIND('-') THEN BEGIN
                            DimSeleccio.LOOKUPMODE := TRUE;
                            REPEAT
                                DimSeleccio.InsertDimSelBuf((STRPOS(wDimensiones, Dim.Code) > 0), Dim.Code, '');
                            UNTIL Dim.NEXT = 0;
                            if DimSeleccio.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                wDimensiones := '';
                                DimSeleccio.GetDimSelBuf(TheDimSelectionBuf);
                                TheDimSelectionBuf.SETRANGE(Selected, TRUE);
                                if TheDimSelectionBuf.FIND('-') THEN
                                    REPEAT
                                        if wDimensiones = '' THEN
                                            wDimensiones := TheDimSelectionBuf.Code
                                        ELSE
                                            wDimensiones += ';' + TheDimSelectionBuf.Code;
                                    UNTIL TheDimSelectionBuf.NEXT = 0;
                            END;
                        END;
                    END;
                }
                //    { 1103350007;Label  ;660  ;2860 ;3300 ;440  ;
                field(wFechaVto; wFechaVto)
                {
                    ApplicationArea = All;

                    //ShowCaption=false;
                    Caption = 'Fecha vencimiento';
                }
            }
        }
    }

    //   
    VAR
        wBanco: Code[20];
        wFechaVto: Boolean;
        wDimensiones: Text[250];

    trigger OnOpenPage()
    VAR
        rConfCont: Record "General Ledger Setup";
    BEGIN
        if wDimensiones = '' THEN BEGIN
            rConfCont.GET;
            if rConfCont."Global Dimension 1 Code" <> '' THEN BEGIN
                wDimensiones := rConfCont."Global Dimension 1 Code";
                if rConfCont."Global Dimension 2 Code" <> '' THEN
                    wDimensiones += ';' + rConfCont."Global Dimension 2 Code";
            END;
        END;
    END;


    PROCEDURE Banco(): Code[20];
    BEGIN
        EXIT(wBanco);
    END;

    PROCEDURE Dimensiones(): Text[250];
    BEGIN
        EXIT(wDimensiones);
    END;

    PROCEDURE FechaVto(): Boolean;
    BEGIN
        EXIT(wFechaVto);
    END;

    //     BEGIN
    //     {
    //       // PLB 19/05/2005
    //       Nueva ventana para crear pagares. Sustituye al antiguo formulario con el mismo número de objeto para
    //       seleccionar el banco y el STRMENU para seleccionar la agrupación por "Fecha vencimiento"

    //       Este nuevo formulario, además, permite poder agrupar la información por dimensiones
    //     }
    //     END.
    //   }
}

page 50055 "Primer pagare"
{
    //Version List=FH3.70,FINTIS,PAG,ES;
    PageType = StandardDialog;
    layout
    {
        area(Content)
        {

            field(wPrimer; wPrimer)
            {
                ApplicationArea = All;

                Caption = 'Primer Pagaré';
            }
        }
    }

    //   
    VAR
        wPrimer: Code[20];




    PROCEDURE SetPrimero(pPrimer: Code[20]);
    BEGIN
        wPrimer := pPrimer;
    END;

    PROCEDURE GetPrimero(): Code[20];
    BEGIN
        Exit(wPrimer);
    END;
    //     BEGIN
    //     {
    //       // PLB 19/05/2005
    //       Nueva ventana para crear pagares. Sustituye al antiguo formulario con el mismo número de objeto para
    //       seleccionar el banco y el STRMENU para seleccionar la agrupación por "Fecha vencimiento"

    //       Este nuevo formulario, además, permite poder agrupar la información por dimensiones
    //     }
    //     END.
    //   }
}
page 50056 "Relación Dimensiones"
{

    PageType = List;
    UsageCategory = Lists;
    //Version List=FH3.70;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Relación Dimensiones";

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Empresa Origen"; Rec."Empresa Origen") { ApplicationArea = All; }


                //    { 3   ;Label        ;0    ;0    ;0    ;0    ;

                field("Código Dimension"; Rec."Código Dimension") { ApplicationArea = All; }



                //    { 5   ;Label        ;0    ;0    ;0    ;0    ;

                field("Empresa Destino"; Rec."Empresa Destino") { ApplicationArea = All; }


                //    { 10  ;Label        ;0    ;0    ;0    ;0    ;

                field("Valor Dimensión"; Rec."Valor Dimensión")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    VAR
                        r349: Record 349;
                    BEGIN
                        r349.SETRANGE(r349."Dimension Code", Rec."Código Dimension");
                        r349.CHANGECOMPANY(Rec."Empresa Origen");
                        if PAGE.RUNMODAL(0, r349) = ACTION::LookupOK THEN
                            Rec."Valor Dimensión" := r349.Code;
                    END;
                }
                //    { 12  ;Label        ;0    ;0    ;0    ;0    ;

                field("Valor Dimensión destino"; Rec."Valor Dimensión destino")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    VAR
                        r349: Record 349;
                    BEGIN
                        r349.CHANGECOMPANY(Rec."Empresa Destino");
                        r349.SETRANGE(r349."Dimension Code", Rec."Código Dimension");
                        if PAGE.RUNMODAL(0, r349) = ACTION::LookupOK THEN
                            Rec."Valor Dimensión destino" := r349.Code;
                    END;
                }
                field(Dim; Dim)
                {
                    ApplicationArea = All;
                    TableRelation = Dimension.Code;
                    trigger OnValidate()
                    BEGIN
                        Rec.SETRANGE("Código Dimension", Dim);
                    END;
                }
                //    { 1100217001;Label  ;220  ;440  ;3300 ;440  ;
                field(Emp; Emp)
                {
                    ApplicationArea = All;
                    TableRelation = Company.Name;
                    trigger OnValidate()
                    BEGIN
                        Rec.SETRANGE("Empresa Origen", Emp);
                    END;
                }
                //    { 1100217004;Label  ;220  ;1100 ;3300 ;440  ;

            }
        }
    }
    actions
    {
        area(Processing)
        {

            group("Ac&ciones")
            {
                Caption = 'Ac&ciones';
                action("Comprobar nuevos dep/Prog")
                {
                    ApplicationArea = all;
                    Image = Check;
                    Caption = 'Comprobar nuevos dep/Prog';
                    trigger OnAction()
                    var
                        Control: Codeunit ControlProcesos;
                    BEGIN

                        rEmp.SetRange("Evaluation Company", false);
                        if rEmp.FINDFIRST THEN
                            REPEAT
                                if Control.Permiso_Empresas(rEmp.Name) Then begin
                                    rEmp2.SETFILTER(rEmp2.Name, '<>%1', rEmp.Name);
                                    r349.CHANGECOMPANY(rEmp.Name);
                                    r349.SETFILTER(r349."Dimension Code", '%1|%2', 'DEPATYAMENTO', 'PROGRAMA');
                                    if r349.FINDFIRST THEN
                                        REPEAT
                                            if rEmp2.FINDFIRST THEN
                                                REPEAT
                                                    Rec."Empresa Origen" := rEmp.Name;
                                                    Rec."Código Dimension" := r349."Dimension Code";
                                                    Rec."Empresa Destino" := rEmp2.Name;
                                                    Rec."Valor Dimensión" := r349.Code;
                                                    if Rec.INSERT THEN;
                                                UNTIL rEmp2.NEXT = 0;
                                        UNTIL r349.NEXT = 0;
                                end;
                            UNTIL rEmp.NEXT = 0;
                    END;
                }
            }
        }
    }

    VAR
        rEmp: Record 2000000006;
        rEmp2: Record 2000000006;
        r349: Record 349;
        Dim: Code[20];
        Emp: Text[30];

    trigger OnOpenPage()
    BEGIN
        //SETRANGE("Empresa Destino",COMPANYNAME);
        Rec.SETRANGE("Empresa Origen", Emp);
    END;

    PROCEDURE Origen(wEmp: Text[30]);
    BEGIN
        Emp := wEmp;
        Rec.SETRANGE("Empresa Origen", Emp);
    END;

    //     BEGIN
    //     END.
    //   }
}

page 50057 "Relacion pagos"
{

    //Version List=PAG;
    Caption = 'Relación pagos';
    SourceTable = "Cab. relacion pagos";
    PageType = Card;


    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No. relación pagos"; Rec."No. relación pagos") { ApplicationArea = All; }
                field("Fecha creación"; Rec."Fecha creación") { ApplicationArea = All; }
                field(Importe; Rec.Importe)
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                }

                field(Descripcion; Rec.Descripcion) { ApplicationArea = All; }

            }
            group(Detalle)
            {
                part(SubForm; "Subform relacion pagos docs")
                {
                    ApplicationArea = All;
                    SubPageLink = "No. relación pagos" = FIELD("No. relación pagos");
                }
                part(SubformVto; "Subform relacion pagos vtos")
                {
                    ApplicationArea = All;
                    SubPageLink = "No. relación pagos" = FIELD("No. relación pagos");
                }
            }
        }
    }
    actions
    {

        area(Navigation)
        {
            group("&Rel. pagos")
            {

                Caption = '&Rel. pagos';
                action(Lista)
                {
                    Image = PaymentHistory;
                    ApplicationArea = All;
                    ShortCutKey = F5;
                    Caption = 'Lista';
                    trigger OnAction()
                    Begin
                        Page.RunModal(0, Rec);
                    End;

                }
            }
        }
        // area(Reporting)
        // {


        //     action("&Imprimir")
        //     {
        //         Caption = '&Imprimir';
        //         Image = Report;
        //         trigger OnAction()
        //         BEGIN
        //             recRelPagos.RESET;
        //             recRelPagos.SETRANGE("No. relación pagos", Rec."No. relación pagos");
        //             REPORT.RUNMODAL(REPORT::"Conformación facturas compras", TRUE, TRUE, recRelPagos);
        //         END;
        //     }
        // }
        area(Processing)
        {
            group("&Acciones")
            {
                // action("Traer documentos pendientes")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Traer documentos pendientes';
                //     Image = Add;
                //     trigger OnAction()
                //     BEGIN
                //         Rec.TESTFIELD("No. relación pagos");
                //         CLEAR(recGenRelPagos);
                //         recGenRelPagos.PasaParam(Rec."No. relación pagos");
                //         recGenRelPagos.RUNMODAL;
                //     END;
                // }
                action("Dividir pago")
                {
                    ApplicationArea = All;
                    Image = DistributionGroup;
                    Caption = 'Dividir pago';
                    trigger OnAction()
                    BEGIN
                        CurrPage.Subform.PAGE.DividirLineas;
                    END;
                }
                action("Generar borradores pagarés")
                {
                    ApplicationArea = All;
                    ShortCutKey = F11;
                    Image = Register;
                    Caption = 'Generar borradores pagarés';
                    trigger OnAction()
                    BEGIN

                        if CONFIRM(Text001) THEN BEGIN
                            recRelPagos.RESET;
                            recRelPagos.SETRANGE("No. relación pagos", Rec."No. relación pagos");
                            CLEAR(repGenPagares);
                            repGenPagares.SETTABLEVIEW(recRelPagos);
                            repGenPagares.UseRequestPage := FALSE;
                            repGenPagares.RUNMODAL;
                            MESSAGE(Text002, repGenPagares.TraerPagaresGenerados);
                        END;
                    END;
                }
                action("Borradores pagarés")
                {
                    ApplicationArea = All;
                    Image = VendorBill;
                    Caption = 'Borradores pagarés';
                    trigger OnAction()
                    BEGIN
                        Page.RunModal(Page::"Borrador pagare");

                    END;
                }
            }
        }
    }
    VAR
        Text001: Label '¿Desea generar borradores de pagarés a partir de la relación de pagos?';
        recRelPagos: Record "Cab. relacion pagos";
        Text002: Label 'Se han generado %1 borradores de pagarés.';
        //recGenRelPagos: Report 80150;
        repGenPagares: Report "Generación borrador pagarés";

    trigger OnAfterGetRecord()
    BEGIN
        CurrPage.SubformVto.Page.PasaParam(Rec."No. relación pagos");
        CurrPage.SubformVto.PAge.Actualizar;
    END;
    //BEGIN
    //     {
    //       $001 01/02/07 JML : Proyecto Florida.
    //                           Añado opción dividir líneas.
    //     }
    //     END.
    //   }
}

page 50058 "Subform relacion pagos docs"
{

    PageType = ListPart;
    Caption = 'Subform relación pagos';
    InsertAllowed = true;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Lin. relacion pagos";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Pago-a Nº proveedor"; Rec."Pago-a Nº proveedor") { ApplicationArea = All; }


                //  OnFormat=BEGIN
                //             if "Fecha vencimiento" = 0D THEN BEGIN
                //               CurrPage."Pago-a Nº proveedor".UPDATEFORECOLOR := 255;
                //               CurrPage."Pago-a Nº proveedor".UPDATEFONTBOLD := TRUE;
                //             END;
                //           END;
                //            }
                //    { 7   ;Label        ;0    ;0    ;0    ;0    ;

                field("Pago a-Nombre"; Rec."Pago a-Nombre")
                {
                    ApplicationArea = All;
                    Editable = false;
                    //  OnFormat=BEGIN
                    //             if "Fecha vencimiento" = 0D THEN BEGIN
                    //               CurrPage."Pago a-Nombre".UPDATEFORECOLOR := 255;
                    //               CurrPage."Pago a-Nombre".UPDATEFONTBOLD := TRUE;
                    //             END;
                    //           END;
                }
                //    { 9   ;Label        ;0    ;0    ;0    ;0    ;

                field("Tipo documento"; Rec."Tipo documento") { ApplicationArea = All; }

                //    { 1103355001;Label  ;0    ;0    ;0    ;0    ;

                field("Nº documento proveedor"; Rec."Nº documento proveedor") { ApplicationArea = All; }
                //  OnFormat=BEGIN
                //             if "Fecha vencimiento" = 0D THEN BEGIN
                //               CurrPage."Nº documento proveedor".UPDATEFORECOLOR := 255;
                //               CurrPage."Nº documento proveedor".UPDATEFONTBOLD := TRUE;
                //             END;
                //           END;
                //            }
                //    { 17  ;Label        ;0    ;0    ;0    ;0    ;

                field("Nº"; Rec."Nº")
                {
                    ApplicationArea = All;
                    Caption = 'Nº documento';
                }
                //  OnFormat=BEGIN
                //             if "Fecha vencimiento" = 0D THEN BEGIN
                //               CurrPage."Nº".UPDATEFORECOLOR := 255;
                //               CurrPage."Nº".UPDATEFONTBOLD := TRUE;
                //             END;
                //           END;
                //}
                //    { 5   ;Label        ;0    ;0    ;0    ;0    ;

                field("Compra a-Nº proveedor"; Rec."Compra a-Nº proveedor") { ApplicationArea = All; }

                //    { 3   ;Label        ;0    ;0    ;0    ;0    ;

                field("Fecha vencimiento"; Rec."Fecha vencimiento") { ApplicationArea = All; }
                //  OnFormat=BEGIN
                //             if "Fecha vencimiento" = 0D THEN BEGIN
                //               CurrPage."Fecha vencimiento".UPDATEFORECOLOR := 255;
                //               CurrPage."Fecha vencimiento".UPDATEFONTBOLD := TRUE;
                //             END;
                //           END;
                //            }
                //    { 11  ;Label        ;0    ;0    ;0    ;0    ;

                field("Importe IVA incl."; Rec."Importe IVA incl.")
                {
                    ApplicationArea = All;

                    Caption = 'Importe a pagar (IVA incl.)';
                }
                field("Pagaré generado"; Rec."Pagaré generado")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                //    { 19  ;Label        ;0    ;0    ;0    ;0    ;

                field("No. borrador pagare"; Rec."No. borrador pagare") { ApplicationArea = All; }
            }
        }
    }
    VAR
        Text0001: Label '¿Desea dividir los pagos seleccionados?';

    PROCEDURE DividirLineas();
    VAR
        recPagos: Record "Lin. relacion pagos";
        cduDivPago: Codeunit "Dividir lin. rel. pago";
    BEGIN
        //$001
        //if CONFIRM(Text0001,TRUE,"Nº factura proveedor") THEN BEGIN
        CLEAR(cduDivPago);
        recPagos.RESET;
        CurrPage.SETSELECTIONFILTER(recPagos);
        cduDivPago.DividirPagos(recPagos);
        //END;
    END;

    //   BEGIN
    //   {
    //     $001 01/02/07 JML : Proyecto Florida.
    //                         Añado función dividir líneas.
    //   }
    //   END.
    // }
}

page 50059 "Subform relacion pagos vtos"
{

    //Version List=PAG;
    Caption = 'Subform relación pagos vtos';
    InsertAllowed = true;
    PageType = ListPart;
    SourceTable = "Lin. relacion pagos";
    AutoSplitKey = true;


    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Pago-a Nº proveedor"; Rec."Pago-a Nº proveedor") { ApplicationArea = All; }


                //    { 7   ;Label        ;0    ;0    ;0    ;0    ;

                field("Pago a-Nombre"; Rec."Pago a-Nombre")
                {
                    ApplicationArea = All;

                    // OnFormat=BEGIN
                    //           if "Fecha vencimiento" = 0D THEN BEGIN
                    //             CurrPage."Pago a-Nombre".UPDATEFORECOLOR := 255;
                    //             CurrPage."Pago a-Nombre".UPDATEFONTBOLD := TRUE;
                    //           END;
                    //         END;
                }
                //    { 9   ;Label        ;0    ;0    ;0    ;0    ;

                field("Fecha vencimiento"; Rec."Fecha vencimiento") { ApplicationArea = All; }


                //    { 11  ;Label        ;0    ;0    ;0    ;0    ;

                field("Importe IVA incl."; Rec."Importe IVA incl.")
                {
                    ApplicationArea = All;

                    Caption = 'Importe total (IVA incl.)';
                }
                //    { 15  ;Label        ;0    ;0    ;0    ;0    ;

            }
        }
    }
    VAR
        recTmp: Record "Lin. relacion pagos" TEMPORARY;
        codRelPagos: Code[20];

    trigger OnOpenPage()
    BEGIN
        AgruparVencimientos;
    END;

    trigger OnFindRecord(which: Text): Boolean
    BEGIN
        recTmp := Rec;
        if NOT recTmp.FIND(Which) THEN
            EXIT(FALSE);
        Rec := recTmp;
        EXIT(TRUE);
    END;

    trigger OnNewRecord(BelowxRec: Boolean)
    VAR
        CurrentSteps: Integer;
    BEGIN
        recTmp := Rec;
        CurrentSteps := recTmp.NEXT(CurrentSteps);
        if CurrentSteps <> 0 THEN
            Rec := recTmp;
        //EXIT(CurrentSteps);
    END;

    PROCEDURE PasaParam(codPrmRelPagos: Code[20]);
    BEGIN
        codRelPagos := codPrmRelPagos;
    END;

    PROCEDURE Actualizar();
    BEGIN
        AgruparVencimientos;
        CurrPage.UPDATE(FALSE);
    END;

    PROCEDURE AgruparVencimientos();
    VAR
        recLinPago: Record "Lin. relacion pagos";
        intLinea: Integer;
    BEGIN
        recTmp.RESET;
        recTmp.DELETEALL;

        recLinPago.RESET;
        recLinPago.SETCURRENTKEY("No. relación pagos", "Pago-a Nº proveedor", "Fecha vencimiento");
        recLinPago.SETRANGE("No. relación pagos", codRelPagos);
        recLinPago.SETFILTER("Pago-a Nº proveedor", '<>%1', '');
        recLinPago.SETFILTER("Fecha vencimiento", '<>%1', 0D);
        if recLinPago.FINDFIRST THEN
            REPEAT
                recTmp.RESET;
                recTmp.SETRANGE("Pago-a Nº proveedor", recLinPago."Pago-a Nº proveedor");
                recTmp.SETRANGE("Fecha vencimiento", recLinPago."Fecha vencimiento");
                if recTmp.FIND('-') THEN BEGIN
                    recTmp."Importe IVA incl." += recLinPago."Importe IVA incl.";
                    recTmp.MODIFY;
                END
                ELSE BEGIN
                    recTmp.INIT;
                    recTmp."No. relación pagos" := recLinPago."No. relación pagos";
                    intLinea += 1;
                    recTmp."No. linea" := intLinea;
                    recTmp."Pago-a Nº proveedor" := recLinPago."Pago-a Nº proveedor";
                    recTmp."Pago a-Nombre" := recLinPago."Pago a-Nombre";
                    recTmp."Compra a-Nº proveedor" := recLinPago."Compra a-Nº proveedor";
                    recTmp."Compra a-Nombre" := recLinPago."Compra a-Nombre";
                    recTmp."Fecha vencimiento" := recLinPago."Fecha vencimiento";
                    recTmp."Importe IVA incl." := recLinPago."Importe IVA incl.";
                    recTmp.INSERT;
                END;
            UNTIL recLinPago.NEXT = 0;
        recTmp.RESET;
    END;

    //   BEGIN
    //   {
    //     $001 01/02/07 JML : Proyecto Florida.
    //                         Añado función dividir líneas.
    //   }
    //   END.
    // }
}

page 50060 "Lista relaciones pagos"
{

    //Version List=PAG;
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "Cab. relacion pagos";

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("No. relación pagos"; Rec."No. relación pagos") { ApplicationArea = All; }
                field("Fecha creación"; Rec."Fecha creación") { ApplicationArea = All; }
                field(Importe; Rec.Importe) { ApplicationArea = All; }
                field(Descripcion; Rec.Descripcion) { ApplicationArea = All; }
            }
        }
    }
}

page 50061 "Borrador pagare"
{
    PageType = Card;
    Caption = 'Borrador pagaré';
    InsertAllowed = false;
    SourceTable = "Cab. borrador pagare";
    SourceTableView = SORTING(Contabilizado)
                    WHERE(Contabilizado = CONST(false));

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("CCC Nº Cuenta"; Rec."CCC Nº Cuenta") { ApplicationArea = All; }
                field("Nombre banco"; Rec."Nombre banco") { ApplicationArea = All; }
                field("Dirección banco"; Rec."Dirección banco") { ApplicationArea = All; }
                field("Cód. pagaré"; Rec."Cód. pagaré") { ApplicationArea = All; }
                field("Cód. proveedor"; Rec."Cód. proveedor") { ApplicationArea = All; }
                field(Importe; Rec.Importe)
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                }
                field("Cód. banco"; Rec."Cód. banco") { ApplicationArea = All; }
                field("Cód. divisa"; Rec."Cód. divisa") { ApplicationArea = All; }
                field("Fecha de vto."; Rec."Fecha de vto.") { ApplicationArea = All; }
                field("Nº documento propio"; Rec."Nº documento propio") { ApplicationArea = All; }
                field(TraerNombreProveedor; TraerNombreProveedorLocal)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre proveedor';
                }
                field("CCC Oficina"; Rec."CCC Oficina") { ApplicationArea = All; }
                field("Fecha registro"; Rec."Fecha registro") { ApplicationArea = All; }
                part(SubForm; "Subform borrador pagare")
                {
                    ApplicationArea = All;
                    SubPageLink = "Cód. pagaré" = FIELD("Cód. pagaré");
                }
            }
        }
    }
    actions
    {

        area(Processing)
        {
            group("&Pagaré")
            {
                action(Lista)
                {
                    ApplicationArea = All;
                    Image = List;
                    ShortCutKey = F5;
                    Caption = 'Lista';
                    trigger OnAction()
                    Begin
                        Page.RunModal(0, Rec);
                    End;
                }
            }
            group("&Acciones")
            {
                action("&Register")
                {
                    Image = Register;
                    ApplicationArea = All;
                    ShortCutKey = F11;
                    Caption = 'Registrar';
                    trigger OnAction()
                    BEGIN
                        cduContabilizarEfectos.RegistrarPagares(Rec);
                        CurrPage.UPDATE(FALSE);
                    END;
                }
            }
        }
        // area(Reporting)
        // {
        //     action("Pa&garés")
        //     {
        //         ApplicationArea = All;
        //         Image = Documents;
        //         Caption = 'Pagarés';
        //         trigger OnAction()
        //         BEGIN
        //             recBorrador.RESET;
        //             recBorrador.SETRANGE("Cód. pagaré", Rec."Cód. pagaré");
        //             REPORT.RUN(REPORT::"Impresión pagarés", TRUE, FALSE, recBorrador);
        //         END;
        //     }
        //     action("&Carta pagarés")
        //     {
        //         ApplicationArea = All;
        //         Image = Document;
        //         Caption = 'Carta pagarés';
        //         trigger OnAction()
        //         BEGIN
        //             recBorrador.RESET;
        //             recBorrador.SETRANGE("Cód. pagaré", Rec."Cód. pagaré");
        //             REPORT.RUNMODAL(REPORT::"Impresión carta pagarés", TRUE, FALSE, recBorrador);
        //         END;
        //     }
        // }
    }
    VAR
        recBorrador: Record "Cab. borrador pagare";
        cduContabilizarEfectos: Codeunit "Gestionpagare";

    PROCEDURE TraerNombreProveedorLocal(): Text[30];
    VAR
        recProveedor: Record Vendor;
    BEGIN
        if recProveedor.GET(Rec."Cód. proveedor") THEN
            EXIT(recProveedor.Name);
    END;



}

page 50062 "Subform borrador pagare"
{
    PageType = ListPart;
    Editable = false;
    Caption = 'Subform borrador pagaré';
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Lin. borrador pagare";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Tipo documento"; Rec."Tipo documento") { ApplicationArea = All; }
                field("No. documento"; Rec."No. documento") { ApplicationArea = All; }
                field("No. documento proveedor"; Rec."No. documento proveedor") { ApplicationArea = All; }
                field("Fecha documento"; Rec."Fecha documento") { ApplicationArea = All; }
                field("Cod. divisa"; Rec."Cod. divisa") { ApplicationArea = All; }
                field(Importe; Rec.Importe) { ApplicationArea = All; }
            }
        }


    }
}

page 50063 "Lista pagares"
{
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    Caption = 'Lista de pagarés';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Cab. borrador pagare";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Cód. pagaré"; Rec."Cód. pagaré") { ApplicationArea = All; }
                field("Cód. proveedor"; Rec."Cód. proveedor") { ApplicationArea = All; }
                field("Nº documento propio"; Rec."Nº documento propio") { ApplicationArea = All; }
                field("Fecha de vto."; Rec."Fecha de vto.") { ApplicationArea = All; }

                field(Importe; Rec.Importe) { ApplicationArea = All; }
                field("Cód. banco"; Rec."Cód. banco") { ApplicationArea = All; }

                field("Nombre banco"; Rec."Nombre banco") { ApplicationArea = All; }

                field("CCC Oficina"; Rec."CCC Oficina") { ApplicationArea = All; }

                field("CCC Nº Cuenta"; Rec."CCC Nº Cuenta") { ApplicationArea = All; }
                field(Contabilizado; Rec.Contabilizado)
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;
                }
            }
        }
    }
    // actions
    // {
    //     area(Reporting)
    //     {
    //         action("&Imprimir")
    //         {
    //             Caption = '&Imprimir';
    //             trigger OnAction()
    //             BEGIN
    //                 CurrPage.SETSELECTIONFILTER(recPagare);
    //                 REPORT.RUNMODAL(REPORT::"Impresión carta pagarés", TRUE, FALSE, recPagare);
    //             END;
    //         }
    //     }
    // }
    VAR
        recPagare: Record "Cab. borrador pagare";


}

page 50064 "Hist. pagare"
{
    PageType = Card;
    Caption = 'Histórico pagarés';
    SourceTable = "Cab. borrador pagare";
    SourceTableView = SORTING(Contabilizado)
                    WHERE(Contabilizado = CONST(true));

    layout
    {
        area(Content)
        {
            field("CCC Nº Cuenta"; Rec."CCC Nº Cuenta") { ApplicationArea = All; }
            field("Nombre banco"; Rec."Nombre banco") { ApplicationArea = All; }
            field("Dirección banco"; Rec."Dirección banco") { ApplicationArea = All; }
            field("Cód. pagaré"; Rec."Cód. pagaré")
            {
                ApplicationArea = All;
                trigger OnAssistEdit()
                BEGIN
                    if Rec.AssistEdit(xRec) THEN
                        CurrPage.UPDATE;
                END;
            }
            field("Cód. proveedor"; Rec."Cód. proveedor") { ApplicationArea = All; }
            field(Importe; Rec.Importe)
            {
                ApplicationArea = All;
                Lookup = false;
                DrillDown = false;
            }
            field("Cód. banco"; Rec."Cód. banco") { ApplicationArea = All; }
            field("Cód. divisa"; Rec."Cód. divisa") { ApplicationArea = All; }
            field("Fecha de vto."; Rec."Fecha de vto.") { ApplicationArea = All; }
            field("Nº documento propio"; Rec."Nº documento propio") { ApplicationArea = All; }
            field(TraerNombreProveedor2; TraerNombreProveedor)
            {
                ApplicationArea = All;
                Caption = 'Nombre proveedor';
            }
            field("CCC Oficina"; Rec."CCC Oficina") { ApplicationArea = All; }
            part(SubForm; "Subform hist. pagare")
            {
                ApplicationArea = All;
                SubPageLink = "Cód. pagaré" = FIELD("Cód. pagaré");

            }


        }
    }
    actions
    {
        area(Processing)
        {
            group("&Pagaré")
            {
                Caption = '&Pagaré';
                action(Lista)
                {
                    ApplicationArea = All;
                    ShortCutKey = F5;
                    Caption = 'Lista';
                    trigger OnAction()
                    Begin
                        Page.Runmodal(0, Rec);
                    End;
                }
            }
        }
        // area(Reporting)
        // {
        //     action("Pagarés")
        //     {
        //         ApplicationArea = All;
        //         Image = Documents;
        //         Caption = 'Pagarés';
        //         trigger OnAction()
        //         BEGIN
        //             recPagare.RESET;
        //             recPagare.SETRANGE("Cód. pagaré", Rec."Cód. pagaré");
        //             REPORT.RUN(REPORT::"Impresión pagarés", TRUE, FALSE, recPagare);
        //         END;
        //     }
        //     action("Carta Pagarés")
        //     {
        //         ApplicationArea = All;
        //         Image = Document;
        //         Caption = 'Carta pagarés';
        //         trigger OnAction()
        //         BEGIN
        //             recPagare.RESET;
        //             recPagare.SETRANGE("Cód. pagaré", Rec."Cód. pagaré");
        //             REPORT.RUNMODAL(REPORT::"Impresión carta pagarés", TRUE, FALSE, recPagare);
        //         END;
        //     }
        // }
    }
    VAR
        recPagare: Record "Cab. borrador pagare";

    PROCEDURE TraerNombreProveedor(): Text[30];
    VAR
        recProveedor: Record Vendor;
    BEGIN
        if recProveedor.GET(Rec."Cód. proveedor") THEN
            EXIT(recProveedor.Name);
    END;


}

page 50065 "Subform hist. pagare"
{
    PageType = ListPart;
    Editable = false;
    Caption = 'Subform histórico pagarés';
    SourceTable = "Lin. borrador pagare";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Tipo documento"; Rec."Tipo documento") { ApplicationArea = All; }
                field("No. documento"; Rec."No. documento") { ApplicationArea = All; }
                field("No. documento proveedor"; Rec."No. documento proveedor") { ApplicationArea = All; }
                field("Fecha documento"; Rec."Fecha documento") { ApplicationArea = All; }
                field("Cod. divisa"; Rec."Cod. divisa") { ApplicationArea = All; }
                field(Importe; Rec.Importe) { ApplicationArea = All; }
            }
        }
    }
}