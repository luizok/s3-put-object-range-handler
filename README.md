# DocumentType Spec

## Document Header

|Field           |Spec    |Type |Position|
|-               |-       |-    |-       |
|_type(always 0) |9       |int  |0       |
|ref_date        |9(8)    |int  |1-9     |
|document_type   |X       |str  |9       |
|total_records   |X(12)   |str  |10-13   |
|**TOTAL**       |        |     |**13**  |

### Document Type A

|Field           |Spec    |Type |Position|
|-               |-       |-    |-       |
|_type(always 1) |9       |int  |0       |
|user_id         |X(12)   |str  |1-12    |
|value           |9(5)V99 |int  |13-19   |
|**TOTAL**       |        |     |**20**  |

### Document Type B

|Field           |Spec    |Type |Position|
|-               |-       |-    |-       |
|_type(alwalys 1)|9       |int  |0       |
|source_id       |X(12)   |str  |1-12    |
|target_id       |X(12)   |str  |13-24   |
|value           |9(5)V99 |int  |25-31   |
|isScheduled     |X       |bool |32      |
|**TOTAL**       |        |     |**33**  |
