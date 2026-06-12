/// <summary>
/// Page Contratos Activities (ID 50000).
/// </summary>
Page 50000 "Contratos Activities"
{
    PageType = CardPart;
    Caption = 'Contratos';
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;
    layout
    {
        area(Content)
        {

            cuegroup("Para Facturar")
            {
                Caption = 'Para Facturar';
                field("Facturación No Iniciada"; Rec."Sin Facturar")
                {
                    Caption = 'Facturación No Iniciada';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'Specifies the number of sales quotes that are not yet converted to invoices or orders.';
                }
                field("Facturación Iniciada"; ContratosPendientes)
                {
                    Caption = 'Facturación Iniciada';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales orders that are not fully posted.';
                    trigger OnDrillDown()
                    var
                        Contratos: Record "Sales Header";
                        UserSetup: Record "User Setup";
                    begin

                        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
                        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
                        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
                        Contratos.SetRange("Facturacion Iniciada", true);
                        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
                        if UserSetup.Get("UserID") Then begin
                            Contratos.FilterGroup(2);
                            Contratos.SetRange("Salesperson Code", UserSetup."Salespers./Purch. Code");
                            Contratos.FilterGroup(0);
                        end;
                        Contratos.CALCFIELDS("borradores de factura");
                        Page.RunModal(Page::"Lista contratos venta", Contratos);
                    end;
                }
                field(Descuadre; ProcedureDescuadre())
                {
                    Caption = 'Descuadre';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'especifica el descuadre de la facturación';
                    trigger OnDrillDown()

                    var
                        Contratos: Record "Sales Header";
                        Contratost: Record "Sales Header" temporary;
                        Facturas: Record "Sales Invoice Header";
                        Descuadre: Decimal;
                        Dif: Decimal;
                        Conador: Integer;
                    begin
                        Descuadre := 0;
                        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
                        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
                        Contratos.SetRange("Facturacion Iniciada", true);
                        Contratos.Setrange("Fecha Estado", CalcDate('PM+1D-3M', Today), CalcDate('PM', Today));
                        if Contratos.FindSet() then
                            repeat
                                TotalesDocumentos(Contratos, Dif);

                                If Abs(Dif) > 4 Then begin
                                    Contratost := Contratos;
                                    Contratost.Insert();
                                end;
                            until Contratos.Next() = 0;
                        Commit();
                        Page.RunModal(Page::"Lista contratos venta", Contratost);
                    end;

                }


            }
            cuegroup("Contratos en Curso")
            {
                Caption = 'Contratos en Curso';

                field("Contratos Firmados"; Rec."Contratos Firmados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Filrmados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Firmados"));
                    end;

                }
                // lo mismo para los otros estados
                field("Penientes de Firma"; Rec."Contratos Pendientes Firma")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pendientes de Firma';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos pendientes de firma';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Pendientes Firma"));

                    end;
                }
                field("Contratos Sin Montar"; Rec."Contratos Sin Montar")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Sin Montar';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos sin montar';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Sin Montar"));
                    end;
                }
                field("Contratos Cancelados"; Rec."Contratos Cancelados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Cancelados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos cancelados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Cancelados"));
                    end;


                }
                field("Contratos Anulados"; Rec."Contratos Anulados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Anulados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos anulados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Anulados"));
                    end;

                }
                field("Contratos Modificados"; Rec."Contratos Modificados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Modificados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos modificados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Modificados"));
                    end;

                }

            }
            cuegroup("Para Firmar")
            {
                Caption = 'Contratos Porta firmas';
                Visible = ActivadoPortafirmas;
                field("Enviados a gerencia"; Rec.Pending)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enviados a gerencia';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos enviados a gerencia';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo(Pending));
                    end;

                }
                // lo mismo para los otros estados
                field("Firmado Malla"; Rec."Own Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Malla';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por Malla';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Own Signed"));
                    end;
                }

                field("Rechazado Malla"; Rec."Own Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Malla';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por Malla';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Own Rejected"));
                    end;
                }

                field("Firmado Contrato"; Rec."Customer Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Contrato';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Customer Signed"));
                    end;
                }

                field("Rechazado Cliente"; Rec."Customer Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Cliente';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Customer Rejected"));
                    end;
                }
                field("Sepa Pendiente"; Rec."Sepa Pending")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Malla y enviado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos con Sepa Pendiente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Pending"));
                    end;

                }

                field("Firmado Sepa"; Rec."Sepa Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos Sepa firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Signed"));
                    end;
                }

                //Rechazado Sepa
                field("Rechazado Sepa"; Rec."Sepa Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Rejected"));
                    end;
                }
                field("Firmado Contrato y Sepa Pendiente"; Rec."Sepa Pending & Contrat Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Contrato y Sepa Pendiente';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente con Sepa Pendiente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("sepa pending & contrat signed"));
                    end;
                }

                field("Firmado Sepa y Contrato"; Rec."Sepa & Contract Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Sepa y Contrato';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("sepa & contract signed"));
                    end;
                }

                //Sepa Pending & Contract Signed


                //Sepa Pending

            }
            // cuegroup("Pedientes Contabilizar")
            // {
            //     Caption = 'Pedientes Contabilizar';
            //     field("Facturas Pendientes"; Rec."Facturas Pendientes")
            //     {
            //         ApplicationArea = All;
            //         DrillDownPageID = "Sales Invoice List";
            //         ToolTip = 'especifica el numero de facturas pendientes de contabilizar';
            //     }
            //     // lo mismo para los abonos
            //     field("Abonos Pendientes"; Rec."Abonos Pendientes")
            //     {
            //         ApplicationArea = All;
            //         DrillDownPageID = "Sales Credit Memos";
            //         ToolTip = 'especifica el numero de abonos pendientes de contabilizar';
            //     }


        }

    }

    var
        ContratosPendientes: Integer;

        Control: Codeunit ControlProcesos;
        ActivadoPortafirmas: Boolean;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        CompanyInf: Record "Company Information";
        Contratos: Record "Sales Header";
    begin

        Rec.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
        If UserSetup.Get("UserID") Then
            If UserSetup."Salespers./Purch. Code" <> '' Then
                Rec.SetRange("Salesperson filter", UserSetup."Salespers./Purch. Code");
        rec.FilterOrders(Contratos, 0);
        Rec.CalcFields(Pending, "Own Signed", "Own Rejected", "Customer Signed", "Customer Rejected", "Sepa Pending", "Sepa Signed", "Sepa Rejected", "Sepa Pending & Contrat Signed", "Sepa & Contract Signed");

        CompanyInf.Get();
        If CompanyInf."Servidor Alfresco" <> '' then ActivadoPortafirmas := true else ActivadoPortafirmas := false;
        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
        Contratos.CALCFIELDS("borradores de factura");
        if Contratos.FindFirst() Then
            ContratosPendientes := Contratos.Count;
    end;

    trigger OnAfterGetRecord()
    var
        Contratos: Record "Sales Header";
    begin
        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
        rec.FilterOrders(Contratos, 0);
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
        Contratos.CALCFIELDS("borradores de factura");
        if Contratos.FindFirst() Then
            ContratosPendientes := Contratos.Count;

    end;

    local procedure ProcedureDescuadre(): Integer
    var
        Contratos: Record "Sales Header";
        Facturas: Record "Sales Invoice Header";
        Dif: Decimal;
        Contador: Integer;
    begin
        exit(0);
        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.Setrange("Fecha Estado", CalcDate('PM+1D-3M', Today), CalcDate('PM', Today));
        if Contratos.FindSet() then
            repeat
                TotalesDocumentos(Contratos, Dif);
                If aBS(Dif) > 4 Then Contador += 1;
            until Contratos.Next() = 0;
    end;

    PROCEDURE TotalesDocumentos(Contrato: Record "Sales Header"; VAR Diferencia: Decimal);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
        impBorFac: Decimal;
        impBorAbo: Decimal;
        impFac: Decimal;
        impAbo: Decimal;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        rCabFac: Record "Sales Invoice Header";
        rCabAbo: Record "Sales Cr.Memo Header";
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;
        wTexto: Text[250];
    BEGIN
        //$002 Obtengo totales de borradores y facturas correspondientes a este contrato.

        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        TotImp := 0;
        TotCont := 0;

        //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN


        rCabVenta.RESET;
        rCabVenta.SETCURRENTKEY("Nº Proyecto");
        rCabVenta.SETRANGE("Nº Proyecto", Contrato."Nº Proyecto");
        rCabVenta.SETRANGE("Nº Contrato", Contrato."No.");
        rCabVenta.SETFILTER("Document Type", '%1|%2',
           rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
        if rCabVenta.FIND('-') THEN BEGIN
            REPEAT
                CLEAR(TotalSalesLine);
                CLEAR(TotalSalesLineLCY);
                CLEAR(RegisVtas);
                CLEAR(TempSalesLine);
                RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
                CLEAR(RegisVtas);
                RegisVtas.SumSalesLinesTemp(
                  rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                  wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
                if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                    ImpBorFac := ImpBorFac + TotalSalesLineLCY."Amount Including VAT";
                END
                ELSE BEGIN
                    ImpBorAbo := ImpBorAbo + TotalSalesLineLCY."Amount Including VAT";
                END;
            UNTIL rCabVenta.NEXT = 0;
        END;



        if Contrato."Facturas Registradas" <> 0 THEN BEGIN

            rCabFac.RESET;
            rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabFac.SETRANGE("Nº Contrato", Contrato."No.");
            if rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFac.CALCFIELDS("Amount Including VAT");
                    ImpFac := ImpFac + rCabFac."Amount Including VAT";
                UNTIL rCabFac.NEXT = 0;
            END;

        END;

        if Contrato."Abonos Registrados" <> 0 THEN BEGIN

            rCabAbo.RESET;
            rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabAbo.SETRANGE("Nº Contrato", Contrato."No.");
            if rCabAbo.FIND('-') THEN BEGIN
                REPEAT
                    rCabAbo.CALCFIELDS("Amount Including VAT");
                    ImpAbo := ImpAbo + rCabAbo."Amount Including VAT";
                UNTIL rCabAbo.NEXT = 0;
            END;

        END;

        //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
        TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;

        if rCabVenta.GET(rCabVenta."Document Type"::Order, Contrato."No.") THEN BEGIN
            CLEAR(TotalSalesLine);
            CLEAR(TotalSalesLineLCY);
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                        wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TotCont := TotalSalesLineLCY."Amount Including VAT";
        END;
    END;



}
