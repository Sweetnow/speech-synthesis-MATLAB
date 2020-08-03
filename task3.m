a1 = 1.3789;
a2 = -0.9506;
b = 1;          % ���ݺ�������
a = [1,-a1,-a2];  % ���ݺ�����ĸ
p = roots(a);	% ���㼫��
R = abs(p);		% ת������
theta=angle(p);
delta_f = 150;	% Ƶ������
delta_omg = 2*pi*delta_f/8000;	% Ƶ��������Ӧ���������
theta_t = zeros(length(theta),1);   
nochange = (theta==0)|(theta==angle(-1));   % ���޸�ʵ���ϵļ���
theta_t(theta>0)=theta(theta>0)+delta_omg;  % 0~180����ʱ��תdelta_omg
theta_t(theta<0)=theta(theta<0)-delta_omg;  % -0~-180��˳ʱ��תdelta_omg
theta_t(nochange)=theta(nochange);
new_p = R.*exp(1i*theta_t); % ������תֱ������
new_a = poly(new_p);        % ��ԭ�ش��ݺ���ϵ��
figure;
subplot(1,2,1);             % ����ǰ��ͼ��
zplane(b,a);
subplot(1,2,2);
zplane(b,new_a);