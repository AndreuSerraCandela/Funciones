/// <summary>
/// Page Buzón Entrada (ID 7001168).
/// </summary>
page 7001168 "Buzón Entrada"
{
    SourceTable = Company;
    Caption = 'Buzón Entrada Facturas';
    PageType = Card;
    UsageCategory = Tasks;
    ApplicationArea = All;
    SourceTableView = where("Evaluation Company" = Const(false));
    layout
    {
        area(Content)
        {
            group("Empresa Seleccionda")
            {
                Editable = false;
                field("Empresa"; Emp)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(FacturasPendientes; 'Facturas Pendientes de ' + Rec.Name)
                {
                    //ShowCaption = false;

                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    BEGIN

                        if ACTION::LookupOK = Page.RUNMODAL(0, rEmp) THEN BEGIN
                            Rec.SETRANGE(Name, rEmp.Name);
                            Rec.FINDFIRST;
                            //RESET;
                            Rec.SETRANGE(Name);
                            CurrPage.UPDATE(FALSE);
                        END;
                    END;
                }

            }
            repeater(Empresas)
            {
                field(Nombre; Rec.Name) { ApplicationArea = All; }

            }

        }
    }

    VAR
        Text015: Label 'El usuario no está debidamente registrado';
        Text016: Label 'El hotel de trabajo no está parametrizado';
        Text017: Label 'Reservas Anuladas';
        Text018: Label 'Reservas No Show';
        Text019: Label 'Histórico de reservas';
        Text020: Label 'Consulta de reservas';
        Text022: Label 'No tiene autorización para ejecutar esta opción';
        rIc: Record 413;
        r112: Record 112;
        Ventana: Dialog;
        Emp: Integer;
        rEmp: Record 2000000006 TEMPORARY;
        r114: Record 114;
        rInf: Record "IC Setup";




    //     BEGIN
    //     {
    //       001 29-05-06 LIS: GRB-135, a¤adir punto de menú Gestión facturas anticipos directos.
    //       002 23-11-06 LIS: SGI-114, A¤adir punto Facturación Electrónica
    //     }
    //     END.
    //   }
}

