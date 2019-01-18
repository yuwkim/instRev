
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
    boxNum=cat(1,data.boxNum);
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
        
        feTable=dataTable(ismember(boxNum,femaleValidAnimals),[5:9 11 18]);
        maTable=dataTable(ismember(boxNum,maleValidAnimals),[5:9 11 18]);
        feData=table2array(feTable);
        feData(:,3)=feData(:,3)./60;
        maData=table2array(maTable);
        maData(:,3)=maData(:,3)./60;
        
        
        
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
    totTable=dataTable(ismember(boxNum,totAnimals),[5:9 11 18]);
    totData=table2array(totTable);
    totData(:,3)=totData(:,3)./60;
    groupData(i).nrTrainningDays=nrTrainningDays;
    groupData(i).totRew=totData(:,1);
    groupData(i).omission=totData(:,2);
    groupData(i).sessionTime=totData(:,3);
    groupData(i).leftPress=totData(:,4);
    groupData(i).rightPress=totData(:,5);
    groupData(i).pctCorrect=totData(:,6);
    groupData(i).avgRTinSec=totData(:,7);
    if isnan(finishedOrderHackerAnimal)
        groupData(i).hackers=[];
    else
        groupData(i).hackers=finishedOrderHackerAnimal;
    end
end
trainingDays=cat(1,groupData.nrTrainningDays);


averageGroupData=nan(length(groupData),7);
averageFemaleData=nan(length(groupData),7);
averageMaleData=nan(length(groupData),7);

steGroupData=nan(length(groupData),7);
steFemaleData=nan(length(groupData),7);
steMaleData=nan(length(groupData),7);

for i=1:length(groupData)
    averageGroupData(i,1)=mean(groupData(i).totRew);
    averageFemaleData(i,1)=mean(feGroup(i).totRew);
    averageMaleData(i,1)=mean(maGroup(i).totRew);
    steGroupData(i,1)=std(groupData(i).totRew)/sqrt(sum(numel(groupData(i).totRew)));
    steFemaleData(i,1)=std(feGroup(i).totRew)/sqrt(sum(numel(feGroup(i).totRew)));
    steMaleData(i,1)=std(maGroup(i).totRew)/sqrt(sum(numel(maGroup(i).totRew)));
    
    averageGroupData(i,2)=mean(groupData(i).omission);
    averageFemaleData(i,2)=mean(feGroup(i).omission);
    averageMaleData(i,2)=mean(maGroup(i).omission);
    steGroupData(i,2)=std(groupData(i).omission)/sqrt(sum(numel(groupData(i).omission)));
    steFemaleData(i,2)=std(feGroup(i).omission)/sqrt(sum(numel(feGroup(i).omission)));
    steMaleData(i,2)=std(maGroup(i).omission)/sqrt(sum(numel(maGroup(i).omission)));
    
    averageGroupData(i,3)=mean(groupData(i).sessionTime);
    averageFemaleData(i,3)=mean(feGroup(i).sessionTime);
    averageMaleData(i,3)=mean(maGroup(i).sessionTime);
    steGroupData(i,3)=std(groupData(i).sessionTime)/sqrt(sum(numel(groupData(i).sessionTime)));
    steFemaleData(i,3)=std(feGroup(i).sessionTime)/sqrt(sum(numel(feGroup(i).sessionTime)));
    steMaleData(i,3)=std(maGroup(i).sessionTime)/sqrt(sum(numel(maGroup(i).sessionTime)));
    
    averageGroupData(i,4)=mean(groupData(i).leftPress);
    averageFemaleData(i,4)=mean(feGroup(i).leftPress);
    averageMaleData(i,4)=mean(maGroup(i).leftPress);
    steGroupData(i,4)=std(groupData(i).leftPress)/sqrt(sum(numel(groupData(i).leftPress)));
    steFemaleData(i,4)=std(feGroup(i).leftPress)/sqrt(sum(numel(feGroup(i).leftPress)));
    steMaleData(i,4)=std(maGroup(i).leftPress)/sqrt(sum(numel(maGroup(i).leftPress)));
    
    
    averageGroupData(i,5)=mean(groupData(i).rightPress);
    averageFemaleData(i,5)=mean(feGroup(i).rightPress);
    averageMaleData(i,5)=mean(maGroup(i).rightPress);
    steGroupData(i,5)=std(groupData(i).rightPress)/sqrt(sum(numel(groupData(i).rightPress)));
    steFemaleData(i,5)=std(feGroup(i).rightPress)/sqrt(sum(numel(feGroup(i).rightPress)));
    steMaleData(i,5)=std(maGroup(i).rightPress)/sqrt(sum(numel(maGroup(i).rightPress)));
    
    
    averageGroupData(i,6)=mean(groupData(i).pctCorrect);
    averageFemaleData(i,6)=mean(feGroup(i).pctCorrect);
    averageMaleData(i,6)=mean(maGroup(i).pctCorrect);
    steGroupData(i,6)=std(groupData(i).pctCorrect)/sqrt(sum(numel(groupData(i).pctCorrect)));
    steFemaleData(i,6)=std(feGroup(i).pctCorrect)/sqrt(sum(numel(feGroup(i).pctCorrect)));
    steMaleData(i,6)=std(maGroup(i).pctCorrect)/sqrt(sum(numel(maGroup(i).pctCorrect)));
    
    
    averageGroupData(i,7)=mean(groupData(i).avgRTinSec);
    averageFemaleData(i,7)=mean(feGroup(i).avgRTinSec);
    averageMaleData(i,7)=mean(maGroup(i).avgRTinSec);
    steGroupData(i,7)=std(groupData(i).avgRTinSec)/sqrt(sum(numel(groupData(i).avgRTinSec)));
    steFemaleData(i,7)=std(feGroup(i).avgRTinSec)/sqrt(sum(numel(feGroup(i).avgRTinSec)));
    steMaleData(i,7)=std(maGroup(i).avgRTinSec)/sqrt(sum(numel(maGroup(i).avgRTinSec)));
    
end
% figure(1);clf
% set(gcf,'position',[50 50 1000 500])
for i=1:length(averageGroupData(1,:))
    %     r=length(averageGroupData(1,:))+1;c=1; %+1 hacker animal coloumn
    %     subplot(r,c,i);
    figure(i);clf
    set(gcf,'position',[50 50 1000 500])
    errorbar(trainingDays,averageGroupData(:,i),steGroupData(:,i))
    hold on
    errorbar(trainingDays,averageFemaleData(:,i),steFemaleData(:,i))
    hold on
    errorbar(trainingDays,averageMaleData(:,i),steMaleData(:,i))
    set(gca,'xlim', [trainingDays(1,1)-1 trainingDays(end,1)+1])
    legend('Overall','Female','Male','location','northeast')
%    legend('Female','Male','location','northeast')
    switch i
        case 1
            ylabel 'Numbers of Rewards'
            legend('Overall','Female','Male','location','southeast')
%             legend('Female','Male','location','southeast')
        case 2
            ylabel 'Numbers of Omissions'
        case 3
            ylabel 'Session Time (min)'
        case 4
            ylabel 'Numbers of Pressing Left'
        case 5
            ylabel 'Numbers of Pressing Right'
        case 6
            ylabel 'Probability of Correnct Responses'
            legend('Overall','Female','Male','location','southeast')
%             legend('Female','Male','location','southeast')
        case 7
            ylabel 'Average Reaction Time (Sec)'
    end
    xlabel 'Training Days'
    legend('boxoff')
    box off
end
