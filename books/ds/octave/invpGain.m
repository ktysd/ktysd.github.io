# "invpGain.m"
global A bb KKp
### システム行列 (倒立振子)###
n=4;
M=2/3; m=1/3; l=1; g=9.8;
A=[0,1,0,0; 0,0,-m/M*g,0; 0,0,0,1; 0,0,(M+m)/(M*l)*g,0];
bb=[0;1/M;0;-1/(M*l)];
### 可制御性行列 ###
Uc=[bb,A*bb,A*A*bb,A*A*A*bb]; #*** 4次元化 ***
### 行列Aの固有方程式 ###
aa=poly(A); # aa(1)*s^n +aa(2)*s^(n-1) +... +aa(n)*s +aa(n+1), a(1)=1
aa=fliplr(aa)(1:n); #テキスト順 s^n +aa(n)*s^(n-1) +... +aa(1)
W = Wmat(aa)
### 基底変換行列 ###
Tc=Uc*W;
### 目標の固有値と固有方程式 ###
ss=[-1,-2,-1-2*i,-1+2*i]  #*** 4次元化 ***
cc=poly(diag(ss)); cc=fliplr(cc)(1:n); #テキスト順
### ゲイン ###
KKp=(cc-aa)*inv(Tc)
### 検算(閉ループ系の固有値) ###
eig(A-bb*KKp)
### シミュレーション ###
function dx=eos(x,t)
 global A bb KKp;
 ut = -KKp*x;
 dx = A*x + bb*ut;
endfunction
tt=linspace(0,10,200);
xx=lsode("eos",[0;0;0.2;0],tt); #*** 4次元化 ***
plot(tt,xx,[";x1(t);";";x2(t);";";x3(t);";";x4(t);"]); #*** 4次元化 ***
xlabel("Time");drawnow;
save invpGain.dat KKp;