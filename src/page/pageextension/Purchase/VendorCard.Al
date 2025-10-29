/// <summary>
/// PageExtension VendorCard (ID 80137) extends Record Vendor Card.
/// </summary>
pageextension 80137 VendorCard extends "Vendor Card"
{
    layout
    {


        addafter("Preferred Bank Account Code")
        {
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
        }
        addafter("Name 2")
        {
            field("Omitir 347"; Rec."Omitir 347") { ApplicationArea = All; }
            field("Saldo real periodo (DL)"; Rec."Saldo real periodo (DL)") { ApplicationArea = All; }
            field("Saldo en Contab"; Rec."Saldo en Contab") { ApplicationArea = All; }
            field("Saldo en Efecto"; Rec."Saldo en Efecto") { ApplicationArea = All; }

            group(Comentarios)
            {
                Editable = CurrPageEditable;
                field(MatComent1; MatComent[1]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent2; MatComent[2]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent3; MatComent[3]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent4; MatComent[4]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent5; MatComent[5]) { ApplicationArea = All; ShowCaption = false; }
            }
            field("Fecha ult movimiento"; Rec."Fecha ult movimiento") { ApplicationArea = All; }

            field("Fecha ult factura"; Rec."Fecha ult factura") { ApplicationArea = All; }
            field("Contacto Facturación"; Rec."Contacto Facturación") { ApplicationArea = All; }
        }
        addafter("Prepayment %")
        {
            field("Importe emplazamientos"; Rec."Importe emplazamientos") { ApplicationArea = All; }
            field("Importe pte. emplazamientos"; Rec."Importe pte. emplazamientos") { ApplicationArea = All; }
            field(Soporte; Rec.Soporte) { ApplicationArea = All; }
            field("Generar Cartera Albarán"; Rec."Generar Cartera Albarán") { ApplicationArea = All; }
        }
        addafter("Block Payment Tolerance")
        {
            // field("Liq. Payment Terms Code"; Rec."Liq. Payment Terms Code") { ApplicationArea = All; }
            // field(Banco; Rec.Banco) { ApplicationArea = All; }
        }
    }
    actions
    {
        // modify("Ledger E&ntries")
        // {
        //     Visible = false;
        // }
        // addafter("Ledger E&ntries")
        // {
        //     action("M&ovimientos")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Ledger E&ntries';
        //         Image = VendorLedger;
        //         RunObject = Page "Vendor LedgerEntries";
        //         RunPageLink = "Vendor No." = FIELD("No.");
        //         RunPageView = SORTING("Vendor No.")
        //                           ORDER(Descending);
        //         ShortCutKey = 'Ctrl+F7';
        //         ToolTip = 'View the history of transactions that have been posted for the selected record.';
        //     }
        // }
        // modify("Ledger E&ntries_Promoted")
        // {
        //     Visible = false;
        // }
        // addafter("Ledger E&ntries_Promoted")
        // {
        //     actionref("M&ovimientos_Promoted"; "M&ovimientos") { }
        // }
        addlast("Ven&dor")
        {
            action("Referencia Catastral")
            {
                ApplicationArea = All;
                Image = Addresses;
                Caption = 'Referencia Catastral';
                trigger OnAction()
                Var
                    rRef: Record "Ref Catastral Address";
                BEGIN
                    rRef.INIT;
                    rRef."Vendor No." := Rec."No.";
                    rRef.Code := Rec."No.";
                    rRef.Name := Rec.Name;
                    rRef."Name 2" := Rec."Name 2";
                    rRef.Address := Rec.Address;
                    rRef."Address 2" := Rec."Address 2";
                    rRef.City := Rec.City;
                    rRef."Phone No." := Rec."Phone No.";
                    rRef."Country/Region Code" := Rec."Country/Region Code";
                    rRef."Post Code" := Rec."Post Code";
                    rRef.County := Rec.County;
                    rRef.Tipo := rRef.Tipo::Proveedor;
                    if rRef.INSERT THEN;
                    rRef.SETRANGE(rRef."Vendor No.", Rec."No.");
                    rRef.SETRANGE(rRef.Code, Rec."No.");
                    COMMIT;
                    Page.Runmodal(Page::"Lista Referencias Catastrales", rRef);
                END;
            }

            action("Anotaciones")
            {
                ApplicationArea = All;
                Image = Notes;
                Caption = 'Anotaciones';
                // RunObject = Page 124;
                // RunPageLink = "Table Name" = CONST(Anotaciones),
                //              "No." = FIELD("No."), Proveedor = const(true);
                trigger OnAction()
                var
                    rAnot: Record "Comment Line";
                    fAnot: Page "Comment Sheet";
                begin
                    rAnot.SETRANGE("Table Name", "Comment Line Table Name"::Anotaciones);
                    rAnot.SETRANGE("No.", Rec."No.");
                    rAnot.SETRANGE(Proveedor, TRUE);
                    fAnot.SetTableView(rAnot);
                    fAnot.Procedure_proveedor();
                    fAnot.run;
                end;
            }
        }
        addafter(Templates)
        {

            action(Salda)
            {
                ApplicationArea = All;
                Image = Balance;
                ShortCutKey = F2;
                Caption = 'Salda';
                trigger OnAction()
                Var
                    r379: Record 380;
                    r21: Record 25;
                    a: Integer;
                    Ip: Decimal;
                    Ipd: Decimal;
                BEGIN
                    r379.FINDLAST;
                    a := r379."Entry No.";
                    Rec.COPYFILTER("Date Filter", r21."Posting Date");
                    r21.SETRANGE(r21."Vendor No.", Rec."No.");
                    if r21.FINDFIRST THEN
                        REPEAT
                            r21.CALCFIELDS(r21."Remaining Amount", r21."Remaining Amt. (LCY)");
                            if r21."Remaining Amt. (LCY)" <> 0 THEN BEGIN
                                a := a + 1;
                                Ip := r21."Remaining Amount";
                                Ipd := r21."Remaining Amt. (LCY)";
                                r379.SETCURRENTKEY(r379."Vendor Ledger Entry No.");
                                r379.SETRANGE(r379."Vendor Ledger Entry No.", r21."Entry No.");
                                r379.FINDFIRST;
                                r379."Entry No." := a;
                                r379."Entry Type" := r379."Entry Type"::Application;
                                r379.Amount := -Ip;
                                r379."Amount (LCY)" := -Ipd;
                                if r379.Amount > 0 THEN BEGIN
                                    r379."Debit Amount" := r379.Amount;
                                    r379."Debit Amount (LCY)" := r379."Amount (LCY)";
                                    r379."Credit Amount" := 0;
                                    r379."Credit Amount (LCY)" := 0;
                                END ELSE BEGIN
                                    r379."Credit Amount" := -r379.Amount;
                                    r379."Credit Amount (LCY)" := -r379."Amount (LCY)";
                                    r379."Debit Amount (LCY)" := 0;
                                    r379."Debit Amount" := 0;
                                END;
                                r379.INSERT;
                            END;
                            r21.Open := FALSE;
                            r21.MODIFY;
                        UNTIL r21.NEXT = 0;
                    if Rec.NEXT <> 0 THEN CurrPage.UPDATE(FALSE);
                END;
            }
        }
        addafter("Request Approval")
        {
            group("Pagarés")
            {
                Image = VendorBill;
                action("Un solo proveedor")
                {
                    Image = Payment;
                    ApplicationArea = All;
                    Caption = 'Un solo proveedor';
                    trigger OnAction()
                    BEGIN
                        rExt.SETCURRENTKEY(rExt."Document No.", rExt."Document Type", rExt."Vendor No.");
                        rExt.SETRANGE("Vendor No.", Rec."No.");
                        Page.Runmodal(Page::"Relacion pagos", rExt);
                    END;
                }
                action("Todos los proveedores")
                {
                    Image = Payables;
                    ApplicationArea = All;
                    Caption = 'Todos los proveedores';
                    trigger OnAction()
                    BEGIN
                        rExt.SETCURRENTKEY(rExt."Document No.", rExt."Document Type", rExt."Vendor No.");
                        Page.Runmodal(Page::"Relacion pagos", rExt);
                    END;
                }
            }


        }
        addlast(Category_Category4)
        {
            actionref(Anotaciones_Promoted; "Anotaciones") { }
            actionref(Ref_Promoted; "Referencia Catastral") { }
        }
    }

    VAR
        CalendarMgmt: Codeunit 7600;
        PaymentToleranceMgt: Codeunit 426;
        CustomizedCalEntry: Record 7603;
        CustomizedCalendar: Record 7602;
        Text001: Label '¿Desea permitir la tolerancia de pago para movimientos pendientes?';
        Text002: Label '¿Confirma que desea eliminar la tolerancia pago de los movimientos actualmente pendientes?';
        rLinComent: Record 97;
        PurchInfoPaneMgt: Codeunit 7181;
        rExt: Record 25;
        MatComent: ARRAY[5] OF Text[80];
        CurrPageEditable: Boolean;
        AlbaranVisible: Boolean;
    //onaftergetrecord() llamar a activatefields y obtenercomentarios
    trigger OnAfterGetRecord()
    begin
        activatefields();
        CurrPageEditable := CurrPage.Editable;
        obtenercomentarios();
    end;

    PROCEDURE ActivateFields();
    VAR
        Control: Codeunit "ControlProcesos";
    BEGIN
        AlbaranVisible := Control.CompruebaPermisos(UserSecurityId(), 'MARCAALB', Companyname);
    END;

    PROCEDURE ObtenerComentarios();
    VAR
        indice: Integer;
    BEGIN
        //$001
        CLEAR(MatComent);
        CLEAR(indice);
        rLinComent.RESET;
        rLinComent.SETRANGE("Table Name", rLinComent."Table Name"::Vendor);
        rLinComent.SETRANGE("No.", Rec."No.");
        if rLinComent.FIND('-') THEN BEGIN
            REPEAT
                indice := indice + 1;
                MatComent[indice] := rLinComent.Comment;
            UNTIL (rLinComent.NEXT = 0) OR (indice = 5);
        END;
    END;
    // BEGIN
    // {
    //   $001 FCL-18/10/10. Incluyo en pantalla varias líneas de comentario no editables.
    //   $002 FCL-24/11/10. Incluyo fecha último movimiento, fecha última factura, y cambio nombre campo bloqueado.
    // }
    // END.
}