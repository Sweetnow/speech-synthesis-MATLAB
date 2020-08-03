NS = 8001;
% ����200Hz�ź�
x=freq2sound(NS,200);
sound(x);
pause;
% ����300Hz�ź�
x=freq2sound(NS,300);
sound(x);
pause;
% ��10ms�ֶβ����ݶ�Ӧ��PT�����ź�
% PT = 80 + 5mod(m,50)
PART_LEN = floor(NS/100); % 10ms��Ӧ�ĳ���
x = zeros(NS,1);
i = 1;
while i<NS
    x(i)=1;
    m = floor(i/PART_LEN)+1;    % ��ȡ���ڶκ�
    PT = 80+5*mod(m,50);        % ���ݹ�ʽ���ź�
    i = i+PT;                   % ��֤ǰ������ȷ
end
sound(x);
pause;
% �����˲�������
a1 = 1.3789;
a2 = -0.9506;
b = 1;          % ���ݺ�������
a = [1,-a1,-a2];  % ���ݺ�����ĸ
s = filter(b,a,x);
sound(s);
figure;
plot(x);
figure;
plot(s);

% ����Ƶ��f��8kHz������1s�����ź�
function x = freq2sound(NS,f)
T = floor(NS/f);
x = zeros(NS,1);
x(1:T:NS)=1;
end

