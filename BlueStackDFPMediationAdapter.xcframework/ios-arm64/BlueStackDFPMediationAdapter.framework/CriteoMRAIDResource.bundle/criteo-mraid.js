!function(){"use strict";function isFunction(any){return"function"==typeof any}!function(LogLevel){LogLevel.Debug="Debug",LogLevel.Info="Info",LogLevel.Warning="Warning",LogLevel.Error="Error"}(LogLevel=LogLevel||{}),function(MraidEvent){MraidEvent.Ready="ready",MraidEvent.Error="error",MraidEvent.StateChange="stateChange",MraidEvent.ViewableChange="viewableChange"}(MraidEvent=MraidEvent||{});var LogLevel,MraidEvent,MraidState,MraidPlacementType,EventsCoordinator=function(){function EventsCoordinator(){this.eventListeners=new Map(Object.values(MraidEvent).map(function(e){return[e,new Set]}))}return EventsCoordinator.prototype.addEventListener=function(event,listener,logger){var _a;event&&this.isCorrectEvent(event)?listener?isFunction(listener)?null!=(_a=this.eventListeners.get(event))&&_a.add(listener):logger(LogLevel.Error,"addEventListener()","Incorrect listener when addEventListener. \n        Listener is not a function. Actual type = ".concat(typeof listener)):logger(LogLevel.Error,"addEventListener()","Incorrect listener when addEventListener. It is null or undefined"):logger(LogLevel.Error,"addEventListener()","Incorrect event when addEventListener.Type = ".concat(typeof event,", value = ").concat(event))},EventsCoordinator.prototype.removeEventListener=function(event,listener,logger){var listeners;event&&this.isCorrectEvent(event)?listener&&!isFunction(listener)?logger(LogLevel.Error,"removeEventListener()","Incorrect listener when removeEventListener. \n        Listener is not a function. Actual type = ".concat(typeof listener)):(listeners=this.eventListeners.get(event),listener?null!=listeners&&listeners.delete(listener):null!=listeners&&listeners.clear()):logger(LogLevel.Error,"removeEventListener()","Incorrect event when removeEventListener.Type = ".concat(typeof event,", value = ").concat(event))},EventsCoordinator.prototype.fireReadyEvent=function(){var _a;null!=(_a=this.eventListeners.get(MraidEvent.Ready))&&_a.forEach(function(value){null!=value&&value()})},EventsCoordinator.prototype.fireErrorEvent=function(message,action){var _a;null!=(_a=this.eventListeners.get(MraidEvent.Error))&&_a.forEach(function(value){null!=value&&value(message,action)})},EventsCoordinator.prototype.fireStateChangeEvent=function(newState){var _a;null!=(_a=this.eventListeners.get(MraidEvent.StateChange))&&_a.forEach(function(value){null!=value&&value(newState)})},EventsCoordinator.prototype.fireViewableChangeEvent=function(isViewable){var _a;null!=(_a=this.eventListeners.get(MraidEvent.ViewableChange))&&_a.forEach(function(value){null!=value&&value(isViewable)})},EventsCoordinator.prototype.isCorrectEvent=function(event){return event&&this.eventListeners.has(event)},EventsCoordinator}(),ExpandProperties=(!function(MraidState){MraidState.Loading="loading",MraidState.Default="default",MraidState.Expanded="expanded",MraidState.Hidden="hidden"}(MraidState=MraidState||{}),!function(MraidPlacementType){MraidPlacementType.Unknown="",MraidPlacementType.Inline="inline",MraidPlacementType.Interstitial="interstitial"}(MraidPlacementType=MraidPlacementType||{}),function(width,height){this.useCustomClose=!1,this.isModal=!0,this.width=width,this.height=height});var Size=function(width,height){this.width=width,this.height=height},MRAIDImplementation=function(){function MRAIDImplementation(eventsCoordinator,sdkInteractor,logger){this.currentState=MraidState.Loading,this.placementType=MraidPlacementType.Unknown,this.isCurrentlyViewable=!1,this.currentExpandProperties=new ExpandProperties(-1,-1),this.currentMaxSize=new Size(0,0),this.pixelMultiplier=1,this.eventsCoordinator=eventsCoordinator,this.sdkInteractor=sdkInteractor,this.logger=logger,this.spreadMraidInstance()}return MRAIDImplementation.prototype.getVersion=function(){return"1.0"},MRAIDImplementation.prototype.addEventListener=function(event,listener){try{this.eventsCoordinator.addEventListener(event,listener,this.logger.log)}catch(e){this.logger.log(LogLevel.Error,"addEventListener()","error when addEventListener, event = ".concat(event,", listenerType = ").concat(typeof listener))}},MRAIDImplementation.prototype.removeEventListener=function(event,listener){try{this.eventsCoordinator.removeEventListener(event,listener,this.logger.log)}catch(e){this.logger.log(LogLevel.Error,"removeEventListener()","error when removeEventListener, event = ".concat(event,", listenerType = ").concat(typeof listener))}},MRAIDImplementation.prototype.getState=function(){return this.currentState},MRAIDImplementation.prototype.getPlacementType=function(){return this.placementType},MRAIDImplementation.prototype.isViewable=function(){return this.isCurrentlyViewable},MRAIDImplementation.prototype.expand=function(url){this.canPerformActions()?this.placementType===MraidPlacementType.Interstitial?this.logger.log(LogLevel.Error,"expand()","can't expand interstitial ad"):null!=url?this.logger.log(LogLevel.Error,"expand()","two-part expandable ads are not supported"):this.sdkInteractor.expand(this.currentExpandProperties.width,this.currentExpandProperties.height):this.logger.log(LogLevel.Error,"expand()","can't expand in ".concat(this.currentState," state"))},MRAIDImplementation.prototype.getExpandProperties=function(){var width=-1===this.currentExpandProperties.width?this.currentMaxSize.width*this.pixelMultiplier:this.currentExpandProperties.width,height=-1===this.currentExpandProperties.height?this.currentMaxSize.height*this.pixelMultiplier:this.currentExpandProperties.height;return new ExpandProperties(width,height)},MRAIDImplementation.prototype.setExpandProperties=function(properties){var _a;this.isCorrectProperties(properties)&&(this.currentExpandProperties.width=null!=(_a=properties.width)?_a:-1,this.currentExpandProperties.height=null!=(_a=properties.height)?_a:-1)},MRAIDImplementation.prototype.close=function(){this.sdkInteractor.close()},MRAIDImplementation.prototype.useCustomClose=function(useCustomClose){this.logger.log(LogLevel.Warning,"useCustomClose()","useCustomClose() is not supported")},MRAIDImplementation.prototype.open=function(url){url?"string"==typeof url?this.sdkInteractor.open(url):url instanceof URL?this.sdkInteractor.open(url.toString()):this.logger.log(LogLevel.Error,"open()","Error when open(), url is not a string"):this.logger.log(LogLevel.Error,"open()","Error when open(), url is null, empty or undefined")},MRAIDImplementation.prototype.notifyReady=function(placementType){this.logger.log(LogLevel.Debug,"notifyReady()","placementType=".concat(placementType)),this.placementType=placementType,this.setReady()},MRAIDImplementation.prototype.notifyError=function(message,action){this.eventsCoordinator.fireErrorEvent(message,action)},MRAIDImplementation.prototype.setIsViewable=function(isViewable){this.logger.log(LogLevel.Debug,"setIsViewable()","isViewable=".concat(isViewable)),this.isCurrentlyViewable!==isViewable&&(this.isCurrentlyViewable=isViewable,this.eventsCoordinator.fireViewableChangeEvent(isViewable))},MRAIDImplementation.prototype.setMaxSize=function(width,height,pixelMultiplier){this.currentMaxSize.width=width,this.currentMaxSize.height=height,this.pixelMultiplier=pixelMultiplier},MRAIDImplementation.prototype.notifyClosed=function(){this.canPerformActions()?this.currentState===MraidState.Expanded?this.updateState(MraidState.Default):this.currentState===MraidState.Default&&this.updateState(MraidState.Hidden):this.logger.log(LogLevel.Warning,"notifyClosed()","can't close in ".concat(this.currentState," state"))},MRAIDImplementation.prototype.notifyExpanded=function(){switch(this.currentState){case MraidState.Default:this.updateState(MraidState.Expanded);break;case MraidState.Expanded:this.logger.log(LogLevel.Warning,"notifyExpanded()","ad is already expanded");break;case MraidState.Loading:case MraidState.Hidden:this.logger.log(LogLevel.Warning,"notifyExpanded()","can't expand from ".concat(this.currentState))}},MRAIDImplementation.prototype.updateState=function(newState){this.currentState=newState,this.eventsCoordinator.fireStateChangeEvent(newState)},MRAIDImplementation.prototype.setReady=function(){this.currentState===MraidState.Loading&&(this.updateState(MraidState.Default),this.eventsCoordinator.fireReadyEvent())},MRAIDImplementation.prototype.canPerformActions=function(){return this.currentState!==MraidState.Loading&&this.currentState!==MraidState.Hidden},MRAIDImplementation.prototype.isCorrectProperties=function(properties){var width,height,useCustomClose,isModal;return function(properties){var hasAnyProperty;if(null!=properties&&"object"==typeof properties)return hasAnyProperty=!1,Object.keys(new ExpandProperties(0,0)).forEach(function(property){Object.prototype.hasOwnProperty.call(properties,property)&&(hasAnyProperty=!0)}),0===Object.keys(properties).length||hasAnyProperty}(properties)?(width=properties.width,height=properties.height,useCustomClose=properties.useCustomClose,isModal=properties.isModal,!!this.isCorrectDimension(width)&&!!this.isCorrectDimension(height)&&(useCustomClose&&this.logger.log(LogLevel.Warning,"setExpandProperties()","useCustomClose is not supported"),null==isModal||isModal||this.logger.log(LogLevel.Warning,"setExpandProperties()","isModal property is readonly and always equals to true"),!0)):(this.logger.log(LogLevel.Error,"setExpandProperties()","properties is ".concat(properties)),!1)},MRAIDImplementation.prototype.isCorrectDimension=function(dimension){return!(dimension&&("number"!=typeof dimension?(this.logger.log(LogLevel.Error,"setExpandProperties()","width is not a number, width is ".concat(typeof dimension)),1):!this.isInAcceptedBounds(dimension)&&(this.logger.log(LogLevel.Error,"setExpandProperties()","width is ".concat(dimension)),1)))},MRAIDImplementation.prototype.isInAcceptedBounds=function(number){return Number.isFinite(number)&&0<=number},MRAIDImplementation.prototype.spreadMraidInstance=function(){for(var _a,_b,iframes=document.getElementsByTagName("iframe"),i=0;i<iframes.length;i+=1){var iframe=iframes[i];if(iframe.contentWindow)try{iframe.contentWindow.mraid=null!=(_a=iframe.contentWindow.mraid)?_a:this}catch(_c){}}if(window.top)try{window.top.mraid=null!=(_b=window.top.mraid)?_b:this}catch(_d){}},MRAIDImplementation}(),IosMraidBridge=function(){function IosMraidBridge(){}return IosMraidBridge.prototype.log=function(logLevel,message,logId){this.postMessage({action:"log",logLevel:logLevel,message:message,logId:logId})},IosMraidBridge.prototype.open=function(url){this.postMessage({action:"open",url:url})},IosMraidBridge.prototype.expand=function(width,height){this.postMessage({action:"expand",width:width,height:height})},IosMraidBridge.prototype.close=function(){this.postMessage({action:"close"})},IosMraidBridge.prototype.postMessage=function(message){var _a;null!=(_a=null==(_a=null==(_a=null===window||void 0===window?void 0:window.webkit)?void 0:_a.messageHandlers)?void 0:_a.criteoMraidBridge)&&_a.postMessage(message)},IosMraidBridge}(),AndroidMraidBridge=function(){function AndroidMraidBridge(){}return AndroidMraidBridge.prototype.log=function(logLevel,message,logId){var _a;null!=(_a=this.getMraidBridge())&&_a.log(logLevel,message,logId)},AndroidMraidBridge.prototype.open=function(url){var _a;null!=(_a=this.getMraidBridge())&&_a.open(url)},AndroidMraidBridge.prototype.expand=function(width,height){var _a;null!=(_a=this.getMraidBridge())&&_a.expand(width,height)},AndroidMraidBridge.prototype.close=function(){var _a;null!=(_a=this.getMraidBridge())&&_a.close()},AndroidMraidBridge.prototype.getMraidBridge=function(){var _a;return null!=(_a=null===window||void 0===window?void 0:window.criteoMraidBridge)?_a:null==(_a=null===window||void 0===window?void 0:window.top)?void 0:_a.criteoMraidBridge},AndroidMraidBridge}(),SdkInteractor=function(){function SdkInteractor(bridges){this.bridges=bridges}return SdkInteractor.prototype.log=function(logLevel,message,logId){void 0===logId&&(logId=null),this.callForAll(function(bridge){bridge.log(logLevel,message,logId)})},SdkInteractor.prototype.open=function(url){this.callForAll(function(bridge){bridge.open(url)})},SdkInteractor.prototype.expand=function(width,height){this.callForAll(function(bridge){bridge.expand(width,height)})},SdkInteractor.prototype.close=function(){this.callForAll(function(bridge){bridge.close()})},SdkInteractor.prototype.callForAll=function(lambda){this.bridges.forEach(function(bridge){lambda(bridge)})},SdkInteractor}(),Logger=function(){function Logger(eventsCoordinator,sdkInteractor){this.eventsCoordinator=eventsCoordinator,this.sdkInteractor=sdkInteractor}return Logger.prototype.log=function(logLevel,method,message){this.sdkInteractor.log(logLevel,"".concat(method,", ").concat(message)),logLevel===LogLevel.Error&&this.eventsCoordinator.fireErrorEvent(message,method)},Logger}(),SdkInteractor=new SdkInteractor([new IosMraidBridge,new AndroidMraidBridge]),IosMraidBridge=new EventsCoordinator,AndroidMraidBridge=new Logger(IosMraidBridge,SdkInteractor);window.mraid=null!=(EventsCoordinator=window.mraid)?EventsCoordinator:new MRAIDImplementation(IosMraidBridge,SdkInteractor,AndroidMraidBridge)}();