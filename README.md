# NLOS imaging over 1.43km

This demo includes data and MATLAB codes used in the paper "Non-line-of-sight imaging over 1.43 kilometers" by Cheng Wu, Jianjiang Liu, Xin Huang, Zheng-Ping Li, Chao Yu, Jun-Tian Ye, Jun Zhang, Qiang Zhang, Xiankang Dou, Vivek K. Goyal, Feihu Xu, and Jian-Wei Pan (to appear in PNAS(2021)).

Corresponding author: feihuxu@ustc.edu.cn.

To try the codes, just download the zip and run the "demo_NLOS_over_1400m.m" in MATLAB. Warning: the code was tested using MATLAB 2018a and 2018b, it might be incompatible with older versions. To obtain a result, 300 iterations are needed, which will cost about 1 hour using a computer with i9-10900K.

## Attribution

### Data

The experimental NLOS imaging data is obtained by our novel NLOS lidar system, including a letter 'H.mat' and a mannequin 'mannequin.mat'.
Instructions for the experimental data:

- 'sig_in': (type: 64 * 64 * 512 double), it contains the temporal distribution(histogram) of arrival photons at each pixel.
- 'timeRes': (type: double), it represents the time resolution of the time-digital-converter(TDC) (unit:s)
- 'pulsewidth': (type: double), it represents the pulse width of the histogram in 'data_processed' (unit:s)
- 'width': (type: double), it represents the width of scanning area

### Code

Our algorithm is based on the following two papers:

O’Toole, Matthew, David B. Lindell, and Gordon Wetzstein. "Confocal non-line-of-sight imaging based on the light-cone transform." Nature 555.7696 (2018): 338-341.

Harmany, Zachary T., Roummel F. Marcia, and Rebecca M. Willett. "This is SPIRAL-TAP: Sparse Poisson intensity reconstruction algorithms—theory and practice." IEEE Transactions on Image Processing 21.3 (2011): 1084-1096.
