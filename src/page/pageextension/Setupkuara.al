/// <summary>
/// PageExtension SetupKuara (ID 80102) extends Record General Ledger Setup.
/// </summary>
pageextension 80102 "SetupKuara" extends "General Ledger Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(Reporting)
        {

            field("Ruta fichero SII"; Rec."Ruta fichero SII")
            {
                ApplicationArea = All;
            }
            field("No Comprobar Consistencia"; Rec."No Comprobar Consistencia")
            {
                ApplicationArea = All;
                ToolTip = 'Ojo, muchisimo cuidado, consultar con informática';
            }
            field("No Comprobar Redondeo"; Rec."No Comprobar Redondeo")
            {
                ApplicationArea = All;
                ToolTip = 'Ojo, muchisimo cuidado, consultar con informática';
            }
        }
    }
    actions
    {
        addafter("Accounting Periods")
        {
            // action("Revisar Dimensiones")
            // {
            //     ApplicationArea = All;
            //     Image = DimensionSets;
            //     trigger OnAction()
            //     var
            //         DimensionValue: Record "Dimension Value";
            //         DimensionValueTemp: Record "Dimension Value" temporary;
            //     begin
            //         if DimensionValue.FindFirst() Then
            //             repeat
            //                 DimensionValueTemp := DimensionValue;
            //                 DimensionValueTemp.Insert();
            //             until DimensionValue.Next() = 0;
            //         DimensionValue.DeleteAll();
            //         if DimensionValueTemp.FindFirst() then
            //             repeat
            //                 DimensionValue.Init();
            //                 DimensionValue.Validate("Dimension Code", DimensionValueTemp."Dimension Code");
            //                 DimensionValue.Validate(Code, DimensionValueTemp.Code);
            //                 DimensionValue.Validate(Name, DimensionValueTemp.Name);
            //                 DimensionValue.Insert(true);

            //             until DimensionValueTemp.Next() = 0;
            //     end;

            // }
            // action("Fecha Comparación Contratos")
            // {
            //     ApplicationArea = All;
            //     Image = ChangeDates;
            //     trigger OnAction()
            //     var
            //         ContratoAnt: Record "Sales Header";
            //         ContratoAntAnt: Record "Sales Header";
            //         Contratos: Record "Sales Header";
            //         Proyectos: Record "Job";
            //         JobAntAnt: Record "Job";
            //         ProyectosRenovados: Record "Job";
            //         Fecha: Date;
            //     begin
            //         Contratos.SetFilter("No.", '%1', 'CTO23*');
            //         If Contratos.FindSet() then
            //             repeat
            //                 Contratos."Fecha Comparación" := Contratos."Fecha Estado";
            //                 Contratos.MODIFY;
            //             until Contratos.Next() = 0;
            //         Contratos.SetFilter("No.", '%1', 'CTO22*');
            //         If Contratos.FindSet() then
            //             repeat
            //                 Contratos."Fecha Comparación" := Contratos."Fecha Estado";
            //                 Contratos.MODIFY;
            //             until Contratos.Next() = 0;
            //         Contratos.SetFilter("No.", '%1', '??C24*');
            //         If Contratos.FindSet() then
            //             repeat
            //                 Contratos."Fecha Comparación" := Contratos."Fecha Estado";
            //                 Contratos.MODIFY;
            //             until Contratos.Next() = 0;
            //         commit;
            //         Contratos.Reset();
            //         Proyectos.SetRange("No.", 'PR22-00000', 'PR24-ZZZZZ');
            //         Proyectos.Setfilter("Proyecto origen", '<>%1', '');
            //         if Proyectos.FindSet() then
            //             repeat
            //                 Contratos.SetRange("Nº Proyecto", Proyectos."No.");
            //                 Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
            //                 Contratos.SetRange(Estado, Contratos.Estado::Firmado);

            //                 If Contratos.FindFirst() then begin
            //                     If ProyectosRenovados.get(Proyectos."Proyecto origen") then begin
            //                         ContratoAnt.SETRANGE("Nº Proyecto", ProyectosRenovados."No.");
            //                         ContratoAnt.SetRange("Document Type", ContratoAnt."Document Type"::Order);
            //                         if ContratoAnt.FindLast() then begin
            //                             Fecha := CalcDate('PS+1D-1S-1A+PS+5D', Contratos."Fecha Estado");
            //                             ContratoAnt."Fecha Comparación" := Fecha;
            //                             if ContratoAnt."Fecha Estado" = 0D then ContratoAnt."Fecha Estado" := ContratoAnt."Fecha Comparación";
            //                             ContratoAnt.MODIFy;
            //                             if ProyectosRenovados."Proyecto origen" <> '' then begin
            //                                 If JobAntAnt.Get(ProyectosRenovados."Proyecto origen") then begin
            //                                     ContratoAntAnt.SETRANGE("Nº Proyecto", JobAntAnt."No.");
            //                                     ContratoAntAnt.SetRange("Document Type", ContratoAntAnt."Document Type"::Order);
            //                                     if ContratoAntAnt.FindLast() then begin
            //                                         if ContratoAnt."Fecha Estado" = 0D then ContratoAnt."Fecha Estado" := ContratoAnt."Fecha Comparación";
            //                                         If ContratoAntAnt."Fecha Estado" <> 0D then begin
            //                                             Fecha := CalcDate('PS+1D-1S-1A+PS+5D', ContratoAnt."Fecha Estado");
            //                                             ContratoAntAnt."Fecha Comparación" := Fecha;
            //                                             ContratoAntAnt.MODIFY;
            //                                         end;
            //                                     end;
            //                                 end;
            //                             end;
            //                         end;
            //                     end;
            //                 end;
            //             until Proyectos.Next() = 0;
            //     end;
            // }
            // action("Copiar Notas")
            // {
            //     ApplicationArea = All;
            //     Image = Copy;
            //     trigger OnAction()
            //     var
            //         Rk: Record "Record Link";
            //         NewNotes: Record "Emplazamientos proveedores new";
            //         OldNotes: Record "Emplazamientos proveedores";
            //         Copynotes: Codeunit "Record Link Management";
            //     begin
            //         If OldNotes.FindFirst() Then
            //             repeat
            //                 NewNotes.TransferFields(OldNotes);
            //                 NewNotes.INSERT;
            //                 Copynotes.CopyLinks(NewNotes, OldNotes);
            //             until OldNotes.NEXT = 0;
            //         NewNotes.DeleteAll(false);
            //     end;
            // }

        }
    }


    var
        myInt: Integer;

}
