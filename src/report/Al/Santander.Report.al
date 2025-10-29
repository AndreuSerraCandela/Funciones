/// <summary>
/// Report Santander (ID 50026).
/// </summary>
report 50022 Santander
{
    // 001 13/08/2015 TSS: Gestionar las Facturas del Efecto contemplando las agrupadas. Añadimos 5 lineas mas con sus correspondientes campos (ej.Factura1..Factura10)
    // 002 21/10/2015 TSS: Si efectos agrupados los importes los cogera de esta tabla (debido a diferencias por abonos con el sistema anterior).
    //                     Ahora con Vista Preliminar no guardaremos la informacion del numero de pagare en cartera doc y mov. proveedor.
    //                     Controlamos el codigo con la variable tolo que ponemos a piñon fijo a true.
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/Santander.rdlc';

    Caption = 'Pagarés Santander';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(CustLedgEntry; 25)
        {
            DataItemTableView = SORTING("Entry No.");
            UseTemporary = true;
            column(DocumentNo_CustLedgEntry; "External Document No.")
            {
            }
            column(BillNo_CustLedgEntry; "Bill No.")
            {
            }
            column(DrawCity; DrawCity)
            {
            }
            column(PrintAmt; PrintAmount2)
            {
                AutoFormatExpression = GetCurrencyCode;
                AutoFormatType = 1;
            }
            column(CurrencyCode; CurrencyCode)
            {
            }
            column(DrawDate; FORMAT(DrawDate))
            {
            }
            column(DueDate_CustLedgEntry; FORMAT("Due Date"))
            {
            }
            column(Dia; FORMAT("Due Date", 0, '<Day,2>'))
            {
            }
            column(Mes; FORMAT("Due Date", 0, '<Month Text>'))
            {
            }
            column(Anyo; FORMAT("Due Date", 0, '<Year4>'))
            {
            }
            column(Dia2; DiaPago)
            {
            }
            column(Mes2; FORMAT(DrawDate, 0, '<Month Text>'))
            {
            }
            column(Anyo2; FORMAT(DrawDate, 0, '<Year4>'))
            {
            }
            column(NumberText1; NumberText[1])
            {
                AutoFormatExpression = GetCurrencyCode;
                AutoFormatType = 1;
            }
            column(PostingDate_CustLedgEntry; FORMAT("Posting Date"))
            {
            }
            column(PaymentMethod; PaymentMethod)
            {
            }
            column(CustBankAccName; CustBankAcc.Name)
            {
            }
            column(CustBankAccBankAccNoDetails; CustBankAcc."Bank Account No." + CustBankAcc."CCC Bank Account No.")
            {
            }
            column(CustVATRegNo; Customer."VAT Registration No.")
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(CustAddr7; CustAddr[7])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CompVATRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column(CompAddr6; CompAddr[6])
            {
            }
            column(CompAddr7; CompAddr[7])
            {
            }
            column(CompAddr5; CompAddr[5])
            {
            }
            column(CompAddr4; CompAddr[4])
            {
            }
            column(CompAddr2; CompAddr[2])
            {
            }
            column(CompAddr3; CompAddr[3])
            {
            }
            column(CompAddr1; CompAddr[1])
            {
            }
            column(CurrencyTxt; CurrencyTxt)
            {
            }
            column(NumberText2; NumberText[2])
            {
                AutoFormatExpression = GetCurrencyCode;
                AutoFormatType = 1;
            }
            column(EntryNo_CustLedgEntry; "Entry No.")
            {
            }
            column(EmptyStringCaption; EmptyStringCaptionLbl)
            {
            }
            column(StatedAddressCaption; YouarekindlyadvisedtopayinthestatedaddressCaptionLbl)
            {
            }
            column(WithTheFollowingDetailsCaption; WithTheFollowingDetailsCaptionLbl)
            {
            }
            column(RelatedtoCaption; RelatedtoCaptionLbl)
            {
            }
            column(InvoiceNoCaption; InvoiceNoCaptionLbl)
            {
            }
            column(IssuedDateCaption; IssuedDateCaptionLbl)
            {
            }
            column(IssuedDueDateCaption; IssuedDueDateCaptionLbl)
            {
            }
            column(NumPag; NumPag)
            {
            }
            column(Facturas1; Facturas1)
            {
            }
            column(Facturas2; Facturas2)
            {
            }
            column(Facturas3; Facturas3)
            {
            }
            column(Facturas4; Facturas4)
            {
            }
            column(Facturas5; Facturas5)
            {
            }
            column(Facturas6; Facturas6)
            {
            }
            column(Facturas7; Facturas7)
            {
            }
            column(Facturas8; Facturas8)
            {
            }
            column(Facturas9; Facturas9)
            {
            }
            column(Facturas10; Facturas10)
            {
            }
            column(Fechas1; Fechas1)
            {
            }
            column(Fechas2; Fechas2)
            {
            }
            column(Fechas3; Fechas3)
            {
            }
            column(Fechas4; Fechas4)
            {
            }
            column(Fechas5; Fechas5)
            {
            }
            column(Fechas6; Fechas6)
            {
            }
            column(Fechas7; Fechas7)
            {
            }
            column(Fechas8; Fechas8)
            {
            }
            column(Fechas9; Fechas9)
            {
            }
            column(Fechas10; Fechas10)
            {
            }
            column(Vto1; Vto1)
            {
            }
            column(Vto2; Vto2)
            {
            }
            column(Vto3; Vto3)
            {
            }
            column(Vto4; Vto4)
            {
            }
            column(Vto5; Vto5)
            {
            }
            column(Vto6; Vto6)
            {
            }
            column(Vto7; Vto7)
            {
            }
            column(Vto8; Vto8)
            {
            }
            column(Vto9; Vto9)
            {
            }
            column(Vto10; Vto10)
            {
            }
            column(Importe1; Importe1)
            {
            }
            column(Importe2; Importe2)
            {
            }
            column(Importe3; Importe3)
            {
            }
            column(Importe4; Importe4)
            {
            }
            column(Importe5; Importe5)
            {
            }
            column(Importe6; Importe6)
            {
            }
            column(Importe7; Importe7)
            {
            }
            column(Importe8; Importe8)
            {
            }
            column(Importe9; Importe9)
            {
            }
            column(Importe10; Importe10)
            {
            }

            trigger OnAfterGetRecord()
            var
                rvendLedgEntry: Record 25;
                rvendLedgEntry1: Record 25;
                rdocCartera: Record 50000;
                sumaImporte: Decimal;
                Dia2U: Text;
                Dia2C: Text;
                Dia1U: Integer;
                Dia1C: Integer;
            begin
                CustBankAcc.INIT;
                //CustPmtAddress.INIT;
                CompanyInfo.GET;
                FormatAddress.Company(CompAddr, CompanyInfo);
                GLSetup.GET;
                NumPag := INCSTR(NumPag);
                rVendenTry.DELETEALL;
                CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                if PrintAmountsInLCY THEN BEGIN
                    FormatNoText(NumberText, -"Remaining Amt. (LCY)");
                    PrintAmt := -"Remaining Amt. (LCY)";
                    CurrencyCode := GLSetup."LCY Code";
                END ELSE BEGIN
                    FormatNoText(NumberText, -"Remaining Amount");
                    PrintAmt := -"Remaining Amount";
                    if "Currency Code" = '' THEN
                        CurrencyCode := GLSetup."LCY Code"
                    ELSE
                        CurrencyCode := "Currency Code";
                END;
                PrintAmount2 := '***' + FORMAT(PrintAmt, 0, '<Precision,2:3><Standard Format,0>') + '***';
                Dia2 := DATE2DMY(DrawDate, 1);
                Dia2C := '';
                Dia1C := 0;
                if Dia2 > 9 THEN BEGIN
                    Dia2U := COPYSTR(FORMAT(Dia2), 2, 1);
                    Dia2C := COPYSTR(FORMAT(Dia2), 1, 1);
                END ELSE BEGIN
                    Dia2U := FORMAT(Dia2);
                END;
                if Dia2C <> '' THEN EVALUATE(Dia1C, Dia2C);
                EVALUATE(Dia1U, Dia2U);
                if Dia1C > 0 THEN
                    DiaPago := 'Palma de Mallorca a ' + TextTensUnits(Dia1C, Dia1U, FALSE)
                ELSE
                    DiaPago := 'Palma de Mallorca a ' + TextUnits(Dia1U, FALSE);
                CurrencyTxt := STRSUBSTNO(Text1100000, CurrencyCode);

                //CASE "Document Situation" OF
                //"Document Situation"::"BG/PO","Document Situation"::Cartera:
                // WITH Doc. DO BEGIN
                Doc.GET(CustLedgEntry."Entry No.");
                CollectionAgent := CollectionAgent::Bank;
                AccountNo := Doc."Account No.";// .Departamento;
                Customer.GET(AccountNo);
                if CustBankAcc.GET(AccountNo, Customer."Preferred Bank Account Code") THEN;
                //if CustPmtAddress.GET(AccountNo, '') THEN;
                if PrintAmountsInLCY THEN
                    PrintAmt := -CustLedgEntry."Remaining Amt. (LCY)"
                ELSE
                    PrintAmt := -CustLedgEntry."Remaining Amount";
                /*if "Bill Gr./Pmt. Order No." <> '' THEN BEGIN
                  BillGr.GET("Bill Gr./Pmt. Order No.");
                  GroupPostingDate := BillGr."Posting Date";
                END;*/
                PaymentMethod := "Payment Method Code";
                // END;
                /*"Document Situation"::"Posted BG/PO":
                  WITH PostedDoc DO BEGIN
                    GET(Type::Payable,CustLedgEntry."Entry No.");
                    CollectionAgent := "Collection Agent";
                    AccountNo := "Account No.";
                    if CustBankAcc.GET(AccountNo,"Cust./Vendor Bank Acc. Code") THEN;
                    if CustPmtAddress.GET(AccountNo,"Pmt. Address Code") THEN;
                    PostedBillGr.GET("Bill Gr./Pmt. Order No.");
                    if PrintAmountsInLCY THEN
                      PrintAmt := -"Amt. for Collection (LCY)"
                    ELSE
                      PrintAmt := -"Amount for Collection";
                    GroupPostingDate := PostedBillGr."Posting Date";
                    PaymentMethod := "Payment Method Code";
                  END;
              END;*/

                if DrawDate = 0D THEN
                    if GroupPostingDate <> 0D THEN
                        DrawDate := GroupPostingDate
                    ELSE
                        DrawDate := WORKDATE;

                if Not Customer.Get(AccountNo) THEN Customer.Init();
                if Customer."Pay-to Vendor No." <> '' Then begin
                    Customer.Get(Customer."Pay-to Vendor No.");
                    VendPmtAddress(CustAddr, Customer);
                end
                ELSE BEGIN
                    //Customer.GET(AccountNo);
                    FormatAddress.Vendor(CustAddr, Customer);
                END;
                if NumberText[1] = Text1100002 THEN
                    NumberText[1] := NumberText[1] + Text1100059;

                CreateVendLedgEntry := CustLedgEntry;

                // FindApplnEntriesDtldtLedgEntry;

                /* if CreateVendLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                   rVendenTry2.GET(CreateVendLedgEntry."Closed by Entry No.");
                   rVendenTry:=rVendenTry2;
                   if rVendenTry.INSERT THEN;
                 END;*/
                rVendenTry.DELETEALL;
                // rVendenTry2.SETCURRENTKEY("Closed by Entry No.");
                rVendenTry2.SETRANGE("Entry No.", "Entry No.");
                if rVendenTry2.FIND('-') THEN
                    REPEAT
                        rVendenTry := rVendenTry2;
                        if rVendenTry.INSERT THEN;

                    UNTIL rVendenTry2.NEXT = 0;
                CreateVendLedgEntry."External Document No." := NumPag;

                if rvendledgerentry.GET(CustLedgEntry."Entry No.") THEN BEGIN
                    // rvendledgerentry."Numero Pagaré" := NumPag;
                    if NOT CurrReport.PREVIEW THEN  //+002
                        rvendledgerentry.MODIFY;
                    // Doc."Numero Pagaré":=NumPag;
                    if NOT CurrReport.PREVIEW THEN  //+002
                        Doc.MODIFY;
                END;

                CLEAR(Facturas1);
                CLEAR(Facturas2);
                CLEAR(Facturas3);
                CLEAR(Facturas4);
                CLEAR(Facturas5);
                CLEAR(Facturas6);
                CLEAR(Facturas7);
                CLEAR(Facturas8);
                CLEAR(Facturas9);
                CLEAR(Facturas10);

                CLEAR(Fechas1);
                CLEAR(Fechas2);
                CLEAR(Fechas3);
                CLEAR(Fechas4);
                CLEAR(Fechas5);
                CLEAR(Fechas6);
                CLEAR(Fechas7);
                CLEAR(Fechas8);
                CLEAR(Fechas9);
                CLEAR(Fechas10);

                CLEAR(Vto1);
                CLEAR(Vto2);
                CLEAR(Vto3);
                CLEAR(Vto4);
                CLEAR(Vto5);
                CLEAR(Vto6);
                CLEAR(Vto7);
                CLEAR(Vto8);
                CLEAR(Vto9);
                CLEAR(Vto10);

                CLEAR(Importe1);
                CLEAR(Importe2);
                CLEAR(Importe3);
                CLEAR(Importe4);
                CLEAR(Importe5);
                CLEAR(Importe6);
                CLEAR(Importe7);
                CLEAR(Importe8);
                CLEAR(Importe9);
                CLEAR(Importe10);

                //a:=0;    //+001
                //a:=a+1;  //+001
                a := 1; //+001

                if NOT rdocCartera.GET(CustLedgEntry."Entry No.") THEN
                    rdocCartera.INIT;

                // rdocsAgrupados.RESET;
                // rdocsAgrupados.SETRANGE(Type,rdocsAgrupados.Type::Payable);
                // rdocsAgrupados.SETRANGE("Cod. Agrupacion", rdocCartera."No.");
                // rdocsAgrupados.SETRANGE(Tipo,rdocsAgrupados.Tipo::Detalle);
                // //+001
                // if rdocsAgrupados.FINDFIRST THEN BEGIN
                //  REPEAT
                //    {
                //    if NOT tolo THEN BEGIN
                //      if rvendLedgEntry.GET(rdocsAgrupados."Entry No.") THEN BEGIN
                //
                //      if a=1 THEN Facturas1:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=2 THEN Facturas2:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=3 THEN Facturas3:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=4 THEN Facturas4:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=5 THEN Facturas5:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=6 THEN Facturas6:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=7 THEN Facturas7:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=8 THEN Facturas8:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=9 THEN Facturas9:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=10 THEN Facturas10:='Factura '+rvendLedgEntry."External Document No.";
                //
                //      if a=1 THEN Fechas1:=rvendLedgEntry."Document Date";
                //      if a=2 THEN Fechas2:=rvendLedgEntry."Document Date";
                //      if a=3 THEN Fechas3:=rvendLedgEntry."Document Date";
                //      if a=4 THEN Fechas4:=rvendLedgEntry."Document Date";
                //      if a=5 THEN Fechas5:=rvendLedgEntry."Document Date";
                //      if a=6 THEN Fechas6:=rvendLedgEntry."Document Date";
                //      if a=7 THEN Fechas7:=rvendLedgEntry."Document Date";
                //      if a=8 THEN Fechas8:=rvendLedgEntry."Document Date";
                //      if a=9 THEN Fechas9:=rvendLedgEntry."Document Date";
                //      if a=10 THEN Fechas10:=rvendLedgEntry."Document Date";
                //
                //
                //      if a=1 THEN Vto1:="Due Date";
                //      if a=2 THEN Vto2:="Due Date";
                //      if a=3 THEN Vto3:="Due Date";
                //      if a=4 THEN Vto4:="Due Date";
                //      if a=5 THEN Vto5:="Due Date";
                //      if a=6 THEN Vto6:="Due Date";
                //      if a=7 THEN Vto7:="Due Date";
                //      if a=8 THEN Vto8:="Due Date";
                //      if a=9 THEN Vto9:="Due Date";
                //      if a=10 THEN Vto10:="Due Date";
                //
                //      rvendLedgEntry.CALCFIELDS(Amount);
                //      if a=1 THEN Importe1:=-rvendLedgEntry.Amount;
                //      if a=2 THEN Importe2:=-rvendLedgEntry.Amount;
                //      if a=3 THEN Importe3:=-rvendLedgEntry.Amount;
                //      if a=4 THEN Importe4:=-rvendLedgEntry.Amount;
                //      if a=5 THEN Importe5:=-rvendLedgEntry.Amount;
                //      if a=6 THEN Importe6:=-rvendLedgEntry.Amount;
                //      if a=7 THEN Importe7:=-rvendLedgEntry.Amount;
                //      if a=8 THEN Importe8:=-rvendLedgEntry.Amount;
                //      if a=9 THEN Importe9:=-rvendLedgEntry.Amount;
                //      if a=10 THEN Importe10:=-rvendLedgEntry.Amount;
                //
                //      a:=a+1;
                //    END;
                //    END ELSE BEGIN
                //    }
                //    if rvendLedgEntry.GET(rdocsAgrupados."Entry No.") THEN;
                //        {
                //      if a=1 THEN Facturas1:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=2 THEN Facturas2:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=3 THEN Facturas3:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=4 THEN Facturas4:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=5 THEN Facturas5:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=6 THEN Facturas6:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=7 THEN Facturas7:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=8 THEN Facturas8:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=9 THEN Facturas9:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      if a=10 THEN Facturas10:='Factura '+ rdocsAgrupados."Doc.Externo";
                //      }
                //      if a=1 THEN Facturas1:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=2 THEN Facturas2:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=3 THEN Facturas3:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=4 THEN Facturas4:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=5 THEN Facturas5:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=6 THEN Facturas6:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=7 THEN Facturas7:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=8 THEN Facturas8:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=9 THEN Facturas9:='Factura '+rvendLedgEntry."External Document No.";
                //      if a=10 THEN Facturas10:='Factura '+rvendLedgEntry."External Document No.";
                //
                //
                //      if a=1 THEN Fechas1:=rvendLedgEntry."Document Date";
                //      if a=2 THEN Fechas2:=rvendLedgEntry."Document Date";
                //      if a=3 THEN Fechas3:=rvendLedgEntry."Document Date";
                //      if a=4 THEN Fechas4:=rvendLedgEntry."Document Date";
                //      if a=5 THEN Fechas5:=rvendLedgEntry."Document Date";
                //      if a=6 THEN Fechas6:=rvendLedgEntry."Document Date";
                //      if a=7 THEN Fechas7:=rvendLedgEntry."Document Date";
                //      if a=8 THEN Fechas8:=rvendLedgEntry."Document Date";
                //      if a=9 THEN Fechas9:=rvendLedgEntry."Document Date";
                //      if a=10 THEN Fechas10:=rvendLedgEntry."Document Date";
                //
                //
                //      if a=1 THEN Vto1:="Due Date";
                //      if a=2 THEN Vto2:="Due Date";
                //      if a=3 THEN Vto3:="Due Date";
                //      if a=4 THEN Vto4:="Due Date";
                //      if a=5 THEN Vto5:="Due Date";
                //      if a=6 THEN Vto6:="Due Date";
                //      if a=7 THEN Vto7:="Due Date";
                //      if a=8 THEN Vto8:="Due Date";
                //      if a=9 THEN Vto9:="Due Date";
                //      if a=10 THEN Vto10:="Due Date";
                //
                //      if a=1 THEN Importe1:=rdocsAgrupados."Remaining Amount";
                //      if a=2 THEN Importe2:=rdocsAgrupados."Remaining Amount";
                //      if a=3 THEN Importe3:=rdocsAgrupados."Remaining Amount";
                //      if a=4 THEN Importe4:=rdocsAgrupados."Remaining Amount";
                //      if a=5 THEN Importe5:=rdocsAgrupados."Remaining Amount";
                //      if a=6 THEN Importe6:=rdocsAgrupados."Remaining Amount";
                //      if a=7 THEN Importe7:=rdocsAgrupados."Remaining Amount";
                //      if a=8 THEN Importe8:=rdocsAgrupados."Remaining Amount";
                //      if a=9 THEN Importe9:=rdocsAgrupados."Remaining Amount";
                //      if a=10 THEN Importe10:=rdocsAgrupados."Remaining Amount";
                //
                //      a:=a+1;
                //
                //   // END;
                //  UNTIL rdocsAgrupados.NEXT = 0;
                //
                //  //"Remaining Amt. (LCY)" := Importe1 + Importe2 + Importe3 + Importe4 + Importe5 + Importe6 + Importe7 + Importe8 + Importe9 + Importe10;
                //  PrintAmt:= Importe1 + Importe2 + Importe3 + Importe4 + Importe5 + Importe6 + Importe7 + Importe8 + Importe9 + Importe10;//"Remaining Amt. (LCY)";
                //
                //  if PrintAmountsInLCY THEN BEGIN
                //    FormatNoText(NumberText,PrintAmt); //"Remaining Amt. (LCY)");
                //    CurrencyCode := GLSetup."LCY Code";
                //  END ELSE BEGIN
                //    FormatNoText(NumberText, PrintAmt);
                //    if "Currency Code" = '' THEN
                //      CurrencyCode := GLSetup."LCY Code"
                //    ELSE
                //      CurrencyCode := "Currency Code";
                //  END;
                //
                //  CurrencyTxt := STRSUBSTNO(Text1100000,CurrencyCode);
                //
                // END
                // ELSE BEGIN
                //-001
                if rVendenTry.FINDFIRST THEN
                    REPEAT
                        if a = 1 THEN Facturas1 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 2 THEN Facturas2 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 3 THEN Facturas3 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 4 THEN Facturas4 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 5 THEN Facturas5 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 6 THEN Facturas6 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 7 THEN Facturas7 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 8 THEN Facturas8 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 9 THEN Facturas9 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";
                        if a = 10 THEN Facturas10 := FORMAT(rVendenTry."Document Type") + ' ' + rVendenTry."External Document No.";

                        if a = 1 THEN Fechas1 := rVendenTry."Document Date";
                        if a = 2 THEN Fechas2 := rVendenTry."Document Date";
                        if a = 3 THEN Fechas3 := rVendenTry."Document Date";
                        if a = 4 THEN Fechas4 := rVendenTry."Document Date";
                        if a = 5 THEN Fechas5 := rVendenTry."Document Date";
                        if a = 6 THEN Fechas6 := rVendenTry."Document Date";
                        if a = 7 THEN Fechas7 := rVendenTry."Document Date";
                        if a = 8 THEN Fechas8 := rVendenTry."Document Date";
                        if a = 9 THEN Fechas9 := rVendenTry."Document Date";
                        if a = 10 THEN Fechas10 := rVendenTry."Document Date";

                        if a = 1 THEN Vto1 := "Due Date";
                        if a = 2 THEN Vto2 := "Due Date";
                        if a = 3 THEN Vto3 := "Due Date";
                        if a = 4 THEN Vto4 := "Due Date";
                        if a = 5 THEN Vto5 := "Due Date";
                        if a = 6 THEN Vto6 := "Due Date";
                        if a = 7 THEN Vto7 := "Due Date";
                        if a = 8 THEN Vto8 := "Due Date";
                        if a = 9 THEN Vto9 := "Due Date";
                        if a = 10 THEN Vto10 := "Due Date";

                        rVendenTry.CALCFIELDS(Amount);
                        if a = 1 THEN Importe1 := -rVendenTry.Amount;
                        if a = 2 THEN Importe2 := -rVendenTry.Amount;
                        if a = 3 THEN Importe3 := -rVendenTry.Amount;
                        if a = 4 THEN Importe4 := -rVendenTry.Amount;
                        if a = 5 THEN Importe5 := -rVendenTry.Amount;
                        if a = 6 THEN Importe6 := -rVendenTry.Amount;
                        if a = 7 THEN Importe7 := -rVendenTry.Amount;
                        if a = 8 THEN Importe8 := -rVendenTry.Amount;
                        if a = 9 THEN Importe9 := -rVendenTry.Amount;
                        if a = 10 THEN Importe10 := -rVendenTry.Amount;

                        a := a + 1;
                    UNTIL rVendenTry.NEXT = 0;
                // END;

            end;

            trigger OnPostDataItem()
            begin
                if r270.GET(Banco) THEN BEGIN
                    r270."Last Check No." := NumPag;
                    if NOT CurrReport.PREVIEW THEN //+002
                        r270.MODIFY;
                END;
            end;

            trigger OnPreDataItem()
            begin
                tolo := TRUE;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(Banco; Banco)
                    {
                        ApplicationArea = All;
                        Caption = 'Banco';
                        TableRelation = "Bank Account";

                        trigger OnValidate()
                        begin
                            if Banco <> '' THEN BEGIN
                                r270.GET(Banco);
                                NumPag := r270."Last Check No.";
                            END;
                        end;
                    }
                    field(DrawDate; DrawDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha';
                    }
                    field(DrawCity; DrawCity)
                    {
                        ApplicationArea = All;
                        Caption = 'Población';
                    }
                    field(PrintAmountsInLCY; PrintAmountsInLCY)
                    {
                        ApplicationArea = All;
                        Caption = 'Mostrar importes en euros';
                    }
                    field(NumPag; NumPag)
                    {
                        ApplicationArea = All;
                        Caption = 'Número Pagaré';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CompanyInfo.GET;
            DrawCity := CompanyInfo.City;

            DrawDate := WORKDATE;
            if Banco <> '' THEN BEGIN
                r270.GET(Banco);
                NumPag := r270."Last Check No.";
            END;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        InsertaMovs;
    end;

    var
        Text1100000: Label 'Total importe de %1';
        Text1100001: Label '%1 es demasiado grande para formatearlo';
        Text1100002: Label 'CERO ';
        Text1100003: Label '<decimals>';
        Text1100004: Label 'CON ';
        Text1100005: Label 'MILLONES ';
        Text1100006: Label 'UN MILLÓN ';
        Text1100007: Label 'MIL ';
        Text1100008: Label 'CIEN ';
        Text1100009: Label 'CIENTO ';
        Text1100010: Label 'DOSCIENTOS ';
        Text1100011: Label 'TRESCIENTOS ';
        Text1100012: Label 'CUATROCIENTOS ';
        Text1100013: Label 'QUINIENTOS ';
        Text1100014: Label 'SEISCIENTOS ';
        Text1100015: Label 'SETECIENTOS ';
        Text1100016: Label 'OCHOCIENTOS ';
        Text1100017: Label 'NOVECIENTOS ';
        Text1100018: Label 'DOSCIENTOS ';
        Text1100019: Label 'TRESCIENTOS ';
        Text1100020: Label 'CUATROCIENTOS ';
        Text1100021: Label 'QUINIENTOS ';
        Text1100022: Label 'SEISCIENTOS ';
        Text1100023: Label 'SETECIENTOS ';
        Text1100024: Label 'OCHOCIENTOS ';
        Text1100025: Label 'NOVECIENTOS ';
        Text1100026: Label 'DIEZ ';
        Text1100027: Label 'ONCE ';
        Text1100028: Label 'DOCE ';
        Text1100029: Label 'TRECE ';
        Text1100030: Label 'CATORCE ';
        Text1100031: Label 'QUINCE ';
        Text1100032: Label 'DIECI';
        Text1100033: Label 'VEINTE ';
        Text1100034: Label 'VEINTI';
        Text1100035: Label 'TREINTA ';
        Text1100036: Label 'TREINTA Y ';
        Text1100037: Label 'CUARENTA ';
        Text1100038: Label 'CUARENTA Y ';
        Text1100039: Label 'CINCUENTA ';
        Text1100040: Label 'CINCUENTA Y ';
        Text1100041: Label 'SESENTA ';
        Text1100042: Label 'SESENTA Y ';
        Text1100043: Label 'SETENTA ';
        Text1100044: Label 'SETENTA Y ';
        Text1100045: Label 'OCHENTA ';
        Text1100046: Label 'OCHENTA Y ';
        Text1100047: Label 'NOVENTA ';
        Text1100048: Label 'NOVENTA Y ';
        Text1100049: Label 'UN ';
        Text1100050: Label 'UNO ';
        Text1100051: Label 'DOS ';
        Text1100052: Label 'TRES ';
        Text1100053: Label 'CUATRO ';
        Text1100054: Label 'CINCO ';
        Text1100055: Label 'SEIS ';
        Text1100056: Label 'SIETE ';
        Text1100057: Label 'OCHO ';
        Text1100058: Label 'NUEVE ';
        Text1100059: Label ' CËNTIMOS';
        Text1100060: Label ' CËNTIMOS';
        Text1100061: Label 'MILESIMAS';
        Text1100062: Label 'DIEZMILESIMAS';
        Text1100063: Label ' CËNTIMO';
        Text1100064: Label ' CËNTIMO';
        Text1100065: Label 'MILESIMA';
        Text1100066: Label 'DIEZMILESIMA';
        Text1100067: Label '%1 \el resultado es un número demasiado alto';
        Doc: Record "Cartera Doc.";
        PostedDoc: Record 7000003;
        BillGr: Record 7000020;
        PostedBillGr: Record 7000021;
        CompanyInfo: Record 79;
        Customer: Record Vendor;
        CustBankAcc: Record 288;
        //CustPmtAddress: Record 7000015;
        GLSetup: Record "General Ledger Setup";
        FormatAddress: Codeunit "Format Address";
        PaymentMethod: Code[10];
        CustAddr: array[8] of Text[100];
        CollectionAgent: Option Direct,Bank;
        AccountNo: Code[20];
        GroupPostingDate: Date;
        CurrencyTxt: Text[250];
        DrawCity: Text[30];
        DrawDate: Date;
        PrintAmountsInLCY: Boolean;
        PrintAmt: Decimal;
        CurrencyCode: Code[10];
        NumberText: array[2] of Text[80];
        Remainder: Integer;
        HundMilion: Integer;
        TenMilion: Integer;
        UnitsMilion: Integer;
        HundThousands: Integer;
        TenThousands: Integer;
        UnitsThousands: Integer;
        Units: Integer;
        DecimalPlaces: Integer;
        DecimalText: array[2] of Text[80];
        DecimalString: Text[15];
        Decimals: Integer;
        EmptyStringCaptionLbl: Label '/', Locked = true;
        RelatedtoCaptionLbl: Label 'referido a';
        InvoiceNoCaptionLbl: Label 'Nº Factura';
        IssuedDateCaptionLbl: Label 'fecha emisión';
        IssuedDueDateCaptionLbl: Label 'fecha emisión';
        YouarekindlyadvisedtopayinthestatedaddressCaptionLbl: Label 'Le recomendamos que pague en la dirección indicada.';
        WithTheFollowingDetailsCaptionLbl: Label 'con el siguiente detalle';
        CompAddr: array[8] of Text[100];
        Fecha: Date;
        Vto: Date;
        Importe: Decimal;
        Saltar: Boolean;
        CreateVendLedgEntry: Record 25;
        rVendenTry: Record 25 temporary;
        rVendenTry2: Record 25;
        NumPag: Code[10];
        r270: Record 270;
        Facturas1: Text[250];
        Facturas2: Text[250];
        Facturas3: Text[250];
        Facturas4: Text[250];
        Facturas5: Text[250];
        Facturas6: Text[250];
        Facturas7: Text[250];
        Facturas8: Text[250];
        Facturas9: Text[250];
        Facturas10: Text[250];
        Fechas1: Date;
        Vto1: Date;
        Importe1: Decimal;
        Fechas2: Date;
        Vto2: Date;
        Importe2: Decimal;
        Fechas3: Date;
        Vto3: Date;
        Importe3: Decimal;
        Fechas4: Date;
        Vto4: Date;
        Importe4: Decimal;
        Fechas5: Date;
        Vto5: Date;
        Importe5: Decimal;
        Fechas6: Date;
        Vto6: Date;
        Importe6: Decimal;
        Fechas7: Date;
        Vto7: Date;
        Importe7: Decimal;
        Fechas8: Date;
        Vto8: Date;
        Importe8: Decimal;
        Fechas9: Date;
        Vto9: Date;
        Importe9: Decimal;
        Fechas10: Date;
        Vto10: Date;
        Importe10: Decimal;
        a: Integer;
        rvendledgerentry: Record 25;
        tolo: Boolean;
        "Numero Pagaré": Text;
        Banco: Code[20];
        Dia2: Integer;
        DiaPago: Text;
        PrintAmount2: Text;


    /// <summary>
    /// GetCurrencyCode.
    /// </summary>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetCurrencyCode(): Code[10]
    begin
        if PrintAmountsInLCY THEN
            EXIT('');
        EXIT(CustLedgEntry."Currency Code");
    end;


    /// <summary>
    /// FormatNoText.
    /// </summary>
    /// <param name="NoText">VAR array[2] of Text[80].</param>
    /// <param name="No">Decimal.</param>
    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal)
    var
        Tens: Integer;
        Hundreds: Integer;
        NoTextIndex: Integer;
    begin
        CLEAR(NoText);
        NoTextIndex := 1;

        if No > 999999999 THEN
            ERROR(Text1100001, No);

        if ROUND(No, 1, '<') = 0 THEN
            AddToNoText(NoText, NoTextIndex, Text1100002);

        HundMilion := ROUND(No, 1, '<') DIV 100000000;
        Remainder := ROUND(No, 1, '<') MOD 100000000;
        TenMilion := Remainder DIV 10000000;
        Remainder := Remainder MOD 10000000;
        UnitsMilion := Remainder DIV 1000000;
        Remainder := Remainder MOD 1000000;
        HundThousands := Remainder DIV 100000;
        Remainder := Remainder MOD 100000;
        TenThousands := Remainder DIV 10000;
        Remainder := Remainder MOD 10000;
        UnitsThousands := Remainder DIV 1000;
        Remainder := Remainder MOD 1000;
        Hundreds := Remainder DIV 100;
        Remainder := Remainder MOD 100;
        Tens := Remainder DIV 10;
        Units := Remainder MOD 10;
        DecimalPlaces := STRLEN(FORMAT(No, 0, Text1100003));
        if DecimalPlaces > 0 THEN BEGIN
            DecimalPlaces := DecimalPlaces - 1;
            Decimals := (No - ROUND(No, 1, '<')) * POWER(10, DecimalPlaces);
            if DecimalPlaces = 1 THEN
                Decimals := Decimals * 10;
            DecimalString := TextNoDecimals(DecimalPlaces);
        END;
        AddToNoText(NoText, NoTextIndex, TextHundMilion(HundMilion, TenMilion, UnitsMilion, TRUE));
        AddToNoText(NoText, NoTextIndex, TextTenUnitsMilion(HundMilion, TenMilion, UnitsMilion, TRUE));
        AddToNoText(NoText, NoTextIndex, TextHundThousands(HundThousands, TenThousands, UnitsThousands, FALSE));
        AddToNoText(NoText, NoTextIndex, TextTenUnitsThousands(HundThousands, TenThousands, UnitsThousands, FALSE));
        AddToNoText(NoText, NoTextIndex, TextHundreds(Hundreds, Tens, Units, FALSE));
        AddToNoText(NoText, NoTextIndex, TextTensUnits(Tens, Units, FALSE));
        if DecimalPlaces > 0 THEN BEGIN
            FormatNoText(DecimalText, Decimals);
            AddToNoText(
              // NoText,NoTextIndex,Text1100004 + DecimalText[1] + TextNoDecimals(DecimalPlaces));
              NoText, NoTextIndex, Text1100004 + DecimalText[1] + DecimalString);
        END;
    end;


    /// <summary>
    /// TextHundMilion.
    /// </summary>
    /// <param name="Hundreds">Integer.</param>
    /// <param name="Ten">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextHundMilion(Hundreds: Integer; Ten: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        if Hundreds <> 0 THEN
            EXIT(TextHundreds(Hundreds, Ten, Units, TRUE));
    end;


    /// <summary>
    /// TextTenUnitsMilion.
    /// </summary>
    /// <param name="Hundreds">Integer.</param>
    /// <param name="Ten">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextTenUnitsMilion(Hundreds: Integer; Ten: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        if (Hundreds <> 0) AND (Ten = 0) AND (Units = 0) THEN
            EXIT(Text1100005);
        if (Hundreds = 0) AND (Ten = 0) AND (Units = 1) THEN
            EXIT(Text1100006);
        if (Ten <> 0) OR (Units <> 0) THEN
            EXIT(TextTensUnits(Ten, Units, Masc) + Text1100005);
    end;


    /// <summary>
    /// TextHundThousands.
    /// </summary>
    /// <param name="Hundreds">Integer.</param>
    /// <param name="Ten">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextHundThousands(Hundreds: Integer; Ten: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        if Hundreds <> 0 THEN
            EXIT(TextHundreds(Hundreds, Ten, Units, Masc))
    end;


    /// <summary>
    /// TextTenUnitsThousands.
    /// </summary>
    /// <param name="Hundreds">Integer.</param>
    /// <param name="Ten">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextTenUnitsThousands(Hundreds: Integer; Ten: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        if (Hundreds <> 0) AND (Ten = 0) AND (Units = 0) THEN
            EXIT(Text1100007);
        if (Hundreds = 0) AND (Ten = 0) AND (Units = 1) THEN
            EXIT(Text1100007);
        if (Ten <> 0) OR (Units <> 0) THEN
            EXIT(TextTensUnits(Ten, Units, Masc) + Text1100007);
    end;

    /// <summary>
    /// VendPmtAddress.
    /// </summary>
    /// <param name="AddrArray">VAR array[8] of Text[100].</param>
    /// <param name="VendPmtAddress">VAR Record "Vendor Pmt. Address".</param>
    procedure VendPmtAddress(var AddrArray: array[8] of Text[100]; var VendPmtAddress: Record "Vendor")
    begin
        // with VendPmtAddress. do
        FormatAddress.FormatAddr(
          AddrArray, VendPmtAddress.Name, VendPmtAddress."Name 2", '', VendPmtAddress.Address, VendPmtAddress."Address 2",
          VendPmtAddress.City, VendPmtAddress."Post Code", VendPmtAddress.County, VendPmtAddress."Country/Region Code");
    end;

    /// <summary>
    /// TextHundreds.
    /// </summary>
    /// <param name="Hundreds">Integer.</param>
    /// <param name="Tens">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextHundreds(Hundreds: Integer; Tens: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        if Hundreds = 0 THEN
            EXIT('');
        if Masc THEN
            CASE Hundreds OF
                1:
                    if (Tens = 0) AND (Units = 0) THEN
                        EXIT(Text1100008)
                    ELSE
                        EXIT(Text1100009);
                2:
                    EXIT(Text1100010);
                3:
                    EXIT(Text1100011);
                4:
                    EXIT(Text1100012);
                5:
                    EXIT(Text1100013);
                6:
                    EXIT(Text1100014);
                7:
                    EXIT(Text1100015);
                8:
                    EXIT(Text1100016);
                9:
                    EXIT(Text1100017);
            END
        ELSE
            CASE Hundreds OF
                1:
                    if (Tens = 0) AND (Units = 0) THEN
                        EXIT(Text1100008)
                    ELSE
                        EXIT(Text1100009);
                2:
                    EXIT(Text1100018);
                3:
                    EXIT(Text1100019);
                4:
                    EXIT(Text1100020);
                5:
                    EXIT(Text1100021);
                6:
                    EXIT(Text1100022);
                7:
                    EXIT(Text1100023);
                8:
                    EXIT(Text1100024);
                9:
                    EXIT(Text1100025);
            END;
    end;


    /// <summary>
    /// TextTensUnits.
    /// </summary>
    /// <param name="Tens">Integer.</param>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextTensUnits(Tens: Integer; Units: Integer; Masc: Boolean): Text[250]
    begin
        CASE Tens OF
            0:
                EXIT(TextUnits(Units, Masc));
            1:
                CASE Units OF
                    0:
                        EXIT(Text1100026);
                    1:
                        EXIT(Text1100027);
                    2:
                        EXIT(Text1100028);
                    3:
                        EXIT(Text1100029);
                    4:
                        EXIT(Text1100030);
                    5:
                        EXIT(Text1100031);
                    ELSE
                        EXIT(Text1100032 + TextUnits(Units, Masc));
                END;
            2:
                if Units = 0 THEN
                    EXIT(Text1100033)
                ELSE
                    EXIT(Text1100034 + TextUnits(Units, Masc));
            3:
                if Units = 0 THEN
                    EXIT(Text1100035)
                ELSE
                    EXIT(Text1100036 + TextUnits(Units, Masc));
            4:
                if Units = 0 THEN
                    EXIT(Text1100037)
                ELSE
                    EXIT(Text1100038 + TextUnits(Units, Masc));
            5:
                if Units = 0 THEN
                    EXIT(Text1100039)
                ELSE
                    EXIT(Text1100040 + TextUnits(Units, Masc));
            6:
                if Units = 0 THEN
                    EXIT(Text1100041)
                ELSE
                    EXIT(Text1100042 + TextUnits(Units, Masc));
            7:
                if Units = 0 THEN
                    EXIT(Text1100043)
                ELSE
                    EXIT(Text1100044 + TextUnits(Units, Masc));
            8:
                if Units = 0 THEN
                    EXIT(Text1100045)
                ELSE
                    EXIT(Text1100046 + TextUnits(Units, Masc));
            9:
                if Units = 0 THEN
                    EXIT(Text1100047)
                ELSE
                    EXIT(Text1100048 + TextUnits(Units, Masc));
        END;
    end;


    /// <summary>
    /// TextUnits.
    /// </summary>
    /// <param name="Units">Integer.</param>
    /// <param name="Masc">Boolean.</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure TextUnits(Units: Integer; Masc: Boolean): Text[250]
    begin
        CASE Units OF
            0:
                EXIT('');
            1:
                if Masc THEN
                    EXIT(Text1100049)
                ELSE
                    EXIT(Text1100050);
            2:
                EXIT(Text1100051);
            3:
                EXIT(Text1100052);
            4:
                EXIT(Text1100053);
            5:
                EXIT(Text1100054);
            6:
                EXIT(Text1100055);
            7:
                EXIT(Text1100056);
            8:
                EXIT(Text1100057);
            9:
                EXIT(Text1100058);
        END;
    end;


    /// <summary>
    /// TextNoDecimals.
    /// </summary>
    /// <param name="NoDecimals">Integer.</param>
    /// <returns>Return value of type Text[15].</returns>
    procedure TextNoDecimals(NoDecimals: Integer): Text[15]
    begin
        if Decimals > 1 THEN
            CASE NoDecimals OF
                0:
                    EXIT('');
                1:
                    EXIT(Text1100059);
                2:
                    EXIT(Text1100060);
                3:
                    EXIT(Text1100061);
                4:
                    EXIT(Text1100062);
            END
        ELSE
            CASE NoDecimals OF
                0:
                    EXIT('');
                1:
                    EXIT(Text1100063);
                2:
                    EXIT(Text1100064);
                3:
                    EXIT(Text1100065);
                4:
                    EXIT(Text1100066);
            END;
    end;

    local procedure AddToNoText(var NoText: array[2] of Text[80]; var NoTextIndex: Integer; AddText: Text[80])
    begin
        WHILE STRLEN(NoText[NoTextIndex] + AddText) > MAXSTRLEN(NoText[1]) DO BEGIN
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ARRAYLEN(NoText) THEN
                ERROR(Text1100067, AddText);
        END;

        NoText[NoTextIndex] := DELCHR(NoText[NoTextIndex] + AddText, '<');
    end;


    /// <summary>
    /// FindApplnEntriesDtldtLedgEntry.
    /// </summary>
    procedure FindApplnEntriesDtldtLedgEntry()
    var
        DtldVendLedgEntry1: Record 380;
        DtldVendLedgEntry2: Record 380;
    begin
        DtldVendLedgEntry1.SETCURRENTKEY("Vendor Ledger Entry No.");
        DtldVendLedgEntry1.SETRANGE("Vendor Ledger Entry No.", CreateVendLedgEntry."Entry No.");
        DtldVendLedgEntry1.SETRANGE(Unapplied, FALSE);
        if DtldVendLedgEntry1.FIND('-') THEN
            REPEAT
                if DtldVendLedgEntry1."Vendor Ledger Entry No." =
                   DtldVendLedgEntry1."Applied Vend. Ledger Entry No."
                THEN BEGIN
                    DtldVendLedgEntry2.INIT;
                    DtldVendLedgEntry2.SETCURRENTKEY("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SETRANGE(
                      "Applied Vend. Ledger Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SETRANGE("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SETRANGE(Unapplied, FALSE);
                    if DtldVendLedgEntry2.FIND('-') THEN
                        REPEAT
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <>
                               DtldVendLedgEntry2."Applied Vend. Ledger Entry No."
                            THEN BEGIN
                                rVendenTry2.SETCURRENTKEY("Entry No.");
                                rVendenTry2.SETRANGE("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if rVendenTry2.FIND('-') THEN BEGIN
                                    rVendenTry := rVendenTry2;
                                    if rVendenTry.INSERT THEN;
                                END;
                            END;
                        UNTIL DtldVendLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    rVendenTry2.SETCURRENTKEY("Entry No.");
                    rVendenTry2.SETRANGE("Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    if rVendenTry2.FIND('-') THEN BEGIN
                        rVendenTry := rVendenTry2;
                        if rVendenTry.INSERT THEN;
                    END ELSE BEGIN
                        rVendenTry2.RESET;
                        rVendenTry2.SETCURRENTKEY("Document No.");
                        rVendenTry2.SETRANGE(rVendenTry2."Document Type", rVendenTry2."Document Type"::Invoice);
                        rVendenTry2.SETRANGE(rVendenTry2."Document No.", CreateVendLedgEntry."Document No.");
                        if rVendenTry2.FIND('-') THEN BEGIN
                            rVendenTry := rVendenTry2;
                            if rVendenTry.INSERT THEN;
                        END;
                    END;
                END;
            UNTIL DtldVendLedgEntry1.NEXT = 0;
        rVendenTry2.RESET;
    end;

    local procedure InsertaMovs()
    var
        SeleccionPagaresProveedores: Record 50000;
        VendorLedgerEntry: Record 25;
    begin
        if SeleccionPagaresProveedores.FINDFIRST THEN
            REPEAT
                VendorLedgerEntry.GET(SeleccionPagaresProveedores.Secuencia);
                CustLedgEntry := VendorLedgerEntry;
                CustLedgEntry.INSERT;
            UNTIL SeleccionPagaresProveedores.NEXT = 0;
    end;
}

