; Function: stormqf
;
; Purpose:
;   This function will return a storm quality factor if you give it an array of dates. 
;
; Inputs: 
;   dates:  the array of dates you are interested. Any anytim friendly format works. 
; 
; Output: 
;  	Returns a double, the quality factor = percentage of events during WWLLN storm. 
; 
; Example: 
;   quickbox5,'2004-08-20 18:07:13.341','event2.ps',5.671,-70.2582,600.d,1.d,1110.
;
; Updates:
;   08/04/2015: Made it useable from outside the directory of dsmith/WWLLN (Alex Infanger)
; 
; Author:
;	Alex Infanger (UC Santa Cruz)
;   For more info contact ainfange@ucsc.edu



function stormqf, dates

	good = 0.0d
	bad = 0.0d

	for i=0,n_elements(dates)-1 do begin
		wwllndate = WWLLN_date_format(dates[i])
		storm = fastcheck(wwllndate)
		if storm eq 0 then bad++
		if storm eq 1 then good++
	endfor

	qf = good/(good+bad)
	return, qf

end
