/// <summary>
/// Page Fra y abonos ptes. (ID 50052).
/// </summary>
page 50020 "Fra y abonos ptes."
{
    SourceTable = "Vendor Ledger Entry";
    PageType = List;
    UsageCategory = Lists;
    Permissions = TableData 25 = rm;
    Caption = 'Fra y abonos ptes.';
    InsertAllowed = false;
    DeleteAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;

    SourceTableView = WHERE("Document Type" = FILTER(' ' | Invoice | "Credit Memo" | 25),
                          Open = CONST(true));

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {

                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                //    { 5   ;Label        ;0    ;0    ;0    ;0    ;

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                //    { 7   ;Label        ;0    ;0    ;0    ;0    ;

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                //    { 9   ;Label        ;0    ;0    ;0    ;0    ;

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                //    { 11  ;Label        ;0    ;0    ;0    ;0    ;

                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;

                }
                //    { 23  ;Label        ;0    ;0    ;0    ;0    ;

                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }



                //    { 25  ;Label        ;0    ;0    ;0    ;0    ;

                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }



                //    { 1103355001;Label  ;0    ;0    ;0    ;0    ;

                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }



                //    { 1103355003;Label  ;0    ;0    ;0    ;0    ;

                field(Amount; Rec.Amount) { ApplicationArea = All; }



                //    { 13  ;Label        ;0    ;0    ;0    ;0    ;

                field("Remaining Amount"; Rec."Remaining Amount") { ApplicationArea = All; }



                //    { 15  ;Label        ;0    ;0    ;0    ;0    ;

                field("Remaining Amt. (LCY)"; Rec."Remaining Amt. (LCY)") { ApplicationArea = All; }



                //    { 26  ;Label        ;0    ;0    ;0    ;0    ;

                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }



                //    { 18  ;Label        ;0    ;0    ;0    ;0    ;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&pagar")
            {
                Caption = '&Pagaré';
                action("&Crear")
                {
                    ApplicationArea = All;
                    ShortCutKey = F3;
                    Caption = '&Crear';
                    trigger OnAction()
                    VAR
                        cGestionPagare: Codeunit GestionPagare;
                    BEGIN

                        rMovProv.COPY(Rec);
                        CurrPage.SETSELECTIONFILTER(rMovProv);
                        cGestionPagare.CrearPagares(rMovProv);
                    END;
                }
            }
        }
    }
    VAR
        rMovProv: Record 25;

    trigger OnOpenPage()
    VAR
        rConfComp: Record "Purchases & Payables Setup";
        rFormas: Record 289;
        rProveedor: Record Vendor;
    BEGIN
        rConfComp.GET;
        // rConfComp.TESTFIELD("Forma pago Pagare");
        // if rFormas.GET(rConfComp."Forma pago Pagare") THEN BEGIN
        //     rFormas.TESTFIELD("Create Bills", FALSE);
        // END;
        // if (Rec."Vendor No." <> '') THEN BEGIN
        //     if rProveedor.GET(Rec."Vendor No.") THEN BEGIN
        //         if rProveedor."Payment Method Code" <> rConfComp."Forma pago Pagare" THEN
        //             Rec.SETRANGE("Cod. Forma Pago", rConfComp."Forma pago Pagare")
        //         ELSE
        //             Rec.SETRANGE("Cod. Forma Pago", rProveedor."Payment Method Code");
        //     END;
        // END ELSE BEGIN
        //     Rec.SETRANGE("Cod. Forma Pago", rConfComp."Forma pago Pagare");
        // END;

        // SGB3600999
        Rec.SETRANGE("On Hold", '');
        // FIN SGB
    END;

    trigger OnClosePage()
    BEGIN
        rMovProv.RESET;
        rMovProv.SETCURRENTKEY(Usuario);
        if USERID <> '' THEN
            rMovProv.SETRANGE(Usuario, USERID)
        ELSE
            rMovProv.SETRANGE(Usuario, '******');
        rMovProv.MODIFYALL(Usuario, '');
    END;


    //     BEGIN
    //     {
    //       SGB 300999
    //       Que no muestre los movimientos que están en espera

    //       // PLB 23/01/2001

    //       // PLB 23/07/2002
    //       Se ha traspasado el campo "Parametros pagare" de "Configuración contabilidad" a
    //       "Forma pago pagare" de "Conf. compras y pagos"

    //       // PLB 26/02/2003
    //       Posibilidad de generar un Pagaré por proveedor o un Pagaré por proveedor y fecha vencimiento

    //       // PLB 28/06/2006
    //       GSH-110: Poder emitir pagarés con movimientos con tipo documento en blanco

    //       // PLB 27/06/2007
    //       Poder visualizar las dimensiones globales
    //     }
    //     END.
    //   }
}
