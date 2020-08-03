﻿function speechproc()

    % 定义常数
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('voice.pcm',100000);             % 载入语音s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    s_rec = zeros(L,1);     % 重建语音
    zi_rec = zeros(P,1);
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    % 变调不变速滤波器
    exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L,1);     % 合成语音
    % 变速不变调滤波器（假设速度减慢一倍）
    exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2*L,1);     % 合成语音

    hw = hamming(WL);       % 汉明窗
    
    remain = 0;             % 激励信号中上一帧最后一个脉冲与帧尾的距离
    remain_v = 0;           % 变速不变调激励信号中上一帧最后一个脉冲与帧尾的距离
    remain_t = 0;           % 变调不变速激励信号中上一帧最后一个脉冲与帧尾的距离
    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A, E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量

        if n == 27
        % (3) 在此位置写程序，观察预测系统的零极点图
            figure;
            zplane(A,1);    % 将生成模型的传递函数取倒数后用于滤波，即为预测模型
            title("预测系统第27帧零极点图");
            pause;
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态
        if n == 3
            [exc_now,zf_exc] = filter(A,1,s_f);     % 将生成模型的传递函数取倒数后用于滤波，即可实现预测模型
        else
            [exc_now, zf_exc] = filter(A,1,s_f,zf_exc); % zf_exc用于保证滤波器前后一致
        end
        
        exc((n-1)*FL+1:n*FL) = exc_now;

        % (5) 在此位置写程序，用filter函数和exc重建语音，注意保持滤波器状态
        if n == 3
            [s_now,zf_rec] = filter(1,A,exc_now);   % 直接利用生成模型滤波得到重建结果
        else
            [s_now, zf_rec] = filter(1,A,exc_now,zf_rec);   % zf_rec用于保证滤波器前后一致
        end
        
        s_rec((n-1)*FL+1:n*FL) = s_now;

        % 注意下面只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）

        
        % (10) 在此位置写程序，生成合成激励，并用激励和filter函数产生合成语音
        exc_syn_now = zeros(FL,1);
        start = mod(-remain-1,PT)+1;    % 计算下一个段中第一个音节的位置
        if start <= FL      % 保证不超出本段
            index = start:PT:FL;    % 按照PT的间隔设置信号为G
            exc_syn_now(index)=G; 
            remain = FL-index(end); % 计算本段后剩余无信号的区间长度
        else
            remain = remain + FL;   % 如果本段没有信号，直接将无信号区间长度+段长
        end
        if n == 3
            [s_syn_now,zf_syn] = filter(1,A,exc_syn_now);   % 直接利用生成模型滤波得到重建结果
        else
            [s_syn_now, zf_syn] = filter(1,A,exc_syn_now,zf_syn);   % zf_syn用于保证滤波器前后一致
        end
        exc_syn((n-1)*FL+1:n*FL) = exc_syn_now;
        s_syn((n-1)*FL+1:n*FL) = s_syn_now;

        % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为filter
        % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。
        FL_v = 2*FL;    % 合成激励加长一倍，速度减慢1倍
        exc_syn_v_now = zeros(FL_v,1);
        start_v = mod(-remain_v-1,PT)+1;    % 计算下一个段中第一个音节的位置
        if start_v <= FL_v                  % 保证不超出本段
            index_v = start_v:PT:FL_v;      % 按照PT的间隔设置信号为G
            exc_syn_v_now(index_v)=G; 
            remain_v = FL_v-index_v(end);   % 计算本段后剩余无信号的区间长度
        else
            remain_v = remain_v + FL_v;     % 如果本段没有信号，直接将无信号区间长度+段长
        end
        if n == 3
            [s_syn_v_now,zf_syn_v] = filter(1,A,exc_syn_v_now);  % 直接利用生成模型滤波得到重建结果
        else
            [s_syn_v_now, zf_syn_v] = filter(1,A,exc_syn_v_now,zf_syn_v); % zf_syn_v用于保证滤波器前后一致
        end
        
        exc_syn_v((n-1)*FL_v+1:n*FL_v) = exc_syn_v_now;
        s_syn_v((n-1)*FL_v+1:n*FL_v) = s_syn_v_now;
        
        % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音，听听是啥感受～
        PT_t = round(PT/2);     % 基音周期减小一半
        delta_f = 150;          % 共振频率增量
        delta_omg = 2*pi*delta_f/8000;  % 共振频率增量转极点相角增量
        ps = roots(A);          % 计算极点
        R = abs(ps);            % 极点转极坐标表示
        theta = angle(ps);
        theta_t = zeros(length(theta),1);
        nochange = (theta==0)|(theta==angle(-1));   % 实轴上的极点不变
        theta_t(theta>0)=theta(theta>0)+delta_omg;  % 0~180度范围内极点逆时针旋转delta_omg
        theta_t(theta<0)=theta(theta<0)-delta_omg;  % -0~-180度范围内极点顺时针旋转delta_omg
        theta_t(nochange)=theta(nochange);
        A_t = real(poly(R.*exp(1i*theta_t)));       % 恢复传输函数系数，共振峰频率增加150Hz后的A_t，用real去除计算误差带来的虚数部分（≈0.000i）
        exc_syn_t_now = zeros(FL,1);
        % 激励信号生成与滤波过程同上
        start_t = mod(-remain_t-1,PT_t)+1;
        if start_t <= FL
            index_t = start_t:PT_t:FL;
            exc_syn_t_now(index_t)=G; 
            remain_t = FL-index_t(end);
        else
            remain_t = remain_t + FL;
        end
        if n == 3
            [s_syn_t_now,zf_syn_t] = filter(1,A_t,exc_syn_t_now);
        else
            [s_syn_t_now, zf_syn_t] = filter(1,A_t,exc_syn_t_now,zf_syn_t);
        end
        exc_syn_t((n-1)*FL+1:n*FL) = exc_syn_t_now;
        s_syn_t((n-1)*FL+1:n*FL) = s_syn_t_now;
        
    end

    % (6) 在此位置写程序，听一听 s ，exc 和 s_rec 有何区别，解释这种区别
    % 后面听语音的题目也都可以在这里写，不再做特别注明
    disp("按任意键播放原始语音");
    pause;
    sound(s);
    disp("按任意键播放重建语音");
    pause;
    sound(s_rec);
    disp("按任意键播放激励信号");
    pause;
    sound(exc);
    disp("按任意键播放合成激励信号");
    pause;
    sound(exc_syn);
    disp("按任意键播放合成语音信号");
    pause;
    sound(s_syn);
    disp("按任意键播放变速合成语音信号");
    pause;
    sound(s_syn_v);
    disp("按任意键播放变调合成语音信号");
    pause;
    sound(s_syn_t);
    % 显示一小段信号波形
    t=1000:1400;
    figure;
    subplot(5,1,1);
    plot(t,s(t));
    title("原始语音");
    subplot(5,1,2);
    plot(t,s_rec(t));
    title("重建语音");
    subplot(5,1,3);
    plot(t,exc(t));
    title("激励信号");
    % 额外显示的部分
    subplot(5,1,4);
    plot(t,exc_syn(t));
    title("合成激励信号");
    subplot(5,1,5);
    plot(t,s_syn(t));
    title("合成语音信号");
    % 保存所有文件
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);
return

% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return