a1 = 1.3789;
a2 = -0.9506;
b = 1;          % ���ݺ�������
a = [1,-a1,-a2];  % ���ݺ�����ĸ
% ���㹲���Ƶ��
p = roots(a);
disp(strcat('�������λΪ',num2str(angle(p(1))/pi),'��'));
% �����㼫��ͼ
figure;
zplane(b,a);
title("�㼫��ͼ")
% ����Ƶ����Ӧ
figure;
n = 2001;       % Ƶ����Ӧ����
[h,w] = freqz(b,a,'whole',n);   % ��ȡƵ����Ӧ
subplot(1,2,1);
plot(w/pi,abs(h));  % ��ͼ����
xlabel("freq/pi");
ylabel("����");
title("Ƶ����Ӧ�����ȣ�");
subplot(1,2,2);
plot(w/pi,angle(h)*180/pi); % ��ͼ��λ
xlabel("freq/pi");
ylabel("���/��");
title("Ƶ����Ӧ����λ��");
% ���Ƶ�λ��ֵ��Ӧ
figure;
subplot(1,2,1);
[h,t]=impz(b,a);    % ��ȡ��λ��ֵ��Ӧ������1��
plot(t,h);
title("��λ��ֵ��Ӧ��impz��");
subplot(1,2,2);
x = double(t==0);   % ��ȡ��λ��ֵ��Ӧ������2��
y = filter(b,a,x);  % ���ɲ��˲�
plot(t,y);
title("��λ��ֵ��Ӧ��filter��");