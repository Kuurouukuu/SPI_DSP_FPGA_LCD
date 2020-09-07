//
//      TMDX ALPHA RELEASE
//      Intended for product evaluation purposes
//
//###########################################################################
//
// FILE:	DSP28_Spi.c
//
// TITLE:	DSP28 SPI Initialization & Support Functions.
//
//###########################################################################
//
//  Ver | dd mmm yyyy | Who  | Description of changes
// =====|=============|======|===============================================
//  0.55| 06 May 2002 | L.H. | EzDSP Alpha Release
//  0.56| 20 May 2002 | L.H. | No change
//  0.57| 27 May 2002 | L.H. | No change
//###########################################################################

#include "DSP28_Device.h"

//---------------------------------------------------------------------------
// InitSPI: 
//---------------------------------------------------------------------------
// This function initializes the SPI(s) to a known state.
//
void InitSpi(void)
{

    /*Configure control register settings*/
	SpiaRegs.SPICCR.all = 0x08;///Enter the initial state, data is output on the rising edge, self-test is prohibited, 8-bit data mode
	/*Operation control register settings*/
	SpiaRegs.SPICTL.all = 0x06;///Normal SPI clock mode, active mode, enable transmission, disable interrupt
	/*波特率的设置*/
	SpiaRegs.SPIBRR = 0x1D;//Baud rate = LSPCLK/（SPIBRR+1）= 30/30 = 1M
	
	SpiaRegs.SPICCR.all = 0x8a; //Exit the initial state
	

//	PieCtrl.PIEIER6.bit.INTx1 = 1;
//	PieCtrl.PIEIER6.bit.INTx2 = 1;
	//tbd...
	//tbd...
	
}

unsigned int Spi_TxReady(void)
{
	unsigned int i;
	if(SpiaRegs.SPISTS.bit.BUFFULL_FLAG == 1)////According to whether the buffer flag bit of the SPI status register is full, to determine whether the sending function is available, you can check it yourself when learning
	{
		i = 0;
	}
	else
	{
		i = 1;
	}
	return(i);
}

unsigned int Spi_RxReady(void)
{
	unsigned int i;
	if(SpiaRegs.SPISTS.bit.INT_FLAG == 1)
	{
		i = 1;
	}
	else
	{
		i = 0;
	}
	return(i);	
}

/*SPI interrupt service register. Not used in this experiment*/

interrupt void SPIRXINTA_ISR(void);   // SPI
interrupt void SPITXINTA_ISR(void);    // SPI
	
//===========================================================================
// No more.
//===========================================================================
