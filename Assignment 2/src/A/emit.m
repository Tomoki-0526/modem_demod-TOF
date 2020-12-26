%% 发送信号
% 参数
% fs: 采样率
% dt: chirp持续时间
% f0: chirp起始频率
% f1: chirp终止频率
% 返回值：无
function emit(fs, dt, f0, f1)
    %% 参数准备
    t = 1 / fs : 1 / fs : dt;
    sig = chirp(t, f0, dt, f1);
    
    %% 发送信号
    sound(sig, fs);
end