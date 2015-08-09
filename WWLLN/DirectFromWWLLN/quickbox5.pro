; Procedure: quickbox5 
;
; Purpose:
;   This program will find the correct WWLLN data file on thunder based on a given time, 
;   and then plot it on a map. 
;
; Inputs: 
;   date: the date you are interested in, format: '2004-08-20 18:07:13.341'
;   pfname: the name of the postscript file it will write. 
;   latc: the latitude of the center point.  
;   lonc: the longitude of the center point. 
;   dsec: The time difference allowed for all events plotted (longer than dsecf).
;   dsecf: The time difference allowed for finding the closest event within dsecf 
;   (shorter than dsec); to clarify, you might want to know the closest event within 
;   1 s (dsecf), but still plot all events with in 10 s (dsec).
;   rad: the radius from the center to plot in kilometers.  

; Output: 
;  A postscript file of the map. It will also open the map for you. 
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

pro quickbox5,date,pfname,latc,lonc,dsec,dsecf,rad

; File prepartion. 

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

; Prepare the plot. Notice that ~111 km is the distance of one degree of latitude,
; and there is an extra cosine term for longitude. 

set_plot,'ps'
device,/color,filename=pfname,/inches,xsize=6.,ysize=6.
loadct,13
lat0=latc-rad/111.
lat1=latc+rad/111.
lon0=lonc-rad/111./cos(latc*!pi/180.)
lon1=lonc+rad/111./cos(latc*!pi/180.)
map_set,xmargin=[2,2],ymargin=[2,2],limit=[lat0,lon0,lat1,lon1],/continents
oplot,[lonc],[latc],psym=1,thick=6,symsize=2 ;RHESSI

typecolors=[80,80,80,80]
typesizes=[1,1,1,1]
t0=anytim(date)

mind=1.d10
midlat=1.d10
mindlon=1.d10
mindf=1.d10
mindlatf=1.d10
mindlonf=1.d10

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


; Open the file, create huge arrays for times, latitudes, and longitudes of WWLLN strikes. 
   openr,1,fname
   t=dblarr(100000)
   lat=dblarr(100000)
   lon=dblarr(100000)
   n=0l


   while (not eof(1)) do begin
       readf,1,s
       t=anytim(strmid(s,0,25))
       dt=t-t0

; Only read the lines that are within dsec of date. 
       if abs(dt) gt dsec then continue

       lat=1.*strmid(s,27,8)
       lon=1.*strmid(s,37,9)
       if lon lt 0. then lon+=360.

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
      
       if (d GE rad) then continue
   
       thk = 3    
       oplot,[lon],[lat],psym=4,thick=thk,color=typecolors[i],symsize=typesizes[i]

; Get the time difference for the closest WWLLN strike.
; Save its time and distance. 
       if d lt mind then begin
            mind=d
            mindlat=lat
            mindlon=lon
            mindi=i
            minddt=abs(dt)
       endif

; Get the closest WWLLN strike that is within time dsecf. 
; Save its time and distance. 
       if d lt mindf and abs(dt) lt dsecf then begin
            mindf=d
            mindlatf=lat
            mindlonf=lon
            mindif=i
            minddtf=abs(dt)
       endif
    endwhile
    close,1
endfor

; Plot and print specs. 

oplot,[mindlonf],[mindlatf],psym=6,color=255,symsize=1,thick=5

print,'Minimum distances (within long and short time differences): ',mind, mindf
print,'Minimum time differences: (within long and short time differences): ',minddt, minddtf


device,/close

spawn,'evince '+pfname+' &'

end



