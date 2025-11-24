# DC6xx Gate Arrays

For info on the base die, see [DC600](DC600.md)

### KA750 Central Processing Unit
 | Type  | Name | Function                                          | Board | Count | EK-GA750-RM                    | Sample | Die shot                                       | Netlist   | RTL          |
 |-------|------|---------------------------------------------------|-------|-------|--------------------------------|--------|------------------------------------------------|-----------|--------------|
 | DC600 | ---- | Base chip                                         | ----  | ----  | ----                           | ----   | ----                                           | ----      | ----         |
 | DC606 | TIM  | replaced by DC620 TOK                             | DPM   | 0     | Not covered                    |        |                                                |           |              |
 | DC607 | MDR  | Memory data register                              | MIC   | 8     | Tables, description            |        |                                                |           |              |
 | DC608 | ALP  | ALU Datapath                                      | DPM   | 8     | High level description         | Yes    | [here](https://siliconpr0n.org/map/dec/dc608/) | Completed | from netlist |
 | DC609 | ADD  | Address datapath                                  | MIC   | 4     | Tables, description            |        |                                                |           |              |
 | DC610 | CCC  | Condition Code Control                            | DPM   | 1     | Truth tables                   | Yes    | [here](https://siliconpr0n.org/map/dec/dc610/) | WIP       | behavioural  |
 | DC611 | CON  | Console UART                                      | UBI   | 2     | Description                    |        |                                                |           |              |
 | DC612 | CLA  | Carry Look-Ahead                                  | DPM   | 1     | Equations                      | Yes    |                                                |           |              |
 | DC613 | SRM  | Shift/Rotator Multiplexer                         | DPM   | 4     | Full truth tables              | Yes    | [here](https://siliconpr0n.org/map/dec/dc613/) |           |              |
 | DC614 | SRK  | Shift/Rotator Control                             | DPM   | 1     | Full truth tables              |        |                                                |           |              |
 | DC615 | ALK  | ALU Control                                       | DPM   | 1     | Full truth tables              | Yes    | [here](https://siliconpr0n.org/map/dec/dc615/) | Completed | from netlist |
 | DC616 | SPA  | Scratchpad address control                        | DPM   | 1     | Full truth tables              | Yes    | [here](https://siliconpr0n.org/map/dec/dc616/) |           |              |
 | DC617 | SAC  | Service arbitration and control                   | DPM   | 1     | Tables, description            |        |                                                |           |              |
 | DC618 | UDP  | Unibus data path                                  | UBI   | 4     | Tables, description            |        |                                                |           |              |
 | DC619 | UCN  | Unibus control                                    | UBI   | 1     | Equations, tables, description |        |                                                |           |              |
 | DC620 | TOK  | Interval timer                                    | DPM   | 1     | Description                    |        |                                                |           |              |
 | DC621 | MSQ  | Microcode Sequencer                               | DPM   | 1     | Tables,description             |        |                                                |           |              |
 | DC622 | IRD  | Instruction Register and Decode                   | DPM   | 1     | Description, tables            | Yes    | [here](https://siliconpr0n.org/map/dec/dc622/) |           |              |
 | DC623 | CMK  | CMI bus control                                   | MIC   | 1     | Description, equations         |        |                                                |           |              |
 | DC624 | PRK  | Prefetch control                                  | MIC   | 1     | Full equations                 |        |                                                |           |              |
 | DC625 | ACV  | MMU access violation checks                       | MIC   | 1     | Tables, partial equations      |        |                                                |           |              |
 | DC626 | ADK  | Address control                                   | MIC   | 1     | Full equations                 |        |                                                |           |              |
 | DC627 | CAK  | Cache address control                             | MIC   | 1     | Full equations                 |        |                                                |           |              |
 | DC628 | UTR  | Microtrap control                                 | MIC   | 1     | Full equations, Truth tables   |        |                                                |           |              |
 | DC629 | PHB  | Practically Half the Bits                         | DPM   | 1     | Table description              |        |                                                |           |              |
 | DC630 | INT  | Interrupt control                                 | UBI   | 1     | Description, partial equations |        |                                                |           |              |
 | DC651 | CML  | CMI bus control (replaces CMK when DR750 is used) | MIC   | 0     | Not covered                    |        |                                                |           |              |


### FP750 Floating Point Unit
 | Type  | Name | Function                  | Board | Count | EK-GA750-RM | Sample | Die shot                               | Netlist   | RTL          |
 |-------|------|---------------------------|-------|-------|-------------|--------|----------------------------------------|-----------|--------------|
 | DC600 | ---- | Base chip                 | ----  | ----  | ----        | ----   |                                        |           |              |
 | DC612 | CLA  | Carry Look-Ahead          | FPA   | 2     |             | Yes    |                                        |           |              |
 | DC636 | FIO  | Fraction IO               | FPA   | 8     |             | Yes    |                                        |           |              |
 | DC637 | FCS  | Float Coarse Shifter      | FPA   | 4     |             | Yes    |                                        |           |              |
 | DC638 | FFA  | Float Fraction ALU        | FPA   | 8     |             | Yes    |                                        |           |              |
 | DC639 | FMR  | Float Multiplier Register | FPA   | 2     |             | Yes    |                                        |           |              |
 | DC641 | FEX  | Float exponent logic      | FPA   | 2     |             | Yes    |                                        |           |              |
 | DC642 | FQA  | Float Quick Aligner       | FPA   | 1     |             | Yes    |                                        |           |              |
 | DC643 | FCC  | Float condition codes     | FPA   | 1     |             | Yes    |                                        |           |              |

### MS750 Comet memory controller
 | Type  | Name | Function                | Board       | Count | EK-GA750-RM | Sample | Die shot                               | Netlist   | RTL          |
 |-------|------|-------------------------|-------------|-------|-------------|--------|----------------------------------------|-----------|--------------|
 | DC600 | ---- | Base chip               | ----        | ----  | ----        |        |                                        |           |              |
 | DC631 | MEC  | Memory error correction | CMC         | 2     | Not covered |        |                                        |           |              |
 | DC632 | MAP  | Memory address decoder? | CMC (L0011) | 4     | Not covered |        |                                        |           |              |
 | DC633 | MDL  | Memory data loop        | CMC         | 4     | Not covered |        |                                        |           |              |
 | DC650 | MAD  | Memory address decoder  | CMC (L0016) | 1     | Not covered |        |                                        |           |              |

### RH750 Massbus adapter
| Type  | Name | Function                 | Board | Count | EK-GA750-RM                    | Sample | Die shot                               | Netlist   | RTL          |
|-------|------|--------------------------|-------|-------|--------------------------------|--------|----------------------------------------|-----------|--------------|
| DC600 | ---- | Base chip                | ----  | ----  | ----                           |        |                                        |           |              |
| DC645 | MDP  | Massbus datapath         | MBA   | 8     | Description, partial equations |        |                                        |           |              |
| DC646 | MSC  | Massbus Silo control     | MBA   | 1     | Description, partial equations |        |                                        |           |              |
| DC647 | MRC  | Massbus register control | MBA   | 1     | Description, partial equations |        |                                        |           |              |
| DC648 | MDC  | Massbus datapath control | MBA   | 1     | Description, partial equations |        |                                        |           |              |
| DC649 | MCI  | Massbus CMI control      | MBA   | 1     | Full equations                 |        |                                        |           |              |

### Unknown
| Type  | Name | Function                 | Board | Count | EK-GA750-RM | Sample | Die shot                               | Netlist   | RTL          |
|-------|------|--------------------------|-------|-------|-------------|--------|----------------------------------------|-----------|--------------|
| DC601 |      |                          |       |       |             |        |                                        |           |              |
| DC602 |      |                          |       |       |             |        |                                        |           |              |
| DC603 |      |                          |       |       |             |        |                                        |           |              |
| DC604 |      |                          |       |       |             |        |                                        |           |              |
| DC605 |      |                          |       |       |             |        |                                        |           |              |
| DC634 |      |                          |       |       |             |        |                                        |           |              |
| DC635 |      |                          |       |       |             |        |                                        |           |              |
| DC640 |      |                          |       |       |             |        |                                        |           |              |
| DC644 |      |                          |       |       |             |        |                                        |           |              |

## Further documents

* MP-XXX [sic]     - Field Service 11/750 Gate Array Print Set
* [EK-GA750-RM      - Gate array reference manual](https://bitsavers.org/pdf/dec/vax/750/EK-GA750-RM-001_VAX-11_750_Gate_Array_Chip_Reference_Manual_1981.pdf)
