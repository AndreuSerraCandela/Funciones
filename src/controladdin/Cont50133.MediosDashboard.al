controladdin "Medios Dashboard AddIn"
{
    HorizontalStretch = true;
    MinimumHeight = 750;
    RequestedHeight = 950;
    VerticalStretch = true;

    Scripts = 'src/controladdin/mediosDashboard.js';
    StartupScript = 'src/controladdin/mediosDashboardStartup.js';
    StyleSheets = 'src/controladdin/mediosDashboard.css';

    event ControlReady();
    event ShowProyectos();
    event ShowContratos();
    event ShowProyPlanning();
    event ShowProyQuote();
    event ShowProyOpen();
    event ShowProyCompleted();
    event ShowProyResSin();
    event ShowProyResCon();
    event ShowProyResOrden();
    event ShowFijacion();
    event ShowContSinMontar();
    event ShowContPendFirma();
    event ShowContFirmado();
    event ShowContModificado();
    event ShowContPteRenovar();
    event ShowContCancelado();
    event ShowContAnulado();
    event ShowFirmaPendiente();
    event ShowFirmaGerencia();
    event ShowFirmaMalla();
    event ShowFirmaCliente();
    event ShowFirmaRechMalla();
    event ShowFirmaRechCliente();
    event DrillDown(Action: Text; Year: Integer);
    procedure Render(Payload: Text);
}
