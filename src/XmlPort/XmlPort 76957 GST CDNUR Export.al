XmlPort 76957 "GST CDNUR Export"
{
    Caption = 'GST CDNUR Export';
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
                XmlName = 'GSTCDNURHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(URTypeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        URTypeTitle := 'UR Type';
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
            tableelement("GST CDNUR"; "GST CDNUR")
            {
                XmlName = 'GSTCDNUR';
                SourceTableView = sorting("Entry No.");
                fieldelement(URType; "GST CDNUR"."UR Type")
                {
                }
                fieldelement(NoteRefundVoucherNumber; "GST CDNUR"."Note/Refund Voucher Number")
                {
                }
                textelement(NoteRefundVoucherdate)
                {
                }
                fieldelement(DocumentType; "GST CDNUR"."Document Type")
                {
                }
                fieldelement(InvoiceAdvanceReceiptNumber; "GST CDNUR"."Invoice/Advance Receipt Number")
                {
                }
                textelement(InvoiceAdvanceReceiptdate)
                {
                }
                fieldelement(ReasonForIssuingdocument; "GST CDNUR"."Reason For Issuing document")
                {
                }
                fieldelement(PlaceOfSupply; "GST CDNUR"."Place Of Supply")
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
                fieldelement(PreGST; "GST CDNUR"."Pre GST")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);
                    NoteRefundVoucherdate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST CDNUR"."Note/Refund Voucher date");
                    InvoiceAdvanceReceiptdate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST CDNUR"."Invoice/Advance Receipt date");
                    NoteRefundVoucherValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNUR"."Note/Refund Voucher Value");
                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNUR".Rate);
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNUR"."Taxable Value");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST CDNUR"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST CDNUR".Count);
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
        GSTCDNUR_gRec: Record "GST CDNUR";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

