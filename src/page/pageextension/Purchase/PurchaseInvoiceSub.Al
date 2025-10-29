/// <summary>
/// PageExtension PurchInvoiceSubPage (ID 80210).
/// </summary>
pageextension 80203 PurchInvoiceSubPage Extends "Purch. Invoice Subform"
{
    layout
    {
        addAfter(Description)
        {
            field("Periodo de Pago"; Rec."Periodo de Pago") { ApplicationArea = All; }
            //field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
            //field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group") { ApplicationArea = All; }
            //  field("VAT Prod. Posting Group";Rec."VAT Prod. Posting Group"){ApplicationArea=All;}
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }
        modify("Gen. Prod. Posting Group")
        {
            Visible = true;
        }
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Tax Group Code")
        {
            Visible = false;
        }
        modify("Qty. Assigned")
        {
            Visible = false;
        }
        modify("Qty. to Assign")
        {
            Visible = false;
        }
        addafter("Direct Unit Cost")
        {
            field("Importe Iva"; (Rec."VAT Base Amount" * (Rec."VAT %" / 100))) { ApplicationArea = All; }
        }


    }



}
