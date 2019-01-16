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








