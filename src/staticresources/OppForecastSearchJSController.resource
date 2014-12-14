
var oppForecast = function() {
    var selectedMonth;
    var selectedYear;
    var paramQuery;
    var months;
    var allColumns;
    var userSessionId = $("#userSessionId").val();
    var $grid;

    getDefaultColModel = function() {
        var oppForecastColModel = [
               { 
                    title: "Id", //title of column. 
                    width: 150, //initial width of column
                    dataType: "string", //data type of column
                    dataIndx: "id", //should match one of the keys in row data.
                    hidden: true,
                    editable: false
                },
                { 
                    title: "End Customer", //title of column. 
                    width: 150, //initial width of column
                    dataType: "string", //data type of column
                    dataIndx: "endCustomerAccount", //should match one of the keys in row data.
                    hidden: $("#endCustomerAccount").prop("checked")==false ? true : false,
                    editable: false
                },
                { 
                    title: "Market Segment", 
                    width: 150, 
                    dataType: "string", 
                    align: "right", 
                    dataIndx: "marketSegment",
                    hidden: $("#marketSegment").prop("checked")==false ? true : false,
                    editable: false
                },
                { 
                title: "Project Name", 
                    width: 150, 
                    dataType: "string", 
                    align: "right", 
                    dataIndx: "projectName",
                    hidden: $("#projectName").prop("checked")==false ? true : false,
                    editable: false
                },
                { 
                    title: "Product", 
                    width: 200, 
                    dataType: "string", 
                    dataIndx: "product",
                    hidden: $("#product").prop("checked")==false ? true : false,
                    editable: false
                },
                { 
                    title: "Contract Manufacturer", 
                    width: 150, 
                    dataType: "string", 
                    align: "right", 
                    dataIndx: "contractManufacturer",
                    hidden: $("#contractManufacturer").prop("checked")==false ? true : false,
                    editable: false
                },
                { 
                    title: "Distributor", 
                    width: 150, 
                    dataType: "string", 
                    align: "right", 
                    dataIndx: "distributor",
                    hidden: $("#distributor").prop("checked")==false ? true : false,
                    editable: false
                },

                 { 
                    title: "Values", 
                    width: 150, 
                    dataType: "string", 
                    align: "right", 
                    dataIndx: "values",
                    editable: false
                }
             ];
        return oppForecastColModel;

    }

    init = function() {
        selectedMonth = $("#month").html();
        selectedYear = $("#year").html();;
        $("#loading").show();
        $("#grid_column").hide();
        $("#grid_json").css({"visibility":"hidden"});
        paramQuery = {  
                        showBottom:false,
                        numberCell:{show:false},
                        trackModel: { on: true },
                        scrollModel:{autoFit:true, theme:true},
                        selectionModel: { type: 'cell' },
                        wrap: false, 
                        width:"100%",
                        height:600,
                        editModel:{clicksToEdit: 2},
                        title: "<h1><b>Opportunity Forecast management</b></h1>",
                        colModel: getDefaultColModel(),
                        virtualX: true, virtualY: true,
                        resizable: true,
                        sortable:false,
                        columnBorders:false,

                        groupModel:{
                            dataIndx: ["id"],                
                            title: ["<div class='idHidden'>{0}</div><div class='overwrite' style='margin-left:-129px; font-weight:bold;'> &nbsp;&nbsp; ({1} records)</div>","{0} - {1}"]
                            },
                        dataModel:{
                                    data:{},
                                    location: "remote",
                                    dataType: "JSON",
                                    method: "GET",
                                    url: "remoteAction"
                                    },
                        change: function (evt, ui) {
                                    //debugger;
                                    if (ui.source == 'commit' || ui.source == 'rollback') {
                                        return;
                                    }

                                    var $grid = $(this),
                                        grid = $grid.pqGrid('getInstance').grid;
                                    var rowList = ui.rowList,
                                        recIndx = grid.option('dataModel').recIndx,
                                        updateList = [];
                                    for (var i = 0; i < rowList.length; i++) {
                                        var obj = rowList[i],
                                            rowIndx = obj.rowIndx,
                                            newRow = obj.newRow,
                                            type = obj.type,
                                            rowData = obj.rowData;
                                        if (type == 'update') {
                                            var valid = grid.isValid({ rowData: rowData, allowInvalid: true }).valid;
                                            if (valid) {
                                                if(grid.updateList === undefined){
                                                    grid.updateList = [];
                                                }
                                                grid.updateList.push(rowData);
                                            }
                                        }

                                    }
                                    if (grid.updateList.length) {
                                        grid.isDirty = true;
                                    }
                                } 
                      };

        getMonthYear();

                
    }
    getMonthYear = function() {
       renderColumns();
       OppForecastRemoteController.getMonthYears(selectedMonth, selectedYear, function(result, event){
           if(event.status) {
                var monthsCol = [];
                for(i=0; i<result.length; i++) {
                    var title = {title: result[i], width:100, dataType: "string", dataIndx: result[i], editable: "true", 
                    render: function(ui){
                        if(ui.cellData !== "" && ui.cellData !== undefined){
                            return ui.cellData;
                        }
                        var cellData = ui.rowData['monthYear'][ui.dataIndx];
                        var myObj = {ASP__c:0.0, KU__c:0, Revenue__c:0, Id:''};
                        if(cellData !== undefined) {
                            myObj = cellData;

                        }
                        if(ui.rowData.recordType === 'asp'){
                            return myObj.ASP__c;        
                        }else if(ui.rowData.recordType === 'ku'){
                            return myObj.KU__c;        
                        }else if(ui.rowData.recordType === 'revenue'){
                            return myObj.Revenue__c;        
                        }
                        return '0';
                    },
                   editable: function(ui){
                     if(ui.rowData.recordType === 'revenue'){
                        return false;
                     }
                     return true;
                   } 
                    };
                    monthsCol.push(title);
                }
                paramQuery.colModel = paramQuery.colModel.concat(monthsCol); 
                getOppForecastData();
           }      
       });
    }


    renderColumns = function() {
        if($(grid_column).children() == null || $(grid_column).children().length ==0) {
            var labelHTML = "<h3><span class='label label-default'>Please Select Field To Hide Or Show</span></h3>";
            $(grid_column).append(labelHTML);
            $(paramQuery.colModel).each(function(){
            if(this.dataIndx == 'values'){
                return false;
            }
            
            var checkBoxHTML = "<label class='btn btn-primary active' title = 'select field to hide or show' data-placement='top' data-toggle='tooltip'>";
                checkBoxHTML += "<input type='checkbox' checked name='headerColumn' id='" + this.dataIndx + "'/>" + this.dataIndx;
                checkBoxHTML += "</label>";
                $(grid_column).append(checkBoxHTML);
            });            
        }
        $('[data-toggle="tooltip"]').tooltip();
    }

    getOppForecastData = function() {
        OppForecastRemoteController.searchOppForecast($("#opportunity").attr("value"), $("#groupColumnName").attr("value"), selectedMonth, selectedYear, function(result, event) {
            if(event.status) {
                $.each(result, function(index, value){
                    var keys = Object.keys(value.monthYear);
                    for(var i=0; i<keys.length; i++){
                        if(value.recordType === 'asp') {
                            value[keys[i]] = value.monthYear[keys[i]].ASP__c;    
                        }else if(value.recordType === 'ku'){
                            value[keys[i]] = value.monthYear[keys[i]].KU__c;        
                        }else if(value.recordType === 'revenue'){
                            value[keys[i]] = value.monthYear[keys[i]].Revenue__c;        
                        }
                    }
                });
                paramQuery.dataModel = {data:result};
                renderGrid();
           }  

        }); 
    }

    renderGrid = function() {
       $grid = $("#grid_json").pqGrid(paramQuery);
       $("#grid_json").pqGrid("option",  "dataModel.sortIndx", "values");
       $("#grid_json").pqGrid( {sortable:false} );
       $("#grid_json").pqGrid("refreshDataAndView");
        $("#loading").hide();
        $("#grid_column").show();
        $("#grid_json").css({"visibility":"visible"});

    }

    saveChanges = function() {
        var grid = $grid.pqGrid('getInstance').grid;
        debugger;
        //attempt to save editing cell.
        if (grid.saveEditCell() === false) {
            return false;
        }
        var isDirty = grid.isDirty;
        if (isDirty) {
            //validate the new updated rows.                
            var updateList = grid.updateList;
            //debugger;
            for (var i = 0; i < updateList.length; i++) {
                var rowData = updateList[i];
                var isValid = grid.isValid({ "rowData": rowData }).valid;
                if (!isValid) {
                    return;
                }
            }
            console.log("updateList is", updateList);
            var inputJson = JSON.stringify(updateList);
            inputJson = '{ \"rowList\":' + inputJson + '}';
            //start calling remote controller to update
            OppForecastRemoteController.updateOppForecastLineItems(inputJson, $("#month").html(), $("#year").html(), function(result, event){
                if(event.status){
                    grid.commit({ type: 'update', rows: result });
                }
            });
 
        }
    }

    return {
        getDefaultColModel:getDefaultColModel, saveChanges:saveChanges, init:init, getMonthYear:getMonthYear, getOppForecastData:getOppForecastData, renderGrid:renderGrid, renderColumns:renderColumns
    }
}

/*
 * Opportunity Forecast Line Item event:
 * Onclick will change the label to be input text;
 * mouse move out will update the value;
 */
var oppForecastLineItem = function(html, id) {

    editable = function() {
        var itemValue = $(html).find("span.value").html();
        var inputTextHTML = "<input type='text' onblur=oppForecastLineItem(this,'"+ id +  "').update() value='" + itemValue + "'/>";
        $(html).hide();
        $(html).next().show();
        $(html).next().focus();
    }

    update = function() {
        var inputType = $(html).attr("name");
        var inputValue = $(html).val();
        $(html).hide();
        $(html).prev().show();
        OppForecastRemoteController.updateOppForecastLineItem(inputValue, inputType, id, function(result, event){
            if(event.status){
                if(inputType === 'asp') {
                    $(html).prev().find('span.value').html(result.ASP__c);
                }else {
                    $(html).prev().find('span.value').html(result.KU__c);
                }
                $(html).parent().find('span.revenue').html(result.Revenue__c);
            }
        });

    }

    return {
        editable:editable, update:update
    }
}



$(document).ready(function(){
    $("#massSave").click(function(){
        search.saveChanges();
    });

    $("#refresh").click(function(){
        $("#loading").show();
        $("#grid_column").hide();
        $("#grid_json").css({"visibility":"hidden"});
        var newOppForecastColModel = [];
        OppForecastRemoteController.searchOppForecast($("#opportunity").attr("value"), $("#groupColumnName").attr("value"), $("#month").html(), $("#year").html(), function(result, event) {
            if(event.status) {
                $.each(result, function(index, value){
                    var keys = Object.keys(value.monthYear);
                    for(var i=0; i<keys.length; i++){
                        console.log("get month year", value.monthYear);
                        if(value.recordType === 'asp') {
                            value[keys[i]] = value.monthYear[keys[i]].ASP__c;    
                        }else if(value.recordType === 'ku'){
                            value[keys[i]] = value.monthYear[keys[i]].KU__c;        
                        }else if(value.recordType === 'revenue'){
                            value[keys[i]] = value.monthYear[keys[i]].Revenue__c;        
                        }
                    }
                });

        OppForecastRemoteController.getMonthYears($("#month").html(), $("#year").html(), function(newMonths, event){
           if(event.status) {
                for(i=0; i<newMonths.length; i++) {
                    var title = {title: newMonths[i], width:100, dataType: "string", dataIndx: newMonths[i], editable: "true", 
                    render: function(ui){
                        if(ui.cellData !== "" && ui.cellData !== undefined){
                            return ui.cellData;
                        }
                        var cellData = ui.rowData['monthYear'][ui.dataIndx];
                        var myObj = {ASP__c:0.0, KU__c:0, Revenue__c:0, Id:''};
                        if(cellData !== undefined) {
                            myObj = cellData;

                        }
                        if(ui.rowData.recordType === 'asp'){
                            return myObj.ASP__c;        
                        }else if(ui.rowData.recordType === 'ku'){
                            return myObj.KU__c;        
                        }else if(ui.rowData.recordType === 'revenue'){
                            return myObj.Revenue__c;        
                        }
                        return '0';
                    },
                   editable: function(ui){
                     if(ui.rowData.recordType === 'revenue'){
                        return false;
                     }
                     return true;
                   } 
                    };
                    newOppForecastColModel.push(title);
                }
            $("#grid_json").pqGrid("option",  "dataModel.sortIndx", "values");
            $("#grid_json").pqGrid( "option", "dataModel.data", result );
            $("#grid_json").pqGrid( "option", "colModel", search.getDefaultColModel().concat(newOppForecastColModel));
            $("#grid_json").pqGrid("refreshDataAndView");
            $("#loading").hide();
            $("#grid_column").show();
            $("#grid_json").css({"visibility":"visible"});
        }
    });}
    });
    });
    $(".dropdown-menu li a").click(function(){
          $(this).parents(".btn-group").find('.selection').text($(this).text());
          $(this).parents(".btn-group").find('.selection').val($(this).text());
          $(this).parents(".btn-group").find('.selection').attr("value", $(this).attr("value"));
    });
    var search = oppForecast();
    search.init();
});
