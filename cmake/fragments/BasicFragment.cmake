# cmake file

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${PROJECT_NAME})
endif()

if(COMMAND AttachBasicBitcodeGenPipeline)
  AttachBasicBitcodeGenPipeline(${PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${PROJECT_NAME})
endif()

if(COMMAND ApplyIOAttributePipeline)
  ApplyIOAttributePipeline(${PROJECT_NAME})
endif()

