Codeunit 76951 "GSTR Common Function"
{

    trigger OnRun()
    begin
    end;

    var
        CreateCustLedgEntry: Record "Cust. Ledger Entry";


    procedure GSTRPlaceOfSupply_gFnc(var DetailGSTLedEntry_vRec: Record "Detailed GST Ledger Entry"): Text[100]
    var
        State_lRec: Record State;
        Location_gTxt: Text;
        PlaceofSupplyOpt_lTxt: Text;
        First2Ch_lCod: Text[2];
        Cust_lRec: Record Customer;
        Vend_lRec: Record Vendor;
        SalesInvoiceHdr_lRec: Record "Sales Invoice Header";
        ShiptoAddress_lRec: Record "Ship-to Address";
        Location_lRec: Record Location;
        Party_lRec: Record Party;
        TransShptHdr_lRec: Record "Transfer Shipment Header";
        TransRcptHdr_lRec: Record "Transfer Receipt Header";
    begin
        case DetailGSTLedEntry_vRec."GST Place of Supply" of
            DetailGSTLedEntry_vRec."gst place of supply"::"Bill-to Address":
                begin
                    //Location_gTxt := DetailGSTLedEntry_vRec."Buyer/Seller State Code";
                    if DetailGSTLedEntry_vRec."Source Type" = DetailGSTLedEntry_vRec."Source Type"::Customer then begin
                        Cust_lRec.get(DetailGSTLedEntry_vRec."Source No.");
                        Location_gTxt := Cust_lRec."State Code";
                    end Else
                        if DetailGSTLedEntry_vRec."Source Type" = DetailGSTLedEntry_vRec."Source Type"::Vendor then begin
                            Vend_lRec.get(DetailGSTLedEntry_vRec."Source No.");
                            Location_gTxt := Vend_lRec."State Code";
                        end;
                end;
            DetailGSTLedEntry_vRec."gst place of supply"::"Ship-to Address":
                begin
                    if SalesInvoiceHdr_lRec.Get(DetailGSTLedEntry_vRec."Document No.") then begin
                        if SalesInvoiceHdr_lRec."Ship-to Code" <> '' then begin
                            ShiptoAddress_lRec.get(SalesInvoiceHdr_lRec."Sell-to Customer No.", SalesInvoiceHdr_lRec."Ship-to Code");
                            Location_gTxt := ShiptoAddress_lRec.State;
                        end else begin
                            Cust_lRec.get(SalesInvoiceHdr_lRec."Sell-to Customer No.");
                            Location_gTxt := Cust_lRec."State Code";
                        end;
                    end;

                    // if DetailGSTLedEntry_vRec."Shipping Address State Code" <> '' then
                    //     Location_gTxt := DetailGSTLedEntry_vRec."Shipping Address State Code"
                    // else
                    //     Location_gTxt := DetailGSTLedEntry_vRec."Buyer/Seller State Code";
                end;
            DetailGSTLedEntry_vRec."gst place of supply"::"Location Address":
                begin
                    //Location_gTxt := DetailGSTLedEntry_vRec."Location State Code";

                    if DetailGSTLedEntry_vRec."Location Code" <> '' then begin
                        Location_lRec.Get(DetailGSTLedEntry_vRec."Location Code");
                        Location_gTxt := Location_lRec."State Code";
                    end;
                end;
            else begin
                    case DetailGSTLedEntry_vRec."Source Type" of
                        DetailGSTLedEntry_vRec."Source Type"::Customer:
                            begin
                                Cust_lRec.get(DetailGSTLedEntry_vRec."Source No.");
                                Location_gTxt := Cust_lRec."State Code";
                            end;
                        DetailGSTLedEntry_vRec."Source Type"::Vendor:
                            begin
                                Vend_lRec.get(DetailGSTLedEntry_vRec."Source No.");
                                Location_gTxt := Vend_lRec."State Code";
                            end;
                        DetailGSTLedEntry_vRec."Source Type"::Party:
                            begin
                                Party_lRec.get(DetailGSTLedEntry_vRec."Source No.");
                                Location_gTxt := Party_lRec."State";
                            end;
                        DetailGSTLedEntry_vRec."Source Type"::" ":
                            begin
                                if TransShptHdr_lRec.Get(DetailGSTLedEntry_vRec."Document No.") then begin
                                    Location_lRec.Get(TransShptHdr_lRec."Transfer-from Code");
                                    Location_gTxt := Location_lRec."State Code";
                                end else
                                    if TransRcptHdr_lRec.Get(DetailGSTLedEntry_vRec."Document No.") then begin
                                        Location_lRec.Get(TransRcptHdr_lRec."Transfer-to Code");
                                        Location_gTxt := Location_lRec."State Code";
                                    end else
                                        Error('Case is not define for GST Place of Supply %1 and Transaction Type %2', DetailGSTLedEntry_vRec."GST Place of Supply", DetailGSTLedEntry_vRec."Transaction Type");
                            end;
                        else
                            Error('Case is not define for GST Place of Supply %1', DetailGSTLedEntry_vRec."GST Place of Supply");
                    end;
                end;
        end;

        if (DetailGSTLedEntry_vRec."GST Customer Type" in [DetailGSTLedEntry_vRec."gst customer type"::"Deemed Export",
                                                           DetailGSTLedEntry_vRec."gst customer type"::"SEZ Unit",
                                                           DetailGSTLedEntry_vRec."gst customer type"::"SEZ Development"]) and
            (Location_gTxt = '')
        then begin
            First2Ch_lCod := CopyStr(DetailGSTLedEntry_vRec."Buyer/Seller Reg. No.", 1, 2);
            if First2Ch_lCod <> '' then begin
                State_lRec.Reset;
                State_lRec.SetRange("State Code (GST Reg. No.)", First2Ch_lCod);
                if State_lRec.FindFirst then
                    Location_gTxt := State_lRec.Code;
            end else
                exit;
        end;

        if Location_gTxt = '' then begin
            if (DetailGSTLedEntry_vRec."Transaction Type" = DetailGSTLedEntry_vRec."transaction type"::Sales) and (DetailGSTLedEntry_vRec."Buyer/Seller Reg. No." <> '') then begin
                First2Ch_lCod := CopyStr(DetailGSTLedEntry_vRec."Buyer/Seller Reg. No.", 1, 2);
                State_lRec.Reset;
                State_lRec.SetRange("State Code (GST Reg. No.)", First2Ch_lCod);
                State_lRec.FindFirst;
                Location_gTxt := State_lRec.Code;
            end;
        end;

        if Location_gTxt = '' then
            Error('Place of Supply not found for Entry No. %1.', DetailGSTLedEntry_vRec."Entry No.");

        State_lRec.Get(Location_gTxt);
        State_lRec.TestField(Description);
        State_lRec.TestField("State Code (GST Reg. No.)");
        PlaceofSupplyOpt_lTxt := State_lRec."State Code (GST Reg. No.)" + '-' + State_lRec.Description;
        exit(PlaceofSupplyOpt_lTxt);
    end;


    procedure ConvertDecimal_gFnc(Decimal_iDec: Decimal): Text[100]
    begin
        exit(Format(Decimal_iDec, 0, '<Precision,2:2><Standard Format,2>'))
    end;


    procedure ConvertDate_gFnc(Date_iDte: Date): Text[15]
    var
        Day_iInt: Integer;
        Month_iInt: Integer;
        Year_iInt: Integer;
        MonthTxt_lTxt: Text[3];
    begin
        if Date_iDte = 0D then
            exit;

        Day_iInt := Date2dmy(Date_iDte, 1);
        Month_iInt := Date2dmy(Date_iDte, 2);
        Year_iInt := Date2dmy(Date_iDte, 3);

        case Month_iInt of
            1:
                MonthTxt_lTxt := 'Jan';
            2:
                MonthTxt_lTxt := 'Feb';
            3:
                MonthTxt_lTxt := 'Mar';
            4:
                MonthTxt_lTxt := 'Apr';
            5:
                MonthTxt_lTxt := 'May';
            6:
                MonthTxt_lTxt := 'Jun';
            7:
                MonthTxt_lTxt := 'Jul';
            8:
                MonthTxt_lTxt := 'Aug';
            9:
                MonthTxt_lTxt := 'Sep';
            10:
                MonthTxt_lTxt := 'Oct';
            11:
                MonthTxt_lTxt := 'Nov';
            12:
                MonthTxt_lTxt := 'Dec';
        end;

        exit(Format(Day_iInt) + '-' + MonthTxt_lTxt + '-' + Format(Year_iInt));
    end;


    procedure FindInvoiceValue_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry"): Decimal
    var
        CustLedgerEntry_lRec: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry_lRec.Reset;
        CustLedgerEntry_lRec.SetRange("Document No.", DetailedGSTLedgerEntry_vRec."Document No.");
        CustLedgerEntry_lRec.SetRange("Posting Date", DetailedGSTLedgerEntry_vRec."Posting Date");
        CustLedgerEntry_lRec.FindFirst;
        CustLedgerEntry_lRec.CalcFields("Amount (LCY)");
        exit(Abs(CustLedgerEntry_lRec."Amount (LCY)"));
    end;

    procedure FindInvoiceValueforCDNUR_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry"): Decimal
    var
        CustLedgerEntry_lRec: Record "Cust. Ledger Entry";
    begin
        // CustLedgerEntry_lRec.Reset;
        // CustLedgerEntry_lRec.SetRange("Document No.", DetailedGSTLedgerEntry_vRec."Document No.");
        // CustLedgerEntry_lRec.SetRange("Posting Date", DetailedGSTLedgerEntry_vRec."Posting Date");
        // CustLedgerEntry_lRec.FindFirst;
        // CustLedgerEntry_lRec.CalcFields("Amount (LCY)");
        exit(FindAppCust_lFnc(DetailedGSTLedgerEntry_vRec));
    end;



    procedure GetHSNDescription_gFnc(HSNCode_iCod: Code[8]): Text[50]
    var
        HSNSAC_lRec: Record "HSN/SAC";
    begin
        if HSNSAC_lRec.Get(HSNCode_iCod) then begin
            HSNSAC_lRec.TestField(Description);
            exit(HSNSAC_lRec.Description)
        end else
            exit('');
    end;


    procedure GetUOMDescription_gFnc(UOMCode_iCode: Code[20]): Text[50]
    var
        UnitofMeasure_lRec: Record "Unit of Measure";
    begin
        if UnitofMeasure_lRec.Get(UOMCode_iCode) then begin
            UnitofMeasure_lRec.TestField("UQC (GST)");
            exit(UnitofMeasure_lRec."UQC (GST)")
        end else
            exit('');
    end;


    procedure GetReasonDesc_gFnc(ReasonCode_iCod: Code[10]): Text[100]
    var
        ReasonCode_lRec: Record "Reason Code";
    begin
        if ReasonCode_iCod = '' then
            exit('01-Sales Return');

        ReasonCode_lRec.Get(ReasonCode_iCod);
        ReasonCode_lRec.TestField(Description);
        exit(ReasonCode_lRec.Description);
    end;


    procedure GetReceiverName_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry"): Text[100]
    var
        Customer_lRec: Record Customer;
        GSTRegistrationNos_lRec: Record "GST Registration Nos.";
        CompanyInformation_lRec: Record "Company Information";
    begin
        if DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No." = '' then
            exit('');

        if DetailedGSTLedgerEntry_iRec."Source Type" = DetailedGSTLedgerEntry_iRec."source type"::Customer then begin
            Customer_lRec.Get(DetailedGSTLedgerEntry_iRec."Source No.");
            exit(Customer_lRec.Name);
        end;

        if GSTRegistrationNos_lRec.Get(DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No.") then begin
            CompanyInformation_lRec.Get;
            exit(CompanyInformation_lRec.Name);
        end;
    end;


    procedure GetPOSFromGSTN_gFnc(GSTNNo_iCod: Code[20]): Text[150]
    var
        State_lRec: Record State;
    begin
        if GSTNNo_iCod = '' then
            exit;

        State_lRec.Reset;
        State_lRec.SetRange("State Code (GST Reg. No.)", CopyStr(GSTNNo_iCod, 1, 2));
        State_lRec.FindFirst;
        exit(GetPOSFromState_gFnc(State_lRec.Code));
    end;


    procedure GetPOSFromState_gFnc(StateCode_iCod: Code[20]): Text[150]
    var
        State_lRec: Record State;
        PlaceofSupplyOpt_lTxt: Text[150];
    begin
        if StateCode_iCod = '' then
            exit;

        State_lRec.Get(StateCode_iCod);
        State_lRec.TestField(Description);
        State_lRec.TestField("State Code (GST Reg. No.)");
        PlaceofSupplyOpt_lTxt := State_lRec."State Code (GST Reg. No.)" + '-' + State_lRec.Description;
        exit(PlaceofSupplyOpt_lTxt);
    end;


    procedure "---------- GSTR2 --------"()
    begin
    end;


    procedure FindPurchInvoiceValue_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry"): Decimal
    var
        VendLedEntry_lRec: Record "Vendor Ledger Entry";
    begin
        VendLedEntry_lRec.Reset;
        VendLedEntry_lRec.SetRange("Document No.", DetailedGSTLedgerEntry_vRec."Document No.");
        VendLedEntry_lRec.SetRange("Posting Date", DetailedGSTLedgerEntry_vRec."Posting Date");
        VendLedEntry_lRec.FindFirst;
        VendLedEntry_lRec.CalcFields("Original Amt. (LCY)");
        exit(Abs(VendLedEntry_lRec."Original Amt. (LCY)") + Abs(VendLedEntry_lRec."Total TDS Including SHE CESS"));
    end;


    procedure GSTRPlaceOfSupplyPurch_gFnc(var DetailGSTLedEntry_vRec: Record "Detailed GST Ledger Entry"): Text[100]
    var
        State_lRec: Record State;
        Location_gTxt: Text;
        PlaceofSupplyOpt_lTxt: Text;
        Location_lRec: Record Location;
    begin
        Location_lRec.get(DetailGSTLedEntry_vRec."Location Code");

        // Location_gTxt := DetailGSTLedEntry_vRec."Location State Code";
        Location_gTxt := Location_lRec."State Code";

        if Location_gTxt = '' then
            Error('Place of Supply not found for Entry No. %1.', DetailGSTLedEntry_vRec."Entry No.");

        State_lRec.Get(Location_gTxt);
        State_lRec.TestField(Description);
        State_lRec.TestField("State Code (GST Reg. No.)");
        PlaceofSupplyOpt_lTxt := State_lRec."State Code (GST Reg. No.)" + '-' + State_lRec.Description;
        exit(PlaceofSupplyOpt_lTxt);
    end;

    local procedure "-------------- ICT 04 -----------"()
    begin
    end;


    procedure GetDateByQuarter_gFnc(Year_iInt: Integer; Quarter_iOpt: Option " ",Q1,Q2,Q3,Q4; var StartDate_vDte: Date; var EndDate_vDte: Date)
    begin
        case Quarter_iOpt of
            Quarter_iopt::Q1:
                begin
                    StartDate_vDte := Dmy2date(1, 4, Year_iInt);
                    EndDate_vDte := Dmy2date(30, 6, Year_iInt);
                end;
            Quarter_iopt::Q2:
                begin
                    StartDate_vDte := Dmy2date(1, 7, Year_iInt);
                    EndDate_vDte := Dmy2date(30, 9, Year_iInt);
                end;
            Quarter_iopt::Q3:
                begin
                    StartDate_vDte := Dmy2date(1, 10, Year_iInt);
                    EndDate_vDte := Dmy2date(31, 12, Year_iInt);
                end;
            Quarter_iopt::Q4:
                begin
                    StartDate_vDte := Dmy2date(1, 1, Year_iInt + 1);
                    EndDate_vDte := Dmy2date(31, 3, Year_iInt + 1);
                end;
            else
                Error('Please select the Quarter');
        end;
    end;


    procedure GetUOMDescriptionITC04_gFnc(UOMCode_iCod: Code[20]): Text[50]
    var
        UnitofMeasure_lRec: Record "Unit of Measure";
    begin
        if UnitofMeasure_lRec.Get(UOMCode_iCod) then
            exit(UnitofMeasure_lRec.Description)
        else
            exit('');
    end;


    //Find CLE Application
    local procedure FindAppCust_lFnc(var DetailedGSTledEntry_iRec: Record "Detailed GST Ledger Entry") RemainingPayAmount_lDec: Decimal
    var
        EntryNo_lInt: Integer;
        CLE_lRec: Record "Cust. Ledger Entry";
        SerachCustLedEntry_gRec: Record "Cust. Ledger Entry";
        DtldGSTLedgEntry_lRec: Record "Detailed GST Ledger Entry";

    begin
        RemainingPayAmount_lDec := 0;
        SerachCustLedEntry_gRec.Reset();
        SerachCustLedEntry_gRec.SetRange("Document No.", DetailedGSTledEntry_iRec."Document No.");
        SerachCustLedEntry_gRec.SetRange("Posting Date", DetailedGSTledEntry_iRec."Posting Date");
        if SerachCustLedEntry_gRec.FindFirst() then;

        CLEAR(CreateCustLedgEntry);
        IF SerachCustLedEntry_gRec."Entry No." <> 0 THEN BEGIN
            CreateCustLedgEntry := SerachCustLedEntry_gRec;

            FindApplnEntriesDtldtLedgEntry(SerachCustLedEntry_gRec);
            CLE_lRec.SETCURRENTKEY("Entry No.");
            CLE_lRec.SETRANGE("Entry No.");

            IF CreateCustLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                CLE_lRec."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
                CLE_lRec.MARK(TRUE);
            END;

            CLE_lRec.SETCURRENTKEY("Closed by Entry No.");
            CLE_lRec.SETRANGE("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
            IF CLE_lRec.FIND('-') THEN
                REPEAT
                    CLE_lRec.MARK(TRUE);
                UNTIL CLE_lRec.NEXT = 0;

            CLE_lRec.SETCURRENTKEY("Entry No.");
            CLE_lRec.SETRANGE("Closed by Entry No.");
        END;

        CLE_lRec.MARKEDONLY(TRUE);

        if CLE_lRec.FindSet() then begin
            repeat
                if CLE_lRec."Document Type" IN [CLE_lRec."Document Type"::Invoice, CLE_lRec."Document Type"::Refund] then begin
                    if CLE_lRec."Document Type" = CLE_lRec."Document Type"::Invoice then begin
                        CLE_lRec.CalcFields("Amount (LCY)");
                        RemainingPayAmount_lDec += CLE_lRec."Amount (LCY)";
                    end
                end;
            until CLE_lRec.Next = 0;
        end;
    End;

    local procedure FindApplnEntriesDtldtLedgEntry(var SerachCustLedEntry_gRec: Record "Cust. Ledger Entry")
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SETCURRENTKEY("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SETRANGE("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SETRANGE(Unapplied, FALSE);
        IF DtldCustLedgEntry1.FIND('-') THEN
            REPEAT
                IF DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                THEN BEGIN
                    DtldCustLedgEntry2.INIT;
                    DtldCustLedgEntry2.SETCURRENTKEY("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SETRANGE(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SETRANGE("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SETRANGE(Unapplied, FALSE);
                    IF DtldCustLedgEntry2.FIND('-') THEN
                        REPEAT
                            IF DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            THEN BEGIN
                                SerachCustLedEntry_gRec.SETCURRENTKEY("Entry No.");
                                SerachCustLedEntry_gRec.SETRANGE("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                IF SerachCustLedEntry_gRec.FIND('-') THEN
                                    SerachCustLedEntry_gRec.MARK(TRUE);
                            END;
                        UNTIL DtldCustLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    SerachCustLedEntry_gRec.SETCURRENTKEY("Entry No.");
                    SerachCustLedEntry_gRec.SETRANGE("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    IF SerachCustLedEntry_gRec.FIND('-') THEN
                        SerachCustLedEntry_gRec.MARK(TRUE);
                END;
            UNTIL DtldCustLedgEntry1.NEXT = 0;
    End;


}

