/// <summary>
/// PageExtension KuaraInteraccion (ID 80124) extends Record Interaction Log Entries.
/// </summary>
pageextension 80124 KuaraInteraccion extends "Interaction Log Entries"
{
    actions
    {
        modify("Create Task")
        {
            Promoted = true;
            PromotedIsBig = true;
            PromotedCategory = New;
        }
    }
}
