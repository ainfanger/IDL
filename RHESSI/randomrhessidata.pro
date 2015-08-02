;;
;; Function: randomrhessidata
;;
;; Purpose:
;; Get data from RHESSI not limited to a certain amount of time.
;; This is good for doing background statistics on data gathere
;; over the entire mission.
;;
;; It gets data in ten minute increments from random days and then
;; returns an hsi_event struct except with the added variable
;; realtime which holds the time of the count relative to the
;; universal time standard, 01-Jan-1979 and an interval flag. 
;;
;; Inputs:
;; numintervals: the number of intervals of RHESSI data you want to look at.
;; dt: the amount of time you want to get per interval
;; chance: a random integer to let randomu start its randomness.
;; number generation sequence. 
;; 
;; Options:
;; /rearsonly = only look at rear segments.
;;
;; Outputs:
;; rhessicount struct: Object similar to RHESSI's object except
;; now you have two new parameters: (1) realtimes and (2) interval 
;; which is an integer flag that tells you for which ten minute
;; interval the count belongs. This would be important for time series
;; analysis. You would not want to start binning the counts into
;; histograms right away because you would be missing much in between
;; data. 
;; 
;; Example: 
;; IDL> d  = randomrhessidata(1,1)
;; IDL> print, anytim(min(d.realtime),/ccsds)
;; 2002-03-15T23:59:59.987
;; print, anytim(max(d.realtime),/ccsds)
;; 2011-10-15T14:46:33.465
;; 
;; Author:
;; Alexander Infanger
;; ainfange@ucsc.edu (Feel free to contact if you have issues.) 
;;
;; Updates:
;; Original Release:  07/08/2015 Alexander Infanger
;; Account for RHESSI binary microsecond sensitivity: 07/31/2015 Alexander Infanger
;; Changed it so you can choose your number of intervals and the time, dt Alexander Infanger
;;

function randomrhessidata, numintervals, dt, chance, rearsonly=rearsonly

;; Get the data and check the keyword to see if the user wants
;; only to use rear segments. 

  if keyword_set(rearsonly) eq 1 then seg = [intarr(9),intarr(18)+1]$
  else seg = intarr(27)+1
  
;; Start time is arbitrarily chosen near the beginning of the mission
;; at a time that has no data problems. Endtime is exactly three days
;; before the system time. We will randomly select 10 minute intervals
;; between these two times. 
 
  initialtime = anytim('2002-Mar-16 00:00:00.000')
  now = anytim(systim())
  endtime = now - 86400.d*3.d
  timerange = endtime-initialtime
  
;; Create random numbers in order to decide random time
;; intervals. Sort the numbers and ensure they are unique. 

  randomnumbers=randomu(chance,numintervals-1,/double)
  rrandomnumbers = randomnumbers(uniq(randomnumbers,sort(randomnumbers)))

;; Create the random dates.  

  randomdates = initialtime+timerange*rrandomnumbers
  i = indgen(n_elements(randomdates))

;; Check to see if two of the ten minute intervals intersect. If so,
;; ask the user to try another chance number. 

  dist = where(abs(randomdates(i)-randomdates(i-1)) le dt,nd)   
  IF nd GT 1 THEN BEGIN
     print, 'An unlikely event has occured. Please try another chance number.'
     stop
     RETURN,-1
  ENDIF

;; Initialize RHESSI object and fetch data from intialtime. 

  o = hsi_eventlist()
  d=o->getdata(obs_time_interval = initialtime+[0.d,dt],$
               a2d_index_mask=seg,time_range=[0,0])
 
;; Account for the binary microsecond sensitivity of the detector. 
  d=d[uniq(d.time/4)]
 
;; The get method will allow us to use the time reference ut_ref of
;; the beginning of our data time. Note that d.times are binary
;; seconds that starts at zero, and so I need to create a new struct
;; that has the extra field, realtime, to calculate and store the
;; times from the universal reference time.
 
  q=o->get()

;; Create the new struct with double realtime. 

  struct = {rhessicount,INHERITS hsi_event, realtime:0.0d, interval:0}
  A = replicate(struct,n_elements(d))

;; Create a struct of structs: one rhessicount for each ten
;; time interval to make it clear to the user that you can't
;; do time analysis on all at once until you put them together. 

;; Struct_Assign transfers over the information from the original
;; hsi_event struct to the new and improved rhessicount struct, minus
;; double realtime. We calculate realtime from the binary seconds as
;; follows: ut_ref + time/(1024.d)^2 

  Struct_Assign, d, A
  A.realtime = q.ut_ref+d.time/(1024.d)^2
  A.interval = 0

;; Go through the number of hours and conctaneate our structs to
;; achieve larger and larger data samples. 

  FOR i=0,numintervals-2 DO BEGIN
     nodata = 0 
     l = o->getdata(obs_time_interval = randomdates[i]+[0.d,dt],$
                    a2d_index_mask=seg,time_range=[0,0])
   
;; Check several ways to see if we got no data, then check for bad data
;; gathering a gap.

     IF size(l, /type) NE 8 THEN BEGIN
        nodata = 1
     ENDIF ELSE IF n_tags(l) EQ 0 THEN BEGIN
        nodata = 1
     ENDIF ELSE  BEGIN 
        wh = where(l.time ge 0, nwh)
        IF nwh eq 0 THEN nodhelpata = 1
     ENDELSE

;; If we have data get the time reference s.ut_ref, create the new
;; count struct B, define the real times, and concatenate B with the
;; original struct A. Do this until we have the correct amount of
;; hours of data. 

     IF nodata EQ 0 then begin
        s=o->get()
        l = l[uniq(l.time/4)]
        B = Replicate(struct,n_elements(l))
        Struct_Assign,l,B
        B.realtime = s.ut_ref+l.time/(1024.d)^2
        B.interval = i+1
        A = [A,B]

;; If we do not have data shift the random time up ten minutes and see
;; if we get data from that interval. 

     ENDIF ELSE BEGIN
        randomdates[i]=randomdates[i]+600.d
        i=i-1
        CONTINUE
     ENDELSE


  ENDFOR
  HEAP_FREE, o

  RETURN, A
END


  
