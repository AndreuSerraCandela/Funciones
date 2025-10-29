/// <summary>
/// Report Renove Purchase Document (ID 50013).
/// </summary>
report 50010 "Renove Purchase Document"
{

    Caption = 'Renovar documento Compra';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Optiones';
                    // field(DocumentType; FromDocType)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Document Type';
                    //     ToolTip = 'Specifies the type of document that is processed by the report or batch job.';

                    //     trigger OnValidate()
                    //     begin
                    //         FromDocNo := '';
                    //         ValidateDocNo();
                    //     end;
                    // }
                    field(DocumentNo; FromDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Nº Documento';
                        ToolTip = 'Pedido Original';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo();
                        end;

                        trigger OnValidate()
                        begin
                            ValidateDocNo();
                        end;
                    }
                    // field(DocNoOccurrence; FromDocNoOccurrence)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     BlankZero = true;
                    //     Caption = 'Doc. No. Occurrence';
                    //     Editable = false;
                    //     ToolTip = 'Specifies the number of times the No. value has been used in the number series.';
                    // }
                    // field(DocVersionNo; FromDocVersionNo)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     BlankZero = true;
                    //     Caption = 'Version No.';
                    //     Editable = false;
                    //     ToolTip = 'Specifies the version of the document to be copied.';
                    // }
                    // field(BuyfromVendorNo; FromPurchHeader."Buy-from Vendor No.")
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Buy-from Vendor No.';
                    //     Editable = false;
                    //     ToolTip = 'Specifies the vendor according to the values in the Document No. and Document Type fields.';
                    // }
                    // field(BuyfromVendorName; FromPurchHeader."Buy-from Vendor Name")
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Buy-from Vendor Name';
                    //     Editable = false;
                    //     ToolTip = 'Specifies the vendor according to the values in the Document No. and Document Type fields.';
                    // }
                    // field(IncludeHeader_Options; IncludeHeader)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Include Header';
                    //     ToolTip = 'Specifies if you also want to copy the information from the document header. When you copy quotes, if the posting date field of the new document is empty, the work date is used as the posting date of the new document.';

                    //     trigger OnValidate()
                    //     begin
                    //         ValidateIncludeHeader();
                    //     end;
                    // }
                    // field(RecalculateLines; RecalculateLines)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Recalculate Lines';
                    //     ToolTip = 'Specifies that lines are recalculate and inserted on the purchase document you are creating. The batch job retains the item numbers and item quantities but recalculates the amounts on the lines based on the vendor information on the new document header. In this way, the batch job accounts for item prices and discounts that are specifically linked to the vendor on the new header.';

                    //     trigger OnValidate()
                    //     begin
                    //         if (FromDocType = FromDocType::"Posted Receipt") or (FromDocType = FromDocType::"Posted Return Shipment") then
                    //             RecalculateLines := true;
                    //     end;
                    // }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin

            if FromDocNo <> '' then begin


                if FromPurchHeader.Get(FromPurchHeader."Document Type"::Order, FromDocNo) then;

                if FromPurchHeader."No." = '' then
                    FromDocNo := '';
            end;
            ValidateDocNo();


        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin

        PurchSetup.Get();
        CopyDocMgt.SetProperties(
          IncludeHeader, RecalculateLines, false, false, false, PurchSetup."Exact Cost Reversing Mandatory", false);
        CopyDocMgt.SetArchDocVal(FromDocNoOccurrence, FromDocVersionNo);


        CopyDocMgt.CopyPurchDoc("Purchase Document Type From"::Order, FromDocNo, PurchHeader);

    end;

    var
        Text000: Label 'The price information may not be reversed correctly, if you copy a %1. if possible, copy a %2 instead or use %3 functionality.';
        Text001: Label 'Undo Receipt';
        Text002: Label 'Undo Return Shipment';

    protected var
        PurchHeader: Record "Purchase Header";
        FromPurchHeader: Record "Purchase Header";
        FromPurchRcptHeader: Record "Purch. Rcpt. Header";
        FromPurchInvHeader: Record "Purch. Inv. Header";
        FromReturnShptHeader: Record "Return Shipment Header";
        FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        FromPurchHeaderArchive: Record "Purchase Header Archive";
        PurchSetup: Record "Purchases & Payables Setup";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        FromDocNo: Code[20];
        FromDocNoOccurrence: Integer;
        FromDocVersionNo: Integer;
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;

    /// <summary>
    /// SetPurchHeader.
    /// </summary>
    /// <param name="NewPurchHeader">VAR Record "Purchase Header".</param>
    procedure SetPurchHeader(var NewPurchHeader: Record "Purchase Header")
    begin
        NewPurchHeader.TestField("No.");
        PurchHeader := NewPurchHeader;
    end;

    /// <summary>
    /// GetNo.
    /// </summary>
    /// <returns>Return value of type Code[20].</returns>
    procedure GetNo(): Code[20]
    begin
        Exit(FromDocNo);
    end;

    local procedure ValidateDocNo()
    var
        FromDocType: Enum "Purchase Document Type From";
    begin
        if FromDocNo = '' then begin
            FromPurchHeader.Init();
            FromDocNoOccurrence := 0;
            FromDocVersionNo := 0;
        end else
            if FromDocNo <> FromPurchHeader."No." then begin
                FromPurchHeader.Init();
                FromPurchHeader.Get(FromPurchHeader."Document Type"::Order, FromDocNo);


            end;
        FromPurchHeader."No." := '';
        FromDocType := FromDocType::Order;
        IncludeHeader :=
          (FromDocType in [FromDocType::"Posted Invoice", FromDocType::"Posted Credit Memo"]) and
          ((FromDocType = FromDocType::"Posted Credit Memo") <>
           (PurchHeader."Document Type" = PurchHeader."Document Type"::"Credit Memo")) and
          (PurchHeader."Buy-from Vendor No." in [FromPurchHeader."Buy-from Vendor No.", '']);

        ValidateIncludeHeader();
    end;

    local procedure FindFromPurchHeaderArchive()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        if not FromPurchHeaderArchive.Get(
            FromPurchHeader."Document Type"::Order, FromDocNo, FromDocNoOccurrence, FromDocVersionNo)
        then begin
            FromPurchHeaderArchive.SetRange("No.", FromDocNo);
            if FromPurchHeaderArchive.FindLast() then begin
                FromDocNoOccurrence := FromPurchHeaderArchive."Doc. No. Occurrence";
                FromDocVersionNo := FromPurchHeaderArchive."Version No.";
            end;
        end;
    end;

    local procedure LookupDocNo()
    begin
        LookupPurchDoc();


        ValidateDocNo();
    end;

    local procedure LookupPurchDoc()
    begin

        FromPurchHeader.FilterGroup := 0;
        FromPurchHeader.SetRange("Document Type", FromPurchHeader."Document Type"::Order);
        if PurchHeader."Document Type" = FromPurchHeader."Document Type"::Order then
            FromPurchHeader.SetFilter("No.", '<>%1', PurchHeader."No.");
        FromPurchHeader.FilterGroup := 2;
        FromPurchHeader."Document Type" := FromPurchHeader."Document Type"::Order;
        FromPurchHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromPurchHeader.SetCurrentKey("Document Type", "Buy-from Vendor No.") then begin
                FromPurchHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromPurchHeader.Find('=><') then;
            end;
        if PAGE.RunModal(0, FromPurchHeader) = ACTION::LookupOK then
            FromDocNo := FromPurchHeader."No.";
    end;


    protected procedure ValidateIncludeHeader()
    var
        FromDocType: Enum "Purchase Document Type From";
    begin
        FromDocType := FromDocType::Order;
        RecalculateLines :=
          (FromDocType in [FromDocType::"Posted Receipt", FromDocType::"Posted Return Shipment"]) or not IncludeHeader;
    end;

    /// <summary>
    /// SetParameters.
    /// </summary>
    /// <param name="NewFromDocType">Enum "Purchase Document Type From".</param>
    /// <param name="NewFromDocNo">Code[20].</param>
    /// <param name="NewIncludeHeader">Boolean.</param>
    /// <param name="NewRecalcLines">Boolean.</param>
    procedure SetParameters(NewFromDocType: Enum "Purchase Document Type From"; NewFromDocNo: Code[20]; NewIncludeHeader: Boolean; NewRecalcLines: Boolean)
    begin
        //FromDocType := NewFromDocType;
        FromDocNo := NewFromDocNo;
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalcLines;
    end;



}
