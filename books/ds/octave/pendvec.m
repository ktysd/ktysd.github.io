# "pendvec.m"
global m l c g;
m=1; l=1; c=1; g=9.8;
function dx=eom(x,t)
 global m l c g;
 dx(1) = x(2);
 dx(2) = -c/(m*l*l)*x(2)-g/l*sin(x(1));
endfunction
nx=20; ny=15; rx=[-2,8]; ry=[-6,6];
hold off;
vectorfield("eom",nx,ny,rx,ry,0.5);
axis([rx(1),rx(2),ry(1),ry(2)]);
tt=linspace(0,10,200);
hold on;
xx=lsode("eom",[1.2;6],tt);
plot(xx(:,1),xx(:,2),"k-",'linewidth',5)
xx=lsode("eom",[1.4;6],tt);
plot(xx(:,1),xx(:,2),"k-",'linewidth',5)
plot([pi],[0],"ko",'markersize',10);
xlabel("x",'fontsize',32); ylabel("dx/dt",'fontsize',32); drawnow();