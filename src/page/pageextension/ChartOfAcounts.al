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
                begin
                    Rec.CopyFilter("Date Filter", GlEntries."Posting Date");
                    GlEntries.SetRange("G/L Account No.", Rec."No.", Copystr(Rec."No." + '999999999', 1, MaxStrLen(GlEntries."G/L Account No.")));
                    if Emp.FindFirst() Then
                        repeat
                            if Control.Permiso_Empresas(Emp.Name) then begin
                                GlEntries.ChangeCompany(Emp.Name);
                                if GlEntries.FindFirst() Then
                                    repeat
                                        EntryNo += 1;
                                        GlEntriesTemp := GlEntries;
                                        GlEntriesTemp.Comment := Emp.Name;
                                        GlEntriesTemp."Entry No." := EntryNo;
                                        if GlEntries."Job No." <> '' Then begin
                                            SalesHeader.ChangeCompany(Emp.Name);
                                            SalesHeader.SetRange("Nº Contrato", GlEntries."Job No.");
                                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                                            if SalesHeader.FindFirst() Then
                                                GlEntriesTemp."Nº Contrato" := SalesHeader."No.";
                                        end;
                                        GlEntriesTemp.Insert();
                                    until GlEntries.Next() = 0;
                            end;
                        until Emp.Next() = 0;
                    Commit();

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