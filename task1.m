a1 = 1.3789;
a2 = -0.9506;
b = 1;          % 传递函数分子
a = [1,-a1,-a2];  % 传递函数分母
% 计算共振峰频率
p = roots(a);
disp(strcat('共振峰相位为',num2str(angle(p(1))/pi),'π'));
% 绘制零极点图
figure;
zplane(b,a);
title("零极点图")
% 绘制频率响应
figure;
n = 2001;       % 频率响应数量
[h,w] = freqz(b,a,'whole',n);   % 获取频率响应
subplot(1,2,1);
plot(w/pi,abs(h));  % 绘图幅度
xlabel("freq/pi");
ylabel("幅度");
title("频率响应（幅度）");
subplot(1,2,2);
plot(w/pi,angle(h)*180/pi); % 绘图相位
xlabel("freq/pi");
ylabel("相角/°");
title("频率响应（相位）");
% 绘制单位样值响应
figure;
subplot(1,2,1);
[h,t]=impz(b,a);    % 获取单位样值响应（方法1）
plot(t,h);
title("单位样值响应（impz）");
subplot(1,2,2);
x = double(t==0);   % 获取单位样值响应（方法2）
y = filter(b,a,x);  % 生成并滤波
plot(t,y);
title("单位样值响应（filter）");