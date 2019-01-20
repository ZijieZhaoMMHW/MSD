# Function description for **`MSD`**

Here a description for functions in MSD toolbox is presented.

## `detect_daily`

### Algorithm description

The function `detect_daily` is designed to detect climatological and annual MSD events following approach given by Zhao et al. 
(in prep.). The algorithm is given as follows.

The algorithm is achieved in two consecutive steps. Firstly, the determination of MSD area needs to be done. A dataset containing daily precipitation `P` in size of `(X, Y, T)`, where `X` and `Y` indicate the number of horizontal grids and `T` indicates the length in days, is assumed to be available for application of the algorithm. For each such dataset, the first step is to calculate its annual climatology <code>P<sub>clim</sub></code> using all records in `P`. <code>P<sub>clim</sub></code> is calculated by averaging all records in each Julian days, where the data on February 29th in each no-leap year is filled by the mean of calculated climatology on February 28th and March 1st. Hence, <code>P<sub>clim</sub></code> is a dataset of size `(X, Y, 366)`. The MSD signal is then detected in each `(x, y)` grid independently. The precipitation time series <code>P<sub>clim</sub></code> is smoothed using a 31-day window with a Gaussian-weighted moving average in each grid, and the resultant data is recorded as <code>P<sub>sm</sub></code>. For the time series <code>P<sub>sm</sub> (x, y)</code> in each grid `(x, y)`, the existence of the MSD signal should be confirmed based on three criteria: 1) two maximum precipitation peaks, <code>P<sub>max1</sub></code> and <code>P<sub>max2</sub></code> should exist separately in the periods May 15th to July 15th and August 15th to October 15th; their corresponding dates should be separately recorded as `d1` and `d2`; 2) `d3`, which corresponds to the date when annual maximum precipitation exists, should thus be the same as either `d1` or `d2`; and 3) the linear trend of the precipitation time series between January 1st and `d1` should be significantly positive, while that of the time series between `d2` and December 31st should be significantly negative. The presence of these three criteria confirms that the grid `(x, y)` can be identified as an MSD area; otherwise, it exhibits no MSD signal. In this process, the relatively drought between two peaks is confirmed by the existence of two peaks of precipitation and the shift between dry and rainy seasons is determined by linear regressions. Although there is still potential that a third peak of precipitation could exist during detected MSD signals, time series confirming three criteria mentioned above are still classified as MSD signals due to determined precipitation reduction and annual biomodal distribution.

Then, the detection and quantification of annual MSD signals in each MSD grid should be done. For a validated MSD `(x, y)` grid, the MSD signal in each year can be determined by following the same procedure applied to <code>P<sub>clim</sub></code> in step 2. For each detected MSD signal, several fundamental metrics can thus be determined, including onset date (the date of <code>P<sub>max1</sub></code>), end date (the date of <code>P<sub>max2</sub></code>), and duration (length of days between onset and end dates). The intensity of each detected MSD signal is quantified by the Intensity of the MSD (<code>I<sub>msd</sub></code>) as defined by García-Martínez (2015).

### Inputs and Outputs

Function **`detect_daily()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>precip</code></td>
<td>3D daily precipitation (mm/day) to detect MSD events, specified as a m-by-n-by-t matrix. m and n separately indicate two spatial dimensions and t indicates temporal dimension. </td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric vector corresponding to the time of <code>precip</code> in length of t in the format of <code>datenum()</code> </td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>lat_full</code></td>
<td>A numeric matrix (m-by-n) indicating latitude for <code>precip</code>. This is actually used to distinguish the situation in northern/southern hemisphere so if you do not have exact latitude data please use positive/negative value for northern/southern hemisphere. </td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>smoothwidth</code></td>
<td>Default is 31. Width of window to smooth raw and calculated climatological precipitation. </td>
<td>Optional</td>
</tr>
<tr class="odd">
<td><code>clim_start</code></td>
<td>Default is the first element of <code>time</code>. The starting time for the calculation of climatology in the format of <code>datenum()</code>. </td>
<td>Optional</td>
</tr>
<tr class="even">
<td><code>clim_end</code></td>
<td>Default is the last element of <code>time</code>. The ending time for the calculation of climatology in the format of <code>datenum()</code>. </td>
<td>Optional</td>
</tr>
<tr class="odd">
<td><code>mhw_start</code></td>
<td>Default is the first year with complete annual precipitation. The starting year for MSD detection. </td>
<td>Optional</td>
</tr>
<tr class="even">
<td><code>mhw_end</code></td>
<td>Default is the last year with complete annual precipitation. The ending year for MSD detection. </td>
<td>Optional</td>
</tr>
</tbody>
</table>

Function **`detect_daily`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Output</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>MSD</code></td>
<td>A table containing all detected MSD events where each row corresponding to a particular event and each column corresponding to a metric. </td>
</tr>
<tr class="even">
<td><code>precip_clim</code></td>
<td>A 3D matrix (m-by-n-by-366) containing smoothed climatologies.</td>
</tr>
<tr class="odd">
<td><code>imsd</code></td>
<td>A matrix (m-by-n) containing <codeI<sub>msd</sub></code> calculated based on <code>precip_clim</code>.</td>
</tr>
</tbody>
</table>

The major output **`MSD`** is a table containing many metrics, including:
<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Output</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>YEAR</code></td>
<td>The year when MSD events happen. For southern hemisphere, it corresponds to the first half year. </td>
</tr>
<tr class="even">
<td><code>XLOC</code></td>
<td>Location of each event in x-dimension of PRECIP. </td>
</tr>
<tr class="odd">
<td><code>YLOC</code></td>
<td>Location of each event in y-dimension of PRECIP. </td>
</tr>
<tr class="even">
<td><code>ONSET</code></td>
<td>The onset date of each event in the format of <code>datenum()</code>. </td>
</tr>
<tr class="odd">
<td><code>ONSET_D</code></td>
<td>The day of year for <code>ONSET</code>. </td>
</tr>
<tr class="even">
<td><code>ENDING</code></td>
<td>The ending date of each event in the format of <code>datenum()</code>. </td>
</tr>
<tr class="odd">
<td><code>ENDING_D</code></td>
<td>The day of year for <code>ENDING</code>. </td>
</tr>
<tr class="even">
<td><code>PEAK</code></td>
<td>The peak date of each event in the format of <code>datenum()</code>. </td>
</tr>
<tr class="odd">
<td><code>PEAK_D</code></td>
<td>The day of year for <code>PEAK</code>. </td>
</tr>
<tr class="even">
<td><code>P<sub>max</sub></code></td>
<td><code>P<sub>max</sub></code> mentiond in Algorithm description. </td>
</tr>
<tr class="odd">
<td><code>P<sub>min</sub></code></td>
<td><code>P<sub>min</sub></code> mentiond in Algorithm description. </td>
</tr>
<tr class="even">
<td><code>P1</sub></code></td>
<td>The precipitation on the onset of MSD.</td>
</tr>
<tr class="odd">
<td><code>P2</sub></code></td>
<td>The precipitation on the end of MSD.</td>
</tr>
<tr class="even">
<td><code>imsd</sub></code></td>
<td> <code>I<sub>msd</sub></code>.</td>
</tr>
</tbody>
</table>

### Examples

Here we use the daily precipitation over land extracted from Climate Prediction Center (CPC) global unified gauge-based analysis of daily precipitation (Xie et al., 2007; Chen et al., 2008), during 1979 to 2017 in (0-30<sup>o</sup>N, 120-60<sup>o</sup>W).

```
% Read and reconstruct data
precip=NaN(120,60,length(datenum(1979,1,1):datenum(2017,12,31)));
for i=1979:2017
    file_here=['precip_' num2str(i)];
    load(file_here);
    precip(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1979,1,1)+1)=precip_here;
    clear precip_here
end
time=(datenum(1979,1,1):datenum(2017,12,31))';
size(precip,3)==length(time)

ans =
  logical
   1
% The time range is (1979,1,1) to (2017,12,31)
```

Then we load associated latitudes and run the **`detect_daily()`** function
```
load('loc');
lat_full=repmat(lat',120,1);
[MSD,precip_clim,imsd_climatology]...
=detect_daily(precip,time,lat_full);
```

You would see something like following contents indicating the running of this algorithm.
```
...
Determining the MSD area, current location: x25 y59
Determining the MSD area, current location: x25 y60
Determining the MSD area, current location: x26 y1
Determining the MSD area, current location: x26 y2
Determining the MSD area, current location: x26 y3
Determining the MSD area, current location: x26 y4
...
```

Let's have a look of the resultant outputs.

MSD is a table containing each detected MSD signal. For example, we could see the 20th detected MSD signal existed in grid (35,1) during 1986. This signal started on the 154th day of year,ended on the 279th day of year, reaching its peak on the 211th day of year. Its intensity is ~0.59.

```
MSD(20,:)
ans =
  1×14 table
    YEAR    XLOC    YLOC      ONSET       ONSET_D      ENDING      ENDING_D       PEAK       PEAK_D    Pmax      Pmin       P1       P2       imsd  
    ____    ____    ____    __________    _______    __________    ________    __________    ______    _____    ______    ______    _____    _______
    1986    35      1       7.2553e+05    154        7.2565e+05    279         7.2558e+05    211       5.966    2.4751    3.7682    5.966    0.58513
```

`imsd` is the <code>I<sub>msd</sub></code> calculated based on `precip_clim`, which is the smoothed climatology. We could plot it with the help from [m_map](https://www.eoas.ubc.ca/~rich/map.html).

## `mean_states`

### Algorithm description

The function **`mean_states()`** is used to calculate the mean state of a particular MSD metric based on **`MSD`** returned by **`detect_daily()`**.

### Inputs and Outputs

Function **`mean_states()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>MSD</code></td>
<td>Output from function <code>detect_daily()</code>.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>year_range</code></td>
<td>A numeric vector containing two values indicating time range of MSD detection. E.G. [1979 2016].</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>Metric</code></td>
<td>Default is 'Frequency'. The MSD metric for which the mean state is calculated.</td>
<td>Optional</td>
</tr>
</tbody>
</table>

The optional input **`Metric`** has 10 different cases, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Options</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>Frequency</code></td>
<td>Calculating frequency (/year) of MSD events.</td>
</tr>
<tr class="even">
<td><code>Onset</code></td>
<td>Calculating mean states of onset date (day of year).</td>
</tr>
<tr class="odd">
<td><code>End</code></td>
<td>Calculating mean states of end date (day of year).</td>
</tr>
<tr class="even">
<td><code>Peak</code></td>
<td>Calculating mean states of peak date (day of year).</td>
</tr>
<tr class="odd">
<td><code>Duration</code></td>
<td>Calculating mean states of duration (days).</td>
</tr>
<tr class="even">
<td><code>P1</code></td>
<td>Calculating mean states of P1 (mm/day).</td>
</tr>
<tr class="odd">
<td><code>P2</code></td>
<td>Calculating mean states of P2 (mm/day).</td>
</tr>
<tr class="even">
<td><code>P<sub>max</sub></code></td>
<td>Calculating mean states of P<sub>max</sub> (mm/day).</td>
</tr>
<tr class="odd">
<td><code>P<sub>min</sub></code></td>
<td>Calculating mean states of P<sub>min</sub> (mm/day).</td>
</tr>
<tr class="even">
<td><code>imsd</code></td>
<td>Calculating mean states of I<sub>msd</sub>.</td>
</tr>
</tbody>
</table>

Function **`mean_states`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Output</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>m</code></td>
<td>m - A numeric matrix containing mean states of MSD metric in each grid. Each column of m corresponds to a particular MSD grid and three column separately indicate x_grid, y_grid and calculated mean state.</td>
</tr>
</tbody>
</table>

### Examples

Here we use **`MSD`** returned in the example in **`detect_daily`**. We know calculate and plot its frequency for MSD signals in each grid and plot it.

Firstly we run the **`mean_states`** function with default metric frequency.

```
freq=mean_states(MSD,[1979 2017]);
```

We need to reconstruct it into spatial map.

```
freq_2d=NaN(120,60);

for i=1:size(freq,1);
    freq_2d(freq(i,1),freq(i,2))=freq(i,3);
end
```

Then we plot it.

```
figure('pos',[10 10 1000 1000]);
m_contourf(lon,lat,freq_2d',0:0.01:1,'linestyle','none');
m_coast();
m_grid;
colormap(jet);
s=colorbar('fontsize',16);
s.Label.String='/year';
caxis([0 1]);
```

## `categorize`

### Algorithm description

The function **`categorize`** is used to separate each detected MSD signal from **`detect_daily`** into four parts. A MSD signal has three important time points, including onset, end and peak dates. Period 1 (P1) is defined as onset date to the 30th percentile between onset and peak date (d30), P2 is d30 to peak date, P3 is peak date to 70th percentile between peak and end date (d70), while P4 is d70 to end date. Intuitively, P1 tends to cover the period representing the onset of MSD, so P1 could be intuitively named as 'Starting Period'. Similarly, P2 is 'Developing Period', P3 is 'Decreasing Period' and P4 is 'Ending Period'.

### Inputs and Outputs

Function **`categorize()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>MSD</code></td>
<td>Output from function <code>detect_daily()</code>.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>threshold</code></td>
<td>Default is 0.3. Threshold to calculate the percentile. For example, if threshold is 0.4, d30 would change to d40 and d70 would change to d60.</td>
<td>Optional</td>
</tr>
</tbody>
</table>

Function **`categorize()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Output</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>start_end_phase_4</code></td>
<td>A 3D numeric matrix in size of m-by-4-by-2. m indicates the number of MSD events, 4 indicates four period of each MSD event, and 2 indicates start and end of each period. Each numeric value indicates a time in the format of <code>datenum()</code>. For example, <code>start_end_phase_4(20,3,2)</code> indicating the end time of period 3 for event 20.</td>
</tr>
</tbody>
</table>

### Examples

We still use the output **`MSD`** in the example of **`detect_daily()`** to run function **`categorize`**.

```
phase_1_4=categorize(MSD);
[datevec(phase_1_4(20,2,1));datevec(phase_1_4(20,2,2))]
ans =
        1986           6          10           0           0           0
        1986           7          30           0           0           0
```

We could see the 20th event's period 2 started on (1986,6,10), ended on (1986,7,30).

## **`composites`**

The function **`composites()`** is used to calculate the average of a particular dataset across a particular index.

### Algorithm description

Skip.

### Inputs and Outputs

Function **`composites()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>d</code></td>
<td>A 3D numeric matrix in size of m-by-n-by-t, where m and n correspond to spatial position and t correspond to temporal record.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric vector indicating the time corresponding to <code>d</code> in the format of <code>datenum()</code>.</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>index</code></td>
<td>A numeric vector corresponding to a set of time for which you would like to calculate composites in the format of <code>datenum()</code>.</td>
<td>Necessary</td>
</tr>
</tbody>
</table>

Function **`composites()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>c</code></td>
<td>m - A numeric matrix in size of m-by-n containing the calculated composites in each grid.</td>
</tr>
</tbody>
</table>

### Examples

Here we calculate the composite of precipitation anomalies across onset dates for detected MSD signals.

Firstly we need to calculate the precipitation anomalies.

```
precip_anom=NaN(120,60,size(precip,3));
date_used=datevec(datenum(1979,1,1):datenum(2017,12,31));
unique_m_d=unique(date_used(:,2:3),'rows');
for i=1:size(unique_m_d,1);
    index_here=(date_used(:,2)==unique_m_d(i,1) & date_used(:,3)==unique_m_d(i,2));
    precip_anom(:,:,index_here)=precip(:,:,index_here)-nanmean(precip(:,:,index_here),3);
end
```

Then we use the onset date from **`MSD`** to execute `composites()`.

```
MSD_m=MSD{:,:};
onset_index=MSD_m(:,4);
c_onset=composites(precip_anom,(datenum(1979,1,1):datenum(2017,12,31))',onset_index);
c_onset(c_onset==0)=nan; % remove lands.
```

Plot it.

```
figure('pos',[10 10 1000 1000]);
m_proj('miller','lon',[180+60 180+120],'lat',[0 30]);
m_contourf(lon,lat,c_onset',-4.2:0.01:4.2,'linestyle','none');
m_coast();
m_grid('fontsize',16);
color_b=[(linspace(0,1,32))' (linspace(0,1,32))' ones(32,1)];
color_r=[ones(32,1) (linspace(1,0,32))' (linspace(1,0,32))'];
color_here=[color_b;color_r];
colormap(color_here);
s=colorbar('fontsize',16);
s.Label.String='mm/day';
caxis([-4.2 4.2]);
```

## `detect_monthly`

### Algorithm description

The function **`detect_monthly()`** is used to detect and quantify climatological MSD events based on monthly precipitation data in unit of mm/day based on the algorithm given by Karnauskas et al. (2013). 

This algorithm is achieved following a protocol for data in each grid. Firstly, the monthly climatological precipitation is calculated and climatology in southern hemisphere is shifted. After that, the first two largest preicpitation are recorded as p1 and p2. If there are 1-3 months between p1 and p2, the time period between them are recorded as a MSD period and its intensity is quantified. If p1 and p2 are next to each other, the third largest precipitation would be found and it would be determined if there are 1-4 months between p3 and both p1 and p2. If so, the time period among p1, p2 and p3 is determined as a MSD period and its intensity is quantified. The intensity (or 'depth') of MSD periods is determined by calculating the reduction of rainfall during the minimum relative to the mean of the two rainfall maxima. One of the biggest advantage is that it does not have a priori assume for MSD periods.

### Inputs and Outputs

Function **`detect_monthly()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>precip</code></td>
<td>3D monthly precipitation (mm/day) to detect MSD events, specified as a m-by-n-by-t matrix. m and n separately indicate two spatial dimensions and t indicates temporal dimension.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric matrix in size of t-by-2. The first column indicates the corresponding year while the second column indicates the corresponding month (1 to 12).</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>lat_full</code></td>
<td>A numeric matrix (m-by-n) indicating latitude for PRECIP. This is actually used to distinguish the situation in northern/southern hemisphere so if you do not have exact latitude data please use positive/negative value for northern/southern hemisphere.</td>
<td>Necessary</td>
</tr>
</tbody>
</table>

Function **`detect_monthly()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Output</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>depth</code></td>
<td>A numeric matrix (m-by-n) indicating the intensity (mm/day) for climatological MSD in each grid.</td>
</tr>
<tr class="even">
<td><code>onset</code></td>
<td>A numeric matrix (m-by-n) indicating the onset month for climatological MSD in each grid.</td>
</tr>
<tr class="odd">
<td><code>ending</code></td>
<td>A numeric matrix (m-by-n) indicating the ending month for climatological MSD in each grid.</td>
</tr>
</tbody>
</table>

### Examples

Here we still use CPC precipitation during 1979-2016 to execute **`detect_monthly()`**. Firstly we need to transform daily data into monthly data by calculating averages.

```
date_used=datevec(datenum(1979,1,1):datenum(2017,12,31));
u_y_m=unique(date_used(:,1:2),'rows');

precip_month=NaN(120,60,size(u_y_m,1));

for i=1:size(precip_month,3);
    index_here=(date_used(:,1)==u_y_m(i,1) & date_used(:,2)==u_y_m(i,2));
    precip_month(:,:,i)=nanmean(precip(:,:,index_here),3);
end
```

Then we run the code and plot the depth.

```
[depth,onset,ending]=detect_monthly(precip_month,u_y_m,ones(120,60));

figure('pos',[10 10 1000 1000]);
m_proj('miller','lon',[180+60 180+120],'lat',[0 30]);
m_contourf(lon,lat,depth',0:0.01:5,'linestyle','none');
m_coast();
m_grid('fontsize',16);
colormap(jet);
caxis([0 4.5]);
s=colorbar('fontsize',16);
s.Label.String='mm/day';
```

## `detect_mg`

### Algorithm description

The function **`detect_mg()`** is used to detect and quantify climatological MSD following the definition given by Mosiño and García (1966). Similar approach has also been used in Perdigón‐Morales et al. (2018). 

This algorithm is achieved by finding consecutive months during the traditionally defined rainy season (May–October) based on climatological monthly precipitation, which presents a decrease in mean monthly accumulated precipitation with respect to the 2 months of maximum precipitation that bound them. If two maximums are next to each other, there is no detected MSD duration. The intensity of MSD is quantified using RD index, referred to a quotient between the representative area of the deficit and the total accumulated precipitation from May to October, which is expressed as a percentage. The MSD is considered weak when RD<10%, moderate when 10%<=RD<16%, strong RD>=16. 

### Inputs and Outputs

Function **`detect_mg()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>precip</code></td>
<td>3D monthly precipitation (mm/day) to detect MSD events, specified as a m-by-n-by-t matrix. m and n separately indicate two spatial dimensions and t indicates temporal dimension.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A 2D numeric matrix in size of t-by-2, where the first column indicates corresponding years and the second column indicates corresponding months.</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>lat_full</code></td>
<td>A numeric matrix (m-by-n) indicating latitude for <code>precip</code>. This is actually used to distinguish the situation in northern/southern hemisphere so if you do not have exact latitude data please use positive/negative value for northern/southern hemisphere.</td>
<td>Necessary</td>
</tr>
</tbody>
</table>

Function **`detect_mg()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Options</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>dur</code></td>
<td>A numeric matrix (m-by-n) containing the number of months during climatological MSD in each grid.</td>
</tr>
<tr class="even">
<td><code>RD</code></td>
<td>A numeric matrix (m-by-n) containing the quotient between the representative area of the deficit and the total accumulated precipitation from May to October.</td>
</tr>
<tr class="odd">
<td><code>label</code></td>
<td>A 2D cell (m-by-n) containing the label of MSD in each grid. 'weak' for RD(i,j)<0.1, 'moderate' for 0.1<=RD(i,j)<0.16, 'strong' for RD(i,j)>=0.16.</td>
</tr>
</tbody>
</table>

### Examples

We still use the monthly precipitation reconstructed from CPC daily precipitation to run the code.

```
[dur,RD,label]=detect_mg(precip_month,u_y_m,ones(120,60));

figure('pos',[10 10 1000 1000]);
m_proj('miller','lon',[180+60 180+120],'lat',[0 30]);
m_contourf(lon,lat,RD',0:0.01:1,'linestyle','none');
m_coast();
m_grid('fontsize',16);
colormap(jet);
caxis([0 0.7]);
s=colorbar('fontsize',16);
s.Label.String='';
```

## `soh`

### Algorithm description

The function **`soh()`** is achieved by applying a second-order harmonic (SOH) to climatological preicpitation in traditionally defined rainy season (May to Oct for nothern hemisphere; Nov to Apr for southern hemisphere). A well modelled SOH during this period should be shaped as a sinusoidal wave with 2 peaks and 2 troughs, representing a well-shaped biomodal distribution of precipitation. Therefore, it is reasonable to use the explained variance of rainy season climatological precipitation by SOH to quantify the strength of biomodal precipitation distribution for a particular precipitation time series. Similar approach has been used in Curtis (2005).

### Inputs and Outputs

Function **`soh()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>precip</code></td>
<td>3D daily precipitation (mm/day) in size of m-by-n-by-t.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric vector (length t) corresponding to the time of <code>precip</code> in the format of <code>datenum()</code>.</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>lat_full</code></td>
<td>A numeric matrix (m-by-n) indicating latitude for <code>precip</code>. This is actually used to distinguish the situation in northern/southern hemisphere so if you do not have exact latitude data please use positive/negative value for northern/southern hemisphere.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>smoothwidth</code></td>
<td>Default is 1. Width of window to smooth calculated climatological precipitation</td>
<td>Optional</td>
</tr>
</tbody>
</table>

Function **`soh()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Options</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>expv</code></td>
<td>A numeric matrix (in size of m-by-n, ranging from 0 to 1) containing proportion of explained variance of daily precipitation in rainy season by a second order harmonic.</td>
</tr>
</tbody>
</table>

### Examples

We use the daily CPC precipitation to run the code.

```
expv=soh(precip,(datenum(1979,1,1):datenum(2017,12,31))',ones(120,60));
figure('pos',[10 10 1000 1000]);
m_proj('miller','lon',[180+60 180+120],'lat',[0 30]);
m_contourf(lon,lat,expv',0:0.01:1,'linestyle','none');
m_coast();
m_grid('fontsize',16);
colormap(jet);
caxis([0 0.7]);
s=colorbar('fontsize',16);
s.Label.String='';
```

## `detect_quadrant`

### Algorithm description

The function **`detect_quadrant()`** is to calculate the bimodal index (BI) based on annual monthly precipitation data. BI is defined using a quadrantal approach. Considering a coordinate system origining at July, the precipitation in June and August should be separately located in quadrant II and I. On the other hand, if the precipitation in June is in quadrant III or that in August is in quadrant IV, the biomodal signal 

### Inputs and Outputs

Function **`soh()`** achieves this algorithm using some inputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="65%" />
<col width="17%" />
</colgroup>
<thead>
<tr class="header">
<th>Input</th>
<th>Description</th>
<th>Label</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>precip</code></td>
<td>3D daily precipitation (mm/day) in size of m-by-n-by-t.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric vector (length t) corresponding to the time of <code>precip</code> in the format of <code>datenum()</code>.</td>
<td>Necessary</td>
</tr>
<tr class="odd">
<td><code>lat_full</code></td>
<td>A numeric matrix (m-by-n) indicating latitude for <code>precip</code>. This is actually used to distinguish the situation in northern/southern hemisphere so if you do not have exact latitude data please use positive/negative value for northern/southern hemisphere.</td>
<td>Necessary</td>
</tr>
<tr class="even">
<td><code>smoothwidth</code></td>
<td>Default is 1. Width of window to smooth calculated climatological precipitation</td>
<td>Optional</td>
</tr>
</tbody>
</table>

Function **`soh()`** returns some outputs, which are summarized in following table.

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Options</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>expv</code></td>
<td>A numeric matrix (in size of m-by-n, ranging from 0 to 1) containing proportion of explained variance of daily precipitation in rainy season by a second order harmonic.</td>
</tr>
</tbody>
</table>

### Examples

We use the daily CPC precipitation to run the code.

```
expv=soh(precip,(datenum(1979,1,1):datenum(2017,12,31))',ones(120,60));
figure('pos',[10 10 1000 1000]);
m_proj('miller','lon',[180+60 180+120],'lat',[0 30]);
m_contourf(lon,lat,expv',0:0.01:1,'linestyle','none');
m_coast();
m_grid('fontsize',16);
colormap(jet);
caxis([0 0.7]);
s=colorbar('fontsize',16);
s.Label.String='';
```














