Reading very complicated text files with a mutiline headers amd muatiple trailer records

This question plays directly into a very important SAS/WPS strength and differentiator.
 SAS Strength
 1. Mainframe text file that oftern have header and trailer data structures
 2.Many tools like #n, @'empid', @@, and @ not availble anywhere else.

   WORKING CODE
     SAS/WPS ( exactly the same output in WPS)

      INPUT (repeating data layout in a text file - Beeter to have the number of trailers in thei header)

       Name : ABC
       EMPID:QQQ
       PIN:1234
       .
       CITY : TA
       .
       PROD SALE1 SALE2 SALE3        * in IBM Jargon these are trailer records;
       DVD 21 32 12                  * just add trailers when you get more data;
       STREAM 25 35 34

      * read header records and one sale recors
      input #1 empid $80. #4 city $80. #7 sales_out $80. @;
      empid=scan(empid,2,':');
      city=scan(city,2,':');
      sales_out=scan(sales_out,4,' ');
      output;

      * read repeating Sales records
      do until(test eq 'Name');
         input sales_inp $80.;
         test=scan(sales_inp,1,':');
         sales_out=scan(sales_inp,4,' ');
         if index(test,'Name')=0 then output;
      end;

      OUTPUT

      Up to 40 obs WORK.WANT total obs=7

                              SALES_
      Obs    EMPID    CITY     OUT

       1     QQQ       TA       12
       2     QQQ       TA       34

https://goo.gl/tZGEHi
https://communities.sas.com/t5/Base-SAS-Programming/Reading-particular-line-from-text-files/td-p/404384


HAVE ( Text file below)

    d:\txt\messy.txt

    Name : ABC
    EMPID:QQQ
    PIN:1234
    .
    CITY : TA
    .
    PROD SALE1 SALE2 SALE3
    DVD 21 32 12
    STREAM 25 35 34
    Name : XYZ
    EMPID:9087
    PIN:1234
    .
    CITY : NY
    .
    PROD SALE1 SALE2 SALE3
    DVD 21 32 22
    STREAM 25 35 11
    Name : XYZ
    EMPID:Z087
    PIN:1234
    .
    CITY : PA
    .
    PROD SALE1 SALE2 SALE3
    DVD 21 32 88
    TV 25 35 99
    STREAM 25 35 33

WANT

   Up to 40 obs WORK.WANT total obs=7

                           SALES_
   Obs    EMPID    CITY     OUT

    1     QQQ       TA       12
    2     QQQ       TA       34
    3     9087      NY       22
    4     9087      NY       11
    5     Z087      PA       88
    6     Z087      PA       99
    7     Z087      PA       33
*                _                _       _
 _ __ ___   __ _| | _____      __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \    / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/   | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|    \__,_|\__,_|\__\__,_|

;
\/*
You don't need to add the '.' tfor blank lines
I had to do this due to a recent bug in the classic editor
that SAS refuses to correct? Ignore valuable data option?)
This only appries to inline data?
*/

data _null_;
 file "d:/txt/messy.txt";
 input;
 put _infile_;
 putlog _infile_;
cards4;
Name : ABC
EMPID:QQQ
PIN:1234
.
CITY : TA
.
PROD SALE1 SALE2 SALE3
DVD 21 32 12
STREAM 25 35 34
Name : XYZ
EMPID:9087
PIN:1234
.
CITY : NY
.
PROD SALE1 SALE2 SALE3
DVD 21 32 22
STREAM 25 35 11
Name : XYZ
EMPID:Z087
PIN:1234
.
CITY : PA
.
PROD SALE1 SALE2 SALE3
DVD 21 32 88
TV 25 35 99
STREAM 25 35 33
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


%utl_submit_wps64('
libname wrk "%sysfunc(pathname(work))";
data wrk.wantwps(keep=empid city sales_out);
retain empid city test;
infile "d:\txt\messy.txt" firstobs=2;
input #1 empid $80. #4 city $80. #7 sales_out $80. @;
 empid=scan(empid,2,":");
 city=scan(city,2,":");
 sales_out=scan(sales_out,4," ");
 output;
 do until(test eq "Name");
    input sales_inp $80.;
    test=scan(sales_inp,1,":");
    sales_out=scan(sales_inp,4," ");
    if index(test,"Name")=0 then output;
 end;
run;quit;
');

