pageextension 76953 GeneralLedgerEntries_P76953 extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {

            field("GSTR-1/IFF/GSTR-5 Period"; Rec."GSTR-1/IFF/GSTR-5 Period")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the GSTR-1/IFF/GSTR-5 Period field.';
            }
        }
    }
}
