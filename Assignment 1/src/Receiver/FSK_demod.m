%% FSK_demod
% 功能：对录到的音频进行解调，将数据段输出
% 输入：录制的音频文件名、开始录音的时间
% 输出：二进制序列、开始接受到音频的时间
function [bits, t1] = FSK_demod(filename, t0)
    %% 参数准备
    [sig, fs] = audioread(filename);        % 音频信号和采样率
    sig = sig(:,1);
    bp = 0.025;                             % 位周期
    f0 = 4000;                              % 低频
    f1 = 6000;                              % 高频
    N = fs * bp;                            % 位采样点数
    pt_len = 0.05;                          % 前导码时长
    pt = 0 : 1 / fs : pt_len;               % 前导码时间序列
    preamble = chirp(pt, f0, pt_len, f1);   % 前导码
    preamble_len = length(preamble);        % 前导码长度
    len = length(sig);                      % 信号长度
    pkg_len = preamble_len + 12 * N;        % 最大数据包全长
    
    figure(1);
    plot(sig);
    
    %% 滤波
    %hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,3900,4100,fs),'butter');
    %sig_low = filter(hd, sig);
    %hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,5900,6100,fs),'butter');
    %sig_high = filter(hd, sig);
    %sig = sig_low + sig_high;
    
    %% 前导码匹配
    % 相关性计算
    corr = [];
    for p = 1 : len
        r = p + preamble_len - 1;
        if r > len
            zeroize = r - len;
            sig = [sig; zeros(zeroize, 1)];
        end
        window_corr = preamble * sig(p : r);
        corr = [corr window_corr];
    end
    
    figure(2);
    plot(corr);
    
    % 寻找峰值
    left = 1;               % 把前面的无效数据截掉
    for left = 1 : len
        if corr(left) > 1
            break;
        end
    end
    locs = [];
    for p = left : pkg_len : len
        r = p + pkg_len - 1;
        if r > len
            r = len;
        end
        [val, index] = max(corr(p : r));
        if val < 0.5
            continue;
        end
        locs = [locs index + p - 1];
    end
    
    %% 分数据包解调解码
    bits = [];
    for i = 1 : length(locs)
        % 包头
        header_index = locs(i) + preamble_len;
        header = demodulator(sig, header_index, 4, fs, bp, f0, f1);
        % 数据段
        payload_num = bin2dec(char(header + '0'));
        if payload_num ~= 8     % 如果数据段长度不等于8视为丢包
            continue;
        end
        payload_index = header_index + 4 * N;
        payload = demodulator(sig, payload_index, payload_num, fs, bp, f0, f1);
        bits = [bits payload];
    end
    
    %% 计算开始接受到音频的时间
    Y = year(t0);
    M = month(t0);
    D = day(t0);
    H = hour(t0);
    MI = minute(t0);
    S = second(t0);
    start_time = locs(1) / fs;
    S = S + start_time;
    t1 = datetime(Y, M, D, H, MI, S);
end

%% demodulator
% 功能：对包头或数据段进行解调
% 输入：原始信号、解码起始位置、解码段位数
% 输出：解调结果序列
function res = demodulator(sig, start_index, num, fs, bp, f0, f1)
    %% 参数准备
    N = fs * bp;                    % 位采样点数
    f = (0 : N - 1) * fs / N;       % 频率序列
    f0_index = find(f == f0);       % 低频位置
    f1_index = find(f == f1);       % 高频位置
    
    %% 解调
    res = [];
    for i = 1 : num
        yf = abs(fft(sig(start_index + (i - 1) * N : start_index + i * N - 1)));
        maxsig0 = max(yf(f0_index - 10 : f0_index + 10));
        maxsig1 = max(yf(f1_index - 10 : f1_index + 10));
        if maxsig0 > maxsig1
            res = [res 0];
        elseif maxsig0 < maxsig1
            res = [res 1];
        else
            continue;
        end
    end
end