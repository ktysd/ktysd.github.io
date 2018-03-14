//
// "vib-tr.sce"
//
clear; clf();
function dx = model(t,x)
  om=1.6;
  dx(1) = x(2);
  dx(2) = -0.2*x(2) - x(1) + cos(om*t);
endfunction
x0 = [0; 0.3]; tt = linspace(0, 100, 800);
xx = ode(x0, 0, tt, model);
g=gca(); g.data_bounds=[0,-1.5;100,1.5];    //座標軸の設定
plot(tt,xx(1,:),"-");
xtitle("x(t)=a(t)+b(t)"); xgrid();
xlabel("t"); ylabel("x(t)");