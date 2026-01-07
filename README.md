# DocumentType Spec

## Document Type A

|Field       |Spec    |Type |Position|
|-           |-       |-    |-       |
|userId      |X(12)   |str  |0-11    |
|value       |9(5)V99 |int  |12-18   |
|**TOTAL**   |        |     |**19**  |

## Document Type B

|Field       |Spec    |Type |Position|
|-           |-       |-    |-       |
|sourceId    |X(12)   |str  |0-11    |
|targetId    |X(12)   |str  |12-23   |
|value       |9(5)V99 |int  |24-30   |
|isScheduled |X       |bool |31      |
|**TOTAL**   |        |     |**32**  |
