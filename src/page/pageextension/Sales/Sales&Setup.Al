/// <summary>
/// PageExtension SalesSetup (ID 80241) extends Record Sales  Receivables Setup.
/// </summary>
pageextension 80215 SalesSetup extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group(Malla)
            {
                field("Forma pago prepago"; Rec."Forma pago prepago")
                {
                    ApplicationArea = All;
                }
                field("Términos de Pago Prepago."; Rec."Prepay. Terms Code")
                {
                    ApplicationArea = All;
                }
                field("Facturación resaltada"; Rec."Facturación resaltada")
                {
                    ApplicationArea = All;
                }
                field("Activar Cont a 0"; Rec."Activar Cont a 0")
                {
                    ApplicationArea = All;
                }
                field("Activar Prepago"; Rec."Activar Prepago")
                {
                    ApplicationArea = All;
                }
                field("Activar e-informa"; Rec."Activar e-informa")
                {
                    ApplicationArea = All;
                }
                field("Activar Aviso de cobro"; Rec."Activar Aviso cobro")
                {
                    ApplicationArea = All;
                }
            }
            group(Textos)
            {

                field("Pie 1 factura"; Rec."Pie 1 factura") { ApplicationArea = All; }

                field("Pie 2 factura"; Rec."Pie 2 factura") { ApplicationArea = All; }


                field("Pie 3 factura"; Rec."Pie 3 factura") { ApplicationArea = All; }


                field("Texto 1 LOPD"; Rec."Texto 1 LOPD") { ApplicationArea = All; }


                // field("Texto 2 LOPD"; Rec."Texto 2 LOPD") { ApplicationArea = All; }


                // field("Texto 3 LOPD"; Rec."Texto 3 LOPD") { ApplicationArea = All; }


                // field("Texto 4 LOPD"; Rec."Texto 4 LOPD") { ApplicationArea = All; }


                // field("Texto 5 LOPD"; Rec."Texto 5 LOPD") { ApplicationArea = All; }


                // field("Texto 6 LOPD"; Rec."Texto 6 LOPD") { ApplicationArea = All; }

                // field("Texto 7 LOPD"; Rec."Texto 7 LOPD") { ApplicationArea = All; }


                field("Texto empresa"; Rec."Texto empresa") { ApplicationArea = All; }


            }
        }

    }
}