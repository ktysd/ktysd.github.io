# "bdsn-cont.m"
global c k K;
load bdsn-ini.dat; #c k K F0 x0 x00;
function y=f(x,F)
 global c k K;
 u = -K*x;
 y = k*sin(x) + F*cos(x) + u;
endfunction
### 解の接続 ###
dx=0.03; dF=0.02;
x=x0; F=F0;
xx=[x]; FF=[F];
while (F<0.04) #0.04はCode 19のグラフのカーブより目測で
 F=F+dF; x=fsolve(@(x) f(x,F),x); #掃引方向→
                  #1変数関数 f(x) にする文法
 xx=[xx,x]; FF=[FF,F];
endwhile
hold on; plot(F,x,"ro",'markersize',8); #掃引方向の切替点
while (x<0.4) #0.4はこのプログラムの実行結果を見ながら調整
 x=x+dx; F=fsolve(@(F) f(x,F),F); #掃引方向↑
                  #1変数関数 f(F) にする文法
 xx=[xx,x]; FF=[FF,F];
endwhile
plot(F,x,"ro",'markersize',8); #掃引方向の切替点
while (F<0.3) #0.3はCode 19のグラフに合わせて
 F=F+dF; x=fsolve(@(x) f(x,F),x); #掃引方向→
 xx=[xx,x]; FF=[FF,F];
endwhile
### 分岐図 ###
plot(FF,xx,"-",'linewidth',3); #分岐図
xlabel("F"); ylabel("x");
axis([-0.3,0.3,-1,1]); drawnow;
save bdsn-cont.dat c k K FF xx
#print -mono -deps -F:24 bdsn-cont.eps