clear
fid = fopen('2018-12-06_14h30m_Subject 20th full RL.txt');
tline1 = fgetl(fid);
header='D:';
c=nan(12,1);
for i=1:12
    while ~contains(tline1,header)
        tline1=fgetl(fid);
        c(i,1)=ftell(fid);
                %c=ftell(fid);
    end
    tline1=fgetl(fid);
    d=ftell(fid);
end
ftell(fid)
a=diff(c);
frewind(fid)
tline2=fgetl(fid);
while ~contains(tline2,header)
        tline2=fgetl(fid);
end
fseek(fid,a(1,1)-(2+length(tline2)),'cof');
tline3=fgetl(fid);
fseek(fid,a(1,1)-(2+length(tline2)),'cof');
tline4=fgetl(fid);
fseek(fid,a(1,1)-(2+length(tline2)),'cof');
tline5=fgetl(fid);
