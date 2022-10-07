# Simulated Measurement Images

## Folder Structure
DICOM images of mass measurement phantom arranged by phantom sizes, densities and KV \
PHANTOMSIZE/KV/IMAGES \
[SIZE] are first set of images (good result), [SIZE1] are second set of images with more focus on lower density (sysmetic error)

## Image Geometry
QRM phantom
* 9 inserts in one image with 3 different densities of 3 different sizes
* Diameter of inserts:
  * **Small**: 1 mm
  * **Medium**: 3 mm
  * **Large**: 5 mm

## Calcium Density(ies)

| Folder Name | File Name      | High Density (mg/cc) | Medium Density (mg/cc) | Low Density (mg/cc) |
| ----------- | -------------- | -------------------- | ---------------------- | ------------------- |
| Large       | 1.dcm          | 733                  | 411                    | 151                 |
| Large       | 2.dcm          | 669                  | 370                    | 90                  |
| Large       | 3.dcm          | 552                  | 222                    | 52                  |
| Large1      | 1.dcm          | 797                  | 101                    | 37                  |
| Large1      | 2.dcm          | 403                  | 480                    | 32                  |
| Large1      | 3.dcm          | 199                  | 41                     | 27                  |
| Medium      | 1.dcm          | 733                  | 411                    | 151                 |
| Medium      | 2.dcm          | 669                  | 370                    | 90                  |
| Medium      | 3.dcm          | 552                  | 222                    | 52                  |
| Medium1     | 1.dcm          | 797                  | 101                    | 37                  |
| Medium1     | 2.dcm          | 403                  | 480                    | 32                  |
| Medium1     | 3.dcm          | 199                  | 41                     | 27                  |
| Small       | 1.dcm          | 733                  | 411                    | 151                 |
| Small       | 2.dcm          | 669                  | 370                    | 90                  |
| Small       | 3.dcm          | 552                  | 222                    | 52                  |
| Small1      | 1.dcm          | 797                  | 101                    | 37                  |
| Small1      | 2.dcm          | 403                  | 480                    | 32                  |
| Small1      | 3.dcm          | 199                  | 41                     | 27                  |


## Simulated Computed Tomography Parameter
**Exposure** 
Exposure values are same as the one used in integrated technique. Increasing the exposure can help reduce the noise and possibly contribute to a better measurement.
| Phantom Size | Exposure (mR) |
| ------------ | ------------- |
| Large        | 5.4           |
| Medium       | 2.0           |
| Small        | 0.9           |
