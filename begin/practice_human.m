%% Preliminary
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'TextEncodingLocale', 'UTF8') ;

rand('twister',sum(100*clock));

Base_dir=pwd;
Exp_name = 'shixian'; 
Stimuli_dir=[Base_dir, '\Stimuli'];
Data_dir=[Base_dir, '\Data\'];
ID=input('Participant ID:','s');
filename=[Exp_name, '_S', ID, '_', date];
%--------------------------------------------------------------------------%%�����Ǵ���
    if exist([Data_dir filename '.csv'], 'file')                           
        ret = input('�ļ��Ѵ��ڣ�ȷ��Ҫ����ô��Y/N:','s');
        if ret == "Y" || ret == "y"
            delete([Data_dir filename '.csv']);
        else
            disp("�˳�");
            return;
        end
    end
%--------------------------------------------------------------------------%%2021.3.13 wx
datafile=fopen([Data_dir filename '.csv'],'a+');
%fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Angle,TrueAngle,time(s),F,J,PressLog\n'); %��18��
%fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Angle,TrueAngle,time(s)\n'); %��15��
fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Height,Weight,Angle,TrueAngle,time(s),FirstQ,SecondQ\n'); %��19��
%% read background image
%Animal={'Dog';'Male'};                                                    %2021.5.14  wx
%Animal={'Dog';'Male';'Item'};                                             %2021.5.14  wx
Animal={'Male'};                                                            %2021.10.6  wx
% Animal={'Dog';'Male';'Female'};
% ImgAnimal(2).background(8).img=[];
ImgAnimal(length(Animal)).background(8).img=[];
% ImgAnimal(2).background(8).name=[];
ImgAnimal(length(Animal)).background(8).name=[];

%--------------------------------------------------------------------------%2021.10.06 wx
%for i=1:2                                                                 %2021.5.14  wx
% for i=1:3
%     currentFolder=[Stimuli_dir '\' Animal{i}];
%     currentFiles=dir([currentFolder '\*.jpg']);
%     for j=1:length(currentFiles)
%         ImgAnimal(i).background(j).img=imread([currentFolder '\' currentFiles(j).name]);
%         ImgAnimal(i).background(j).name=[currentFolder '\' currentFiles(j).name];
%     end
% end
%--------------------------------------------------------------------------%2021.10.06 wx

%--------------------------------------------------------------------------%2021.10.06 wx
i = 1;
currentFolder=[Stimuli_dir '\' Animal{i}];
currentFiles=dir([currentFolder '\*.jpg']);
for j=1:length(currentFiles)
    ImgAnimal(i).background(j).img=imread([currentFolder '\' currentFiles(j).name]);
    ImgAnimal(i).background(j).name=[currentFolder '\' currentFiles(j).name];
end
%--------------------------------------------------------------------------%2021.10.06 wx

% read papar or money image �� ��ȶ���дѭ���ṹ
Tube={'Paper';'Money'};

ii= 1;
currentFolder=[Stimuli_dir '\' Tube{ii}]; %��...\stimuli\papaer
currentFiles=dir([currentFolder '\*.png']);
for j=1:length(currentFiles)
    ImgTube_shape(j).img=readPNG([currentFolder '\' currentFiles(j).name]);
    ImgTube_shape(j).name=[currentFolder '\' currentFiles(j).name];
end
% Tube={'Paper';'Money'};
% ImgTube(length(Tube)).ImgTube_shape(?).img=[];
% ImgTube(length(Tube)).ImgTube_shape(?).name=[];
% 
% for i=1:2
%     currentFolder=[Stimuli_dir '\' Tube{i}];
%     currentFiles=dir([currentFolder '\*.png']);
%     for j=1:length(currentFiles)
%         ImgTube_shape(j).img=readPNG([currentFolder '\' currentFiles(j).name]);
%         ImgTube_shape(j).name=[currentFolder '\' currentFiles(j).name];
%     end
% end


%% design
BlockType=length(Animal);
Repeat = 2;
NwithinBlock = 16;                                                         %2021.5.14  wx
%NwithinBlock = 32;
% BlockInterval = 10;
% Rest = 10;

% TotalBlock = 10; %4+4+2(Item)                                            %2021.5.14  wx         
TotalBlock = 6; %4(Dog)                                                    %2021.10.6  wx   
TotalTrial = TotalBlock * NwithinBlock; %6*16 = 96                         %2021.5.14  wx

% TotalBlock = BlockType * Repeat; %4         
% TotalTrial = TotalBlock * NwithinBlock; %4*32 = 128                        
% Design=zeros(TotalTrial, 9);

Design=zeros(TotalTrial, 9);

%% block�������
%--------------------------------------------------------------------------%2021.10.6  wx
BlockOrder=[1 1 1 1 1 1];                                                  %ȫ����
%--------------------------------------------------------------------------%2021.10.6  wx

% ---------------------------------------------------------------------------%2021.5.14  wx
% BlockOrder=[1:2 1:2]; % ���� Block վ�����Ŷ�
% BlockOrder=BlockOrder(randperm(4)); % ��� Block ���
% while prod(BlockOrder(1:3)-BlockOrder(2:4))==0 % ���� Block ����������
%     BlockOrder=BlockOrder(randperm(4));
% end
% ---------------------------------------------------------------------------%2021.5.14  wx


BlockOrder=repmat(BlockOrder, [NwithinBlock 1]); % �� Block ��չ�� Trial ˮƽ
BlockOrder=reshape(BlockOrder, [TotalTrial 1]); % �� Block ��չ�ɳ���ʽ�Ա����

Design(:,1)=BlockOrder; % �� Block �������� Design ���


%% trail�������
all_random_trial_Order = [];

% ---------------------------------------------------------------------------%2021.10.6  wx
for block_List = 1:6   %block type����6
    
    TrialOrder=[1:16]; % 1��block������ trail վ�����Ŷ�
    TrialOrder=TrialOrder(randperm(16)); % ��� trail���
    while prod(TrialOrder(1:15)-TrialOrder(2:16))==0 % ���� trail ����������
        TrialOrder=TrialOrder(randperm(16));
    end
    TrialOrder=reshape(TrialOrder, [16 1]);
    all_random_trial_Order = [all_random_trial_Order;TrialOrder];          %��ÿһ������õ�16��trial����ȥ
    
end
% ---------------------------------------------------------------------------%2021.10.6  wx

% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_List = 1:10   %block type����4    �����32Ҳ�ñ�����ֵ
%     
%     TrialOrder=[1:16]; % 1��block������ trail վ�����Ŷ�
%     TrialOrder=TrialOrder(randperm(16)); % ��� trail���
%     while prod(TrialOrder(1:15)-TrialOrder(2:16))==0 % ���� trail ����������
%         TrialOrder=TrialOrder(randperm(16));
%     end
%     TrialOrder=reshape(TrialOrder, [16 1]);
%     all_random_trial_Order = [all_random_trial_Order;TrialOrder];          %��ÿһ������õ�16��trial����ȥ
%     
% end
% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_List = 1:4   %block type����4    �����32Ҳ�ñ�����ֵ
%     
%     TrialOrder=[1:32]; % 1��block������ trail վ�����Ŷ�
%     TrialOrder=TrialOrder(randperm(32)); % ��� trail���
%     while prod(TrialOrder(1:31)-TrialOrder(2:32))==0 % ���� trail ����������
%         TrialOrder=TrialOrder(randperm(32));
%     end
%     TrialOrder=reshape(TrialOrder, [32 1]);
%     all_random_trial_Order = [all_random_trial_Order;TrialOrder]; %��ÿһ������õ�32��trial����ȥ
%     
% end
% ---------------------------------------------------------------------------%2021.5.14  wx

Design(:,2)=all_random_trial_Order; % �� random_Trial ���� Design ����2��

%% �����к͵�������back_order��tube_order
[Back_order,Tube_order]=find_place(all_random_trial_Order);
Design(:,3) = Back_order;
Design(:,4) = Tube_order;

%% Trial���
% ---------------------------------------------------------------------------%2021.5.14  wx
for i=1:10
    Design((i-1)*16+1:i*16,5)=[1:16]; % �� Design ����5������������ Trial ���
end
% ---------------------------------------------------------------------------%2021.5.14  wx
% for i=1:4
%     Design((i-1)*32+1:i*32,5)=[1:32]; % �� Design ����5������������ Trial ���
% end

%% ����Qtrial��ţ��ڶ���trial���룬֮����96��֮�ڲ��ظ��������
% ---------------------------------------------------------------------------%2021.10.6  wx
Qtrial = randperm(96, 9); %��дrange �涨��Χ �Ϳ�ʡ���·�ѭ��
while (ismember(1,Qtrial) | ismember(2,Qtrial))
    Qtrial = randperm(96, 9);
end
Qtrial_list=[1 Qtrial]; %�ܹ�����16�����⣬��1��trail������֣��ڶ������ܳ���
% ---------------------------------------------------------------------------%2021.5.14  wx
% Qtrial = randperm(160, 15); %��дrange �涨��Χ �Ϳ�ʡ���·�ѭ��
% while (ismember(1,Qtrial) | ismember(2,Qtrial))
%     Qtrial = randperm(160, 15);
% end
% Qtrial_list=[1 Qtrial]; %�ܹ�����16�����⣬��1��trail������֣��ڶ������ܳ���
% ---------------------------------------------------------------------------%2021.5.14  wx
% %% ����Qtrial��ţ��ڶ���trial���룬֮����128��֮�ڲ��ظ��������
% Qtrial = randperm(128, 15); %��дrange �涨��Χ �Ϳ�ʡ���·�ѭ��
% while (ismember(1,Qtrial) | ismember(2,Qtrial))
%     Qtrial = randperm(128, 15);
% end
% Qtrial_list=[1 Qtrial]; %�ܹ�����16�����⣬��1��trail������֣��ڶ������ܳ���

 %Screen('Preference', 'SkipSyncTests', 1); 
PsychDefaultSetup(2);
screenNum=0; %change to 1 if use external monitor
[wPtr, rect]=Screen('OpenWindow', screenNum);

[xCenter, yCenter] = RectCenter(rect);
ifi=Screen('GetFlipInterval',wPtr);%get Screen flip interval
HideCursor;
white=100;%background grayscale level can be changed to match the face images
fontSize = 50;
Screen('FillRect', wPtr, white);
Screen('Flip',wPtr);

%% experiment start

Screen('TextSize',wPtr,fontSize);
Screen('TextFont', wPtr, 'SimHei'); 
DrawFormattedText(wPtr, '�밴�ո����ʼ', 'center', 'center', 0); % ��һ��ָ���� P125 %2021.3.13  wx
%DrawFormattedText(wPtr, 'Press the space bar to start', 'center', 'center', 0); % ��һ��ָ���� P125
Screen('Flip',wPtr);
% space = Kbname('space')
while 1 % �ȴ����ո������   
    [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
    %if keyIsDown
    if keyIsDown ==1    %2021.3.13  wx
        if keyCode(32) %Space bar keycode 44 on mac, keycode 32 on windows   ������KbName  P102
            while KbCheck; end %wait till release key press, only one key press is recognized
            break;
        end
    end
end

Screen('FillRect', wPtr, white);
Screen('Flip',wPtr);

%%
% CatIndex=Screen('MakeTexture', wPtr, Cat);
% RabbitIndex=Screen('MakeTexture', wPtr, Rabbit);
Trial=0; %�����trail�����������ڼ���
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %��ɫ��Ϻ�������P139

b_exit = false;

littleAngleInc = 0.1;
%largeAngleInc = 0.5;
limitAngle = 45;
limitAngle1 = 0.1;                                                         %2021.6.7  wx ��ʾ��F��J��ʧ�Ƕ�
% Presscount = 0;                                                          %2021.6.7  wx

% [rotateImg, map, alpha]=imread('./Stimuli/Money/money_tall_thin_zuo.png');
% rotateImgRGBA = rotateImg;
% rotateImgRGBA(:,:,4)=alpha;
% backGroundIm = imread('./picture/Dog_Left_1_Left.jpg');
% backGroundIndex=Screen('MakeTexture', wPtr, backGroundIm);
TrueTrial=0;
% ---------------------------------------------------------------------------%2021.10.6  wx
for block_nr = 1:1  %blockѭ��
    for back_nr=1:4  %backѭ��
        for tube_nr = 1:1 %tubeѭ��
% ---------------------------------------------------------------------------%2021.10.6  wx  
% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_nr = 1:10  %blockѭ��
%     for back_nr=1:8  %backѭ��
%         for tube_nr = 1:2 %tubeѭ��
% ---------------------------------------------------------------------------%2021.5.14  wx            
% for block_nr = 1:4  %blockѭ��
%     for back_nr=1:8  %backѭ��
%         for tube_nr = 1:4 %tubeѭ��
% ---------------------------------------------------------------------------%2021.5.14  wx
  %% ��ʼ����ʾ��������                                                 %2021.5.27  wx
  
  
           Trial=Trial+1;                                                   %2021.5.27  wx  
           Presscount = 0;                                                  %2021.6.7  wx
           %����һ�ֵ�����д����
           CurrentImg= ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).img;
           currentImgName = ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).name;
            
            S = strsplit(currentImgName,'\');
            name =  char(S{7}); % pwd���߲����ͼƬ����������
            condition = strsplit(name,'_');
            
            
            col7 = char(condition{1}); % male or dog or female
            % ��8����place
            if condition{2}(1) == 'L' 
                col8 = '1'; 
            elseif condition{2}(1) == 'R'
                col8 = '2';
            end
            %col7 = char(condition{2}); % place:left=1,right=2
            
            % ��9����Orientation
            if condition{3}(1) == 'L'
                col9 = '1'; 
            elseif condition{3}(1) == 'R'
                col9 = '2';
            elseif condition{3}(1) == 'N'                                  %2021.5.14  wx
                col9 = 'N';                                                %2021.5.14  wx
%             elseif condition{3}(1) == 'R'                                %2021.5.14  wx
%                 col9 = '2';
            end
            %col8 = char(condition{3}); % orientatoin
            
            % ��10����Arrow
            if condition{4}(1) == 'L'  
                col10 = '1'; 
            elseif condition{4}(1) == 'R'
                col10 = '2';
            end
            %col9 = char(condition{4}); % arrow
            
            % ��11����See(3) or NotSee(4)
            col11 = char(condition{5});
            
            % ��12����Push(5) or Pull(6)
            col12 = char(condition{6}(1));  
  
              fontSize2 = 200;
              Screen('TextSize',wPtr,fontSize2);
              if condition{4}(1) == 'L'  
                  DrawFormattedText(wPtr, double('��'), 'center', 'center', 0);                            
              elseif condition{4}(1) == 'R'
                   DrawFormattedText(wPtr, double('��'), 'center', 'center', 0); 
              end
                       
              Screen('Flip',wPtr); 
               WaitSecs(0.8);                                                  %��ʾʱ��
%                 WaitSecs(0.01);                                               %testʱ��

%%    

            %Trial=Trial+1;                                                 %2021.5.27  wx
            tic;  %��¼��ǰʱ��                                             %2021.5.27  wx          
            col18 = 'Null';     %18 19��Ԥ��Ϊ��  ���ڼ�¼���������trial  
            col19 = 'Null';
            %׼����������
%             CurrentImg=ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).img;%2021.5.27  wx   
            backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg); %p106
            
            
%             %����һ�ֵ�����д����
%             currentImgName = ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).name;
%             
%             S = strsplit(currentImgName,'\');
%             name =  char(S{7}); % pwd���߲����ͼƬ����������
%             condition = strsplit(name,'_');
%             
%             
%             col7 = char(condition{1}); % male or dog or female
%             % ��8����place
%             if condition{2}(1) == 'L' 
%                 col8 = '1'; 
%             elseif condition{2}(1) == 'R'
%                 col8 = '2';
%             end
%             %col7 = char(condition{2}); % place:left=1,right=2
%             
%             % ��9����Orientation
%             if condition{3}(1) == 'L'
%                 col9 = '1'; 
%             elseif condition{3}(1) == 'R'
%                 col9 = '2';
%             elseif condition{3}(1) == 'N'                                  %2021.5.14  wx
%                 col9 = 'N';                                                %2021.5.14  wx
% %             elseif condition{3}(1) == 'R'                                %2021.5.14  wx
% %                 col9 = '2';
%             end
%             %col8 = char(condition{3}); % orientatoin
%             
%             % ��10����Arrow
%             if condition{4}(1) == 'L'  
%                 col10 = '1'; 
%             elseif condition{4}(1) == 'R'
%                 col10 = '2';
%             end
%             %col9 = char(condition{4}); % arrow
%             
%             % ��11����See(3) or NotSee(4)
%             col11 = char(condition{5});
%             
%             % ��12����Push(5) or Pull(6)
%             col12 = char(condition{6}(1));
%  
            
            %׼����tube
            angle = 0;
            %��direction���޶�
            if col10(1) == '1'
                direction = 0;%1�� ���ҵ��� 0�� ����
            elseif col10(1) == '2'
                direction = 1;
            end
            
            xPos_off = 0;
            yPos_off = 138;
            
%             press_log = '';
            while 1 % ��spacebar��������һ��ͼƬ
                
                im_size = size(ImgTube_shape(tube_nr).img);
                
                baseRectDst = [0 0 im_size(2) im_size(1)] .* 1;
                
                xPos = xCenter;
                yPos = yCenter;
                
                dstRects = CenterRectOnPointd(baseRectDst, xPos + xPos_off, yPos + yPos_off); %���ξ�����ĳ�㣬��P111
                
                filterMode = 0;
                
                colorMod = [255, 255, 255, 255];
                
                texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);
                
                Screen('DrawTexture', wPtr, backGroundIndex); %������������
                
%                 zzrect = [1300 1080 1600 1200];
%                 Screen('FillRect', wPtr, [196,196,198], [1300 1080 1600 1200]); %���������ּ�ͷ�Ļ�ɫ����%2021.5.27  wx   2880*1800  
                Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %���������ּ�ͷ�Ļ�ɫ����%2021.5.27  wx   1920*1080  
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080   
                fontSize3 = 70;
                Screen('TextSize',wPtr,fontSize3);
                if condition{4}(1) == 'L'  
                      DrawFormattedText(wPtr, double('F'), 947, 770, 0); 
%                      DrawFormattedText(wPtr, double('�밴F����ʼ����'), 'center', 760, 0);
                elseif condition{4}(1) == 'R'
                      DrawFormattedText(wPtr, double('J'), 947, 770, 0);
%                      DrawFormattedText(wPtr, double('�밴J����ʼ����'), 'center', 760, 0);
                end                
               
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080 

                Screen('DrawTextures', wPtr, texIndex, [],...
                    dstRects, angle, filterMode, [], colorMod); %��������������P135
%                tic;  %��¼��ǰʱ��                                        %2021.5.29  wx

                
                %��tube������д��
                CurrentName_Tube=ImgTube_shape(tube_nr).name; % C:\graduates\shixian\begin\Stimuli\Paper\paper_tall_thin.png
                String_Tube = strsplit(CurrentName_Tube,'\');
                Tube_name =  char(String_Tube{7}); % pwd���߲����tubeͼƬ����������
                tube_condition = strsplit(Tube_name,'_'); %tube_condition��Ϊpaper��tall��thin
                
                %��13�� �߶�
                col13 ='';                                                 %2021.5.14  wx
%                 col13 = char(tube_condition{2});                         %2021.5.14  wx
%                 last_name = char(tube_condition{3});                     %2021.5.14  wx
                 
                %��14�� ���
                col14 ='';                                                 %2021.5.14  wx
%                 col14 = last_name(1:4);                                  %2021.5.14  wx

%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080
                if angle < -1 * limitAngle1
                    Screen('FillRect', wPtr, [196,196,198], [600 710 1300 810]); %���������ּ�ͷ�Ļ�ɫ����%2021.6.7  wx   1920*1080                 
                elseif angle >  limitAngle1
                    Screen('FillRect', wPtr, [196,196,198], [600 710 1300 810]); %���������ּ�ͷ�Ļ�ɫ����%2021.6.7  wx   1920*1080
                end

%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080        
                
                
                Screen('Flip', wPtr);
                
                [keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                if keyIsDown                        
                    if keyCode(32) %Space bar keycode 44 on mac, keycode 32 on windows
                        %�ж��Ƿ��������У����������������Ļ
                        test_time = toc; %ͳ��ʱ��
                        if ismember(Trial,Qtrial_list)
                      %% ������������У���һ����ʼ
                            Screen('TextSize',wPtr,fontSize);
%                             DrawFormattedText(wPtr, double('����һ�������У���ǰ����\��\��Ʒ��λ���ǣ�\n\n ��A��ߣ�L�ұ�'), 'center', 'center', 0); 
                            DrawFormattedText(wPtr, double('����һ�������У��˵�λ���ǣ�\n\n ��A��ߣ�L�ұ�'), 'center', 'center', 0);        %2021.10.6  wx
%                             DrawFormattedText(wPtr, double('What place is the current animal?\n����һ��trial�У���ǰ�����λ���ǣ�'), 'center', 'center', 0); 
                            Screen('Flip',wPtr);
                            
                              while 1 % ���ո���˳�
                                [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                                if keyIsDown %����а����ж�
                                    if keyCode(65) %�����A
                                        while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                        if col8=='1' %Place��Ӧ��ߣ�Ӧ�ð�A
                                            col18 = 'TRUE';
                                        else
                                            col18 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
                                 
                                    if keyCode(76) %�����L
                                        while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                        if col8=='2' %Place��Ӧ�ұߣ�Ӧ�ð�L
                                            col18 = 'TRUE';
                                        else
                                            col18 = 'FALSE';
                                        end
                                        
                                        break;                                                                       
                                    end
                                    
                                    if keyCode(27) %esc�˳�  ����ӣ����������水escҲΪ�˳�
                                         while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                           b_exit = true;
                                           break;           
                                    end                                    %2021.3.13  wx                                         
                                end
                                if b_exit
                                    break
                                end                                        %2021.3.13  wx
                                
                              end
                              if b_exit
                                    break
                              end                                          %2021.3.13  wx                             
% ��һ������                            
%% �ڶ�����ʼ  
                            Screen('TextSize',wPtr,fontSize);
%                             DrawFormattedText(wPtr, '����һ��trial�У���ǰ�����λ���ǣ�', 'center', 'center', 0);
%                             DrawFormattedText(wPtr, double('����һ�������У���ǰ����\�˵ĳ����ǣ�(��Ϊ��Ʒ�밴B)\n\n ��A����L����'), 'center', 'center', 0); 
                            DrawFormattedText(wPtr, double('����һ�������У��˵ĳ����ǣ�\n\n ��A����L����'), 'center', 'center', 0);  %2021.10.6  wx
%                             DrawFormattedText(wPtr, 'What orientation is the current animal?', 'center', 'center', 0); 
                            Screen('Flip',wPtr);
                            
                              while 1 % ���ո���˳�
                                [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                                if keyIsDown %����а����ж�                                          
                                    if keyCode(65) %�����A��������
                                        while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                        if col9=='1'
                                            col19 = 'TRUE';
                                        else
                                            col19 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
                                 
                                    if keyCode(76) %�����L��������
                                        while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                        if col9=='2'
                                            col19 = 'TRUE';
                                        else
                                            col19 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
 %--------------------------------------------------------------------------%2021.5.30  wx                                   
                                    if keyCode(66) %�����B�����޳���     
                                        while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                        if col9=='N'
                                            col19 = 'TRUE';
                                        end
                                        break;
                                    end                                    
 %--------------------------------------------------------------------------%2021.5.30  wx                                      
                                    if keyCode(27) %esc�˳�  ����ӣ����������水escҲΪ�˳�
                                         while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
                                           b_exit = true;
                                           break;           
                                    end                                    %2021.3.13  wx                    
                       
                                end
                                
                                if b_exit
                                    break
                                end                                        %2021.3.13  wx
                                
                              end
                              
                              if b_exit
                                  break 
                              end                                          %2021.3.13  wx                              
                            
                        end
                        if b_exit
                            break 
                        end                                                %2021.3.13  wx
                               
                        

                      while KbCheck; end %wait till release key press, only one key press is recognized
                        %                         Screen('Close',texIndex); % �رջ�ͼ����
                        break;
                    elseif keyCode(27) %esc�˳�  ����ӣ����������水escҲΪ�˳�
                        b_exit = true;
                        %                         Screen('Close',texIndex); % �رջ�ͼ����
                        break;
                    elseif keyCode(70) %F������㵹
%                         angle = angle - littleAngleInc; %F left  
%--------------------------------------------------------------------------%2021.6.7  wx
                        Presscount = Presscount+1; 
                        if Presscount > 16
                            angle = angle - littleAngleInc; %F left
                        else
                            r = 0.3 .* rand;
                            angle = angle - littleAngleInc - r;
                        end
%--------------------------------------------------------------------------%2021.6.7  wx                        
%                         press_log = [press_log, 'F'];
                        elseif keyCode(74)
%                         angle = angle + littleAngleInc; %J right
%--------------------------------------------------------------------------%2021.6.7  wx
                        Presscount = Presscount+1; 
                        if Presscount > 16
                            angle = angle + littleAngleInc; %F left
                        else
                            r = 0.3 .* rand;
                            angle = angle + littleAngleInc + r;
                        end
%--------------------------------------------------------------------------%2021.6.7  wx
%                         press_log = [press_log, 'J'];
%                     elseif keyCode(68)
%                        angle = angle - largeAngleInc; %D  left
%                        press_log = [press_log, 'D'];
%                     elseif keyCode(70)
%                        angle = angle + largeAngleInc; %F  right
%                        press_log = [press_log, 'F'];
                    end
                end
                
                if direction == 1 && angle < 0 %����涨���������ұߵ������ǽǶ�<0��˵�����������㵹�ļ���
                    angle = 0;
                end
                
                if direction == 0 && angle > 0
                    angle = 0;
                end
                      
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080
%                 if angle < -1 * limitAngle1
% %                     backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg);
% %                     texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);                
%                     Screen('DrawTexture', wPtr, backGroundIndex); %������������ 
%                     Screen('DrawTextures', wPtr, texIndex, [],...
%                         dstRects, angle, filterMode, [], colorMod); %��������������P135
%                     Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %���������ּ�ͷ�Ļ�ɫ����%2021.6.7  wx   1920*1080
%                     Screen('Flip',wPtr);                    
%                 elseif angle >  limitAngle1
% %                     backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg);
% %                     texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);                
%                     Screen('DrawTexture', wPtr, backGroundIndex); %������������ 
%                     Screen('DrawTextures', wPtr, texIndex, [],...
%                         dstRects, angle, filterMode, [], colorMod); %��������������P135
%                     Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %���������ּ�ͷ�Ļ�ɫ����%2021.6.7  wx   1920*1080
%                     Screen('Flip',wPtr);
%                 end

%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080                   
                if angle < -1 * limitAngle
                    angle = -1 * limitAngle;
                elseif angle >  limitAngle
                    angle = limitAngle;
                end
 

                TrueAngle = abs(angle);
            end
            
            %test_time = toc; %ͳ��ʱ��                                      %2021.5.28  wx
            
            TrueTrial= TrueTrial+1;
%             num = AnalysisPressLog(press_log);
%             fprintf(datafile,'%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%.3f,%.3f,%.3f,%d,%d,%s\n',TrueTrial,Design(Trial,1:5), col7, col8, col9, col10,col11,col12,angle,TrueAngle,test_time,num(1),num(2),press_log); % ��ʽ�����ÿ�� Trial ������
            fprintf(datafile,'%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%s,%s,%.3f,%.3f,%.3f,%s, %s\n',TrueTrial,Design(Trial,1:5), col7, col8, col9, col10,col11,col12,col13,col14,angle,TrueAngle,test_time,col18,col19); % ��ʽ�����ÿ�� Trial ������
            Screen('Close',texIndex); % �رջ�ͼ����
            if b_exit
                break
            end
        end
        if b_exit
            break
        end
    end
    if b_exit
        break
    end
    
%      if block_nr == 5                                                       %2021.5.14  wx
%     if block_nr == 2
    if block_nr == 3                                                       %2021.10.6  wx
        %% experiment start
        Screen('TextSize',wPtr,fontSize);
        DrawFormattedText(wPtr, '����Ϣһ��, ��Ϣ�ú���Enter������ʵ��', 'center', 'center', 0);   %2021.3.13  wx
        %DrawFormattedText(wPtr, 'Please take a rest, press Enter to continue', 'center', 'center', 0); 
        Screen('Flip',wPtr);
        StartTime=GetSecs;
% 
%         while GetSecs-StartTime<30 % �ȴ� 30 �루С�� 30 ���һֱִ�У�
%         end
        while 1 % �ȴ����ո������
            [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
            if keyIsDown
                if keyCode(13) %Enter keycode 13 on windows
                    while KbCheck; end %wait till release key press, only one key press is recognized
                    break;
                end
            end
        end
        
        Screen('FillRect', wPtr, white);
        Screen('Flip',wPtr);
    end
end



% StartTime=GetSecs; % �ٵ� 3 ��
% while GetSecs-StartTime<3
% end

%%
%DrawFormattedText(wPtr, 'End of the experiment.', 'center', 'center', 0); % �������������Ϣ  
Screen('TextSize',wPtr,fontSize);                                           %2021.5.27  wx 
DrawFormattedText(wPtr, 'ʵ�����', 'center', 'center', 0);                 %2021.3.13  wx
Screen('Flip',wPtr);

while 1 % ���ո���˳�
    [ keyIsDown, Secs, keyCode ] = KbCheck;  %check key press
    if keyIsDown % ����а����ж�
        if keyCode(32) %����ǿո�����ж�
            while KbCheck; end %���û�а�����һֱ�ȣ�ֱ���а���
            break;
        end
    end
end
Screen('CloseAll');
ShowCursor;
fclose(datafile);%close the data file




