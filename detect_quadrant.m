function BI=detect_quadrant(precip,time,lat_full,varargin)
%soh - calculating biomodal index (BI) based on monthly precipitation data.
%  Syntax
%
%  BI=detect_quadrant(precip,time,lat_full)
%
%  Description
%
%  BI=detect_quadrant(precip,time,lat_full) returns BI based on monthly
%  rainfall data PRECIP.
%
%  Input Arguments
%   precip - 3D daily precipitation (mm/day) in size of m-by-n-by-t.
%
%   time - A numeric matrix in size of t-by-2. The first column indicates
%   the corresponding year while the second column indicates the
%   corresponding month (1 to 12).
%
%   lat_full - A numeric matrix (m-by-n) indicating latitude for PRECIP.
%   This is actually used to distinguish the situation in northern/southern
%   hemisphere so if you do not have exact latitude data please use
%   positive/negative value for northern/southern hemisphere.
%
%   'clim_start' - Default is the first row of TIME. The time for the
%   calculation of climatology.
%
%   'clim_end' - Default is the last row of TIME. The time for the
%   calculation of climatology in the format of datenum().
%
%   'msd_start' - Default is the first year with complete annual
%   precipitation. The starting year for BI calculation.
%
%   'msd_end' - Default is the last year with complete annual precipitation.
%   the ending year for BI calculation.
%
%  Output Arguments
%   BI - A 3D numeric matrix (in size of m-by-n-by-(msd_end-msd_start+1))
%   containing calculated biomodal index.
%
%  Reference
%   Angeles, M. E., Gonz¡§?lez, J. E., Ram¡§?rez?Beltr¡§?n, N. D., Tepley, C. A.,
%   & Comarazamy, D. E. (2010). Origins of the Caribbean rainfall bimodal behavior.
%   Journal of Geophysical Research: Atmospheres,?115(D11).

paramNames = {'clim_start','clim_end','msd_start','msd_end'};
defaults   = {time(1,:),time(end,:),nanmin(time(:,1)),nanmax(time(:,1))};
[vclim_start,vclim_end,vmsd_start,vmsd_end]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});
precip_cclim=precip(:,:,...
    find(time(:,1)==vclim_start(1) & time(:,2)==vclim_start(2)):...
    find(time(:,1)==vclim_end(1) & time(:,2)==vclim_end(2)));
time_cclim=time(find(time(:,1)==vclim_start(1) & time(:,2)==vclim_start(2)):...
    find(time(:,1)==vclim_end(1) & time(:,2)==vclim_end(2)),:);
precip_clim=NaN(size(precip,1),size(precip,2),12);
for i=1:12
    precip_clim(:,:,i)=nanmean(precip_cclim(:,:,time_cclim(:,2)==i),3);
end
precip_cell=num2cell(precip,3);
precip_clim_cell=num2cell(precip_clim,3);
time_cell=(repmat({time},size(precip,1),size(precip,2)));
lat_cell=num2cell(lat_full,3);
vmsd_start_cell=repmat({vmsd_start},size(precip,1),size(precip,2));
vmsd_end_cell=repmat({vmsd_end},size(precip,1),size(precip,2));
BI=cellfun(@detect_one,precip_cell,precip_clim_cell,time_cell,lat_cell,...
    vmsd_start_cell,vmsd_end_cell,'UniformOutput',false);
BI=cell2mat(BI);
function BI_here=detect_one(precip_here,precip_clim_here,time,lat_here,vmsd_start,vmsd_end)
BI_here=NaN(1,1,length(vmsd_start:vmsd_end));
precip_here=squeeze(precip_here);
precip_clim_here=squeeze(precip_clim_here);
if nansum(isnan(precip_here))~=length(precip_here)
    for y=vmsd_start:vmsd_end
        precip_year=precip_here(time(:,1)==y);
        
        if length(precip_year)==12
            if lat_here>0
                precip_o=precip_year(7);
                precip_b=precip_year(6);
                precip_a=precip_year(8);
                
                precip_clim_b=precip_clim_here(6);
                precip_clim_a=precip_clim_here(8);
            else
                precip_o=precip_year(1);
                precip_b=precip_year(12);
                precip_a=precip_year(2);
                
                precip_clim_b=precip_clim_here(12);
                precip_clim_a=precip_clim_here(2);
            end
            
            if precip_b>precip_o && precip_a>precip_o
                BF=1;
            elseif precip_b==precip_o && precip_a==precip_o
                BF=0;
            else
                BF=-1;
            end
            
            BI_here(:,:,y-vmsd_start+1)=BF.*((precip_a+precip_b)./(precip_clim_a+precip_clim_b));
            
        end
    end
end