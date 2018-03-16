# "invpLQR.m"
global A bb KKopt
### システム行列 (倒立振子)###
n=4;
M=2/3; m=1/3; l=1; g=9.8;
A=[0,1,0,0; 0,0,-m/M*g,0; 0,0,0,1; 0,0,(M+m)/(M*l)*g,0];
bb=[0;1/M;0;-1/(M*l)];
### 無限時間最適レギュレータ ###
Q=diag([10,3,7,3]); #状態x(t)の重み
R=2;                #入力u(t)の重み
[KKopt,PP,EE]=lqr(A,bb,Q,R) #最適レギュレータを求める
### シミュレーション ###
function dx=eos(x,t)
 global A bb KKopt;
 ut = -KKopt*x;
 dx = A*x + bb*ut;
endfunction
tt=linspace(0,10,200);
xx=lsode("eos",[0;0;0.2;0],tt);
plot(tt,xx,[";x1(t);";";x2(t);";";x3(t);";";x4(t);"]);
xlabel("Time");drawnow;
save invpLQR.dat KKopt;