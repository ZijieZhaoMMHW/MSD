function m=mean_states(MSD,year_range,varargin)
%mean_states - Calculating mean states for MSD metrics.
%  Syntax
%
%  m=mean_states(MSD,year_range)
%  m=mean_states(MSD,year_range,'Metric')
%  Description
%
%  m=mean_states(MSD,year_range) returns the frequency (/year) of MSD
%  events in each grid.
%
%  m=mean_states(MSD,year_range,'Metric') returns the mean state of a
%  particular MSD metric.
%
%  Input Arguments
%
%   MSD - Output from function detect_daily.
%
%   year_range - A numeric vector containing two values indicating time
%   range of MSD detection. E.G. [1979 2016].
%
%   'Metric' - Default is 'Frequency'.
%           - 'Frequency' - calculating frequency (/year) of MSD events.
%           - 'Onset' - calculating mean states of onset date (day of
%           year).
%           - 'End' - calculating mean states of end date (day of year).
%           - 'Peak' - calculating mean states of peak date (day of year).
%           - 'Duration' - calculating mean states of duration (days).
%           - 'P1' - calculating mean states of P1 (mm/day).
%           - 'P2' - calculating mean states of P2 (mm/day).
%           - 'Pmax' - calculating mean states of Pmax (mm/day).
%           - 'Pmin' - calculating mean states of Pmin (mm/day).
%           - 'imsd' - calculating mean states of imsd.
%
%  Output Arguments
%   
%   m - A numeric matrix containing the mean state of a particular MSD
%   metric in size of (m-by-n).

paramNames = {'Metric'};
defaults   = {'Frequency'};

[vMetric]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

MetricNames = {'Frequency','Onset','End','Peak','Duration','P1','P2','Pmax','Pmin','imsd'};
vMetric = internal.stats.getParamVal(vMetric,MetricNames,...
    '''Metric''');

MSD=MSD{:,:};
loc=unique(MSD(:,2:3),'rows');
m=NaN(size(loc,1),3);
m(:,1:2)=loc;

switch vMetric
    case 'Frequency'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=size(MSD_here,1)./length(year_range(2)-year_range(1)+1);
        end
    case 'Onset'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,5));
        end
    case 'End'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,7));
        end
    case 'Peak'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,9));
        end
    case 'Duration'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,7)-MSD_here(:,5)+1);
        end
    case 'P1'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,12));
        end
    case 'P2'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,13));
        end
    case 'Pmax'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,10));
        end
    case 'Pmin'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,11));
        end
    case 'imsd'
        for i=1:size(loc,1)
            MSD_here=MSD(MSD(:,2)==loc(i,1) & MSD(:,3)==loc(i,2),:);
            m(i,3)=nanmean(MSD_here(:,14));
        end
end
    
