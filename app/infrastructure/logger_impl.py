import logging
from app.interfaces.logger_interface import ILogger
from colorama import Fore, Style

class Logger(ILogger):
    def __init__(self):
        self.logger = logging.getLogger("app")
        self.logger.setLevel(logging.DEBUG)
        handler = logging.StreamHandler()
        formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)

    def info(self, message: str):
        self.logger.info(Fore.GREEN + message + Style.RESET_ALL)

    def error(self, message: str):
        self.logger.error(Fore.RED + message + Style.RESET_ALL)