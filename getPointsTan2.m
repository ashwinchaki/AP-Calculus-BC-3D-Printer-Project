%% Function that outputs gcode given a function and bounds
function getPointsTan2(str,xmin,xmax)
  f = inline(str);      % turn input into function of x 
  z = inline('-1*abs(f(x))');
  zmax = num2str(abs(f(xmax)));
  y = inline(['z(x)+' zmax], 'x');
 
  
  %% Range and number of layers is generated
  ymax = y(xmin);
  ymin = y(xmax);
  range = (ymax - ymin)*2;
  numLayers = range / 0.42;
  numLayers = int16(numLayers);
  printf('numlayers %f\n', numLayers);
  %% Set the initial values for layer and ycoord
  layer = 0;
  ycoord = 0.2;

  %% Creates file that gcode is outputed to
  filename = ["sandra.gcode"];
  fid = fopen(filename,'w+t');
  
  %% Initial setup for gcode
  inString = {"G21\n","M107\n","M190 s55\n","M104 s196\n","G28\n","G1 z5 F5000\n","M109 s196\n","G90\n","G92 E0\n","M83\n G0 X100 Y100\n"};
  for i=1:(size(inString))(2)
    fputs(fid,inString{i});
  endfor
  
  %% Creates five concentric circle skirt that is twice the radius of the function
  for n = 0:4
         xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.2 * n);
        layerChange = ['G1 Z' num2str(0.2) " F900\n" "G1 X" num2str(4*xcoord+100) " Y" num2str(4*xcoord+100)  "\nG1 E0.00000 F900\n"];
        fputs(fid, layerChange);
        outString = ["G01 X" num2str(4*xcoord+100) " Y" num2str(4*xcoord+100) "\n"];
        fputs(fid, outString);
        outString = ["G02 X" num2str(4*xcoord+100) " Y" num2str(4*xcoord+100) " I" num2str(-4*xcoord) " J" num2str(-4*xcoord) " E" num2str(6) "\n"]; 
        fputs(fid, outString);
  
  
  endfor
  
 
  while (layer < numLayers)
  
  %% Calculates speed of the printer
  spd = 900/sqrt(layer+1);
  
    %% Creates two concentric circles for each layer of function
    for n = 0:1
    
       xcoord = (fzero(@(x) y(x)-ycoord,[0,100]))
       deg = atand(xcoord/ycoord);
       
     %% Generates a linear function to generate points when degree is less than 45
     if(deg < 45)
      layerChange = ['G1 Z' num2str(ycoord) " F" num2str(spd) "\n" "G1 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100)  "\nG1 E0.00000 F" num2str(spd) " \n"];
      fputs(fid, layerChange);
      altx = 0;
      alty = ((ymax-ycoord)/xcoord)*altx + ycoord; 
      xcoord = (fzero(@(x) y(x)-alty,[0,100])) - (0.6 * n);
      
        if (xcoord < 0.0001)
          xcoord = 0;
        endif
        %% Extrusion value calculation
        evalue = (sqrt(xcoord^2 + xcoord^2) * .35); 
        if (xcoord > 0)
          outString = ["G01 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) "\n"];
          fputs(fid, outString);
          outString = ["G02 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) " I" num2str(-2*xcoord) " J" num2str(-2*xcoord) " E" num2str(evalue) "\n"]; 
          fputs(fid, outString);
        endif
      
      altx = altx + 1;
   
     %% Point generation when angle is greater than 45
     else  
        layerChange = ['G1 Z' num2str(ycoord) " F" num2str(spd) "\n" "G1 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100)  "\nG1 E0.00000 F" num2str(spd) "\n"];
        fputs(fid, layerChange);
        ycoord = 0.42 * layer; 
        xcoord = (fzero(@(x) y(x)-ycoord,[0,100])) - (0.6 * n);
        if (xcoord < 0.0001)
          xcoord = 0;
        endif
        %% Extrusion value calculation
        evalue = (sqrt(xcoord^2 + xcoord^2) * .35);
        
        if (xcoord > 0)
          outString = ["G01 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) "\n"];
          fputs(fid, outString);
          outString = ["G02 X" num2str(2*xcoord+100) " Y" num2str(2*xcoord+100) " I" num2str(-2*xcoord) " J" num2str(-2*xcoord) " E" num2str(evalue) "\n"]; 
          fputs(fid, outString);
        endif
     end
     
    endfor
    
    %% Code to end a layer
    endLayer = ["G1 F" num2str(spd) " E0\nG92 E0\n"];
    fputs(fid, endLayer);
    
    %%Increment layer and ycoord
    layer = layer + 1; 
    ycoord = 0.42 * layer; 
    
  endwhile

  %% Commands to end print
  inStrings = {"G1 X0 Y0 Z0.2 F800\n M104 S0 \n","G28 X0\n","M84\n"}
  for i=1:(size(inStrings))(2)
    fputs(fid,inStrings{i});
  endfor  
  
endfunction
