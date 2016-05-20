function getPoints(str,xmin,xmax)
{
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
  
  while layer < numLayers
  {
    for n = 0:2
    {
      ycoord = 0.6(layer);
      
     
    }
    
    layer = layer + 1;
  
  
  
}
endfunction
