# "fpen-lyap.m"
global c k P omeg;
c=0.3; k=1; P=2.7; omeg=1.0; T=2*pi/omeg;
n1=1000; #無視する過渡応答
n2=2000;  #データ数
x0=[0;0;1;1];
### カオスのリアプノフ指数 ###
[xx,lam]=fpen_lyap(x0,T,n1,n2);
lyap=mean(lam)
x=mod(xx(:,1).+pi,2*pi).-pi; #角度を-πからπに収める変換
plot(x,xx(:,2),"."); sleep(3);
plot(lam,'.;{/Symbol l_k};'); hold on;
plot(lyap*ones(size(lam)),'-;{/Symbol l};','linewidth',8);
xlabel("k"); ylabel("Lyapunov exponent");
drawnow(); hold off;
#print -deps2 -F:24 fpen-lyap.eps