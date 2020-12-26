%% FSK_demod_test
% 功能：修改FSK_demod函数以适应测试数据包
% 输入：测试音频文件
% 输出：无
function FSK_demod_test(csv_filename, wav_filename)
    %% 参数准备
    % 从csv文件获取参数
    params = csvread(csv_filename, 0, 1, [0 1 3 1]);
    fs = params(1);         % 采样率
    bp = params(2);         % 位周期
    f0 = params(3);         % 低频
    f1 = params(4);         % 高频
    
    content = csvread(csv_filename, 5, 0);
    onset = content(:,4);   % 数据包起始位置
    
    % 从wav文件获取音频信息
    [sig, ~] = audioread(wav_filename);
    
    figure(1);
    plot(sig);
    
    % 其他参数
    N = fs * bp;            % 位采样点数
    preamble_len = 20;      % 前导码长度
    header_len = 8;         % 包头长度

    %% 解码
    for i = 1 : length(onset)
        % 包头
        header_index = onset(i) + preamble_len * N;
        header = demodulator(sig, header_index, header_len, fs, bp, f0, f1);
        % 数据段
        payload_num = bin2dec(char(header + '0'));
        payload_index = header_index + header_len * N;
        payload = demodulator(sig, payload_index, payload_num, fs, bp, f0, f1);
        % 输出到csv文件
        output = [payload_num payload];
        dlmwrite('output.csv', output, '-append', 'delimiter', ',');
    end
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