//
//      TMDX ALPHA RELEASE
//      Intended for product evaluation purposes
//
//###########################################################################
//
// FILE:	DSP28_SysCtrl.c
//
// TITLE:	DSP28 Device System Control Initialization & Support Functions.
//
//###########################################################################
//
//  Ver | dd mmm yyyy | Who  | Description of changes
// =====|=============|======|===============================================
//  0.55| 06 May 2002 | L.H. | EzDSP Alpha Release
//  0.56| 20 May 2002 | L.H. | No change
//  0.57| 24 May 2002 | L.H. | Added initialization of RAM control registers
//      |             |      | for TMX samples.
//###########################################################################


#include "DSP28_Device.h"

//---------------------------------------------------------------------------
// InitSysCtrl: 
//---------------------------------------------------------------------------
// This function initializes the System Control registers to a known state.
//
void InitSysCtrl(void)
{
   Uint16 i;
   EALLOW;
   
// On TMX samples, to get the best performance of on chip RAM blocks M0/M1/L0/L1/H0 internal
// control registers bit have to be enabled. The bits are in Device emulation registers.
   DevEmuRegs.M0RAMDFT = 0x0300;
   DevEmuRegs.M1RAMDFT = 0x0300;
   DevEmuRegs.L0RAMDFT = 0x0300;
   DevEmuRegs.L1RAMDFT = 0x0300;
   DevEmuRegs.H0RAMDFT = 0x0300;
   
           
// Disable watchdog module
   SysCtrlRegs.WDCR= 0x0068;

// Initalize PLL
   SysCtrlRegs.PLLCR = 0xA;///150M
   // Wait for PLL to lock
   for(i= 0; i< 5000; i++){}
       
// HISPCP/LOSPCP prescale register settings, normally it will be set to default values
   SysCtrlRegs.HISPCP.all = 0x0001;
   SysCtrlRegs.LOSPCP.all = 0x0002;	
// Peripheral clock enables set for the selected peripherals.   
//   SysCtrlRegs.PCLKCR.bit.EVAENCLK=1;
//   SysCtrlRegs.PCLKCR.bit.EVBENCLK=1;
   SysCtrlRegs.PCLKCR.bit.SCIENCLKA=1;
// SysCtrlRegs.PCLKCR.bit.SCIENCLKB=1;
  SysCtrlRegs.PCLKCR.bit.SPIENCLK=1;
				
   EDIS;
	
}

//---------------------------------------------------------------------------
// KickDog: 
//---------------------------------------------------------------------------
// This function resets the watchdog timer.
// Enable this function for using KickDog in the application 

void KickDog(void)
{
    EALLOW;
    SysCtrlRegs.WDKEY = 0x0055;
    SysCtrlRegs.WDKEY = 0x00AA;
    EDIS;
}
		

//===========================================================================
// No more.
//===========================================================================
