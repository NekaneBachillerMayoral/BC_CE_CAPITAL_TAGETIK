query 60050 "ATT G/L Entries Grouped"
{
    QueryType = Normal;
    Caption = 'G/L Entries Grouped', comment = 'ESP="Movs. Contabilidad Agrupados"';
    Permissions = tabledata "G/L Entry"=r;

    elements
    {
    dataitem(ATT_Tagetik_G_L_Entry;
    "ATT Tagetik G/L Entry")
    {
    column(COMPANY;
    "ATT Company")
    {
    }
    column(ACCOUNT_CODE;
    "ATT G/L Account No.")
    {
    }
    column(ACCOUNT_DESCR;
    "ATT G/L Account Name")
    {
    }
    column(ACCOUNT_NATURE;
    "ATT Account Nature")
    {
    }
    column(ACCOUNT_TYPE;
    "ATT Account Type")
    {
    }
    column(ACCOUNT_CONVERSION_TYPE;
    "ATT Account Conv. Type")
    {
    }
    column(CURRENCY;
    "ATT LCY Code")
    {
    }
    column(AMOUNT;
    "ATT Amount")
    {
    Method = Sum;
    }
    column(DEST2_CODE;
    "ATT Cost Center Code")
    {
    }
    column(DEST2_DESCR;
    "ATT Cost Center Name")
    {
    }
    column(COMPANY_IC;
    "ATT IC Code")
    {
    }
    filter(POSTING_DATE;
    "ATT Posting Date")
    {
    }
    }
    }
    trigger OnBeforeOpen()
    var
        rLTagetikGLEntry: Record "ATT Tagetik G/L Entry";
        vLTagetikType: Enum "ATT Tagetik Type";
    begin
        rLTagetikGLEntry.CheckTagetik();
        rLTagetikGLEntry.LoadTagetikGLEntries(vLTagetikType::"Web Service");
    end;
}
