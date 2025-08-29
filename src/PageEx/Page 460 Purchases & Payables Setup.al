pageextension 76956 PurchasesPayablesSetup_P76956 extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {

            field("JV Receivable Nos."; Rec."JV Receivable Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the JV Receivable Nos. field.';
            }
            field("JV Post on GSTB2B"; Rec."JV Post on GSTB2B")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the JV Post on GSTB2B field.';
            }
        }
    }
}
