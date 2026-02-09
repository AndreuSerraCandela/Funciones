

/// <summary>
/// Page Efectos conf. en rem. cerr (2) (ID 50067).
/// </summary>
page 50034 "Efectos conf. en rem. cerr (2)"
{

    Permissions = TableData 7000003 = m;
    PageType = ListPart;

    InsertAllowed = false;
    DeleteAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Closed Cartera Doc.";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; Editable = false; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Original Amount"; Rec."Original Amount") { ApplicationArea = All; }
                field("Original Amount (LCY)"; Rec."Original Amount (LCY)") { ApplicationArea = All; }
                field("Amount for Collection"; Rec."Amount for Collection") { ApplicationArea = All; }
                field("Remaining Amount"; Rec."Remaining Amount") { ApplicationArea = All; }
                field(Redrawn; Rec.Redrawn)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field(Place; Rec.Place)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ShowCaption = false;
                }
                field("Account No."; Rec."Account No.") { ApplicationArea = All; Editable = false; }
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
            }
        }
    }
    VAR
        EfectRegis: Record 7000003;
        MovProveedor: Record 25;
        GestionEfecto: Codeunit "Gestion Confirming";

    PROCEDURE Clasificar();
    BEGIN
        CurrPage.SETSELECTIONFILTER(EfectRegis);
        GestionEfecto.ClasifEfecsRegis(EfectRegis);
    END;

    PROCEDURE Desclasificar();
    BEGIN
        CurrPage.SETSELECTIONFILTER(EfectRegis);
        GestionEfecto.DeclasifEfecsRegis(EfectRegis);
    END;


    PROCEDURE Impagar();
    BEGIN
        // {CurrPage.SETSELECTIONFILTER(EfectRegis);
        // if NOT EfectRegis.FIND('=><') THEN
        //   EXIT;

        // EfectRegis.SETRANGE(Estado,EfectRegis.Estado::Pendiente);
        // if NOT EfectRegis.FIND('-') THEN
        //   ERROR(
        //     'No se han encontrado efectos para impagar. \' +
        //     'Por favor compruebe que ha seleccionado al menos un efecto pendiente.');

        // Movproveedor.RESET;
        // REPEAT
        //   Movproveedor.GET(EfectRegis."Nº mov.");
        //   Movproveedor.MARK(TRUE);
        // UNTIL EfectRegis.NEXT = 0;

        // Movproveedor.MARKEDONLY(TRUE);
        // REPORT.RUNMODAL(REPORT::"Efectos impagados",TRUE,FALSE,MovCliente);
        //  }
    END;

    PROCEDURE Recircular();
    BEGIN
        // {
        // CurrPage.SETSELECTIONFILTER(EfectRegis);
        // if NOT EfectRegis.FIND('=><') THEN
        //   EXIT;

        // EfectRegis.SETRANGE(Estado,EfectRegis.Estado::Impagado);
        // if NOT EfectRegis.FIND('-') THEN
        //   ERROR(
        //     'No se han encontrado efectos para volver a poner en circulación. \' +
        //     'Por favor compruebe que ha seleccionado al menos un efecto impagado.');

        // MovCliente.RESET;
        // REPEAT
        //   MovCliente.GET(EfectRegis."Nº mov.");
        //   MovCliente.MARK(TRUE);
        // UNTIL EfectRegis.NEXT = 0;

        // MovCliente.MARKEDONLY(TRUE);
        // REPORT.RUNMODAL(REPORT::"Recircular impagados",TRUE,FALSE,MovCliente);
        // }
    END;

    PROCEDURE ImprEfRec();
    BEGIN
        CurrPage.SETSELECTIONFILTER(EfectRegis);
        if NOT EfectRegis.FIND('-') THEN
            EXIT;
        // {
        // Movpro.RESET;
        // REPEAT
        //   MovCliente.GET(EfectRegis."Nº mov.");
        //   MovCliente.MARK(TRUE);
        // UNTIL EfectRegis.NEXT = 0;

        // MovCliente.MARKEDONLY(TRUE);
        // REPORT.RUNMODAL(REPORT::"Imprimir efectos/recibos",TRUE,FALSE,MovCliente);
        //  }
    END;

    PROCEDURE Navegar();
    BEGIN
        GestionEfecto.NavegarEfeCerrado(Rec);
    END;


}

page 50035 "Efectos confirming (2)"
{
    Permissions = TableData 7000002 = m;

    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Cartera Doc.";
    SourceTableView = WHERE("Bill Gr./Pmt. Order No." = FILTER(<> ''));

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; Editable = false; }

                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }

                field("Document No."; Rec."Document No.") { ApplicationArea = All; }

                field("No."; Rec."No.") { ApplicationArea = All; }

                field(Description; Rec.Description) { ApplicationArea = All; Editable = false; }
                field("Original Amount (LCY)"; Rec."Original Amount (LCY)") { ApplicationArea = All; }
                field("Original Amount"; Rec."Original Amount") { ApplicationArea = All; }

                field("Remaining Amount"; Rec."Remaining Amount") { ApplicationArea = All; }

                field("Cust./Vendor Bank Acc. Code"; Rec."Cust./Vendor Bank Acc. Code") { ApplicationArea = All; }

                field(Place; Rec.Place)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; }
                field("Account No."; Rec."Account No.") { ApplicationArea = All; Editable = false; }
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
            }
        }

    }
    VAR
        Efecto: Record 7000002;
        GestionEfecto: Codeunit "Gestion Confirming";

    PROCEDURE Clasificar();
    BEGIN
        CurrPage.SETSELECTIONFILTER(Efecto);
        GestionEfecto.ClasifEfecs(Efecto);
    END;

    PROCEDURE Desclasificar();
    BEGIN
        CurrPage.SETSELECTIONFILTER(Efecto);
        GestionEfecto.DesclasifEfecs(Efecto);
    END;

    PROCEDURE AddEfecs();
    BEGIN
        Efecto.COPY(Rec);
        GestionEfecto.InsertEfecs(Efecto);
    END;

    PROCEDURE EliminEfecs();
    BEGIN
        CurrPage.SETSELECTIONFILTER(Efecto);
        GestionEfecto.EliminEfecs(Efecto);
    END;

    PROCEDURE Navegar();
    BEGIN
        GestionEfecto.NavegarEfecs(Rec);
    END;

}

page 50036 "Configuración confirming (2)"
{

    SourceTable = "General Ledger Setup";
    PageType = Card;
    layout
    {
        area(Content)
        {
            field("Ult. nº remesa confirming"; Rec."Ult. nº remesa confirming") { ApplicationArea = All; }
            field("Cod. Confirming"; Rec."Cod. Confirming") { ApplicationArea = All; }

        }
    }

}