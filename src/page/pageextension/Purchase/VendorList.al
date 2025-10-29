/// <summary>
/// PageExtension VendorList (ID 80138) extends Record Vendor List.
/// </summary>
pageextension 80138 VendorList extends "Vendor List"
{
    layout
    {
        addafter(Name)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = All;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
            field("Preferred Bank Account Code"; Rec."Preferred Bank Account Code")
            {
                ApplicationArea = All;
            }
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
            // field("Saldo en Contab"; Rec."Saldo en Contab")
            // {
            //     ApplicationArea = all;
            //     Visible = Nomolestar;
            // }
            // field("Saldo periodo Contab"; Rec."Saldo periodo Contab")
            // {
            //     ApplicationArea = all;
            //     Visible = Nomolestar;
            // }
            field(Balance; Rec.Balance)
            {
                ApplicationArea = all;
                Visible = Nomolestar;
            }
            field("Net Change"; Rec."Net Change")
            {
                ApplicationArea = all;
                Visible = Nomolestar;
            }


        }
        modify("Balance (LCY)")
        {
            Visible = Nomolestar;
        }
        addafter("Balance (LCY)")
        {
            field("Saldo Vencido"; Rec."Balance Due (LCY)")
            {
                ApplicationArea = All;
                Visible = Nomolestar;
            }
        }
        modify("Balance Due (LCY)")
        {
            Visible = false;

        }
        modify("Payments (LCY)")
        {
            Visible = Nomolestar;

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
        addafter("&Purchases")
        {
            action("Asigna Dimensiones")
            {
                Image = MapDimensions;
                ApplicationArea = All;
                trigger OnAction()
                var
                    r349: Record "Dimension Value";
                    r348: Record Dimension;
                    rRes: Record Vendor;
                    rDiRe: Record "Default Dimension";
                begin

                    if Page.RUNMODAL(0, r348) = ACTION::LookupOK THEN BEGIN
                        r349.SETRANGE(r349."Dimension Code", r348.Code);
                        if Page.RUNMODAL(0, r349) = ACTION::LookupOK THEN BEGIN
                            CurrPage.SETSELECTIONFILTER(rRes);
                            if rRes.FINDFIRST THEN
                                REPEAT
                                    if rDiRe.GET(23, rRes."No.", r349."Dimension Code") THEN rDiRe.DELETE;
                                    rDiRe."Table ID" := 23;
                                    rDiRe."No." := rRes."No.";
                                    rDiRe."Dimension Code" := r349."Dimension Code";
                                    rDiRe."Dimension Value Code" := r349.Code;
                                    rDiRe.INSERT;
                                UNTIL rRes.NEXT = 0;
                        END;
                    END;
                end;
            }
            action("Mostrar Saldos")
            {
                Image = Balance;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Nomolestar := true;
                    CurrPage.Update(false);
                end;
            }
            action("Proveedores Erroneos")
            {
                Image = ErrorLog;
                ApplicationArea = All;
                trigger OnAction()
                var
                    rCust: Record Vendor;
                begin

                    Rec.CLEARMARKS;
                    if rCust.FINDFIRST THEN
                        REPEAT
                            rCust.CALCFIELDS(rCust."Net Change (LCY)", rCust."Saldo en Contab", rCust."Saldo real (DL)");
                            if (ABS(rCust."Net Change (LCY)" - rCust."Saldo en Contab") > 5) OR
                            (ABS(rCust."Saldo en Contab" - rCust."Saldo real (DL)") > 5) OR
                            (ABS(rCust."Saldo real (DL)" - rCust."Net Change (LCY)") > 5)
                            THEN BEGIN
                                Rec.GET(rCust."No.");
                                Rec.MARK := TRUE;
                            END;
                        UNTIL rCust.NEXT = 0;
                    Rec.MARKEDONLY := TRUE;
                end;
            }
            action("Dimensiones desde Malla")
            {
                Image = CopyDimensions;
                ApplicationArea = All;
                trigger OnAction()
                var
                    rPro: Record Vendor;
                    rDim: Record "Default Dimension";
                    rProMy: Record Vendor;
                    rDimMy: Record "Default Dimension";
                begin

                    CurrPage.SETSELECTIONFILTER(rPro);
                    if rPro.FINDFIRST THEN
                        REPEAT
                            rProMy.CHANGECOMPANY('Malla Publicidad');
                            if rProMy.GET(rPro."No.") THEN BEGIN
                                rDimMy.CHANGECOMPANY('Malla Publicidad');
                                rDimMy.SETRANGE(rDimMy."Table ID", 23);
                                rDimMy.SETRANGE(rDimMy."No.", rProMy."No.");
                                if rDimMy.FINDFIRST THEN
                                    REPEAT
                                        rDim := rDimMy;
                                        if rDim.INSERT THEN;
                                    UNTIL rDimMy.NEXT = 0;
                            END;
                        UNTIL rPro.NEXT = 0;
                end;
            }
        }
        addlast(processing)
        {
            action("Generar Pagarés")
            {
                Image = VendorBill;
                ApplicationArea = All;
                trigger OnAction()
                var
                    MovProveedor: Record "Vendor Ledger Entry";
                Begin
                    //SORTING(Vendor No.,Open,Positive,Due Date,Currency Code) WHERE(Document Type=FILTER(' '|Invoice|Credit Memo|Bill),Remaining Amount=FILTER(<>0))
                    MovProveedor.SetFilter("Document Type", '%1|%2|%3|%4', MovProveedor."Document Type"::" ", MovProveedor."Document Type"::Invoice, MovProveedor."Document Type"::"Credit Memo", MovProveedor."Document Type"::Bill);
                    MovProveedor.SetFilter("Remaining Amount", '<>%1', 0);
                    Page.RunModal(0, MovProveedor);
                end;
            }
        }
        addlast("Ven&dor")
        {
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

        addlast(Promoted)
        {
            actionref(Mostrar_Saldos_Promoted; "Mostrar Saldos") { }
            actionref("Anotaciones_Ref"; "Anotaciones") { }
        }
    }
    var
        nomolestar: Boolean;

    trigger OnOpenPage()
    begin
        nomolestar := false;
    end;
}