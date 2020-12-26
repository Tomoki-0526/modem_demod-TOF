%% generateWave
% 功能：将音频信号序列转化为wav文件
% 输入：音频信号序列
% 输出：无输出，在本地生成wav文件
function generateWave(sig)
    fs = 48000;
    filename = 'send.wav';
    audiowrite(filename, sig, fs);
end