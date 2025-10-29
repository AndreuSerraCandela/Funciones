/// <summary>
/// Codeunit Notification Handler (ID 50100).
/// </summary>
codeunit 50100 "Notification Handler"
{
    /// <summary>
    /// OpenProjectCard.
    /// </summary>
    /// <param name="Notification">Notification.</param>
    procedure OpenProjectCard(Notification: Notification)
    var
        Job: Record Job;
        ProjectNo: Text;
    begin
        ProjectNo := Notification.GetData('ProjectNo');
        if ProjectNo <> '' then begin
            Job.SetRange("No.", ProjectNo);
            if Job.FindFirst() then
                Page.Run(Page::"Job Card", Job);
        end;
    end;
}
