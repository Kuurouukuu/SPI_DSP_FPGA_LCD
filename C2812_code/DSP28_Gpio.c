//
//      TMDX ALPHA RELEASE
//      Intended for product evaluation purposes
//
//###########################################################################
//
// FILE:	DSP28_Gpio.c
//
// TITLE:	DSP28 General Purpose I/O Initialization & Support Functions.
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
// InitGpio: 
//---------------------------------------------------------------------------
// This function initializes the Gpio to a known state.
//
void InitGpio(void)
{
  EALLOW;
     ///设置SPI口外设功能，这里我们只用了SPISIMO和SPICLK
     GpioMuxRegs.GPFMUX.bit.SPISIMOA_GPIOF0 = 1;
     ///GpioMuxRegs.GPFMUX.bit.SPISOMIA_GPIOF1 = 1;
     GpioMuxRegs.GPFMUX.bit.SPICLKA_GPIOF2  = 1;
     ///GpioMuxRegs.GPFMUX.bit.SPISTEA_GPIOF3  = 1;
     	 
     EDIS;
}	
	
//===========================================================================
// No more.
//===========================================================================
