MSD
==================================================================

Different from normal rainy condition in northern hemisphere (Hastenrath, 1967), the climatological and annual precipitation over Central America and Mexico are widely dominated by a biomodal precipitation, shaped by two peaks separately during May to July and August to October and a relative trough during between this two peaks, named as midsummer drought (MSD) (Mosiño and García, 1966; Coen, 1973). This phenomenon has been identified and studied for a long time but there are still many unresolved problems around it, includng both mechanism and characteristics. This could be caused by many reasons including the absence of a practical protocol to identify and detect MSD signals. 

Based on a preprint (Zhao et al., in prep.), a new approach to determine and quantify the climatological and annual MSD signals is proposed. This algorithm makes it possible to use annual daily precipitation data to find potential traditionally-defined (where first peak in May to Jul and second peak in Aug to Oct) MSD events. It also specifies MSD signals into daily resolution, enabling more detailed analysis to be applied to MSD events. 

This module contains a set of function associated with detection and analysis about MSD based on recent and past research. This module is built in a user-friendly way and is expected to have a good scalability. This toolbox would be updated with the development of associated MSD research.

Installation
-------------

The installation of this toolbox could be directly achieved by downloading this repositories and add its path in your MATLAB.

Requirements
-------------

The MATLAB Statistics and Machine Learning Toolbox. [m_map](https://www.eoas.ubc.ca/~rich/map.html) is recommended for running example.

Current Functions
-------------

<table>
<colgroup>
<col width="17%" />
<col width="60%" />
<col width="22%" />
</colgroup>
<thead>
<tr class="header">
<th>Function</th>
<th>Description</th>
<th>Literature</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>detect_daily()</code></td>
<td>The main function, aiming to detect and quantify climatological and annual MSD events based on the definition given by Zhao et al. (in prep.) </td>
<td>Zhao et al. in prep.</td>
</tr>
<tr class="even">
<td><code>detect_monthly()</code></td>
<td>The function to detect and quantify climatological MSD events using climatological monthly precipitation data, based on the definition given by </td>
<td>Karnauskas et al. 2013</td>
</tr>
<tr class="odd">
<td><code>categorize()</code></td>
<td>The function to categorize each MSD event into four periods. </td>
<td>Zhao et al. in prep. </td>
</tr>
<tr class="even">
<td><code>mean_states()</code></td>
<td>The function to calculate mean states for a set of MSD properties. </td>
<td>Zhao et al. in prep. </td>
</tr>
<tr class="odd">
<td><code>composites()</code></td>
<td>The function to calculate composites for a particular dataset across a particular index.</td>
<td>Zhao et al. in prep. </td>
</tr>
<tr class="even">
<td><code>soh()</code></td>
<td>The function to calculate the proportion of explained variance of rainy season precipitation by a second order harmonic.</td>
<td>Curtis, 2005. </td>
</tr>
</tbody>
</table>

Contributing to `MSD`
-------

To contribute to the package please follow the guidelines [here](https://github.com/ZijieZhaoMMHW/MSD/blob/master/docs/Contributing_to_MSD.md).

Please use this [link](https://github.com/ZijieZhaoMMHW/MSD/issues) to report any bugs found.

Contact
-------

Zijie Zhao

School of Earth Science, The University of Melbourne

Parkville VIC 3010, Melbourne, Australia

E-mail: <zijiezhaomj@gmail.com> 




