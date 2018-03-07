//
// "vib-bode.sce"
//
clear; clf();
m=1; c=0.2; k=1; P=1;
zeta = c/( 2*sqrt(m*k) ); //表3.1
omn = sqrt(k/m);          //表3.1
function y = K(Om)
  global zeta;
  y=1/sqrt((1-Om^2)^2 +(2*zeta*Om)^2);
endfunction
function y = phase_diff(Om)
  global zeta;
  y=-atan((2*zeta*Om),(1-Om^2)); //atan2(y,x)
endfunction
om = linspace(0.2,1.6,100);
A = P/(m*omn^2);
for i=1:100
  R(i) = A*K(om(i)/omn);
  phi(i) = phase_diff(om(i)/omn);
end
subplot(2,1,1); plot(om, R);
xlabel("om"); ylabel("Amplitude");
title("Amplitude Ratio"); xgrid();
subplot(2,1,2); plot(om, phi);
xlabel("om"); ylabel("phi");
title("Phase Difference"); xgrid();