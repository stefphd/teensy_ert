/*
 *
 * Abstract:
 *      Arduino External Interrupt Block.
 *
 */

#define S_FUNCTION_NAME     sfunar_extInt
#define S_FUNCTION_LEVEL    2

#define MODE            (ssGetSFcnParam(S,0))
#define PRIORITY        (ssGetSFcnParam(S,1))
#define PINMODE         (ssGetSFcnParam(S,2))
#define PIN             (ssGetSFcnParam(S,3))
#define SIMULATION      (ssGetSFcnParam(S,4))
#define TIMER           (ssGetSFcnParam(S,5))

#include "simstruc.h"

#ifndef MATLAB_MEX_FILE
/* Since we have a target file for this S-function, declare an error here
 * so that, if for some reason this file is being used (instead of the
 * target file) for code generation, we can trap this problem at compile
 * time. */
#  error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    int_T priority  = (int_T) (*(mxGetPr(PRIORITY)));

    /* Check priority */
    if( priority < 0 || priority > 255 ) {
        ssSetErrorStatus(S, "Priority must be 0-255.");
	return;
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    int_T priority;

    ssSetNumSFcnParams(S, 6);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
    ssSetSFcnParamNotTunable( S, 0);
    ssSetSFcnParamNotTunable( S, 1);
    ssSetSFcnParamNotTunable( S, 2);
    ssSetSFcnParamNotTunable( S, 3);
    ssSetSFcnParamNotTunable( S, 4);
    ssSetSFcnParamNotTunable( S, 5);

    /* Check if we need simulation trigger input */
    if( (int_T)(*(mxGetPr(SIMULATION))) != 0){
        ssSetNumInputPorts(       S, 1);
        ssSetInputPortWidth(      S, 0, 1);
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortDataType(   S, 0, SS_UINT8);
    }else{
        ssSetNumInputPorts(       S, 0);
    }

    ssSetNumOutputPorts(      S, 1);
    ssSetOutputPortWidth(     S, 0, 1);
    /* All output elements are function-call, so we can set the data type of the
     * entire port to be function-call. */
    ssSetOutputPortDataType(  S, 0, SS_FCN_CALL);
    ssSetNumIWork(            S, 0);
    ssSetNumRWork(            S, 0);
    ssSetNumPWork(            S, 0);
    ssSetNumSampleTimes(      S, 1);
    ssSetNumContStates(       S, 0);
    ssSetNumDiscStates(       S, 0);
    ssSetNumModes(            S, 0);
    ssSetNumNonsampledZCs(    S, 0);

    priority  = (int_T) (*(mxGetPr(PRIORITY)));
    ssSetAsyncTaskPriorities(S, 1, &priority);

    ssSetOptions(             S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                  SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME |
                                  SS_OPTION_ASYNCHRONOUS_INTERRUPT ));

    /* Block has not internal states. Need change SimStateCompliance setting
     * if new state is added */
    ssSetSimStateCompliance(S, HAS_NO_SIM_STATE);

   /* Setup Async Timer attributes */
    if( (int_T)(*(mxGetPr(TIMER))) != 0){   // true if you have your own timer like "millis()"
        ssSetTimeSource(S, SS_TIMESOURCE_SELF);
        ssSetAsyncTimerAttributes(S, 1.0/1e3);  // Timer resolution

        /* Setup async timer clockTick word length */
        ssSetAsyncTimerDataType(S, SS_UINT32);  // Timer data type
    } else {
         ssSetTimeSource(S, SS_TIMESOURCE_BASERATE);
    }
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetCallSystemOutput(S, 0);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
     if (ssGetNumInputPorts(S) == 0) {
         /* Call subsystem with base rate */
         ssCallSystemWithTid(S, 0, tid);
     }
     else{
        InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S, 0);
        InputUInt8PtrsType pU  = (InputUInt8PtrsType)uPtrs;
        if(*pU[0] != 0U) {
            /* Call subsystem only when input signal is "true" */
            ssCallSystemWithTid(S, 0, tid);
        }
     }
}

static void mdlTerminate(SimStruct *S)
{
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int32_T prio   = (int32_T) mxGetPr(PRIORITY)[0];
    int32_T pin = (int32_T) mxGetPr(PIN)[0];

    if (!ssWriteRTWParamSettings(S, 4,
                    SSWRITE_VALUE_STR,        "Mode",       mxArrayToString(MODE),
                    SSWRITE_VALUE_DTYPE_NUM,  "Priority",   &prio, DTINFO(SS_INT32, COMPLEX_NO),
                    SSWRITE_VALUE_STR,        "Pinmode",    mxArrayToString(PINMODE),
                    SSWRITE_VALUE_DTYPE_NUM,  "Pin",        &pin, DTINFO(SS_INT32, COMPLEX_NO)
                    ))
    {
            ssSetErrorStatus(S,"ssWriteRTWParamSettings error in mdlRTW");
            return;
    }
}

#ifdef MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif

/* EOF: sfunar_extInt.c*/
