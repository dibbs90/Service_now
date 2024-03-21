(function process( /*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
 
    try {
        var queryParams = request.queryParams;
        var tableName = queryParams.tableName;
        var query = queryParams.tableQuery;
        var result = [];
        var attachGr = new GlideRecord('sys_attachment');
        attachGr.addQuery('table_name', tableName);
        attachGr.addQuery('file_nameISNOTEMPTY');
        attachGr.orderBy('sys_created_on');
        if(query){
            attachGr.addQuery(query);
        }
        attachGr.query();
        while (attachGr.next()) {
            var taskNumber = getTaskDetails(attachGr.getValue('table_sys_id'));
            if (taskNumber == '')
                continue;
            var fileName = attachGr.getValue('file_name');
            var obj = {
                file_name: taskNumber + '_' +fileName,
                download_link: gs.getProperty('glide.servlet.uri') + 'api/now/attachment/' + attachGr.getUniqueValue() + '/file',
                sys_id: attachGr.getUniqueValue()
            };
            result.push(obj);
        }
 
        response.setBody(result);
        response.setStatus(200);
    } catch (e) {
        response.setError(new sn_ws_error.BadRequestError('e'));
        response.setStatus(400);
    }
 
 
    function getTaskDetails(recordId) {
        var taskGr = new GlideRecord(tableName);
        if (taskGr.get(recordId) && taskGr.isValidRecord()) {
            return taskGr.getValue('number');
        }
        return '';
    }
 
 
 
})(request, response);