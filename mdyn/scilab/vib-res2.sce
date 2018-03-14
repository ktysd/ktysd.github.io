//
// "vib-res2.sce"
//
clear; clf();
load("vib_res.dat","om1","xxmax");  // vib-res.sce で保存したデータ
m=1; c=0.2; k=1; P=1;
zeta = c/( 2*sqrt(m*k) ); // 表3.1
omn = sqrt(k/m);          // 表3.1
function y = K(Om)
  global zeta;
  y=1/sqrt((1-Om^2)^2 +(2*zeta*Om)^2);
endfunction
om2 = linspace(0.2,1.6,100);
A = P/(m*omn^2);
for i=1:100
  R(i) = A*K(om2(i)/omn);
end
plot(om1, xxmax,"o", om2, R,"-" );
xlabel("om"); ylabel("Amplitude");
xtitle("Response Curve (o max(x); - R)"); xgrid();
g=gca(); g.data_bounds=[0.2,0;1.6,6]; xgrid(); //座標軸の設定