page 7001122 "Lista docs. vta. relacionados"
{
    //Version List=MLL1.00;
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = 36;
    DataCaptionFields = "Document Type";
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
                field("Document Type"; Rec."Document Type") { ApplicationArea = All; }
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field("Amount"; Rec.Amount) { ApplicationArea = All; }
                field("Amount Including VAT"; Rec."Amount Including VAT") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("Sell-to Post Code"; Rec."Sell-to Post Code") { ApplicationArea = All; }
                field("Posting Description"; Rec."Posting Description") { ApplicationArea = All; }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code") { ApplicationArea = All; }
                field("Sell-to Contact"; Rec."Sell-to Contact") { ApplicationArea = All; }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { ApplicationArea = All; }
                field("Bill-to Name"; Rec."Bill-to Name") { ApplicationArea = All; }
                field("Bill-to Post Code"; Rec."Bill-to Post Code") { ApplicationArea = All; }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code") { ApplicationArea = All; }
                field("Bill-to Contact"; Rec."Bill-to Contact") { ApplicationArea = All; }
                field("Ship-to Code"; Rec."Ship-to Code") { ApplicationArea = All; }
                field("Ship-to Name"; Rec."Ship-to Name") { ApplicationArea = All; }
                field("Ship-to Post Code"; Rec."Ship-to Post Code") { ApplicationArea = All; }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code") { ApplicationArea = All; }
                field("Ship-to Contact"; Rec."Ship-to Contact") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                //    { 140 ;Label        ;0    ;0    ;0    ;0    ;
                field("Document Date"; Rec."Document Date") { ApplicationArea = All; }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto") { ApplicationArea = All; }
                field("Fecha fin proyecto"; Rec."Fecha fin proyecto") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("&Hist. Fras.")
            {
                ApplicationArea = All;
                Image = SalesInvoice;
                Caption = '&Hist. Fras.';
                RunObject = Page 143;
                //RunPageLinkType=OnUpdate;
                //RunPageView = SORTING("Nº Contrato");
                RunPageLink = "Nº Contrato" = FIELD("No.");
            }
        }
    }

}