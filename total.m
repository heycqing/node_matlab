function total(data_file_path1, sheet_name1, range1, data_file_path2, sheet_name2, range2)
    rng('shuffle');
    close all
    clc
    % ע�⣬������Զ������Ƚ���������ͳ��
    % ������ͳ�Ƶ����ݼ���5��.���ϵ��
    % a=xlsread('/Users/cqing/makeMoney/node_matlab/uploads/excelFile-1687801616855.xlsx','Sheet1','A2:Q9999')
    % b=xlsread('/Users/cqing/makeMoney/node_matlab/uploads/excelFile-1687801616855.xlsx','Sheet2','A2:P9999')

    a=xlsread(data_file_path1, sheet_name1, range1)
    b=xlsread(data_file_path1, sheet_name2, range2)


    B=a(:,end)
    a=a(:,1:end-1)
    x=[a;b]
    [n,p] = size(a);  % n������������p��ָ�����
    [h,l] = size(b);
    %% ��һ����������x��׼��ΪX
    X=zscore(x);   % matlab���õı�׼��������x-mean(x)��/std(x)
    E=X(n+1:end,:)
    X=X(1:n,:)
    %% �ڶ�������������Э�������
    R = cov(X);

    %% ע�⣺���������ɺϲ�Ϊ����һ����ֱ�Ӽ����������ϵ������
    R = corrcoef(x);
    disp('�������ϵ������Ϊ��')
    disp(R)

    %% ������������R������ֵ����������
    % ע�⣺R�ǰ�������������������ֵ��Ϊ����
    % Rͬʱ�ǶԳƾ���Matlab����Գƾ���ʱ���Ὣ����ֵ���մ�С��������Ŷ
    % eig������������һ����η���������Ƶ
    [V,D] = eig(R);  % V ������������  D ����ֵ���ɵĶԽǾ���


    %% ���Ĳ����������ɷֹ����ʺ��ۼƹ�����
    lambda = diag(D);  % diag�������ڵõ�һ����������Խ���Ԫ��ֵ(���ص���������)
    lambda = lambda(end:-1:1);  % ��Ϊlambda�����Ǵ�С������ģ����ǽ������ͷ
    contribution_rate = lambda / sum(lambda);  % ���㹱����
    cum_contribution_rate = cumsum(lambda)/ sum(lambda);   % �����ۼƹ�����  cumsum�����ۼ�ֵ�ĺ���
    disp('����ֵΪ��')
    disp(lambda')  % ת��Ϊ������������չʾ
    disp('������Ϊ��')
    disp(contribution_rate')
    disp('�ۼƹ�����Ϊ��')
    disp(cum_contribution_rate')
    disp('������ֵ��Ӧ��������������Ϊ��')
    % ע�⣺�������������Ҫ������ֵһһ��Ӧ��֮ǰ����ֵ�൱�ڵߵ������ˣ�������������ĸ�����Ҫ�ߵ�����
    %  rot90��������ʹһ��������ʱ����ת90�ȣ�Ȼ����ת�ã��Ϳ���ʵ�ֽ�������еߵ���Ч��
    V=rot90(V)';
    disp(V)


    %% ������������Ҫ�����ɷֵ�ֵ
    F1=(cum_contribution_rate')'
    count = 0; % ��ʼ��������Ϊ0
    for i = 1:length(F1)    
        if F1(i) < 1 % �����ǰԪ��С��0.85        
            count = count + 1; % ��������1    
        else % �����ǰԪ�ش��ڵ���0.75        
            break; % ����ѭ��    
        end
    end
    %m = input('��������Ҫ��������ɷֵĸ���:  ');
    m = 2
    F = zeros(n,m);  %��ʼ���������ɷֵľ���ÿһ����һ�����ɷ֣�
    for i = 1:m
        ai = V(:,i)';   % ����i����������ȡ������ת��Ϊ������
        Ai = repmat(ai,n,1);   % ������������ظ�n�Σ�����һ��n*p�ľ���
        F(:, i) = sum(Ai .* X, 2);  % ע�⣬�Ա�׼������������Ȩ�غ�Ҫ����ÿһ�еĺ�
    end
    e = zeros(h,m);  %��ʼ���������ɷֵľ���ÿһ����һ�����ɷ֣�
    for i = 1:m
        bi = V(:,i)';   % ����i����������ȡ������ת��Ϊ������
        Bi = repmat(bi,h,1);   % ������������ظ�n�Σ�����һ��n*p�ľ���
        e(:, i) = sum(Bi .* E, 2);  % ע�⣬�Ա�׼������������Ȩ�غ�Ҫ����ÿһ�еĺ�
    end
    H=[F B]
    %% �����粿��
    data=H;%%��ȡexcel����
    % �������������������
    input=data(:,1:end-1);    %��1����������2��Ϊ����
    output=data(:,end);       %���1��Ϊ���

    N=length(output);         %������������
    testNum=50;     %�趨���Լ����������������ݼ���ȡ30%Ϊ���Լ�
    trainNum=N-testNum;       %�趨ѵ������������
    %% 3.����ѵ�����Ͳ��Լ�
    input_train = input(1:trainNum,:)';                   % ѵ��������
    output_train =output(1:trainNum)';                    % ѵ�������
    input_test =input(trainNum+1:trainNum+testNum,:)';    % ���Լ�����
    output_test =output(trainNum+1:trainNum+testNum)';    % ���Լ����
    %% 4.���ݹ�һ��
    [inputn,inputps]=mapminmax(input_train,0,1);         % ѵ���������һ����[0,1]֮��
    [outputn,outputps]=mapminmax(output_train);          % ѵ���������һ����Ĭ������[-1, 1]
    inputn_test=mapminmax('apply',input_test,inputps);   % ���Լ�������ú�ѵ����������ͬ�Ĺ�һ����ʽ
    %% 5.������������
    inputnum=size(input,2);   %size������ȡ�����������������1����������2��������
    outputnum=size(output,2);
    disp(['�����ڵ�����',num2str(inputnum),',  �����ڵ�����',num2str(outputnum)])
    disp(['������ڵ�����ΧΪ ',num2str(fix(sqrt(inputnum+outputnum))+1),' �� ',num2str(fix(sqrt(inputnum+outputnum))+10)])
    disp(' ')
    disp('���������ڵ��ȷ��...')
    
    %����hiddennum=sqrt(m+n)+a��mΪ�����ڵ�����nΪ�����ڵ�����aȡֵ[1,10]֮�������
    MSE=1e+5;                             %����ʼ��
    transform_func={'tansig','purelin'};  %���������tan-sigmoid��purelin
    train_func='trainlm';                 %ѵ���㷨
    for hiddennum=fix(sqrt(inputnum+outputnum))+1:fix(sqrt(inputnum+outputnum))+10
        
        net=newff(inputn,outputn,hiddennum,transform_func,train_func); %����BP����
        
        % �����������
        net.trainParam.epochs=1000;       % ����ѵ������
        net.trainParam.lr=0.01;           % ����ѧϰ����
        net.trainParam.goal=0.000001;     % ����ѵ��Ŀ����С���
        
        % ��������ѵ��
        net=train(net,inputn,outputn);
        an0=sim(net,inputn);     %������
        mse0=mse(outputn,an0);   %����ľ������
        disp(['��������ڵ���Ϊ',num2str(hiddennum),'ʱ��ѵ�����������Ϊ��',num2str(mse0)])
        
        %���ϸ������������ڵ�
        if mse0<MSE
            MSE=mse0;
            hiddennum_best=hiddennum;
        end
    end
    disp(['���������ڵ���Ϊ��',num2str(hiddennum_best),'���������Ϊ��',num2str(MSE)])
    %% 6.��������������BP������
    net=newff(inputn,outputn,hiddennum_best,transform_func,train_func);

    % �������
    net.trainParam.epochs=1000;         % ѵ������
    net.trainParam.lr=0.01;             % ѧϰ����
    net.trainParam.goal=0.000001;       % ѵ��Ŀ����С���

    %% 7.����ѵ��
    net=train(net,inputn,outputn);      % train��������ѵ�������磬������ɫ�������

    %% 8.�������
    an=sim(net,inputn_test);                     % ѵ����ɵ�ģ�ͽ��з������
    test_simu=mapminmax('reverse',an,outputps);  % ���Խ������һ��
    error=abs(test_simu-output_test)./test_simu;      % ����ֵ����ʵֵ�����

    % Ȩֵ��ֵ
    W1 = net.iw{1, 1};  %����㵽�м���Ȩֵ
    B1 = net.b{1};      %�м������Ԫ��ֵ
    W2 = net.lw{2,1};   %�м�㵽������Ȩֵ
    B2 = net.b{2};      %��������Ԫ��ֵ

    %% 9.������
    % BPԤ��ֵ��ʵ��ֵ�ĶԱ�ͼ
    figure
    plot(output_test,'bo-','linewidth',1.5)
    hold on
    plot(test_simu,'rv-','linewidth',1.5)
    legend('ʵ��ֵ','Ԥ��ֵ')
    xlabel('��������'),ylabel('ָ��ֵ')
    title('BPԤ��ֵ��ʵ��ֵ�ĶԱ�')
    set(gca,'fontsize',12)
    
    % ����ͼƬ - ��ʼ
    saveas(gcf, 'bp_comparison.png')
    % ����ͼƬ - ����


    % BP���Լ���Ԥ�����ͼ
    figure
    plot(error,'b*-','linewidth',1.5)
    xlabel('��������'),ylabel('Ԥ�����')
    title('BP��������Լ���Ԥ�����')
    set(gca,'fontsize',12)
    
    % ����ͼƬ - ��ʼ
    saveas(gcf, 'bp_error.png')
    % ����ͼƬ - ����

    %�������������
    error=test_simu-output_test; 
    [~,len]=size(output_test);            % len��ȡ����������������ֵ����testNum���������ָ��ƽ��ֵ
    SSE1=sum(error.^2);                   % ���ƽ����
    MAE1=sum(abs(error))/len;             % ƽ���������
    MSE1=error*error'/len;                % �������
    RMSE1=MSE1^(1/2);                     % ���������
    MAPE1=mean(abs(error./output_test));  % ƽ���ٷֱ����
    r=corrcoef(output_test,test_simu);    % corrcoef�������ϵ�����󣬰�������غͻ����ϵ��
    R1=r(1,2);

    % ��ʾ��ָ����
    disp(' ')
    disp('�������ָ������')
    disp(['���ƽ����SSE��',num2str(SSE1)])
    disp(['ƽ���������MAE��',num2str(MAE1)])
    disp(['�������MSE��',num2str(MSE1)])
    disp(['���������RMSE��',num2str(RMSE1)])
    disp(['ƽ���ٷֱ����MAPE��',num2str(MAPE1*100),'%'])
    disp(['Ԥ��׼ȷ��Ϊ��',num2str(100-MAPE1*100),'%'])
    disp(['���ϵ��R�� ',num2str(R1)])

    % ����ͼƬ - ��ʼ
    figure
    text(0.1,0.9,['���ƽ����SSE��',num2str(SSE1)],'FontSize',12)
    text(0.1,0.8,['ƽ���������MAE��',num2str(MAE1)],'FontSize',12)
    text(0.1,0.7,['�������MSE��',num2str(MSE1)],'FontSize',12)
    text(0.1,0.6,['���������RMSE��',num2str(RMSE1)],'FontSize',12)
    text(0.1,0.5,['ƽ���ٷֱ����MAPE��',num2str(MAPE1*100),'%'],'FontSize',12)
    text(0.1,0.4,['Ԥ��׼ȷ��Ϊ��',num2str(100-MAPE1*100),'%'],'FontSize',12)
    text(0.1,0.3,['���ϵ��R�� ',num2str(R1)],'FontSize',12)
    axis off
    saveas(gcf, 'error_results.png')
    % ����ͼƬ - ���� 

   %��ʾ���Լ����
    disp(' ')
    disp('���Լ������')
    disp('    ���     ʵ��ֵ     BPԤ��ֵ     ���')
    for i=1:len
        disp([i,output_test(i),test_simu(i),error(i)])   % ��ʾ˳��: ������ţ�ʵ��ֵ��Ԥ��ֵ�����
    end

    % ���Լ����ͼ
    figure;
    plot(1:len, output_test, 'r', 'LineWidth', 2); % ʵ��ֵ��ɫ��
    hold on;
    plot(1:len, test_simu, 'b', 'LineWidth', 2); % Ԥ��ֵ��ɫ��
    legend('ʵ��ֵ', 'Ԥ��ֵ');
    xlabel('�������');
    ylabel('ֵ');
    title('���Լ����');
    saveas(gcf, 'test_results.png') % ����ͼƬ

    % ���ֲ�ͼ
    figure;
    histogram(error);
    xlabel('���');
    ylabel('Ƶ��');
    title('���ֲ�');
    saveas(gcf, 'error_distribution.png') % ����ͼƬ

    %% %%δ��Ԥ��
    data_test=e'
    %data_test=xlsread('original data1.xlsx','A500:P510')'
    datan_test=mapminmax('apply',data_test,inputps);

    sim1=sim(net,datan_test);
    Sim1=mapminmax('reverse',sim1,outputps);

    disp(['Ԥ��δ��CO2�ŷ���Ϊ',num2str(Sim1)]);

    % ���Sim1������������Ԥ����ͼ
    if length(Sim1) > 1
        figure;
        plot(1:length(Sim1), Sim1, 'g', 'LineWidth', 2);
        xlabel('�������');
        ylabel('Ԥ��ֵ');
        title('Ԥ��δ��CO2�ŷ���');
        saveas(gcf, 'future_prediction.png') % ����ͼƬ
    end

        
    end

