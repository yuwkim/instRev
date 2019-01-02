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
% by doing this, the code will work on Mac and PC the same.
if ismac || isunix
    tlineTemp=strsplit(tline,'\');
    tline=char(join(tlineTemp,'/'));
end

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
tagData=strsplit(file,'_');
matFileName=strsplit(file,'.');
tagData=tagData{1,1};

[data,hackerAnimal]=reversalReader(file);
if ~isempty(hackerAnimal) % temporary will be revised later
    switch length(hackerAnimal)
        case 1
            be='is animal';
        otherwise
            be='are animals';
    end
    warning(['Zerotrial response! There ' be ' hacked the program, box number: ' data(hackerAnimal).boxNum])
    save(matFileName{1,1},'data','tagData','hackerAnimal');
else
    save(matFileName{1,1},'data','tagData')
end

disp(['The processed data saved as ' matFileName{1,1} '.mat.']);

% wait for it, it takes time, about ~20s in Mac about ~90s in PC to analyze
% 12 animals.

fclose(fileID);
% Data reading done, analyzing starts

%% data reformation for analyzation.
%
%

% behavior program version check.
versionChecker=nan(length(data),1);
for i=1:length(data)
    versionChecker(i,1)=data(i).leftPress+data(i).rightPress+data(i).omission;
end
if any(~(versionChecker==150))
    warning('this result file was from an old version before dealing with hacking issue.')
end




for i=1:length(data)
    % 1. Pct correct during right lever or left lever
    anal(i).rightPressReward=data(i).reward(data(i).lever==1); % 1=left
    anal(i).leftPressReward=data(i).reward(data(i).lever==2); % 2=right this is in the behavior program code
    anal(i).pctCorRight=sum(anal(i).rightPressReward)/length(anal(i).rightPressReward);
    anal(i).pctCorLeft=sum(anal(i).leftPressReward)/length(anal(i).leftPressReward);
    if ttest2(anal(i).rightPressReward, anal(i).leftPressReward)
        if anal(i).pctCorRight>anal(i).pctCorLeft
            anal(i).biasedLever='Right Biased';
        else
            anal(i).biasedLever='Left Biased';
        end
    else
        anal(i).biasedLever='None';
    end
    
    % 2. one sample T-test, animals got right not by chance
    compRandom=repmat([0;1],length(data(i).reward)/2,1);
    [anal(i).oneSampleH,anal(i).oneSampleP] = ttest(data(i).reward,compRandom);
    % 3. number of switching rewarded levers.
    switching=diff(data(i).lever);
    anal(i).switching=switching;
    switching(switching==0)=[];
    anal(i).nrSwitching=length(switching);
    % 4. lever pressing probability
    switchingTrials=find(anal(i).switching);
    
    % switchingTrials(switchingTrials>140)=[]; % not enough amount of trials to test
    if anal(i).switching(switchingTrials(1,1),1)>0 % left->right switching
    
    end
    
end
% anotherCompRandom=ones(150,1);
% anotherCompRandom(1:(length(data(11).reward)/2),1)=0;
% [anotherH,anotherP] = ttest(data(11).reward,anotherCompRandom);
%% descriptive statistics
%
%

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

function [outputArray,hackerAnimal] = arrayTaker(lineName,fileName,header,num)
fid = fopen(fileName,'rt');
maxNumAnimal=12; % physically, my lab has 12 boxes.
hackerAnimal=nan(1,maxNumAnimal);
for j=1:num
    while ~contains(lineName,header)
        lineName=fgetl(fid);
    end
    nrCul=5; % the Med PC software default value in a result file.
    totalTrial=str2double(lineTaker(lineName,fileName,'D:',num))-1;
    tempArray=nan(round(totalTrial./nrCul)+1,nrCul); % +1, because of 0 trial, software's feature=> every var starts with 0.
    for i=1:length(tempArray)-1
        lineName=fgetl(fid);
        arrayByLine=strsplit(lineName,':');
        tempArray(i,:)=str2num(arrayByLine{1,2});
    end
    % for 150 trial, the demension problem.
    lineName=fgetl(fid);
    arrayByLine=strsplit(lineName,':');
    tempArray(i+1,1)=str2num(arrayByLine{1,2}); %#ok<*ST2NM>
    % another sainty check.
    if contains(header,'G:') && ~tempArray(1,1)==0
        hackerAnimal(1,j)=j;
    end
    % make the array as a column vector
    tempArray(1,1)=nan;
    [m,n]=size(tempArray);
    revisedArray=reshape(tempArray',[m*n,1]);
    revisedArray(isnan(revisedArray))=[];
    outputArray=revisedArray;
    hackerAnimal(isnan(hackerAnimal))=[];
    hackerAnimal((hackerAnimal==0))=[];
    lineName=fgetl(fid);
end
fclose(fid);
end

% reversalReader

function [output,hackerAnimal]= reversalReader(fileName)
fid=fopen(fileName,'rt');
% frewind(fid);
tline=fgetl(fid);
nrAnimals=0;
nrTotalBoxes=12; % physically, the number of behavioral chambers in my lab is 12.
while nrAnimals<nrTotalBoxes
    while ~contains(tline,'Box:')
        tline=fgetl(fid);
    end
    tline=fgetl(fid);
    nrAnimals=nrAnimals+1;
end
fclose(fid);
flds={'date','boxNum','programName','totalTrial','totalReward','omission',...
    'totalTimeInSec','leftPress','rightPress','totalTime','choice','lever',...
    'reward','headEntryTime','pressLeverTime','pctCorrect','rtIn10ms','avgRtInSec'};
nrFields=length(flds);
data=cell(nrFields,nrAnimals);
data=cell2struct(data,flds);
% after preallocation, it was 5s faster, wow.
if ismac
    disp(['it will not that be long, just wait a bit, about ' num2str(1.5.*nrAnimals) ' seconds?']);
elseif isunix
    disp('I havent run it on Linux, but it will not be long.');
else
    disp(['it is not stopped, just wait a bit, about ' num2str(7*nrAnimals) ' seconds?']);
end
for j=1:nrAnimals
    %% read session information
    % check the linetaker function at the end of the script.
    %
    data(j).date=lineTaker(tline,fileName,'Start Date:',j);
    data(j).boxNum=lineTaker(tline,fileName,'Box:',j);
    data(j).programName=lineTaker(tline,fileName,'MSN:',j);
    data(j).totalTrial=str2double(lineTaker(tline,fileName,'D:',j));
    data(j).totalReward=str2double(lineTaker(tline,fileName,'Q:',j));
    data(j).omission=str2double(lineTaker(tline,fileName,'R:',j));
    data(j).totalTimeInSec=str2double(lineTaker(tline,fileName,'X:',j));
    data(j).leftPress=str2double(lineTaker(tline,fileName,'Y:',j));
    data(j).rightPress=str2double(lineTaker(tline,fileName,'Z:',j));
    %%
    % Let's organize a bit.
    %
    if data(j).totalTrial>150 % session ends at >j5j trials, so the j5j trial initiated but not completed.
        data(j).totalTrial=150;
    end
    data(j).totalTime=join([string(fix(data(j).totalTimeInSec/60)) 'min' ...
        rem(data(j).totalTimeInSec,60) 'sec']);
    %% Read numeric data
    % (G: array) making animal choice data (0=omission,j=left,2=right)
    % (J: array) making rewarded levers
    % (L: array) making number of rewardss info
    %
    [data(j).choice,hackerAnimal]=arrayTaker(tline,fileName,'G:',j);
    data(j).lever=arrayTaker(tline,fileName,'J:',j);
    data(j).reward=arrayTaker(tline,fileName,'L:',j);
    data(j).headEntryTime=arrayTaker(tline,fileName,'V:',j);
    data(j).pressLeverTime=arrayTaker(tline,fileName,'W:',j);
    
    
    % another sanity check with the same issue when it calculated choice array
    if ~(data(j).totalReward==sum(data(j).reward))
        warning(['More pressing than total trials! Animal in the box' data(j).boxNum ' hacked the system, be careful with data interpretation'])
    end
    % reset indeces
    data(j).pctCorrect=sum(data(j).reward)/(data(j).totalTrial-data(j).omission);
    % nose poke to press lever, because of the medpc coding, a variable
    % starts with 0, there is 0 trial for head entry (nose poke) and 151th head
    % entry to finish the program. In a nutshell, we can get 149 of 150
    % reaction time. Plus, jitter timing of lever extension applied. jitter
    % range = 0.1s to 1s.
    data(j).rtIn10ms=data(j).pressLeverTime(2:length(data(j).pressLeverTime))-data(j).headEntryTime(1:length(data(j).headEntryTime)-1);
    data(j).avgRtInSec=mean(data(j).rtIn10ms(data(j).rtIn10ms>0 & data(j).rtIn10ms<3000))./100;
    % omission trial has 0 ms reaction time, so if the animal omitted the
    % trial, the rt will be huge, and it will be screened by indexing them with
    % 0> and <3000.
    be='are';
    patientMessage='Thank you for your patient.';
    if j==1
        be='is';
    elseif j>7 && j<nrAnimals-1
        patientMessage='I know it is long. Thank you.';
    elseif j==nrAnimals-1
        patientMessage='Almost done!!';
    end
    disp([num2str(j) ' out of ' num2str(nrAnimals) ' ' be ' done. ' patientMessage]);
end
output=data;
end
