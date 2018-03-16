# "modexp.m"
global A Adiag;
A=[0,1;-2,-3];
v1=[1;-1]; v1=v1/norm(v1); #unit vector
v2=[1;-2]; v2=v2/norm(v2); #unit vector
T=[v1,v2]; #change of basis matrix
function dx=eos(x,t)
 global A;
 dx = A*x;
endfunction
Adiag=inv(T)*A*T;
function dy=eos_mode(y,t)
 global Adiag;
 dy = Adiag*y;
endfunction
x0=[1;0];
y0=inv(T)*x0;
n=100;
tt=linspace(0,10,n);
xx=lsode("eos", x0, tt);
yy=lsode("eos_mode", y0, tt);
zz=zeros(n,2);
for i=1:n
 zz(i,:)=(yy(i,1)*v1 + yy(i,2)*v2)';
endfor
clf; subplot(1,2,1);
plot( xx(:,1), xx(:,2), "k-;x(t);" ); hold on;
plot( zz(:,1), zz(:,2), "ko;y_1(t)*v_1+y_2(t)*v_2;" );
xlabel("x_1(t)"); ylabel("x_2(t)");
subplot(1,2,2);
plot( yy(:,1), yy(:,2), "k-;y(t);" );
xlabel("y_1(t)"); ylabel("y_2(t)"); drawnow();