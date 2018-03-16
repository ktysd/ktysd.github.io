# "vectorfield.m"
function vectorfield(func,nx,ny,rx,ry,scal)
 xx=linspace(rx(1),rx(2),nx);
 yy=linspace(ry(1),ry(2),ny);
 uu=zeros(ny,nx); vv=zeros(ny,nx);
 for ix=1:nx
  for iy=1:ny
   x = [xx(ix),yy(iy)];
   eval(sprintf("dx=%s([xx(ix),yy(iy)],0);",func));#dx = eqn(x,0);
   uu(iy,ix) = dx(1); vv(iy,ix) = dx(2);
  endfor
 endfor
 quiver(xx, yy, uu, vv, scal, "k-");
endfunction