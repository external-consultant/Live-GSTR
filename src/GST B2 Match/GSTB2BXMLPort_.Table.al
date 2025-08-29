Table 76962 GSTB2BXMLPort_
{

    fields
    {
        field(1;"Entry No.";Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            NotBlank = false;
        }
        field(20;"GSTIN of supplier";Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30;"Trade/Legal name";Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40;"Invoice Number";Code[40])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50;"Invoice Date";Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60;"Invoice Value";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70;"Taxable Value";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80;"Integrated Tax";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90;"Central Tax";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100;"State/UT Tax";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(110;"TOTAL GST";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(120;"GSTR-1/IFF/GSTR-5 Period";Text[30])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(130;"Credit Availed";Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(140;Checked;Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(145;"Document Type";Option)
        {
            DataClassification = ToBeClassified;
            Description = 'T26372';
            OptionCaption = 'Purchase Invoice,Purchase Credit Memo';
            OptionMembers = "Purchase Invoice","Purchase Credit Memo";
        }
        field(150;"Invoice Match";Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(160;"Matching Error";Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(170;"Matched Invoice No.";Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = if ("Document Type"=const("Purchase Invoice")) "Purch. Inv. Header"
                            else if ("Document Type"=const("Purchase Credit Memo")) "Purch. Cr. Memo Hdr.";
        }
        field(180;"Force Match Invoice No.";Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = if ("Document Type"=const("Purchase Invoice")) "Purch. Inv. Header"
                            else if ("Document Type"=const("Purchase Credit Memo")) "Purch. Cr. Memo Hdr.";

            trigger OnValidate()
            begin
                if "Force Match Invoice No." <> '' then
                  TestField("Forced Match Remarks",'');
            end;
        }
        field(190;"Forced Match";Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(191;"Return File Month";Text[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(192;Post;Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(200;"Forced Match Remarks";Text[100])
        {
            DataClassification = ToBeClassified;
            Description = 'T26372';

            trigger OnValidate()
            begin
                if "Forced Match Remarks" <> '' then
                  TestField("Force Match Invoice No.",'');
            end;
        }
        field(210;Remarks;Text[100])
        {
            DataClassification = ToBeClassified;
            Description = 'T26372';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
            Clustered = true;
        }
        key(Key2;"Invoice Number")
        {
        }
    }

    fieldgroups
    {
    }
}

