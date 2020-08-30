// c:{parse["select from t",$[count x;" where ",x;""]]. 2 0}
// b:{parse["select",$[count x;" by ",x;""]," from t"]3}
// a:{parse["select ",x," from t"]4}
// fbyx:{.[parse["select from t where ",x,"fby c"]. 2 0 0;2 2;:;(flip;(!;enlist(),y;(enlist,y)))]}
//  select sum x by y from t where x<>1
//  ?[t;c"x<>1";b"y";a"sum x"]
//  select from t2 where i=(last;i)fby([]y;k)
//  ?[t2;enlist fbyx["i=(last;i)";`y`k];0b;()]
// 
//  c"t1_name <> t2_name"

show t1:([s:`s1`s2`s3A`s4;k:`k1`k2`k3`k4]
 name: `smith``blake`clark;
 status: 10 20 30 40;
 city:`london`paris`paris`londonA);
show t2:([s:`s2`s3`s4`s5;k:`k2`k3A`k4`k5]
 name:``blake`clark`adams;
 status:25 0N 45 50;
 city:`paris`paris`londonB`athens);

k: keys t2;
v: (cols t2) where not (cols t2) in k
v1: `$"t1_",/:string v
v2: `$"t2_",/:string v
ids: distinct ?[t1;();0b;k!k],?[t2;();0b;k!k]
uni: ?[ids lj t1;();0b;(k,v1)!k,v]
uni: ?[uni lj t2;();0b;(k,v1,v2)!k,v1,v]

uni
select from uni where t1_name <> t2_name
select from uni where t1_city <> t2_city
select from uni where t1_status <> t2_status
?[uni;enlist((';~:;=);`t1_name;`t2_name);0b;(k,`field,`t1_val,`t2_val)!(k,(enlist enlist`name),`t1_name,`t2_name)]
?[uni;enlist((';~:;=);`t1_city;`t2_city);0b;(k,`field,`t1_val,`t2_val)!(k,(enlist enlist`city),`t1_city,`t2_city)]

{[col]
    t1_col: `$"t1_",string col;
    t2_col: `$"t2_",string col;
    ?[uni;
      enlist((';~:;=);t1_col;t2_col);
      0b;
      (k,`n,`field,`t1_val,`t2_val)!(k,(v?col),(enlist enlist col),t1_col,t2_col)]
 }`status

dif:0#enlist(k,`n,`field,`t1_val,`t2_val)!(4+count[k])#();
dif
over
NULL AS FIELD, 'NULL' AS T1_VAL, 'NULL' AS T2_VAL FROM DUAL

//////
DIF AS
SELECT LOAN_ID, ACC_ID,
       COUNT(*) OVER(PARTITION BY LOAN_ID, ACC_ID ORDER BY N) AS F,
       DENSE_RANK() OVER(ORDER BY LOAN_ID, ACC_ID) AS RN,
       N,
       FIELD,
       T1_VAL, T2_VAL
FROM (SELECT           LOAN_ID, ACC_ID, N, FIELD,        T1_VAL,          T2_VAL
      UNION ALL SELECT LOAN_ID, ACC_ID, 2, 'ID',         "t1_ID",         "t2_ID"         FROM UNI WHERE NVL(t1_ID, -123456) <> NVL(t2_ID, -123456)
      UNION ALL SELECT LOAN_ID, ACC_ID, 3, 'REPORTDATE', "t1_REPORTDATE", "t2_REPORTDATE" FROM UNI WHERE NVL(t1_REPORTDATE, TO_DATE('01.01.1945','DD.MM.YYYY')) <> NVL(t2_REPORTDATE, TO_DATE('01.01.1945','DD.MM.YYYY'))


/
CREATE OR REPLACE
PROCEDURE TDIFF(pT1 VARCHAR2 := '',
                pW1 VARCHAR2 := '',
                pT2 VARCHAR2 := '',
                pW2 VARCHAR2 := '',
                pPK VARCHAR2 := '',
                pIGNORE VARCHAR2 := '',
                pOWNER VARCHAR2 := 'QADRPT')
IS
    TYPE t_lst IS TABLE OF VARCHAR2(256) INDEX BY PLS_INTEGER;
    head VARCHAR2(32);
    tail VARCHAR2(4000);
    cnt NUMBER;
    str VARCHAR2(4000);

    pk t_lst;
    pk_defs t_lst;
    ig t_lst;

    cols t_lst;
    defs t_lst;
    nums t_lst;

    TYPE t_colon_item
    IS RECORD
    (
        OWNER VARCHAR2( 256 ),
        TABLE_NAME VARCHAR2( 256 ),
        COLUMN_NAME VARCHAR2( 256 ),
        DATA_NULL VARCHAR2( 256 ),
        DATA_TYPE VARCHAR2( 256 ),
        DATA_DEFAULT VARCHAR2( 256 ),
        COLUMN_ID NUMBER
    );
    TYPE colon_list
    IS TABLE OF t_colon_item;
    table_cols colon_list;

    ColCounter NUMBER;
    Comma VARCHAR2( 32 ) := NULL;

    CURSOR cur_columns
    IS SELECT OWNER,
              TABLE_NAME,
              COLUMN_NAME,
              CASE WHEN DATA_TYPE = 'NUMBER' THEN '-123456'
                   WHEN DATA_TYPE = 'VARCHAR2' THEN '''NULL'''
                   WHEN DATA_TYPE = 'DATE' THEN 'TO_DATE(''01.01.1945'',''DD.MM.YYYY'')'
                   ELSE '0'
              END AS DATA_NULL,
              DATA_TYPE,
              DATA_DEFAULT,
              -- TO_LOB(DATA_DEFAULT) AS DATA_DEFAULT,
              COLUMN_ID AS N
       FROM ALL_TAB_COLS
       WHERE OWNER = UPPER(pOWNER)
       AND TABLE_NAME = UPPER(pT1)
       AND HIDDEN_COLUMN = 'NO'
       AND VIRTUAL_COLUMN = 'NO' -- нет виртуалам
       ORDER BY COLUMN_ID
    ;

    -- get a comma-separated ids
    -- # in sufffix is used as a backreference to an id
    FUNCTION get_list(format VARCHAR2, ids1 t_lst, delim VARCHAR2 := ', ')
    RETURN VARCHAR2
    IS
        ret VARCHAR2(4000);
    BEGIN
        FOR i IN ids1.FIRST..ids1.LAST LOOP
            ret := SUBSTR(ret || REPLACE(format, '{1}', ids1(i)) || CASE WHEN i <> ids1.LAST THEN delim END, 1, 4000);
        END LOOP;
        RETURN ret;
    END;
    FUNCTION get_list2(format VARCHAR2, ids1 t_lst, ids2 t_lst, delim VARCHAR2 := ', ')
    RETURN VARCHAR2
    IS
        ret VARCHAR2(4000);
    BEGIN
        FOR i IN ids1.FIRST..ids1.LAST LOOP
            ret := SUBSTR(ret || REPLACE(REPLACE(format, '{1}', ids1(i)), '{2}', ids2(i)) || CASE WHEN i <> ids1.LAST THEN delim END, 1, 4000);
        END LOOP;
        RETURN ret;
    END;
    PROCEDURE put_list(format VARCHAR2, ids1 t_lst, ids2 t_lst, ids3 t_lst, delim VARCHAR2 := ', ')
    IS
    BEGIN
        FOR i IN ids1.FIRST..ids1.LAST LOOP
            DBMS_OUTPUT.put(REPLACE(REPLACE(REPLACE(format, '{1}', ids1(i)), '{2}', ids2(i)), '{3}', ids3(i))
            || CASE WHEN i <> ids1.LAST THEN delim END);
        END LOOP;
    END;
BEGIN

    IF (pT1 IS NULL) THEN
        DBMS_OUTPUT.put_line('-- EXAMPLE:');
        DBMS_OUTPUT.put_line('');
        DBMS_OUTPUT.put_line('-- create first table');
        DBMS_OUTPUT.put_line('BEGIN EXECUTE IMMEDIATE ''DROP TABLE tbl1''; EXCEPTION WHEN OTHERS THEN NULL; END;');
        DBMS_OUTPUT.put_line('/');
        DBMS_OUTPUT.put_line('CREATE TABLE tbl1 (ID1 NUMBER, ID2 NUMBER, V1 VARCHAR2(10), V2 VARCHAR2(10), V3 VARCHAR2(10));');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(1, 10, ''a1'', ''b1'', ''c1'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(2, 10, ''a2'', ''b2'', ''c2'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(3, 10, ''a3'', ''b3'', ''c3'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(4, 20, ''a4'', ''b4'', ''c4'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(5, 30, ''a5'', ''b5'', ''c5'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl1 VALUES(6, NULL, ''a6'', ''b6'', ''c6'');');
        DBMS_OUTPUT.put_line('COMMIT;');
        DBMS_OUTPUT.put_line('');
        DBMS_OUTPUT.put_line('-- create second table');
        DBMS_OUTPUT.put_line('BEGIN EXECUTE IMMEDIATE ''DROP TABLE tbl2''; EXCEPTION WHEN OTHERS THEN NULL; END;');
        DBMS_OUTPUT.put_line('/');
        DBMS_OUTPUT.put_line('CREATE TABLE tbl2 (ID1 NUMBER, ID2 NUMBER, V1 VARCHAR2(10), V2 VARCHAR2(10), V3 VARCHAR2(10));');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(1, 10, ''A1'', ''b1'', ''c1'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(2, 10, ''a2'', ''B2'', ''c2'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(3, 10, ''A3'', ''B3'', ''c3'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(4, 25, ''a4'', ''b4'', ''c4'');');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(5, 30, ''a5'', ''b5'', NULL);');
        DBMS_OUTPUT.put_line('INSERT INTO tbl2 VALUES(6, NULL, ''A6'', ''B6'', ''C6'');');
        DBMS_OUTPUT.put_line('COMMIT;');
        DBMS_OUTPUT.put_line('');
        DBMS_OUTPUT.put_line('-- compare tables (see output)');
        DBMS_OUTPUT.put_line('BEGIN TDIFF(pT1 => ''TBL1'', pW1 => ''WHERE 1=1'',');
        DBMS_OUTPUT.put_line('            pT2 => ''TBL2'', pW2 => ''WHERE 2=2'',');
        DBMS_OUTPUT.put_line('            pPK => ''ID1, ID2'', pIGNORE => ''V1''');
        DBMS_OUTPUT.put_line('           );');
        DBMS_OUTPUT.put_line('END;');
        DBMS_OUTPUT.put_line('/');
        RETURN;
    END IF;

    DBMS_OUTPUT.put_line('-- compare two tables');
    DBMS_OUTPUT.put_line('--');
    DBMS_OUTPUT.put_line('-- scm = ' || pOWNER);
    DBMS_OUTPUT.put_line('-- t1 = ' || pT1);
    DBMS_OUTPUT.put_line('-- w1 = ' || pW1);
    DBMS_OUTPUT.put_line('-- t2 = ' || pT2);
    DBMS_OUTPUT.put_line('-- w2 = ' || pW2);
    DBMS_OUTPUT.put_line('-- pk = ' || pPK);
    DBMS_OUTPUT.put_line('-- ig = ' || pIGNORE);
    DBMS_OUTPUT.put_line('');

    -- get the column counter
    SELECT COUNT( * )
    INTO ColCounter
    FROM ALL_TAB_COLS
    WHERE OWNER = UPPER(pOWNER)
    AND TABLE_NAME = UPPER(pT1)
    AND HIDDEN_COLUMN = 'NO'
    -- AND VIRTUAL_COLUMN = 'NO'
    ;

    -- pk
    cnt := 1;
    str := REPLACE(pPK, ' ');
    head := SUBSTR(str, 1, INSTR(str, ',') - 1);
    tail := SUBSTR(str, INSTR(str, ',') + 1);
    WHILE tail <> str
    LOOP
        pk(cnt) := head;

        cnt := cnt + 1;
        str := tail;
        head := SUBSTR(str, 1, INSTR(str, ',') - 1);
        tail := SUBSTR(str, INSTR(str, ',') + 1);
    END LOOP;
    pk(cnt) := tail;

    -- ig
    cnt := 1;
    str := REPLACE(pIGNORE, ' ');
    head := SUBSTR(str, 1, INSTR(str, ',') - 1);
    tail := SUBSTR(str, INSTR(str, ',') + 1);
    WHILE tail <> str
    LOOP
        ig(cnt) := head;

        cnt := cnt + 1;
        str := tail;
        head := SUBSTR(str, 1, INSTR(str, ',') - 1);
        tail := SUBSTR(str, INSTR(str, ',') + 1);
    END LOOP;
    ig(cnt) := tail;

    OPEN cur_columns;
    FETCH cur_columns BULK COLLECT INTO table_cols;
    CLOSE cur_columns;

    -- cols
    cnt := 1;
    <<ii_cols>> FOR i IN table_cols.FIRST..table_cols.LAST LOOP
        FOR j IN pk.FIRST..pk.LAST LOOP
            CONTINUE ii_cols WHEN pk(j) = table_cols(i).COLUMN_NAME;
        END LOOP;
        cols(cnt) := table_cols(i).COLUMN_NAME;
        cnt := cnt + 1;
    END LOOP;

    -- defs
    cnt := 1;
    <<ii_defs>> FOR i IN table_cols.FIRST..table_cols.LAST LOOP
        FOR j IN pk.FIRST..pk.LAST LOOP
            CONTINUE ii_defs WHEN pk(j) = table_cols(i).COLUMN_NAME;
        END LOOP;
        defs(cnt) := table_cols(i).DATA_NULL;
        cnt := cnt + 1;
    END LOOP;
   
    -- pk_defs
    <<ii_pk_defs>> FOR i IN table_cols.FIRST..table_cols.LAST LOOP
        FOR j IN pk.FIRST..pk.LAST LOOP
            IF pk(j) = table_cols(i).COLUMN_NAME THEN
                pk_defs(j) := table_cols(i).DATA_NULL;
                CONTINUE ii_pk_defs;
            END IF;
        END LOOP;
    END LOOP;

    -- nums
    cnt := 1;
    <<ii_nums>> FOR i IN table_cols.FIRST..table_cols.LAST LOOP
        FOR j IN pk.FIRST..pk.LAST LOOP
            CONTINUE ii_nums WHEN pk(j) = table_cols(i).COLUMN_NAME;
        END LOOP;
        nums(cnt) := cnt + 1;
        cnt := cnt + 1;
    END LOOP;


    -- == WITH
    DBMS_OUTPUT.put_line('WITH');
    -- == IDS
    DBMS_OUTPUT.put_line('IDS AS (');
    DBMS_OUTPUT.put_line('    SELECT ' || get_list('{1}', pk) || ' FROM ' || pOWNER || '.' || pT1 || ' ' || pW1);
    DBMS_OUTPUT.put_line('    UNION');
    DBMS_OUTPUT.put_line('    SELECT ' || get_list('{1}', pk) || ' FROM ' || pOWNER || '.' || pT2 || ' ' || pW2);
    DBMS_OUTPUT.put_line('),');
    -- === UNI
    DBMS_OUTPUT.put_line('UNI AS (');
    DBMS_OUTPUT.put_line('    SELECT ' || get_list('i.{1}', pk) || ',');
    DBMS_OUTPUT.put_line('           ' || get_list('t1.{1} AS t1_{1}', cols) || ',');
    DBMS_OUTPUT.put_line('           ' || get_list('t2.{1} AS t2_{1}', cols));
    DBMS_OUTPUT.put_line('    FROM IDS i');
    DBMS_OUTPUT.put_line('    LEFT JOIN (SELECT * FROM ' || pOWNER || '.' || pT1 || ' ' || pW1 || ') t1 ON ' || get_list2('(NVL(t1.{1}, {2}) = NVL(i.{1}, {2}))', pk, pk_defs, ' AND '));
    DBMS_OUTPUT.put_line('    LEFT JOIN (SELECT * FROM ' || pOWNER || '.' || pT2 || ' ' || pW2 || ') t2 ON ' || get_list2('(NVL(t2.{1}, {2}) = NVL(i.{1}, {2}))', pk, pk_defs, ' AND '));
    DBMS_OUTPUT.put_line('),');
    -- === DIFF
    DBMS_OUTPUT.put_line('DIF AS (');
    DBMS_OUTPUT.put_line('    SELECT ' || get_list('{1}', pk) || ',');
    DBMS_OUTPUT.put_line('           COUNT(*) OVER(PARTITION BY ' || get_list('{1}', pk) || ' ORDER BY N) AS F,');
    DBMS_OUTPUT.put_line('           DENSE_RANK() OVER(ORDER BY ' || get_list('{1}', pk) || ') AS RN,');
    DBMS_OUTPUT.put_line('           N,');
    DBMS_OUTPUT.put_line('           FIELD,');
    DBMS_OUTPUT.put_line('           T1_VAL, T2_VAL');
    DBMS_OUTPUT.put_line('    FROM (SELECT ' || get_list('NULL AS {1}', pk) || ', 0 AS N, NULL AS FIELD, ''NULL'' AS T1_VAL, ''NULL'' AS T2_VAL FROM DUAL');
                put_list('          UNION ALL SELECT ' || get_list('{1}', pk) || ', {1}, ''{2}'', TO_CHAR(t1_{2}), TO_CHAR(t2_{2}) FROM UNI WHERE NVL(t1_{2}, {3}) <> NVL(t2_{2}, {3})', nums, cols, defs, CHR(10));
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('         )');
    DBMS_OUTPUT.put_line('    WHERE N > 0');
    DBMS_OUTPUT.put_line('    -- ignored fields');
    DBMS_OUTPUT.put_line('    AND FIELD NOT IN (' || NVL(NULLIF(get_list('''{1}''', ig), ''''''), '''<NULL>''') || ')');
    DBMS_OUTPUT.put_line(')');
    -- === SELECT
    DBMS_OUTPUT.put_line('SELECT ' || get_list('DECODE(F, 1, {1}) AS {1}', pk) || ',');
    DBMS_OUTPUT.put_line('       DECODE(F, 1, RN) AS NUM,');
    DBMS_OUTPUT.put_line('       FIELD,');
    DBMS_OUTPUT.put_line('       T1_VAL, T2_VAL');
    DBMS_OUTPUT.put_line('FROM DIF d');
    DBMS_OUTPUT.put_line('ORDER BY ' || get_list('d.{1}', pk) || ', N');
    DBMS_OUTPUT.put_line(';');

END;
/
-- example output
WITH
IDS AS (
    SELECT LOAN_ID, ACC_ID FROM QADRPT.QAD_LNP_COMMISSION_ORA_PT WHERE REPORTDATE = '30.04.2016'
    UNION
    SELECT LOAN_ID, ACC_ID FROM QADRPT.QAD_LNP_COMMISSION_ORA_T
),
UNI AS (
    SELECT i.LOAN_ID, i.ACC_ID,
           t1.ID AS t1_ID, t1.REPORTDATE AS t1_REPORTDATE, t1.BRANCHCODE AS t1_BRANCHCODE, t1.ACCSINFEE AS t1_ACCSINFEE, t1.ACCANLFEE AS t1_ACCANLFEE, t1.NAMEACCANLFEE AS t1_NAMEACCANLFEE, t1.SUMFEECURRENCYREPORTINGDATE AS t1_SUMFEECURRENCYREPORTINGDATE, t1.SUMFEEROUBLEREPORTINGDATE AS t1_SUMFEEROUBLEREPORTINGDATE, t1.ACCSINRESERVEFEE AS t1_ACCSINRESERVEFEE, t1.ACCANLRESERVEFEE AS t1_ACCANLRESERVEFEE, t1.NAMEACCANLRESERVEFEE AS t1_NAMEACCANLRESERVEFEE, t1.SUMRESERVEFEE AS t1_SUMRESERVEFEE, t1.AMOUNTLUMPSUMFEE AS t1_AMOUNTLUMPSUMFEE, t1.DATEAMOUNTLUMPSUMFEE AS t1_DATEAMOUNTLUMPSUMFEE, t1.LN_RN AS t1_LN_RN,
           t2.ID AS t2_ID, t2.REPORTDATE AS t2_REPORTDATE, t2.BRANCHCODE AS t2_BRANCHCODE, t2.ACCSINFEE AS t2_ACCSINFEE, t2.ACCANLFEE AS t2_ACCANLFEE, t2.NAMEACCANLFEE AS t2_NAMEACCANLFEE, t2.SUMFEECURRENCYREPORTINGDATE AS t2_SUMFEECURRENCYREPORTINGDATE, t2.SUMFEEROUBLEREPORTINGDATE AS t2_SUMFEEROUBLEREPORTINGDATE, t2.ACCSINRESERVEFEE AS t2_ACCSINRESERVEFEE, t2.ACCANLRESERVEFEE AS t2_ACCANLRESERVEFEE, t2.NAMEACCANLRESERVEFEE AS t2_NAMEACCANLRESERVEFEE, t2.SUMRESERVEFEE AS t2_SUMRESERVEFEE, t2.AMOUNTLUMPSUMFEE AS t2_AMOUNTLUMPSUMFEE, t2.DATEAMOUNTLUMPSUMFEE AS t2_DATEAMOUNTLUMPSUMFEE, t2.LN_RN AS t2_LN_RN
    FROM IDS i
    LEFT JOIN (SELECT * FROM QADRPT.QAD_LNP_COMMISSION_ORA_PT WHERE REPORTDATE = '30.04.2016') t1 ON (NVL(t1.LOAN_ID, -123456) = NVL(i.LOAN_ID, -123456)) AND (NVL(t1.ACC_ID, -123456) = NVL(i.ACC_ID, -123456))
    LEFT JOIN (SELECT * FROM QADRPT.QAD_LNP_COMMISSION_ORA_T ) t2 ON (NVL(t2.LOAN_ID, -123456) = NVL(i.LOAN_ID, -123456)) AND (NVL(t2.ACC_ID, -123456) = NVL(i.ACC_ID, -123456))
),
DIF AS (
    SELECT LOAN_ID, ACC_ID,
           COUNT(*) OVER(PARTITION BY LOAN_ID, ACC_ID ORDER BY N) AS F,
           DENSE_RANK() OVER(ORDER BY LOAN_ID, ACC_ID) AS RN,
           N,
           FIELD,
           T1_VAL, T2_VAL
    FROM (SELECT NULL AS LOAN_ID, NULL AS ACC_ID, 0 AS N, NULL AS FIELD, 'NULL' AS T1_VAL, 'NULL' AS T2_VAL FROM DUAL
          UNION ALL SELECT LOAN_ID, ACC_ID, 2, 'ID', TO_CHAR(t1_ID), TO_CHAR(t2_ID) FROM UNI WHERE NVL(t1_ID, -123456) <> NVL(t2_ID, -123456)
          UNION ALL SELECT LOAN_ID, ACC_ID, 3, 'REPORTDATE', TO_CHAR(t1_REPORTDATE), TO_CHAR(t2_REPORTDATE) FROM UNI WHERE NVL(t1_REPORTDATE, TO_DATE('01.01.1945','DD.MM.YYYY')) <> NVL(t2_REPORTDATE, TO_DATE('01.01.1945','DD.MM.YYYY'))
          UNION ALL SELECT LOAN_ID, ACC_ID, 4, 'BRANCHCODE', TO_CHAR(t1_BRANCHCODE), TO_CHAR(t2_BRANCHCODE) FROM UNI WHERE NVL(t1_BRANCHCODE, 'NULL') <> NVL(t2_BRANCHCODE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 5, 'ACCSINFEE', TO_CHAR(t1_ACCSINFEE), TO_CHAR(t2_ACCSINFEE) FROM UNI WHERE NVL(t1_ACCSINFEE, 'NULL') <> NVL(t2_ACCSINFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 6, 'ACCANLFEE', TO_CHAR(t1_ACCANLFEE), TO_CHAR(t2_ACCANLFEE) FROM UNI WHERE NVL(t1_ACCANLFEE, 'NULL') <> NVL(t2_ACCANLFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 7, 'NAMEACCANLFEE', TO_CHAR(t1_NAMEACCANLFEE), TO_CHAR(t2_NAMEACCANLFEE) FROM UNI WHERE NVL(t1_NAMEACCANLFEE, 'NULL') <> NVL(t2_NAMEACCANLFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 8, 'SUMFEECURRENCYREPORTINGDATE', TO_CHAR(t1_SUMFEECURRENCYREPORTINGDATE), TO_CHAR(t2_SUMFEECURRENCYREPORTINGDATE) FROM UNI WHERE NVL(t1_SUMFEECURRENCYREPORTINGDATE, -123456) <> NVL(t2_SUMFEECURRENCYREPORTINGDATE, -123456)
          UNION ALL SELECT LOAN_ID, ACC_ID, 9, 'SUMFEEROUBLEREPORTINGDATE', TO_CHAR(t1_SUMFEEROUBLEREPORTINGDATE), TO_CHAR(t2_SUMFEEROUBLEREPORTINGDATE) FROM UNI WHERE NVL(t1_SUMFEEROUBLEREPORTINGDATE, -123456) <> NVL(t2_SUMFEEROUBLEREPORTINGDATE, -123456)
          UNION ALL SELECT LOAN_ID, ACC_ID, 10, 'ACCSINRESERVEFEE', TO_CHAR(t1_ACCSINRESERVEFEE), TO_CHAR(t2_ACCSINRESERVEFEE) FROM UNI WHERE NVL(t1_ACCSINRESERVEFEE, 'NULL') <> NVL(t2_ACCSINRESERVEFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 11, 'ACCANLRESERVEFEE', TO_CHAR(t1_ACCANLRESERVEFEE), TO_CHAR(t2_ACCANLRESERVEFEE) FROM UNI WHERE NVL(t1_ACCANLRESERVEFEE, 'NULL') <> NVL(t2_ACCANLRESERVEFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 12, 'NAMEACCANLRESERVEFEE', TO_CHAR(t1_NAMEACCANLRESERVEFEE), TO_CHAR(t2_NAMEACCANLRESERVEFEE) FROM UNI WHERE NVL(t1_NAMEACCANLRESERVEFEE, 'NULL') <> NVL(t2_NAMEACCANLRESERVEFEE, 'NULL')
          UNION ALL SELECT LOAN_ID, ACC_ID, 13, 'SUMRESERVEFEE', TO_CHAR(t1_SUMRESERVEFEE), TO_CHAR(t2_SUMRESERVEFEE) FROM UNI WHERE NVL(t1_SUMRESERVEFEE, -123456) <> NVL(t2_SUMRESERVEFEE, -123456)
          UNION ALL SELECT LOAN_ID, ACC_ID, 14, 'AMOUNTLUMPSUMFEE', TO_CHAR(t1_AMOUNTLUMPSUMFEE), TO_CHAR(t2_AMOUNTLUMPSUMFEE) FROM UNI WHERE NVL(t1_AMOUNTLUMPSUMFEE, -123456) <> NVL(t2_AMOUNTLUMPSUMFEE, -123456)
          UNION ALL SELECT LOAN_ID, ACC_ID, 15, 'DATEAMOUNTLUMPSUMFEE', TO_CHAR(t1_DATEAMOUNTLUMPSUMFEE), TO_CHAR(t2_DATEAMOUNTLUMPSUMFEE) FROM UNI WHERE NVL(t1_DATEAMOUNTLUMPSUMFEE, TO_DATE('01.01.1945','DD.MM.YYYY')) <> NVL(t2_DATEAMOUNTLUMPSUMFEE, TO_DATE('01.01.1945','DD.MM.YYYY'))
          UNION ALL SELECT LOAN_ID, ACC_ID, 16, 'LN_RN', TO_CHAR(t1_LN_RN), TO_CHAR(t2_LN_RN) FROM UNI WHERE NVL(t1_LN_RN, -123456) <> NVL(t2_LN_RN, -123456)
         )
    WHERE N > 0
    -- ignored fields
    AND FIELD NOT IN ('<NULL>')
)
SELECT DECODE(F, 1, LOAN_ID) AS LOAN_ID, DECODE(F, 1, ACC_ID) AS ACC_ID,
       DECODE(F, 1, RN) AS NUM,
       FIELD,
       T1_VAL, T2_VAL
FROM DIF d
ORDER BY d.LOAN_ID, d.ACC_ID, N
;
