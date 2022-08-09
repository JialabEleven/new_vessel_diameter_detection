clear all;
clc;
cur_p1 = mfilename('fullpath');%获得现在所打开的文件的路径
i=strfind(cur_p1,'\');%匹配 \
cur_p=cur_p1(1:i(end-1));   
buildingDir = fullfile([cur_p '\diameter_detection\line3.bmp']);
imgData1 = imread(buildingDir);

a=im2gray(imgData1);
%a=imgData1(1:8000,175:240);%MCAO48minR2
%a=imgData1(:,25:195);%MCAO56minR3 %select part of picture for test show the bright value
figure(), imshow(a);



%axis off;
[rows,columns]=size(a)
k=0
p=0;
kk=0;
pp=0;
number_positive=0;
number_negative=0;

for i=1:rows
b=a(i,:);
     %figure(),plot(b);
c=smoothdata(b,'gaussian',5); %smooth data
      %figure(),plot(c);
%        figure,plot(c); 
%       figure()
%       plot(c,'r','Linewidth',1);%select part of picture for test show the bright value
%       xlabel('horizonal pixel');
%       ylabel('bright value');



d=double(c);
[e,f]=findpeaks(d);
n = find(e >60);  %select the peak value of left and right


for t=1:length(n)%
    g(t)=e(n(t));
    h(t)=f(n(t));
end
left=min(h);
right=max(h);


if right<0.7*columns%
    dg1=floor(0.7*columns);
    ff1=find(d(dg1:columns)==max(d(dg1:columns)));
    right=max(ff1)+(dg1-1);
    e=max(d(dg1:columns));
end

if left>0.3*columns%
    dg2=floor(0.3*columns);
    ff2=find(d(1:dg2)==max(d(1:dg2)));
    left=min(ff2);
    e=max(d(1:dg2));
end


if length(n)<2
    %if isempty(e)==1 | e<30 %judge whether e is empty
      ff3=find(d==max(d));
      left=min(ff3);
      right=max(ff3);
      e=max(d);
end
for m=1:columns
    boundary1(i,m)=c(m+right);
    if boundary1(i,m)==c(right)
        k=k+1;
    end
    if m>1
        if boundary1(i,m)==boundary1(i,m-1) 
            boundary1(i,m)=boundary1(i,m-1)-1;
            d(right+m)=boundary1(i,m);
            p=p+1;
        end
    end
    if m>2  
        if boundary1(i,m)>boundary1(i,m-1)
            boundary1(i,m)=boundary1(i,m-1)-1;
            d(right+m)=boundary1(i,m);
            p=p+1;
        end
    end
    if boundary1(i,m)<20 %base line of right
        markright=m+right;
        break;
    end
end

for q=1:columns
    boundary2(i,q)=c(left-q);
    if boundary2(i,q)==c(left)
        left=left-1; 
        kk=kk+1;
    end
    if q>1
        if boundary2(i,q)==boundary2(i,q-1) 
            boundary2(i,q)=boundary2(i,q-1)-1;
            d(left-q)=boundary2(i,q);
            pp=pp+1;
        end
    end
    if q>2 
        if boundary2(i,q)>boundary2(i,q-1)
            boundary2(i,q)=boundary2(i,q-1)-1;
            d(left-q)=boundary2(i,q);
            pp=pp+1;
        end
    end
    if boundary2(i,q)<20  %base line of left
        markleft=left-q;
        break;
    end
end

x=d((right+k):markright);
y=((right+k):markright);
y1(i)=interp1(x,y,(d(right)+d(markright))/2,'pchip');
y2(i)=interp1(x,y,(d(right)+d(markright))/2,'spline');


xx=d((markleft-kk):left);
yy=((markleft-kk):left);
y3(i)=interp1(xx,yy,(d(left)+d(markleft))/2,'pchip');
y4(i)=interp1(xx,yy,(d(left)+d(markleft))/2,'spline');

diameter_cubic(i)=0.994*((y1(i))-y3(i));%select pixel per mm
%tt=0;
%mm=0;
if i>=2
    if diameter_cubic(i)> (1+0.08)*diameter_cubic(i-1)
        diameter_cubic(i)=(1+0.01)*diameter_cubic(i-1);
        number_positive=number_positive+1;
    else
        if diameter_cubic(i)<(1-0.08)*diameter_cubic(i-1)
            diameter_cubic(i)=(1-0.01)*diameter_cubic(i-1);
            number_negative=number_negative+1;
        end
    end
end
%diameter_spline(i)=0.509117*((y2(i))-y4(i)); %select pixel per mm
h(:)=[];
g(:)=[];
k=0;
end


j=length(diameter_cubic);
figure(), plot(1:j,diameter_cubic(1,:));

[d_pks1,d_locs1]=findpeaks(diameter_cubic);
figure(), plot(diameter_cubic);   
hold on
plot(d_locs1,d_pks1,'.','color','R');                %绘制最大值点
diameter=diameter_cubic';
for ii=1:size(d_locs1,2)
    d_time(ii)=1.08*d_locs1(ii);
    text(d_locs1(ii),d_pks1(ii),['',num2str(ii),''],'FontSize',10,'Color','r'); 
end


