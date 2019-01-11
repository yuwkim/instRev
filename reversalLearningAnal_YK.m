%% Reversal Learning Analyzer Ver 0.82 by YK
%
% This is a set of scripts to analyze the result file of reversal learning
% paradigm (motivated by Parker et al., 2016).
% The original looking of the result file is like this.
%
% Start Date: 11/22/18
% End Date: 11/22/18
% ... ... (syncopation)
% Start Time: 11:06:06
% End Time: 11:45:56
% MSN: Inst Rev Full v8 RL even_Yk_150trials test
% A:       0.000
% B:   10000.000
% C:   10000.000
% D:     151.000
% E:       2.000
% ... ... (syncopation)
% G:
%      0:        0.000        1.000        1.000        2.000        1.000
%      5:        2.000        2.000        1.000        2.000        1.000
%     10:        2.000        2.000        1.000        2.000        1.000
%     15:        2.000        2.000        2.000        1.000        2.000
% ... ... (continues)
%
% This user-unfriendly, counterintuitive and redundant data will be
% organized, sorted, and trimmed in this code.
%
% (flowchart)
% reversalReader(text file)= data-----> reversalAnalyzer(data)= anal---->plotting([anal,model])
%   - lineTaker or arrayTaker           logisticRegressor(data)= model
%
% This Analyzer works in this scheme.
% 1. Reading Data
%    - reversalReader: a function reversalReader organizes and assigns data
%                     types and a way of sorting them with 2 functions;
%                     (1) lineTaker and (2) arrayTaker.
%    - Sorted data will be saved as a struct 'data' with a date tagging,
%     'tagData'.
% 2. Analyze Data
%    - reversalAnalyzer: this will do basic analysis, such as whether
%                       the animal was biased to pressing a certain side of
%                       a lever or were animals' performance is above a
%                       chance. The analyzed data will be saved as a struct
%                       'anal'.
%    - logisticRegressor: This is a modeling to figure out whether the
%                        animal is updating the information from previous
%                        tirals. In other words, by using a logistic
%                        regression scheme I try to predict whether the
%                        consequence of previous trials influence the
%                        current trial. Details will be in the help section
%                        of this function. The data will be saved as a
%                        struct 'model', regression coefficient in one
%                        matrix 'betaValuesInMat', logic matrix of
%                        rejecting null hypothesis 'h', p-values for this h
%                        array as 'p', and the fitness of the modeling of
%                        each animal as 'rSquared'.
% 3. Drawing data (currently in working)
%

%% load data file
%
clear
% I thought for some users who are not familiar with coding the origin of
% a warning msg is not informative but a distraction.
%
warning('off','backtrace')
% Since the name of the result file is long, I decided to make it with
% (GUI) clicking the file.
%
[file,path,indx] = uigetfile('*.txt');
% if the user did not choose a txt file to analyze, the script will be
% stopped runing. If the chosen file is not a txt file, it will also stop,
% saying to choose a txt file.
%
if isequal(file,0)
    disp('Data Analysis Aborted.')
    return
    % For a sanity check, this code will run only with a selection of a text file.
elseif ~contains(file,'.txt')
    warning('This only can analyze text files.')
    return
else
    disp(['Analyzing ', fullfile(path, file)])
end
% the subject of analyzation will be appeard.
%
fileID = fopen([path file],'rt');
tline=fgetl(fileID);
% by doing this, the code will work on Mac including linux and PC the same.
%
if ismac || isunix
    tlineTemp=strsplit(tline,'\');
    tline=char(join(tlineTemp,'/'));
end
[pathT,fileT,ext]=fileparts(tline);

%% Saving results
% for taging the data. Let's take the date information from the data file.
% and this information will be used to name the result mat file.
%
tagData=strsplit(file,'_');
matFileName=strsplit(file,'.');
tagData=tagData{1,1};
%%
% reading the data file by 'reversalReader' function.
% it will make data struct which has organized basic raw data and a list of
% animals using a bug of behavioral program.
%
[data,hackerAnimal2,hackerAnimal1]=reversalReader(fileID);
%%
% analyze the read data by 'reversalAnalyzer' function.
% the output struct 'anal' will have basic analyzed information like biased
% lever, onesample ttest, numbers of switching lever.
%
[anal,hackerAnimal3]=reversalAnalyzer(data);
%%
% use logistic regression model for analyzing and modeling the behavior of
% animals with 'logsticRegression' function.
% logistic regression provides that whether the animal updated the
% information from previous trials. Motivated from Parker et al., 2016.
%
%
[model,betaValuesInMat,rSquared,p,h]=logisticRegressor(data);

%%
% By the unidentified bug, animals could hack the behavior program. It was
% a retracted lever pressing.
%
hackerAnimals=[hackerAnimal2;hackerAnimal1;hackerAnimal3];
boxNum=cat(2,data.boxNum);
if ~isempty(hackerAnimals)
    switch length(hackerAnimal2)
        case 1
            be='is animal';
        otherwise
            be='are animals';
    end
    warning(['Type2 hacking! Zerotrial response! There ' be ' hacked the program, box number: ' num2str(boxNum(hackerAnimal2)) '. These animals are excluded in the data analysis.'])
    %hackerAnimals=[hackerAnimal2;hackerAnimal1;hackerAnimal3];
    finishedOrderHackerAnimal=unique(hackerAnimals);
else
    finishedOrderHackerAnimal=nan;
end
save(fullfile(path,matFileName{1,1}),'data','anal','model','tagData','h','p','betaValuesInMat','rSquared','finishedOrderHackerAnimal');
disp(['The processed data saved as ' fullfile(path,matFileName{1,1}) '.mat.']);
% Data reading done.
%
fclose(fileID);


%% Sanity checking
% one sanity checking.
% if the subject of analysis is not an original text file from my behavior
% software, the warning message will be appeared, but the process will keep
% going on.
% this works because, the original data file from MED-PC software always
% includes information like this in the first line of the data file
%
% File: C:\MED-PC\Data\2018-11-16_15h09m_Subject .txt
%
% And, this info is supposed to match with the title of the data file.
%
if ~contains(file,fileT)
    warning('this is NOT an original data txt file, the consequence of analysis is on you.')
end
%%
% another sanity check.
% behavior program version check.
% using old version of behavior controlling program, by far there is no
% issue other than pressing retracted lever--hacking behavior. This was
% confirmed by video recording during behavior session.
% However, just in case, I provided this info, too.
%
versionChecker=nan(length(data),1);
for i=1:length(data)
    versionChecker(i,1)=data(i).leftPress+data(i).rightPress+data(i).omission;
end
if any(~(versionChecker==150))
    disp('this result file was from an old version before solving the hacking issue.')
end

%%
% Valid Animal checking

dataTable=struct2table(data);
totAnimals=table2array(dataTable(:,2));
boxNum=cat(1,data.boxNum);
if ~isnan(finishedOrderHackerAnimal)
    totAnimals(finishedOrderHackerAnimal)=[];
end
% based on my lab notes
%
if strcmp(tagData,'2018-11-20')
    mutantAnimals=[2;3;4;5;8;12];
elseif ismember(tagData,['2018-11-23','2018-11-26','2018-11-27'])
    mutantAnimals=[4;5;9;10;11;12];
elseif ismember(tagData,['2018-12-03','2018-12-04','2018-12-05'])
    mutantAnimals=[3;4;5;7;8;12];
else
    mutantAnimals=[1;2;3;4;5;12]; 
end
mutantValidAnimals=intersect(mutantAnimals,totAnimals);
wildtyeValidAnimals=totAnimals(~ismember(totAnimals,mutantAnimals));

%% plotting starts!
%

nrTrainningDays=dataDrawer(data,tagData,finishedOrderHackerAnimal,mutantValidAnimals,wildtyeValidAnimals);
analDrawer(anal,nrTrainningDays,tagData,finishedOrderHackerAnimal,mutantValidAnimals,wildtyeValidAnimals)

%% functions
%
% lineTaker
%

function output= lineTaker(fileName,header)
% This is a function to sort a type of data like this .
%
% Start Date: 12/06/18
%
% this function will take the part after ':', in this example, 12/06/18.
%
% Inputs
% lineName: a line of information, a subject of the function.
% fileName: a name of the file, which contains the line--the subject of the
%           function.
% header  : a part of the line before ':', in this example, Start Date.
% num     : a number of repeating, up to 12 animals' behavioral data can be
%           recorded per day. repeat twice= 2nd animal's data, repeat
%           triple= 3rd animal's data. Saving multiple animals' data is out
%           of my control, default setting of MED-PC software.

dataOnly=strsplit(fileName,':');
tline=dataOnly{1,2};
switch header
    case'Box:'
        tline=str2num(dataOnly{1,2});
end
output=tline;
end
%%
% arrayTaker

function [outputArray,hackerAnimal] = arrayTaker(fileName,header,totalTrial,num,varargin)
% This is a function to sort a type of data like this .
%
% G:
%      0:        0.000        2.000        2.000        2.000        1.000
%      5:        2.000        2.000        1.000        2.000        2.000
%     10:        2.000        2.000        1.000        1.000        2.000
%     15:        1.000        2.000        1.000        1.000        2.000
%     ....(continues...)
%
% (name of array)
% G:
% (row number indicator)
% 0:
% 5:
% 10:
% ... ...
% (real data)
%  0.000        2.000        2.000        2.000        1.000
%  2.000        2.000        1.000        2.000        2.000
%  ... ...
% this function will only take a part of real data.
%
% Inputs
% arrayName: an array of information, a subject of the function
% fileName: a name of the file, which contains the array--the subject of
%           the function.
% header  : a part of the line before ':', in this example, G:, a name of
%           array.
% num     : a number of repeating, up to 12 animals' behavioral data can be
%           recorded per day. repeat twice= 2nd animal's data, repeat
%           triple= 3rd animal's data. Saving multiple animals' data is out
%           of my control, default setting of MED-PC software.
p=inputParser;
p.addParameter('nrCulumn',5,@(x) x>0 && rem(x,1)==0);
p.parse(varargin{:});

hackerAnimal=nan;
nrCul=p.Results.nrCulumn; % the Med PC software default value in a result file.
% +1, because of 0 trial, software's feature=> every var starts with 0.
tempArray=nan(round(totalTrial./nrCul)+1,nrCul);
for i=1:length(tempArray)-1
    arrayName=fgetl(fileName);
    arrayByLine=strsplit(arrayName,':');
    tempArray(i,:)=str2num(arrayByLine{1,2});
end
% for 150 trial, the demension problem.
arrayName=fgetl(fileName);
arrayByLine=strsplit(arrayName,':');
tempArray(i+1,1)=str2num(arrayByLine{1,2}); %#ok<*ST2NM>
% another sainty check.
if contains(header,'G:') && tempArray(1,1)~=0
    hackerAnimal=num;
end
% make the array as a column vector
tempArray(1,1)=nan;
tempArray=tempArray';
revisedArray=tempArray(:);
revisedArray(isnan(revisedArray))=[];
outputArray=revisedArray;
end
%%
% reversalReader

function [output,hackerAnimal,hackerAnimal1]= reversalReader(fileName,varargin)
% This is a function assigning which type of data will be analyzed by which
% function--lineTaker and arrayTaker. Simultaneuously, it also makes a
% struct array to store the data after analyzation. This function has the
% header information of txt files, such as variable D in the txt file is a
% total number of trials, or variable L in the txtfile is an array
% including reinforcer dispensing at each trials.
%
% Input
% fileName: the name of the txt file to analyze with the file location--file path.
%

p=inputParser;
p.addParameter('workingBoxes',12,@(x) x>0 && rem(x,1)==0);
p.addParameter('totNumAnimal',12,@(x) x>0 && x<12);
p.parse(varargin{:});

tline=fgetl(fileName);
nrAnimals=0; % this var will change based on the result of the calculation below. it is not solid 0.
nrTotalBoxes=p.Results.workingBoxes;
while nrAnimals<nrTotalBoxes
    while ~contains(tline,'Box:')
        tline=fgetl(fileName);
    end
    tline=fgetl(fileName);
    nrAnimals=nrAnimals+1;
end
% preallocation of the struct array in the for-loop
flds={'date','boxNum','programName','totalTrial','totalReward','omission',...
    'totalTimeInSec','leftPress','rightPress','totalTime','pctCorrect',...
    'choice','lever','reward','headEntryTime','pressLeverTime','rtIn10ms','avgRtInSec'};
nrFields=length(flds);
data=cell(nrFields,nrAnimals);
data=cell2struct(data,flds);
hackerAnimal=nan(nrAnimals,1);
frewind(fileName);
hackerAnimal1=nan(nrAnimals,1);
for j=1:nrAnimals
    while ~feof(fileName)
        tline=fgetl(fileName);
        headerOnly=strsplit(tline,':');
        switch headerOnly{1,1}
            case 'Start Date'
                data(j).date=lineTaker(tline,'Start Date:');
            case 'Box'
                data(j).boxNum=lineTaker(tline,'Box:');
            case 'MSN'
                data(j).programName=lineTaker(tline,'MSN:');
            case 'D'
                data(j).totalTrial=str2double(lineTaker(tline,'D:'));
                if data(j).totalTrial>150 % session ends at >151 trials, so the 151 trial initiated but not completed.
                    data(j).totalTrial=150;
                end
            case 'Q'
                data(j).totalReward=str2double(lineTaker(tline,'Q:'));
            case 'R'
                data(j).omission=str2double(lineTaker(tline,'R:'));
            case 'X'
                data(j).totalTimeInSec=str2double(lineTaker(tline,'X:'));
            case 'Y'
                data(j).leftPress=str2double(lineTaker(tline,'Y:'));
            case 'Z'
                data(j).rightPress=str2double(lineTaker(tline,'Z:'));
            case 'G'
                [data(j).choice,hackerAnimal(j,1)]=arrayTaker(fileName,'G:',data(j).totalTrial,j);
            case 'J'
                data(j).lever=arrayTaker(fileName,'J:',data(j).totalTrial,j);
            case 'L'
                data(j).reward=arrayTaker(fileName,'L:',data(j).totalTrial,j);
            case 'V'
                data(j).headEntryTime=arrayTaker(fileName,'V:',data(j).totalTrial,j);
            case 'W'
                data(j).pressLeverTime=arrayTaker(fileName,'W:',data(j).totalTrial,j);
                data(j).totalTime=join([string(fix(data(j).totalTimeInSec/60)) 'min' ...
                    rem(data(j).totalTimeInSec,60) 'sec']);
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
                if ~(data(j).totalReward==sum(data(j).reward))
                    warning(['Type1 Hacking! More pressing than total trials! Animal in the box' num2str(data(j).boxNum) ' hacked the system, this animal excluded in data analysis.'])
                    hackerAnimal1(j,1)=j;
                end
                hackerAnimal1(hackerAnimal1==0|isnan(hackerAnimal1))=[];
                j=j+1; %#ok<FXSET>
        end
    end
end
hackerAnimal(hackerAnimal==0|isnan(hackerAnimal))=[];

% (G: array) making animal choice data (0=omission,j=left,2=right)
%
output=data;
end
%%
% reversalAnalyzer

function [output,hackerAnimal3] = reversalAnalyzer(data,varargin)
% A role of this is basic analysis of the data. This will show whether
% the animal has a biased lever to press, behavioral performance above a
% chance level, number of rewarded lever switching (numbers of blocks in
% one session), and a probability before and after rewarded lever
% switching.
%
% Input
% data: a result struct of a function 'reversalReader'
p=inputParser;
p.addParameter('binSize',8,@(x) x>0 && rem(x,1)==0);
p.parse(varargin{:});

% preallocation of the struct array in the for-loop
flds={'boxNum','leftPressReward','rightPressReward','pctCorLeft','pctCorRight',...
    'biasedLever','oneSampleH','oneSampleP','switching','nrSwitching',...
    'rewardProbAroundSwitches'};
nrFields=length(flds);
nrData=length(data);
anal=cell(nrFields,nrData);
anal=cell2struct(anal,flds);
hackerAnimal3=nan(length(data),1);
for i=1:length(data)
    anal(i).boxNum=data(i).boxNum;
    % 1. Pct correct during right lever or left lever
    anal(i).leftPressReward=data(i).reward(data(i).lever==1); % 1=left
    anal(i).rightPressReward=data(i).reward(data(i).lever==2); % 2=right this is in the behavior program code
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
    anal(i).oneSampleP=1-binocdf(sum(data(i).reward),data(i).totalTrial,0.5);
    if anal(i).oneSampleP<0.05
        anal(i).oneSampleH=1;
    else
        anal(i).oneSampleH=0;
    end
    % 3. number of switching rewarded levers.
    switching=diff(data(i).lever);
    anal(i).switching=switching; % -1:right->left // 1:left->right
    switching(switching==0)=[];
    anal(i).nrSwitching=length(switching);
    % 4. lever pressing probability before and after switching
    switchingTrials=find(anal(i).switching);
    switchingInterval=diff(switchingTrials);
    switchingInterval=[switchingTrials(1,1);switchingInterval]; %#ok<AGROW>
    binSize=p.Results.binSize;
    switchingTrials(switchingTrials>data(i).totalTrial-binSize)=[]; % not enough amount of trials to test
    switchingInd=repmat(switchingTrials,[1 2*binSize+1])+repmat(-binSize:1:binSize,[length(switchingTrials) 1]);
    % sanitycheck, hacker animals can switch the rewarded lever within the
    % box of trials, these should be excluded.
    if any(switchingInterval<10)
        warning(['Type3 Hacking! The animal in the box' num2str(data(i).boxNum) ' hacked the system too much to be analyzed. So, this result is excluded.'])
        anal(i).rewardProbAroundSwitches=nan;
        anal(i).oneSampleH=nan;
        hackerAnimal3(i,1)=i;
    else
        anal(i).rewardProbAroundSwitches=(data(i).reward(switchingInd));
    end
    hackerAnimal3(hackerAnimal3==0|isnan(hackerAnimal3))=[];
end
output=anal;
end

%%
% logisticRegressor

function [model,betaValuesInMat,rSquared,p,h]=logisticRegressor(data,varargin)
% this function does a logistic regression modeling to predict whether the
% consequences in the previous trials affect the choice of the animal doing
% the reversal learning. I am going to look back by 5 trials (Parker et
% al., 2016). As Parker et al., 2016 did there will be 2 predictors; cases
% of being rewarded and non-rewarded repectively. And, the probability of
% choosing one side, here I will choose pressing right side lever, will be
% calculated with these two predictors. These predicors are covering most
% of the cases can happen during the behavior paradigm.
%
% prob(pressing right side lever) = beta0+beta1*rewarded+beta2*nonReward
% Reward predictor= +1 (pressing right side lever and rewarded)
%                   -1 (pressing left side lever and rewarded)
%                    0 (not rewarded)
% nonReward predictor= +1 (pressing right side lever and not rewarded)
%                      -1 (pressing left side lever and not rewarded)
%                       0 (rewarded)
%
% This being under the influence of the consequence of previous trials can
% be interpreted as an updating the information. And, in my opinion,
% updating information should be the result of active behavior. So, I
% eliminated omitted trials which are the results of passive behavior in
% this calculation.
%
% Input
% data: a struct array 'data' from the result of a function reversalReader.
p=inputParser;
p.addParameter('stepBack',5,@(x) x>0 && rem(x,1)==0);
p.parse(varargin{:});

% preallocation of the struct array in the for-loop
flds={'boxNum','betaS','statS','pValues','rSquared'};
nrFields=length(flds);
nrData=length(data);
model=cell(nrFields,nrData);
model=cell2struct(model,flds);
% a warning sourse can be a distraction to read the actual message itself.
warning('off','backtrace')
stepback=p.Results.stepBack; % as the Parker et al., 2016 did
% preallocation of other arrays
rSquared=zeros(length(data),1);
betaValuesInMat=zeros(length(data),2.*stepback+1);
for i=1:length(data)
    model(i).boxNum=data(i).boxNum;
    % let's get rid of omission which is a result of passive behavior.
    withoutOmissionChoice=data(i).choice;
    withoutOmissionChoice(withoutOmissionChoice==0)=[];
    withoutOmissionRewards=data(i).reward;
    withoutOmissionRewards(data(i).choice==0)=[];
    % let's make reward and non-reward predictor
    rewardPredictor=zeros(length(withoutOmissionChoice),1);
    nonRewardPredictor=zeros(length(withoutOmissionChoice),1);
    % +1, -1 and 0 applying rule to generate a precursor of a model matrix
    rewardPredictor(withoutOmissionChoice==2&withoutOmissionRewards==1)=1;
    rewardPredictor(withoutOmissionChoice==1&withoutOmissionRewards==1)=-1;
    nonRewardPredictor(withoutOmissionChoice==2&withoutOmissionRewards==0)=1;
    nonRewardPredictor(withoutOmissionChoice==1&withoutOmissionRewards==0)=-1;
    % let's add observed responses. since pressing Right=2, left=1, and
    % omission=0 and there is no more omission now, plus, the observed
    % responses should all or none in glmfit, I can just simply subtract 1
    % from the non-omission vector to get all or none vector.
    rightPressing=withoutOmissionChoice-1;
    % I want to look back the previous trials so the model matrix should be
    % multiplied by the number of trials that I want to look back. Let's do
    % it with for-loop.
    % so, preallocation.
    rewardP=zeros(length(rewardPredictor)-stepback,stepback);
    nonRewardP=zeros(length(nonRewardPredictor)-stepback,stepback);
    for j=1:stepback
        rewardP(:,j)=rewardPredictor(stepback-(stepback-j):end-(stepback-j+1));
        nonRewardP(:,j)=nonRewardPredictor(stepback-(stepback-j):end-(stepback-j+1));
        modelMatrix=cat(2,[rewardP nonRewardP]);
    end
    % glmfit needs a categorized vector.
    categorizedRightPress=logical(rightPressing(1+stepback:end,1));
    [betaValues,~,stats] = glmfit(modelMatrix,categorizedRightPress,'binomial','link','logit');
    % save beta values(=best fit pharms or regression coefficient) separatly
    % for plotting them easier in the next part.
    model(i).betaS=betaValues';
    model(i).statS=stats;
    % show the fitting value for each animal.
    totalSumSquares = sum(categorizedRightPress-mean(categorizedRightPress).^2);
    residual=model(i).statS.resid;
    % it will be also interesting to see which beta value is significantly
    % affecting the current choice. so, save it separately to draw it
    % later.
    model(i).pValues=model(i).statS.p;
    residualSumSquares=sum(residual.^2);
    model(i).rSquared = 1-residualSumSquares./totalSumSquares;
    rSquared(i,1)=model(i).rSquared;
    betaValuesInMat(i,:)=model(i).betaS;
    ordinal='th';
    switch i
        case 1
            ordinal='st';
        case 2
            ordinal='nd';
        case 3
            ordinal='rd';
    end
    disp(['R sqaured of '  num2str(i) ordinal ' animal is '  num2str(model(i).rSquared) '.'])
    
end
medianValue=median(rSquared);
disp(['median R squared value of this session is ' num2str(medianValue) '.'])
p=cat(2,model.pValues)';
h=p<0.05;
end

%%
% dataDrawer
%
function nrTrainningDays=dataDrawer(data,tagData,hackerAnimals,mutantAnimals,wildtyeAnimals,varargin)
p=inputParser;
p.addParameter('yourStartingDay',datetime('2018-11-12'),@isdatetime);
p.addParameter('ytickUnitRew',10,@(x) x>0 && rem(x,1)==0);
p.addParameter('ytickUnitOmt',5,@(x) x>0 && rem(x,1)==0);
p.addParameter('ytickUnitMin',1,@(x) x>0 && rem(x,1)==0);
p.addParameter('ytickUnitPress',20,@(x) x>0 && rem(x,1)==0);
p.addParameter('ytickUnitProb',0.05,@(x) x>0);
p.addParameter('ytickUnitSec',1,@(x) x>0 && rem(x,1)==0);
p.addParameter('hacker',1,@(x) x>0 && rem(x,1)==0);
p.parse(varargin{:});

fieldsOfData={'totalReward','omission','totalTimeInSec','leftPress','rightPress','pctCorrect','avgRtInSec'};

dataTable=struct2table(data);
boxNum=cat(1,data.boxNum);

muTable=dataTable(ismember(boxNum,mutantAnimals),[5:9 11 18]);
wyTable=dataTable(ismember(boxNum,wildtyeAnimals),[5:9 11 18]);
muData=table2array(muTable);
muData(:,3)=muData(:,3)./60;
wyData=table2array(wyTable);
wyData(:,3)=wyData(:,3)./60;
unified=[wyData;muData];
categ=[repmat(char('  WT  '),length(wyData(:,1)),1);...
       repmat(char('Mutant'),length(muData(:,1)),1)];

figure(1);clf;
set(gcf,'position',[50 50 1500 450])
for i=1:length(fieldsOfData)
    r=1;c=length(fieldsOfData);
    subplot(r,c,i);
    wildtypeOnes=ones(length(wyData(:,i)),1);
    mutantOnes=2.*ones(length(muData(:,i)),1);
    boxplot(unified(:,i),categ)
    hold on
    scatter(wildtypeOnes,wyData(:,i),'jitter', 'on', 'jitterAmount', 0.06);
    scatter(mutantOnes,muData(:,i),'jitter', 'on', 'jitterAmount', 0.06);
    minYValue=min([wyData(:,i);muData(:,i)]);
    maxYValue=max([wyData(:,i);muData(:,i)]);
    ytickUnit=[p.Results.ytickUnitRew;p.Results.ytickUnitOmt;p.Results.ytickUnitMin...
        ;p.Results.ytickUnitPress;p.Results.ytickUnitPress;p.Results.ytickUnitProb...
        ;p.Results.ytickUnitSec];
    closestMin=minYValue-rem(minYValue,ytickUnit(i,1));
    closestMax=maxYValue-rem(maxYValue,ytickUnit(i,1))+ytickUnit(i,1);
    switch i
        case 1
            ylabel 'Numbers of Rewards'
            set(gca,'ytick',closestMin:p.Results.ytickUnitRew:closestMax,'ylim',[closestMin closestMax])
        case 2
            ylabel 'Numbers of Omissions'
            set(gca,'ylim',[0 inf],'ytick',closestMin:p.Results.ytickUnitOmt:closestMax,'ylim',[closestMin closestMax])
        case 3
            ylabel 'Session Time (min)'
            set(gca,'ytick',closestMin:closestMax,'ylim',[closestMin closestMax])
        case 4
            ylabel 'Numbers of Pressing Left'            
        case 5
            ylabel 'Numbers of Pressing Right'            
        case 6
            ylabel 'Probability of Correnct Responses'            
        case 7
            ylabel 'Average Reaction Time (Sec)'            
    end
    if ismember(i,[4,5])
        set(gca,'ytick',closestMin:p.Results.ytickUnitPress:closestMax,'ylim',[closestMin closestMax])
    elseif ismember(i,[6,7])
        set(gca,'ylim',[closestMin closestMax])
    end
    set(gca,'XTick',[1 2],'XTickLabel',{'WT','Mutant'});
    if ttest2(wyData(:,i),muData(:,i))
        title '*'
        warning([char(fieldsOfData(1,i)) ' is significant.'])
    end
    box off
end
currentSession=datetime(tagData);
fullVerStarted=p.Results.yourStartingDay;
trainedDays=currentSession-fullVerStarted;
if datetime(currentSession)==datetime('2018-11-09')
    nrTrainningDays=1; % the actual firstday. if you wanna computed a numbers of days, you can use inputparser.
elseif datetime(currentSession)>datetime('2018-12-22')
    nrTrainningDays=datenum(trainedDays)-2.*fix(datenum(trainedDays)/7)-6;
else
    nrTrainningDays=datenum(trainedDays)-2.*fix(datenum(trainedDays)/7)+2;
end

annotation('textbox',[0.30 0.935 0.43 0.08],'VerticalAlignment','middle',...
    'String',['The Result of Day ' num2str(nrTrainningDays) ' full version recording ' tagData],...
    'LineStyle','none','HorizontalAlignment','center','FontSize',12,'FitBoxToText','off');
if ~isnan(hackerAnimals)
    annotation('textbox',[0.30 0.016 0.4 0.062],'VerticalAlignment','middle',...
        'String',['Hacker Animal(s) in box: ' num2str(boxNum(hackerAnimals)') ' is/are excluded.'],...
        'HorizontalAlignment','center','FontSize',10,'FitBoxToText','off','EdgeColor','none');
end
end
%%
% analDrawer
%

function analDrawer(anal,nrTrainningDays,tagData,hackerAnimals,mutantValidAnimals,wildtyeValidAnimals,varargin)
p=inputParser;
p.addParameter('probPlotSize',3,@(x) x>0 && rem(x,1)==0);
p.addParameter('ytickUnitProb',0.05,@(x) x>0);
p.addParameter('ytickUnitProbSwitch',0.2,@(x) x>0 && x<1);
p.addParameter('ytickUnitPress',20,@(x) x>0 && rem(x,1)==0);
p.parse(varargin{:});

for i=1:length(anal)
    switch anal(i).biasedLever
        case 'None'
            anal(i).biasedLever=0;
        case 'Left Biased'
            anal(i).biasedLever=-1; %#ok<*SAGROW>
        case 'Right Biased'
            anal(i).biasedLever=1;
    end
end
analTable=struct2table(anal);
boxNum=cat(1,anal.boxNum);
muAnalTable=analTable(ismember(boxNum,mutantValidAnimals),[4:7 10:11]);
wyAnalTable=analTable(ismember(boxNum,wildtyeValidAnimals),[4:7 10:11]);
muAnal=table2array(muAnalTable(:,1:5));
wyAnal=table2array(wyAnalTable(:,1:5));
muProbRewAroundSwitches=cell2mat(table2array(muAnalTable(:,6)));
wyProbRewAroundSwitches=cell2mat(table2array(wyAnalTable(:,6)));
categ=[repmat(char('  WT  '),length(wyAnal(:,1)),1);...
    repmat(char('Mutant'),length(muAnal(:,1)),1)];
wildtypeOnes=ones(length(wyAnal(:,1)),1);
mutantOnes=2.*ones(length(muAnal(:,1)),1);
ytickUnit=p.Results.ytickUnitProb;

figure(2);clf;
set(gcf,'position',[50 50 1500 450])
for i=1:length(muAnal(1,:))
    r=1;c=length(muAnal(1,:))+p.Results.probPlotSize;
    subplot(r,c,i);
    if ismember(i,[1 2 5])
        unifiedAnal=[wyAnal(:,i);muAnal(:,i)];
        boxplot(unifiedAnal,categ)
        hold on
        scatter(wildtypeOnes,wyAnal(:,i),'jitter', 'on', 'jitterAmount', 0.06);
        scatter(mutantOnes,muAnal(:,i),'jitter', 'on', 'jitterAmount', 0.06);
        minYValue=min([wyAnal(:,i);muAnal(:,i)]);
        maxYValue=max([wyAnal(:,i);muAnal(:,i)]);
        closestMin=minYValue-rem(minYValue,ytickUnit);
        closestMax=maxYValue-rem(maxYValue,ytickUnit)+ytickUnit;
        set(gca,'ylim',[closestMin closestMax])
        switch i
            case 1
                ylabel 'Left-biased Probability of Correnct Responses'
            case 2
                ylabel 'Right-biased Probability of Correnct Responses'
            case 5
                ylabel 'Number of Switching in One Session'
        end
        if ismember(i,[1 2])
            set(gca,'ytick',closestMin:p.Results.ytickUnitProb:closestMax)
        else
            set(gca,'ytick',closestMin:p.Results.ytickUnitProbSwitch:closestMax)
        end
        set(gca,'XTick',[1 2],'XTickLabel',{'WT','Mutant'});
        
    else
        unified=([mean(wyAnal(:,i)) mean(muAnal(:,i))]);
        wyStdError=std(wyAnal(:,i)/sqrt(sum(wyAnal(:,i))));
        muStdError=std(muAnal(:,i)/sqrt(sum(muAnal(:,i))));
        bar([1 2],unified)
        hold on
        errorbar(1,mean(wyAnal(:,i)),wyStdError,'k')
        hold on
        errorbar(2,mean(muAnal(:,i)),muStdError,'k')
        set(gca,'XTick',[1 2],'XTickLabel',{'WT','Mutant'});
        switch i
            case 3
                ylabel 'Biased to One Side of a Lever Level'
                set(gca,'ylim',[-1 1],'ytick',[-1 0 1],'YTickLabel',{'Right','None','Left'})
            case 4
                ylabel 'Probability of Rewards Above a Chance Level'
                set(gca,'ylim',[closestMin closestMax])
        end
        if all(diff([wyAnal(:,i);muAnal(:,i)])~=0)
            if ttest2(wyAnal(:,i),muAnal(:,i))
                title '*'
                warning([char(fieldsOfData(1,i)) ' is significant.'])
            end
        end
    end
    box off
end
stepback=(length(wyProbRewAroundSwitches(1,:))-1)/2;
xRange=-stepback:1:stepback;
xAxisTicks=num2cell(xRange');

subplot(r,c,i+1:length(muAnal(1,:))+p.Results.probPlotSize);
meanWy=mean(wyProbRewAroundSwitches);
meanMu=mean(muProbRewAroundSwitches);
wyProbStdError=nan(1,length(wyProbRewAroundSwitches(1,:)));
muProbStdError=nan(1,length(muProbRewAroundSwitches(1,:)));
for i=1:length(wyProbRewAroundSwitches(1,:))
    wyProbStdError(1,i)=std(wyProbRewAroundSwitches(:,i)/sqrt(sum(wyProbRewAroundSwitches(:,i))));
    muProbStdError(1,i)=std(muProbRewAroundSwitches(:,i)/sqrt(sum(muProbRewAroundSwitches(:,i))));
end
errorbar(1:length(meanWy),meanWy,wyProbStdError,'b')
hold on
errorbar(1:length(meanMu),meanMu,muProbStdError,'r')
hold on
stem(stepback+1,1,'LineStyle','--','marker','none','Color','k')
ylabel('Probability of Correct Responses at The Reversal')
xlabel('The Rewarded Lever Switched at 0')
set(gca,'ylim',[0 1],'ytick',0:p.Results.ytickUnitProbSwitch:1,...
        'xtick',1:length(wyProbRewAroundSwitches(1,:)),'xticklabel',xAxisTicks)
legend('WT','Mutant','Lever Switch','location','southwest')
legend('boxoff')
box off

annotation('textbox',[0.30 0.935 0.43 0.08],'VerticalAlignment','middle',...
    'String',['The Analysis Result of Day ' num2str(nrTrainningDays) ' full version recording ' tagData],...
    'LineStyle','none','HorizontalAlignment','center','FontSize',12,'FitBoxToText','off');
if ~isnan(hackerAnimals)
    annotation('textbox',[0.30 0.016 0.4 0.062],'VerticalAlignment','middle',...
        'String',['Hacker Animal(s) in box: ' num2str(boxNum(hackerAnimals)') ' is/are excluded.'],...
        'HorizontalAlignment','center','FontSize',10,'FitBoxToText','off','EdgeColor','none');
end
end
