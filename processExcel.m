function result = processExcel(filePath)
    % 读取 Excel 文件
    data = xlsread(filePath);

    % 初始化结果结构体
    result = struct();
    [numRows, numCols] = size(data);

    % 计算每列的总和和平均值
    for col = 1:numCols
        columnData = data(:, col);
        result(col).sum = sum(columnData);
        result(col).average = mean(columnData);
    end
end
