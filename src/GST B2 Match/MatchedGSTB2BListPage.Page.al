Page 76953 "Matched GSTB2B List Page"
{
    Editable = false;
    PageType = List;
    SourceTable = GSTB2BXMLPort_;
    SourceTableView = sorting("Entry No.")
                      order(descending)
                      where(Post=const(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("GSTIN of supplier";"GSTIN of supplier")
                {
                    ApplicationArea = Basic;
                }
                field("Trade/Legal name";"Trade/Legal name")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Number";"Invoice Number")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Date";"Invoice Date")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Value";"Invoice Value")
                {
                    ApplicationArea = Basic;
                }
                field("Taxable Value";"Taxable Value")
                {
                    ApplicationArea = Basic;
                }
                field("Integrated Tax";"Integrated Tax")
                {
                    ApplicationArea = Basic;
                }
                field("Central Tax";"Central Tax")
                {
                    ApplicationArea = Basic;
                }
                field("State/UT Tax";"State/UT Tax")
                {
                    ApplicationArea = Basic;
                }
                field("TOTAL GST";"TOTAL GST")
                {
                    ApplicationArea = Basic;
                }
                field("GSTR-1/IFF/GSTR-5 Period";"GSTR-1/IFF/GSTR-5 Period")
                {
                    ApplicationArea = Basic;
                }
                field("Credit Availed";"Credit Availed")
                {
                    ApplicationArea = Basic;
                }
                field(Checked;Checked)
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Match";"Invoice Match")
                {
                    ApplicationArea = Basic;
                }
                field("Matching Error";"Matching Error")
                {
                    ApplicationArea = Basic;
                    StyleExpr = Style_gTxt;
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Matched Invoice No.";"Matched Invoice No.")
                {
                    ApplicationArea = Basic;
                }
                field("Force Match Invoice No.";"Force Match Invoice No.")
                {
                    ApplicationArea = Basic;
                }
                field("Forced Match Remarks";"Forced Match Remarks")
                {
                    ApplicationArea = Basic;
                }
                field("Forced Match";"Forced Match")
                {
                    ApplicationArea = Basic;
                }
                field("Return File Month";"Return File Month")
                {
                    ApplicationArea = Basic;
                }
                field(Post;Post)
                {
                    ApplicationArea = Basic;
                }
                field(Remarks;Remarks)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetRecord()
    begin
        Style_gTxt := '';
        if "Matching Error" <> '' then
          Style_gTxt := 'Attention';
    end;

    var
        Style_gTxt: Text;
}

