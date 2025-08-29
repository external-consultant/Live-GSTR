XmlPort 76958 "GST EXP Export"
{
    Caption = 'GST EXP Export';
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
                XmlName = 'GSTEXPHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(ExportTypeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ExportTypeTitle := 'Export Type';
                    end;
                }
                textelement(InvoiceNumberTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceNumberTitle := 'Invoice Number';
                    end;
                }
                textelement(InvoicedateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoicedateTitle := 'Invoice date';
                    end;
                }
                textelement(InvoiceValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        InvoiceValueTitle := 'Invoice Value';
                    end;
                }
                textelement(PortCodeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PortCodeTitle := 'Port Code';
                    end;
                }
                textelement(ShippingBillNumberTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ShippingBillNumberTitle := 'Shipping Bill Number';
                    end;
                }
                textelement(ShippingBillDateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ShippingBillDateTitle := 'Shipping Bill Date';
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
            }
            tableelement("GST EXP"; "GST EXP")
            {
                XmlName = 'GSTEXP';
                SourceTableView = sorting("Entry No.");
                fieldelement(ExportType; "GST EXP"."Export Type")
                {
                }
                fieldelement(InvoiceNumber; "GST EXP"."Invoice Number")
                {
                }
                textelement(Invoicedate)
                {
                }
                textelement(InvoiceValue)
                {
                }
                fieldelement(PortCode; "GST EXP"."Port Code")
                {
                }
                fieldelement(ShippingBillNumber; "GST EXP"."Shipping Bill Number")
                {
                }
                textelement(ShippingBillDate)
                {
                }
                textelement(Rate)
                {
                }
                textelement(TaxableValue)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);

                    Invoicedate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST EXP"."Invoice date");
                    InvoiceValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXP"."Invoice Value");
                    ShippingBillDate := GSTRCommonFunction_gCdu.ConvertDate_gFnc("GST EXP"."Shipping Bill Date");
                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXP".Rate);
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXP"."Taxable Value");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST EXP".Count);
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
        GSTEXP_gRec: Record "GST EXP";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

