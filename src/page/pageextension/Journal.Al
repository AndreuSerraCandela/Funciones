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
        addfirst(FactBoxes)
        {
            part(MatchingEntriesFB; SugerenciaMovDiarPagoFactBox)
            {
                ApplicationArea = All;
                Caption = 'Sugerencias de Importe';
            }
        }

    }
    actions
    {
        addlast(Processing)
        {
            action(VincularDesdeFactBox)
            {
                Caption = 'Vincular Sugerencia';
                ToolTip = 'Aplica la sugerencia. Si hay varias, elegirá en la que estés situado';
                Image = ApplyEntries;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortcutKey = 'F4';

                trigger OnAction()
                var
                    TempBuffer: Record "Bank Statement Matching Buffer" temporary;
                    SelectionPage: Page "SugerenciaMovDiarPago";
                    // Movemos el Label (Etiqueta) aquí arriba
                    ConfirmMsg: Label 'La línea ya tiene un movimiento de liquidación vinculado. ¿Está seguro de que desea cambiarlo?';
                begin
                    // --- 1. LA NUEVA BARRERA DE SEGURIDAD ---
                    // Preguntamos ANTES de hacer nada, ahorrando tiempo al usuario
                    if (Rec."Applies-to Doc. No." <> '') or (Rec."Applies-to Bill No." <> '') then begin
                        if not Confirm(ConfirmMsg, false) then
                            exit; // Si dice que no, se cancela la ejecución inmediatamente
                    end;

                    // 2. Obtenemos TODOS los registros que ha encontrado el FactBox
                    CurrPage.MatchingEntriesFB.Page.GetSelectedRecord(TempBuffer);

                    if TempBuffer.IsEmpty() then
                        Error('No hay ninguna sugerencia disponible para este importe.');

                    // 3. Si solo hay 1, lo aplicamos del tirón
                    //if TempBuffer.Count = 1 then begin
                    //  TempBuffer.FindFirst();
                    AplicarLinea(TempBuffer);
                    // end else begin
                    //     // 4. Si hay varios, inyectamos los datos y abrimos la ventana flotante
                    //     SelectionPage.SetBuffer(TempBuffer);
                    //     SelectionPage.LookupMode(true);

                    //     if SelectionPage.RunModal() = Action::LookupOK then begin
                    //         SelectionPage.GetRecord(TempBuffer);
                    //         AplicarLinea(TempBuffer);
                    //     end;
                    // end;
                end;
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

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.MatchingEntriesFB.Page.UpdateFactBox(Rec);
    end;

    // --- Procedimiento local (ahora sin el Confirm, solo aplica los datos) ---
    local procedure AplicarLinea(var TempBuffer: Record "Bank Statement Matching Buffer" temporary)
    begin
        Rec.Validate("Account Type", TempBuffer."Account Type");
        Rec.Validate("Account No.", TempBuffer."Account No.");

        Rec."Applies-to Doc. Type" := TempBuffer."Document Type";
        Rec."Applies-to Doc. No." := TempBuffer."Document No.";

        if TempBuffer."Bill No." <> '' then begin
            Rec."Applies-to Bill No." := TempBuffer."Bill No.";
            Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Bill;
        end else begin
            Rec."Applies-to Bill No." := '';
        end;

        Rec.Modify(true);
        CurrPage.Update(false);
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

        addfirst(FactBoxes)
        {
            part(MatchingEntriesFB; SugerenciaMovDiarPagoFactBox)
            {
                ApplicationArea = All;
                Caption = 'Sugerencias de Importe';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(VincularDesdeFactBox)
            {
                Caption = 'Vincular Sugerencia';
                ToolTip = 'Aplica la sugerencia. Si hay varias, te pedirá elegir.';
                Image = ApplyEntries;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortcutKey = 'F4';

                trigger OnAction()
                var
                    TempBuffer: Record "Bank Statement Matching Buffer" temporary;
                    SelectionPage: Page "SugerenciaMovDiarPago";
                    // Movemos el Label (Etiqueta) aquí arriba
                    ConfirmMsg: Label 'La línea ya tiene un movimiento de liquidación vinculado. ¿Está seguro de que desea cambiarlo?';
                begin
                    // --- 1. LA NUEVA BARRERA DE SEGURIDAD ---
                    // Preguntamos ANTES de hacer nada, ahorrando tiempo al usuario
                    if (Rec."Applies-to Doc. No." <> '') or (Rec."Applies-to Bill No." <> '') then begin
                        if not Confirm(ConfirmMsg, false) then
                            exit; // Si dice que no, se cancela la ejecución inmediatamente
                    end;

                    // 2. Obtenemos TODOS los registros que ha encontrado el FactBox
                    CurrPage.MatchingEntriesFB.Page.GetSelectedRecord(TempBuffer); //GetBuffer(TempBuffer);

                    if TempBuffer.IsEmpty() then
                        Error('No hay ninguna sugerencia disponible para este importe.');

                    // 3. Si solo hay 1, lo aplicamos del tirón
                    // if TempBuffer.Count = 1 then begin
                    //     TempBuffer.FindFirst();
                    AplicarLinea(TempBuffer);
                    // end else begin
                    //     // 4. Si hay varios, inyectamos los datos y abrimos la ventana flotante
                    //     SelectionPage.SetBuffer(TempBuffer);
                    //     SelectionPage.LookupMode(true);

                    //     if SelectionPage.RunModal() = Action::LookupOK then begin
                    //         SelectionPage.GetRecord(TempBuffer);
                    //         AplicarLinea(TempBuffer);
                    //     end;
                    // end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.MatchingEntriesFB.Page.UpdateFactBox(Rec);
    end;

    // --- Procedimiento local (ahora sin el Confirm, solo aplica los datos) ---
    local procedure AplicarLinea(var TempBuffer: Record "Bank Statement Matching Buffer" temporary)
    begin
        Rec.Validate("Account Type", TempBuffer."Account Type");
        Rec.Validate("Account No.", TempBuffer."Account No.");

        Rec."Applies-to Doc. Type" := TempBuffer."Document Type";
        Rec."Applies-to Doc. No." := TempBuffer."Document No.";

        if TempBuffer."Bill No." <> '' then begin
            Rec."Applies-to Bill No." := TempBuffer."Bill No.";
            Rec."Applies-to Doc. Type" := Rec."Applies-to Doc. Type"::Bill;
        end else begin
            Rec."Applies-to Bill No." := '';
        end;

        Rec.Modify(true);
        CurrPage.Update(false);
    end;
}