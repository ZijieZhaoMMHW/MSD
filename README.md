MSD <img src="https://github.com/ZijieZhaoMMHW/MSD/blob/master/docs/logo_msd.png" width=200 align="right" />
==================================================================

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1c171c80979e40e9b2f7e63874835ba1)](https://app.codacy.com/app/ZijieZhaoMMHW/MSD?utm_source=github.com&utm_medium=referral&utm_content=ZijieZhaoMMHW/MSD&utm_campaign=Badge_Grade_Settings)

Different from normal rainy condition in northern hemisphere (Hastenrath, 1967), the climatological and annual precipitation over Central America and Mexico are widely dominated by a bimodal precipitation, shaped by two peaks separately during May to July and August to October and a relative trough during between this two peaks, named as midsummer drought (MSD) (Mosiño and García, 1966; Coen, 1973). This phenomenon has been identified and studied for a long time but there are still many unresolved problems around it, includng both mechanism and characteristics. This could be caused by many reasons including the absence of a practical protocol to identify and detect MSD signals. 

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
<td>The function to detect and quantify climatological MSD events using climatological monthly precipitation data, based on the definition given by Karnauskas et al. (2013). </td>
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
<td>Curtis, 2002. </td>
</tr>
<tr class="odd">
<td><code>detect_mg()</code></td>
<td>The function to detect and quantify climatological MSD following definition given by Mosiño and García (1966).</td>
<td>Mosiño and García, 1966. </td>
</tr>
<tr class="even">
<td><code>detect_quadrant()</code></td>
<td>The function to calculate bimodal index of annual monthly precipitation.</td>
<td>Angeles et al., 2010. </td>
</tr>
<tr class="odd">
<td><code>detect_monthly_updated()</code></td>
<td>Daily version of <code>detect_monthly</code>.</td>
<td>Karnauskas et al. 2013 </td>
</tr>
</tbody>
</table>

Detailed descriptions and examples of functions could be found [here](https://github.com/ZijieZhaoMMHW/MSD/blob/master/docs/function_description.md).

Contributing to `MSD`
-------

To contribute to the package please follow the guidelines [here](https://github.com/ZijieZhaoMMHW/MSD/blob/master/docs/Contributing_to_MSD.md).

Please use this [link](https://github.com/ZijieZhaoMMHW/MSD/issues) to report any bugs found.

Citation
-------

There is currently no publication about **`MSD`**, so if you use it in your research please refer to corresponding paper. When this toolbox is strong and complete enough I may try to find a journal (such as [The Jounral of Open Source Software](https://joss.theoj.org/papers) or [Environmetnal Modelling & Software](https://www.journals.elsevier.com/environmental-modelling-and-software/)) to publish it.

Reference
-------

Coen, E., 1973. El floklore costarricense relativo al clima. Revista de la Universidad de Costa Rica.

Curtis, S. (2002). Interannual variability of the bimodal distribution of summertime rainfall over Central America and tropical storm activity in the far-eastern Pacific. Climate Research, 22(2), 141-146.

Hastenrath, S., 1967. Rainfall distribution and regime in Central America. Archiv für Meteorologie, Geophysik und Bioklimatologie, Serie B, 15(3), pp.201-241.

Karnauskas, K. B., Seager, R., Giannini, A., & Busalacchi, A. J. (2013). A simple mechanism for the climatological midsummer drought along the Pacific coast of Central America. Atmósfera, 26(2), 261-281.

Mosiño, P. and García, E., 1966. The midsummer droughts in Mexico. In Proc. Regional Latin American Conf (Vol. 3, pp. 500-516).


Contact
-------

Zijie Zhao

School of Earth Science, The University of Melbourne

Parkville VIC 3010, Melbourne, Australia

E-mail: <zijiezhaomj@gmail.com> 




