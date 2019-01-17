
clear
% warning('off','backtrace')
[file,path] = uigetfile('*.mat','Select One or More Files','MultiSelect', 'on');
if isequal(file,0)
    disp('Group Data Analysis Aborted.');
    return
end

subjectOfAnal=string(file);
format compact
for i=1:length(subjectOfAnal)
    indicator=strsplit(subjectOfAnal(1,i));
    disp(['Chosen file : ' indicator(1,2:end)])
end
load(fullfile(path,file{1,1}))
sexDiff=1;

for i=1:length(subjectOfAnal)
    load(fullfile(path,char(subjectOfAnal(1,i))))
    dataTable=struct2table(data);
    totAnimals=table2array(dataTable(:,2));
    if ~isnan(finishedOrderHackerAnimal)
        totAnimals(finishedOrderHackerAnimal)=[];
    end
    if sexDiff==1
        if ismember(tagData,{'2018-11-23','2018-11-26','2018-11-27'})
            femaleAnimals=[3;4;5;6];
        else
            femaleAnimals=[5;6;11;12];
        end
        femaleValidAnimals=intersect(femaleAnimals,totAnimals);
        maleValidAnimals=totAnimals(~ismember(totAnimals,femaleAnimals));
        boxNum=cat(1,data.boxNum);
        dataTable=struct2table(data);
        feTable=dataTable(ismember(boxNum,femaleValidAnimals),[5:9 11 18]);
        maTable=dataTable(ismember(boxNum,maleValidAnimals),[5:9 11 18]);
        feData=table2array(feTable);
        feData(:,3)=feData(:,3)./60;
        maData=table2array(maTable);
        maData(:,3)=maData(:,3)./60;
        feGroup(i).nrTrainningDays=nrTrainningDays;
        maGroup(i).nrTrainningDays=nrTrainningDays;
        
        feGroup(i).totRew=feData(:,1);
        feGroup(i).omission=feData(:,2);
        feGroup(i).sessionTime=feData(:,3);
        feGroup(i).leftPress=feData(:,4);
        feGroup(i).rightPress=feData(:,5);
        feGroup(i).pctCorrect=feData(:,6);
        feGroup(i).avgRTinSec=feData(:,7);
        
        maGroup(i).totRew=maData(:,1);
        maGroup(i).omission=maData(:,2);
        maGroup(i).sessionTime=maData(:,3);
        maGroup(i).leftPress=maData(:,4);
        maGroup(i).rightPress=maData(:,5);
        maGroup(i).pctCorrect=maData(:,6);
        maGroup(i).avgRTinSec=maData(:,7);
        
    end
    
    groupData(i).nrTrainningDays=nrTrainningDays;
    
    omission=cat(1,data.omission);
    groupData(i).omission=omission;
    
    totalReward=cat(1,data.totalReward);
    groupData(i).totalReward=totalReward;
    
    totalTimeInSec=cat(1,data.totalTimeInSec);
    groupData(i).totalTimeInSec=totalTimeInSec;
    
    pctCorrect=cat(1,data.pctCorrect);
    groupData(i).pctCorrect=pctCorrect;
    
    avgRtInSec=cat(1,data.avgRtInSec);
    groupData(i).avgRtInSec=avgRtInSec;
    
end
trainingDays=cat(2,groupData.nrTrainningDays);

figure(1);clf
set(gcf,'position',[50 50 700 450])
