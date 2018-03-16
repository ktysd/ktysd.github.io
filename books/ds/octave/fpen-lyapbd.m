# "fpen-lyapbd.m"
global c k P omeg;
c=0.3; k=1; P=2.7; omeg=1.0; T=2*pi/omeg;
n1=800; #無視する過渡応答
n2=800;  #データ数
x0=[0;0;1;1];
### 周期倍加分岐のリアプノフ指数 ###
N=100; p=linspace(0.7,0.6,N+1);
hold on; lyapbd=[];
for i=1:N+1
 c=p(i); [xx,lam]=fpen_lyap(x0,T,n1,n2);
 lyap=mean(lam); graph=[p(i),lyap];
 plot(graph(1),graph(2),"."); drawnow();
 lyapbd=[lyapbd;graph];
 x0=xx(rows(xx),:)';
endfor
hold off; plot(lyapbd(:,1),lyapbd(:,2),"k-",'linewidth',5);
xlabel('c', 'fontsize', 32);
ylabel('Lyapunov exponent', 'fontsize', 32);
grid on; drawnow();
save fpen-lyapbd.dat lyapbd;
#print -deps2 -F:26 fpen-lyapbd.eps