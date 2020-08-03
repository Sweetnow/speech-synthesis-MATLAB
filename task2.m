NS = 8001;
% 生成200Hz信号
x=freq2sound(NS,200);
sound(x);
pause;
% 生成300Hz信号
x=freq2sound(NS,300);
sound(x);
pause;
% 按10ms分段并根据对应的PT生成信号
% PT = 80 + 5mod(m,50)
PART_LEN = floor(NS/100); % 10ms对应的长度
x = zeros(NS,1);
i = 1;
while i<NS
    x(i)=1;
    m = floor(i/PART_LEN)+1;    % 获取所在段号
    PT = 80+5*mod(m,50);        % 根据公式加信号
    i = i+PT;                   % 保证前后间隔正确
end
sound(x);
pause;
% 激励滤波后的情况
a1 = 1.3789;
a2 = -0.9506;
b = 1;          % 传递函数分子
a = [1,-a1,-a2];  % 传递函数分母
s = filter(b,a,x);
sound(s);
figure;
plot(x);
figure;
plot(s);

% 生成频率f的8kHz采样的1s语音信号
function x = freq2sound(NS,f)
T = floor(NS/f);
x = zeros(NS,1);
x(1:T:NS)=1;
end

