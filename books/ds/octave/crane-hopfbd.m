# "crane-hopfbd.m" ※旧"invp-hopfbd.m"
global A bb K3 K4;
K3=3; K4=5; #台車制御のゲイン(固定)
M=2/3; m=1/3; l=1; g=-9.8;
A=[0,1,0,0; 0,0,-m/M*g,0; 0,0,0,1; 0,0,(M+m)/(M*l)*g,0];
bb=[0;1/M;0;-1/(M*l)];
### 閉ループ系の行列 ###
function m=H(K1,K2)
 global A bb K3 K4;
 KK=[K1,K2,K3,K4];
 m=A-bb*KK; #
endfunction
### 分岐方程式 ###
function y=bifeqn(K1,K2)
 m=H(K1,K2); #閉ループ系
 aa=poly(m)(2:rows(m)+1);
 y=aa(3)^2-aa(1)*aa(2)*aa(3)+aa(1)^2*aa(4);
endfunction
### Hopf分岐点の概算 ###
K2=7; KK1=linspace(20,25,100); #invp-hopf.mを参考に
yy=[];
for i=1:100
 yy=[yy,bifeqn(KK1(i),K2)];
endfor
plot(KK1,yy); xlabel("K1"); ylabel("bifeqn");
grid on; sleep(3); #グラフを見ると22.5付近でy=0
### 初期解 ###
format long;
K1=fsolve(@(K1) bifeqn(K1,K2),22.5) #概算より
          #1変数関数 bifeqn(K1) にする文法
BF1=[K1]; BF2=[K2];
### 接続1 ###
dK=0.1;
while (K2<=30)
 K2=K2+dK; K1=fsolve(@(K1) bifeqn(K1,K2),K1);
 BF1=[BF1,K1]; BF2=[BF2,K2];
endwhile
### 接続2 ###
K1=BF1(1); K2=BF2(1);
BF1=fliplr(BF1); BF2=fliplr(BF2); #接続1とグラフを継げたいので，逆順に
while (K1<=30)
 K1=K1+dK; K2=fsolve(@(K2) bifeqn(K1,K2),K2);
 BF1=[BF1,K1]; BF2=[BF2,K2];
endwhile
plot(BF1,BF2,"k-",'linewidth',5);
axis([5,30,5,30]);
xlabel("K1"); ylabel("K2");
### 固有値の確認 ###
hold on; format short;
p0=[BF1(170),BF2(170)]; #分岐点の1つ
ps=p0+[2,2]; pu=p0-[2,2];
plot(ps(1),ps(2),"k*",'markersize',10);
plot(p0(1),p0(2),"ko",'markersize',10);
plot(pu(1),pu(2),"k+",'markersize',10);
printf("(*)"); Stable_eigenvalue=eig(H(ps(1),ps(2)))
printf("(o)"); Imaginary_eigenvalue=eig(H(p0(1),p0(2)))
printf("(+)"); Unstable_eigenvalue=eig(H(pu(1),pu(2)))
#print -deps -F:24 invp-hopfbd.eps