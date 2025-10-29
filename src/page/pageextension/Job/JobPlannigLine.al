
/// <summary>
/// PageExtension JobPlannigLine (ID 80100) extends Record Job Planning Lines.
/// </summary>
pageextension 80100 JobPlannigLine extends "Job Planning Lines"
{
    layout
    {
        // modify("No.")
        // {
        //     trigger OnLookup(var Text: Text): Boolean
        //     var
        //         ResourceList: Page "Resource List";
        //         Resource: Record Recurso;
        //     begin
        //         if Rec.Type = Rec.Type::Resource Then begin
        //             if ResourceList.RunModal() = Action::LookupOK Then begin
        //                 Error('p');
        //                 Rec.Validate("No.", ResourceList.CambiaEmpresa());
        //             end;
        //         end;
        //     end;

        // }
    }
    actions
    {
        addafter("&Reservation Entries")
        {
            action("Ver años Anteriores")
            {
                ApplicationArea = All;
                Image = Calendar;
                Caption = 'Ver años Anteriores';
                ToolTip = 'Ver años Anteriores';
                trigger OnAction()
                begin
                    Rec.Setrange("Planning Date");
                end;
            }

        }
        addafter("&Open Job Journal_Promoted")
        {
            actionref(Ver_años_Anteriores_Ref; "Ver años Anteriores") { }

        }

    }
    VAR
        JobCreateInvoice: Codeunit "Job Create-Invoice";
        ActiveField: Option ,Cost,CostLCY,PriceLCY,Price;
        rLin: Record "Job Planning Line";
        Empresa: Text[30];

    PROCEDURE CreateSalesInvoice(CrMemo: Boolean);
    VAR
        JobPlanningLine: Record 1003;
        JobCreateInvoice: Codeunit 1002;
    BEGIN
        Rec.TESTFIELD("Line No.");
        JobPlanningLine.COPY(Rec);
        CurrPage.SETSELECTIONFILTER(JobPlanningLine);
        JobCreateInvoice.CreateSalesInvoice(JobPlanningLine, CrMemo)
    END;

    PROCEDURE SetActiveField(ActiveField2: Integer);
    BEGIN
        ActiveField := ActiveField2;
    END;

    PROCEDURE Devuelvemarcados(VAR pLin: Record 1003);
    BEGIN
        pLin.CLEARMARKS;
        if Empresa <> '' THEN BEGIN
            rLin.CHANGECOMPANY(Empresa);
            pLin.CHANGECOMPANY(Empresa);
        END;
        CurrPage.SETSELECTIONFILTER(rLin);
        if rLin.FINDFIRST THEN
            REPEAT
                pLin.GET(rLin."Job No.", rLin."Job Task No.", rLin."Line No.");
                pLin.MARK := TRUE;
            UNTIL rLin.NEXT = 0;
    END;

    PROCEDURE CambiaEmpresa(pEmpresa: Text[30]);
    BEGIN
        Rec.CHANGECOMPANY(pEmpresa);
        Empresa := pEmpresa;
        //CurrPage.UPDATE(FALSE);
    END;
}

