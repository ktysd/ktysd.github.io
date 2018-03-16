# "bdsn-ini.m"
global c k K F;
c=0.7; k=9.8; K=20;
function dx=eom(x,t)
 global c k K F;
 u = -K*x(1);
 dx(1) = x(2);
 dx(2) = -c*x(2) + k*sin(x(1)) + F*cos(x(1)) + u;
endfunction
format long; K=9.5; F0=-0.3
### 平衡点の概算 ###
tt=linspace(0,200,120);
F=F0; xx=lsode("eom",[0;0],tt);
subplot(2,1,1); plot(tt,xx(:,1)); xlabel("t"); ylabel("x1");
subplot(2,1,2); plot(tt,xx(:,2)); xlabel("t"); ylabel("x2");
drawnow(); sleep(2);
x0a=xx(120,1) #最後の値=概算値
### 初期解 ###
function y=f(x)
 global c k K F;
 u = -K*x;
 y = k*sin(x) + F*cos(x) + u;
endfunction
x0=fsolve("f",x0a) #高精度化したもの
save bdsn-ini.dat c k K F0 x0 x0a;