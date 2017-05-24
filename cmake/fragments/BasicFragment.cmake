# cmake file

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${BMK_PROJECT_NAME})
endif()

if(COMMAND AttachBasicBitcodeGenPipeline)
  AttachBasicBitcodeGenPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND ApplyIOAttributePipeline)
  ApplyIOAttributePipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND PropagateAttributesPipeline)
  PropagateAttributesPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND MixedPropagateAttributesPipeline)
  MixedPropagateAttributesPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND SimplifyLoopExitsPipeline)
  SimplifyLoopExitsPipeline(${BMK_PROJECT_NAME})
endif()
