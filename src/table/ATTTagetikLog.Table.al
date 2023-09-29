table 60051 "ATT Tagetik Log"
{
    DataClassification = CustomerContent;
    Caption = 'Tagetik Log', comment = 'ESP="Log Tagetik"';
    DataPerCompany = false;
    fields
    {
        field(1; "ATT Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'ESP="Nº registro"';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "ATT Init DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Init DateTime', comment = 'ESP="Fecha y hora de inicio"';
        }
        field(3; "ATT Ending DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending DateTime', comment = 'ESP="Fecha y hora de finalización"';
        }
        field(4; "ATT Tagetik Type"; Enum "ATT Tagetik Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Origin', comment = 'ESP="Origen"';
        }
        field(5; "ATT User"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User', comment = 'ESP="Usuario"';
        }
        field(6; "ATT In Execution"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'In execution', comment = 'ESP="En ejecución"';
        }
    }

    keys
    {
        key(PK; "ATT Entry No.")
        {
            Clustered = true;
        }
    }
}