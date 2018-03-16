# "optRic.m"
global a b q r tt KK;
a=1; b=1; q=100; r=1; x0=1; t1=1; #t1=5;
function dx=eos(x,t) #状態方程式
 global a b;
 u = - K(t)*x;
 dx = a*x + b*u;
endfunction
function dP=Riccati(P,t) #リッカチ方程式
 global a b q r;
 dP = -q - a*P - P*a + P*b/r*b*P;
endfunction
function y = K(t) #KK(1),...,KK(n) を補間して K(t) を求める
 global tt KK;
 y = interp1(tt, KK, t);
endfunction
n=100; tt=linspace(0,t1,n);
# リッカチ方程式を解く
rt=tt(n:-1:1);               #逆時間
PP=lsode("Riccati",0,rt);    #P(t) の数列
KK=1/r*b*PP(n:-1:1);         #K(t) の数列
clf; subplot(3,1,1); plot(rt, PP(:,1), "k-;;", 'linewidth', 1);
ylabel("P(t)",'fontsize',24);
# 状態方程式を解く (終端自由)
xx=lsode("eos",x0,tt);       #x(t) の数列
load "optbvp.dat";           #optbvp.m のデータを読む
subplot(3,1,2);
plot(tt,xx,"o;with P(t);",'markersize',8,...
     ttb,xxb,"k-;with lam(t);", 'linewidth', 1);
ylabel("x(t)",'fontsize',24);
subplot(3,1,3); uu=-KK.*xx;
plot(tt,uu,"o;with P(t);",'markersize',8,...
     ttb,uub,"k-;with lam(t);", 'linewidth', 1);
xlabel("t",'fontsize',24); ylabel("u(t)",'fontsize',24);