# "eigplace.m"
global A bb KKp
### システム行列 ###
n=3;
A=randn(n,n);
bb=randn(n,1);
### 可制御性行列 ###
Uc=[bb,A*bb,A*A*bb];
### 行列Aの固有方程式 ###
aa=poly(A); # aa(1)*s^n +aa(2)*s^(n-1) +... +aa(n)*s +aa(n+1), a(1)=1
aa=fliplr(aa)(1:n); #テキスト順 s^n +aa(n)*s^(n-1) +... +aa(1)
W = Wmat(aa)
### 基底変換行列 ###
Tc=Uc*W;
### 目標の固有値と固有方程式 ###
ss=[-1-2i,-1+2i,-3]
cc=poly(diag(ss)); cc=fliplr(cc)(1:n); #テキスト順
### ゲイン ###
KKp=(cc-aa)*inv(Tc);
### 検算(閉ループ系の固有値) ###
eig(A-bb*KKp)
### シミュレーション ###
function dx=eos(x,t)
 global A bb KKp;
 ut = -KKp*x;
 dx = A*x + bb*ut;
endfunction
tt=linspace(0,10,200);
xx=lsode("eos",[1;1;1],tt);
plot(tt,xx,[";x1(t);";";x2(t);";";x3(t);"]);
xlabel("Time"); drawnow;