; Procedure: cel (Compare EventLists)
;
; Purpose:
; This is probably not code you want to use directly, but rather code you want to emulate
; when you want to compare, say Gjesteland TGF eventlists to UCSC TGF eventlists. 
;
; Inputs: 
;  Two eventlists. 
; 
; Output: 
;  Find events that are in one but not in the other. Then you can WWLLN-storm match them
;  if you like to create Gjesteland-not-UCSC storm. 
;
; Author:
; Alex Infanger (UC Santa Cruz)
; For more info contact ainfange@ucsc.edu


pro cel, eventlist1, eventlist2

   readcol, eventlist1, timestamp1,description, delimiter=';', $ 
   format='A,A'
   readcol, eventlist2, timestamp2, delimiter=';', $
   format='A', comment = ';'
   stop

  ; for i=0L, n_elements(timestamp1)-1 do begin
  ;    timestamp1[i]=StrJoin(StrSplit(timestamp1[i],'T',/Regex, /Extract, $
  ;    /Preserve_Null), ' ')
  ;    endfor

 ;  for i=0L, n_elements(timestamp2)-1 do begin
 ;     timestamp2[i]=StrJoin(Strsplit(timestamp2[i],'T',/Regex, /Extract, $
 ;     /Preserve_Null), ' ')
 ;     endfor


   matches = indgen(n_elements(timestamp1))
   for i=0L,n_elements(timestamp1)-1 do begin
      matches[i]=0
   endfor

   for i=0L,n_elements(timestamp2)-1 do begin
       matcht2index = where(abs(anytim(timestamp1)-anytim(timestamp2[i])) le .01, nat)
       if nat ne 0 then matches[matcht2index] = 1
       if nat ne 0 then print, 'match'
    endfor
   
   matchevents = where(matches eq 1,nm)

   if nm ne 0 then begin
      for k=0,nm-1 do begin
         openu, 1, 'bergennotucsc_reasons',/append, width=23
         printf,1, timestamp1[matchevents(k)],description[matchevents(k)]
         close, 1
      endfor
   endif  

end
