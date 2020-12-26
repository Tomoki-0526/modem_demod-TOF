%% 计算AB端的距离
% 参数
% A_filename: A.wav文件名
% B_filename: B.wav文件名
% dt: 信号持续时间
% A_f0: A端chirp起始频率
% A_f1: A端chirp终止频率
% B_f0: B端chirp起始频率
% B_f1: B端chirp终止频率
% 返回值
% d: AB端距离
function d = rangingCal(A_filename, B_filename, dt, A_f0, A_f1, B_f0, B_f1)
    %% 参数准备
    [A_data, fs] = audioread(A_filename);
    [B_data, ~] = audioread(B_filename);
    A_len = length(A_data);
    B_len = length(B_data);
    t = 1 / fs : 1 / fs : dt;
    A_sig = chirp(t, A_f0, dt, A_f1);
    B_sig = chirp(t, B_f0, dt, B_f1);
    sig_len = length(t);

    %% 计算各时间点
    t_A1 = timePoint(A_data, A_sig, fs, A_len, sig_len);  % A端接收到A端发出的信号
    t_B1 = timePoint(B_data, A_sig, fs, B_len, sig_len);  % B端接收到A端发出的信号
    t_B3 = timePoint(B_data, B_sig, fs, B_len, sig_len);  % B端接收到B端发出的信号
    t_A3 = timePoint(A_data, B_sig, fs, A_len, sig_len);  % A端接收到B端发出的信号

    % 计算距离
    d = 34000 * ((t_A3 - t_A1) - (t_B3 - t_B1)) / 2 + 4.5;
end

%% 计算时间点
% 参数
% data: 待检测音频信号
% sig: 标准信号
% fs: 采样率
% len: 音频信号长度
% sig_len: 标准信号长度
% 返回值
% t: 时间点
function t = timePoint(data, sig, fs, len, sig_len)
    %% 相关性计算
    corr = [];
    for p = 1 : len
        r = p + sig_len - 1;
        if r > len
            zeroize = r - len;
            data = [data; zeros(zeroize, 1)];
        end
        window_corr = sig * data(p : r);
        corr = [corr window_corr];
    end

    %% 计算时间点
    [~, t_index] = max(corr);
    t = t_index / fs;
end