clear; clf(); //変数クリア; 描画クリア;
///// 同次変換 /////
function x = H(x0, r, angle)
    A = [ cos(angle), -sin(angle), r(1); ...
          sin(angle),  cos(angle), r(2); ...
              0,           0,       1 ];//同次変換行列
    x1 = A*[x0;1];  //ダミー成分1を付けて同次変換
    x = x1(1:2);    //ダミー成分の除去
endfunction
///// データ点列の変換 /////
function points = trans_object(r, angle)
    /// 初期のデータ点列(三角形) ///
    points=[ 2,-4, 2; ...           //x座標
             2,-1,-1 ];             //y座標
    n=size(points,'c');             //点の数
    /// 座標変換 ///
    for i=1:n
        oldp = points(:,i);
        newp = H(oldp, r, angle); //同次変換
        points(:,i) = newp;
    end
endfunction
///// データ点列の描画 /////
function draw_object(points)
    drawlater; clf();               //描画延期; 描画クリア;
    points=[points, points(:,1)];   //描画用に図形を閉じる
    plot(points(1,:),points(2,:),"r-"); //折れ線グラフ
    g=gca();  g.isoview="on";       //座標軸の取得; 縦横比1;
    g.data_bounds=[-10,-10;10,10];  //座標軸の範囲
    p=gce(); p.children.thickness=3;//直前の描画の線の太さ
    xlabel("x"); ylabel("y");       //軸ラベル 
    xgrid(2); drawnow;              //グリッドon; 描画更新;
endfunction
///// 処理の実行 /////
rr=[0;0]; theta=0;   //初期姿勢
points=trans_object(rr, theta*%pi/180);
draw_object(points);
while(1) //意図的な無限ループ
    disp([rr',theta]); disp(points);    //コンソールへ数値を出力
    txt = ['rx','ry','theta (deg)'];
    sig0 = string([rr;theta])';
    sig = x_mdialog("Position and Angle", txt, sig0);
    if ( size(sig) == 0 )       //もし入力が空なら
        break;          //while脱出
    end
    rr(1) = evstr(sig(1));      //x方向変位
    rr(2) = evstr(sig(2));      //y方向変位
    theta = evstr(sig(3));      //姿勢角
    points=trans_object(rr, theta*%pi/180);
    draw_object(points);        //データ点列の描画
end
