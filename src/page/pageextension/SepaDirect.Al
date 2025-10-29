pageextension 80160 Sepadirect extends "SEPA Direct Debit Mandates"
{
    actions
    {
        addfirst(Processing)
        {
            action("Crear automáticamente")
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    recBancoClienteLoc: Record "Customer Bank Account";
                    recClienteLoc: Record Customer;
                    recMandatosLoc: Record "SEPA Direct Debit Mandate";

                    g_dlgWindow: Dialog;
                    g_intContador: Integer;
                    g_intTotal: Integer;
                begin

                    recClienteLoc.RESET;
                    if recClienteLoc.FINDFIRST THEN BEGIN
                        g_intContador := 0;
                        g_intTotal := recClienteLoc.COUNT;
                        g_dlgWindow.OPEN('Generando Mandatos @1@@@@@@@@@@@@@');
                        REPEAT
                            g_dlgWindow.UPDATE(1, ROUND(g_intContador / g_intTotal * 10000, 1));
                            g_intContador += 1;
                            recBancoClienteLoc.RESET;
                            recBancoClienteLoc.SETRANGE("Customer No.", recClienteLoc."No.");
                            if recBancoClienteLoc.FINDFIRST THEN
                                REPEAT
                                    recMandatosLoc.INIT;
                                    recMandatosLoc.ID := '';
                                    recMandatosLoc.INSERT(TRUE);
                                    recMandatosLoc.VALIDATE("Customer No.", recBancoClienteLoc."Customer No.");
                                    recMandatosLoc.VALIDATE("Customer Bank Account Code", recBancoClienteLoc.Code);
                                    recMandatosLoc.VALIDATE("Valid From", 20091231D);
                                    recMandatosLoc.VALIDATE("Date of Signature", 20091231D);
                                    recMandatosLoc.VALIDATE("Type of Payment", recMandatosLoc."Type of Payment"::Recurrent);
                                    recMandatosLoc.VALIDATE("Expected Number of Debits", 999999999);
                                    recMandatosLoc.MODIFY(TRUE);
                                UNTIL recBancoClienteLoc.NEXT = 0;

                        UNTIL recClienteLoc.NEXT = 0;
                        g_dlgWindow.CLOSE;
                    END;
                end;
            }
        }
    }
}