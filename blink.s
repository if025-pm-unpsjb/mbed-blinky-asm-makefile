/* Select the target processor. */
.cpu cortex-m3

/* Generate Thumb instructions. This performs the same action as .code 16 */
.thumb

/* nvic -- vector interrupt table */
.section ".isr_vector"
.word   0x10008000  /* stack top address */
.word   _start      /* 1  Reset */
.word   hang        /* 2  NMI */
.word   hang        /* 3  HardFault */
.word   hang        /* 4  MemManage */
.word   hang        /* 5  BusFault */
.word   hang        /* 6  UsageFault */
.word   hang        /* 7  RESERVED */
.word   hang        /* 8  RESERVED */
.word   hang        /* 9  RESERVED*/
.word   hang        /* 10 RESERVED */
.word   hang        /* 11 SVCall */
.word   hang        /* 12 Debug Monitor */
.word   hang        /* 13 RESERVED */
.word   hang        /* 14 PendSV */
.word   hang        /* 15 SysTick */

/* This directive indicates to assemble the following code into a the section
name. See the flash.ld file for section layout. */
.section ".text"

/* The .thumb_func directive specifies that the following symbol is the name
of a Thumb encoded function. */
.thumb_func
hang:
   b    .                  // ~ while( true )

/* Perform a busy waiting. */
.thumb_func
dowait:
   ldr  r7, =0xA000        // store 0xA0000 in the r7 register
dowaitloop:
   sub  r7, #1             // substract 1 from the value in r7
   bne  dowaitloop         // if r7 != 0, goto dowaitloop
   bx   lr                 // return

/* .globl makes the symbol visible to ld */
.thumb_func
.globl _start
_start:
   ldr  r0, =0x2009C022    // load memory address 0x2009C022 into r0 register,
                           // this is the port direction register FIO1DIR2, see
                           // page 134 in LPC17xx manual.

   ldrb r1, [r0]           // load in r1 the value store in the memory address
                           // [r0], with immediate offset (unsigned byte).

   mov  r2, #0x04          // store the value 0x0000100 in r2, this value is used
                           // to change the direction mode of the GPIOs pins
                           // into which the mbed LPC1768 LED1 is connected.

   orr  r1, r2             // logical OR between r1 and r2 registers.

   strb r1, [r0]           // store register r1 value into memory adress [r0].

   ldr  r0, =0x2009C03A    // set gpio (FIO1SET2, page 135 in LPC17xx manual)

   ldr  r1, =0x2009C03E    // clear gpio (FIO1CLR2, page 136 in LPC17xx manual)

   mov  r2, #0x04          // store the value 0100 in r2

mainloop:
   strb r2, [r0]           // store the value in r2 in the memory address [r0]
   bl dowait               // execute dowait
   strb r2, [r1]           // store the value in r2 in the memory address [r1]
   bl   dowait             // execute dowait
   b    mainloop           // goto mainloop

.end
