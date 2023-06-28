--Setup all the modules needed for the computer and control panel

--Each Fluid Container/Buffer has the following:
-- - a valve on the input side
-- - a 2 position switch
-- - an indicator light
-- - a micro LED screen to display how full it is
-- - a guage to display the flow of steam into the buffer


controlPanel = component.proxy("3AD3518A4058C87D99DE69B3A31A1065")
computer = component.proxy("C1393A074F7CD4EB5CB26BAAD70C10B9")

--text displays on the control panel
screenL = controlPanel:getModule()
screenR = controlPanel:getModule()

--luid Buffer 1
buffer1 = component.proxy("0542909A4C300E9013608885CB5A7009")
bufferIndicator1 = controlPanel:getModule(0,5,0)
buffer1LEDScreen = controlPanel:getModule(0,2,0)
bufferSwitch1 = controlPanel:getModule(0,4,0)
bufferFlowValve1 = component.proxy("6FE9C34F442BE616C508DB9B7B41D3CD")
bufferFlowGauge1 = controlPanel:getModule(0,1,0)
bufferFlowGauge1.limit = 1.0

--Fluid Buffer 2
buffer2 = component.proxy("3B065525406973657944079363AFD762")
bufferIndicator2 = controlPanel:getModule(1,5,0)
buffer2LEDScreen = controlPanel:getModule(1,2,0)
bufferSwitch2 = controlPanel:getModule(1,4,0)
bufferFlowValve2 = component.proxy("C9B30B244A2865ED142F8C96ACCCE68C")
bufferFlowGauge2 = controlPanel:getModule(1,1,0)
bufferFlowGauge2.limit = 1.0

--Fluid Buffer 2
buffer3 = component.proxy("83D308C14E6E1F689B9AA7AA9975A77B")
bufferIndicator3 = controlPanel:getModule(2,5,0)
buffer3LEDScreen = controlPanel:getModule(2,2,0)
bufferSwitch3 = controlPanel:getModule(2,4,0)
bufferFlowValve3 = component.proxy("B6C0E2AE4CDFBC7EC030FFB676CF8981")
bufferFlowGauge3 = controlPanel:getModule(2,1,0)
bufferFlowGauge3.limit = 1.0

--lever switch & indicator
manFlushSafety = controlPanel:getModule(3,4,0)
manFlushIndicator = controlPanel:getModule(3,5,0)
manFlushIndicator:setColor(0,0,0,0)
manFlushLEDScreen = controlPanel:getModule(4,5,0)

--the Valve for releasing the excess to more turbines/generators & a guage/LED screen combo on the control panel
valveOverflow = component.proxy("48B15DC640BE87DA828CBB9B089BBAD5")
valveLEDScreen = controlPanel:getModule(7,2,0)
valveOverflowGauge = controlPanel:getModule(7,3,0)

--a stop button to use for manually emptying the fluid buffers if needed
flushBtn = controlPanel:getModule(4,3,0)

--primary function used to let the system automatically open and close the valve; also allows for manually flushing the buffers
function autoMode()
 buffer1Content = math.ceil(buffer1.fluidContent)
 buffer2Content = math.ceil(buffer2.fluidContent)
 buffer3Content = math.ceil(buffer3.fluidContent)
 maxBufferContent = math.floor(buffer1.maxFluidContent)
 b1p = (buffer1Content / maxBufferContent)
 b2p = (buffer2Content / maxBufferContent)
 b3p = (buffer3Content / maxBufferContent)
 capTarget = 0.75

 local flushing = true
 local shouldOpenValve

 if b1p >= capTarget
 then
  shouldOpenValve = true
 elseif b2p >= capTarget
 then
  shouldOpenValve = true
 elseif b3p >= capTarget
 then
  shouldOpenValve = true
 else
  shouldOpenValve = false
 end

 if s == flushBtn and (buffer1Bool == true and buffer2Bool == true and buffer3Bool == true and manFlushSafety.state == true)
 then --trigger the buffers to get flushed
  buffer1:flush()
  buffer2:flush()
  buffer3:flush()
 end
   
--update some UI on the control panel
 if shouldOpenValve
 then
  --print("valve should open")
  flushing = true
  manFlushLEDScreen:setText("Flushing...")
  valveLEDScreen:setText("Open")
  valveOverflow.userflowLimit = 150
  valveOverflowGauge.percent = 1
 else
  --print("valve should be closed")
  flushing = false
  valveLEDScreen:setText("Closed")
  valveOverflowGauge.percent = 0
  valveOverflow.userflowLimit = 0
 end
end

--code that manipulates the control panel components
local buffer1Bool = false
local buffer2Bool = false
local buffer3Bool = false
local bufferFull = false

while true do
 buffer1LEDScreen:setText(math.ceil(buffer1.fluidContent))
 buffer2LEDScreen:setText(math.ceil(buffer2.fluidContent))
 buffer3LEDScreen:setText(math.ceil(buffer3.fluidContent))
 bufferFlowGauge1.percent = bufferFlowValve1.flow
 bufferFlowGauge2.percent = bufferFlowValve2.flow
 bufferFlowGauge3.percent = bufferFlowValve3.flow
 
 autoMode()

 
 event.listen(bufferSwitch1, bufferSwitch2, bufferSwitch3, manFlushSafety, buffer1, buffer2, buffer3, flushBtn)
 e, s = event.pull(0.0)
 if s == bufferSwitch3 and bufferSwitch3.state == true
 then
  bufferSwitch3:setColor(1,1,1,2)
  bufferIndicator3:setColor(1,0,0,1)
  buffer3Bool = true
 elseif s == bufferSwitch3 and bufferSwitch3.state == false
 then
  bufferSwitch3:setColor(0,0,0,1)
  bufferIndicator3:setColor(1,0,0,0)
  buffer3Bool = false
 elseif s == bufferSwitch1 and bufferSwitch1.state == true
 then
  bufferSwitch1:setColor(1,1,1,2)
  bufferIndicator1:setColor(1,0,0,1)
  buffer1Bool = true
 elseif s == bufferSwitch1 and bufferSwitch1.state == false
 then
  bufferSwitch1:setColor(0,0,0,1)
  bufferIndicator1:setColor(1,0,0,0)
  buffer1Bool = false
 elseif s == bufferSwitch2 and bufferSwitch2.state == true
 then
  bufferSwitch2:setColor(1,1,1,2)
  bufferIndicator2:setColor(1,0,0,1)
  buffer2Bool = true
 elseif s == bufferSwitch2 and bufferSwitch2.state == false
 then
  bufferSwitch2:setColor(0,0,0,1)
  bufferIndicator2:setColor(1,0,0,0)
  buffer2Bool = false
 end
 
 if buffer1Bool == true and buffer2Bool == true and buffer3Bool == true and manFlushSafety.state == false
  then
   manFlushIndicator:setColor(1,1,0,1)
   manFlushLEDScreen:setText("Confirm...")
  else
   manFlushIndicator:setColor(1,1,0,0)
 end
 if buffer1Bool == true and buffer2Bool == true and buffer3Bool == true and manFlushSafety.state == true
  then
   bufferIndicator1:setColor(0,1,0,1)
   bufferIndicator2:setColor(0,1,0,1)
   bufferIndicator3:setColor(0,1,0,1)
   manFlushIndicator:setColor(0,1,0,1)
   manFlushLEDScreen:setText("Ready...")
  else
   manFlushIndicator:setColor(1,1,0,1)
 end
 if (buffer1Bool == false or buffer2Bool == false or buffer3Bool == false)
 then
   manFlushLEDScreen:setText("Auto Mode")
  if buffer1Bool == true
   then bufferIndicator1:setColor(1,0,0,1)
   else
    bufferIndicator1:setColor(1,0,0,0)
    manFlushIndicator:setColor(1,1,0,0)
  end
  if buffer2Bool == true
   then bufferIndicator2:setColor(1,0,0,1)
   else
    bufferIndicator2:setColor(1,0,0,0)
    manFlushIndicator:setColor(1,1,0,0)
  end
  if buffer3Bool == true
   then bufferIndicator3:setColor(1,0,0,1)
   else
    bufferIndicator3:setColor(1,0,0,0)
    manFlushIndicator:setColor(1,1,0,0)
  end
 end

--manually flush the buffers when the stop button is pressed
 if s == flushBtn and (buffer1Bool == true and buffer2Bool == true and buffer3Bool == true and manFlushSafety.state == true)
 then
  buffer1:flush()
  buffer2:flush()
  buffer3:flush()
 end
end