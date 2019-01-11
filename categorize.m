function start_end_phase_4=categorize(MSD,varargin)
%categorize - Categorizing MSD events
%  Syntax
%
%  start_end_phase_4=categorize(MSD)
%
%  Description
%
%  start_end_phase_4=categorize(MSD) returns a 3D matrix in size of
%  m-by-4-by-2. m indicates the number of MSD events, 4 indicates four
%  period of each MSD event, and 2 indicates start and end of each period.
%  MSD
%
%  Input Arguments
%   MSD - The output from detect_daily function.
%
%   'threshold' - Default is 0.3. The percentile used for categorizing.
%
%  Output Arguments
%   start_end_phase_4 - A 3D numeric matrix in size of m-by-4-by-2. m
%   indicates the number of MSD events, 4 indicates four period of each MSD
%   event, and 2 indicates start and end of each period. Each numeric value
%   indicates a time in the format of datenum(). For example,
%   start_end_phase_4(20,3,2) indicating the end time of period 3 for event
%   20.

paramNames = {'threshold'};
defaults   = {0.3};

[vthreshold]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

start_end_phase_4=NaN(21872,4,2);
for i=1:size(MSD,1)
    msd_here=MSD(i,:);
    start_here=msd_here(4);
    end_here=msd_here(6);
    peak_here=msd_here(8);
    
    start_end_phase_4(i,1,1)=start_here;
    start_end_phase_4(i,1,2)=round(quantile([start_here peak_here],vthreshold));
    start_end_phase_4(i,2,1)=round(quantile([start_here peak_here],vthreshold))+1;
    start_end_phase_4(i,2,2)=peak_here;
    start_end_phase_4(i,3,1)=peak_here+1;
    start_end_phase_4(i,3,2)=round(quantile([peak_here+1 end_here],1-vthreshold));
    start_end_phase_4(i,4,1)=round(quantile([peak_here+1 end_here],1-vthreshold))+1;
    start_end_phase_4(i,4,2)=end_here;
end