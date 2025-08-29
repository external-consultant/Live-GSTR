report 76951 "GSTR All Report"
{
    // UsageCategory = ReportsAndAnalysis;
    // ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'GSTR All Report';

    dataset
    {
        dataitem("GST B2B"; "GST B2B")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Customer.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTRB2B_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTRB2B_lFnc("GST B2B");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST B2B', true);
            end;
        }
        dataitem("GST B2CL"; "GST B2CL")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTRB2CL_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTRB2CL_lFnc("GST B2CL");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST B2CL', false);
            end;
        }
        dataitem("GST B2CS"; "GST - B2CS")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTRB2CS_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTRB2CS_lFnc("GST B2CS");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST B2CS', false);
            end;
        }
        dataitem("GST CDNR"; "GST CDNR")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderCDNR_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyCDNR_lFnc("GST CDNR");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST CDNR', false);
            end;
        }
        dataitem("GST CDNUR"; "GST CDNUR")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTCDNUR_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTCDNUR_lFnc("GST CDNUR");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST CDNUR', false);
            end;
        }
        dataitem("GST EXP"; "GST EXP")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTEXP_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTEXP_lFnc("GST EXP");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST EXP', false);
            end;
        }

        dataitem("GST AT"; "GST AT")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTAT_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTAT_lFnc("GST AT");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST AT', false);
            end;
        }
        dataitem("GST ATADJ"; "GST ATADJ")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHeaderGSTATADJ_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTATADJ_lFnc("GST ATADJ");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST ATADJ', false);
            end;
        }
        dataitem("GST EXEMP"; "GST EXEMP")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHdrGSTEXEMP_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTEXEMP_lFnc("GST EXEMP");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST EXEMP', false);
            end;
        }
        dataitem("GST HSN"; "GST HSN")
        {
            DataItemTableView = SORTING("Entry No.") ORDER(Ascending);
            trigger OnPreDataItem()
            begin
                // Vendor.SetAutoCalcFields(Balance);
                MakeExcelDataHdrGSTHSN_lFnc();

                SetRange("GST Month", Month_gInt);
                SetRange("GST Year", Year_gInt);
                SetRange("GST Registration No.", GSTRegNo_gCod);
            end;

            trigger OnAfterGetRecord()
            begin
                MakeExcelDataBodyGSTHSN_lFnc("GST HSN");
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelSheet('GST HSN', false);
            end;
        }

    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(Month; Month_gInt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Month';
                    MaxValue = 12;
                    MinValue = 0;
                }
                field(Year; Year_gInt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Year';
                    MaxValue = 2099;
                    MinValue = 2017;
                }
                field("GST Register No."; GSTRegNo_gCod)
                {
                    ApplicationArea = Basic;
                    Caption = 'GST Registration No.';
                    // TableRelation = "GST Registration Nos.";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTRegnNos_lRec: Record "GST Registration Nos.";
                        GSTRegnNos_lPge: Page "GST Registration Nos.";
                    begin
                        GSTRegnNos_lRec.Reset();

                        Clear(GSTRegnNos_lPge);
                        GSTRegNo_gCod := '';
                        GSTRegnNos_lPge.LookupMode(true);
                        GSTRegnNos_lPge.SetTableView(GSTRegnNos_lRec);
                        if GSTRegnNos_lPge.RunModal() = Action::LookupOK then begin
                            GSTRegnNos_lRec.Reset();
                            GSTRegnNos_lPge.SetSelectionFilter(GSTRegnNos_lRec);
                            if GSTRegnNos_lRec.FindSet then begin
                                repeat
                                    if GSTRegNo_gCod = '' then
                                        GSTRegNo_gCod := GSTRegnNos_lRec.Code
                                    else
                                        GSTRegNo_gCod := GSTRegNo_gCod + '|' + GSTRegnNos_lRec.Code;
                                until GSTRegnNos_lRec.Next = 0;
                            end;
                        end else
                            Error('');
                    end;

                }
            }
        }

        actions
        {
        }
    }

    trigger OnInitReport()
    begin
        TempExcelBuffer.DeleteAll();
    end;

    trigger OnPreReport()
    var
        GSTB2B_lRpt: Report "GST B2B";
        GSTB2CL_lRpt: Report "GST B2CL";
        GSTCDNR_lRpt: Report "GST CDNR";
        GSTCDNUR_lRpt: Report "GST CDNUR";
        GSTEXP_lRpt: Report "GST EXP";
        GSTHSN_lRpt: Report "GST HSN";
        GSTREXEMP_lRpt: Report "GSTR EXEMP";
        GSTAT_lRpt: Report "GST AT";
        GSTATADJ_lRpt: Report "GST ATADJ";
        GSTRITCJWToMFG_lRpt: Report "GSTR ITC 04 JW To MFG";
        GSTRITCMFGToJW_lRpt: Report "GSTR ITC 04 MFG To JW";
    begin
        if Month_gInt = 0 then
            Error('Select Month to Export Data');

        if Year_gInt = 0 then
            Error('Select Year to Export Data');

        if GSTRegNo_gCod = '' then
            Error('Select GST Registration No.');

        Clear(GSTB2B_lRpt);
        GSTB2B_lRpt.UseRequestPage(false);
        GSTB2B_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTB2B_lRpt.RunModal();

        Clear(GSTB2CL_lRpt);
        GSTB2CL_lRpt.UseRequestPage(false);
        GSTB2CL_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTB2CL_lRpt.RunModal();

        Clear(GSTCDNR_lRpt);
        GSTCDNR_lRpt.UseRequestPage(false);
        GSTCDNR_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTCDNR_lRpt.RunModal();

        Clear(GSTCDNUR_lRpt);
        GSTCDNUR_lRpt.UseRequestPage(false);
        GSTCDNUR_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTCDNUR_lRpt.RunModal();

        Clear(GSTEXP_lRpt);
        GSTEXP_lRpt.UseRequestPage(false);
        GSTEXP_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTEXP_lRpt.RunModal();

        Clear(GSTHSN_lRpt);
        GSTHSN_lRpt.UseRequestPage(false);
        GSTHSN_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTHSN_lRpt.RunModal();

        Clear(GSTREXEMP_lRpt);
        GSTREXEMP_lRpt.UseRequestPage(false);
        GSTREXEMP_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTREXEMP_lRpt.RunModal();

        Clear(GSTAT_lRpt);
        GSTAT_lRpt.UseRequestPage(false);
        GSTAT_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTAT_lRpt.RunModal();

        Clear(GSTATADJ_lRpt);
        GSTATADJ_lRpt.UseRequestPage(false);
        GSTATADJ_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        GSTATADJ_lRpt.RunModal();

        // Clear(GSTRITCJWToMFG_lRpt);
        // GSTRITCJWToMFG_lRpt.UseRequestPage(false);
        // GSTRITCJWToMFG_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        // GSTRITCJWToMFG_lRpt.RunModal();

        // Clear(GSTRITCMFGToJW_lRpt);
        // GSTRITCMFGToJW_lRpt.UseRequestPage(false);
        // GSTRITCMFGToJW_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegNo_gCod, True);
        // GSTRITCMFGToJW_lRpt.RunModal();
    end;

    trigger OnPostReport()
    begin
        if GSTRCount_gInt = 0 then
            CreateExcelBook();
    end;

    //GSTR B2B
    local procedure MakeExcelDataHeaderGSTRB2B_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('GSTIN/UIN of Recipient', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Receiver Name', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Reverse Charge', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);  //NJ
        TempExcelBuffer.AddColumn('Invoice Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('E-Commerce GSTIN', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTRB2B_lFnc(GSTB2B_iRec: Record "GST B2B")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTB2B_iRec."GSTIN/UIN of Recipient", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Receiver Name", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Invoice Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Invoice Date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Invoice Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Place of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(Format(GSTB2B_iRec."Reverse Charge"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(Format(GSTB2B_iRec."Invoice Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."E-Commerce GSTIN", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2B_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2B_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
    end;

    //GSTB2CL
    local procedure MakeExcelDataHeaderGSTRB2CL_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Invoice Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);  //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('E-Commerce GSTIN', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTRB2CL_lFnc(GSTB2CL_iRec: Record "GST B2CL")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Invoice Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Invocie Date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Invoice Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Place of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTB2CL_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CL_iRec."E-Commerce GSTIN", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
    end;

    //GST B2CS
    local procedure MakeExcelDataHeaderGSTRB2CS_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('E-Commerce GSTIN', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTRB2CS_lFnc(GSTB2CS_iRec: Record "GST - B2CS")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(Format(GSTB2CS_iRec.Type), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTB2CS_iRec."Place of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTB2CS_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CS_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CS_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTB2CS_iRec."E-Commerce GSTIN", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
    end;

    //GST CDNR
    local procedure MakeExcelDataHeaderCDNR_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('GSTIN/UIN of Recipient', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Receiver Name', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Invoice/Advance Receipt Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Invoice/Advance Receipt Date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note/Refund Voucher Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note/Refund Voucher date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Document Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Reason For Issuing document', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Reverse Charge', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note Supply Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Pre GST', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyCDNR_lFnc(GSTCDNR_iRec: Record "GST CDNR")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."GSTIN/UIN of Recipient", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Receiver Name", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn(GSTCDNR_iRec."Invoice/Advance Receipt Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn(GSTCDNR_iRec."Invoice/Advance Receipt date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Note/Refund Voucher Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Note/Refund Voucher date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(Format(GSTCDNR_iRec."Document Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn(GSTCDNR_iRec."Reason For Issuing document", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Place Of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('N', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(Format(GSTCDNR_iRec."Invoice Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Note/Refund Voucher Value", false, '#,##0.00', false, false, false, '', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTCDNR_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTCDNR_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        // TempExcelBuffer.AddColumn(Format(GSTCDNR_iRec."Pre GST"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
    end;

    //GSTCDNUR
    local procedure MakeExcelDataHeaderGSTCDNUR_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('UR Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note/Refund Voucher Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note/Refund Voucher date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Document Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Invoice/Advance Receipt Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Invoice/Advance Receipt Date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Reason For Issuing document', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Note/Refund Voucher Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn('Pre GST', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTCDNUR_lFnc(GSTCDNUR_iRec: Record "GST CDNUR")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(Format(GSTCDNUR_iRec."UR Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Note/Refund Voucher Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Note/Refund Voucher date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(Format(GSTCDNUR_iRec."Document Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Invoice/Advance Receipt Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        // TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Invoice/Advance Receipt date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        // TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Reason For Issuing document", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Place Of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Note/Refund Voucher Value", false, '#,##0.00', false, false, false, '', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTCDNUR_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        // TempExcelBuffer.AddColumn(Format(GSTCDNUR_iRec."Pre GST"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataHeaderGSTEXP_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Export Type', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Invoice Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Port Code', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Shipping Bill Number', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Shipping Bill Date', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTEXP_lFnc(GSTEXP_iRec: Record "GST EXP")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(Format(GSTEXP_iRec."Export Type"), false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Invoice Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Invoice date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Invoice Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Port Code", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Shipping Bill Number", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Shipping Bill Date", false, '', false, false, false, '', TempExcelBuffer."cell type"::Date);
        TempExcelBuffer.AddColumn(GSTEXP_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTEXP_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
    end;

    local procedure MakeExcelDataHdrGSTHSN_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('HSN', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Description', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('UQC', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Total Quantity', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Total Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Taxable Value', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Integrated Tax Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Central Tax Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('State UT Tax Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTHSN_lFnc(GSTHSN_iRec: Record "GST HSN")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTHSN_iRec.HSN, false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTHSN_iRec.Description, false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTHSN_iRec.UQC, false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Total Quantity", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Total Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."GST %", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Integrated Tax Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Central Tax Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."State/UT Tax Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTHSN_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
    end;

    local procedure MakeExcelDataHdrGSTEXEMP_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Description', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Nil Rated Supplies', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Exempted', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Non GST supplies', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTEXEMP_lFnc(GSTEXEMP_iRec: Record "GST EXEMP")
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTEXEMP_iRec.Description, false, '', false, false, false, '@', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXEMP_iRec."Nil Rated Supplies", false, '', false, false, false, '@', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXEMP_iRec.Exempted, false, '', false, false, false, '@', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn(GSTEXEMP_iRec."Non-GST supplies", false, '', false, false, false, '@', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataHeaderGSTAT_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Gross Advance Received', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTAT_lFnc(GSTAT_iRec: Record "GST AT")
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTAT_iRec."Place of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTAT_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTAT_iRec."Gross Advance Received", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTAT_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
    end;

    local procedure MakeExcelDataHeaderGSTATADJ_lFnc()
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Place Of Supply', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn('Rate', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Gross Advance Adjusted', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('Cess Amount', false, '', true, false, true, '', TempExcelBuffer."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyGSTATADJ_lFnc(GSTATADJ_iRec: Record "GST ATADJ")
    begin
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(GSTATADJ_iRec."Place of Supply", false, '', false, false, false, '', TempExcelBuffer."cell type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."cell type"::Text); //NJ
        TempExcelBuffer.AddColumn(GSTATADJ_iRec.Rate, false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTATADJ_iRec."Gross Advance Adjusted", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
        TempExcelBuffer.AddColumn(GSTATADJ_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', TempExcelBuffer."cell type"::Number);
    end;

    local procedure CreateExcelBook()
    var
        TempBlob_lCdu: Codeunit "Temp Blob";
    begin
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(StrSubstNo('GSTR1_%1_%2%3', GSTRegNo_gCod, Month_gInt, Year_gInt));
        TempExcelBuffer.OpenExcel();
    end;

    procedure CreateExcelBook_Zip(var ExcelOutstream: OutStream)
    begin
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SaveToStream(ExcelOutstream, true)
    end;

    local procedure CreateExcelSheet(SheetName: Text[250]; NewBook: Boolean)
    begin
        if NewBook then
            TempExcelBuffer.CreateNewBook(SheetName)
        else
            TempExcelBuffer.SelectOrAddSheet(SheetName);
        TempExcelBuffer.WriteSheet(SheetName, CompanyName, UserId);
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    procedure SetJustFillData_gFnc(Month_iInt: Integer; Year_iInt: Integer; GSTRegNo_iCod: Text; GSTRCount_iInt: Integer)
    begin
        Month_gInt := Month_iInt;
        Year_gInt := Year_iInt;
        GSTRegNo_gCod := GSTRegNo_iCod;
        GSTRCount_gInt := GSTRCount_iInt;
    end;



    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        Month_gInt: Integer;
        Year_gInt: Integer;
        GSTRegNo_gCod: Text;
        GSTRCount_gInt: Integer;

}

