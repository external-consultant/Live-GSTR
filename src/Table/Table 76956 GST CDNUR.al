Table 76956 "GST CDNUR"
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
        field(76955; "UR Type"; Option)
        {
            OptionCaption = 'B2CL,EXPWP,EXPWOP';
            OptionMembers = B2CL,EXPWP,EXPWOP;
        }
        field(76956; "Note/Refund Voucher Number"; Code[20])
        {
        }
        field(76957; "Note/Refund Voucher date"; Date)
        {
        }
        field(76958; "Document Type"; Option)
        {
            OptionCaption = 'C,D,R';
            OptionMembers = C,D,R;
        }
        field(76959; "Invoice/Advance Receipt Number"; Code[20])
        {
        }
        field(76960; "Invoice/Advance Receipt date"; Date)
        {
        }
        field(76961; "Reason For Issuing document"; Text[100])
        {
        }
        field(76962; "Place Of Supply"; Text[100])
        {
        }
        field(76963; "Note/Refund Voucher Value"; Decimal)
        {
            BlankZero = true;
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
        field(76967; "Pre GST"; Option)
        {
            OptionCaption = 'N,Y';
            OptionMembers = N,Y;
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

