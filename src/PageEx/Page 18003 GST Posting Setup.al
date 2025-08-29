pageextension 76958 GSTPostingSetup_P76958 extends "GST Posting Setup"
{
    layout
    {
        addlast(General)
        {
            field("JV Payable Account"; Rec."JV Payable Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the JV Payable Account field.';
            }
            field("JV Recevible Account"; Rec."JV Recevible Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the JV Recevible Account field.';
            }
        }
    }
}
