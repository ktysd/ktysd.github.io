///// Kalman filter /////
function [xf, xp, Pp] = KF(y,x0,P0,F,G,H,Q,R);
    //filtering
    K = P0*H'*pinv(H*P0*H'+R); //Kalman gain
    //// pinv is used instead of inv
    xf = x0 + K*( y - H*x0 ); //x_t/t <== result
    //prediction
    xp = F*xf;                //x_t+1/t
    Pp = F*P0*F' + G*Q*G' - F*K*H*P0*F'; //P_t+1/t
endfunction
