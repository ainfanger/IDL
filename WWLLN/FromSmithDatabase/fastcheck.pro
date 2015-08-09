; Function: fastcheck (uses Prof. Smith's dbase which is faster)
;
; Purpose:
;   This function will find the correct WWLLN data file on thunder based on a given time, 
;   and then see if there was a storm close to the given latitude and longitude. Returns 
;   (0) if no WWLLN-storm nearby and (1) if WWLLN-storm nearby. 
;
;   A WWLLN-storm being nearby is characterized by;
;   One WWLLN-strike being within 600 s, and 650 km. 
;
; Inputs: 
;   date: the date you are interested in, format: '2004-08-20 18:07:13.341'
;   latc: the latitude of the center point.  
;   lonc: the longitude of the center point.  
;
; Updates:
;   08/04/2015: Made it useable from outside the directory of dsmith/WWLLN (Alex Infanger)
; 
; Author:
;   Alex Infanger (UC Santa Cruz)
;   For more info contact ainfange@ucsc.edu

function fastcheck,date

  dsec = 600.d
  rad = 650.d ;in km

  filename =  '/disks/darksun/home/dsmith/hessi/diagnostic/tgf/wwlln/flashlists/' + strmid(date,0,10)+'.sav'
  restore, filename
  storm = where(flashes.distance le rad and abs(flashes.flash_time-anytim(date)) le dsec, numstorm)
  if numstorm eq 0 then return, 0 else return, 1
end



