XmlPort 76954 "GST - B2CL Export"
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
                textelement(ECommerceGSTINTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ECommerceGSTINTitle := 'E-Commerce GSTIN';
                    end;
                }
            }
            tableelement("GST B2CL"; "GST B2CL")
            {
                XmlName = 'GSTB2CL';
                SourceTableView = sorting("Entry No.");
                fieldelement(InvoiceNumber; "GST B2CL"."Invoice Number")
                {
                }
                textelement(InvoiceDate)
                {
                }
                textelement(InvoiceValue)
                {
                }
                fieldelement(PlaceofSupply; "GST B2CL"."Place of Supply")
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
                fieldelement(ECommerceGSTIN; "GST B2CL"."E-Commerce GSTIN")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);

                    InvoiceDate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST B2CL"."Invocie Date");
                    InvoiceValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2CL"."Invoice Value");
                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2CL".Rate);
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2CL"."Taxable Value");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST B2CL"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST B2CL".Count);
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
        GSTB2CL_gRec: Record "GST B2CL";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

