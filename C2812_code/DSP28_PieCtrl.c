//
//      TMDX ALPHA RELEASE
//      Intended for product evaluation purposes
//
//###########################################################################
//
// FILE:	DSP28_PieCtrl.c
//
// TITLE:	DSP28 Device PIE Control Register Initialization Functions.
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
// InitPieCtrl: 
//---------------------------------------------------------------------------
// This function initializes the PIE control registers to a known state.
//
void InitPieCtrl(void)
{
	// Disable PIE:
	PieCtrl.PIECRTL.bit.ENPIE = 0;

	// Clear all PIEIER registers:
	PieCtrl.PIEIER1.all = 0;
	PieCtrl.PIEIER2.all = 0;
	PieCtrl.PIEIER3.all = 0;	
	PieCtrl.PIEIER4.all = 0;
	PieCtrl.PIEIER5.all = 0;
	PieCtrl.PIEIER6.all = 0;
	PieCtrl.PIEIER7.all = 0;
	PieCtrl.PIEIER8.all = 0;
	PieCtrl.PIEIER9.all = 0;
	PieCtrl.PIEIER10.all = 0;
	PieCtrl.PIEIER11.all = 0;
	PieCtrl.PIEIER12.all = 0;

	// Clear all PIEIFR registers:
	PieCtrl.PIEIFR1.all = 0;
	PieCtrl.PIEIFR2.all = 0;
	PieCtrl.PIEIFR3.all = 0;	
	PieCtrl.PIEIFR4.all = 0;
	PieCtrl.PIEIFR5.all = 0;
	PieCtrl.PIEIFR6.all = 0;
	PieCtrl.PIEIFR7.all = 0;
	PieCtrl.PIEIFR8.all = 0;
	PieCtrl.PIEIFR9.all = 0;
	PieCtrl.PIEIFR10.all = 0;
	PieCtrl.PIEIFR11.all = 0;
	PieCtrl.PIEIFR12.all = 0;

	// Enable PIE:
	PieCtrl.PIECRTL.bit.ENPIE = 1;
	PieCtrl.PIEACK.all = 0xFFFF;
}	

//===========================================================================
// No more.
//===========================================================================
