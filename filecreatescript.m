% Wave
figure
plot(cornetFiles.sig(3000:7000));
set(gca,'XLim',[0 4000]);
set(gca,'XTickLabel',xOL);
xlabel('Time(seconds)');
title('Cornet Waveform');

% BMM
figure
for z2 = 1:7
    subplot(7,1,z2)
    plot(cornetFiles.bmpos(z2+26,3000:7000))
    title(['Bmm Pos Channel ' int2str(z2+26)]);
    set(gca,'XLim',[0 4000]);
    set(gca,'YLim',[0 0.015]);
    
    if(z2 <7)
        set(gca,'xticklabel',[])
    else
       set(gca,'XTickLabel',xOL);
       xlabel('Time(seconds)');
    end
       
end

%Spikes
figure
for z2 = 1:7
    subplot(7,1,z2)
    plot(cornetFiles.chanTrain(z2+26,3000:7000))
    title(['Onset Spikes Channel ' int2str(z2+26)]);
    set(gca,'XLim',[0 4000]);
    set(gca,'YLim',[0 10]);
    
    if(z2 <7)
        set(gca,'xticklabel',[])
    else
       set(gca,'XTickLabel',xOL);
       xlabel('Time(seconds)');
    end
       
end
