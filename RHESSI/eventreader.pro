pro eventreader 
readcol,'test_times',format='A',comment=';',delimiter='x',dates
for i=0,size(dates,/n_elements)-1 do begin
   specificaa,dates[i]
   endfor
end

