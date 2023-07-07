report 60050 "ATT Load Tagetik GL Entries"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Load Tagetik GL Entries', comment = 'ESP="Cargar movimientos de contabilidad - Tagetik"';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                rLTagetikGLEntry: Record "ATT Tagetik G/L Entry";
                vLTagetikType: Enum "ATT Tagetik Type";
            begin
                rLTagetikGLEntry.CheckTagetik();
                rLTagetikGLEntry.LoadTagetikGLEntries(vLTagetikType::"Job Queue");
            end;
        }
    }
}
