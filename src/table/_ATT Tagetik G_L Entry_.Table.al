table 60050 "ATT Tagetik G/L Entry"
{
    Caption = 'Tagetik GL Entry', comment = 'ESP="Mov. Contabilidad Tagetik"';
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "ATT Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'ESP="Nº registro"';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "ATT Company"; Text[30])
        {
            Caption = 'Company', comment = 'ESP="Empresa"';
            DataClassification = CustomerContent;
            TableRelation = Company;
        }
        field(3; "ATT Last GL Entry No."; Integer)
        {
            Caption = 'Last GL Entry No.', comment = 'ESP="Último nº mov. contabilidad"';
            DataClassification = CustomerContent;
        }
        field(4; "ATT G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.', comment = 'ESP="Nº cuenta"';
            DataClassification = CustomerContent;
        }
        field(5; "ATT G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name', comment = 'ESP="Nombre cuenta"';
            DataClassification = CustomerContent;
        }
        field(6; "ATT Posting Date"; Date)
        {
            Caption = 'Posting Date', comment = 'ESP="Fecha registro"';
            DataClassification = CustomerContent;
        }
        field(7; "ATT Account Nature"; Code[1])
        {
            Caption = 'Account Nature', comment = 'ESP="Naturaleza cuenta"';
            DataClassification = CustomerContent;
        }
        field(8; "ATT Account Type"; Code[1])
        {
            Caption = 'Account Type', comment = 'ESP="Tipo cuenta"';
            DataClassification = CustomerContent;
        }
        field(9; "ATT Account Conv. Type"; Code[1])
        {
            Caption = 'Account Conv. Type', comment = 'ESP="Tipo conv. cuenta"';
            DataClassification = CustomerContent;
        }
        field(10; "ATT LCY Code"; Code[10])
        {
            Caption = 'LCY Code', comment = 'ESP="Divisa"';
            DataClassification = CustomerContent;
        }
        field(11; "ATT Amount"; Decimal)
        {
            Caption = 'Amount', comment = 'ESP="Importe"';
            DataClassification = CustomerContent;
        }
        field(12; "ATT Cost Center Code"; Code[20])
        {
            Caption = 'Cost Center Code', comment = 'ESP="Código centro de coste"';
            DataClassification = CustomerContent;
        }
        field(13; "ATT Cost Center Name"; Text[50])
        {
            Caption = 'Cost Center Name', comment = 'ESP="Nombre centro de coste"';
            DataClassification = CustomerContent;
        }
        field(14; "ATT IC Code"; Code[20])
        {
            Caption = 'IC Code', comment = 'ESP="Código IC"';
            DataClassification = CustomerContent;
        }
        field(15; "ATT IC Name"; Text[50])
        {
            Caption = 'IC Name', comment = 'ESP="Nombre IC"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "ATT Entry No.")
        {
            Clustered = true;
        }
        key(SK; "ATT Company", "ATT G/L Account No.", "ATT Posting Date", "ATT Cost Center Code", "ATT IC Code")
        {
        }
        key(SK_; "ATT Company", "ATT Last GL Entry No.")
        {
        }
    }
    procedure CheckTagetik()
    var
        rLTagetikLog: Record "ATT Tagetik Log";
        LocalText001_Err: Label 'There is another execution of the load process in progress. Wait for it to finish.', comment = 'ESP="Existe otra ejecución del proceso de carga en progreso. Espere a que finalice."';
    begin
        rLTagetikLog.Reset();
        rLTagetikLog.SetRange("ATT In Execution", true);
        if not rLTagetikLog.IsEmpty then Error(LocalText001_Err);
    end;
    procedure LoadTagetikGLEntries(pTagetikType: Enum "ATT Tagetik Type")
    var
        rLCompany: Record Company;
        rLGLEntry: Record "G/L Entry";
        rLGLAccount: Record "G/L Account";
        rLDimensionSetEntry: Record "Dimension Set Entry";
        rLDimensionValue: Record "Dimension Value";
        rLTagetikGLEntry: Record "ATT Tagetik G/L Entry";
        rLGLSetup: Record "General Ledger Setup";
        rLTagetikLog: Record "ATT Tagetik Log";
        vLLastEntryNo: Integer;
        vLCostCenterCode: Code[20];
        vLCostCenterName: Text[50];
        vLICCode: Code[20];
        vLICName: Text[50];
        vLGLAccountName: Text[100];
    begin
        Clear(rLTagetikLog);
        rLTagetikLog.Init();
        rLTagetikLog."ATT Init DateTime":=CurrentDateTime();
        rLTagetikLog."ATT User":=UserId();
        rLTagetikLog."ATT Tagetik Type":=pTagetikType;
        rLTagetikLog."ATT In Execution":=true;
        rLTagetikLog.Insert(true);
        Commit();
        rLCompany.Reset();
        rLCompany.SetFilter(Name, '<>%1', 'CRONUS España S.A.');
        if rLCompany.FindSet()then repeat Clear(vLLastEntryNo);
                rLTagetikGLEntry.Reset();
                rLTagetikGLEntry.SetCurrentKey("ATT Company", "ATT Last GL Entry No.");
                rLTagetikGLEntry.SetRange("ATT Company", rLCompany.Name);
                if rLTagetikGLEntry.FindLast()then vLLastEntryNo:=rLTagetikGLEntry."ATT Last GL Entry No.";
                rLGLEntry.Reset();
                rLGLEntry.ChangeCompany(rLCompany.Name);
                rLGLEntry.SetFilter("Entry No.", '%1..', vLLastEntryNo + 1);
                if rLGLEntry.FindSet()then repeat Clear(vLGLAccountName);
                        Clear(rLGLAccount);
                        rLGLAccount.ChangeCompany(rLCompany.Name);
                        rLGLAccount.Get(rLGLEntry."G/L Account No.");
                        vLGLAccountName:=rLGLAccount.Name;
                        //Dimensión centro de coste
                        Clear(vLCostCenterCode);
                        Clear(vLCostCenterName);
                        if(StrPos(rLGLEntry."Document No.", 'cierre') = 0) and (StrPos(rLGLEntry."Document No.", 'CIERRE') = 0)then begin
                            rLDimensionSetEntry.Reset();
                            rLDimensionSetEntry.ChangeCompany(rLCompany.Name);
                            rLDimensionSetEntry.SetRange("Dimension Set ID", rLGLEntry."Dimension Set ID");
                            rLDimensionSetEntry.SetRange("Dimension Code", 'CENTRO COSTE');
                            if rLDimensionSetEntry.FindFirst()then begin
                                vLCostCenterCode:=rLDimensionSetEntry."Dimension Value Code";
                                Clear(rLDimensionValue);
                                rLDimensionValue.ChangeCompany(rLCompany.Name);
                                if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", rLDimensionSetEntry."Dimension Value Code")then vLCostCenterName:=rLDimensionValue.Name;
                            end;
                        end;
                        //Dimensión IC
                        Clear(vLICCode);
                        Clear(vLICName);
                        rLDimensionSetEntry.Reset();
                        rLDimensionSetEntry.ChangeCompany(rLCompany.Name);
                        rLDimensionSetEntry.SetRange("Dimension Set ID", rLGLEntry."Dimension Set ID");
                        rLDimensionSetEntry.SetRange("Dimension Code", 'IC');
                        if rLDimensionSetEntry.FindFirst()then begin
                            vLICCode:=rLDimensionSetEntry."Dimension Value Code";
                            Clear(rLDimensionValue);
                            rLDimensionValue.ChangeCompany(rLCompany.Name);
                            if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", rLDimensionSetEntry."Dimension Value Code")then vLICName:=rLDimensionValue.Name;
                        end;
                        //Divisa
                        Clear(rLGLSetup);
                        rLGLSetup.ChangeCompany(rLCompany.Name);
                        rLGLSetup.Get();
                        rLTagetikGLEntry.Reset();
                        rLTagetikGLEntry.SetCurrentKey("ATT Company", "ATT Posting Date", "ATT Cost Center Code", "ATT IC Code");
                        rLTagetikGLEntry.SetRange("ATT Company", rLCompany.Name);
                        rLTagetikGLEntry.SetRange("ATT G/L Account No.", rLGLEntry."G/L Account No.");
                        rLTagetikGLEntry.SetRange("ATT Posting Date", rLGLEntry."Posting Date");
                        rLTagetikGLEntry.SetRange("ATT Cost Center Code", vLCostCenterCode);
                        rLTagetikGLEntry.SetRange("ATT IC Code", vLICCode);
                        if rLTagetikGLEntry.FindFirst()then begin
                            rLTagetikGLEntry."ATT Amount"+=rLGLEntry.Amount;
                            if vLGLAccountName <> '' then rLTagetikGLEntry."ATT G/L Account Name":=vLGLAccountName;
                            rLTagetikGLEntry."ATT Last GL Entry No.":=rLGLEntry."Entry No.";
                            rLTagetikGLEntry."ATT LCY Code":=rLGLSetup."LCY Code";
                            rLTagetikGLEntry."ATT Cost Center Name":=vLCostCenterName;
                            rLTagetikGLEntry."ATT IC Name":=vLICName;
                            if rLGLAccount."Income/Balance" = rLGLAccount."Income/Balance"::"Income Statement" then begin
                                rLTagetikGLEntry."ATT Account Nature":='E';
                                rLTagetikGLEntry."ATT Account Conv. Type":='6';
                            end
                            else
                            begin
                                rLTagetikGLEntry."ATT Account Nature":='P';
                                rLTagetikGLEntry."ATT Account Conv. Type":='1';
                            end;
                            rLTagetikGLEntry.Modify(false);
                        end
                        else
                        begin
                            Clear(rLTagetikGLEntry);
                            rLTagetikGLEntry.Init();
                            rLTagetikGLEntry."ATT Company":=rLCompany.Name;
                            rLTagetikGLEntry."ATT G/L Account No.":=rLGLEntry."G/L Account No.";
                            rLTagetikGLEntry."ATT G/L Account Name":=vLGLAccountName;
                            rLTagetikGLEntry."ATT Posting Date":=rLGLEntry."Posting Date";
                            rLTagetikGLEntry."ATT Cost Center Code":=vLCostCenterCode;
                            rLTagetikGLEntry."ATT Cost Center Name":=vLCostCenterName;
                            rLTagetikGLEntry."ATT IC Code":=vLICCode;
                            rLTagetikGLEntry."ATT IC Name":=vLICName;
                            rLTagetikGLEntry."ATT Amount":=rLGLEntry.Amount;
                            rLTagetikGLEntry."ATT LCY Code":=rLGLSetup."LCY Code";
                            rLTagetikGLEntry."ATT Last GL Entry No.":=rLGLEntry."Entry No.";
                            rLTagetikGLEntry."ATT Account Type":='N';
                            if rLGLAccount."Income/Balance" = rLGLAccount."Income/Balance"::"Income Statement" then begin
                                rLTagetikGLEntry."ATT Account Nature":='E';
                                rLTagetikGLEntry."ATT Account Conv. Type":='6';
                            end
                            else
                            begin
                                rLTagetikGLEntry."ATT Account Nature":='P';
                                rLTagetikGLEntry."ATT Account Conv. Type":='1';
                            end;
                            rLTagetikGLEntry.Insert(true);
                        end;
                    until rLGLEntry.Next() = 0;
                Commit();
            until rLCompany.Next() = 0;
        rLTagetikLog."ATT Ending DateTime":=CurrentDateTime();
        rLTagetikLog."ATT In Execution":=false;
        rLTagetikLog.Modify(true);
        Commit();
    end;
}
