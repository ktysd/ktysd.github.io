# "optlqr.m"
global A bb KK
### システム行列 ###
n=3;
A=randn(n,n);
bb=randn(n,1);
### 無限次元最適レギュレータ ###
Q=diag([1,1,1]); #状態x(t)の重み
R=2;             #入力u(t)の重み
[KK,PP,EE]=lqr(A,bb,Q,R) #最適レギュレータを求める
### シミュレーション ###
function dx=eos(x,t)
 global A bb KK;
 ut = -KK*x;
 dx = A*x + bb*ut;
endfunction
tt=linspace(0,10,200);
xx=lsode("eos",[1;1;1],tt);
plot(tt,xx,["-0;x1(t);";"-1;x2(t);";"-3;x3(t);"],'linewidth',2);
xlabel("Time"); drawnow;