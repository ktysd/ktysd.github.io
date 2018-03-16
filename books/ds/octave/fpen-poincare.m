# "fpen-poincare.m"
global c k P omeg;
n1=1000; #無視する過渡応答
n2=4000; #データ数
x0=[0;0];
c=0.61; k=1; P=2.7; omeg=1.0;
T=2*pi/omeg; #外力の周期
xx=fpen_po(x0,T,n1,n2); #ポアンカレ写像
x=mod(xx(:,1).+pi,2*pi).-pi; #角度を-πからπに収める変換
y=xx(:,2);
plot(x,y,"."); axis([-pi,pi,-0.71,3.22]);
xlabel('x_n mod {2\pi}'); ylabel('{~x{.5.}_n}'); drawnow();
print -deps2 -F:26 fpen-poincare1.eps
c=0.3;
xx=fpen_po(x0,T,n1,n2); #ポアンカレ写像
x=mod(xx(:,1).+pi,2*pi).-pi; #角度を-πからπに収める変換
y=xx(:,2);
plot(x,y,"."); axis([-pi,pi,-0.71,3.22]);
xlabel('x_n mod {2\pi}'); ylabel('{~x{.5.}_n}'); drawnow();
#print -deps2 -F:26 fpen-poincare2.eps