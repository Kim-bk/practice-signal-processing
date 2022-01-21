clear;

    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\01MDA\a.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\01MDA\e.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\01MDA\i.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\01MDA\o.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\01MDA\u.wav');
    %
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\02FVA\a.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\02FVA\e.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\02FVA\i.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\02FVA\o.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\02FVA\u.wav');
    %
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\03MAB\a.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\03MAB\e.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\03MAB\i.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\03MAB\o.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\03MAB\u.wav');
    %
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\06FTB\a.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\06FTB\e.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\06FTB\i.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\06FTB\o.wav');
    STECel= Bai1('E:\BaITapXLTHS\NguyenAmHuanLuyen-16k\06FTB\u.wav');

function STE_Line=Bai1(fileName)
    [Sig, Fs] = audioread(fileName);
    Sig = Sig./abs(max(Sig));
    samples = length(Sig);
    frameDuration = 0.03;
    frameLength = round(Fs * frameDuration);
    frameTotalNoFrameShift = floor(samples / frameLength); 
    totalFrame = 2*frameTotalNoFrameShift - 1;
    %Sig = medianFilter(Sig,7);
    [STECal,STE_Line] = STE(Sig, totalFrame, frameLength);
    

    [STECal_Line] = Chuan_Hoa(STE_Line);
    [STECal1] = Chuan_Hoa(STECal);

    

    %threshold =0.005;
    threshold =ThresholdSolve(STECal1);

    VowelArray = XulyTiengNoi(totalFrame , STECal1 , threshold);

    SilenceArray = XacDinhKhoangLang(VowelArray, totalFrame);

    figure('name',fileName);

    subplot(3,1,1);    
    p1=plot(Sig);
    %plot(STECal,'Color','red');
    title('Phan tich vowel va� silence (STE)');
    hold on;
    plot(STECal_Line,'Color','r');
    hold on; grid on;
    for j = 1: size(SilenceArray)
        start =  SilenceArray(j, 1);
        endd = SilenceArray(j, 2);
        
        start1 = ((start - 1) / 2) * frameLength;
        endd1 = (endd * frameLength) - (frameLength * (endd - 1) / 2);
        
        plot ([start1 start1],[-1 1],'b');
        plot ([endd1 endd1],[-1 1],'b');
    end

    hold off;

    xlabel('Thoi gian (s)'); 
    ylabel('Bien do');
end


function [STECal,STE_Line] = STE(x, frameTotal, frameLength)
    STECal = zeros(1, frameTotal); % tinh nang luong cua moi frame
    for i = 1 : frameTotal
        start = (frameLength * (i - 1) / 2) + 1;
        endd =  start + frameLength - 1 ;
        frameI = x(start : endd);
        STECal(i) = sum(frameI.^2);
        STE_Line(start : endd) = STECal(i);
    end
end


function [STECal] = Chuan_Hoa(STECal)
    minEnergy = min(STECal); 
    maxEnergy = max(STECal);
    for i = 1 : length(STECal) 
        STECal(i) = (STECal(i) - minEnergy) / (maxEnergy - minEnergy);
    end
end


function [threshold] = ThresholdSolve(STECal)
    [histo, x_arr] = hist(STECal, round(length(STECal)/0.5));
    M1 = 0;
    M2 = 0;
    M1Index = 0; 
    M2Index = 0;
    for i = 2 : length(histo) - 1 
        previous = i - 1;
        next = i + 1;
        while(histo(i) == histo(next))
            next = next + 1;
        end
        if(histo(i) > histo(previous) && histo(i) > histo(next)) 
            if(M1Index == 0)
                M1 = histo(i);
                M1Index = i;
            else
                M2 = histo(i);
                M2Index = i;
                break;
            end
        end
        i = next;
    end
    M1 = x_arr(M1Index);
    M2 = x_arr(M2Index);
    W =1000;
    threshold = (W * M1 + M2) / (W + 1);
end


function [VowelArray] =  XulyTiengNoi(totalFrame , STECal , threshold)
    VowelArray = zeros(1, totalFrame); 
    for i = 1 : totalFrame 
        if(STECal(i) >threshold ) 
            VowelArray(i) = 1; 
        else
            VowelArray(i) = 0; 
        end
    end
end


function SilenceArray = XacDinhKhoangLang(VowelArray, frameTotal) %xac dinh khoang de in ra 
    SilenceArray = [];
    indexSilence = 1;
    skipp = 0;
    for i = 1 : frameTotal
        if(skipp > 0)
            skipp = skipp - 1;
            continue;
        end
       
        if(VowelArray(i) == 0)
            count = i;
            while(count < frameTotal && VowelArray(count + 1) == 0)
                count = count + 1;
            end
            if(count - i >= 14)
                SilenceArray(indexSilence, 1) = i;
                SilenceArray(indexSilence, 2) = count;
                indexSilence = indexSilence + 1;
                skipp = count - i;
            end
        end
    end
end


