Table 76952 "GST B2B"
{

    fields
    {
        field(76951; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(76952; "GST Month"; Integer)
        {
            Editable = false;
            MaxValue = 12;
            MinValue = 1;
        }
        field(76953; "GST Year"; Integer)
        {
            Editable = false;
            MinValue = 2017;
        }
        field(76954; "GST Registration No."; Code[15])
        {
            Caption = 'GST Registration No.';
            Editable = false;
            TableRelation = "GST Registration Nos.";

            trigger OnValidate()
            var
                GSTRegistrationNos: Record "GST Registration Nos.";
            begin
            end;
        }
        field(76955; "GSTIN/UIN of Recipient"; Code[20])
        {
        }
        field(76956; "Receiver Name"; Text[100])
        {
            Description = 'V1.4';
        }
        field(76957; "Invoice Number"; Code[20])
        {
        }
        field(76958; "Invoice Date"; Date)
        {
        }
        field(76959; "Invoice Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76960; "Place of Supply"; Text[100])
        {
        }
        field(76961; "Reverse Charge"; Option)
        {
            OptionCaption = 'N,Y';
            OptionMembers = N,Y;
        }
        field(76962; "Invoice Type"; Option)
        {
            OptionCaption = 'Regular,SEZ Supplies with Payment,SEZ Supplies without Payment,Deemed Export,Intra-State supplies attracting IGST';
            OptionMembers = Regular,"SEZ Supplies with Payment","SEZ Supplies without Payment","Deemed Export","Intra-State supplies attracting IGST";
        }
        field(76963; "E-Commerce GSTIN"; Code[20])
        {
        }
        field(76964; Rate; Decimal)
        {
            BlankZero = true;
        }
        field(76965; "Taxable Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76966; "Cess Amount"; Decimal)
        {
            BlankZero = true;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "GST Month", "GST Year")
        {
        }
        key(Key3; "Invoice Number", Rate)
        {
        }
        key(Key4; "Invoice Number", "Invoice Date", Rate)
        {
        }
    }

    fieldgroups
    {
    }
}

