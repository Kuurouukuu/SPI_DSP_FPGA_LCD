/*
 * main.c
 *
 *  Created on: Aug 28, 2020
 *      Author: Nguyen Huynh DUc
 */

#include "DSP28_Device.h"
#include <string.h>
#include <stdbool.h>
#include <math.h>


//extern unsigned long inputNumberValue;
//extern unsigned char inputAsciiValue[10];

//Variable mapped to FPGA, used to send data
unsigned int * AsciiValue1 = (unsigned int *) 0x4000 ;
unsigned int * AsciiValue2 = (unsigned int *) 0x4100 ;
unsigned int * AsciiValue3 = (unsigned int *) 0x4200 ;
unsigned int * AsciiValue4 = (unsigned int *) 0x4300 ;

//Variable to store received value
char AsciiValue[4] = "xxx";
char * tempStr;

interrupt void TXAISR(void);
interrupt void RXAISR(void);

void printRequestString(const char * requestString);
void printInfoString(const char * infoString);


bool isGetNumDataFlag;

unsigned int numOfTenth = 0;
char rxValue = 68;
unsigned int index = 0;


void main(void)
{
    InitSysCtrl();
    //Initialize watchdog, PLL, HSPCLK, LSPCLK

    DINT; // Disable Global Interrupt
    IER = 0x0000; // Disable all peripheral INT
    IFR = 0x0000; // Clear all Peripheral interrupt flag

    InitPieCtrl(); // Disable all PIE interrupt, clear all PIE Flag, Enable PIE and Clear all PIEACK (by set the according bit)

    InitPieVectTable(); // Initialize PieVectTable to the known state, that is the default ISR for all the interrupt

    InitPeripherals(); // Initialize peripherals (set up the value in the control register) of desired peripherals.
    // In this part, we use GPIO (to control the MUXING) and SCI (to use serial communication).

    EALLOW; // To edit EALLOW protected registers
    PieVectTable.TXAINT = &TXAISR;
    PieVectTable.RXAINT = &RXAISR;
    EDIS;

    IER |= M_INT9; // Enable Peripheral Interrupt group 9 which contains TX and RX interrupt

    EINT; //enable global interrupt

    tempStr = "Enter number: ";
    printRequestString(tempStr);

    while(1)
    {

        if (isGetNumDataFlag)
        {
            SciaRegs.SCICTL2.all = 0x03; //Enable both TXINT and RXINT
        }
        else
        {
            SciaRegs.SCICTL2.all = 0x01; // Disable RXINT, no need to get data
        }

    }
}

interrupt void TXAISR(void)
{
    PieCtrl.PIEACK.bit.ACK9 = 1; // Clear ACK (by write 1 into ack regs ) to enable other interrupt in group 9
}

interrupt void RXAISR(void)
{
    PieCtrl.PIEACK.bit.ACK9 = 1; // Clear ACK (by write 1 into ack regs ) to enable other interrupt in group 9
    if (isGetNumDataFlag)
    {
        if (SciaRegs.SCIRXBUF.all == 13 || numOfTenth == 4) // CR to end, only get 4 characters
        {
            rxValue = SciaRegs.SCIRXBUF.all; // Read dummy data
            isGetNumDataFlag = false;
            numOfTenth = 0;
            printInfoString("Done"); // Print the string then
            *AsciiValue1 = (0x00FF) & AsciiValue[0];
            *AsciiValue2 = (0x00FF) & AsciiValue[1];
            *AsciiValue3 = (0x00FF) & AsciiValue[2];
            *AsciiValue4 = (0x00FF) & AsciiValue[3];
        }
        else
        {
            rxValue = SciaRegs.SCIRXBUF.all; // TODO: consider timing in ISR here

            //inputNumberValue = (inputNumberValue * pow(10, numOfTenth)) + (SciaRegs.SCIRXBUF.all - 0x30);
            //inputAsciiValue[numOfTenth] = SciaRegs.SCIRXBUF.all;

            AsciiValue[numOfTenth] = rxValue;
            numOfTenth++; // ASCII to decimal
            SciaRegs.SCITXBUF = SciaRegs.SCIRXBUF.all; // Echo back the value to PC through SCI;
        }
    }

}

void printRequestString(const char * requestString)
{
    size_t temp = strlen(requestString);
    for (index = 0; index < temp; index++)
    {
        while (!SciaTx_Ready()); // No ops
        SciaRegs.SCITXBUF = requestString[index];
    }
    isGetNumDataFlag = true;
}

void printInfoString(const char * infoString)
{
    for (index = 0; index < strlen(infoString); index++)
    {
        while (!SciaTx_Ready()); // No ops
        SciaRegs.SCITXBUF = infoString[index];
    }
}

