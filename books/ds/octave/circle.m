# circle.m
function z=f(x,y)
 z=x^2+y^2-1;
endfunction
dx=0.05; dy=0.05;
x=-1/sqrt(2); y=-x;
xx=[x];yy=[y];
while (x<0.8)
 x=x+dx; y=fsolve(@(y) f(x,y),y); #1変数関数 f(y) にする文法
 xx=[xx,x]; yy=[yy,y];
endwhile
hold on;
plot(xx,yy,"o");
xx=[x];yy=[y];
while (y>-0.8)
 y=y-dy; x=fsolve(@(x) f(x,y),x); #1変数関数 f(x) にする文法
 xx=[xx,x]; yy=[yy,y];
endwhile
plot(xx,yy,"x");
xx=[x];yy=[y];
while (x>-0.8)
 x=x-dx; y=fsolve(@(y) f(x,y),y);
 xx=[xx,x]; yy=[yy,y];
endwhile
plot(xx,yy,"*");
xx=[x];yy=[y];
while (y<0.8)
 y=y+dy; x=fsolve(@(x) f(x,y),x);
 xx=[xx,x]; yy=[yy,y];
endwhile
plot(xx,yy,"+"); xlabel("x"); ylabel("y");
#print -deps -F:24 circle.eps