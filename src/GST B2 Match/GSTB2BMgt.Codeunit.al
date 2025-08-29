Codeunit 76952 "GSTB2B Mgt."
{
    Permissions = TableData "G/L Entry" = rmd,
                  TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm;

    trigger OnRun()
    var
        PurchInvHeader_lrec: Record "Purch. Inv. Header";
        GLEntry: Record "G/L Entry";
    begin
        /*
        PurchInvHeader_lrec.RESET;
        PurchInvHeader_lrec.SETFILTER("GSTR-1/IFF/GSTR-5 Period",'<>%1','');
        IF PurchInvHeader_lrec.FINDSET THEN BEGIN
          REPEAT
            PurchInvHeader_lrec."GSTR-1/IFF/GSTR-5 Period" := '';
            PurchInvHeader_lrec.MODIFY(TRUE);
          UNTIL PurchInvHeader_lrec.NEXT =0;
        END;
        
        GLEntry.RESET;
        GLEntry.SETFILTER("Entry No.",'6019070..6019077');
        GLEntry.SETRANGE(Description,'PI/21-22/08462');
        IF GLEntry.FINDSET THEN
          GLEntry.DELETEALL;
          */

        Message('Done');

    end;

    var
        GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
        EntryNo: Integer;
        PostingDate_gDte: Date;


    procedure MatchingInvoice_gFnc(var Rf_Month: Integer; var Rf_Year: Integer)
    var
        PurchInvHeader_lRec: Record "Purch. Inv. Header";
        PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
        Win_gDlg: Dialog;
        Counter_gInt: Integer;
        B2BMatch_lRec: Record GSTB2BXMLPort_;
        B2BTotalGST_lDec: Decimal;
        InvTotalGst_lDec: Decimal;
        DiffAmt_lDec: Decimal;
        GLEntry_lRec: Record "G/L Entry";
        Invoicefound_lbln: Boolean;
        PostingDate_lDte: Date;
    begin



        if not Confirm('Do You Want to Match Invoice ?') then
            exit;

        // SalesInvoiceHeader_lRec.RESET;
        // IF SalesInvoiceHeader_lRec.FINDSET THEN BEGIN
        //  REPEAT
        //    IF NOT SalesExt_lRec.GET(SalesInvoiceHeader_lRec."No.") THEN BEGIN
        //      CLEAR(SalesExt_lRec);
        //      SalesExt_lRec.INIT;
        //      SalesExt_lRec."No." := SalesInvoiceHeader_lRec."No.";
        //      SalesExt_lRec.INSERT;
        //    END;
        //  UNTIL SalesInvoiceHeader_lRec.NEXT = 0;
        // END;


        Counter_gInt := 0;
        Win_gDlg.Open('Matching Total #1################\Current #2##################');

        PostingDate_lDte := CalcDate('CM', Dmy2date(1, Rf_Month, Rf_Year));

        GSTB2BXMLPort_lRec.Reset;
        //GSTB2BXMLPort_lRec.SETFILTER("Entry No.",'%1|%2' ,240,239);
        //GSTB2BXMLPort_lRec.SETRANGE("Invoice Match",FALSE);
        //GSTB2BXMLPort_lRec.SETRANGE("GSTIN of supplier",'27AACPP0680K1ZJ');
        //GSTB2BXMLPort_lRec.SETRANGE("Invoice Number",'MUMCI/2645/21-22');
        if GSTB2BXMLPort_lRec.FindSet then begin
            Win_gDlg.Update(1, GSTB2BXMLPort_lRec.Count);
            repeat
                B2BTotalGST_lDec := GetTotalGSTAmount_lFnc(GSTB2BXMLPort_lRec);
                PurchInvHeader_lRec.Reset;
                PurchInvHeader_lRec.SetRange("Vendor GST Reg. No.", GSTB2BXMLPort_lRec."GSTIN of supplier");
                PurchInvHeader_lRec.SetRange("Vendor Invoice No.", GSTB2BXMLPort_lRec."Invoice Number");
                //PurchInvHeader_lRec.SETFILTER("Posting Date",'%1..%2',20210104D,20223103D);
                //PurchInvHeader_lRec.SetRange("Vendor Invoice Date", GSTB2BXMLPort_lRec."Invoice Date");
                PurchInvHeader_lRec.SetFilter("Posting Date", '..%1', PostingDate_lDte);
                //PurchInvHeader_lRec.SETRANGE(forc
                if PurchInvHeader_lRec.FindFirst then begin
                    InvTotalGst_lDec := GSTInvTotalGSTAmount_lFnc(PurchInvHeader_lRec);
                    //        PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" :=    FORMAT(Rf_Year) + '-' + FORMAT(Rf_Month);
                    //        PurchInvHeader_lRec.MODIFY;

                    //PurchInvGST_lFnc(PurchInvHeader_lRec."No.");  //T27003-NS
                    //IF PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" <> GSTB2BXMLPort_lRec."GSTR-1/IFF/GSTR-5 Period" THEN BEGIN
                    //  GSTB2BXMLPort_lRec."Invoice Match" := FALSE;
                    //  GSTB2BXMLPort_lRec."Matching Error" := 'Current Field GSTR-1/IFF/GSTR-5 Period '+ GSTB2BXMLPort_lRec."GSTR-1/IFF/GSTR-5 Period" +' Is Not Match with invoice '+PurchInvHeader_lRec."No." +'field "GSTR-1/IFF/GSTR-5 Period" '
                    //END ELSE BEGIN

                    //IF B2BTotalGST_lDec IN [InvTotalGst_lDec,InvTotalGst_lDec-1,InvTotalGst_lDec+1,ROUND(InvTotalGst_lDec,0.1,'=')] THEN BEGIN
                    DiffAmt_lDec := B2BTotalGST_lDec - InvTotalGst_lDec;
                    if (DiffAmt_lDec <= 1) and (DiffAmt_lDec >= -1) then begin
                        GSTB2BXMLPort_lRec."Invoice Match" := true;
                        GSTB2BXMLPort_lRec."Document Type" := GSTB2BXMLPort_lRec."document type"::"Purchase Invoice";
                        GSTB2BXMLPort_lRec."Matched Invoice No." := PurchInvHeader_lRec."No.";
                        GSTB2BXMLPort_lRec."Matching Error" := '';
                        GSTB2BXMLPort_lRec."Return File Month" := Format(Rf_Year) + '-' + Format(Rf_Month);
                    end else begin
                        GSTB2BXMLPort_lRec."Invoice Match" := false;
                        GSTB2BXMLPort_lRec."Matched Invoice No." := '';
                        GSTB2BXMLPort_lRec."Matching Error" := 'Total GST Amount ' + AmountFormatEmail_gFnc(B2BTotalGST_lDec) + ' is not match Invoice No. ' + PurchInvHeader_lRec."No." + ' Total Gst Amount '
                                                                + AmountFormatEmail_gFnc(InvTotalGst_lDec) + '.';
                    end;
                    //END;

                end else begin
                    PurchCrMemoHdr_lRec.Reset;
                    PurchCrMemoHdr_lRec.SetRange("Vendor GST Reg. No.", GSTB2BXMLPort_lRec."GSTIN of supplier");
                    PurchCrMemoHdr_lRec.SetRange("Vendor Cr. Memo No.", GSTB2BXMLPort_lRec."Invoice Number");
                    PurchCrMemoHdr_lRec.SetFilter("Posting Date", '..%1', PostingDate_lDte);
                    //PurchInvHeader_lRec.SETFILTER("Posting Date",'%1..%2',20210104D,20223103D);
                    //      PurchCrMemoHdr_lRec.SETRANGE("Vendor Invoice Date",GSTB2BXMLPort_lRec."Invoice Date");
                    if PurchCrMemoHdr_lRec.FindFirst then begin
                        InvTotalGst_lDec := GSTCrTotalGSTAmount_lFnc(PurchCrMemoHdr_lRec);
                        //        PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" :=    FORMAT(Rf_Year) + '-' + FORMAT(Rf_Month);
                        //        PurchCrMemoHdr_lRec.MODIFY;

                        //PurchInvGST_lFnc(PurchInvHeader_lRec."No.");  //T27003-NS
                        //IF PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" <> GSTB2BXMLPort_lRec."GSTR-1/IFF/GSTR-5 Period" THEN BEGIN
                        //  GSTB2BXMLPort_lRec."Invoice Match" := FALSE;
                        //  GSTB2BXMLPort_lRec."Matching Error" := 'Current Field GSTR-1/IFF/GSTR-5 Period '+ GSTB2BXMLPort_lRec."GSTR-1/IFF/GSTR-5 Period" +' Is Not Match with invoice '+PurchInvHeader_lRec."No." +'field "GSTR-1/IFF/GSTR-5 Period" '
                        //END ELSE BEGIN

                        //IF B2BTotalGST_lDec IN [InvTotalGst_lDec,InvTotalGst_lDec-1,InvTotalGst_lDec+1,ROUND(InvTotalGst_lDec,0.1,'=')] THEN BEGIN
                        DiffAmt_lDec := B2BTotalGST_lDec - InvTotalGst_lDec;
                        if (DiffAmt_lDec <= 1) and (DiffAmt_lDec >= -1) then begin
                            GSTB2BXMLPort_lRec."Invoice Match" := true;
                            GSTB2BXMLPort_lRec."Document Type" := GSTB2BXMLPort_lRec."document type"::"Purchase Credit Memo";
                            GSTB2BXMLPort_lRec."Matched Invoice No." := PurchCrMemoHdr_lRec."No.";
                            GSTB2BXMLPort_lRec."Matching Error" := '';
                            GSTB2BXMLPort_lRec."Return File Month" := Format(Rf_Year) + '-' + Format(Rf_Month);
                        end else begin
                            GSTB2BXMLPort_lRec."Invoice Match" := false;
                            GSTB2BXMLPort_lRec."Matched Invoice No." := '';
                            GSTB2BXMLPort_lRec."Matching Error" := 'Total GST Amount ' + AmountFormatEmail_gFnc(B2BTotalGST_lDec) + ' is not match CreditMemo No. ' + PurchCrMemoHdr_lRec."No." + ' Total Gst Amount '
                                                                    + AmountFormatEmail_gFnc(InvTotalGst_lDec) + '.';
                        end;
                        //END;

                    end else begin
                        GSTB2BXMLPort_lRec."Invoice Match" := false;
                        GSTB2BXMLPort_lRec."Matching Error" := 'Invoice number not match.';
                    end;
                end;

                if not GSTB2BXMLPort_lRec."Invoice Match" then begin
                    InvTotalGst_lDec := 0;
                    Invoicefound_lbln := false;
                    B2BTotalGST_lDec := GetTotalGSTAmount_lFnc(GSTB2BXMLPort_lRec);
                    PurchInvHeader_lRec.Reset;
                    PurchInvHeader_lRec.SetFilter("GSTR-1/IFF/GSTR-5 Period", '=%1', '');
                    PurchInvHeader_lRec.SetRange("Vendor GST Reg. No.", GSTB2BXMLPort_lRec."GSTIN of supplier");
                    //PurchInvHeader_lRec.SetRange("Vendor Invoice Date", GSTB2BXMLPort_lRec."Invoice Date");
                    PurchInvHeader_lRec.SetFilter("Posting Date", '..%1', PostingDate_lDte);
                    if PurchInvHeader_lRec.FindSet then begin
                        repeat
                            PurchInvHeader_lRec.CalcFields("Amount Including VAT");
                            DiffAmt_lDec := B2BTotalGST_lDec - PurchInvHeader_lRec."Amount Including VAT";
                            if (DiffAmt_lDec <= 5) and (DiffAmt_lDec >= -5) then
                                Invoicefound_lbln := true;
                        until (PurchInvHeader_lRec.Next = 0) or (Invoicefound_lbln);
                    end;

                    if not Invoicefound_lbln then begin
                        GSTB2BXMLPort_lRec."Invoice Match" := false;
                        GSTB2BXMLPort_lRec."Matching Error" := 'Invoice number not found.';
                    end;
                end;


                /*
                IF GSTB2BXMLPort_lRec."Invoice Match" THEN BEGIN
                  IF GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."Document Type"::"Purchase Credit Memo" THEN BEGIN
                    GLEntry_lRec.RESET;
                    GLEntry_lRec.SETRANGE("Document No.",PurchCrMemoHdr_lRec."No.");
                    GLEntry_lRec.SETFILTER("G/L Account No.",'2300261|2300263|2300265');
                    IF GLEntry_lRec.FINDSET THEN BEGIN
                      REPEAT
                        GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                        GLEntry_lRec.MODIFY(TRUE);
                      UNTIL GLEntry_lRec.NEXT =0;
                    END;
                  END ELSE IF GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."Document Type"::"Purchase Invoice" THEN BEGIN
                    GLEntry_lRec.RESET;
                    GLEntry_lRec.SETRANGE("Document No.",PurchInvHeader_lRec."No.");
                    GLEntry_lRec.SETFILTER("G/L Account No.",'1416001|1416003|1416005');
                    IF GLEntry_lRec.FINDSET THEN BEGIN
                      REPEAT
                        GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                        GLEntry_lRec.MODIFY(TRUE);
                      UNTIL GLEntry_lRec.NEXT =0;
                    END;
                  END;
                END;
                */

                GSTB2BXMLPort_lRec.Modify;

                Counter_gInt += 1;
                Win_gDlg.Update(2, Counter_gInt);
            until GSTB2BXMLPort_lRec.Next = 0;
        end else
            Error('No record is Found ');

        Win_gDlg.Close;

    end;

    local procedure GetTotalGSTAmount_lFnc(var B2BGST_iRec: Record GSTB2BXMLPort_): Decimal
    var
        B2B_lRec: Record GSTB2BXMLPort_;
        TmpSum_gDec: Decimal;
    begin
        B2B_lRec.Reset;
        B2B_lRec.SetRange("Invoice Number", B2BGST_iRec."Invoice Number");
        B2B_lRec.SetRange("GSTIN of supplier", B2BGST_iRec."GSTIN of supplier");
        if B2B_lRec.FindSet then begin
            repeat
                TmpSum_gDec += B2B_lRec."TOTAL GST";
            until B2B_lRec.Next = 0;
        end;

        exit(TmpSum_gDec);
    end;

    local procedure GSTInvTotalGSTAmount_lFnc(SI_iRec: Record "Purch. Inv. Header"): Decimal
    var
        SIH_lRec: Record "Sales Invoice Header";
        DetailedGSTLedgerEntry_lRec: Record "Detailed GST Ledger Entry";
        TmpSum_gDec: Decimal;
    begin
        //MESSAGE(FORMAT(SI_iRec."Vendor Invoice No."));
        DetailedGSTLedgerEntry_lRec.Reset;

        DetailedGSTLedgerEntry_lRec.SetRange("Document No.", SI_iRec."No.");
        DetailedGSTLedgerEntry_lRec.SetRange("External Document No.", SI_iRec."Vendor Invoice No.");
        DetailedGSTLedgerEntry_lRec.SetRange("Transaction Type", DetailedGSTLedgerEntry_lRec."transaction type"::Purchase);
        DetailedGSTLedgerEntry_lRec.SetRange("Document Type", DetailedGSTLedgerEntry_lRec."document type"::Invoice);
        DetailedGSTLedgerEntry_lRec.SetRange("Buyer/Seller Reg. No.", SI_iRec."Vendor GST Reg. No.");
        if DetailedGSTLedgerEntry_lRec.FindSet then begin
            repeat
                TmpSum_gDec += Abs(DetailedGSTLedgerEntry_lRec."GST Amount");
            until DetailedGSTLedgerEntry_lRec.Next = 0;
        end;

        exit(TmpSum_gDec);
    end;

    local procedure GSTCrTotalGSTAmount_lFnc(SI_iRec: Record "Purch. Cr. Memo Hdr."): Decimal
    var
        DetailedGSTLedgerEntry_lRec: Record "Detailed GST Ledger Entry";
        TmpSum_gDec: Decimal;
    begin
        //MESSAGE(FORMAT(SI_iRec."Vendor Invoice No."));
        DetailedGSTLedgerEntry_lRec.Reset;

        DetailedGSTLedgerEntry_lRec.SetRange("Document No.", SI_iRec."No.");
        DetailedGSTLedgerEntry_lRec.SetRange("External Document No.", SI_iRec."Vendor Cr. Memo No.");
        DetailedGSTLedgerEntry_lRec.SetRange("Transaction Type", DetailedGSTLedgerEntry_lRec."transaction type"::Purchase);
        DetailedGSTLedgerEntry_lRec.SetRange("Document Type", DetailedGSTLedgerEntry_lRec."document type"::"Credit Memo");
        DetailedGSTLedgerEntry_lRec.SetRange("Buyer/Seller Reg. No.", SI_iRec."Vendor GST Reg. No.");
        if DetailedGSTLedgerEntry_lRec.FindSet then begin
            repeat
                TmpSum_gDec += Abs(DetailedGSTLedgerEntry_lRec."GST Amount");
            until DetailedGSTLedgerEntry_lRec.Next = 0;
        end;

        exit(TmpSum_gDec);
    end;


    procedure ManuallyMatch_gFnc(var B2BGST_vRec: Record GSTB2BXMLPort_; Rf_Month: Integer; Rf_Year: Integer)
    var
        SelectInvoice_lRpt: Report "Select Invoice";
        GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
        PurInv_lrec: Record "Purch. Inv. Header";
        GLEntry_lRec: Record "G/L Entry";
        PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
        GSTPostingSetup_lRec: Record "GST Posting Setup";
    begin


        GSTB2BXMLPort_lRec.Reset;
        GSTB2BXMLPort_lRec.SetRange("Invoice Match", false);
        //GSTB2BXMLPort_lRec.SETRANGE("Forced Match",FALSE);
        //GSTB2BXMLPort_lRec.SETFILTER("Force Match Invoice No.",'<>%1','');
        GSTB2BXMLPort_lRec.SetFilter("Matched Invoice No.", '=%1', '');
        if GSTB2BXMLPort_lRec.FindSet then begin
            repeat
                if (GSTB2BXMLPort_lRec."Force Match Invoice No." <> '') then begin
                    if GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."document type"::"Purchase Invoice" then begin
                        PurInv_lrec.Reset;
                        PurInv_lrec.SetRange("No.", GSTB2BXMLPort_lRec."Force Match Invoice No.");
                        if PurInv_lrec.FindFirst then begin
                            //GSTB2BXMLPort_lRec.TESTFIELD("Force Match Invoice No.");
                            GSTB2BXMLPort_lRec.TestField("Matched Invoice No.", '');

                            GSTB2BXMLPort_lRec."Matched Invoice No." := GSTB2BXMLPort_lRec."Force Match Invoice No.";
                            GSTB2BXMLPort_lRec."Matching Error" := '';
                            GSTB2BXMLPort_lRec."Invoice Match" := true;
                            GSTB2BXMLPort_lRec."Forced Match" := true;
                            GSTB2BXMLPort_lRec."Return File Month" := Format(Rf_Year) + '-' + Format(Rf_Month);
                            GSTB2BXMLPort_lRec.Modify;
                            /*
                            PurInv_lrec."GSTR-1/IFF/GSTR-5 Period" := FORMAT(Rf_Year) + '-' + FORMAT(Rf_Month);
                            PurInv_lrec.MODIFY;

                            //PurchInvGST_lFnc(PurInv_lrec."No.");  //T27003-N

                            IF GSTB2BXMLPort_lRec."Invoice Match" THEN BEGIN
                              GSTPostingSetup_lRec.RESET;
                              IF GSTPostingSetup_lRec.FINDSET THEN BEGIN
                                REPEAT
                                  GLEntry_lRec.RESET;
                                  GLEntry_lRec.SETRANGE("Document No.",PurInv_lrec."No.");
                                  GLEntry_lRec.SETRANGE("G/L Account No.",GSTPostingSetup_lRec."Receivable Account");
                                  IF GLEntry_lRec.FINDSET THEN BEGIN
                                    REPEAT
                                      GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                                      GLEntry_lRec.MODIFY(TRUE);
                                    UNTIL GLEntry_lRec.NEXT =0;
                                  END;
                                UNTIL GSTPostingSetup_lRec.NEXT =0;
                              END;
                            END;
                            */
                        end;
                    end else begin
                        PurchCrMemoHdr_lRec.Reset;
                        PurchCrMemoHdr_lRec.SetRange("No.", GSTB2BXMLPort_lRec."Force Match Invoice No.");
                        if PurchCrMemoHdr_lRec.FindFirst then begin
                            //GSTB2BXMLPort_lRec.TESTFIELD("Force Match Invoice No.");
                            GSTB2BXMLPort_lRec.TestField("Matched Invoice No.", '');

                            GSTB2BXMLPort_lRec."Matched Invoice No." := GSTB2BXMLPort_lRec."Force Match Invoice No.";
                            GSTB2BXMLPort_lRec."Matching Error" := '';
                            GSTB2BXMLPort_lRec."Invoice Match" := true;
                            GSTB2BXMLPort_lRec."Forced Match" := true;
                            GSTB2BXMLPort_lRec."Return File Month" := Format(Rf_Year) + '-' + Format(Rf_Month);
                            GSTB2BXMLPort_lRec.Modify;
                            /*
                            PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" := FORMAT(Rf_Year) + '-' + FORMAT(Rf_Month);
                            PurchCrMemoHdr_lRec.MODIFY;

                            //PurchInvGST_lFnc(PurInv_lrec."No.");  //T27003-N
                            IF GSTB2BXMLPort_lRec."Invoice Match" THEN BEGIN
                              GSTPostingSetup_lRec.RESET;
                              IF GSTPostingSetup_lRec.FINDSET THEN BEGIN
                                REPEAT
                                  GLEntry_lRec.RESET;
                                  GLEntry_lRec.SETRANGE("Document No.",PurchCrMemoHdr_lRec."No.");
                                  GLEntry_lRec.SETRANGE("G/L Account No.",GSTPostingSetup_lRec."Receivable Account");
                                  IF GLEntry_lRec.FINDSET THEN BEGIN
                                    REPEAT
                                      GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                                      GLEntry_lRec.MODIFY(TRUE);
                                    UNTIL GLEntry_lRec.NEXT =0;
                                  END;
                                UNTIL GSTPostingSetup_lRec.NEXT =0;
                              END;
                            END;
                            */
                        end;
                    end;
                end else
                    if (GSTB2BXMLPort_lRec."Forced Match Remarks" <> '') then begin
                        GSTB2BXMLPort_lRec.TestField("Forced Match Remarks");
                        GSTB2BXMLPort_lRec."Invoice Match" := true;
                        GSTB2BXMLPort_lRec."Forced Match" := true;
                        GSTB2BXMLPort_lRec."Return File Month" := Format(Rf_Year) + '-' + Format(Rf_Month);
                        GSTB2BXMLPort_lRec.Modify;
                    end;
            until GSTB2BXMLPort_lRec.Next = 0;
        end;

    end;


    procedure UndoMatch_gFnc(var B2BGST_vRec: Record GSTB2BXMLPort_; EntryNo: Integer)
    var
        SelectInvoice_lRpt: Report "Select Invoice";
        GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
        Purinv_lrec: Record "Purch. Inv. Header";
        PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
    begin

        GSTB2BXMLPort_lRec.Reset;
        GSTB2BXMLPort_lRec.SetRange("Invoice Match", true);
        //GSTB2BXMLPort_lRec.SETFILTER("Matched Invoice No.",'<>%1','');
        GSTB2BXMLPort_lRec.SetRange("Entry No.", B2BGST_vRec."Entry No.");
        if GSTB2BXMLPort_lRec.FindFirst then begin
            if (GSTB2BXMLPort_lRec."Matched Invoice No." <> '') or (GSTB2BXMLPort_lRec."Forced Match Remarks" <> '') then begin
                GSTB2BXMLPort_lRec."Matched Invoice No." := '';
                GSTB2BXMLPort_lRec."Matching Error" := '';
                GSTB2BXMLPort_lRec."Invoice Match" := false;
                GSTB2BXMLPort_lRec."Forced Match" := false;
                GSTB2BXMLPort_lRec."Return File Month" := '';
                GSTB2BXMLPort_lRec."Forced Match Remarks" := '';
                GSTB2BXMLPort_lRec.Modify;

                if (GSTB2BXMLPort_lRec."Forced Match Remarks" = '') then begin
                    if GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."document type"::"Purchase Invoice" then begin
                        Purinv_lrec.Reset;
                        Purinv_lrec.SetRange("No.", B2BGST_vRec."Matched Invoice No.");
                        if Purinv_lrec.FindFirst then begin
                            Purinv_lrec."GSTR-1/IFF/GSTR-5 Period" := '';
                            Purinv_lrec.Modify;
                        end else
                            Error('Purchase Invoice Not Found');
                    end else
                        if GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."document type"::"Purchase Credit Memo" then begin
                            PurchCrMemoHdr_lRec.Reset;
                            PurchCrMemoHdr_lRec.SetRange("No.", B2BGST_vRec."Matched Invoice No.");
                            if PurchCrMemoHdr_lRec.FindFirst then begin
                                PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" := '';
                                PurchCrMemoHdr_lRec.Modify;
                            end else begin
                                Error('Purchase Credit Memo Not Found');
                            end;
                        end;
                end;
            end;
        end;
    end;


    procedure PostMatch_gFnc(var B2BGST_vRec: Record GSTB2BXMLPort_; Rf_Month: Integer; Rf_Year: Integer)
    var
        SelectInvoice_lRpt: Report "Select Invoice";
        GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
        PurInv_lrec: Record "Purch. Inv. Header";
        PurchInvHeader_lRec: Record "Purch. Inv. Header";
        GSTPostingSetup_lRec: Record "GST Posting Setup";
        GLEntry_lRec: Record "G/L Entry";
        PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
        PostDocument_lBln: Boolean;
    begin
        GSTB2BXMLPort_lRec.Reset;

        GSTB2BXMLPort_lRec.CopyFilters(B2BGST_vRec);

        GSTB2BXMLPort_lRec.SetRange("Invoice Match", true);
        //GSTB2BXMLPort_lRec.SETFILTER("Matched Invoice No.",'<>%1','');
        GSTB2BXMLPort_lRec.SetRange("Return File Month", Format(Rf_Year) + '-' + Format(Rf_Month));
        if GSTB2BXMLPort_lRec.FindSet then begin
            repeat
                if (GSTB2BXMLPort_lRec."Matched Invoice No." <> '') or (GSTB2BXMLPort_lRec."Forced Match Remarks" <> '') then begin
                    if GSTB2BXMLPort_lRec."Matched Invoice No." <> '' then begin
                        PostDocument_lBln := false;
                        if GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."document type"::"Purchase Invoice" then begin
                            PurchInvHeader_lRec.Get(GSTB2BXMLPort_lRec."Matched Invoice No.");
                            if PurchInvHeader_lRec."Posting Date" <= PostingDate_gDte then begin
                                PostDocument_lBln := true;
                                if PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" = '' then
                                    PurchInvGST_lFnc(GSTB2BXMLPort_lRec."Matched Invoice No.", true);  //T27003-N


                                PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" := Format(Rf_Year) + '-' + Format(Rf_Month);
                                PurchInvHeader_lRec.Modify;

                                GSTPostingSetup_lRec.Reset;
                                if GSTPostingSetup_lRec.FindSet then begin
                                    repeat
                                        GLEntry_lRec.Reset;
                                        GLEntry_lRec.SetRange("Document No.", PurchInvHeader_lRec."No.");
                                        GLEntry_lRec.SetRange("G/L Account No.", GSTPostingSetup_lRec."Receivable Account");
                                        if GLEntry_lRec.FindSet then begin
                                            repeat
                                                GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                                                GLEntry_lRec.Modify(true);
                                            until GLEntry_lRec.Next = 0;
                                        end;
                                    until GSTPostingSetup_lRec.Next = 0;
                                end;
                            end;
                        end else
                            if GSTB2BXMLPort_lRec."Document Type" = GSTB2BXMLPort_lRec."document type"::"Purchase Credit Memo" then begin
                                PurchCrMemoHdr_lRec.Get(GSTB2BXMLPort_lRec."Matched Invoice No.");
                                if PurchCrMemoHdr_lRec."Posting Date" <= PostingDate_gDte then begin
                                    PostDocument_lBln := true;
                                    if PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" = '' then
                                        PurchInvGST_lFnc(GSTB2BXMLPort_lRec."Matched Invoice No.", false);  //T27003-N


                                    PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" := Format(Rf_Year) + '-' + Format(Rf_Month);
                                    PurchCrMemoHdr_lRec.Modify;

                                    //PurchInvGST_lFnc(PurInv_lrec."No.");  //T27003-N
                                    GSTPostingSetup_lRec.Reset;
                                    if GSTPostingSetup_lRec.FindSet then begin
                                        repeat
                                            GLEntry_lRec.Reset;
                                            GLEntry_lRec.SetRange("Document No.", PurchCrMemoHdr_lRec."No.");
                                            GLEntry_lRec.SetRange("G/L Account No.", GSTPostingSetup_lRec."Receivable Account");
                                            if GLEntry_lRec.FindSet then begin
                                                repeat
                                                    GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTB2BXMLPort_lRec."Return File Month";
                                                    GLEntry_lRec.Modify(true);
                                                until GLEntry_lRec.Next = 0;
                                            end;
                                        until GSTPostingSetup_lRec.Next = 0;
                                    end;
                                end;
                            end;
                    end;
                    if PostDocument_lBln then begin
                        GSTB2BXMLPort_lRec.Post := true;
                        GSTB2BXMLPort_lRec.Modify;
                    end;
                end;
            until GSTB2BXMLPort_lRec.Next = 0;
        end;
    end;

    local procedure AmountFormatEmail_gFnc(Decimal_iDec: Decimal): Text
    begin
        exit(Format(ROUND(Decimal_iDec, 0.01), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'));  //T2897
    end;

    local procedure "---ReverseGST-----"()
    begin
    end;

    local procedure PurchInvGST_lFnc(InvoicenNo: Code[20]; Invoice: Boolean)
    var
        GLEntry_lRec: Record "G/L Entry";
        PurchInvHeader_lRec: Record "Purch. Inv. Header";
        GSTPostingSetup_lRec: Record "GST Posting Setup";
        DocumentNo_lCod: Code[20];
        PurchSetup_lRec: Record "Purchases & Payables Setup";
        NoSeriesManagement_lCdu: Codeunit NoSeriesManagement;
        PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
    begin
        if Invoice then begin
            if not PurchInvHeader_lRec.Get(InvoicenNo) then
                exit;

            if PurchInvHeader_lRec."Posting Date" > PostingDate_gDte then
                exit;
        end else begin
            if not PurchCrMemoHdr_lRec.Get(InvoicenNo) then
                exit;

            if PurchCrMemoHdr_lRec."Posting Date" > PostingDate_gDte then
                exit;
        end;

        DocumentNo_lCod := '';
        GSTPostingSetup_lRec.Reset;
        if GSTPostingSetup_lRec.FindSet then begin
            repeat
                if Invoice then begin
                    GLEntry_lRec.Reset;
                    GLEntry_lRec.SetRange("Document No.", PurchInvHeader_lRec."No.");
                    GLEntry_lRec.SetRange("G/L Account No.", GSTPostingSetup_lRec."Receivable Account");
                    if GLEntry_lRec.FindSet then begin
                        repeat
                            if DocumentNo_lCod = '' then begin
                                PurchSetup_lRec.Get;
                                PurchSetup_lRec.TestField("JV Receivable Nos.");

                                Clear(NoSeriesManagement_lCdu);
                                DocumentNo_lCod := NoSeriesManagement_lCdu.GetNextNo(PurchSetup_lRec."JV Receivable Nos.", Today, true);
                            end;

                            GSTPostingSetup_lRec.TestField("JV Recevible Account");
                            PostGenLine_lFnc(GLEntry_lRec, PurchInvHeader_lRec, DocumentNo_lCod, GSTPostingSetup_lRec."JV Recevible Account");
                        until GLEntry_lRec.Next = 0;
                    end;
                end else begin
                    GLEntry_lRec.Reset;
                    GLEntry_lRec.SetRange("Document No.", PurchCrMemoHdr_lRec."No.");
                    GLEntry_lRec.SetFilter("G/L Account No.", '%1|%2', GSTPostingSetup_lRec."Payable Account", GSTPostingSetup_lRec."Receivable Account");
                    if GLEntry_lRec.FindSet then begin
                        repeat
                            if DocumentNo_lCod = '' then begin
                                PurchSetup_lRec.Get;
                                PurchSetup_lRec.TestField("JV Receivable Nos.");

                                Clear(NoSeriesManagement_lCdu);
                                DocumentNo_lCod := NoSeriesManagement_lCdu.GetNextNo(PurchSetup_lRec."JV Receivable Nos.", Today, true);
                            end;

                            if GLEntry_lRec."G/L Account No." = GSTPostingSetup_lRec."Receivable Account" then begin
                                GSTPostingSetup_lRec.TestField("JV Recevible Account");
                                PostCreGenLine_lFnc(GLEntry_lRec, PurchCrMemoHdr_lRec, DocumentNo_lCod, GSTPostingSetup_lRec."JV Recevible Account");
                            end else
                                if GLEntry_lRec."G/L Account No." = GSTPostingSetup_lRec."Payable Account" then begin
                                    GSTPostingSetup_lRec.TestField("JV Payable Account");
                                    PostCreGenLine_lFnc(GLEntry_lRec, PurchCrMemoHdr_lRec, DocumentNo_lCod, GSTPostingSetup_lRec."JV Payable Account");
                                end;
                        until GLEntry_lRec.Next = 0;
                    end;
                end;
            until GSTPostingSetup_lRec.Next = 0;
        end;
    end;

    local procedure PostGenLine_lFnc(GLEntry_iRec: Record "G/L Entry"; PurchInvHeader_iRec: Record "Purch. Inv. Header"; DocumentNo_iCod: Code[20]; BalAccountNo_iCod: Code[20])
    var
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        with GLEntry_iRec do begin
            GenJnlLine2.Init;
            GenJnlLine2."Posting Date" := PostingDate_gDte;
            GenJnlLine2."Document Date" := "Document Date";
            GenJnlLine2.Description := PurchInvHeader_iRec."No.";
            //GenJnlLine2.Description := PurchInvHeader_iRec."Vendor Invoice No.";
            //GenJnlLine2.Description := "Posting Description";
            GenJnlLine2."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            GenJnlLine2."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            GenJnlLine2."Dimension Set ID" := "Dimension Set ID";
            GenJnlLine2."Reason Code" := "Reason Code";
            GenJnlLine2."Account Type" := GenJnlLine2."account type"::"G/L Account";
            GenJnlLine2."Account No." := "G/L Account No.";
            GenJnlLine2."Document Type" := GLEntry_iRec."Document Type";
            GenJnlLine2."Document No." := DocumentNo_iCod;
            GenJnlLine2."External Document No." := PurchInvHeader_iRec."No.";
            GenJnlLine2."Currency Code" := PurchInvHeader_iRec."Currency Code";
            GenJnlLine2.Amount := -1 * Abs(GLEntry_iRec.Amount);
            //GenJnlLine2."Amount (LCY)" := ABS(GLEntry_iRec.Amount);
            if PurchInvHeader_iRec."Currency Code" = '' then
                GenJnlLine2."Currency Factor" := 1
            else
                GenJnlLine2."Currency Factor" := PurchInvHeader_iRec."Currency Factor";
            // GenJnlLine2."Currency Factor" := GLEntry_iRec."Conversion Factor";

            GenJnlLine2."Sell-to/Buy-from No." := PurchInvHeader_iRec."Buy-from Vendor No.";
            GenJnlLine2."Bill-to/Pay-to No." := PurchInvHeader_iRec."Pay-to Vendor No.";
            GenJnlLine2."Salespers./Purch. Code" := PurchInvHeader_iRec."Purchaser Code";
            GenJnlLine2."System-Created Entry" := true;
            GenJnlLine2."Bal. Account Type" := GenJnlLine2."bal. account type"::"G/L Account";
            GenJnlLine2."Bal. Account No." := BalAccountNo_iCod;
            GenJnlLine2."Amount (LCY)" := -1 * Abs(GLEntry_iRec.Amount);
            GenJnlPostLine.RunWithCheck(GenJnlLine2);
        end;
    end;

    local procedure PostCreGenLine_lFnc(GLEntry_iRec: Record "G/L Entry"; PurchCrMemoHdr_iRec: Record "Purch. Cr. Memo Hdr."; DocumentNo_iCod: Code[20]; BalAccountNo_iCod: Code[20])
    var
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        with GLEntry_iRec do begin
            GenJnlLine2.Init;
            GenJnlLine2."Posting Date" := PostingDate_gDte;
            GenJnlLine2."Document Date" := "Document Date";
            GenJnlLine2.Description := PurchCrMemoHdr_iRec."No.";
            //GenJnlLine2.Description := PurchCrMemoHdr_iRec."Vendor Cr. Memo No.";
            //GenJnlLine2.Description := "Posting Description";
            GenJnlLine2."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            GenJnlLine2."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            GenJnlLine2."Dimension Set ID" := "Dimension Set ID";
            GenJnlLine2."Reason Code" := "Reason Code";
            GenJnlLine2."Account Type" := GenJnlLine2."account type"::"G/L Account";
            GenJnlLine2."Account No." := "G/L Account No.";
            GenJnlLine2."Document Type" := GLEntry_iRec."Document Type";
            GenJnlLine2."Document No." := DocumentNo_iCod;
            GenJnlLine2."External Document No." := PurchCrMemoHdr_iRec."No.";
            GenJnlLine2."Currency Code" := PurchCrMemoHdr_iRec."Currency Code";
            GenJnlLine2.Amount := Abs(GLEntry_iRec.Amount);
            //GenJnlLine2."Amount (LCY)" := ABS(GLEntry_iRec.Amount);
            if PurchCrMemoHdr_iRec."Currency Code" = '' then
                GenJnlLine2."Currency Factor" := 1
            else
                GenJnlLine2."Currency Factor" := PurchCrMemoHdr_iRec."Currency Factor";
            // GenJnlLine2."Currency Factor" := GLEntry_iRec."Conversion Factor";

            GenJnlLine2."Sell-to/Buy-from No." := PurchCrMemoHdr_iRec."Buy-from Vendor No.";
            GenJnlLine2."Bill-to/Pay-to No." := PurchCrMemoHdr_iRec."Pay-to Vendor No.";
            GenJnlLine2."Salespers./Purch. Code" := PurchCrMemoHdr_iRec."Purchaser Code";
            GenJnlLine2."System-Created Entry" := true;
            GenJnlLine2."Bal. Account Type" := GenJnlLine2."bal. account type"::"G/L Account";
            GenJnlLine2."Bal. Account No." := BalAccountNo_iCod;
            GenJnlLine2."Amount (LCY)" := Abs(GLEntry_iRec.Amount);
            GenJnlPostLine.RunWithCheck(GenJnlLine2);
        end;
    end;

    local procedure "--Direct Reverse to Posted Purchase Invoice---"()
    begin
    end;


    procedure DirectReversetoPostedPurchaseInvoice_gFnc(var PurchInvHeader_vRec: Record "Purch. Inv. Header")
    var
        GLEntry_lRec: Record "G/L Entry";
        GSTPostingSetup_lRec: Record "GST Posting Setup";
    begin

        if PurchInvHeader_vRec."GSTR-1/IFF/GSTR-5 Period" <> '' then
            exit;

        if PurchInvHeader_vRec."GSTR Force Matched Reversed" then
            exit;

        PurchInvGST_lFnc(PurchInvHeader_vRec."No.", true);  //T27003-N

        PurchInvHeader_vRec."GSTR-1/IFF/GSTR-5 Period" := Format(Date2dmy(PurchInvHeader_vRec."Posting Date", 3)) + '-' + Format(Date2dmy(PurchInvHeader_vRec."Posting Date", 2));
        PurchInvHeader_vRec."GSTR Force Matched Reversed" := true;
        PurchInvHeader_vRec.Modify;


        GSTPostingSetup_lRec.Reset;
        if GSTPostingSetup_lRec.FindSet then begin
            repeat
                GLEntry_lRec.Reset;
                GLEntry_lRec.SetRange("Document No.", PurchInvHeader_vRec."No.");
                GLEntry_lRec.SetRange("G/L Account No.", GSTPostingSetup_lRec."Payable Account");
                if GLEntry_lRec.FindSet then begin
                    repeat
                        GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := PurchInvHeader_vRec."GSTR-1/IFF/GSTR-5 Period";
                        GLEntry_lRec.Modify(true);
                    until GLEntry_lRec.Next = 0;
                end;
            until GSTPostingSetup_lRec.Next = 0;
        end;
    end;

    local procedure "--Direct Reverse to Posted Purchase CreditMemo---"()
    begin
    end;


    procedure DirectReversetoPostedPurchaseCreditMemo_gFnc(var PurchCrMemoHdr_vRec: Record "Purch. Cr. Memo Hdr.")
    var
        GLEntry_lRec: Record "G/L Entry";
        GSTPostingSetup_lRec: Record "GST Posting Setup";
    begin

        if PurchCrMemoHdr_vRec."GSTR-1/IFF/GSTR-5 Period" <> '' then
            exit;

        if PurchCrMemoHdr_vRec."GSTR Force Matched Reversed" then
            exit;

        PurchInvGST_lFnc(PurchCrMemoHdr_vRec."No.", false);  //T27003-N

        PurchCrMemoHdr_vRec."GSTR-1/IFF/GSTR-5 Period" := Format(Date2dmy(PurchCrMemoHdr_vRec."Posting Date", 3)) + '-' + Format(Date2dmy(PurchCrMemoHdr_vRec."Posting Date", 2));
        PurchCrMemoHdr_vRec."GSTR Force Matched Reversed" := true;
        PurchCrMemoHdr_vRec.Modify;

        GSTPostingSetup_lRec.Reset;
        if GSTPostingSetup_lRec.FindSet then begin
            repeat
                GLEntry_lRec.Reset;
                GLEntry_lRec.SetRange("Document No.", PurchCrMemoHdr_vRec."No.");
                GLEntry_lRec.SetRange("G/L Account No.", GSTPostingSetup_lRec."Receivable Account");
                if GLEntry_lRec.FindSet then begin
                    repeat
                        GLEntry_lRec."GSTR-1/IFF/GSTR-5 Period" := PurchCrMemoHdr_vRec."GSTR-1/IFF/GSTR-5 Period";
                        GLEntry_lRec.Modify(true);
                    until GLEntry_lRec.Next = 0;
                end;
            until GSTPostingSetup_lRec.Next = 0;
        end;
    end;

    local procedure "-----SetPostingDate----"()
    begin
    end;


    procedure SetPostingDate_gDte(PostingDate_iDte: Date)
    begin
        PostingDate_gDte := PostingDate_iDte;
    end;
}

