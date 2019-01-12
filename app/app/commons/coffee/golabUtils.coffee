"use strict";

window.ut = window.ut || {}
ut.commons = ut.commons || {}

angular = window.angular

ut.commons.golabUtils = angular.module('golabUtils', [])

ut.commons.golabUtils.factory("browser",->
  # from http://stackoverflow.com/questions/9847580/how-to-detect-safari-chrome-ie-firefox-and-opera-browser
  testCSS = (prop)->
    prop of document.documentElement.style;
  # At least Safari 3+: "[object HTMLElementConstructor]"
  isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
  browser = {
    isOpera: !!(window.opera && window.opera.version)  # Opera 8.0+
    isFirefox: testCSS('MozBoxSizing')                 # FF 0.8+
    isSafari: isSafari
    isChrome:  !isSafari && testCSS('WebkitTransform')  # Chrome 1+
    isIE: false || testCSS('msTransform')  # At least IE6
    isWebKit: testCSS('WebkitTransform')
  }
#  console.log("browser: " + JSON.stringify(browser))
  browser
)

getCssPixelValue = (element,cssName) ->
  value = element.css(cssName)
  parseInt(value)

ut.commons.golabUtils.directive("golabcontainer", () ->
  {
  restrict: "E"
  scope: {
    containertitle: "@"
  }
  template: """
            <div class="golabContainer">
              <div class="golabContainerHeader">
                <img src="{{minimizeImage}}" class="golabContainerMinimizeButton activeButton"
                  ng-click="toggleMinimize()" ng-show="showMinimize"/>
                <span class="golabContainerTitle">{{containertitle}}</span>
              </div>
              <div class="golabContainerContent">
                <div ng-transclude></div>
              </div>
            </div>
            """
  replace: true
  transclude: true
  link: (scope, element, attrs)->
    sizeComponentSelector = ut.commons.utils.getAttributeValue(attrs,"sizeComponent","")
    if (sizeComponentSelector)
      sizeComponent = element.find(sizeComponentSelector)
      if (sizeComponent && sizeComponent.length)
        if (sizeComponent.prop("tagName")=="TEXTAREA")
          sizeComponent.css("resize","none")
        scope.element = element
        oldHeight = element.height()
        adjustHeight = ->
          newHeight = scope.element.height()
          #          console.log("#{scope.containertitle}.height(): #{newHeight}")
          sizeComponent.height(sizeComponent.height()+newHeight-oldHeight)
          oldHeight = newHeight
        scope.$watch("element.height()", (newHeight)->
          if (oldHeight!=newHeight)
            setTimeout(adjustHeight,10)
        )
    scope.showMinimize = false
    minimizeDirection = ut.commons.utils.getAttributeValue(attrs,"minimize","").toLowerCase()
    minimizeClassExtension = ""
    minimizeVertical = false
    switch minimizeDirection
      when ""
        minimizeClassExtension = ""
      when "vertical"
        minimizeClassExtension = "Vertical"
        minimizeVertical = true
      when "horizontal"
        minimizeClassExtension = "Horizontal"
      else
        console.log("unknown minimize value: #{minimizeDirection}")
    if (minimizeClassExtension)
      scope.showMinimize = true
      golabContainer = element
      golabContainerHeader = golabContainer.find(".golabContainerHeader")
      golabContainerContent = golabContainer.find(".golabContainerContent")
      golabContainerTitle = golabContainer.find(".golabContainerTitle")
      minimized = false
      minimizeImage = "#{ut.commons.utils.commonsImagesPath}minimize.png"
      unminimizeImage = "#{ut.commons.utils.commonsImagesPath}unminimize.png"
      scope.minimizeImage = minimizeImage
      headerHeight = golabContainerHeader.height()
      contentHeight = golabContainerContent.height()
      containerHeight = golabContainer.height()
      scope.toggleMinimize = ->
        if (minimized)
          element.removeClass("golabContainerMinimized#{minimizeClassExtension}")
          golabContainerContent.removeClass("golabContainerContentMinimized")
          if (minimizeVertical)
            golabContainerTitle.removeClass("golabContainerTitleVertical")
            golabContainer.height(containerHeight)
          scope.minimizeImage = minimizeImage
        else
          containerHeight = golabContainer.height()
          element.addClass("golabContainerMinimized#{minimizeClassExtension}")
          golabContainerContent.addClass("golabContainerContentMinimized")
          if (minimizeVertical)
            contentHeight = golabContainerContent.height()
            golabContainerTitle.addClass("golabContainerTitleVertical")
            newContainerHeight = headerHeight+golabContainerTitle.width() - 1 +
              getCssPixelValue(golabContainerTitle,"padding-left")+getCssPixelValue(golabContainerTitle,"padding-right")
#            console.log("newContainerHeight: #{newContainerHeight}")
            golabContainer.height(newContainerHeight)
          scope.minimizeImage = unminimizeImage
        minimized = !minimized
  }
)
