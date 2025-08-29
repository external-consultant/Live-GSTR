XmlPort 76956 "GST - CDNR Export"
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
                XmlName = 'GSTCDNRHeader';
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
                textelement(InvoiceAdvanceReceiptNumberTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceAdvanceReceiptNumberTitle := 'Invoice/Advance Receipt Number';
                    end;
                }
                textelement(InvoiceAdvanceReceiptdateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceAdvanceReceiptdateTitle := 'Invoice/Advance Receipt date';
                    end;
                }
                textelement(NoteRefundVoucherNumberTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NoteRefundVoucherNumberTitle := 'Note/Refund Voucher Number';
                    end;
                }
                textelement(NoteRefundVoucherdateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NoteRefundVoucherdateTitle := 'Note/Refund Voucher date';
                    end;
                }
                textelement(DocumentTypeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        DocumentTypeTitle := 'Document Type';
                    end;
                }
                textelement(ReasonForIssuingdocumentTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ReasonForIssuingdocumentTitle := 'Reason For Issuing document';
                    end;
                }
                textelement(PlaceOfSupplyTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PlaceOfSupplyTitle := 'Place Of Supply';
                    end;
                }
                textelement(NoteRefundVoucherValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NoteRefundVoucherValueTitle := 'Note/Refund Voucher Value';
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
                textelement(PreGSTTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PreGSTTitle := 'Pre GST';
                    end;
                }
            }
            tableelement("GST CDNR"; "GST CDNR")
            {
                XmlName = 'GSTCDNR';
                SourceTableView = sorting("Entry No.");
                fieldelement(GSTINUINRecipent; "GST CDNR"."GSTIN/UIN of Recipient")
                {
                }
                fieldelement(ReceiverName; "GST CDNR"."Receiver Name")
                {
                }
                fieldelement(InvoiceAdvanceReceiptNumber; "GST CDNR"."Invoice/Advance Receipt Number")
                {
                }
                textelement(InvoiceAdvanceReceiptdate)
                {
                }
                fieldelement(NoteRefundVoucherNumber; "GST CDNR"."Note/Refund Voucher Number")
                {
                }
                textelement(NoteRefundVoucherdate)
                {
                }
                fieldelement(DocumentType; "GST CDNR"."Document Type")
                {
                }
                fieldelement(ReasonForIssuingdocument; "GST CDNR"."Reason For Issuing document")
                {
                }
                fieldelement(PlaceOfSupply; "GST CDNR"."Place Of Supply")
                {
                }
                textelement(NoteRefundVoucherValue)
                {
                }
                textelement(Rate)
                {
                }
                textelement(TaxableValue)
                {
                }
                textelement(CessAmount)
                {
                }
                fieldelement(PreGST; "GST CDNR"."Pre GST")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);
                    InvoiceAdvanceReceiptdate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST CDNR"."Invoice/Advance Receipt date");
                    NoteRefundVoucherdate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST CDNR"."Note/Refund Voucher date");
                    NoteRefundVoucherValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNR"."Note/Refund Voucher Value");
                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNR".Rate);
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNR"."Taxable Value");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNR"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST CDNR".Count);
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
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTCDNR_gRec: Record "GST CDNR";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

