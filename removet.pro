; Function: removet
;
; Purpose:
;   Remove the t from a bunch of ccsds timestrings in an array. Anytim can only 
;   run on single events so this function does the for loop for you.  
;
; Inputs: 
;   ccsds: the date you are interested in, in ccsds. 
;
; Author:
;	Alex Infanger (UC Santa Cruz)

function removet, ccsds
	for i=0,n_elements(ccsds)-1 do begin
		ccsds[i] = STRJOIN(STRSPLIT(ccsds[i],'T', /EXTRACT), ' ')
	endfor
	return, ccsds
end

