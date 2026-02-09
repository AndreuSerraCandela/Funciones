/// <summary>
/// PageExtension FacturaCompraKuara (ID 80107) extends Record Purchase Invoice.
/// </summary>
pageextension 80107 "FacturaCompraKuara" extends "Purchase Invoice"
{
    layout
    {


        addafter("Vendor Invoice No.")
        {
            field(ImporteProv; ImporteProv) { ApplicationArea = All; }
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
            field("Nº proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
        }
        addafter("Responsibility Center")
        {
            field("Periodo de Pago"; Rec."Periodo de Pago") { ApplicationArea = All; }
        }
        addafter("Vendor Bank Acc. Code")
        {
            field(Banco; Rec.Banco) { ApplicationArea = All; }
            field("Descripción operación"; Rec."Descripción operación") { ApplicationArea = All; }
            field("Tipo factura SII"; Rec."Tipo factura SII") { ApplicationArea = All; }
            field("Corrected Invoice No."; Rec."Corrected Invoice No.") { ApplicationArea = All; }
            field("Tipo factura rectificativa"; Rec."Tipo factura rectificativa") { ApplicationArea = All; }
            field("Obviar SII"; Rec."Obviar SII") { ApplicationArea = All; }
            field("Posting No."; Rec."Posting No.") { ApplicationArea = All; }
            field("Posting No. Series"; Rec."Posting No. Series") { ApplicationArea = All; }


            field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
            {
                ApplicationArea = All;
            }
            field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
            {
                ApplicationArea = All;
            }
        }


        // addfirst(FactBoxes)
        // {
        //     part(PDFViewer; "PDF Viewer Part")
        //     {
        //         Caption = 'PDF Viewer';
        //         ApplicationArea = All;
        //     }
        // }
    }
    actions
    {
        addafter(Reopen)
        {
            action("Calcula Dto. Agencias")
            {
                Caption = 'Calcula Dto. Agencias';
                trigger OnAction()
                VAR
                    PurchSetup: Record "Purchases & Payables Setup";
                    PurchLine: Record 39;
                    PurchHeader: Record 38;
                    //DTO: Record 100;
                    PurchLine2: Record 39;
                    InvDiscBase: Decimal;
#pragma warning disable AL0432
                    TempVATAmountLine: Record "VAT Amount Line" TEMPORARY;
#pragma warning restore AL0432
                    TempServiceChargeLine: Record 39 TEMPORARY;
                BEGIN
                    PurchSetup.GET;
                    if Rec.RECORDLEVELLOCKING THEN
                        Rec.LOCKTABLE;
                    PurchHeader.GET(Rec."Document Type", Rec."No.");
                    PurchHeader.TESTFIELD("Vendor Posting Group");
                    PurchLine2.RESET;
                    PurchLine2.SETRANGE("Document Type", Rec."Document Type");
                    PurchLine2.SETRANGE("Document No.", Rec."No.");
                    PurchLine2.SETFILTER(Type, '<>0');
                    if PurchLine2.FIND('-') THEN;
                    PurchLine2.CalcVATAmountLines(0, PurchHeader, PurchLine2, TempVATAmountLine);
                    InvDiscBase :=
                        TempVATAmountLine.GetTotalInvDiscBaseAmount(
                        PurchHeader."Prices Including VAT", PurchHeader."Currency Code");
                    //DTO.SETRANGE(DTO."Nº proveedor","Buy-from Vendor No.");
                    // if DTO.FINDFIRST THEN BEGIN
                    // PurchLine2.SETRANGE("Document Type","Document Type");
                    // PurchLine2.SETRANGE("Document No.","No.");
                    // PurchLine2.SETFILTER(Type,'<>0');
                    // if PurchLine2.FIND('+') THEN BEGIN
                    //     PurchLine:=PurchLine2;
                    //     PurchLine."Line No.":=PurchLine."Line No."+10000;
                    //     PurchLine."Receipt No.":='';
                    //     PurchLine."Receipt Line No.":=0;
                    //     PurchLine.Description:='Descuento Agencia';
                    //     PurchLine.VALIDATE(Quantity,-1);
                    //     PurchLine.VALIDATE("Direct Unit Cost",InvDiscBase*DTO."% Descuento"/100);
                    //     PurchLine.INSERT;
                    // END;
                    // END;
                END;
            }
        }

    }
    var
        myInt: Integer;
        PurchSetup: Record "Purchases & Payables Setup";
        ChangeExchangeRate: Page 511;
        CopyPurchDoc: Report 492;
        MoveNegPurchLines: Report 6698;
        ReportPrint: Codeunit 228;
        UserMgt: Codeunit 5700;
        PurchInfoPaneMgmt: Codeunit 7181;

    PROCEDURE ImporteProv(): Decimal;
    VAR
        rIc: Record 413;
        r112: Record 112;
        rCust: Record Customer;
        wEmpresa: Text[30];
        r23: Record Vendor;
        IncomingDocument: Record "Incoming Document";
    BEGIN
        If Rec."Incoming Document Entry No." <> 0 THEN BEGIN
            If IncomingDocument.GET(Rec."Incoming Document Entry No.") Then
                EXIT(IncomingDocument."Amount Incl. VAT");
        END;
        if NOT r23.GET(Rec."Buy-from Vendor No.") THEN EXIT(0);
        if NOT rIc.GET(r23."IC Partner Code") THEN EXIT(0);
        wEmpresa := rIc."Inbox Details";
        //rCust.CHANGECOMPANY(wEmpresa);
        //rCust.SETRANGE(rCust."IC Partner Code",rIc.Code);
        //rCust.FINDFIRST;
        r112.CHANGECOMPANY(wEmpresa);
        if r112.GET(Rec."Vendor Invoice No.") THEN BEGIN
            r112.Calcfields(r112."Amount Including VAT");
            EXIT(r112."Amount Including VAT");
        END;
    END;

    PROCEDURE CompruebaFactura();
    VAR
        TotalPurchLine: Record 39;
        TotalPurchLineLCY: Record 39;
        Vend: Record Vendor;
#pragma warning disable AL0432
        TempVATAmountLine: Record "VAT Amount Line" TEMPORARY;
#pragma warning restore AL0432
        PurchSetup: Record "Purchases & Payables Setup";
        PurchPost: Codeunit 90;
        TotalAmount1: Decimal;
        TotalAmount2: Decimal;
        VATAmount: Decimal;
        VATAmountText: Text[30];
        PrevNo: Code[20];
        AllowInvDisc: Boolean;
        AllowVATDifference: Boolean;
        TempPurchLine: Record 39 TEMPORARY;
    BEGIN
        //CLEAR(PurchLine);
        CLEAR(TotalPurchLine);
        CLEAR(TotalPurchLineLCY);
        CLEAR(PurchPost);
        PurchPost.GetPurchLines(Rec, TempPurchLine, 0);
        CLEAR(PurchPost);
        PurchPost.SumPurchLinesTemp(
          Rec, TempPurchLine, 0, TotalPurchLine, TotalPurchLineLCY, VATAmount, VATAmountText);
        if Rec."Prices Including VAT" THEN BEGIN
            TotalAmount2 := TotalPurchLine.Amount;
            TotalAmount1 := TotalAmount2 + VATAmount;
            TotalPurchLine."Line Amount" := TotalAmount1 + TotalPurchLine."Inv. Discount Amount"
              + TotalPurchLine."Pmt. Discount Amount";
        END ELSE BEGIN
            TotalAmount1 := TotalPurchLine.Amount;
            TotalAmount2 := TotalPurchLine."Amount Including VAT";
        END;
        if ImporteProv <> TotalAmount2 THEN
            ERROR('La factura que esta contabilizando no coincide con la factura de venta');//,TotalAmount2);
    END;



}