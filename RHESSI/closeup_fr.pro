; + 
; Procedure: closeup_fr
;
; Purpose:
;   This plots a time series of RHESSI counts. 
;
; Inputs: 
;   date: anytim piendly date
;   dt: width of window in ms, e.g. 3 
;   (shift): shift the window in ms
;   (title): title the plot, e.g. 'Vetoed event: Concentration Parameter'
;   (filenameflag): an extra flag to put on your filenames, e.g.'Concentration-veto'
;    /postscript: create a postscript of the event whose name is the date
; 
; Example:
;   closeup_fr,'17-Feb-02 19:51:27.852', 3, shift=.2, title='Vetoed event: Poisson'
;
; Updates: 
; All previous versions can be found in thunder: ainfanger/tgf/old_programs
; 07/27/2015: Added title and screenshot keywords. Added postscript option. Added concentration. 
;
; Authors:
;   Prof. David Smith (UC Santa Cruz)
;   Alex Infanger (For more info, please contact: ainfange@ucsc.edu)
; +



pro closeup_fr, date,dt,shift=shift, title=title, postscript=postscript, filenameflag=filenameflag,nofront=nofront,d

  shift=fcheck(shift,0.d )  

  loadct,13  
  !p.multi=[0,5,2]
  !x.margin=[4,3]


; Grab two seconds of data from all segments. 

  o=hsi_eventlist()
  seg=intarr(27)+1        	 
  d=o->getdata(obs_time_interval=anytim(date)+[-1.,1.],$
  a2d_index_mask=seg,time_range=[0,0])
  s=o->get()
  ttrig = anytim(date)
  t0 = anytim(strmid(date,0,19))


; Convert channels to keV energies. 
  kev_energy = findgen(n_elements(d))
  params = hsi_get_e_edges(gain_time_wanted = string(anytim(date, /atime)), $
                             /coeff_only)
  fuld = where(d.channel EQ -1 AND d.a2d_index LT 9, nfuld)
  ruld = where(d.channel EQ -1 AND d.a2d_index GE 9, nruld)
  fres = where(d.channel EQ -2 AND d.a2d_index LT 9, nfres)
  rres = where(d.channel EQ -2 AND d.a2d_index GE 9, nrres)
  kev_energy =  d.channel*params[d.a2d_index, 1]+params[d.a2d_index, 0]
  IF nfuld GT 0 THEN kev_energy[fuld] = 5000.
  IF nruld GT 0 THEN kev_energy[ruld] = 30000.
  IF nfres GT 0 THEN kev_energy[fres] = 60000.
  IF nrres GT 0 THEN kev_energy[rres] = 60000.
  t=s.ut_ref+(d.time)/(1024.d)^2

  tsec=anytim(date)-t0
  tmsec=tsec*1000.d
  xr=[-dt,dt]+shift

  !p.multi=[0,1,1]
  !x.margin=[12,3]

; Create window to plot and begin plotting. Go through each rear detector (first where statement), 
; which has both low (0:8) and high energy segments(18:27). Then go through the front segments (0:9)
; (the second where statement).
  if keyword_set(filenameflag) then filename = strjoin(strsplit(filenameflag + date + '_fr.ps', /extract),'-') else $
    filename = strjoin(strsplit(date+'_fr.ps', /extract),'-')

    
  IF keyword_set(postscript) then begin
    rpsopen, filename, xs=9, ys=6, /inches, /color, /encapsulated
  ENDIF ELSE BEGIN
    window,0,xsize=800,ysize=600
  ENDELSE
  
  IF keyword_set(title) THEN gtitle = title ELSE gtitle = 'RHESSI Time Series'

  plot,[0],[0],xticks=3,$
     /ylog,yrange=[1.,100000.],$
     psym=5,color=255,$
           xrange=xr, xtitle='Time rel. to '+date+' in ms',$
                      ytitle='Energy, keV',title=title
  energy=0.
  print, 'detector    tot-counts    tot-energy(keV)'

  conc1 = 0 

  all = where(abs(t-ttrig) LE dt*.001d, nallwithindt)

  FOR i=0,8 DO BEGIN

       w=where(d.a2d_index EQ 9+i OR d.a2d_index EQ 18+i $
         AND abs(t-ttrig) LE 0.5d ,nw)
       IF nw EQ 0 THEN CONTINUE	
       tclose1 = t[w]-t0
       tclose2 = tclose1*1000.d
       e_close=kev_energy[w]
       tpl = tclose2-tmsec
       ww=where(tpl GT xr[0] AND tpl LT xr[1],nww)
       IF nww GT 0 THEN energy += total(e_close[ww])
       IF nww GT 0 THEN print,i,nww,total(e_close[ww])
       oplot,tpl,e_close,psym=5,color=255-(8-i)*25,symsize=8.-i/1.4


; See which detector has max percent of counts.
      within_dt = where(d.a2d_index EQ 9+i OR d.a2d_index EQ 18+i $ 
          AND abs(t-ttrig) LE dt*.001d, nwithindt)

      conc2 = (1.*nwithindt)/(1.*nallwithindt)
      IF conc2 GT conc1 THEN conc1 = conc2 

;fronts
      if not keyword_set(nofront) then begin

       w=where(d.a2d_index EQ i AND abs(t-ttrig) LE 0.5d ,nw)
	     IF nw EQ 0 THEN CONTINUE
       tclose1 = t[w]-t0
       tclose2 = tclose1*1000.d
       e_close=kev_energy[w]
       tpl = tclose2-tmsec
       ww=where(tpl GT xr[0] AND tpl LT xr[1],nww)
       IF nww GT 0 THEN energy += total(e_close[ww])
       IF nww GT 0 THEN print,i,nww,total(e_close[ww])
       oplot,tpl,e_close,psym=4,color=255-(8-i)*25,symsize=8.-i/1.4

      endif

  ENDFOR
  print,'Total energy: ',energy/1000., ' MeV'
  oplot,[-dt,dt]+shift,[18000.,18000.],psym=0
  oplot,[-dt,dt]+shift,[2800.,2800.],psym=0,color=255
  oplot,[-dt,dt]+shift,[20.,20.],psym=0,linestyle=2,color=255
 
  IF KEYWORD_SET(postscript) THEN rpsclose
  print, 'Concentration (using all non-ULD energies): ' + string(conc1)

END


 
