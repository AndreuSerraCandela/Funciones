/// <summary>
/// PageExtension JobsSetup (ID 80150) extends Record Jobs Setup.
/// </summary>
pageextension 80150 JobsSetup extends "Jobs Setup"
{
    layout
    {
        addafter("Allow Sched/Contract Lines Def")
        {
            field("Correlación de ingresos-gastos"; Rec."Correlación de ingresos-gastos")
            {
                ApplicationArea = All;
            }
        }
        addlast(content)
        {
            group(Malla)
            {
                field("Nº serie tarifa"; Rec."Nº serie tarifa")
                {
                    ApplicationArea = All;
                }
                field("Nº serie orden publicidad"; Rec."Nº serie orden publicidad")
                {
                    applicationArea = All;
                }
                field("Crear Factura Interempresas"; Rec."Crear Factura Interempresas") { ApplicationArea = All; }
                field("Cód. Proyecto Genérico"; Rec."Cód. Proyecto Genérico") { ApplicationArea = All; }
                field("Tarifa manual prensa"; Rec."Tarifa manual prensa") { ApplicationArea = All; }
                field("Tarifa manual radio"; Rec."Tarifa manual radio") { ApplicationArea = All; }
                field("Tarifa manual cine"; Rec."Tarifa manual cine") { ApplicationArea = All; }
                field("Imprimir orden al validar"; Rec."Imprimir orden al validad") { ApplicationArea = All; }
                field("Dpto. General"; Rec."Dpto. General") { ApplicationArea = All; }
                field("Dpto. Exterior"; Rec."Dpto. Exterior") { ApplicationArea = All; }
                field("Limite paso Proyecto a Contrat"; Rec."Limite paso Proyecto a Contrat") { ApplicationArea = All; }
                field("Impr. Ped. Compra asociado Cto"; Rec."Impr. Ped. Compra asociado Cto") { ApplicationArea = All; }
                field("Facturar solo si Cto Firmado"; Rec."Facturar solo si Cto Firmado") { ApplicationArea = All; }
                field("Poder modificar fecha firmado"; Rec."Poder modificar fecha firmado") { ApplicationArea = All; }
                field("Poder modificar renovado"; Rec."Poder modificar renovado") { ApplicationArea = All; }
                field("Listado proyectos"; 'Listado proyectos') { ApplicationArea = All; }
                field("Proy Impr Iva/Total"; Rec."Proy Impr Iva/Total") { ApplicationArea = All; }
                field("Proy Impr Sop/Sec"; Rec."Proy Impr Sop/Sec") { ApplicationArea = All; }
                field("Proy Impr Tot sin IVA"; Rec."Proy Impr Tot sin IVA") { ApplicationArea = All; }
                field("Cuenta Contable Emplazamientos"; Rec."Cuenta Contable Emplazamientos") { ApplicationArea = All; }
                field("Grupo Contable emplazamiento"; Rec."Grupo Contable emplazamiento") { ApplicationArea = All; }
                field("Cliente Varios"; Rec."Cliente Varios") { ApplicationArea = All; }
                field("No Comprobar Recursos"; Rec."No Comprobar Recursos") { ApplicationArea = All; }
                field("Nuevo sistema producción"; Rec."Nuevo sistema producción") { ApplicationArea = All; }

            }
            group(Cláusulas)
            {
                field("Cláusula Buses"; Rec."Clausula Buses")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Cláusula Intercambio"; Rec."Clausula Intercambio")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }

    }
}
