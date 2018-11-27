% str=input('tell me the text file to analyze:','s');
% fileID=fopen([strtok(str,'.') '.txt'],'r');
% You can coment out this to run the code
fileID=fopen('full_24th_RL.txt','r+t'); %FOR YOUR CONVEINENCE
data.fileName=fgetl(fileID);

dataStr=textscan(fileID,'%s %s %s %s','delimiter',':');
%%
% read session information
for i = 1:length(dataStr{1,1})
    switch lower(dataStr{1,1}{i,1})
        case 'start date'
            data.startDate=dataStr{1,2}{i,1};
        case 'box'
            data.box=dataStr{1,2}{i,1};
        case 'start time'
            data.startTime=[dataStr{1,2}{i,1} ':' dataStr{1,3}{i,1} ':' dataStr{1,4}{i,1}];
        case 'end time'
            data.endTime=[dataStr{1,2}{i,1} ':' dataStr{1,3}{i,1} ':' dataStr{1,4}{i,1}];
        case 'msn'
            data.programName=dataStr{1,2}{i,1};
        case 'd'
            data.totalNrOfTrial=dataStr{1,2}{i,1};
        case 'p'
            data.pctCorrect=dataStr{1,2}{i,1};
        case 'q'
            data.reward=dataStr{1,2}{i,1};
        case 'r'
            data.omission=dataStr{1,2}{i,1};
        case 'y'
            data.leftPresses=dataStr{1,2}{i,1};
        case 'z'
            data.rightPresses=dataStr{1,2}{i,1};
        case 'g' % animal's actual choice, 0=omission;1=left;2=right, 
            choiceIndex=i+2;
        case 'j' % rewarded levers
            rewardIndex=i+2;
    end
    
end

%% read numeric data
frewind(fileID)
dataNum=textscan(fileID,'%s %f %f %f %f %f','headerlines',choiceIndex);
choice=cell2mat(dataNum(1,2:end));
data.actualChoice=reshape(choice(1:21,:),[],1);

frewind(fileID)
dataNum=textscan(fileID,'%s %f %f %f %f %f','headerlines',rewardIndex);
reward=cell2mat(dataNum(1,2:end));
data.rewardedLever=reshape(reward(1:21,:),[],1);
fclose(fileID);
figure;
scatter(1:length(data.actualChoice),data.actualChoice)
hold on
scatter(1:length(data.rewardedLever),data.rewardedLever,'filled')




%% descriptive statistics
startSession=datetime(data.startTime);
endSession=datetime(data.endTime);
data.sessionTime=endSession-startSession;