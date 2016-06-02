function getPointsTan(str,xmin,xmax)
  f = inline(str);      % turn input into function of x 
  z = inline('-1*abs(f(x))');
  zmax = num2str(abs(f(xmax)));
  y = inline(['z(x)+' zmax], 'x');
 
  
  %% Range
  ymax = y(xmin);
  ymin = y(xmax);
  range = (ymax - ymin);
  numLayers = range / 0.42;
  numLayers = int16(numLayers);
  printf('numlayers %f\n', numLayers);
  layer = 0;
  ycoord = 0.2;

  
  filename = [str ".gcode"];
  fid = fopen(filename,'w+t');
  inString = {"G21\n","M107\n","M190 s55\n","M104 s196\n","G28\n","G1 z5 F5000\n","M109 s196\n","G90\n","G92 E0\n","M83\n G0 X100 Y100\n"};
  for i=1:(size(inString))(2)
    fputs(fid,inString{i});
  endfor
  
  for n = 0:4
         xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.2 * n);
        layerChange = ['G1 Z' num2str(0.2) " F900\n" "G1 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100)  "\nG1 E0.00000 F900\n"];
        fputs(fid, layerChange);
        outString = ["G01 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) "\n"];
        fputs(fid, outString);
        outString = ["G02 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) " I" num2str(-2*xcoord) " J" num2str(-2*xcoord) " E" num2str(6) "\n"]; 
        fputs(fid, outString);
  
  
  endfor
  
  while (layer < numLayers)
  spd = 900/sqrt(layer+1);
    for n = 0:1
       xcoord = (fzero(@(x) y(x)-ycoord,[0,100]))
       deg = atand(xcoord/ycoord);
     if(deg < 45)
      layerChange = ['G1 Z' num2str(ycoord) " F" num2str(spd) "\n" "G1 X" num2str(xcoord+100) " Y" num2str(xcoord+100)  "\nG1 E0.00000 F" num2str(spd) " \n"];
      fputs(fid, layerChange);
      altx = 0;
      alty = ((ymax-ycoord)/xcoord)*altx + ycoord; 
      xcoord = (fzero(@(x) y(x)-alty,[0,100])) - (0.6 * n);
      
        if (xcoord < 0.0001)
          xcoord = 0;
        endif
        evalue = (sqrt(xcoord^2 + xcoord^2) * .35); 
        if (xcoord > 0)
          outString = ["G01 X" num2str(xcoord+100) " Y" num2str(xcoord+100) "\n"];
          fputs(fid, outString);
          outString = ["G02 X" num2str(xcoord+100) " Y" num2str(xcoord+100) " I" num2str(-xcoord) " J" num2str(-xcoord) " E" num2str(evalue) "\n"]; 
          fputs(fid, outString);
        endif
      
      altx = altx + 1;
   
     else  
        layerChange = ['G1 Z' num2str(ycoord) " F" num2str(spd) "\n" "G1 X" num2str(xcoord+100) " Y" num2str(xcoord+100)  "\nG1 E0.00000 F" num2str(spd) "\n"];
        fputs(fid, layerChange);
        ycoord = 0.42 * layer; 
        xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.6 * n);
        if (xcoord < 0.0001)
          xcoord = 0;
        endif
        evalue = (sqrt(xcoord^2 + xcoord^2) * .35); 
        if (xcoord > 0)
          outString = ["G01 X" num2str(xcoord+100) " Y" num2str(xcoord+100) "\n"];
          fputs(fid, outString);
          outString = ["G02 X" num2str(xcoord+100) " Y" num2str(xcoord+100) " I" num2str(-xcoord) " J" num2str(-xcoord) " E" num2str(evalue) "\n"]; 
          fputs(fid, outString);
        endif
     end
    endfor
    endLayer = ["G1 F" num2str(spd) " E0\nG92 E0\n"];
    fputs(fid, endLayer);
    layer = layer + 1; 
    ycoord = 0.42 * layer; 
    
  endwhile

  inStrings = {"G1 X0 Y0 Z0.2 \n M104 S0 \n","G28 X0\n","M84\n"}
  for i=1:(size(inStrings))(2)
    fputs(fid,inStrings{i});
  endfor  
  
endfunction
