# "ctrbform.m"
function [y] = chop ( x ) #計算機誤差の除去
  eps=1e-12; y=( abs(x) > eps).*x;
endfunction
### システム行列 ###
n=3;
A=randn(n,n)
bb=randn(n,1)
### 可制御性行列 ###
Uc=[bb,A*bb,A*A*bb];
### 行列Aの固有方程式 ###
aa=poly(A); # aa(1)*s^n +aa(2)*s^(n-1) +... +aa(n)*s +aa(n+1), a(1)=1
aa=fliplr(aa)(1:n) #テキスト順 s^n +aa(n)*s^(n-1) +... +aa(1)
W = Wmat(aa)
### 基底変換行列 ###
Tc=Uc*W
### コンパニオン行列 ###
Ac=chop(inv(Tc)*A*Tc)
bbc=chop(inv(Tc)*bb)