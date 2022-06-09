import requests
import logging
import pprint

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

try:
    logging.info("Below is the response for the latest release of the repo.")

    response = requests.get("https://api.github.com/repos/RahulARanger/RashSetup/releases/latest")
    response.raise_for_status()
    
    pprint.pprint(response.json(), indent=4)

except requests.exceptions.RequestException as e:
    logging.error(e)


# while True:
#     ...

