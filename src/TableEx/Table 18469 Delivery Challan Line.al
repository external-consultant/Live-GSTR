TableExtension 76951 "DeliveryChallanLine_T76951" extends "Delivery Challan Line"
{
    fields
    {

        //Unsupported feature: Property Modification (Data type) on "Description(Field 14)".


        //Unsupported feature: Property Insertion (Description) on "Description(Field 14)".


        //Unsupported feature: Property Modification (Data type) on ""Deliver Challan No."(Field 54)".


        //Unsupported feature: Property Insertion (Description) on ""Deliver Challan No."(Field 54)".


        //Unsupported feature: Property Modification (CalcFormula) on ""Remaining Quantity"(Field 57)".


        //Unsupported feature: Property Insertion (Description) on ""Remaining Quantity"(Field 57)".


        //Unsupported feature: Property Modification (Data type) on ""Process Description"(Field 61)".


        //Unsupported feature: Property Insertion (Description) on ""Process Description"(Field 61)".

        field(76951; "Company Bin Code"; Code[20])
        {
            Caption = 'Company Bin Code';
            Description = 'C0011-1001330';
            Editable = false;
            TableRelation = Bin.Code where("Location Code" = field("Company Location"));

            trigger OnLookup()
            var
                CompanyBinCode_lCod: Code[20];
            begin
                //I-C0011-1001330-02 NS
                TestField("Company Location");
                CompanyBinCode_lCod := '';
                CompanyBinCode_lCod := WMSManagement_gCdu.BinContentLookUp("Company Location", "Item No.", "Variant Code", "Company Zone Code"
                                                                           , "Company Bin Code");
                //I-C0011-1001330-02 NE
            end;

            trigger OnValidate()
            begin
                //I-C0011-1001330-02 NS
                if "Company Bin Code" <> '' then
                    WMSManagement_gCdu.FindBin("Company Location", "Company Bin Code", "Company Zone Code");
                //I-C0011-1001330-02 NE
            end;
        }
        field(76952; "Operation Description"; Text[50])
        {
            Description = 'C0011-1001330';
        }
        field(76953; "Description 2"; Text[30])
        {
            Description = 'C0011-1001330';
        }
        field(76954; "Company Zone Code"; Code[10])
        {
            Description = 'C0011-1001330';
            Editable = false;
            TableRelation = Zone.Code where("Location Code" = field("Company Location"));
        }
        field(76955; "Operation No."; Code[10])
        {
            Description = 'C0011-1001330';
        }
        field(76956; "Order Date"; Date)
        {
            CalcFormula = lookup("Purchase Header"."Order Date" where("No." = field("Document No.")));
            Description = 'C0011-1001330';
            Editable = false;
            FieldClass = FlowField;
        }
        field(76957; "Standard Task Code"; Code[10])
        {
            Description = 'C0011-1001330';
            TableRelation = "Standard Task";
        }
        field(76958; "Already Applied Qty."; Decimal)
        {
            CalcFormula = sum("Applied Delivery Challan"."Qty. to Consume" where("Applied Delivery Challan No." = field("Delivery Challan No."),
                                                                                  "App. Delivery Challan Line No." = field("Line No.")));
            Description = 'SubConChngV2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(76959; "GST Registration No."; Code[20])
        {
            CalcFormula = lookup(Location."GST Registration No." where(Code = field("Company Location")));
            Caption = 'GST Registration No.';
            Description = 'GSTR';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "GST Registration Nos.";

            trigger OnValidate()
            var
                GSTRegistrationNos: Record "GST Registration Nos.";
            begin
            end;
        }
        field(76960; "Subcon Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'GST_FIX 050918';
            Editable = false;
        }
        field(76961; "Created By"; Code[30])
        {
            Description = 'LogDetail';
            Editable = false;
            TableRelation = "User Setup";
        }
        field(76962; "Created DateTime"; DateTime)
        {
            Description = 'LogDetail';
            Editable = false;
        }
        field(76963; "Modified By"; Code[30])
        {
            Description = 'LogDetail';
            Editable = false;
            TableRelation = "User Setup";
        }
        field(76964; "Modified DateTime"; DateTime)
        {
            Description = 'LogDetail';
            Editable = false;
        }
    }


    //Unsupported feature: Code Modification on "UpdateExciseAmount(PROCEDURE 1280001)".

    //procedure UpdateExciseAmount();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    Exciseamount := 0;
    BEDAmount := 0;
    AEDAmount := 0;
    #4..14
    ExBusinessPostingGroup := '';
    ExProdPostingGroup := '';
    ItemapplicationEntry.SETRANGE("Inbound Item Entry No.",ItemLedgerEntry."Entry No.");
    IF ItemapplicationEntry.FIND('-') THEN
      REPEAT
        ItemLedgerEntry2.SETRANGE("Entry No.",ItemapplicationEntry."Transferred-from Entry No.");
    #21..55
      UNTIL ItemapplicationEntry.NEXT = 0
    ELSE
      ERROR(Text101,ItemLedgerEntry."Entry No.");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..17
    //ItemapplicationEntry.SETFILTER("Transferred-from Entry No.",'<>0'); //I-C0011-1001330-02-N   //SubConChngV2-O
    #18..58
    */
    //end;


    //Unsupported feature: Code Modification on "UpdateGSTChallanLine(PROCEDURE 1500004)".

    //procedure UpdateGSTChallanLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    CALCFIELDS("Remaining Quantity");
    "HSN/SAC Code" := Item."HSN/SAC Code";
    "GST Group Code" := Item."GST Group Code";
    #4..15
      ERROR(GSTStateErr,"Document No.");
    GSTGroup.GET("GST Group Code");
    DummyDeliveryChallanHeader.GET("Deliver Challan No.");
    PurchaseHeader.SETRANGE("No.",DummyDeliveryChallanHeader."Sub. order No.");
    PurchaseHeader.FINDFIRST;
    IF (PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Unregistered) AND
       (GSTJurisdiction = GSTJurisdiction::Interstate) AND
    #23..35
      ERROR(CostErr,"Item No.");

    "GST Jurisdiction Type" := GSTJurisdiction;
    "GST Base Amount" := UnitCost * "Remaining Quantity";
    "Total GST Amount" :=
      GSTManagement.CalculateGSTAmounts(
        "Deliver Challan No.","Line No.",GSTJurisdiction,GSTPerStateCode,"GST Group Code",
    #43..49
      TESTFIELD("Total GST Amount");

    MODIFY;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..18

    IF DummyDeliveryChallanHeader."Sub. order No." <> '' THEN  //GST_FIX-N
      PurchaseHeader.SETRANGE("No.",DummyDeliveryChallanHeader."Sub. order No.")
    //GST_FIX-NS
    ELSE
      PurchaseHeader.SETRANGE("No.","Subcon Order No.");
    //GST_FIX-NE

    #20..38
    //"GST Base Amount" := UnitCost * "Remaining Quantity";  //N16_GST-FIX-O Same Item 2 time than remain qty come incorrect
    "GST Base Amount" := UnitCost * Quantity;  //N16_GST-FIX-N Same Item 2 time than remain qty come incorrect
    #40..52
    */
    //end;


    //Unsupported feature: Code Modification on "GetUnitCost(PROCEDURE 1500003)".

    //procedure GetUnitCost();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ProdOrderComponent.SETRANGE("Prod. Order No.",ProdOrderNo);
    ProdOrderComponent.SETRANGE("Prod. Order Line No.",ProdOrderLineNo);
    ProdOrderComponent.SETRANGE("Item No.",ItemNo);
    IF ProdOrderComponent.FINDFIRST THEN
      EXIT(ProdOrderComponent."Unit Cost");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..3
    IF ProdOrderComponent.FINDFIRST THEN BEGIN
      ProdOrderComponent.TESTFIELD("Unit Cost");  //GST_FIX-N 050918
      EXIT(ProdOrderComponent."Unit Cost");
    END;
    */
    //end;

    var
        Loc_gRec: Record Location;
        WMSManagement_gCdu: Codeunit "WMS Management";
}

