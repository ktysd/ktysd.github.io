//
// "vib-res.sce"
//
clear; clf();
function dx = model(t,x)
  dx(1) = x(2);
  dx(2) = -0.2*x(2) - x(1) + cos(om*t);
endfunction
om1 = linspace(0.2,1.6,15);
x0 = [0; 0.1]; tt = linspace(0, 100, 300);
realtimeinit(0.1); //アニメーションの時間刻み
for i = 1:15
    realtime(i);
    drawlater();       //描画延期
    om = om1(i); f = cos(om*tt);
    xx = ode(x0, 0, tt, model);
    clf(); subplot(2,1,1);
    plot(tt,f,"-",tt,xx(1,:),"-");
    xlabel("t"); ylabel("x(t)");
    xtitle(sprintf("Waveform (om = %.1f)",om));
    g=gca(); g.data_bounds=[0,-5;100,5]; xgrid(); //座標軸の設定
    drawnow;           //画面更新
    xxmax(i)=max(xx(1, 250:300)); //xx(250,1)〜xx(300,1)の最大値
end
subplot(2,1,2); plot(om1, xxmax, "o-");
xlabel("om"); ylabel("max x(t)");
xtitle("Response Curve");
save("vib_res.dat","om1","xxmax");  // vib-res2.sce で使うデータの保存