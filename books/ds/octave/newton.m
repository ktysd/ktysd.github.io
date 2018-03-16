# "newton.m"
function y=f(x)
 y=x^2-1;
endfunction
function y=df(x)
 y=2*x;
endfunction
function xx=newton(x0,n)
 x=x0;
 xx=[x];
 for i=1:n
  x = x - f(x)/df(x);
  xx = [xx,x];
 endfor
endfunction
hold on; rand('seed',1);
for i=1:50
 x0=10*rand(1)-5; # -5<x<5 の一様乱数
 xx=newton(x0,10);
 plot(0:10,xx);
 xlabel('n'); ylabel('x_n');
endfor
#print -deps -F:24 newton.eps;