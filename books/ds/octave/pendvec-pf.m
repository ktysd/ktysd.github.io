# "pendvec-pf.m"
global c k K;
c=1; k=9.8; K=20;
function dx=eom(x,t)
 global c k K;
 u = -K*x(1);
 dx(1) = x(2);
 dx(2) = -c*x(2) + k*sin(x(1)) + u;
endfunction
function myplot(nx, ny, rx, ry, x0s)
  vectorfield("eom",nx,ny,rx,ry,1.2); hold on;
  tt=linspace(0,30,500);
  XX=[]; YY=[];
  for i=1:columns(x0s)
   xx=lsode("eom",x0s(:,i),tt);
   XX=[XX,xx(:,1)]; YY=[YY,xx(:,2)];
  endfor
  plot(XX,YY,"k-",'linewidth',2)
  axis([rx(1),rx(2),ry(1),ry(2)]);
  xlabel("x"); ylabel("dx/dt");
endfunction
clf; hold off;
subplot(2,2,1);
K=20; rx=[-2,2]; ry=[-6,6];
x01=[-1.5;-4]; x02=[1.6;3];
myplot(20,15,rx,ry,[x01,x02]); drawnow();
subplot(2,2,2);
K=9.75; rx=[-2,2]; ry=[-6,6];
x01=[-1.5;-2]; x02=[1.5;2];
myplot(20,15,rx,ry,[x01,x02]);
plot(0.15*[0;1;-1],[0;0;0],"o",'markersize',5);
drawnow();
subplot(2,2,3);
K=8; ry=[-3,3];
x01=[-1.8;1.5]; x02=[-1.8;2];
myplot(20,15,rx,ry,[x01,x02]);
plot(1.08*[0;1;-1],[0;0;0],"o",'markersize',5);