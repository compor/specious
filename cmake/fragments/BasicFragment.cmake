# cmake file

if(COMMAND BmkBasicInstall)
  BmkBasicInstall(${BMK_PROJECT_NAME})
endif()

if(COMMAND BasicBitcodeGenPipeline)
  BasicBitcodeGenPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND LoopC14NPipeline)
  LoopC14NPipeline(${BMK_PROJECT_NAME})
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

if(COMMAND AnnotateLoopsPipeline)
  AnnotateLoopsPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND ClassifyLoopsPipeline)
  ClassifyLoopsPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND ClassifyLoopsWithIdPipeline)
  ClassifyLoopsWithIdPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND SimplifyLoopExitsPipeline)
  SimplifyLoopExitsPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND SimplifyLoopExitsFrontPipeline)
  SimplifyLoopExitsFrontPipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND ClassifyLoopsWithId2Pipeline)
  ClassifyLoopsWithId2Pipeline(${BMK_PROJECT_NAME})
endif()

if(COMMAND SimplifyLoopExitsFrontIterativePipeline)
  SimplifyLoopExitsFrontIterativePipeline(${BMK_PROJECT_NAME})
endif()
