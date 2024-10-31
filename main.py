from app.infrastructure.config import load_config
from app.infrastructure.smb_repository_impl import SMBRepository
from app.infrastructure.logger_impl import Logger
from app.use_cases.access_shared_folder import AccessSharedFolderUseCase
from app.domain.entities import SMBFilePath
from app.domain.exceptions import ConfigurationException

def main():
    logger = Logger()
    config = load_config(logger)
    smb_repository = SMBRepository(
        server=config.smb_server,
        username=config.smb_username,
        password=config.smb_password,
        share_name=config.smb_share,
        logger=logger
    )
    use_case = AccessSharedFolderUseCase(smb_repository, logger)
    file_path = SMBFilePath(config.smb_file_path)
    logger.info(f"Archivo que servira demostrar el acceso al compartido: {file_path.path}")
    data = use_case.execute(file_path)
    print("Contenido del archivo:", data.content.decode())

if __name__ == "__main__":
    main()