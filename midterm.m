%% Read a data file
% 
% For a sanity check, this code will run only with a selection of text
% file.
%
clear
[file,path,indx] = uigetfile('*.txt');
if isequal(file,0)
    disp('Data Analysis Aborted.')
    return
elseif ~contains(file,'.txt')
    warning('This only can analyze text files.')
    return
else
    disp(['Analyzing ', fullfile(path, file)])
end
fileID = fopen([path file],'rt');
tline=fgetl(fileID);
[pathT,fileT,ext]=fileparts(tline);
%%
% another line of sanity checking.
% if the subject of analysis is not an original text file from my behavior
% software, the warning message will be appeared, but the process will keep
% going on.
%
if ~contains(file,fileT)
    warning('this is NOT an original data txt file, the consequence of analysis is on you.')
end
%% read session information
% 
% 
while ~contains(tline, 'Start')
    tline=fgetl(fileID);
end
dataOnly=strsplit(tline,':');
data.date=dataOnly{1,2};
while ~contains(tline, 'Box:')
     tline=fgetl(fileID);
end
boxNum=strsplit(tline,':');
data.boxNum=boxNum{1,2};
while ~contains(tline, 'MSN:')
     tline=fgetl(fileID);
end
programName=strsplit(tline,':');
data.programName=programName{1,2};
% dataStr=textscan(fileID,'%s %s %s %s','delimiter',':');

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
%
% 
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
%
%
startSession=datetime(data.startTime);
endSession=datetime(data.endTime);
data.sessionTime=endSession-startSession;
