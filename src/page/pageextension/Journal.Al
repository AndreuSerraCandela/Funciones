/// <summary>
/// PageExtension DiarioCartera (ID 80152) extends Record Cartera Journal.
/// </summary>
pageextension 80152 DiarioCartera extends "Cartera Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field(AccountName; AccName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Nombre cuenta';
                Editable = false;
                ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
            }
        }
        addAfter("Bal. Account No.")
        {
            field(BalAccountName; BalAccName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Nombre contrapartida';
                Editable = false;
                ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
            }
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }

            field("Source Type"; Rec."Source Type")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
    var
        AccName: Text[100];
        BalAccName: Text[100];

    trigger OnAfterGetRecord()
    var
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
    end;
}
pageextension 80153 DiarioGeneral extends "General Journal"
{
    layout
    {
        addAfter("Bal. Account No.")
        {

            field("Source Type"; Rec."Source Type")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Visible = true;
            }

            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;

            }


            field("Nº Albarán"; Rec."Nº Albar n")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Periodo de Pago"; Rec."Periodo de Pago")
            {
                ApplicationArea = All;
            }
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }

        }
        modify("VAT Reporting Date")
        {
            Visible = false;
        }

    }


}
pageextension 80164 DiarioPagos extends "Payment Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field(AccountName; AccName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Nombre cuenta';
                Editable = false;
                ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
            }
        }
        addAfter("Bal. Account No.")
        {
            field(BalAccountName; BalAccName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Nombre contrapartida';
                Editable = false;
                ToolTip = 'Specifies the account name that the entry on the journal line will be posted to.';
            }
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Source Type"; Rec."Source Type")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Visible = true;
            }


        }

    }
    var
        AccName: Text[100];
        BalAccName: Text[100];

    trigger OnAfterGetRecord()
    var
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
    end;
}
pageextension 80165 DiarioCobros extends "Cash Receipt Journal"
{
    layout
    {
        addAfter("Bal. Account No.")
        {
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Source Type"; Rec."Source Type")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Visible = true;
            }


        }

    }
}