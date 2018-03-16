# "expAt2.m"
global A;
A=[0,1;-9.8,-1];
function dX=eqn(X,t)
 global A;
 Xmat=reshape(X,size(A)); #行列化
 dXmat=A*Xmat; #行列微分方程式
 dX=dXmat(:); #ベクトル化
endfunction
t=1; n=100; tt=linspace(0,t,n);
X0mat=eye(size(A));
X0=X0mat(:); #ベクトル化
XX=lsode("eqn",X0,tt);
Xmat=reshape(XX(n,:),size(A)) #手製の数値解
expm(A) #組み込みの行列指数関数