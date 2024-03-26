table 60050 "ATT Tagetik G/L Entry"
{
    Caption = 'Tagetik GL Entry', comment = 'ESP="Mov. Contabilidad Tagetik"';
    DataClassification = ToBeClassified;
    Permissions = tabledata "G/L Entry" = rimd;
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
        if not rLTagetikLog.IsEmpty then
            Error(LocalText001_Err);
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
        //+JGA Tagetik - Reclasificación movimientos CECO e IC
        rLDimension: Record Dimension;
        RecRef: RecordRef;
        FldRef: FieldRef;
        rLDecimalValue: Decimal;
        rLDateValue: date;
        //-JGA        
        vLLastEntryNo: Integer;
        vLCostCenterCode: Code[20];
        vLCostCenterName: Text[50];
        vLICCode: Code[20];
        vLICName: Text[50];
        vLGLAccountName: Text[100];
    begin
        Clear(rLTagetikLog);
        rLTagetikLog.Init();
        rLTagetikLog."ATT Init DateTime" := CurrentDateTime();
        rLTagetikLog."ATT User" := UserId();
        rLTagetikLog."ATT Tagetik Type" := pTagetikType;
        rLTagetikLog."ATT In Execution" := true;
        rLTagetikLog.Insert(true);
        Commit();

        rLCompany.Reset();
        rLCompany.SetFilter(Name, '<>%1', 'CRONUS España S.A.');
        if rLCompany.FindSet() then
            repeat
                Clear(vLLastEntryNo);
                rLTagetikGLEntry.Reset();
                rLTagetikGLEntry.SetCurrentKey("ATT Company", "ATT Last GL Entry No.");
                rLTagetikGLEntry.SetRange("ATT Company", rLCompany.Name);
                if rLTagetikGLEntry.FindLast() then
                    vLLastEntryNo := rLTagetikGLEntry."ATT Last GL Entry No.";

                rLGLEntry.Reset();
                rLGLEntry.ChangeCompany(rLCompany.Name);
                rLGLEntry.SetFilter("Entry No.", '%1..', vLLastEntryNo + 1);
                if rLGLEntry.FindSet() then
                    repeat

                        Clear(vLGLAccountName);
                        Clear(rLGLAccount);
                        rLGLAccount.ChangeCompany(rLCompany.Name);
                        rLGLAccount.Get(rLGLEntry."G/L Account No.");
                        vLGLAccountName := rLGLAccount.Name;

                        //Dimensión centro de coste
                        Clear(vLCostCenterCode);
                        Clear(vLCostCenterName);

                        if (StrPos(rLGLEntry."Document No.", 'cierre') = 0) and (StrPos(rLGLEntry."Document No.", 'CIERRE') = 0) then begin
                            rLDimensionSetEntry.Reset();
                            rLDimensionSetEntry.ChangeCompany(rLCompany.Name);
                            rLDimensionSetEntry.SetRange("Dimension Set ID", rLGLEntry."Dimension Set ID");
                            rLDimensionSetEntry.SetRange("Dimension Code", 'CENTRO COSTE');
                            if rLDimensionSetEntry.FindFirst() then begin
                                vLCostCenterCode := rLDimensionSetEntry."Dimension Value Code";

                                Clear(rLDimensionValue);
                                rLDimensionValue.ChangeCompany(rLCompany.Name);
                                if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", rLDimensionSetEntry."Dimension Value Code") then
                                    vLCostCenterName := rLDimensionValue.Name;
                            end;
                        end;

                        //Dimensión IC
                        Clear(vLICCode);
                        Clear(vLICName);

                        rLDimensionSetEntry.Reset();
                        rLDimensionSetEntry.ChangeCompany(rLCompany.Name);
                        rLDimensionSetEntry.SetRange("Dimension Set ID", rLGLEntry."Dimension Set ID");
                        rLDimensionSetEntry.SetRange("Dimension Code", 'IC');
                        if rLDimensionSetEntry.FindFirst() then begin
                            vLICCode := rLDimensionSetEntry."Dimension Value Code";

                            Clear(rLDimensionValue);
                            rLDimensionValue.ChangeCompany(rLCompany.Name);
                            if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", rLDimensionSetEntry."Dimension Value Code") then
                                vLICName := rLDimensionValue.Name;
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
                        if rLTagetikGLEntry.FindFirst() then begin
                            rLTagetikGLEntry."ATT Amount" += rLGLEntry.Amount;
                            if vLGLAccountName <> '' then
                                rLTagetikGLEntry."ATT G/L Account Name" := vLGLAccountName;

                            rLTagetikGLEntry."ATT Last GL Entry No." := rLGLEntry."Entry No.";
                            if rLGLSetup."LCY Code" = '' then
                                rLTagetikGLEntry."ATT LCY Code" := 'EUR'
                            else
                                rLTagetikGLEntry."ATT LCY Code" := rLGLSetup."LCY Code";
                            rLTagetikGLEntry."ATT Cost Center Name" := vLCostCenterName;
                            rLTagetikGLEntry."ATT IC Name" := vLICName;

                            if rLGLAccount."Income/Balance" = rLGLAccount."Income/Balance"::"Income Statement" then begin
                                rLTagetikGLEntry."ATT Account Nature" := 'E';
                                rLTagetikGLEntry."ATT Account Conv. Type" := '6';
                            end else begin
                                rLTagetikGLEntry."ATT Account Nature" := 'P';
                                rLTagetikGLEntry."ATT Account Conv. Type" := '1';
                            end;

                            rLTagetikGLEntry.Modify(false);
                        end else begin

                            Clear(rLTagetikGLEntry);
                            rLTagetikGLEntry.Init();
                            rLTagetikGLEntry."ATT Company" := rLCompany.Name;
                            rLTagetikGLEntry."ATT G/L Account No." := rLGLEntry."G/L Account No.";
                            rLTagetikGLEntry."ATT G/L Account Name" := vLGLAccountName;
                            rLTagetikGLEntry."ATT Posting Date" := rLGLEntry."Posting Date";

                            rLTagetikGLEntry."ATT Cost Center Code" := vLCostCenterCode;
                            rLTagetikGLEntry."ATT Cost Center Name" := vLCostCenterName;
                            rLTagetikGLEntry."ATT IC Code" := vLICCode;
                            rLTagetikGLEntry."ATT IC Name" := vLICName;

                            rLTagetikGLEntry."ATT Amount" := rLGLEntry.Amount;
                            if rLGLSetup."LCY Code" = '' then
                                rLTagetikGLEntry."ATT LCY Code" := 'EUR'
                            else
                                rLTagetikGLEntry."ATT LCY Code" := rLGLSetup."LCY Code";
                            rLTagetikGLEntry."ATT Last GL Entry No." := rLGLEntry."Entry No.";
                            rLTagetikGLEntry."ATT Account Type" := 'N';

                            if rLGLAccount."Income/Balance" = rLGLAccount."Income/Balance"::"Income Statement" then begin
                                rLTagetikGLEntry."ATT Account Nature" := 'E';
                                rLTagetikGLEntry."ATT Account Conv. Type" := '6';
                            end else begin
                                rLTagetikGLEntry."ATT Account Nature" := 'P';
                                rLTagetikGLEntry."ATT Account Conv. Type" := '1';
                            end;

                            rLTagetikGLEntry.Insert(true);
                        end;
                        //+JGA Tagetik - Reclasificación movimientos CECO e IC   
                        //Vamos guardando el último nº mov, por si hay que resiflicar movimientos antiguos 
                        vLLastEntryNo := rLGLEntry."Entry No.";
                    //-JGA

                    until rLGLEntry.Next() = 0;
                //+JGA Tagetik - Reclasificación movimientos CECO e IC
                //Buscamos los mov. contabilidad marcados para reclasificar, y realizamos los ajustes pertinentes
                //En el proceso de reclasificación solo se marcan los mov. contabilidad que no están en Tagetik, y que
                //tienen cambiada la dimensión CECO o la dimensión IC
                RecRef.open(Database::"G/L Entry", false);
                RecRef.ChangeCompany(rLCompany.Name);
                RecRef.CurrentKeyIndex(20); // 20 = clave "ATT Tagetik Reclass."
                FldRef := RecRef.Field(60003); // 60003 = field "ATT Tagetik Reclass."
                FldRef.SetRange(true); // Filtramos los marcados como reclasificados
                while RecRef.findset do repeat
                                            rLTagetikGLEntry.Reset();
                                            rLTagetikGLEntry.SetCurrentKey("ATT Company", "ATT Posting Date", "ATT Cost Center Code", "ATT IC Code");
                                            rLTagetikGLEntry.SetRange("ATT Company", rLCompany.Name);
                                            FldRef := RecRef.Field(rLGLEntry.FieldNo("Posting Date"));
                                            Evaluate(rLDateValue, Format(FldRef.Value));
                                            rLTagetikGLEntry.SetRange("ATT Posting Date", rLDateValue);
                                            FldRef := RecRef.Field(60004); // 60004 = field "ATT Reclass. CECO ORG"
                                            rLTagetikGLEntry.SetRange("ATT Cost Center Code", format(FldRef.Value()));
                                            FldRef := RecRef.Field(60005); // 60004 = field "ATT Reclass. IC ORG"
                                            rLTagetikGLEntry.SetRange("ATT IC Code", format(FldRef.Value()));
                                            FldRef := RecRef.Field(rLGLEntry.FieldNo("G/L Account No."));
                                            rLTagetikGLEntry.SetRange("ATT G/L Account No.", format(FldRef.Value()));
                                            IF rLTagetikGLEntry.FindLast() then begin
                                                //Descontamos el importe con el la combinación anterior
                                                FldRef := RecRef.Field(rLGLEntry.FieldNo(Amount));
                                                Evaluate(rLDecimalValue, format(FldRef.Value));
                                                rLTagetikGLEntry."ATT Amount" -= rLDecimalValue;
                                                rLTagetikGLEntry.Modify();
                                                //Añadimos el importe en la nueva combinación, si no existe la creamos                            
                                                FldRef := RecRef.Field(rLGLEntry.FieldNo("Dimension Set ID"));
                                                rLDimensionSetEntry.Reset();
                                                rLDimensionSetEntry.ChangeCompany(rLCompany.Name);
                                                Clear(vLICCode);
                                                Clear(vLICName);
                                                if rLDimensionSetEntry.Get(format(FldRef.Value()), 'IC') then begin
                                                    vLICCode := rLDimensionSetEntry."Dimension Value Code";
                                                    rLDimensionValue.ChangeCompany(rLCompany.Name);
                                                    if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", vLICCode) then vLICName := rLDimensionValue.Name;
                                                end;
                                                Clear(vLCostCenterCode);
                                                Clear(vLCostCenterName);
                                                if rLDimensionSetEntry.Get(format(FldRef.Value()), 'CENTRO COSTE') then begin
                                                    vLCostCenterCode := rLDimensionSetEntry."Dimension Value Code";
                                                    rLDimensionValue.ChangeCompany(rLCompany.Name);
                                                    if rLDimensionValue.Get(rLDimensionSetEntry."Dimension Code", vLCostCenterCode) then vLCostCenterName := rLDimensionValue.Name;
                                                end;
                                                rLTagetikGLEntry.SetRange("ATT Cost Center Code", vLCostCenterCode);
                                                rLTagetikGLEntry.SetRange("ATT IC Code", vLICCode);
                                                if rLTagetikGLEntry.FindLast() then begin
                                                    rLTagetikGLEntry."ATT Amount" += rLDecimalValue;
                                                    rLTagetikGLEntry.Modify();
                                                end
                                                else begin
                                                    Clear(rLTagetikGLEntry);
                                                    rLTagetikGLEntry."ATT Company" := rLCompany.Name;
                                                    FldRef := RecRef.Field(rLGLEntry.FieldNo("G/L Account No."));
                                                    Evaluate(rLTagetikGLEntry."ATT G/L Account No.", format(FldRef.Value));
                                                    rLGLAccount.ChangeCompany(rLCompany.Name);
                                                    rLGLAccount.Get(rLTagetikGLEntry."ATT G/L Account No.");
                                                    vLGLAccountName := rLGLAccount.Name;
                                                    rLTagetikGLEntry."ATT G/L Account Name" := vLGLAccountName;
                                                    FldRef := RecRef.Field(rLGLEntry.FieldNo("Posting Date"));
                                                    evaluate(rLTagetikGLEntry."ATT Posting Date", format(FldRef.Value()));
                                                    rLTagetikGLEntry."ATT Cost Center Code" := vLCostCenterCode;
                                                    rLTagetikGLEntry."ATT Cost Center Name" := vLCostCenterName;
                                                    rLTagetikGLEntry."ATT IC Code" := vLICCode;
                                                    rLTagetikGLEntry."ATT IC Name" := vLICName;
                                                    rLTagetikGLEntry."ATT Amount" := rLDecimalValue;
                                                    if rLGLSetup."LCY Code" = '' then
                                                        rLTagetikGLEntry."ATT LCY Code" := 'EUR'
                                                    else
                                                        rLTagetikGLEntry."ATT LCY Code" := rLGLSetup."LCY Code";
                                                    //NOTA: DEJAMOS EL ÚLTIMO Nº MOV. CONTABILIDADO, NO EL QUE ESTAMOS RECORRIENDO QUE ES ANTERIOR!!!!
                                                    rLTagetikGLEntry."ATT Last GL Entry No." := vLLastEntryNo;
                                                    rLTagetikGLEntry."ATT Account Type" := 'N';
                                                    if rLGLAccount."Income/Balance" = rLGLAccount."Income/Balance"::"Income Statement" then begin
                                                        rLTagetikGLEntry."ATT Account Nature" := 'E';
                                                        rLTagetikGLEntry."ATT Account Conv. Type" := '6';
                                                    end
                                                    else begin
                                                        rLTagetikGLEntry."ATT Account Nature" := 'P';
                                                        rLTagetikGLEntry."ATT Account Conv. Type" := '1';
                                                    end;
                                                    rLTagetikGLEntry.Insert(true);
                                                end;
                                            end;
                                            FldRef := RecRef.Field(60003); // 60003 = field "ATT Tagetik Reclass."
                                            FldRef.Value := false;
                                            FldRef := RecRef.Field(60004); // 60004 = field "ATT Reclass. CECO ORG"
                                            FldRef.Value := '';
                                            FldRef := RecRef.Field(60005); // 60004 = field "ATT Reclass. IC ORG"
                                            FldRef.Value := '';
                                            RecRef.Modify();
                    until RecRef.Next() = 0;
                RecRef.Close();
                //-JGA        

                Commit();
            until rLCompany.Next() = 0;

        rLTagetikLog."ATT Ending DateTime" := CurrentDateTime();
        rLTagetikLog."ATT In Execution" := false;
        rLTagetikLog.Modify(true);
        Commit();
    end;
}