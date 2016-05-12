function [output] = getPoints(str,xmin,xmax)
{
  f = inline(str);      % turn input into function of x 
  z = inline('abs(f(x))');
  zmax = num2str(z(xmax));
  y = inline(['z(x)-' zmax]);
  f(1);
  z(1);
  f(1);  
  
  
}
endfunction
