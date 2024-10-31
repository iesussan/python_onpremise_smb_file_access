import os
from dataclasses import dataclass
from app.domain.exceptions import ConfigurationException
from app.interfaces.logger_interface import ILogger

@dataclass
class Config:
    smb_server: str
    smb_username: str
    smb_password: str
    smb_share: str
    smb_file_path: str

def load_config(logger: ILogger) -> Config:
    try:
        smb_server = os.environ["SMB_SERVER"]
        smb_username = os.environ["SMB_USERNAME"]
        smb_password = os.environ["SMB_PASSWORD"]
        smb_share = os.environ["SMB_SHARE"]
        smb_file_path = os.environ.get("SMB_FILE_PATH")
        return Config(
            smb_server=smb_server,
            smb_username=smb_username,
            smb_password=smb_password,
            smb_share=smb_share,
            smb_file_path=smb_file_path
        )
    except KeyError as e:
        missing_key = e.args[0]
        logger.error(f"La variable de entorno '{missing_key}' no está definida.")
        raise ConfigurationException(f"La variable de entorno '{missing_key}' no está definida.") from e