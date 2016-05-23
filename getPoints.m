function getPoints(str,xmin,xmax)

  f = inline(str);      % turn input into function of x 
  z = inline('-1*abs(f(x))');
  zmax = num2str(abs(f(xmax)));
  y = inline(['z(x)+' zmax]);
  
  %% Range
  ymax = y(xmin);
  ymin = y(xmax);
  range = ymax - ymin;
  numLayers = range / 0.6;
%  numLayers = int16(numLayers);
  layer = 0;
  fid = fopen("gcode.txt",'w+t');
  inString = {"G21 ; set units to millimeters","M107","M190 s55","M104 s196","G28","G1 z5 F5000","M109 s196","G90","G92 E0","M82"};
  for i=1:size(inString)
    fprintf(fid,"%s\n",inString{1,i});
  endfor
  while (layer <= numLayers)
    for n = 0:2
      ycoord = 0.6 * layer;
      xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.5 * n);
      
      
%      out = printf("The y coordinate is %f, the x coordinate is %f\n",ycoord,xcoord);
%      out = printf("G01 X%f Y0 Z%f",xcoord,ycoord);
%      out = printf("G02 X%f Y0 Z%f I0 J0 K%F",xcoord,ycoord,ycoord);
    endfor
    layer = layer + 1;  
  endwhile
  
  
  

endfunction
