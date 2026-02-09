/// <summary>
/// PageExtension GLAccountS (ID 80167) extends Record Chart of Accounts.
/// </summary>
pageextension 80167 GLAccountS extends "Chart of Accounts"
{
    layout
    {
        addafter(Name)
        {
            field(Indentation; Rec.Indentation)
            {
                ApplicationArea = All;
            }
        }
        addbefore("Balance at Date")
        {
            field("Saldo a la fecha"; Rec."Saldo a la fecha")
            {
                ApplicationArea = All;
            }
            field("Debe Acumulado"; Rec."Debe Acumulado")
            {
                ApplicationArea = All;
            }
            field("Haber Acumulado"; Rec."Haber Acumulado")
            {
                ApplicationArea = All;
            }

        }
        modify("Balance at Date")
        { Visible = false; }

    }
    actions
    {
        addafter("A&ccount")
        {
            action("Mov. Todas las empresas")
            {
                ApplicationArea = all;
                Image = GeneralLedger;
                trigger OnAction()
                var
                    GlEntries: Record "G/L Entry";
                    GlEntriesTemp: Record "G/L Entry" temporary;
                    EntryNo: Integer;
                    Control: Codeunit ControlProcesos;
                    Emp: Record Company;
                    pMov: Page "General Ledger Entries";
                    SalesHeader: Record "Sales Header";
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    SalesShipmentHeader: Record "Sales Shipment Header";
                    Ventana: Dialog;
                    a: Integer;
                begin
                    Rec.CopyFilter("Date Filter", GlEntries."Posting Date");
                    Ventana.Open('Procesando Movimientos de la empresa #################1#\'
                    + 'Desde dia ' + Format(Rec.GetRangeMin("Date Filter"), 0, '<Day,2>/<Month,2>/<Year>')
                    + ' hasta dia ' + Format(Rec.GetRangeMax("Date Filter"), 0, '<Day,2>/<Month,2>/<Year>') + '\'
                    + '###############2## de ############3##');
                    GlEntries.SetRange("G/L Account No.", Rec."No.", Copystr(Rec."No." + '999999999', 1, MaxStrLen(GlEntries."G/L Account No.")));
                    if Emp.FindFirst() Then
                        repeat
                            Ventana.Update(1, Emp.Name);

                            a := 0;
                            if Control.Permiso_Empresas(Emp.Name) then begin
                                GlEntries.ChangeCompany(Emp.Name);
                                Ventana.Update(3, GlEntries.Count());
                                if GlEntries.FindFirst() Then
                                    repeat
                                        a := a + 1;
                                        Ventana.Update(2, a);
                                        EntryNo += 1;
                                        GlEntriesTemp := GlEntries;
                                        GlEntriesTemp.Comment := Emp.Name;
                                        GlEntriesTemp."Entry No." := EntryNo;
                                        if GlEntries."Job No." <> '' Then begin
                                            GlEntriesTemp."Nº Contrato" := '';
                                            SalesHeader.ChangeCompany(GlEntriesTemp.Comment);
                                            SalesHeader.SetRange("Nº proyecto", GlEntries."Job No.");
                                            SalesHeader.SetRange("Nº Contrato", '');
                                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                                            if SalesHeader.FindSet() Then
                                                GlEntriesTemp."Nº Contrato" := SalesHeader."No.";
                                            if GlEntriesTemp."Nº Contrato" = '' Then begin
                                                SalesInvoiceHeader.ChangeCompany(GlEntriesTemp.Comment);
                                                GlEntriesTemp."Nº Contrato" := '';
                                                if SalesInvoiceHeader.Get(GlEntries."Document No.") Then
                                                    GlEntriesTemp."Nº Contrato" := SalesInvoiceHeader."Nº Contrato";
                                                if GlEntriesTemp."Nº Contrato" = '' Then begin
                                                    SalesCrMemoHeader.ChangeCompany(GlEntriesTemp.Comment);
                                                    if SalesCrMemoHeader.Get(GlEntries."Document No.") Then
                                                        GlEntriesTemp."Nº Contrato" := SalesCrMemoHeader."Nº Contrato";
                                                end;
                                                if GlEntriesTemp."Nº Contrato" = '' Then begin
                                                    SalesShipmentHeader.ChangeCompany(GlEntriesTemp.Comment);
                                                    if SalesShipmentHeader.Get(GlEntries."Document No.") Then
                                                        GlEntriesTemp."Nº Contrato" := SalesShipmentHeader."Nº Contrato";
                                                end;
                                            end;
                                        end;
                                        GlEntriesTemp.Insert();
                                    until GlEntries.Next() = 0;
                            end;
                        until Emp.Next() = 0;
                    Commit();
                    Ventana.Close();
                    Page.RunModal(0, GlEntriesTemp);

                end;
            }
        }
    }
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

}
pageextension 80173 GLAccount extends "G/L Account Card"
{
    layout
    {
        addafter(Name)
        {
            field(Indentation; Rec.Indentation)
            {
                ApplicationArea = All;
            }
        }


    }
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

}