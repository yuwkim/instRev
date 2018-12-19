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
% check the linetaker function at the end of the script.
%
data1.date=lineTaker(tline,file,'Start',1);
data1.boxNum=lineTaker(tline,file,'Box:',1);
data1.programName=lineTaker(tline,file,'MSN:',1);
data1.totalTrial=str2double(lineTaker(tline,file,'D:',1));
data1.totalReward=str2double(lineTaker(tline,file,'Q:',1));
data1.omission=str2double(lineTaker(tline,file,'R:',1));
data1.totalTimeInSec=str2double(lineTaker(tline,file,'X:',1));
data1.leftPress=str2double(lineTaker(tline,file,'Y:',1));
data1.rightPress=str2double(lineTaker(tline,file,'Z:',1));
%%
% Let's organize a bit.
%
if data1.totalTrial>150 % session ends at >151 trials, so the 151 trial initiated but not completed.
    data1.totalTrial=150;
end
data1.totalTime=join([string(fix(data1.totalTimeInSec/60)) 'min' ...
    rem(data1.totalTimeInSec,60) 'sec']);
%% Read numeric data
% (G: array) making animal choice data (0=omission,1=left,2=right)
% (J: array) making rewarded levers
% (L: array) making number of rewardss info

data1.choice=arrayTaker(tline,file,'G:',1);
data1.lever=arrayTaker(tline,file,'J:',1);
data1.reward=arrayTaker(tline,file,'L:',1);
data1.headEntry=arrayTaker(tline,file,'V:',1);
data1.pressLever=arrayTaker(tline,file,'W:',1);


% another sanity check with the same issue when it calculated choice array
if ~data1.totalReward==sum(data1.reward)
    warning('this animal hacked the system, be careful with data interpretation')
end
% reset indeces
data1.pctCorrect=sum(data1.reward)/(data1.totalTrial-data1.omission);
tline=fgetl(fileID);





%% read numeric data
%
%
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

%% functions
% lineTaker
%

function output= lineTaker(lineName,fileName,header,num)
fid = fopen(fileName,'rt');
for i=1:num
    while ~contains(lineName,header)
        lineName=fgetl(fid);
    end
    dataOnly=strsplit(lineName,':');
    output=dataOnly{1,2};
    lineName=fgetl(fid);
end
fclose(fid);
end

% arrayTaker

function output = arrayTaker(lineName,fileName,header,num)
fid = fopen(fileName,'rt');
for j=1:num
    while ~contains(lineName,header)
        lineName=fgetl(fid);
    end
    nrCul=5; % the Med PC software default value in a result file.
    totalTrial=150;
    tempArray=nan(round(totalTrial./nrCul)+1,nrCul); % +1, because of 0 trial, software's feature=> every var starts with 0.
    for i=1:length(tempArray)-1
        lineName=fgetl(fid);
        arrayByLine=strsplit(lineName,':');
        tempArray(i,:)=str2num(arrayByLine{1,2});
    end
    % for 150 trial, the demension problem.
    lineName=fgetl(fid);
    arrayByLine=strsplit(lineName,':');
    tempArray(i+1,1)=str2num(arrayByLine{1,2});
    % another sainty check.
    if contains(header,'G:') && ~tempArray(1,1)==0
        warning('this animal is a hacker! Be careful with data analysis')
        % there was an issue that animal could hack the behavioral system.
        % however, the important part of data is not contaminated.
        % so, it will keep going.
    end
    % make the array as a column vector
    tempArray(1,1)=nan;
    [m,n]=size(tempArray);
    revisedArray=reshape(tempArray',[m*n,1]);
    revisedArray(isnan(revisedArray))=[];
    output=revisedArray;
    lineName=fgetl(fid);
end
end
