%% myEncode
% 功能：将英文字符串转化为二进制序列
% 输入：英文字符串
% 输出：二进制序列
function bits = myEncode(str)
    bits = [];
    for i = 1 : length(str)
        ascii = dec2bin(abs(str(i)), 8);
        bits = [bits ascii];
    end
end