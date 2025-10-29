/// <summary>
/// PageExtension SetupCompras (ID 80129) extends Record Purchases  Payables Setup.
/// </summary>
pageextension 80129 SetupCompras extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Invoice Rounding")
        {
            field("Carta pago fraccionado"; Rec."Carta pago fraccionado")
            {
                ApplicationArea = all;
            }
            field("Recursos en proforma"; Rec."Recursos en proforma")
            {
                ApplicationArea = all;

            }
            field("Activar contabilización albaranes"; Rec."Activar contabilización albara")
            {
                ApplicationArea = all;
            }
            field("Impr recursos carta pago"; Rec."Impr recursos carta pago")
            {
                ApplicationArea = All;
            }
        }
        addafter("Posted Credit Memo Nos.")
        {
            field("Nº serie anulaciones"; Rec."Nº serie anulaciones")
            {
                ApplicationArea = All;
            }
            field("Nº serie pagarés"; Rec."Nº serie pagarés")
            {
                ApplicationArea = All;
            }
            group(Emplazamientos)
            {
                field("Num. serie fact. Empl"; Rec."Num. serie fact. Empl")
                {
                    ApplicationArea = All;
                }
                field("Grupo Neg Empla"; Rec."Grupo Neg Empla")
                {
                    ApplicationArea = all;

                }
                // field("Cuenta IRPF Emplz."; Rec."Cuenta IRPF Emplz.")
                // {
                //     ApplicationArea = All;
                // }
                field("Forma de Pago Emplz. Pag"; Rec."Forma de Pago Emplz. Pag")
                {
                    ApplicationArea = All;
                }
                field("Forma de Pago Emplz. Trans"; Rec."Forma de Pago Emplz. Trans")
                {
                    ApplicationArea = All;
                }
                field("Términos de pago emplazamiento"; Rec."Términos de pago emplazamiento")
                {
                    ApplicationArea = All;
                }
                field("Cuenta FPR Emplz."; Rec."Cuenta FPR Emplz.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
