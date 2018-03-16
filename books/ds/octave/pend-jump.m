# "pend-jump.m"
global c k K FR dF;
c=0.7; k=9.8;
function dx=eom(x,t)
 global c k K FR dF;
 u = -K*x(1);
 F = FR(1)+dF*t;
 dx(1) = x(2);
 dx(2) = -c*x(2) + k*sin(x(1)) + F*cos(x(1)) + u;
endfunction
K=9.5; T=200; n=120;
x0=[-0.4;0]; FR=[-0.3,0.3]; dF=(FR(2)-FR(1))/T;
tt=linspace(0,T,n);
x1=lsode("eom",x0,tt);
F1=FR(1) .+ tt*dF;
x0=x1(n,:)'; FR=-FR; dF=(FR(2)-FR(1))/T;
x2=lsode("eom",x0,tt);
F2=FR(1) .+ tt*dF;
xx=[x1;x2]; FF=[F1,F2];
for i=1:2*n
  x=sin(xx(i,1)); y=cos(xx(i,1));
  plot([0,x],[0,y],"-",'linewidth',2);
  axis([-1.5,1.5,-1.5,1.5],'square');
  title(sprintf("F=%f",FF(i)));  drawnow();
  if ( i==1 ) sleep(2);
  else sleep(0.02); endif
endfor
plot(F1,x1(:,1),"-;F increases -->;",'linewidth',2, ...
     F2,x2(:,1),"--;F decreases <--;",'linewidth',2);
xlabel("F"); ylabel("x");
axis([-0.3,0.3,-1,1]); drawnow();