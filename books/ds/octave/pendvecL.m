# "pendvecL.m"
global m l c g;
m=1; l=1; c=1; g=9.8;
function dv=eom_v(v,t)
 global m l c g;
 dv(1) = v(2);
 dv(2) = -c/(m*l*l)*v(2)-g/l*v(1);
endfunction
function dw=eom_w(w,t)
 global m l c g;
 dw(1) = w(2);
 dw(2) = -c/(m*l*l)*w(2)+g/l*w(1);
endfunction
nx=20; ny=15;
clf; hold off;
rx=[-2,8];ry=[-6,6];
vectorfield("eom_v",nx,ny,rx,ry,0.5);
axis([rx(1),rx(2),ry(1),ry(2)]);
tt=linspace(0,10,200);
hold on;
xx=lsode("eom_v",[0.5;-4.8],tt); #[1.2;6]
plot([0.5],[-4.8],"ko",'markersize',10);
plot(xx(:,1),xx(:,2),"k-",'linewidth',5)
xlabel("v",'fontsize',42); ylabel("dv/dt",'fontsize',42); drawnow();
sleep(3);
clf; hold off;
rx=[-2-pi,8-pi];ry=[-6,6];
vectorfield("eom_w",nx,ny,rx,ry,0.5);
axis([rx(1),rx(2),ry(1),ry(2)]);
hold on;
plot([1.4-pi,1.6-pi],[6,6],"ko",'markersize',10);
xx=lsode("eom_w",[1.4-pi;6],tt);
plot(xx(:,1),xx(:,2),"k-",'linewidth',5)
xx=lsode("eom_w",[1.6-pi;6],tt);
plot(xx(:,1),xx(:,2),"k-",'linewidth',5)
xlabel('w=x-{\pi}','fontsize',42);
ylabel("dw/dt",'fontsize',42); drawnow();