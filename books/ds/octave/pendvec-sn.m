# "pendvec-sn.m"
global c k K F;
c=1; k=9.8; K=8;
function dx=eom(x,t)
 global c k K F;
 u = -K*x(1) + F*cos(x(1));
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
F=0.9; rx=[-1.5,1.5];ry=[-3,3];
x01=[0.53;-2]; x02=[0.5;-2];
myplot(20,15,rx,ry,[x01,x02]); drawnow();
plot([-0.58;-0.81],[0;0],"o",'markersize',8); drawnow();
subplot(2,2,2);
F=2; rx=[-2,2];ry=[-3,3];
x01=[-1.4;-1]; x02=[0.235;-2];
myplot(20,15,rx,ry,[x01,x02]); drawnow();
subplot(2,2,3);
F=-0.9; rx=[-1.5,1.5];ry=[-3,3];
x01=-[0.53;-2]; x02=-[0.5;-2];
myplot(20,15,rx,ry,[x01,x02]); drawnow();
plot(-[-0.58;-0.81],[0;0],"o",'markersize',8); drawnow();
subplot(2,2,4);
F=-2; rx=[-2,2];ry=[-3,3];
x01=-[-1.4;-1]; x02=-[0.235;-2];
myplot(20,15,rx,ry,[x01,x02]); drawnow();