Table 76955 "GST CDNR"
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
        field(76957; "Invoice/Advance Receipt Number"; Code[20])
        {
        }
        field(76958; "Invoice/Advance Receipt date"; Date)
        {
        }
        field(76959; "Note/Refund Voucher Number"; Code[20])
        {
        }
        field(76960; "Note/Refund Voucher date"; Date)
        {
        }
        field(76961; "Document Type"; Option)
        {
            OptionCaption = 'C,D,R';
            OptionMembers = C,D,R;
        }
        field(76962; "Reason For Issuing document"; Text[100])
        {
        }
        field(76963; "Place Of Supply"; Text[100])
        {
        }
        field(76964; "Note/Refund Voucher Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76965; Rate; Decimal)
        {
            BlankZero = true;
        }
        field(76966; "Taxable Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76967; "Cess Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76968; "Pre GST"; Option)
        {
            OptionCaption = 'N,Y';
            OptionMembers = N,Y;
        }
        field(76969; "Invoice Type"; Option)
        {
            OptionCaption = 'Regular,SEZ Supplies with Payment,SEZ Supplies without Payment,Deemed Export,Intra-State supplies attracting IGST';
            OptionMembers = Regular,"SEZ Supplies with Payment","SEZ Supplies without Payment","Deemed Export","Intra-State supplies attracting IGST";
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
        key(Key3; "Note/Refund Voucher Number", Rate)
        {
        }
    }

    fieldgroups
    {
    }
}

