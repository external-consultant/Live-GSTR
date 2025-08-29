pageextension 76951 "Units of Measure Extension" extends "Units of Measure"
{
    layout
    {
        addlast(Control1)
        {

            field("UQC (GST)"; Rec."UQC (GST)")
            {
                ToolTip = 'Specifies the value of the UQC (GST) field.';
                ApplicationArea = All;
            }
        }
    }
}
