clear; clf(); //変数クリア; 描画クリア;
///// 同次変換(3次元) /////
function A = Rotz(q)
  A = [cos(q), -sin(q), 0, 0; ...
       sin(q),  cos(q), 0, 0; ...
            0,       0, 1, 0; ...
            0,       0, 0, 1];
endfunction
function A = Rotx(q)
  A = [1,      0,       0, 0; ...
       0, cos(q), -sin(q), 0; ...
       0, sin(q),  cos(q), 0; ...
       0,      0,       0, 1];
endfunction
function A = Trans(r1,r2,r3)
  A = [1, 0, 0, r1; ...
       0, 1, 0, r2; ...
       0, 0, 1, r3; ...
       0, 0, 0, 1];
endfunction
///// データ点列 /////
global HandData;
///// マニピュレータ形状データの生成 /////
function points = trans_object( th ) // th=[th1,th2,th3,th4]
    /// 手首〜手先の形状データ列(4点) ///
    l1 = 0.8; l2 = 0.8; l3 = 0.8;
    hand = [ 0,    0,   0, 0; ...   //x成分
             0, -0.2, 0.2, 0; ...   //y成分
             0,  0.2, 0.2, 0; ...   //z成分
             1,    1,   1, 1 ];     //ダミー成分1
    /// 同次変換行列 ///
    R2 = Rotz( th(4) );
    T3 = Trans(0,0,l3);
    R4 = Rotx( -th(3) );
    T5 = Trans(0,0,l2);
    R6 = Rotx( -th(2) );
    T7 = Trans(0,0,l1);
    R8 = Rotz( th(1) );
    /// 形状データの生成 ///
    for i=1:4                       //手首〜手先(4点)
        oldp = hand(:,i);
        newp = R8*T7*R6*T5*R4*T3*R2*oldp;   
        xi1s(:,i) = newp;
    end
    xi4 = R8*T7*R6*T5*[0;0;0;1];    //肘
    xi5 = R8*T7*[0;0;0;1];          //肩
    xi6 = [0;0;0;1];                //根本
    xx = [ xi1s, xi4, xi5, xi6 ];   //一筆書きの点列
    points = xx(1:3,:);             //ダミー成分(4行目)除去
endfunction
///// データ点列の描画 /////
function draw_object(pts)
    drawlater; clf();               //描画延期; 描画クリア;
    param3d(pts(1,:),pts(2,:),pts(3,:));   //3次元折れ線グラフ
    g=gca(); g.isoview="on";        //座標軸の取得; 縦横比1;
    g.data_bounds=[-0.5,-0.5,0;2,2,2.5];   //座標軸の範囲
    g.rotation_angles=[75,30];      //3次元透視角度
    p=gce(); p.thickness=3;         //描画線の太さ
    p.foreground=5;                 //描画線の色番号
    xlabel("X"); ylabel("Y"); zlabel("Z"); //軸ラベル 
    xgrid(2); drawnow;              //グリッドon; 描画更新;
endfunction
///// 処理の実行 /////
thdeg = [-40, 60, 30, 90];       //初期姿勢 deg
points=trans_object( thdeg*%pi/180 );
draw_object(points);
while(1) //意図的な無限ループ
    disp(thdeg); disp(points);  //コンソールへ数値を出力
    txt = ['th1 (deg)','th2 (deg)','th3 (deg)','th4 (deg)'];
    sig0 = string(thdeg);
    sig = x_mdialog("Angles", txt, sig0);
    if ( size(sig) == 0 )       //もし入力が空なら
        break;          //while脱出
    end
    thdeg = evstr(sig)';        //姿勢角 deg 
    points=trans_object( thdeg*%pi/180 );
    draw_object(points);        //データ点列の描画
end
