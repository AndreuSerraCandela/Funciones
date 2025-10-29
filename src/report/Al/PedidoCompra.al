/// <summary>
/// Unknown PedidoCompra (ID 80100) extends Record Order.
/// </summary>
reportextension 80100 PedidoCompra extends "Order"
{
    dataset
    {
        modify("Purchase Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                if Job.Get("Nº Proyecto") Then begin
                    DescripcionProyecto := Job.Description;
                    if Customer.Get(Job."Bill-to Customer No.") then
                        Cliente := Customer.Name;
                    NProyecto := "Nº Proyecto";
                    if "Your Reference" = '' then
                        "Your Reference" := 'Proyecto ' + "Nº Proyecto";
                end else begin
                    DescripcionProyecto := "Descripcion proyecto";
                end;
                "Document Date" := "Order Date";
            end;

        }
        add(CopyLoop)
        {
            column(DescripcionProyecto; DescripcionProyecto)
            {
            }
            column(Cliente; Cliente)
            { }
            column("NProyecto"; "NProyecto")
            { }

        }

    }
    trigger OnPreReport()
    begin
        ArchiveDocument := true;
    end;

    var
        DescripcionProyecto: Text;
        "NProyecto": Text;
        Cliente: Text;
        Customer: Record Customer;
        Job: Record Job;
}
