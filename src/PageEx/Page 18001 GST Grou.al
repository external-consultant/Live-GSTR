pageextension 76957 GSTGroup_P76957 extends "GST Group"
{
    layout
    {
        addlast(General)
        {

            field("NIL Rated Group"; Rec."NIL Rated Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NIL Rated Group field.';
            }
        }
    }
}
