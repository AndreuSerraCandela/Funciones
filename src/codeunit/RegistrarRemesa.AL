/// <summary>
/// Codeunit Remesa C.-Registrar + Impr (ID 50011).
/// </summary>
Codeunit 50011 "Remesa C.-Registrar + Impr"
{

    PROCEDURE SoloReg(NoRemesa: Record "Cab. borrador pagare");
    BEGIN
        if NoRemesa.Impresa = false THEN BEGIN
            if NOT
              CONFIRM(
                'El confirming no se ha impreso. ¿Confirma que desea continuar?')
            THEN
                ERROR('El proceso de registro ha sido cancelado por el usuario.');
        END ELSE
            if NOT
              CONFIRM(
                '¿Confirma que desea registrar el confirming?', FALSE)
            THEN
                ERROR('El proceso de registro ha sido cancelado por el usuario.');

        NoRemesa.SETRECFILTER;
        REPORT.RUNMODAL(REPORT::"Registrar remesas confirming", false, FALSE, NoRemesa);
    END;

    PROCEDURE ImprYRegis(NoRemesa: Record "Cab. borrador pagare");
    VAR
        NoRemeRegis: Record "Cab. borrador pagare";
    BEGIN
        NoRemesa.SETRECFILTER;
        REPORT.RUNMODAL(REPORT::"Registrar remesas confirming", false, FALSE, NoRemesa);

        COMMIT;

        if NoRemeRegis.GET(NoRemesa."Cód. pagaré") THEN BEGIN
            NoRemeRegis.SETRECFILTER;
            //REPORT.RUNMODAL(REPORT::"Listado remesas confirming", FALSE, FALSE, NoRemeRegis);
        END;
    END;


}