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
  numLayers = int16(numLayers);
  layer = 0;
  fid = fopen('gcode.txt','w');
  while (layer < numLayers)
    for n = 0:2
      ycoord = 0.6 * layer;
      xcoord = fzero(@(x) y(x)-ycoord,[0,100]);
      printf("The y coordinate is %f, the x coordinate is %f\n",ycoord,xcoord);
    endfor
    layer = layer + 1;  
  endwhile
  
  
  

endfunction
