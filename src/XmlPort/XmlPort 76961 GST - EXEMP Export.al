XmlPort 76961 "GST - EXEMP Export"
{
    Caption = 'GST - EXEMP Export';
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
                XmlName = 'GSTEXEMPHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(DescriptionTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        DescriptionTitle := GSTEXEMP_gRec.FieldCaption(Description);
                    end;
                }
                textelement(NilRatedSuppliesTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NilRatedSuppliesTitle := GSTEXEMP_gRec.FieldCaption("Nil Rated Supplies");
                    end;
                }
                textelement(ExemptedTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ExemptedTitle := GSTEXEMP_gRec.FieldCaption(Exempted);
                    end;
                }
                textelement(NonGSTsuppliesTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NonGSTsuppliesTitle := GSTEXEMP_gRec.FieldCaption("Non-GST supplies");
                    end;
                }
            }
            tableelement("GST EXEMP"; "GST EXEMP")
            {
                XmlName = 'GSTEXEMP';
                SourceTableView = sorting("Entry No.");
                fieldelement(Description; "GST EXEMP".Description)
                {
                }
                textelement(NilRatedSupplies)
                {
                }
                textelement(Exempted)
                {
                }
                textelement(NonGSTsupplies)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);
                    NilRatedSupplies := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXEMP"."Nil Rated Supplies");
                    Exempted := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXEMP".Exempted);
                    NonGSTsupplies := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST EXEMP"."Non-GST supplies");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST EXEMP".Count);
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
        GSTEXEMP_gRec: Record "GST EXEMP";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

