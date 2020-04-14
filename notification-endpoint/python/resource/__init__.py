import logging
import json
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
        request_as_text = json.dumps(req_body, default=lambda o: o.__dict__)
        logging.info(request_as_text)
    except e as Exception:
        logging.exception(e)
        return func.HttpResponse(
            "An error occurred.",
            status_code=500
        )

    return func.HttpResponse(f"Success")
