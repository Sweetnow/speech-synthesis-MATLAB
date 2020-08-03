a1 = 1.3789;
a2 = -0.9506;
b = 1;          % 传递函数分子
a = [1,-a1,-a2];  % 传递函数分母
p = roots(a);	% 计算极点
R = abs(p);		% 转极坐标
theta=angle(p);
delta_f = 150;	% 频率增量
delta_omg = 2*pi*delta_f/8000;	% 频率增量对应的相角增量
theta_t = zeros(length(theta),1);   
nochange = (theta==0)|(theta==angle(-1));   % 不修改实轴上的极点
theta_t(theta>0)=theta(theta>0)+delta_omg;  % 0~180°逆时针转delta_omg
theta_t(theta<0)=theta(theta<0)-delta_omg;  % -0~-180°顺时针转delta_omg
theta_t(nochange)=theta(nochange);
new_p = R.*exp(1i*theta_t); % 极坐标转直角坐标
new_a = poly(new_p);        % 还原回传递函数系数
figure;
subplot(1,2,1);             % 绘制前后图像
zplane(b,a);
subplot(1,2,2);
zplane(b,new_a);