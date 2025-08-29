XmlPort 76963 "GSTB2B Import"
{
    // ------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // ------------------------------------------------------------------------------------------------
    // No.                 Date      Author
    // ------------------------------------------------------------------------------------------------
    // I-I032-550008-01    23/01/15  RaviShah
    //                     New XmlPort for Item journal Upload
    //                     Create New XMLPort to Import Item Journal Lines
    // ------------------------------------------------------------------------------------------------

    Direction = Import;
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement(GSTB2BXMLPort_;GSTB2BXMLPort_)
            {
                XmlName = 'GSTB2B';
                UseTemporary = true;
                textelement(GSTINofSupplier)
                {
                }
                textelement(TradeLegalname)
                {
                }
                textelement(InvoiceNumber)
                {
                }
                textelement(InvoiceDate)
                {
                }
                textelement(InvoiceValue)
                {
                }
                textelement(TaxableValue)
                {
                }
                textelement(IntegratedTax)
                {
                }
                textelement(CentralTax)
                {
                }
                textelement(StateUTTax)
                {
                }
                textelement(TOTALGST)
                {
                }
                textelement(GSTR1IFFGSTRPeriod)
                {
                }
                textelement(CREDITAVAILED)
                {
                }
                textelement(Checked)
                {
                }

                trigger OnAfterInitRecord()
                begin
                    RecLine_gInt += 1;

                    if RecLine_gInt = 1 then
                      currXMLport.Skip;

                    InitializeValues_gFnc();
                end;

                trigger OnBeforeInsertRecord()
                begin
                    //NU-OS
                    if RecLine_gInt = 1 then begin
                      RecLine_gInt += 1;
                      InitializeValues_gFnc();
                      currXMLport.Skip;
                    end;
                    //NU-OE
                    InsertGenJnlLine_gFnc();
                    //InitializeValues_gFnc();
                    currXMLport.Skip;
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

    trigger OnInitXmlPort()
    begin
        RecLine_gInt := 0; //NU-O
    end;

    trigger OnPostXmlPort()
    begin
        if InvoiceNoSkip_gTxt <> '' then
          Message(StrSubstNo('Invoice No Skip %1.',InvoiceNoSkip_gTxt))
        else
          Message(Text00002_gCtx)
    end;

    trigger OnPreXmlPort()
    begin
        if not Confirm(Text00001_gCtx,true) then
          exit;
        LineNo_gInt := 10000;
        RecLine_gInt := 0
    end;

    var
        Text00001_gCtx: label 'Are You Sure you want to Import  Line?';
        Text00002_gCtx: label 'All  Lines Uploaded Successfully. Please Reopen or Refersh Page.';
        ItemJnlTamplate_gRec: Record "Item Journal Template";
        ItemJnlBatches_gRec: Record "Item Journal Batch";
        ItemJnlLine_gRec: Record "Item Journal Line";
        NoSeriesMgt_gCdu: Codeunit NoSeriesManagement;
        ItemJnl1_gRec: Record "Item Journal Line";
        ReservationEntry_gRec: Record "Reservation Entry";
        ItemNo_gCod: Code[20];
        RecLine_gInt: Integer;
        LineNo_gInt: Integer;
        PostingDate_gDat: Date;
        SourceCode_gCod: Code[10];
        DocNo_gCod: Code[20];
        Qty_gDec: Decimal;
        EntryType_gOpt: Option Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output";
        UnitCost_gDec: Decimal;
        Amt_gDec: Decimal;
        ExpDate_gDte: Date;
        WarrDate_gDte: Date;
        ResEntryNo_gInt: Integer;
        ExciseEntry_gBln: Boolean;
        ExciseRecord_gOpt: Option ,RG23A,RG23C;
        DocumentDate_gDte: Date;
        LocationCode_gCod: Code[20];
        JnlTemplateName_gCod: Code[10];
        JnlBatchName_gCod: Code[10];
        GenBusPostingGrp_gCod: Code[20];
        SD1_gCod: Code[20];
        SD2_gCod: Code[20];
        SD3_gCod: Code[20];
        SD4_gCod: Code[20];
        SD5_gCod: Code[20];
        SD6_gCod: Code[20];
        SD7_gCod: Code[20];
        SD8_gCod: Code[20];
        DimMgt: Codeunit DimensionManagement;
        GSTINofSupplier_gCod: Code[50];
        TradeLegalname_gTxt: Text[100];
        InvoiceNumber_gCod: Code[20];
        InvoiceDate_gDat: Date;
        InvoiceValue_gDec: Decimal;
        IntegratedTax_gDec: Decimal;
        CentralTax_gDec: Decimal;
        StateUTTax_gDec: Decimal;
        TOTALGST_gDec: Decimal;
        GSTR1IFFGSTRPeriod_gTxt: Text;
        CREDITAVAILED_gDec: Decimal;
        Checked_gBln: Boolean;
        LastEntryNo_gInt: Integer;
        InvoiceNoSkip_gTxt: Text;
        TaxableValue_gDec: Decimal;


    procedure InitializeValues_gFnc()
    begin
        GSTINofSupplier := '';
        TradeLegalname  := '';
        InvoiceNumber   := '';
        InvoiceDate     := '';
        InvoiceValue    := '';
        TaxableValue    := '';
        IntegratedTax   := '';
        CentralTax      := '';
        StateUTTax      := '';
        TOTALGST        := '';
        GSTR1IFFGSTRPeriod := '';
        CREDITAVAILED := '';
        Checked := '';


        GSTINofSupplier_gCod := '';
        TradeLegalname_gTxt := '';
        InvoiceNumber_gCod := '';
        InvoiceDate_gDat := 0D;
        InvoiceValue_gDec := 0;
        IntegratedTax_gDec := 0;
        TaxableValue_gDec := 0;
        CentralTax_gDec := 0;
        StateUTTax_gDec := 0;
        TOTALGST_gDec := 0;
        GSTR1IFFGSTRPeriod_gTxt := '';
        CREDITAVAILED_gDec := 0;
        Checked_gBln := false;;
    end;


    procedure InsertGenJnlLine_gFnc()
    var
        GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
    begin

        Evaluate(GSTINofSupplier_gCod,GSTINofSupplier);
        if TradeLegalname <> '' then
          Evaluate(TradeLegalname_gTxt,TradeLegalname);
        if InvoiceNumber <> '' then
          Evaluate(InvoiceNumber_gCod,InvoiceNumber);

        if InvoiceDate <> '' then
          Evaluate(InvoiceDate_gDat,InvoiceDate);

        if InvoiceValue <> '' then
          Evaluate(InvoiceValue_gDec,InvoiceValue);
        if TaxableValue <> '' then
          Evaluate(TaxableValue_gDec,TaxableValue);

        if IntegratedTax <> '' then
          Evaluate(IntegratedTax_gDec,IntegratedTax);

        if CentralTax <> '' then
          Evaluate(CentralTax_gDec,CentralTax);
        if StateUTTax <> '' then
          Evaluate(StateUTTax_gDec,StateUTTax);
        if TOTALGST <> '' then
          Evaluate(TOTALGST_gDec,TOTALGST);
        if GSTR1IFFGSTRPeriod <> '' then
          Evaluate(GSTR1IFFGSTRPeriod_gTxt,GSTR1IFFGSTRPeriod);
        if CREDITAVAILED <> '' then
          Evaluate(CREDITAVAILED_gDec,CREDITAVAILED);

        if Checked in ['','No' ] then
          Checked_gBln := false;

        if Checked in ['Yes'] then
          Checked_gBln := true;


        if GSTINofSupplier_gCod = '' then
          Error('GST Place of Supplier must have value.');



        if InvoiceNumber_gCod = '' then
          Error('Invoice number Field must have value.');


        // GSTB2BXMLPort_lRec.RESET;
        // GSTB2BXMLPort_lRec.SETRANGE("Invoice Number",InvoiceNumber_gCod);
        // GSTB2BXMLPort_lRec.SETRANGE("Invoice Date",InvoiceDate_gDat);
        // IF GSTB2BXMLPort_lRec.FINDFIRST THEN
        //  ERROR('Invoice %1 is Already Exist.',InvoiceNumber_gCod);

        GSTB2BXMLPort_lRec.Reset;
        GSTB2BXMLPort_lRec.SetRange("GSTIN of supplier",GSTINofSupplier_gCod);
        GSTB2BXMLPort_lRec.SetRange("Invoice Number",InvoiceNumber_gCod);
        GSTB2BXMLPort_lRec.SetRange("Invoice Date",InvoiceDate_gDat);
        GSTB2BXMLPort_lRec.SetRange("Invoice Value",InvoiceValue_gDec);
        GSTB2BXMLPort_lRec.SetRange("TOTAL GST",TOTALGST_gDec);
        if GSTB2BXMLPort_lRec.FindFirst then begin
          if InvoiceNoSkip_gTxt = '' then
            InvoiceNoSkip_gTxt := InvoiceNumber_gCod
          else
            InvoiceNoSkip_gTxt := InvoiceNoSkip_gTxt + ',' + InvoiceNumber_gCod;
          currXMLport.Skip;
        end;

        GSTB2BXMLPort_lRec.Reset;
        if GSTB2BXMLPort_lRec.FindLast then
          LastEntryNo_gInt := GSTB2BXMLPort_lRec."Entry No.";

        LastEntryNo_gInt += 1;


        Clear(GSTB2BXMLPort_lRec);
        GSTB2BXMLPort_lRec.Init;
        GSTB2BXMLPort_lRec."Entry No." := LastEntryNo_gInt;
        GSTB2BXMLPort_lRec."GSTIN of supplier" := GSTINofSupplier_gCod;
        GSTB2BXMLPort_lRec."Trade/Legal name" := TradeLegalname_gTxt;
        GSTB2BXMLPort_lRec."Invoice Number" := InvoiceNumber_gCod;
        GSTB2BXMLPort_lRec."Invoice Date" := InvoiceDate_gDat;
        GSTB2BXMLPort_lRec."Invoice Value" := InvoiceValue_gDec;
        GSTB2BXMLPort_lRec."Taxable Value" := TaxableValue_gDec;
        GSTB2BXMLPort_lRec."Integrated Tax" := IntegratedTax_gDec;
        GSTB2BXMLPort_lRec."Central Tax" := CentralTax_gDec;
        GSTB2BXMLPort_lRec."State/UT Tax" := StateUTTax_gDec;
        GSTB2BXMLPort_lRec."TOTAL GST" := TOTALGST_gDec;
        GSTB2BXMLPort_lRec."GSTR-1/IFF/GSTR-5 Period" := GSTR1IFFGSTRPeriod_gTxt;
        GSTB2BXMLPort_lRec.Checked := Checked_gBln ;
        GSTB2BXMLPort_lRec.Insert;
    end;
}

