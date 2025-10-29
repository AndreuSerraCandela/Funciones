/// <summary>
/// Report Generación borrador pagarés (ID 50005).
/// </summary>
report 50004 "Generación borrador pagarés"
{
    UseRequestPage = false;
    ProcessingOnly = true;
    //No se usa
    dataset
    {
        dataitem("Cab. relacion pagos"; "Cab. relacion pagos")
        {

            dataitem("Lin. relacion pagos"; "Lin. relacion pagos")
            {
                DataItemTableView = SORTING("No. relación pagos", "Pago-a Nº proveedor", "Fecha vencimiento") WHERE("Pagaré generado" = CONST(false));
                RequestFilterFields = "No. relación pagos";

                DataItemLink = "No. relación pagos" = FIELD("No. relación pagos");
                trigger OnAfterGetRecord()
                begin

                    recMovProveedor.RESET;
                    recMovProveedor.SETRANGE("Vendor No.", "Pago-a Nº proveedor");
                    recMovProveedor.SETRANGE("Document No.", "Nº");
                    if recMovProveedor.FIND('-') THEN BEGIN
                        if recMovProveedor.Open THEN BEGIN

                            recMovProveedor.CALCFIELDS("Remaining Amt. (LCY)");

                            recTmpLinPagare.INIT;
                            recTmpLinPagare."No. documento" := "Nº";
                            recTmpLinPagare."No. linea" := "No. linea";
                            recTmpLinPagare.Importe := "Importe IVA incl.";
                            decTotalPagare += recTmpLinPagare.Importe;
                            recTmpLinPagare."Fecha documento" := recMovProveedor."Posting Date";
                            recTmpLinPagare."No. documento proveedor" := "Nº documento proveedor";
                            recTmpLinPagare."No. mov. proveedor" := recMovProveedor."Entry No.";
                            recTmpLinPagare."Tipo documento" := "Tipo documento";
                            recTmpLinPagare."Cod. divisa" := recMovProveedor."Currency Code";
                            recTmpLinPagare.INSERT;

                        END;
                    END;
                end;
            }
        }
    }
    requestpage
    {
    }
    VAR
        recPagare: Record "Cab. borrador pagare";
        recTmpLinPagare: Record "Lin. borrador pagare";
        recLinPagare: Record "Lin. borrador pagare";
        recHisFac: Record "Purch. Inv. Header";
        recMovProveedor: Record "Vendor Ledger Entry";
        recProveedor: Record Vendor;
        decTotalPagare: Decimal;
        intPagares: Integer;

    PROCEDURE TraerPagaresGenerados(): Integer;
    BEGIN

        EXIT(intPagares);
    END;

    PROCEDURE MarcarLineasPagos(codPrmPagare: Code[20]);
    VAR
        recLinPago: Record "Lin. relacion pagos";
    BEGIN

        recLinPago.RESET;
        recLinPago.SETRANGE("No. relación pagos", "Lin. relacion pagos"."No. relación pagos");
        recLinPago.SETRANGE("Pago-a Nº proveedor", "Lin. relacion pagos"."Pago-a Nº proveedor");
        recLinPago.SETRANGE("Fecha vencimiento", "Lin. relacion pagos"."Fecha vencimiento");
        if recLinPago.FINDFIRST THEN
            REPEAT
                recLinPago."Pagaré generado" := TRUE;
                recLinPago."No. borrador pagare" := codPrmPagare;
                recLinPago.MODIFY;
            UNTIL recLinPago.NEXT = 0;
    END;

    /*   
      
            $001 01/02/07 JML : Proyecto Florida.
            Revisión del proceso para corregir varios errores. */



}

