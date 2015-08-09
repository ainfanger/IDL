; Function: stormcheckrc (uses ReadCol)
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
; Example: 
;   quickbox5,'2004-08-20 18:07:13.341','event2.ps',5.671,-70.2582,600.d,1.d,1110.
;
; Updates:
;   08/04/2015: Made it useable from outside the directory of dsmith/WWLLN (Alex Infanger)
; 
; Author:
;   Prof. David Smith (UC Santa Cruz)
;   Edits: Alex Infanger 
;   For more info contact ainfange@ucsc.edu

function stormcheckrc,date,latc,lonc

; Set storm parameters. 

 dsec = 600.d
 rad = 650.d ;in km

; File preparation. 

dates=[2003,2004,2005,2006,2007,2008,2009,2010,2011,2012]
file_l =[1,1,1,intarr(7)]
file_a =[0,0,0,1,1,1,bytarr(4)]
file_0 =[0,bytarr(9)+1]
file_e =[bytarr(6),bytarr(4)+1]
matrix=[[file_l],[file_a],[file_0],[file_e]]

; Find the year
yrs=strmid(date,0,4)
yri=where(yrs eq dates,nw)
if nw ne 1 then message, 'Bad year or date format.'

t0=anytim(date)

s=""

; Loop through file types:

for i=0,3 do begin
   if matrix[yri,i] eq 0 then continue
   case i of
      0: fname='~/../dsmith/wwlln/older/L'+yrs+'/'+yrs+strmid(date,5,2)+'_proc/L'+ $
            yrs+strmid(date,5,2)+strmid(date,8,2)+'.loc'
      1: fname= '~/../dsmith/wwlln/A'+yrs+'daily/A'+yrs+strmid(date,5,2)+strmid(date,8,2)+'.loc'
      2: fname='~/../dsmith/wwlln/'+yrs+'/A'+yrs+strmid(date,5,2)+strmid(date,8,2)+'.loc'
      3: fname='~/../dsmith/wwlln/AEdata/'+yrs+'/AE'+yrs+strmid(date,5,2)+strmid(date,8,2)+'.loc'
   endcase

; If no file found try the the next case of filetype. Else, look at the file. 
   if file_search(fname) eq '' then continue

    readcol, fname, wdates, wminute, lat,lon, format='A,A,D,D', delimiter=','
  
    t=anytim(wdates+' '+minute)
    dt=abs(t-t0)

    negative = where(lon lt 0., nn)
    if nn ne 0 then lon[negative]+=360.

; Only read the lines thar are within rad of our center location. 
; Haversine formula from http://andrew.hedges.name/experiments/haversine/
    dlon = (lon-lonc)*!pi/180.
    dlat = (lat-latc)*!pi/180.
    lat1=latc*!pi/180.
    lat2=lat*!pi/180.
    R = 6378.1370d  ;equatorial
    a = (sin(dlat/2.))^2 + cos(lat1) * cos(lat2) * (sin(dlon/2.))^2
    c = 2. * atan( sqrt(a), sqrt(1.-a) )
    d = R * c
      
    storm = where(d le rad and dt le dsec, numstorm)
    if numstorm ne 0 then return, 1 else return, 0 
endfor
return, 2

end



