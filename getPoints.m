function getPoints(str,xmin,xmax)
  clc
  f = inline(str);      % turn input into function of x 
  z = inline('-1*abs(f(x))');
  zmax = num2str(abs(f(xmax)));
  y = inline(['z(x)+' zmax]);
  
  %% Range
  ymax = y(xmin);
  ymin = y(xmax);
  range = ymax - ymin;
  numLayers = range / 0.42;
  numLayers = int16(numLayers);
  layer = 0;
  fid = fopen("ashwin.gcode",'w+t');
  inString = {"G21\n","M107\n","M190 s55\n","M104 s196\n","G28\n","G1 z5 F5000\n","M109 s196\n","G90\n","G92 E0\n","M82\n"};
  for i=1:(size(inString))(2)
    fputs(fid,inString{i});
  endfor
  while (layer <= numLayers)
    for n = 0:2
      ycoord = 0.6 * layer
      xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.6 * n);
      if (xcoord < 0.0001)
        xcoord = 0;
      endif
      evalue = (2 * pi * xcoord); 
      if (xcoord > 0)
        outString = ["G01 X" num2str(xcoord) " Y0 Z" num2str(ycoord) "\n"];
        fputs(fid, outString);
        outString = ["G02 X" num2str(xcoord) " Y0 Z" num2str(ycoord) " I" num2str(0 - xcoord) " J0 K" num2str(ycoord) " E" num2str(evalue) "\n"]; 
        fputs(fid, outString);
      endif
    endfor
    layer = layer + 1;  
    fputs(fid,"G1 E1.00000 F1800.000\nG92 E0\n")
  endwhile

  inString = {"M104 S0 \n";"G28 X0\n";"M84\n"}
  for i=1:(size(inString))(2)
    fputs(fid,inString{i});
  endfor  
  
endfunction
