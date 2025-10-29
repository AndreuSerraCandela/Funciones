/// <summary>
/// PageExtension CFLiqCta (ID 80217) extends Record Cash Flow Account Card.
/// </summary>
pageextension 80208 CFLiqCta extends "Cash Flow Account Card"
{
    layout
    {
        addafter("G/L Integration")
        {
            field("Banco Informes"; Rec."Banco Informes")
            {
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    "Nombre Banco": Record "Nombre Banco";
                begin
                    if Page.RunModal(0, "Nombre Banco") in [Action::LookupOK, Action::OK] Then begin
                        Rec."Banco Informes" := "Nombre Banco"."Nombre Banco";
                        Rec.Modify();
                    end;
                end;
            }
            field("Cod banco"; Rec."Cod banco") { ApplicationArea = All; }
            field("Calcular vto Cuenta ( ,M,T)"; Rec."Calcular vto. Cuenta") { ApplicationArea = All; ValuesAllowed = ' ', 'M', 'T'; Caption = 'Calcular vto Cuenta ( ,M,T)'; }
            field("Dias Liquidación DESDE"; Rec."Dias Liquidación DESDE") { ApplicationArea = All; }
            field("Dias Liquidación HASTA"; Rec."Dias Liquidación HASTA") { ApplicationArea = All; }
            field("Solo Atrasados"; Rec."Solo Atrasados") { ApplicationArea = All; }
            field("Solo Cartera"; Rec."Solo Cartera") { ApplicationArea = All; }
            field("Cód. Proveedor"; Rec."Cód. Proveedor") { ApplicationArea = All; }
            field("Cód. Cliente"; Rec."Cód. Cliente") { ApplicationArea = All; }
            field("Cód Prestamo"; Rec."Cód Prestamo") { ApplicationArea = All; }
            field("Debe/Haber"; Rec."Debe/Haber") { ApplicationArea = All; }
            field(Desglosar; Rec.Desglosar) { ApplicationArea = All; }
            field("Vinculado a noº"; Rec."Vinculado a noº") { ApplicationArea = All; }
            field("Pago Impuestos"; Rec."Pago Impuestos") { ApplicationArea = All; }
            field("Tipo Saldo"; Rec."Tipo Saldo") { ApplicationArea = All; }
            field("Dia de pago"; Rec."Dia de pago") { ApplicationArea = All; }
            field("Vto Resto Año"; Rec."Vto Resto Año") { ApplicationArea = All; }
            field("Vto enero"; Rec."Vto enero") { ApplicationArea = All; }
            field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast("A&ccount")
        {

        }
    }
}