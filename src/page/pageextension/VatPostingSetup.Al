/// <summary>
/// PageExtension VatSetup (ID 80170) extends Record VAT Posting Setup.
/// </summary>
pageextension 80180 VatSetup extends "VAT Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Emplazaminentos"; Rec.Emplazaminentos) { ApplicationArea = All; }
            //field("VAT Cash Regime ant";Rec.){ ApplicationArea=All;}
            field("Tipo desglose emitidas"; Rec."Tipo desglose emitidas") { ApplicationArea = All; }
            field("Sujeta exenta"; Rec."Sujeta exenta") { ApplicationArea = All; }
            field("Tipo de operación"; Rec."Tipo de operación") { ApplicationArea = All; }
            field("Obviar SII"; Rec."Obviar SII") { ApplicationArea = All; }
            field("Tipo desglose recibidas"; Rec."Tipo desglose recibidas") { ApplicationArea = All; }
        }
    }
}
