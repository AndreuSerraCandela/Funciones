pageextension 75003 ListaIntercambio extends "Intercambio x Empresa"
{
    layout
    {
        modify("Albaranes sin facturar")
        {
            trigger OnDrillDown()
            var
                rDev: Record "Return Shipment Header";
                Alb: Page "Posted Purchase Receipts";
                Dev: Page "Posted Return Shipments";
                rLinDev: Record "Return Shipment Line";
                r120: Record 120;
            begin

                MESSAGE('Primero aparecen los albaranes y luego las devoluciones');
                AlbaranesPendientes(Rec.Empresa, Rec.GETRANGEMIN("Date Filter"), Rec.GETRANGEMAX("Date Filter"), Rec."Código Intercambio", r120);
                CLEAR(Alb);
                r120.MARKEDONLY(TRUE);

                //r120.FINDFIRST;
                Alb.CambiaEmpresa(Rec.Empresa);
                Alb.SETTABLEVIEW(r120);
                Alb.RUNMODAL;
                //FORM.RUNMODAL(0,r120t);
                rDev.CHANGECOMPANY(Rec.Empresa);
                rDev.SETRANGE(rDev."Buy-from Vendor No.", Rec.Proveedor);
                rDev.SETRANGE("Posting Date", Rec.Desde, Rec.Hasta);
                rDev.SETRANGE(Contabilizado, TRUE);
                If rDev.FINDFIRST THEN
                    repeat
                        if rDev.Facturado = false then
                            rDev.Mark(TRUE) ELSE begin
                            rLinDev.CHANGECOMPANY(Rec.Empresa);
                            rLinDev.SETRANGE(rLinDev."Document No.", rDev."No.");
                            rLinDev.SetFilter(rLinDev."Return Qty. Shipped Not Invd.", '<>0');
                            if rLinDev.FINDFIRST THEN
                                rLinDev.Mark(TRUE);
                        end;
                    UNTIL rDev.NEXT = 0;
                rDev.MARKEDONLY(TRUE);
                CLEAR(Dev);
                Dev.CambiaEmpresa(Rec.Empresa);
                Dev.SETTABLEVIEW(rDev);
                Dev.RUNMODAL;

            end;
        }
        modify("Pedidos pendientes")
        {
            trigger OndrillDown()
            var
                Pedido: Page "Purchase List";
                r38: Record 38;
            begin

                PedidosPendientes(Rec.Empresa, Rec.GETRANGEMIN("Date Filter"), Rec.GETRANGEMAX("Date Filter"), Rec."Código Intercambio", r38);
                r38.MARKEDONLY(TRUE);
                //r120.FINDFIRST;
                CLEAR(Pedido);
                Pedido.CambiaEmpresa(Rec.Empresa);
                r38.SETRANGE(r38.Status, 0, 3);
                r38.SETRANGE("No.");
                Pedido.SETTABLEVIEW(r38);
                Pedido.RUNMODAL();
            end;
        }

    }
}
pageextension 75024 ListaIntercambioLP extends "Intercambio x Empresa LP"
{
    layout
    {
        modify("Albaranes sin facturar")
        {
            trigger OnDrillDown()
            var
                rDev: Record "Return Shipment Header";
                Alb: Page "Posted Purchase Receipts";
                Dev: Page "Posted Return Shipments";
                rLinDev: Record "Return Shipment Line";
                r120: Record 120;
            begin

                MESSAGE('Primero aparecen los albaranes y luego las devoluciones');
                AlbaranesPendientes(Rec.Empresa, Rec.GETRANGEMIN("Date Filter"), Rec.GETRANGEMAX("Date Filter"), Rec."Código Intercambio", r120);
                CLEAR(Alb);
                r120.MARKEDONLY(TRUE);

                //r120.FINDFIRST;
                Alb.CambiaEmpresa(Rec.Empresa);
                Alb.SETTABLEVIEW(r120);
                Alb.RUNMODAL;
                //FORM.RUNMODAL(0,r120t);
                rDev.CHANGECOMPANY(Rec.Empresa);
                rDev.SETRANGE(rDev."Buy-from Vendor No.", Rec.Proveedor);
                rDev.SETRANGE("Posting Date", Rec.Desde, Rec.Hasta);
                rDev.SETRANGE(Contabilizado, TRUE);
                If rDev.FINDFIRST THEN
                    repeat
                        if rDev.Facturado = false then
                            rDev.Mark(TRUE) ELSE begin
                            rLinDev.CHANGECOMPANY(Rec.Empresa);
                            rLinDev.SETRANGE(rLinDev."Document No.", rDev."No.");
                            rLinDev.SetFilter(rLinDev."Return Qty. Shipped Not Invd.", '<>0');
                            if rLinDev.FINDFIRST THEN
                                rLinDev.Mark(TRUE);
                        end;
                    UNTIL rDev.NEXT = 0;
                rDev.MARKEDONLY(TRUE);
                CLEAR(Dev);
                Dev.CambiaEmpresa(Rec.Empresa);
                Dev.SETTABLEVIEW(rDev);
                Dev.RUNMODAL;

            end;
        }
        modify("Pedidos pendientes")
        {
            trigger OndrillDown()
            var
                Pedido: Page "Purchase List";
                r38: Record 38;
            begin

                PedidosPendientes(Rec.Empresa, Rec.GETRANGEMIN("Date Filter"), Rec.GETRANGEMAX("Date Filter"), Rec."Código Intercambio", r38);
                r38.MARKEDONLY(TRUE);
                //r120.FINDFIRST;
                CLEAR(Pedido);
                Pedido.CambiaEmpresa(Rec.Empresa);
                r38.SETRANGE(r38.Status, 0, 3);
                r38.SETRANGE("No.");
                Pedido.SETTABLEVIEW(r38);
                Pedido.RUNMODAL();
            end;
        }

    }
}