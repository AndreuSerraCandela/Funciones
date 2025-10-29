/// <summary>
/// PageExtension VatBusGroup (ID 80105) extends Record VAT Business Posting Groups.
/// </summary>
pageextension 80105 VatBusGroup extends "VAT Business Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("Clave registro SII expedidas"; Rec."Clave registro SII expedidas") { ApplicationArea = All; }
            field("Clave registro SII recibidas"; Rec."Clave registro SII recibidas") { ApplicationArea = All; }
            field("Devengo SII"; Rec."Devengo SII") { ApplicationArea = All; }

        }
    }
}