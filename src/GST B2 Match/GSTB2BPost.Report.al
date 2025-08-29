Report 76967 "GSTB2B Post"
{
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(RejectionComment_gTxt;RejectionComment_gTxt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Posting Date';
                    MultiLine = true;
                    ShowMandatory = true;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        RejectionComment_gTxt: Date;


    procedure GetRejComm_gFnc(): Date
    begin
        exit(RejectionComment_gTxt);
    end;
}

