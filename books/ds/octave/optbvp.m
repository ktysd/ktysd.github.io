# "optbvp.m"
a=1; b=1; t1=1; q=100; r=1;
global A;
function dx=eom(x,t)
 global A;
 dx = A*x;
endfunction
A=[a, -b^2/(2*r); -2*q, -a];
expA=expm(A*t1);
aa1=expA(:,1); aa2=expA(:,2); ee1=[1;0]; ee2=[0;1];
tt=linspace(0,t1,200);
# 両端固定 ... x0 x1 既知
x0=1; x1=2; p0p1=[-aa2,ee2]\(x0*aa1-x1*ee1); ## p ... lamda
xx=lsode("eom",[x0;p0p1(1)],tt);
uu=-b/(2*r)*xx(:,2);
subplot(2,2,1); plot(tt,xx(:,1),"k-;x(t);");
title("Both sides fixed",'fontsize',24);
subplot(2,2,3); plot(tt,uu,"k-;u(t);");
xlabel("Time",'fontsize',24);
# 終端自由 ... x0 p1 既知
x0=1; p1=0; p0x1=[-aa2,ee1]\(x0*aa1-p1*ee2);
xx=lsode("eom",[x0;p0x1(1)],tt);
uu=-b/(2*r)*xx(:,2);
subplot(2,2,2); plot(tt,xx(:,1),"k-;x(t);");
title("Free endpoint",'fontsize',24);
subplot(2,2,4); plot(tt,uu,"k-;u(t);");
xlabel("Time",'fontsize',24);
xxb=xx(:,1); uub=uu; ttb=tt; save "optbvp.dat" xxb uub ttb;