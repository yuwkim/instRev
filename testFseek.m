clear   
fid = fopen('2018-12-21_15h38m_Subject 31st full LL.txt');
tline1 = fgetl(fid);
header='W:';
interval=nan(12,1);
for i=1:12
    while ~contains(tline1,header)
        interval(i,1)=ftell(fid);
        tline1=fgetl(fid);
    end
    tline1=fgetl(fid);
end

frewind(fid)
tline=nan(length(interval),1);
tline=string(tline);
tline(1,1)=fgetl(fid);
for i=1:12
fseek(fid,interval(i,1),'bof');
tline(i,1)=fgetl(fid);
end
