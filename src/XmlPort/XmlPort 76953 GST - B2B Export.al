XmlPort 76953 "GST - B2B Export"
{
    Direction = Export;
    FieldDelimiter = '<None>';
    Format = VariableText;
    RecordSeparator = '<NewLine>';
    TableSeparator = '<NewLine>';
    TextEncoding = WINDOWS;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'GSTB2BHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(GSTINUINRecipentTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GSTINUINRecipentTitle := 'GSTIN/UIN of Recipient';
                    end;
                }
                textelement(ReceiverNameTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ReceiverNameTitle := 'Receiver Name';
                    end;
                }
                textelement(InvoiceNumberTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceNumberTitle := 'Invoice Number';
                    end;
                }
                textelement(InvocieDateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvocieDateTitle := 'Invoice date';
                    end;
                }
                textelement(InvoiceValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceValueTitle := 'Invoice Value';
                    end;
                }
                textelement(PlaceofSupplyTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PlaceofSupplyTitle := 'Place Of Supply';
                    end;
                }
                textelement(ReverseChargeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ReverseChargeTitle := 'Reverse Charge';
                    end;
                }
                textelement(InvoiceTypeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceTypeTitle := 'Invoice Type';
                    end;
                }
                textelement(ECommerceGSTINTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ECommerceGSTINTitle := 'E-Commerce GSTIN';
                    end;
                }
                textelement(RateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        RateTitle := 'Rate';
                    end;
                }
                textelement(TaxableValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TaxableValueTitle := 'Taxable Value';
                    end;
                }
                textelement(CessAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CessAmountTitle := 'Cess Amount';
                    end;
                }
            }
            tableelement("GST B2B"; "GST B2B")
            {
                XmlName = 'GSTB2B';
                SourceTableView = sorting("Invoice Number", "Invoice Date", Rate);
                fieldelement(GSTINUINofRecipent; "GST B2B"."GSTIN/UIN of Recipient")
                {
                }
                fieldelement(ReceiverName; "GST B2B"."Receiver Name")
                {
                }
                fieldelement(InvoiceNumber; "GST B2B"."Invoice Number")
                {
                }
                textelement(InvoiceDate)
                {
                }
                textelement(InvoiceValue)
                {
                }
                fieldelement(PlaceofSupply; "GST B2B"."Place of Supply")
                {
                }
                fieldelement(ReverseCharge; "GST B2B"."Reverse Charge")
                {
                }
                fieldelement(InvoiceType; "GST B2B"."Invoice Type")
                {
                }
                fieldelement(ECommerceGSTIN; "GST B2B"."E-Commerce GSTIN")
                {
                }
                fieldelement(Rate; "GST B2B".Rate)
                {
                }
                textelement(TaxableValue)
                {
                }
                fieldelement(CessAmount; "GST B2B"."Cess Amount")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);
                    InvoiceValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2B"."Invoice Value");
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2B"."Taxable Value");
                    InvoiceDate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST B2B"."Invoice Date");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST B2B".Count);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        if not HideWinDialog_gBln then
            Window_gDlg.Close;
    end;

    trigger OnPreXmlPort()
    begin
        if not HideWinDialog_gBln then
            Window_gDlg.Open('Total Lines #1###########\Current Line #2##########');
    end;

    var
        GSTB2B_gRec: Record "GST B2B";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

