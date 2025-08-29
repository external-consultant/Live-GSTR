pageextension 76954 PostedPurchaseInvoice_P76954 extends "Posted Purchase Invoice"
{
    layout
    {
        addlast(General)
        {

            field("GSTR-1/IFF/GSTR-5 Period"; Rec."GSTR-1/IFF/GSTR-5 Period")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the GSTR-1/IFF/GSTR-5 Period field.';
            }
            field("GSTR Force Matched Reversed"; Rec."GSTR Force Matched Reversed")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the GSTR Force Matched Reversed field.';
            }
        }
    }
}
