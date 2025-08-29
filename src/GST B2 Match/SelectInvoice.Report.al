Report 76969 "Select Invoice"
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
                field(Invoice;InvoiceNo_gCode)
                {
                    ApplicationArea = Basic;
                    TableRelation = "Sales Invoice Header";
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

    trigger OnPreReport()
    begin
        if InvoiceNo_gCode = '' then
          exit;
    end;

    var
        InvoiceNo_gCode: Code[20];

    local procedure GetInvoice_gFnc(): Code[20]
    begin
        exit(InvoiceNo_gCode);
    end;
}

