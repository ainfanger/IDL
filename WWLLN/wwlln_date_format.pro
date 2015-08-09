; Function: WWLLN_date_format
;
; Purpose:
;   This function will turn your given date into the correct date for using all
;   WWLLN-data related functions and procedures. The data is named differently 
;   for different procedures, and so fastcheck, etc. needs the date in the
;   format YYYY-MM-DAY TT:TT:TT.TTT. 
;
; Author:
;   Alex Infanger (UC Santa Cruz)
;   For more info contact ainfange@ucsc.edu


function WWLLN_date_format, date
	wwllndate = strjoin(strsplit(anytim(date,/ccsds),'T',/extract),' ')
return, wwllndate
end