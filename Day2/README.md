## Day 2 - Application Binary Interface and verification flow

### Application Binary Interface (ABI)

#### Intro to ABI

![image](https://user-images.githubusercontent.com/66086031/170488080-6818b07f-3ae7-4da8-b7d3-86a21550b442.png)

- ABI is the system-call interface present between the software application and the registers of the ISA
- It can be used to access the registers through system calls

```mermaid

graph TD
A[Application-Program] -->|API| Standard-Libraries
Standard-Libraries -->|System-call| Operating-System
Operating-System -->|ISA| RISC-V-Core

A -->|ABI| RISC-V-Core
```

- There are 32 registers each of 64 bits in the RV64.

#### Memory Allocation for double words

- Memory is **byte-addressable**
- Each address contains 8 - bits (i.e.) - 1 byte
- RISC - V follows little-endian memory system.
- MSB bits have higher memory address and LSB have lower memory address

#### Load, Add and Store instructions



#### RV64I registers and their ABI Names

- Load, add and store belong to $RV64I$ base instructions.
- Load is a I-type instruction
- Add is a R-type instruction
- Store is a S-type instruction
- $rd$ is of size 5 bits => So $2^5 = 32$ registers
- Naming convention is $x0$ to $x31$


### Labs using ABI function call

#### Sum of N numbers Flowchart

```mermaid
graph TD;
S[Start a0 = 0, a1 = count] --> M[temp variable, a4 = 0]
M --> R[incrementing variable, a3 = 0]
R --> N[Store count in a2]
N --> Q[a4 = a3 + a4]
Q --> I[a3 = a3 + 1]
I --> D{Is a3 < a2 ?}
D -->|yes| Q
D -->|no| F[a0 = a4 + zero]
F --> End
```

- Value of a0 is returned to the main program.

#### Assembly Function Call

##### Assembly code for the sum of N

```assembly
.section .text
.global load
.type load, @function

load:
  add a4, a0, zero // a4 - sum register
  add a2, a0, a1   // a2 - count register, n
  add a3, a0, zero // a3 - intermediate register, i
  
loop:
  add a4, a3, a4 // add a3 to a4 every loop
  add a3, a3, 1  // increment a3 by 1
  blt a3, a2, loop // loop back as long as i < n
  add a0, a4, zero // store result in a0
  ret  
```

##### C program to call the assembly code

```c
#include <stdio.h>

extern int load(int x, int y);

int main () {
 int result = 0;
 int count = 10;
 result = load(0x0, count+1);
 printf("Sum of numbers from 1 to %d is %d\n", count, result);
 return 0;
} 
```

![image](https://user-images.githubusercontent.com/66086031/170498879-1920ab36-96c5-41c2-b347-5423c969d997.png)

##### Compiling through a RISC-V core

```console
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sumof_N.o sumof_N.c load.S
spike pk sumof_N.o
```

![image](https://user-images.githubusercontent.com/66086031/170499741-88729f95-264c-4b93-9d11-c9de044a5533.png)

### Passing the C program as a HEX file

```mermaid
graph LR;

Memory --> RISC-V
RISC-V --> R[Display the result]

```

```console
git clone https://github.com/kunalg123/riscv_workshop_collaterals.git
```

```console
chmod 377 rv32im.sh
./rv32im.sh
```

- The instructions that we want to run are passed as HEX files into the RISC - V core

![image](https://user-images.githubusercontent.com/66086031/170502881-b3b81525-44fd-4bf0-b972-2e8a5425dcaf.png)
