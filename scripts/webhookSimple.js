try {
    /* Script Webhook no Zabbix */

    /* Doc: https://www.zabbix.com/documentation/current/en/manual/config/notifications/media/webhook */

    /* Pego os parâmetros e os valores. */
    var params = JSON.parse(value)
    Zabbix.Log(4, 'API Webhook com os seguintes parametros: ' + params)     
    var req = new CurlHttpRequest()
    req.AddHeader('Content-Type: application/json');

    /* Vou criar uma lista com os valores dos parametros */
    var fields = {}
    fields.phone = params.phone
    fields.message = params.message
    
    /* Monto a URL da API com os valores dos parametros */
    resp = req.Post(params.URL,
        JSON.stringify(fields)
    );
 
    /* Gero resposta de erro. */
    if (req.Status() != 200) {
        throw 'Response code: ' + req.Status();
    }

    return 'OK';
}
catch (error) {
     throw 'Failed with error: ' + error;
}