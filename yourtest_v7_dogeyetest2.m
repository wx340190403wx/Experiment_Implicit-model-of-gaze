%% Preliminary
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'TextEncodingLocale', 'UTF8') ;

rand('twister',sum(100*clock));

if ~IsOctave
    commandwindow;
else
    more off;
end

dummymode=0;
try 
    % STEP 1
    % Added a dialog box to set your own EDF file name before opening 
    % experiment graphics. Make sure the entered EDF file name is 1 to 8 
    % characters in length and only numbers or letters are allowed.
    if IsOctave
        edfFile = 'DEMO';
    else

    prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
    dlg_title = 'Create EDF file';
    num_lines= 1;
    def     = {'DEMO'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    %edfFile= 'DEMO.EDF'
    edfFile = answer{1};
    fprintf('EDFFile: %s\n', edfFile );
    end

    % STEP 2
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);

    % STEP 4
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end

    % the following code is used to check the version of the eye tracker
    % and version of the host software
    sw_version = 0;

    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', edffilename);
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end

    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    [width, height]=Screen('WindowSize', screenNumber);


    % STEP 5    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type, 
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);                
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set parser (conservative saccade thresholds)

    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    if sw_version >=4
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end

    % allow to use the big button on the eyelink gamepad to accept the 
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
   
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end



    % STEP 6
    % Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    el.backgroundcolour = [128 128 128];
    el.calibrationtargetcolour = [0 0 0];

    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    el.cal_target_beep=[600 0.5 0.05];
    el.drift_correction_target_beep=[600 0.5 0.05];
    el.calibration_failed_beep=[400 0.5 0.25];
    el.calibration_success_beep=[800 0.5 0.25];
    el.drift_correction_failed_beep=[400 0.5 0.25];
    el.drift_correction_success_beep=[800 0.5 0.25];
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);

    % Hide the mouse cursor;
    Screen('HideCursorHelper', window);
    EyelinkDoTrackerSetup(el);

Base_dir=pwd;
Exp_name = 'shixian'; 
Stimuli_dir=[Base_dir, '\Stimuli'];
Data_dir=[Base_dir, '\Data\'];
ID=input('Participant ID:','s');
filename=[Exp_name, '_S', ID, '_', date];
%--------------------------------------------------------------------------%%防覆盖代码
    if exist([Data_dir filename '.csv'], 'file')                           
        ret = input('文件已存在，确定要覆盖么？Y/N:','s');
        if ret == "Y" || ret == "y"
            delete([Data_dir filename '.csv']);
        else
            disp("退出");  
            return;
        end
    end
%--------------------------------------------------------------------------%%2021.3.13 wx
datafile=fopen([Data_dir filename '.csv'],'a+');
%fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Angle,TrueAngle,time(s),F,J,PressLog\n'); %共18列
%fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Angle,TrueAngle,time(s)\n'); %共15列
fprintf(datafile,'TrueTrial,Block,random_trial,Back_order,Tube_order,Trail,Animal,Place,Orientation,Arrow,See,Push,Height,Weight,Angle,TrueAngle,time(s),FirstQ,SecondQ\n'); %共19列
%% read background image
%Animal={'Dog';'Male'};                                                    %2021.5.14  wx
%Animal={'Dog';'Male';'Item'};                                             %2021.5.14  wx
Animal={'Dog'};                                                            %2021.10.6  wx
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

% read papar or money image 可 类比动物写循环结构
Tube={'Paper';'Money'};

ii= 1;
currentFolder=[Stimuli_dir '\' Tube{ii}]; %到...\stimuli\papaer
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

%% block随机排序
%--------------------------------------------------------------------------%2021.10.6  wx
BlockOrder=[1 1 1 1 1 1];                                                  %全是狗
%--------------------------------------------------------------------------%2021.10.6  wx

% ---------------------------------------------------------------------------%2021.5.14  wx
% BlockOrder=[1:2 1:2]; % 所有 Block 站出来排队
% BlockOrder=BlockOrder(randperm(4)); % 随机 Block 编号
% while prod(BlockOrder(1:3)-BlockOrder(2:4))==0 % 相邻 Block 不连续出现
%     BlockOrder=BlockOrder(randperm(4));
% end
% ---------------------------------------------------------------------------%2021.5.14  wx


BlockOrder=repmat(BlockOrder, [NwithinBlock 1]); % 把 Block 扩展到 Trial 水平
BlockOrder=reshape(BlockOrder, [TotalTrial 1]); % 把 Block 扩展成长格式以便输出

Design(:,1)=BlockOrder; % 把 Block 代码填入 Design 表格


%% trail随机排序
all_random_trial_Order = [];

% ---------------------------------------------------------------------------%2021.10.6  wx
for block_List = 1:6   %block type代替6
    
    TrialOrder=[1:16]; % 1个block里所有 trail 站出来排队
    TrialOrder=TrialOrder(randperm(16)); % 随机 trail编号
    while prod(TrialOrder(1:15)-TrialOrder(2:16))==0 % 相邻 trail 不连续出现
        TrialOrder=TrialOrder(randperm(16));
    end
    TrialOrder=reshape(TrialOrder, [16 1]);
    all_random_trial_Order = [all_random_trial_Order;TrialOrder];          %把每一次随机好的16个trial挂上去
    
end
% ---------------------------------------------------------------------------%2021.10.6  wx

% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_List = 1:10   %block type代替4    后面的32也用变量赋值
%     
%     TrialOrder=[1:16]; % 1个block里所有 trail 站出来排队
%     TrialOrder=TrialOrder(randperm(16)); % 随机 trail编号
%     while prod(TrialOrder(1:15)-TrialOrder(2:16))==0 % 相邻 trail 不连续出现
%         TrialOrder=TrialOrder(randperm(16));
%     end
%     TrialOrder=reshape(TrialOrder, [16 1]);
%     all_random_trial_Order = [all_random_trial_Order;TrialOrder];          %把每一次随机好的16个trial挂上去
%     
% end
% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_List = 1:4   %block type代替4    后面的32也用变量赋值
%     
%     TrialOrder=[1:32]; % 1个block里所有 trail 站出来排队
%     TrialOrder=TrialOrder(randperm(32)); % 随机 trail编号
%     while prod(TrialOrder(1:31)-TrialOrder(2:32))==0 % 相邻 trail 不连续出现
%         TrialOrder=TrialOrder(randperm(32));
%     end
%     TrialOrder=reshape(TrialOrder, [32 1]);
%     all_random_trial_Order = [all_random_trial_Order;TrialOrder]; %把每一次随机好的32个trial挂上去
%     
% end
% ---------------------------------------------------------------------------%2021.5.14  wx

Design(:,2)=all_random_trial_Order; % 把 random_Trial 填入 Design 表格第2列

%% 第三列和第四列是back_order和tube_order
[Back_order,Tube_order]=find_place(all_random_trial_Order);
Design(:,3) = Back_order;
Design(:,4) = Tube_order;

%% Trial编号
% ---------------------------------------------------------------------------%2021.5.14  wx
for i=1:10
    Design((i-1)*16+1:i*16,5)=[1:16]; % 在 Design 表格第5列填入真正的 Trial 编号
end
% ---------------------------------------------------------------------------%2021.5.14  wx
% for i=1:4
%     Design((i-1)*32+1:i*32,5)=[1:32]; % 在 Design 表格第5列填入真正的 Trial 编号
% end

%% 生成Qtrial编号，第二个trial必须，之后是96个之内不重复的随机数
% ---------------------------------------------------------------------------%2021.10.6  wx
Qtrial = randperm(96, 9); %可写range 规定范围 就可省略下方循环
while (ismember(1,Qtrial) | ismember(2,Qtrial))
    Qtrial = randperm(96, 9);
end
Qtrial_list=[1 Qtrial]; %总共出现16个问题，第1个trail必须出现，第二个不能出现
% ---------------------------------------------------------------------------%2021.5.14  wx
% Qtrial = randperm(160, 15); %可写range 规定范围 就可省略下方循环
% while (ismember(1,Qtrial) | ismember(2,Qtrial))
%     Qtrial = randperm(160, 15);
% end
% Qtrial_list=[1 Qtrial]; %总共出现16个问题，第1个trail必须出现，第二个不能出现
% ---------------------------------------------------------------------------%2021.5.14  wx
% %% 生成Qtrial编号，第二个trial必须，之后是128个之内不重复的随机数
% Qtrial = randperm(128, 15); %可写range 规定范围 就可省略下方循环
% while (ismember(1,Qtrial) | ismember(2,Qtrial))
%     Qtrial = randperm(128, 15);
% end
% Qtrial_list=[1 Qtrial]; %总共出现16个问题，第1个trail必须出现，第二个不能出现

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
DrawFormattedText(wPtr, '请按空格键开始', 'center', 'center', 0); % 第一屏指导语 P125 %2021.3.13  wx
%DrawFormattedText(wPtr, 'Press the space bar to start', 'center', 'center', 0); % 第一屏指导语 P125
Screen('Flip',wPtr);
% space = Kbname('space')
while 1 % 等待按空格键结束   
    [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
    %if keyIsDown
    if keyIsDown ==1    %2021.3.13  wx
        if keyCode(32) %Space bar keycode 44 on mac, keycode 32 on windows   按键用KbName  P102
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
Trial=0; %这里的trail算是行数，第几行
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %颜色混合函数，见P139

b_exit = false;

littleAngleInc = 0.1;
%largeAngleInc = 0.5;
limitAngle = 45;
limitAngle1 = 0.1;                                                         %2021.6.7  wx 显示的F或J消失角度
% Presscount = 0;                                                          %2021.6.7  wx

% [rotateImg, map, alpha]=imread('./Stimuli/Money/money_tall_thin_zuo.png');
% rotateImgRGBA = rotateImg;
% rotateImgRGBA(:,:,4)=alpha;
% backGroundIm = imread('./picture/Dog_Left_1_Left.jpg');
% backGroundIndex=Screen('MakeTexture', wPtr, backGroundIm);
TrueTrial=0;
% ---------------------------------------------------------------------------%2021.10.6  wx
for block_nr = 1:6  %block循环
    for back_nr=1:8  %back循环
        for tube_nr = 1:2 %tube循环
% ---------------------------------------------------------------------------%2021.10.6  wx  
% ---------------------------------------------------------------------------%2021.5.14  wx
% for block_nr = 1:10  %block循环
%     for back_nr=1:8  %back循环
%         for tube_nr = 1:2 %tube循环
% ---------------------------------------------------------------------------%2021.5.14  wx            
% for block_nr = 1:4  %block循环
%     for back_nr=1:8  %back循环
%         for tube_nr = 1:4 %tube循环
% ---------------------------------------------------------------------------%2021.5.14  wx
  %% 开始（提示调整方向）                                                 %2021.5.27  wx
  
  
           Trial=Trial+1;                                                  %2021.5.27  wx
           test_time = 0;                                                  %2022.7.6  wx
           Presscount = 0;                                                 %2021.6.7  wx
           %将这一轮的条件写入表格
           CurrentImg= ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).img;
           currentImgName = ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).name;
            
            S = strsplit(currentImgName,'\');
            name =  char(S{7}); % pwd第七层就是图片真正的名字
            condition = strsplit(name,'_');
            
            
            col7 = char(condition{1}); % male or dog or female
            % 第8列是place
            if condition{2}(1) == 'L' 
                col8 = '1'; 
            elseif condition{2}(1) == 'R'
                col8 = '2';
            end
            %col7 = char(condition{2}); % place:left=1,right=2
            
            % 第9列是Orientation
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
            
            % 第10列是Arrow
            if condition{4}(1) == 'L'  
                col10 = '1'; 
            elseif condition{4}(1) == 'R'
                col10 = '2';
            end
            %col9 = char(condition{4}); % arrow
            
            % 第11列是See(3) or NotSee(4)
            col11 = char(condition{5});
            
            % 第12列是Push(5) or Pull(6)
            col12 = char(condition{6}(1));  
  
              fontSize2 = 200;
              Screen('TextSize',wPtr,fontSize2);
              if condition{4}(1) == 'L'  
                  DrawFormattedText(wPtr, double('←'), 'center', 'center', 0);                            
              elseif condition{4}(1) == 'R'
                   DrawFormattedText(wPtr, double('→'), 'center', 'center', 0); 
              end
                       
              Screen('Flip',wPtr); 
               WaitSecs(0.8);                                                  %提示时间
%                 WaitSecs(0.01);                                               %test时间

%%    

            %Trial=Trial+1;                                                 %2021.5.27  wx
%             tic;  %记录当前时间                                             %2021.5.27  wx          
            col18 = 'Null';     %18 19列预设为空  用于记录随机的问题trial  
            col19 = 'Null';
            %准备画背景板
%             CurrentImg=ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).img;%2021.5.27  wx   
            backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg); %p106
            
            
%             %将这一轮的条件写入表格
%             currentImgName = ImgAnimal(Design(Trial,1)).background(Design(Trial,3)).name;
%             
%             S = strsplit(currentImgName,'\');
%             name =  char(S{7}); % pwd第七层就是图片真正的名字
%             condition = strsplit(name,'_');
%             
%             
%             col7 = char(condition{1}); % male or dog or female
%             % 第8列是place
%             if condition{2}(1) == 'L' 
%                 col8 = '1'; 
%             elseif condition{2}(1) == 'R'
%                 col8 = '2';
%             end
%             %col7 = char(condition{2}); % place:left=1,right=2
%             
%             % 第9列是Orientation
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
%             % 第10列是Arrow
%             if condition{4}(1) == 'L'  
%                 col10 = '1'; 
%             elseif condition{4}(1) == 'R'
%                 col10 = '2';
%             end
%             %col9 = char(condition{4}); % arrow
%             
%             % 第11列是See(3) or NotSee(4)
%             col11 = char(condition{5});
%             
%             % 第12列是Push(5) or Pull(6)
%             col12 = char(condition{6}(1));
%  
            %准备画tube
            angle = 0;
            %对direction的限定
            if col10(1) == '1'
                direction = 0;%1， 往右倒； 0， 往左倒
            elseif col10(1) == '2'
                direction = 1;
            end
            
            xPos_off = 0;
            yPos_off = 138;
            
                
            tic;  %记录当前时间                                             %2022.6.22  wx   
            
%             press_log = '';
            while 1 % 按spacebar键进入下一张图片

                im_size = size(ImgTube_shape(tube_nr).img);
                
                baseRectDst = [0 0 im_size(2) im_size(1)] .* 1;
                
                xPos = xCenter;
                yPos = yCenter;
                
                dstRects = CenterRectOnPointd(baseRectDst, xPos + xPos_off, yPos + yPos_off); %矩形居中至某点，见P111
                
                filterMode = 0;
                
                colorMod = [255, 255, 255, 255];
                               
                texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);
                
                Screen('DrawTexture', wPtr, backGroundIndex); %画出来背景板

                
%                 zzrect = [1300 1080 1600 1200];
%                 Screen('FillRect', wPtr, [196,196,198], [1300 1080 1600 1200]); %画出来遮罩箭头的灰色矩形%2021.5.27  wx   2880*1800  
                Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %画出来遮罩箭头的灰色矩形%2021.5.27  wx   1920*1080  
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080   
                fontSize3 = 70;
                Screen('TextSize',wPtr,fontSize3);
                if condition{4}(1) == 'L'  
                      DrawFormattedText(wPtr, double('F'), 947, 770, 0); 
%                      DrawFormattedText(wPtr, double('请按F键开始调节'), 'center', 760, 0);
                elseif condition{4}(1) == 'R'
                      DrawFormattedText(wPtr, double('J'), 947, 770, 0);
%                      DrawFormattedText(wPtr, double('请按J键开始调节'), 'center', 760, 0);
                end                
               
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080 
                Screen('DrawTextures', wPtr, texIndex, [],...
                    dstRects, angle, filterMode, [], colorMod); %见绘制纹理函数，P135
%                tic;  %记录当前时间                                        %2021.5.29  wx

                
                %将tube的名字写入
                CurrentName_Tube=ImgTube_shape(tube_nr).name; % C:\graduates\shixian\begin\Stimuli\Paper\paper_tall_thin.png
                String_Tube = strsplit(CurrentName_Tube,'\');
                Tube_name =  char(String_Tube{7}); % pwd第七层就是tube图片真正的名字
                tube_condition = strsplit(Tube_name,'_'); %tube_condition分为paper，tall，thin
                
                %第13列 高度
                col13 ='';                                                 %2021.5.14  wx
%                 col13 = char(tube_condition{2});                         %2021.5.14  wx
%                 last_name = char(tube_condition{3});                     %2021.5.14  wx
                 
                %第14列 宽度
                col14 ='';                                                 %2021.5.14  wx
%                 col14 = last_name(1:4);                                  %2021.5.14  wx

%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080
                if angle < -1 * limitAngle1
                    Screen('FillRect', wPtr, [196,196,198], [600 710 1300 810]); %画出来遮罩箭头的灰色矩形%2021.6.7  wx   1920*1080                 
                elseif angle >  limitAngle1
                    Screen('FillRect', wPtr, [196,196,198], [600 710 1300 810]); %画出来遮罩箭头的灰色矩形%2021.6.7  wx   1920*1080
                end

%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080        
                
                
                Screen('Flip', wPtr);
                
                [keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                if keyIsDown                        
                    if keyCode(32) %Space bar keycode 44 on mac, keycode 32 on windows
                        %判断是否在序列中，如果在跳到问题屏幕
                        test_time = toc; %统计时间
                        if ismember(Trial,Qtrial_list)
                      %% 如果是问题序列，第一屏开始
                            Screen('TextSize',wPtr,fontSize);
%                             DrawFormattedText(wPtr, double('在上一个环节中，当前动物\人\物品的位置是？\n\n 按A左边，L右边'), 'center', 'center', 0); 
                            DrawFormattedText(wPtr, double('在上一个环节中，当前狗的位置是？\n\n 按A左边，L右边'), 'center', 'center', 0);        %2021.10.6  wx
%                             DrawFormattedText(wPtr, double('What place is the current animal?\n在上一个trial中，当前动物的位置是？'), 'center', 'center', 0); 
                            Screen('Flip',wPtr);
                            
                              while 1 % 按空格键退出
                                [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                                if keyIsDown %如果有按键判断
                                    if keyCode(65) %如果是A
                                        while KbCheck; end %如果没有按键就一直等，直到有按键
                                        if col8=='1' %Place对应左边，应该按A
                                            col18 = 'TRUE';
                                        else
                                            col18 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
                                 
                                    if keyCode(76) %如果是L
                                        while KbCheck; end %如果没有按键就一直等，直到有按键
                                        if col8=='2' %Place对应右边，应该按L
                                            col18 = 'TRUE';
                                        else
                                            col18 = 'FALSE';
                                        end
                                        
                                        break;                                                                       
                                    end
                                    
                                    if keyCode(27) %esc退出  可添加：在其他界面按esc也为退出
                                         while KbCheck; end %如果没有按键就一直等，直到有按键
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
% 第一屏结束                            
%% 第二屏开始  
                            Screen('TextSize',wPtr,fontSize);
%                             DrawFormattedText(wPtr, '在上一个trial中，当前动物的位置是？', 'center', 'center', 0);
%                             DrawFormattedText(wPtr, double('在上一个环节中，当前动物\人的朝向是？(若为物品请按B)\n\n 按A朝左，L朝右'), 'center', 'center', 0); 
                            DrawFormattedText(wPtr, double('在上一个环节中，当前狗的朝向是？\n\n 按A朝左，L朝右'), 'center', 'center', 0);  %2021.10.6  wx
%                             DrawFormattedText(wPtr, 'What orientation is the current animal?', 'center', 'center', 0); 
                            Screen('Flip',wPtr);
                            
                              while 1 % 按空格键退出
                                [ keyIsDown, Secs, keyCode ] = KbCheck;%check key press
                                if keyIsDown %如果有按键判断                                          
                                    if keyCode(65) %如果是A代表向左
                                        while KbCheck; end %如果没有按键就一直等，直到有按键
                                        if col9=='1'
                                            col19 = 'TRUE';
                                        else
                                            col19 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
                                 
                                    if keyCode(76) %如果是L代表向右
                                        while KbCheck; end %如果没有按键就一直等，直到有按键
                                        if col9=='2'
                                            col19 = 'TRUE';
                                        else
                                            col19 = 'FALSE';
                                        end
                                        
                                        break;
                                    end
 %--------------------------------------------------------------------------%2021.5.30  wx                                   
                                    if keyCode(66) %如果是B代表无朝向     
                                        while KbCheck; end %如果没有按键就一直等，直到有按键
                                        if col9=='N'
                                            col19 = 'TRUE';
                                        end
                                        break;
                                    end                                    
 %--------------------------------------------------------------------------%2021.5.30  wx                                      
                                    if keyCode(27) %esc退出  可添加：在其他界面按esc也为退出
                                         while KbCheck; end %如果没有按键就一直等，直到有按键
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
                        %                         Screen('Close',texIndex); % 关闭绘图窗口
                        break;
                    elseif keyCode(27) %esc退出  可添加：在其他界面按esc也为退出
                        b_exit = true;
                        %                         Screen('Close',texIndex); % 关闭绘图窗口
                        break;
                    elseif keyCode(70) %F向左边倾倒
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
                
                if direction == 1 && angle < 0 %如果规定方向是往右边倒，但是角度<0，说明按了向左倾倒的键盘
                    angle = 0;
                end
                
                if direction == 0 && angle > 0
                    angle = 0;
                end
                      
%--------------------------------------------------------------------------%2021.6.7  wx   1920*1080
%                 if angle < -1 * limitAngle1
% %                     backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg);
% %                     texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);                
%                     Screen('DrawTexture', wPtr, backGroundIndex); %画出来背景板 
%                     Screen('DrawTextures', wPtr, texIndex, [],...
%                         dstRects, angle, filterMode, [], colorMod); %见绘制纹理函数，P135
%                     Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %画出来遮罩箭头的灰色矩形%2021.6.7  wx   1920*1080
%                     Screen('Flip',wPtr);                    
%                 elseif angle >  limitAngle1
% %                     backGroundIndex=Screen('MakeTexture', wPtr, CurrentImg);
% %                     texIndex=Screen('MakeTexture', wPtr, ImgTube_shape(j).img);                
%                     Screen('DrawTexture', wPtr, backGroundIndex); %画出来背景板 
%                     Screen('DrawTextures', wPtr, texIndex, [],...
%                         dstRects, angle, filterMode, [], colorMod); %见绘制纹理函数，P135
%                     Screen('FillRect', wPtr, [196,196,198], [867 710 1067 810]); %画出来遮罩箭头的灰色矩形%2021.6.7  wx   1920*1080
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
            
            %test_time = toc; %统计时间                                      %2021.5.28  wx
            
            TrueTrial= TrueTrial+1;
%             num = AnalysisPressLog(press_log);
%             fprintf(datafile,'%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%.3f,%.3f,%.3f,%d,%d,%s\n',TrueTrial,Design(Trial,1:5), col7, col8, col9, col10,col11,col12,angle,TrueAngle,test_time,num(1),num(2),press_log); % 格式化输出每个 Trial 的数据
            fprintf(datafile,'%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%s,%s,%.3f,%.3f,%.3f,%s, %s\n',TrueTrial,Design(Trial,1:5), col7, col8, col9, col10,col11,col12,col13,col14,angle,TrueAngle,test_time,col18,col19); % 格式化输出每个 Trial 的数据
            Screen('Close',texIndex); % 关闭绘图窗口
            if b_exit
                break
            end
            % STEP 7.1 
            % Sending a 'TRIALID' message to mark the start of a trial in Data 
            % Viewer.  This is different than the start of recording message 
            % START that is logged when the trial recording begins. The viewer
            % will not parse any messages, events, or samples, that exist in 
            % the data file prior to this message. 
            Eyelink('Message', 'TRIALID %d', i);

            % This supplies the title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message "TRIAL %d/%d  %s"', i, 3, imgfile); 
            % Before recording, we place reference graphics on the host display
            % Must be offline to draw to EyeLink screen
            Eyelink('Command', 'set_idle_mode');
            % clear tracker display and draw box at center
            Eyelink('Command', 'clear_screen 0')
            Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %transfer image to host
            transferimginfo=imfinfo(imgfile);

            fprintf('img file name is %s\n',transferimginfo.Filename);


            % image file should be 24bit or 32bit bitmap
            % parameters of ImageTransfer:
            % imagePath, xPosition, yPosition, width, height, trackerXPosition, trackerYPosition, xferoptions
            transferStatus =  Eyelink('ImageTransfer',transferimginfo.Filename,0,0,transferimginfo.Width,transferimginfo.Height,width/2-transferimginfo.Width/2 ,height/2-transferimginfo.Height/2,1);
            if transferStatus ~= 0
                fprintf('*****Image transfer Failed*****-------\n');
            end

            WaitSecs(0.1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            % STEP 7.2
            % Do a drift correction at the beginning of each trial
            % Performing drift correction (checking) is optional for
            % EyeLink 1000 eye trackers.
            EyelinkDoDriftCorrection(el);  

            % STEP 7.3
            % start recording eye position (preceded by a short pause so that 
            % the tracker can finish the mode transition)
            % The paramerters for the 'StartRecording' call controls the
            % file_samples, file_events, link_samples, link_events availability
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            % Eyelink('StartRecording', 1, 1, 1, 1);    
            Eyelink('StartRecording');    
            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data 
            WaitSecs(0.1);

            % STEP 7.4
            % Prepare and show the screen. 
            Screen('FillRect', window, el.backgroundcolour);   
            imdata=imread(imgfile);
            imageTexture=Screen('MakeTexture',window, imdata);
            Screen('DrawTexture', window, imageTexture);
            Screen('DrawText', window, 'Press the SPACEBAR or BUTTON 5 to end the recording of the trial.', floor(width/5), floor(height/2), 0);
            Screen('Flip', window);
            % write out a message to indicate the time of the picture onset
            % this message can be used to create an interest period in EyeLink
            % Data Viewer.

            Eyelink('Message', 'SYNCTIME');

            % Send an integration message so that an image can be loaded as 
            % overlay backgound when performing Data Viewer analysis.  This 
            % message can be placed anywhere within the scope of a trial (i.e.,
            % after the 'TRIALID' message and before 'TRIAL_RESULT')
            % See "Protocol for EyeLink Data to Viewer Integration -> Image 
            % Commands" section of the EyeLink Data Viewer User Manual.
            Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', imgfile, width/2, height/2);

            stopkey=KbName('space');

            % STEP 7.5
            % Monitor the trial events;
            while 1 % loop till error or space bar is pressed
                % Check recording status, stop display if error
                error=Eyelink('CheckRecording');
                if(error~=0)
                    break;
                end


                % ending by pressing button 5
                buttonResult = Eyelink('ButtonStates');
                if buttonResult
                    if(bitshift(buttonResult, -4)==1)  %fprintf('button 5 pressed\n');
                        Eyelink('Message','Button 5 pressed');
                        break;
                    end
                end

                % check for keyboard press
                [keyIsDown,secs,keyCode] = KbCheck;
                % if spacebar was pressed stop display
                if keyCode(stopkey)
                    Eyelink('Message', 'Key pressed');
                    break;
                end
            end % main loop


            % STEP 7.6
            % Clear the display
            Screen('FillRect', window, el.backgroundcolour);
            Screen('Flip', window);
            Eyelink('Message', 'BLANK_SCREEN');
            % adds 100 msec of data to catch final events
            WaitSecs(0.1);
            % stop the recording of eye-movements for the current trial
            Eyelink('StopRecording');


            % STEP 7.7
            % Send out necessary integration messages for data analysis
            % Send out interest area information for the trial
            % See "Protocol for EyeLink Data to Viewer Integration-> Interest 
            % Area Commands" section of the EyeLink Data Viewer User Manual
            % IMPORTANT! Don't send too many messages in a very short period of
            % time or the EyeLink tracker may not be able to write them all 
            % to the EDF file.
            % Consider adding a short delay every few messages.

            % Please note that  floor(A) is used to round A to the nearest
            % integers less than or equal to A

            WaitSecs(0.001);
            Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(width/2)-50, floor(height/2)-50, floor(width/2)+50, floor(height/2)+50,'center');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, floor(width/4)-50, floor(height/2)-50, floor(width/4)+50, floor(height/2)+50,'left');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 3, floor(3*width/4)-50, floor(height/2)-50, floor(3*width/4)+50, floor(height/2)+50,'right');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 4, floor(width/2)-50, floor(height/4)-50, floor(width/2)+50, floor(height/4)+50,'up');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 5, floor(width/2)-50, floor(3*height/4)-50, floor(width/2)+50, floor(3*height/4)+50,'down');


            % Send messages to report trial condition information
            % Each message may be a pair of trial condition variable and its
            % corresponding value follwing the '!V TRIAL_VAR' token message
            % See "Protocol for EyeLink Data to Viewer Integration-> Trial
            % Message Commands" section of the EyeLink Data Viewer User Manual
            WaitSecs(0.001);
            Eyelink('Message', '!V TRIAL_VAR index %d', i)        
            Eyelink('Message', '!V TRIAL_VAR imgfile %s', imgfile)               

            % STEP 7.8
            % Sending a 'TRIAL_RESULT' message to mark the end of a trial in 
            % Data Viewer. This is different than the end of recording message 
            % END that is logged when the trial recording ends. The viewer will
            % not parse any messages, events, or samples that exist in the data 
            % file after this message.
            Eyelink('Message', 'TRIAL_RESULT 0')
        end   

                % STEP 8
                % End of Experiment; close the file first   
                % close graphics window, close data file and shut down tracker

                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.5);
                Eyelink('CloseFile');

                % download data file
                try
                    fprintf('Receiving data file ''%s''\n', edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                end

                % STEP 9
                % close the eye tracker and window
                  Eyelink('ShutDown');
                  Screen('CloseAll');

            catch
                 %this "catch" section executes in case of an error in the "try" section
                 %above.  Importantly, it closes the onscreen window if its open.
                  Eyelink('ShutDown');
                  Screen('CloseAll');
            %      commandwindow;
            %      rethrow(lasterr);
            end %try..catch.
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
        DrawFormattedText(wPtr, '请休息一下, 休息好后按下Enter键继续实验', 'center', 'center', 0);   %2021.3.13  wx
        %DrawFormattedText(wPtr, 'Please take a rest, press Enter to continue', 'center', 'center', 0); 
        Screen('Flip',wPtr);
        StartTime=GetSecs;
% 
%         while GetSecs-StartTime<30 % 等待 30 秒（小于 30 秒就一直执行）
%         end
        while 1 % 等待按空格键结束
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



% StartTime=GetSecs; % 再等 3 秒
% while GetSecs-StartTime<3
% end


%%
%DrawFormattedText(wPtr, 'End of the experiment.', 'center', 'center', 0); % 输出结束程序信息  
Screen('TextSize',wPtr,fontSize);                                           %2021.5.27  wx 
DrawFormattedText(wPtr, '实验结束', 'center', 'center', 0);                 %2021.3.13  wx
Screen('Flip',wPtr);

while 1 % 按空格键退出
    [ keyIsDown, Secs, keyCode ] = KbCheck;  %check key press
    if keyIsDown % 如果有按键判断
        if keyCode(32) %如果是空格键就中断
            while KbCheck; end %如果没有按键就一直等，直到有按键
            break;
        end
    end
end
Screen('CloseAll');
ShowCursor;
fclose(datafile);%close the data file




