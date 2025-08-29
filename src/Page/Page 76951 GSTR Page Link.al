page 76951 "GSTR Page Link"
{
    Caption = 'GSTR Page Link';
    ApplicationArea = All;
    UsageCategory = Lists;


    layout
    {

    }

    actions
    {
        area(Processing)
        {
            group("GSTR Report")
            {
                action("GSTR All Report")
                {
                    ApplicationArea = All;
                    RunObject = Report "GSTR All Report Multiple";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST B2B")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST B2B";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST B2CL")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST B2CL";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST B2CS")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST B2CS";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST CDNR")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST CDNR";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST CDNUR")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST CDNUR";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST EXP")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST EXP";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST HSN")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST HSN";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST EXEMP")
                {
                    ApplicationArea = All;
                    RunObject = Report "GSTR EXEMP";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GSTR ITC 04 JW To MFG")
                {
                    ApplicationArea = All;
                    RunObject = Report "GSTR ITC 04 JW To MFG";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GSTR ITC 04 MFG To JW")
                {
                    ApplicationArea = All;
                    RunObject = Report "GSTR ITC 04 MFG To JW";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST AT")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST AT";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
                action("GST ATADJ")
                {
                    ApplicationArea = All;
                    RunObject = Report "GST ATADJ";
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                }
            }
        }
    }
}
