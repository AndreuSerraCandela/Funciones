/// <summary>
/// PageExtension ForecasEntry (ID 80218) extends Record Cash Flow Forecast Entries.
/// </summary>
pageextension 80209 ForecasEntry extends "Cash Flow Forecast Entries"
{
    layout
    {
        addfirst(Control1000)
        {
            field(Empresa; Rec.Empresa)
            {
                ApplicationArea = All;
            }


        }

        addlast(Control1000)
        {
            field("Fecha Anotacion"; Rec."Fecha Anotacion")
            {
                ApplicationArea = All;
            }
            field("Anotación"; Rec."Anotación")
            {
                ApplicationArea = All;
            }
            field("Associated Entry No."; Rec."Associated Entry No.")
            {
                ApplicationArea = All;
            }

        }
        addafter(Description)
        {

            field("Cod. banco"; Rec."Cod banco")
            {
                ApplicationArea = All;
            }
            field("Nombre Banco"; Rec."Nombre Banco")
            {
                ApplicationArea = All;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                Caption = 'Forma de Pago';
                ApplicationArea = All;
            }
            field(Comercial; Comercial())
            {
                ApplicationArea = ALL;
            }

        }
        modify("Source Type")

        {
            Visible = false;
        }
        modify("User ID")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 3 Code")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 4 Code")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 5 Code")
        {
            Visible = false;
        }
        modify("Global Dimension 1 Code")
        {
            Visible = false;
        }
        modify("Global Dimension 2 Code")
        {
            Visible = true;
        }
    }
    actions
    {
        // modify(ShowSource)
        // {
        //     Visible = false;
        // }
        addafter(ShowSource)
        {

        }
    }
    Procedure Comercial(): Text
    var
        R21: Record 21;
        r18: Record Customer;
        r13: Record 13;
    begin
        r13.ChangeCompany(Rec.Empresa);
        if Rec."Source Type" In [Rec."Source Type"::"Cartera Clientes", Rec."Source Type"::Receivables] THEN begin
            if STRLEN(Rec."Source No.") > 20 THEN EXIT('');
            r21.CHANGECOMPANY(Rec.Empresa);
            if r21.GET(Rec."Associated Entry No.") THEN BEGIN
                if r13.GET(r21."Salesperson Code") THEN EXIT(r13.Name);
            END;
            r18.CHANGECOMPANY(Rec.Empresa);
            if r18.GET(Rec."Source No.") THEN BEGIN
                if r13.GET(r18."Salesperson Code") THEN EXIT(r13.Name);
            END;
        end;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

}