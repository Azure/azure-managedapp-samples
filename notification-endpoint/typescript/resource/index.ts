import { AzureFunction, Context, HttpRequest } from "@azure/functions"

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
    context.log('HTTP trigger function processed a request.');
    var data = req.body;
    
    try {
        if (data) {
            context.log(req.body);
            context.res = {
                // status: 200, /* Defaults to 200 */
                body: "Processed"
            };
        }
        else {
            context.res = {
                status: 400,
                body: "Please POST data in the message body."
            };
        }
    } catch(e) {
        if (e instanceof Error) {
            context.log.error(e.message);
        }
        else {
            context.log.error("An unknown error occurred of type " + e.constructor.name);
        }
        context.res = {
            status: 500,
            body: "An error occurred and has been logged."
        }; 
    }
};

export default httpTrigger;
