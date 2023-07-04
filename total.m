function total(data_file_path1, sheet_name1, range1, data_file_path2, sheet_name2, range2)
    rng('shuffle');
    close all
    clc
    % 注意，这里可以对数据先进行描述性统计
    % 描述性统计的内容见第5讲.相关系数
    % a=xlsread('/Users/cqing/makeMoney/node_matlab/uploads/excelFile-1687801616855.xlsx','Sheet1','A2:Q9999')
    % b=xlsread('/Users/cqing/makeMoney/node_matlab/uploads/excelFile-1687801616855.xlsx','Sheet2','A2:P9999')

    a=xlsread(data_file_path1, sheet_name1, range1)
    b=xlsread(data_file_path1, sheet_name2, range2)


    B=a(:,end)
    a=a(:,1:end-1)
    x=[a;b]
    [n,p] = size(a);  % n是样本个数，p是指标个数
    [h,l] = size(b);
    %% 第一步：对数据x标准化为X
    X=zscore(x);   % matlab内置的标准化函数（x-mean(x)）/std(x)
    E=X(n+1:end,:)
    X=X(1:n,:)
    %% 第二步：计算样本协方差矩阵
    R = cov(X);

    %% 注意：以上两步可合并为下面一步：直接计算样本相关系数矩阵
    R = corrcoef(x);
    disp('样本相关系数矩阵为：')
    disp(R)

    %% 第三步：计算R的特征值和特征向量
    % 注意：R是半正定矩阵，所以其特征值不为负数
    % R同时是对称矩阵，Matlab计算对称矩阵时，会将特征值按照从小到大排列哦
    % eig函数的详解见第一讲层次分析法的视频
    [V,D] = eig(R);  % V 特征向量矩阵  D 特征值构成的对角矩阵


    %% 第四步：计算主成分贡献率和累计贡献率
    lambda = diag(D);  % diag函数用于得到一个矩阵的主对角线元素值(返回的是列向量)
    lambda = lambda(end:-1:1);  % 因为lambda向量是从小大到排序的，我们将其调个头
    contribution_rate = lambda / sum(lambda);  % 计算贡献率
    cum_contribution_rate = cumsum(lambda)/ sum(lambda);   % 计算累计贡献率  cumsum是求累加值的函数
    disp('特征值为：')
    disp(lambda')  % 转置为行向量，方便展示
    disp('贡献率为：')
    disp(contribution_rate')
    disp('累计贡献率为：')
    disp(cum_contribution_rate')
    disp('与特征值对应的特征向量矩阵为：')
    % 注意：这里的特征向量要和特征值一一对应，之前特征值相当于颠倒过来了，因此特征向量的各列需要颠倒过来
    %  rot90函数可以使一个矩阵逆时针旋转90度，然后再转置，就可以实现将矩阵的列颠倒的效果
    V=rot90(V)';
    disp(V)


    %% 计算我们所需要的主成分的值
    F1=(cum_contribution_rate')'
    count = 0; % 初始化计数器为0
    for i = 1:length(F1)    
        if F1(i) < 1 % 如果当前元素小于0.85        
            count = count + 1; % 计数器加1    
        else % 如果当前元素大于等于0.75        
            break; % 跳出循环    
        end
    end
    %m = input('请输入需要保存的主成分的个数:  ');
    m = 2
    F = zeros(n,m);  %初始化保存主成分的矩阵（每一列是一个主成分）
    for i = 1:m
        ai = V(:,i)';   % 将第i个特征向量取出，并转置为行向量
        Ai = repmat(ai,n,1);   % 将这个行向量重复n次，构成一个n*p的矩阵
        F(:, i) = sum(Ai .* X, 2);  % 注意，对标准化的数据求了权重后要计算每一行的和
    end
    e = zeros(h,m);  %初始化保存主成分的矩阵（每一列是一个主成分）
    for i = 1:m
        bi = V(:,i)';   % 将第i个特征向量取出，并转置为行向量
        Bi = repmat(bi,h,1);   % 将这个行向量重复n次，构成一个n*p的矩阵
        e(:, i) = sum(Bi .* E, 2);  % 注意，对标准化的数据求了权重后要计算每一行的和
    end
    H=[F B]
    %% 神经网络部分
    data=H;%%读取excel数据
    % 设置神经网络的输入和输出
    input=data(:,1:end-1);    %第1列至倒数第2列为输入
    output=data(:,end);       %最后1列为输出

    N=length(output);         %计算样本数量
    testNum=50;     %设定测试集样本数量，从数据集中取30%为测试集
    trainNum=N-testNum;       %设定训练集样本数量
    %% 3.设置训练集和测试集
    input_train = input(1:trainNum,:)';                   % 训练集输入
    output_train =output(1:trainNum)';                    % 训练集输出
    input_test =input(trainNum+1:trainNum+testNum,:)';    % 测试集输入
    output_test =output(trainNum+1:trainNum+testNum)';    % 测试集输出
    %% 4.数据归一化
    [inputn,inputps]=mapminmax(input_train,0,1);         % 训练集输入归一化到[0,1]之间
    [outputn,outputps]=mapminmax(output_train);          % 训练集输出归一化到默认区间[-1, 1]
    inputn_test=mapminmax('apply',input_test,inputps);   % 测试集输入采用和训练集输入相同的归一化方式
    %% 5.求解最佳隐含层
    inputnum=size(input,2);   %size用来求取矩阵的行数和列数，1代表行数，2代表列数
    outputnum=size(output,2);
    disp(['输入层节点数：',num2str(inputnum),',  输出层节点数：',num2str(outputnum)])
    disp(['隐含层节点数范围为 ',num2str(fix(sqrt(inputnum+outputnum))+1),' 至 ',num2str(fix(sqrt(inputnum+outputnum))+10)])
    disp(' ')
    disp('最佳隐含层节点的确定...')
    
    %根据hiddennum=sqrt(m+n)+a，m为输入层节点数，n为输出层节点数，a取值[1,10]之间的整数
    MSE=1e+5;                             %误差初始化
    transform_func={'tansig','purelin'};  %激活函数采用tan-sigmoid和purelin
    train_func='trainlm';                 %训练算法
    for hiddennum=fix(sqrt(inputnum+outputnum))+1:fix(sqrt(inputnum+outputnum))+10
        
        net=newff(inputn,outputn,hiddennum,transform_func,train_func); %构建BP网络
        
        % 设置网络参数
        net.trainParam.epochs=1000;       % 设置训练次数
        net.trainParam.lr=0.01;           % 设置学习速率
        net.trainParam.goal=0.000001;     % 设置训练目标最小误差
        
        % 进行网络训练
        net=train(net,inputn,outputn);
        an0=sim(net,inputn);     %仿真结果
        mse0=mse(outputn,an0);   %仿真的均方误差
        disp(['当隐含层节点数为',num2str(hiddennum),'时，训练集均方误差为：',num2str(mse0)])
        
        %不断更新最佳隐含层节点
        if mse0<MSE
            MSE=mse0;
            hiddennum_best=hiddennum;
        end
    end
    disp(['最佳隐含层节点数为：',num2str(hiddennum_best),'，均方误差为：',num2str(MSE)])
    %% 6.构建最佳隐含层的BP神经网络
    net=newff(inputn,outputn,hiddennum_best,transform_func,train_func);

    % 网络参数
    net.trainParam.epochs=1000;         % 训练次数
    net.trainParam.lr=0.01;             % 学习速率
    net.trainParam.goal=0.000001;       % 训练目标最小误差

    %% 7.网络训练
    net=train(net,inputn,outputn);      % train函数用于训练神经网络，调用蓝色仿真界面

    %% 8.网络测试
    an=sim(net,inputn_test);                     % 训练完成的模型进行仿真测试
    test_simu=mapminmax('reverse',an,outputps);  % 测试结果反归一化
    error=abs(test_simu-output_test)./test_simu;      % 测试值和真实值的误差

    % 权值阈值
    W1 = net.iw{1, 1};  %输入层到中间层的权值
    B1 = net.b{1};      %中间各层神经元阈值
    W2 = net.lw{2,1};   %中间层到输出层的权值
    B2 = net.b{2};      %输出层各神经元阈值

    %% 9.结果输出
    % BP预测值和实际值的对比图
    figure
    plot(output_test,'bo-','linewidth',1.5)
    hold on
    plot(test_simu,'rv-','linewidth',1.5)
    legend('实际值','预测值')
    xlabel('测试样本'),ylabel('指标值')
    title('BP预测值和实际值的对比')
    set(gca,'fontsize',12)
    
    % 生成图片 - 开始
    saveas(gcf, 'bp_comparison.png')
    % 生成图片 - 结束


    % BP测试集的预测误差图
    figure
    plot(error,'b*-','linewidth',1.5)
    xlabel('测试样本'),ylabel('预测误差')
    title('BP神经网络测试集的预测误差')
    set(gca,'fontsize',12)
    
    % 生成图片 - 开始
    saveas(gcf, 'bp_error.png')
    % 生成图片 - 结束

    %计算各项误差参数
    error=test_simu-output_test; 
    [~,len]=size(output_test);            % len获取测试样本个数，数值等于testNum，用于求各指标平均值
    SSE1=sum(error.^2);                   % 误差平方和
    MAE1=sum(abs(error))/len;             % 平均绝对误差
    MSE1=error*error'/len;                % 均方误差
    RMSE1=MSE1^(1/2);                     % 均方根误差
    MAPE1=mean(abs(error./output_test));  % 平均百分比误差
    r=corrcoef(output_test,test_simu);    % corrcoef计算相关系数矩阵，包括自相关和互相关系数
    R1=r(1,2);

    % 显示各指标结果
    disp(' ')
    disp('各项误差指标结果：')
    disp(['误差平方和SSE：',num2str(SSE1)])
    disp(['平均绝对误差MAE：',num2str(MAE1)])
    disp(['均方误差MSE：',num2str(MSE1)])
    disp(['均方根误差RMSE：',num2str(RMSE1)])
    disp(['平均百分比误差MAPE：',num2str(MAPE1*100),'%'])
    disp(['预测准确率为：',num2str(100-MAPE1*100),'%'])
    disp(['相关系数R： ',num2str(R1)])

    % 生成图片 - 开始
    figure
    text(0.1,0.9,['误差平方和SSE：',num2str(SSE1)],'FontSize',12)
    text(0.1,0.8,['平均绝对误差MAE：',num2str(MAE1)],'FontSize',12)
    text(0.1,0.7,['均方误差MSE：',num2str(MSE1)],'FontSize',12)
    text(0.1,0.6,['均方根误差RMSE：',num2str(RMSE1)],'FontSize',12)
    text(0.1,0.5,['平均百分比误差MAPE：',num2str(MAPE1*100),'%'],'FontSize',12)
    text(0.1,0.4,['预测准确率为：',num2str(100-MAPE1*100),'%'],'FontSize',12)
    text(0.1,0.3,['相关系数R： ',num2str(R1)],'FontSize',12)
    axis off
    saveas(gcf, 'error_results.png')
    % 生成图片 - 结束 

   %显示测试集结果
    disp(' ')
    disp('测试集结果：')
    disp('    编号     实际值     BP预测值     误差')
    for i=1:len
        disp([i,output_test(i),test_simu(i),error(i)])   % 显示顺序: 样本编号，实际值，预测值，误差
    end

    % 测试集结果图
    figure;
    plot(1:len, output_test, 'r', 'LineWidth', 2); % 实际值红色线
    hold on;
    plot(1:len, test_simu, 'b', 'LineWidth', 2); % 预测值蓝色线
    legend('实际值', '预测值');
    xlabel('样本编号');
    ylabel('值');
    title('测试集结果');
    saveas(gcf, 'test_results.png') % 保存图片

    % 误差分布图
    figure;
    histogram(error);
    xlabel('误差');
    ylabel('频数');
    title('误差分布');
    saveas(gcf, 'error_distribution.png') % 保存图片

    %% %%未来预测
    data_test=e'
    %data_test=xlsread('original data1.xlsx','A500:P510')'
    datan_test=mapminmax('apply',data_test,inputps);

    sim1=sim(net,datan_test);
    Sim1=mapminmax('reverse',sim1,outputps);

    disp(['预测未来CO2排放量为',num2str(Sim1)]);

    % 如果Sim1是向量，生成预测结果图
    if length(Sim1) > 1
        figure;
        plot(1:length(Sim1), Sim1, 'g', 'LineWidth', 2);
        xlabel('样本编号');
        ylabel('预测值');
        title('预测未来CO2排放量');
        saveas(gcf, 'future_prediction.png') % 保存图片
    end

        
    end

