# "expAt.m"
A1=[0,1;-9.8,-1]; A2=[0,1;9.8,-1];
tt=linspace(0,10,200); xx=zeros(2,200);
x0=[0.5;-4.8];
for i=1:200
 xx(:,i)=expm(A1*tt(i))*x0;
endfor
clf; hold off;
plot(xx(1,:),xx(2,:),"k-",'linewidth',5);
axis([-2,8,-6,6]);
hold on;
x0a=[1.4-pi;6]; x0b=[1.6-pi;6];
for i=1:200
 xxa(:,i)=expm(A2*tt(i))*x0a;
 xxb(:,i)=expm(A2*tt(i))*x0b;
endfor
plot(xxa(1,:).+pi,xxa(2,:),"k-",'linewidth',5);
plot(xxb(1,:).+pi,xxb(2,:),"k-",'linewidth',5);
xlabel("x",'fontsize',32); ylabel("dx/dt",'fontsize',32); drawnow();