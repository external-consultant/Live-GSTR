pageextension 76952 "BusinessManagerRole_P33029002" extends "Business Manager Role Center"
{
    actions
    {
        addlast(sections)
        {
            group("GSTR ISPL")
            {
                action("GSTR Report")
                {
                    ApplicationArea = All;
                    RunObject = page "GSTR Page Link";
                }
            }
        }
    }
}
