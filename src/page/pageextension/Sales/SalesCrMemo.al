/// <summary>
/// PageExtension SalesCrmemo (ID 80141) extends Record Sales Credit Memo.
/// </summary>
pageextension 80141 SalesCrmemo extends "Sales Credit Memo"
{

    layout
    {


        modify("Posting Description")
        {
            Visible = true;
            ApplicationArea = All;
        }

        addafter(Status)
        {


            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = All;
            }
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = All;

            }
            field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto")
            {
                ApplicationArea = All;

            }
            field("Fecha fin proyecto"; Rec."Fecha fin proyecto")
            {
                ApplicationArea = All;
            }
            field("Posting No. Series"; Rec."Posting No. Series")
            {
                ApplicationArea = All;
            }
            field("No. Series"; Rec."No. Series")
            {
                ApplicationArea = All;
                Editable = true;
            }
            field("Esperar Orden Cliente"; Rec."Esperar Orden Cliente")
            {
                ApplicationArea = All;
            }



        }

        addafter(SalesLines)
        {
            part("Lineas de impresion"; "Lineas de Impresión")
            {
                SubPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
                ApplicationArea = All;

            }
        }


        addafter("SII First Summary Doc. No.")
        {
            field("Tipo factura SII"; Rec."Tipo factura SII")
            {
                ApplicationArea = All;
            }
            field("Descripción operación"; Rec."Descripción operación")
            {
                ApplicationArea = All;
            }
            field("Tipo factura rectificativa"; Rec."Tipo factura rectificativa")
            {
                ApplicationArea = All;
            }
            field("Nº factura correctiva"; Rec."Corrected Invoice No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Foreign Trade")
        {
            group(Comentario)
            {

                field("Comentario Cabecera"; Rec."Comentario Cabecera")
                {
                    ApplicationArea = All;
                }
            }
            group(Proyecto)
            {
                field("Proyecto origen"; Rec."Proyecto origen") { ApplicationArea = All; }
                field("Interc./Compens."; Rec."Interc./Compens.") { Editable = false; ApplicationArea = All; }
                field(Renovado; Rec.Renovado) { Editable = false; ApplicationArea = All; }
                field("Soporte de"; Rec."Soporte de") { Editable = false; ApplicationArea = All; }
                field(Subtipo; Rec.Subtipo) { Editable = false; ApplicationArea = All; }
                field("Fecha Firma"; Rec."Fecha Firma") { Editable = false; ApplicationArea = All; }
                field(Firmado; Rec.Firmado) { Editable = false; ApplicationArea = All; }
                field(Tipo; Rec.Tipo) { Editable = false; ApplicationArea = All; }
                field("Fecha inicial factura"; Rec."Fecha inicial factura") { Editable = false; ApplicationArea = All; }
                field("Fecha final factura"; Rec."Fecha final factura") { Editable = false; ApplicationArea = All; }
                field("Número Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }

            }
        }
    }
    var
        AvtVisible: Boolean;
        AvbVisible: Boolean;
        Avb2Visible: Boolean;
        SalesSetup: Record 311;
        ChangeExchangeRate: page 511;
        CopySalesDoc: Report 292;
        MoveNegSalesLines: Report 6699;
        ReportPrint: Codeunit 228;
        UserMgt: Codeunit 5700;
        SalesInfoPaneMgt: Codeunit 7171;
        rContr: Record 36;
        Avisos: Text;

    trigger OnOpenPage()
    BEGIN
        if UserMgt.GetSalesFilter <> '' THEN BEGIN
            Rec.FILTERGROUP(2);
            Rec.SETRANGE("Responsibility Center", UserMgt.GetSalesFilter);
            Rec.FILTERGROUP(0);
        END;

        AplicarFiltros;                       //$001
    END;


    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$001
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Salesperson Code", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
        END;
    END;



}
