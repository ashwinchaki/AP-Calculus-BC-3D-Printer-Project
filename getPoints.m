function getPoints(str,xmin,xmax)

  f = inline(str);      % turn input into function of x 
  z = inline('-1*abs(f(x))');
  zmax = num2str(abs(f(xmax)));
  y = inline(['z(x)+' zmax]);
  
  %% Range
  ymax = y(xmin);
  ymin = y(xmax);
  range = (ymax - ymin)*10;
  numLayers = range / 0.6;
  numLayers = int16(numLayers);
  extrusion = 2.5;
  

  layer = 0;
  fid = fopen('gcode.txt','w');
  gsetup = 'G21 ; set units to millimeters\nM107\nM190 S55 ; wait for bed temperature to be reached\nM104 S196 ; set temperature\nG28 ; home all axes \nG1 Z5 F5000 ; lift nozzle \nM109 S196 ; wait for temperature to be reached \nG90 ; use absolute coordinates\nG92 E0\nM83 ; use realtive distances for extrusion\n';
  fputs(gsetup); 
  
  while (layer < (numLayers))
    fprintf('G1 E1.00000 F1800.000\nG92 E0\n');
    ycoord = 0.6 * layer;
    xcoord = fzero(@(x) y(x)*10-ycoord,[0,100]);
    for n = 0:2
      if ((xcoord-0.2) > 0)
      xcoord = xcoord - 0.2*n;
      fputs("G01 X%f Y0 Z%f\n",xcoord+100,ycoord+100);
      fputs("G02 X%f Y0 Z%f I%f J0 K%f E%f\n",xcoord+100,ycoord+100, -xcoord-100,-ycoord-100,extrusion);
      endif
      
    endfor
    layer = layer + 1;  
  endwhile
  gfinishup = 'G92 E0 \nM104 S0 ; turn off temperature \nG28 X0  ; home X axis \nM84  ; disable motors\n';
  fputs(gfinishup);
  fclose(fid);
  

endfunction
