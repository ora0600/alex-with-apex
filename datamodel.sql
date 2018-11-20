/* SQL CODE */
-- sequences
CREATE SEQUENCE   "ALEXA_BEGRUESSUNG_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION
/
CREATE SEQUENCE   "ALEXA_INNOVATIONSTATEMENT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 181 CACHE 20 NOORDER  NOCYCLE  NOPARTITION
/
CREATE SEQUENCE   "ALEXA_NEWPROJECTS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION
/
CREATE SEQUENCE   "ALEXA_OIGTEAMMEMBERS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOPARTITION
/


-- Tables
CREATE TABLE  "ALEXA_BEGRUESSUNG" 
   (	"ID" NUMBER, 
	"DAYTIME" VARCHAR2(50), 
	"GREETING" VARCHAR2(500), 
	 CONSTRAINT "ALEXA_BEGRUESSUNG_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_ALEXA_BEGRUESSUNG" 
  before insert on "ALEXA_BEGRUESSUNG"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "ALEXA_BEGRUESSUNG_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ALEXA_BEGRUESSUNG" ENABLE
/

CREATE TABLE  "ALEXA_INNOVATIONSTATEMENTS" 
   (	"ID" NUMBER, 
	"STATEMENT" VARCHAR2(4000), 
	 CONSTRAINT "ALEXA_INNOVATIONSTATEMENTS_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_ALEXA_INNOVATIONSTATEMENTS" 
  before insert on "ALEXA_INNOVATIONSTATEMENTS"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "ALEXA_INNOVATIONSTATEMENT_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ALEXA_INNOVATIONSTATEMENTS" ENABLE
/

CREATE TABLE  "ALEXA_NEWPROJECTS" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"PROJECT_NAME" VARCHAR2(100), 
	"PROJECT_DESCRIPTION" VARCHAR2(4000), 
	 CONSTRAINT "ALEXA_NEWPROJECTS_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_ALEXA_NEWPROJECTS" 
  before insert on "ALEXA_NEWPROJECTS"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "ALEXA_NEWPROJECTS_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ALEXA_NEWPROJECTS" ENABLE
/

CREATE TABLE  "ALEXA_OIGTEAMMEMBERS" 
   (	"ID" NUMBER, 
	"TEAMMEMBER" VARCHAR2(4000), 
	"NAME" VARCHAR2(100), 
	 CONSTRAINT "ALEXA_OIGTEAMMEMBERS_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_ALEXA_OIGTEAMMEMBERS" 
  before insert on "ALEXA_OIGTEAMMEMBERS"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "ALEXA_OIGTEAMMEMBERS_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ALEXA_OIGTEAMMEMBERS" ENABLE
/

-- Functions
create or replace FUNCTION alexa_greetings
   RETURN VARCHAR
is
  l_message   varchar2(32000);
  l_hour      integer;
  l_statement varchar2(4000);
begin
-- get the statement as random
BEGIN
 -- the server is in Texas Austin, add 7 hours for germany
 select to_number(to_char(sysdate+1/24,'HH24')) into l_hour 
   from dual;
 IF (l_hour >= 5 and l_hour <= 11) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'MORGENS';
 ELSIF (l_hour > 11 and l_hour <= 14) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'MITTAGS';
 ELSIF (l_hour > 14 and l_hour <= 16) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'NACHMITTAGS';
 ELSIF (l_hour > 16 and l_hour <= 21) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'ABENDS';
 ELSIF (l_hour > 21 and l_hour <= 24) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'NACHTS';
 ELSIF (l_hour >= 0 and l_hour <= 4) THEN
   select GREETING into l_statement
     from ALEXA_BEGRUESSUNG
    where daytime = 'NACHTS';
 ELSE
  l_statement := 'Servus. Hier spricht der automatische Überwachnungsdienst. Die Datenbank lieferte kein sauberes Ergebnis. Trotzdem eine schöne Zeit für Dich.';
 END IF;
exception when others then
 l_statement := 'Die Innovation fällt heute aus, ich wünsche Dir einen schönen Tag.';
END;
l_message := '
{
  "version": "1.0",
  "response": { "outputSpeech": 
                { "type": "PlainText",
                  "text": "'||l_statement||'",
                  "ssml": null
                },
                "shouldEndSession": true
              }
}';
return l_message;

end alexa_greetings;
/

create or replace FUNCTION alexa_newproject
   RETURN VARCHAR
is
  l_message   varchar2(32000);
  l_statement varchar2(4000);
begin
-- get the statement as random
BEGIN
 select 'Projekt '||PROJECT_NAME||': '|| PROJECT_DESCRIPTION into l_statement
 from ( select PROJECT_NAME, PROJECT_DESCRIPTION
 from ALEXA_NEWPROJECTS
where PROJECT_NAME like '%'
order by dbms_random.value )
where rownum = 1;
exception when others then
 l_statement := 'Die Innovation fällt heute aus, ich wünsche Dir einen schönen Tag.';
END;
l_message := '
{
  "version": "1.0",
  "response": { "outputSpeech": 
                { "type": "PlainText",
                  "text": "'||l_statement||'",
                  "ssml": null
                },
                "shouldEndSession": true
              }
}';
return l_message;
end alexa_newproject;
/
create or replace FUNCTION alexa_oigteam
   RETURN VARCHAR
is
  l_message   varchar2(32000);
  l_standard varchar2(500) := 'Die Oracle Innovation Group grüßt Dich ganz lieb. Heute stellen wir vor: ';
  l_statement varchar2(4000);
begin
-- get the statement as random
BEGIN
 select NAME||'. '||TEAMMEMBER into l_statement
 from ( select NAME, TEAMMEMBER
 from ALEXA_OIGTEAMMEMBERS
where NAME like '%'
order by dbms_random.value )
where rownum = 1;
exception when others then
 l_statement := 'Die Innovation fällt heute aus, ich wünsche Dir einen schönen Tag.';
END;
l_message := '
{
  "version": "1.0",
  "response": { "outputSpeech": 
                { "type": "PlainText",
                  "text": "'||l_statement||'",
                  "ssml": null
                },
                "shouldEndSession": true
              }
}';
return l_message;
end alexa_oigteam;
/
create or replace FUNCTION alexa_statementoftheDay
   RETURN VARCHAR2
is
  l_message   varchar2(32000);
  l_statement varchar2(4000);
begin
-- get the statement as random
BEGIN
 select statement into l_statement
  from ( select statement
  from ALEXA_INNOVATIONSTATEMENTS
 where statement like '%'
 order by dbms_random.value)
 where rownum = 1;
exception when others then
 l_statement := 'Die Innovation fällt heute aus, ich wünsche Dir einen schönen Tag.';
END;
-- Message an Alexa
l_message := '
{
  "version": "1.0",
  "response": { "outputSpeech": 
                { "type": "PlainText",
                  "text": "'||l_statement||'",
                  "ssml": null
                },
                "shouldEndSession": true
              }
}';return l_message;
end alexa_statementoftheDay;
/
create or replace FUNCTION blob_to_clob (p_data  IN  BLOB)
  RETURN CLOB
AS
  l_clob         CLOB;
  l_dest_offset  PLS_INTEGER := 1;
  l_src_offset   PLS_INTEGER := 1;
  l_lang_context PLS_INTEGER := DBMS_LOB.default_lang_ctx;
  l_warning      PLS_INTEGER;
BEGIN

  DBMS_LOB.createTemporary(
    lob_loc => l_clob,
    cache   => TRUE);

  DBMS_LOB.converttoclob(
   dest_lob      => l_clob,
   src_blob      => p_data,
   amount        => DBMS_LOB.lobmaxsize,
   dest_offset   => l_dest_offset,
   src_offset    => l_src_offset, 
   blob_csid     => DBMS_LOB.default_csid,
   lang_context  => l_lang_context,
   warning       => l_warning);
   
   RETURN l_clob;
END blob_to_clob;
/

CREATE OR REPLACE procedure alexa_skill (p_body in blob)
is
 l_body_clob     clob;
 l_values        apex_json.t_values;
 l_intent_name   varchar2(4000);

begin

 --transfer blob to clob
 l_body_clob := blob_to_clob (p_data => p_body);

 --Parse clob to json object and get the intent
 apex_json.parse(l_values,l_body_clob); 
 l_intent_name := apex_json.get_varchar2(p_path   =>'request.intent.name',
                                         p0       =>1, 
	  									 p_values =>l_values);

 if l_intent_name in ('statementoftheday') then
  htp.p(alexa_statementoftheDay);
 elsif l_intent_name in ('sayhello') then  
  htp.p(alexa_greetings);
 elsif l_intent_name in ('meetheteam') then  
  htp.p(alexa_oigteam);
 elsif l_intent_name in ('newprojects') then  
  htp.p(alexa_newproject);
 else
  htp.p(alexa_greetings);
 end if;
end alexa_skill;
/

-- REST API
-- Modules -> Alexa -> Resource Template Statement -> Post Method Source Type PLSQL
begin
owa_util.mime_header('application/json');
alexa_skill (p_pbody => :body);
:status := 200;
end;
