/* Copyright 2013-2014 The MathWorks, Inc. */
/*
 *   sfunar_WireConfig.c Simple C-MEX S-function for function call.
 *
 */

/*
 * Must specify the S_FUNCTION_NAME as the name of the S-function.
 */
#define S_FUNCTION_NAME                sfunar_WireConfig
#define S_FUNCTION_LEVEL               2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#define EDIT_OK(S, P_IDX) \
 (!((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ssGetSFcnParam(S, P_IDX))))
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)

#define PORT    ssGetSFcnParam(S, 0)
#define MASTER  ssGetSFcnParam(S, 1)
#define ADDRESS ssGetSFcnParam(S, 2)
#define INIT    ssGetSFcnParam(S, 3)
 
 
/* Function: mdlCheckParameters ===========================================
 * Abstract:
 *    mdlCheckParameters verifies new parameter settings whenever parameter
 *    change or are re-evaluated during a simulation. When a simulation is
 *    running, changes to S-function parameters can occur at any time during
 *    the simulation loop.
 */
static void mdlCheckParameters(SimStruct *S)
{

  /*
   * Check the parameter 2
   */
  if EDIT_OK(S, 1) {
    int_T dimsArray[2] = { 1, 1 };

    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 1, "P2", DYNAMICALLY_TYPED, 2, dimsArray, 0);
  }

  /*
   * Check the parameter 3
   */
  
  if EDIT_OK(S, 2) {
    int_T dimsArray[2] = { 1, 1 };

    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 2, "P3", DYNAMICALLY_TYPED, 2, dimsArray, 0);
  }
    
  /*
   * Check the parameter 4
   */

  if EDIT_OK(S, 3) {
    int_T *dimsArray = (int_T *) mxGetDimensions(INIT);
 
     if(dimsArray[0] != 0){
         /* Parameter 3 must be a vector */
         if ((dimsArray[0] > 1) && (dimsArray[1] > 1)) {
          ssSetErrorStatus(S,"Parameter 4 must be a vector");
          return;
         }
    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 3, "P4", DYNAMICALLY_TYPED, 2, dimsArray, 0);
    }
    
  }
 
 }

#endif


#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    uint32_T init[32];
    int32_T i, n;
    
    n = mxGetNumberOfElements(INIT);
    if(n > (sizeof(init)/sizeof(init[0]))){
        ssSetErrorStatus(S,"Maximum size of slave init code reached."); 
    }

    for(i=0;i<n;i++){
        init[i] = (uint32_T) mxGetPr(INIT)[i];
    }
    
    if (!ssWriteRTWParamSettings(S, 2,
                    SSWRITE_VALUE_DTYPE_VECT,   "Init",   init, n, DTINFO(SS_UINT32, COMPLEX_NO),
                    SSWRITE_VALUE_STR,          "Port",   mxArrayToString(PORT)))
    {
            ssSetErrorStatus(S,"ssWriteRTWParamSettings error in mdlRTW"); 
            return;
    }
}
 
 
/* Function: mdlInitializeSizes ===========================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int32_T n;
    int32_T priority;
    
  /* Number of expected parameters */
  ssSetNumSFcnParams(S, 4);

#if defined(MATLAB_MEX_FILE)

  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
    /*
     * If the number of expected input parameters is not equal
     * to the number of parameters entered in the dialog box return.
     * Simulink will generate an error indicating that there is a
     * parameter mismatch.
     */
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) {
      return;
    }
  } else {
    /* Return if number of expected != number of actual parameters */
    return;
  }

#endif

  /* Set the parameter's tunable status */
  ssSetSFcnParamTunable(S, 0, SS_PRM_NOT_TUNABLE);
  ssSetSFcnParamTunable(S, 1, SS_PRM_NOT_TUNABLE);
  ssSetSFcnParamTunable(S, 2, SS_PRM_NOT_TUNABLE);
  ssSetSFcnParamTunable(S, 3, SS_PRM_NOT_TUNABLE);

    ssSetNumIWork(            S, 0);
    ssSetNumRWork(            S, 0);
    ssSetNumPWork(            S, 0);
    ssSetNumContStates(       S, 0);
    ssSetNumDiscStates(       S, 0);
    ssSetNumModes(            S, 0);
    ssSetNumNonsampledZCs(    S, 0);

  if (!ssSetNumDWork(S, 0))
    return;

  /*
   * Set the number of input ports.
   */
  if (!ssSetNumInputPorts(S, 0))
    return;

  /*
   * Set the number of output ports.
   */
  n = (int32_T) mxGetPr(MASTER)[0];
  if( n != 1){  // Slave configuration
   if (!ssSetNumOutputPorts(S, 1))
      return;

    ssSetOutputPortWidth(     S, 0, 1);
    /* All output elements are function-call, so we can set the data type of the
     * entire port to be function-call. */
    ssSetOutputPortDataType(  S, 0, SS_FCN_CALL);
  }

  /*
   * This S-function can be used in referenced model simulating in normal mode.
   */
  ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);

  /*
   * Set the number of sample time.
   */
  ssSetNumSampleTimes(S, 1);


    if( n != 1){
        priority  = 39; //(int_T) (*(mxGetPr(PRIORITY)));
        ssSetAsyncTaskPriorities(S, 1, &priority);
        
        ssSetOptions(             S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                  SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME |
                                  SS_OPTION_ASYNCHRONOUS_INTERRUPT ));

        /* Block has not internal states. Need change SimStateCompliance setting
         * if new state is added */
        ssSetSimStateCompliance(S, HAS_NO_SIM_STATE);
        ssSetTimeSource(S, SS_TIMESOURCE_BASERATE);
    }
    else {
    
    ssSetOptions(S,
               //SS_OPTION_USE_TLC_WITH_ACCELERATOR |
               SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
               SS_OPTION_EXCEPTION_FREE_CODE |
               SS_OPTION_WORKS_WITH_CODE_REUSE |
               SS_OPTION_SFUNCTION_INLINED_FOR_RTW |
               SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME );
    }
}

/* Function: mdlInitializeSampleTimes =====================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
  ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
  if((int32_T) mxGetPr(MASTER)[0] != 1){
    ssSetCallSystemOutput(S, 0);
  }
  else{
#if defined(ssSetModelReferenceSampleTimeDefaultInheritance)
  ssSetModelReferenceSampleTimeDefaultInheritance(S);
#endif
  }
}

#define MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)

/* Function: mdlSetWorkWidths =============================================
 * Abstract:
 *      The optional method, mdlSetWorkWidths is called after input port
 *      width, output port width, and sample times of the S-function have
 *      been determined to set any state and work vector sizes which are
 *      a function of the input, output, and/or sample times.
 *
 *      Run-time parameters are registered in this method using methods
 *      ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
  /* Set number of run-time parameters */
  if (!ssSetNumRunTimeParams(S, 2))
    return;

  /*
   * Register the run-time parameter 1
   */
  ssRegDlgParamAsRunTimeParam(S, 1, 0, "p1", ssGetDataTypeId(S, "uint8"));

  /*
   * Register the run-time parameter 2
   */
  ssRegDlgParamAsRunTimeParam(S, 2, 1, "p2", ssGetDataTypeId(S, "uint8"));
}

#endif

#define MDL_START
#if defined(MDL_START)

/* Function: mdlStart =====================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
    UNUSED_PARAMETER(S);
}

#endif

/* Function: mdlOutputs ===================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector(s),
 *    ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
     if (ssGetNumOutputPorts(S) != 0) {
         /* Call subsystem with base rate */
         ssCallSystemWithTid(S, 0, tid);
     }
}

/* Function: mdlTerminate =================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_PARAMETER(S);
}

/*
 * Required S-function trailer
 */
#ifdef MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif
