clear all
hsv_mean1_lst=[];
hsv_mean2_lst=[];
hsv_mean3_lst=[];
var1lst=[];var2lst=[];var3lst=[];
%逐个计算图片的HSV平均值和方差，并存储
usetag=zeros(320);
for i = 1:320
    I=imread([num2str(i) '.png']);
    I_small=imresize(I,0.2);
    I_hsv=rgb2hsv(I_small);
    szI=size(I_hsv);
    hsv_mean=sum(sum(I_hsv))/(szI(1)*szI(2));
    hsv_mean1_lst(i)=hsv_mean(:,:,1);
    hsv_mean2_lst(i)=hsv_mean(:,:,2);
    hsv_mean3_lst(i)=hsv_mean(:,:,3);
    a=var(I_hsv,0,[1,2]);
    var1lst(i)=a(:,:,1);var2lst(i)=a(:,:,2);var3lst(i)=a(:,:,3);
end
%方差较大即颜色变化较大的图片不用
%将图片较大的方差的平均值设置为很大，这样误差函数计算的误差会很大
hsv_mean1_lst(var1lst>0.05)=-99999;
hsv_mean2_lst(var1lst>0.05)=-99999;
hsv_mean2_lst(var1lst>0.05)=-99999;
%目标图片
TG=imread("TG2.png");
TG=TG(1:375,:,:);
%降采样，减少不必要的细节
TG=(imresize(imresize(TG,0.05),20));
%扩大图片，用于之后的匹配
TG_big=imresize(TG,5);
TG_hsv=rgb2hsv(TG_big);
err_all=zeros(25,25);
%逐个匹配
for i = 0:24
    for j = 0:24
        %计算窗内的HSV平均值
        win=TG_big(1+i*75:75+i*75,1+j*120:120+j*120,:);
        szwin=size(win);
        winm=rgb2hsv(win);
        h=sum(sum(winm(:,:,1)))/(szwin(1)*szwin(2));s=sum(sum(winm(:,:,2)))/(szwin(1)*szwin(2));v=sum(sum(winm(:,:,3)))/(szwin(1)*szwin(2));
        %误差函数为相对偏差的比例的绝对值的求和，选取误差最小的一张素材与之匹配，对HSV赋予了不同的权重，可以自行修改。
        errlst=1*abs((hsv_mean1_lst-h))/h+5*abs((hsv_mean2_lst-s))/s+abs((hsv_mean3_lst-v))/v;
        idx_chose=find(abs(errlst)==min(abs(errlst)));
        err_all(i+1,j+1)=min(abs(errlst));
        %如果有多张，就选第一张(我偷懒了)
        
        idx=idx_chose(1);
      %在该像素位置记录选区的素材编号
            idx_mat(1+i,1+j)=idx;
            %记录这张图片备用过了
            usetag(idx)=1;
        
    end
end
%生成最终图片
    I_final=uint8(zeros(25*75,25*120,3));
    
    figure()
set(gcf,'unit','normalized','position',[0,0,1,1]);

    %给图片赋值
    for i = 0:24
        for j = 0:24
            figname=[num2str(idx_mat(i+1,j+1)) '.png'];
            fig=imread(figname);fig=imresize(fig,0.2);
            I_final(1+i*75:75+i*75,1+j*120:120+j*120,:)=fig;


        end
    end
            imshow(I_final);
%无损保存
imwrite(I_final,'eye.png');
