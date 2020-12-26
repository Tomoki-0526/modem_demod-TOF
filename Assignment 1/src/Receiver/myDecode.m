%% myDecode
% 功能：将解调得到的二进制数据解码为字符串，并输出到文本文件
% 输入：二进制序列、开始接受到音频的时间
% 输出：字符串、开始接受到音频的时间
function str = myDecode(bits)
    payload_len = 8;
    str = [];
    for i = 1 : payload_len : length(bits)
        ch = char(bin2dec(num2str(bits(i : i + payload_len - 1))));
        str = [str ch];
    end
end