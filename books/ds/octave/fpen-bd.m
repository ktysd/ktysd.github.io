# "fpen-bd.m"
global c k P omeg;
c=0.22; k=1; P=2.7; omeg=1.0;
n1=1000; #無視する過渡応答
n2=500;  #データ数
x0=[0;0]; N=100;
p=linspace(0.7,0.6,N+1);
hold on; fpen_bd=[];
for i=1:N+1
 c=p(i); T=2*pi/omeg;
 xx=fpen_po(x0,T,n1,n2); #fpen_po.oct によるポアンカレ写像の計算
 graph=[p(i)*ones(n2,1),xx(:,1)];
 plot(graph(:,1),graph(:,2),"."); drawnow();
 fpen_bd=[fpen_bd;graph];
 x0=xx(n2,:)';
endfor
xlabel('c', 'fontsize', 32); ylabel('x_n', 'fontsize', 32); drawnow();
save fpen-bd.dat fpen_bd;
#print -deps2 -F:26 fpen-bd.eps