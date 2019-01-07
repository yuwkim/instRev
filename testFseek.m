clear
fid = fopen('2018-12-06_14h30m_Subject 20th full RL.txt');
tline1 = fgetl(fid);
header='Box:';
c=nan(12,1);
for i=1:12
    while ~contains(tline1,header)
        tline1=fgetl(fid);
        c(i,1)=ftell(fid);
    end
    tline1=fgetl(fid);
    d=ftell(fid);
end
interval=diff(c);
frewind(fid)
tline2=fgetl(fid);
txtFileLineChangingConstant=2; 
while ~contains(tline2,header)
        tline2=fgetl(fid);
end
tline=nan(length(interval),1);
tline=string(tline);
for i=1:11
fseek(fid,min(interval)-(txtFileLineChangingConstant+length(tline2)),'cof');
tline(i,1)=fgetl(fid);
end
