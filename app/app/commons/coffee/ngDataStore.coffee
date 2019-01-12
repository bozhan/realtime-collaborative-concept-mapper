"use strict";

window.ut = window.ut || {}
ut.commons = ut.commons || {}

angular = window.angular

dummy = {
  loadDataFromJson: null
}

ut.commons.golabUtils.directive("datastoreselection", (localStorageService) ->
  {
  restrict: "E"
  template: """
            <table width="100%">
                <tr>
                    <td>
                        Category:
                        <select ng-model="selectedCategory"
                                ng-options="category for category in dataStore.getCategories()">
                        </select>
                        <br/>
                        Data:
                        <select ng-model="selectedData" ng-options="data.title for data in getDatas()">
                        </select>
                    </td>
                    <td align="right">
                        <button ng-click="reload()">reload</button>
                        <br/>
                        <button ng-click="clearData()">clear</button>
                    </td>
                </tr>
            </table>
            """
  replace: true
  link: (scope, element,attrs)->
    dataStoreName = ut.commons.utils.getAttributeValue(attrs,"dataStoreName")
    if (dataStoreName==null)
      throw new Error("attribute dataStoreName is not defined")
    selectedCategoryStoreName = "#{dataStoreName}_selectedCategory"
    selectedDataTitleStoreName = "#{dataStoreName}_selectedDataTitle"
    if (!scope[dataStoreName])
      throw new Error("cannot find data store, named '#{dataStoreName}' on the scope")
    scope.dataStore = scope[dataStoreName]
    scope.selectedCategory = localStorageService.get(selectedCategoryStoreName)
    scope.selectedData = ""
    if (scope.selectedCategory)
      selectedDataTitle = localStorageService.get(selectedDataTitleStoreName)
      if (selectedDataTitle)
        selectedData = scope.dataStore.getData(scope.selectedCategory, selectedDataTitle)
      if (selectedData)
        scope.selectedData = selectedData
    else
      scope.selectedCategory = ""

    scope.getDatas = ->
      scope.dataStore.getDatas(scope.selectedCategory)

    initialized = false
    scope.$watch("selectedCategory", ->
      localStorageService.set(selectedCategoryStoreName, scope.selectedCategory)
      if (initialized)
        scope.selectedData = ""
      else
        initialized = true
    )
    loadData = ->
      if (scope.selectedCategory && scope.selectedData)
        console.log("load data: category #{scope.selectedCategory}, data #{scope.selectedData.title}")
        scope.dataStore.sendLoadEvent(scope.selectedData)
#        if (scope.loadDataFromJson)
#          scope.loadDataFromJson(scope.selectedData)
#        else
#          console.log("cannot load data, because cannot find scope.loadDataFromJson")
    scope.$watch("selectedData", ->
      localStorageService.set(selectedDataTitleStoreName, scope.selectedData.title)
      loadData()
    )
    scope.reload = ->
      loadData()
  }
)
