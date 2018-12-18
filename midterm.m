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
while ~contains(tline,'Start')
    tline=fgetl(fileID);
end
dataOnly=strsplit(tline,':');
data1.date=dataOnly{1,2};
while ~contains(tline,'Box:')
    tline=fgetl(fileID);
end
boxNum=strsplit(tline,':');
data1.boxNum=boxNum{1,2};
while ~contains(tline,'MSN:')
    tline=fgetl(fileID);
end
programName=strsplit(tline,':');
data1.programName=programName{1,2};
while ~contains(tline,'D:')
    tline=fgetl(fileID);
end
totalTrial=strsplit(tline,':');
totalTrial=str2double(totalTrial{1,2});
data1.totalTrial=totalTrial;
if data1.totalTrial>150 % session ends at >151 trials, so the 151 trial initiated but not completed.
    data1.totalTrial=150;
end
while ~contains(tline,'Q:')
    tline=fgetl(fileID);
end
totalReward=strsplit(tline,':');
totalReward=str2double(totalReward{1,2});
data1.totalReward=totalReward;
while ~contains(tline,'R:')
    tline=fgetl(fileID);
end
omission=strsplit(tline,':');
omission=str2double(omission{1,2});
data1.omission=omission;
while ~contains(tline,'X:')
    tline=fgetl(fileID);
end
totalTime=strsplit(tline,':');
totalTime=str2double(totalTime{1,2});
data1.totalTimeInSec=totalTime;
data1.totalTime=join([string(round(totalTime/60)) 'min' rem(totalTime,60) 'sec']);
while ~contains(tline,'Y:')
    tline=fgetl(fileID);
end
leftPress=strsplit(tline,':');
leftPress=str2double(leftPress{1,2});
data1.leftPress=leftPress;
while ~contains(tline,'Z:')
    tline=fgetl(fileID);
end
rightPress=strsplit(tline,':');
rightPress=str2double(rightPress{1,2});
data1.rightPress=rightPress;

%% Read numeric data
% making animal choice data
%

while ~contains(tline,'G:')
    tline=fgetl(fileID);
end
nrCul=5; % the Med PC software default value in a result file.
choiceArray=nan(round(totalTrial./nrCul)+1,nrCul); % +1, because of 0 trial, software's feature=> every var starts with 0.
for i=1:length(choiceArray)-1
    tline=fgetl(fileID);
    rewardByLine=strsplit(tline,':');
    choiceArray(i,:)=str2num(rewardByLine{1,2});
end
% for 150 trial, the demension problem.
tline=fgetl(fileID);
rewardByLine=strsplit(tline,':');
choiceArray(i+1,1)=str2num(rewardByLine{1,2});
% another sainty check.
if ~choiceArray(1,1)==0
    warning('this animal is a hacker! Be careful with data analysis')
    % there was an issue that animal could hack the behavioral system.
    % however, the important part of data is not contaminated.
    % so, it will keep going.
end
% make the array as a column vector
choiceArray(1,1)=nan;
[m,n]=size(choiceArray);
revisedChoice=reshape(choiceArray',[m*n,1]);
revisedChoice(isnan(revisedChoice))=[];
data1.choice=revisedChoice;

%%
% making rewarded levers
%
while ~contains(tline,'J:')
    tline=fgetl(fileID);
end
leverArray=nan(round(totalTrial./nrCul)+1,nrCul); % +1, because of 0 trial, software's feature=> every var starts with 0.
for j=1:length(leverArray)-1
    tline=fgetl(fileID);
    leverByLine=strsplit(tline,':');
    leverArray(j,:)=str2num(leverByLine{1,2});
end
% for 150 trial, the demension problem.
tline=fgetl(fileID);
leverByLine=strsplit(tline,':');
leverArray(j+1,1)=str2num(leverByLine{1,2});
% make the array as a column vector
leverArray(1,1)=nan;
[m,n]=size(leverArray);
revisedlever=reshape(leverArray',[m*n,1]);
revisedlever(isnan(revisedlever))=[];
data1.lever=revisedlever;

%%
% making number of rewardss info
%
while ~contains(tline,'L:')
    tline=fgetl(fileID);
end
rewardArray=nan(round(totalTrial./nrCul)+1,nrCul); % +1, because of 0 trial, software's feature=> every var starts with 0.
for k=1:length(rewardArray)-1
    tline=fgetl(fileID);
    rewardByLine=strsplit(tline,':');
    rewardArray(k,:)=str2num(rewardByLine{1,2});
end
% for 150 trial, the demension problem.
tline=fgetl(fileID);
rewardByLine=strsplit(tline,':');
rewardArray(k+1,1)=str2num(rewardByLine{1,2});
% make the array as a column vector
rewardArray(1,1)=nan;
[m,n]=size(rewardArray);
revisedreward=reshape(rewardArray',[m*n,1]);
revisedreward(isnan(revisedreward))=[];
data1.reward=revisedreward;
% another sanity check with the same issue when it calculated choice array
if ~data1.totalReward==sum(data1.reward)
    warning('this animal hacked the system, be careful with data interpretation')
end
% reset indeces
i=1;j=1;k=1; 
data1.pctCorrect=sum(data1.reward)/(data1.totalTrial-data1.omission);
tline=fgetl(fileID);




while ~contains(tline,'V:')
    tline=fgetl(fileID);
end
tline=fgetl(fileID);
tline=fgetl(fileID);
%%
% except pct correct, all info will be sorted in the data1.

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
choiceArray=cell2mat(dataNum(1,2:end));
data.actualChoice=reshape(choiceArray(1:21,:),[],1);

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
