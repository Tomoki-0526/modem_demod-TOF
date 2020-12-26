%% FSK_mod
% 功能：将给定的二进制序列调制成数个完整的数据包
% 输入：二进制序列
% 输出：音频信号序列
function sig = FSK_mod(bits)
    %% 参数准备
    fs = 48000;                             % 采样率
    f0 = 4000;                              % 低频
    f1 = 6000;                              % 高频
    pt_len = 0.05;                          % 前导码时长
    pt = 0 : 1 / fs : pt_len;               % 前导码时间序列
    preamble = chirp(pt, f0, pt_len, f1);   % 前导码
    bits_len = length(bits);                % 信号时长
    max_len = 8;                            % 数据段最大长度

    %% 调制
    sig = [];
    for p = 1 : max_len : bits_len
        r = p + max_len - 1;
        % 如果剩余位数不足8位，右边界则取整个序列的右边界
        if r > bits_len
            r = bits_len;
        end
        header = dec2bin(r - p + 1, 4);
        sig = [sig preamble bits2sig(header) bits2sig(bits(p : r))];
    end
end

%% bits2sig
% 功能：将0或1转换为信号（作为包头或数据段）
% 输入：二进制序列
% 输出：高低频信号
function sig = bits2sig(bits)
    %% 参数准备
    fs = 48000;                             % 采样率
    bp = 0.025;                             % 位周期
    f0 = 4000;                              % 低频
    f1 = 6000;                              % 高频
    N = fs * bp;                            % 位采样点数
    t = bp / N : bp / N : bp;               % 位时间序列
    base0 = sin(2 * pi * f0 * t);           % 低频信号
    base1 = sin(2 * pi * f1 * t);           % 高频信号
    
    %% 调制
    sig = [];
    for i = 1 : length(bits)
        if bits(i) == '0'
            sig = [sig base0];
        elseif bits(i) == '1'
            sig = [sig base1];
        else
            continue;
        end
    end
end